--[[
Title: Import_bmax.lua
Author(s): leio
Date: 2017/6/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Import_bmax.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/STLExporter/BMaxModel.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)script/ide/System/Core/Color.lua");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local vector3d = commonlib.gettable("mathlib.vector3d");
local BMaxModel = commonlib.gettable("Mod.STLExporter.BMaxModel");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local Color = commonlib.gettable("System.Core.Color");

local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;

function NplCadEnvironment.import_bmax(options)
	local self = getfenv(2);
	return self:import_bmax__(options);
end
function NplCadEnvironment:import_bmax__(options)
	local parent = self:getNode__();
    local node = NplCadEnvironment.read_import_bmax(options);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_import_bmax(options)
    options = options or {};
    local filename = options.path;
    local version = options.version;
    local node;
    version = version or 1;
     if(version == 1)then
	    node = NplCadEnvironment.read_import_bmax1(filename);
    else
	    node = NplCadEnvironment.read_import_bmax2(filename);
    end
    return node;
end
function NplCadEnvironment.read_import_bmax1(filename)
	local node = Node.create("");
    local model = BMaxModel:new();
	model:Load(filename);

    local function write_face(polygons,vertex_1,vertex_2,vertex_3)
		local a = vertex_3 - vertex_1;
		local b = vertex_3 - vertex_2;
		local normal = a*b;
		normal:normalize();

        local vertices = {};
        --bmax:y up lefthand
        table.insert(vertices,CSGVertex:new():init(vector3d:new(vertex_1[1],vertex_1[2],vertex_1[3]),normal));
		table.insert(vertices,CSGVertex:new():init(vector3d:new(vertex_2[1],vertex_2[2],vertex_2[3]),normal));
		table.insert(vertices,CSGVertex:new():init(vector3d:new(vertex_3[1],vertex_3[2],vertex_3[3]),normal));

--		table.insert(vertices,CSGVertex:new():init(vector3d:new(vertex_1[1],vertex_1[3],vertex_1[2]),normal));
--		table.insert(vertices,CSGVertex:new():init(vector3d:new(vertex_3[1],vertex_3[3],vertex_3[2]),normal));
--		table.insert(vertices,CSGVertex:new():init(vector3d:new(vertex_2[1],vertex_2[3],vertex_2[2]),normal));

        local polygon = CSGPolygon:new():init(vertices);
		table.insert(polygons,polygon);
    end
    for _, cube in ipairs(model.m_blockModels) do
        local polygons = {};
        local bmax_node = cube:GetTag();

		for nFaceIndex = 0, cube:GetFaceCount()-1 do
			local v1,v2,v3 = cube:GetFaceTriangle(nFaceIndex, 0);
            

			write_face(polygons,v1,v2,v3);
			v1,v2,v3 = cube:GetFaceTriangle(nFaceIndex, 1);
			write_face(polygons,v1,v2,v3);
		end
        local o = CSGModel:new():init(CSG.fromPolygons(polygons));
	    if(o ~= nil) then
            local child = Node.create("");
		    child:setDrawable(o);
            if(bmax_node and bmax_node.block_data)then
                local color = bmax_node.block_data;
                color = Color.convert16_32(color)
                local r,g,b,a = Color.DWORD_TO_RGBA(color)
                r = r / 255;
                g = g / 255;
                b = b / 255;
                color = {r,g,b}
                o:setColor(color);
            end
            node:addChild(child);
	    end
	end	
	return node;
end
function NplCadEnvironment.read_import_bmax2(filename)
	local node = Node.create("");
    commonlib.echo(filename);
    return node;
end