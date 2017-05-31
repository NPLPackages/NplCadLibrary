--[[
Title: Extrusion.lua
Author(s): leio
Date: 2017/5/31
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Extrusion.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Transform.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Scene.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/doms/DomParser.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/CSGService.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/Color.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/CSGBuildContext.lua");
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Transform = commonlib.gettable("Mod.NplCadLibrary.core.Transform");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local Scene = commonlib.gettable("Mod.NplCadLibrary.core.Scene");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");
local DomParser = commonlib.gettable("Mod.NplCadLibrary.doms.DomParser");
local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local Color = commonlib.gettable("Mod.NplCadLibrary.utils.Color");
local CSGBuildContext = commonlib.gettable("Mod.NplCadLibrary.services.CSGBuildContext");
local ArrayMap = commonlib.gettable("commonlib.ArrayMap");
local vector3d = commonlib.gettable("mathlib.vector3d");
local math3d = commonlib.gettable("mathlib.math3d");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");


local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;

--[[
rectangular_extrude(path)
rectangular_extrude(0.1,path)
rectangular_extrude({w = 0.1, h = 0.2, fn = 8},path)
-- width default is 1
-- height default is 1
-- fn default is 32
--]]

function NplCadEnvironment.rectangular_extrude(options,path)
	local self = getfenv(2);
	return self:rectangular_extrude__(options,path);
end
function NplCadEnvironment:rectangular_extrude__(options,path)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_rectangular_extrude(options,path);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_rectangular_extrude(options,path)
	local node = Node.create("");
    local w = 1;
    local h = 1;
    local fn = CSGFactory.defaultResolution2D;
    local closed = false;
    if(p) then
        w = p.w or w;
        h = p.h or h;
        fn = p.fn or fn;
        closed = p.closed;
    end
	if(is_path(path)) then
		obj = path;
		local o = CSGModel:new():init(obj:rectangularExtrude(w,h,fn),"rectangular_extrude");
		node:setDrawable(o);
		node:setTag("shape","rectangular_extrude");
	else
		log("obj isn't a path,cannot be rectangular_extrude.");
	end
	return node;
end

--[[
extrude(shape)
extrude({0,10,0},shape)
extrude({offset = {0,10,0}, twistangle = 360, twiststeps = 100},shape)
-- offset default is {0,0,1}
-- twistangle default is 0
-- twiststeps default is 32
--]]

function NplCadEnvironment.linear_extrude(options,shape)
	local self = getfenv(2);
	return self:linear_extrude__(options,shape);
end
function NplCadEnvironment:linear_extrude__(options,shape)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_linear_extrude(options,shape);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_linear_extrude(options,shape)
	local node = nil;
	local obj = nil;
	local o;
	local twistangle = 0;
	local twiststeps = 32
	local x,y,z = 0,0,1;
	if(is_shape(shape)) then
		node = shape;
		obj = node:getDrawable().cag_node;
		if(obj.extrude) then
			if (is_array(options)) then 
				if(is_number(options[1])) then
					x = options[1];
				end
				if(is_number(options[2])) then
					y = options[2];
				end
				if(is_number(options[3])) then
					z = options[3];
				end
			elseif (is_table(options)) then
				if(is_table(options.offset)) then
					if(is_number(options.offset[1])) then
						x = options.offset[1];
					end
					if(is_number(options.offset[2])) then
						y = options.offset[2];
					end
					if(is_number(options.offset[3])) then
						z = options.offset[3];
					end
				end
				if(is_number(options.twistangle)) then
					twistangle = options.twistangle;
				end
				if(is_number(options.twiststeps)) then
					twiststeps = options.twiststeps;
				end
			end
			o = CSGModel:new():init(obj:extrude({offset = {x,y,z},twistangle = twistangle,twiststeps = twiststeps}),"extrude");
			node:setDrawable(o);
			node:setTag("extrude","linear_extrude");
		else
			log("obj isn't a shape,cannot be linear_extrude.");
		end
	end
	return node;
end

--[[
rotate_extrude
arguments: options dict with angle and resolution, both optional
rotate_extrude(angle,shape)
rotate_extrude({angle = a, fn = 8},shape)
-- angle default is 360
-- fn default is 32
--]]

function NplCadEnvironment.rotate_extrude(options,shape)
	local self = getfenv(2);
	return self:rotate_extrude__(options,shape);
end
function NplCadEnvironment:rotate_extrude__(options,shape)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_rotate_extrude(options,shape);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_rotate_extrude(p,o)
	local node = Node.create("");

    local fn = p.fn or CSGFactory.defaultResolution2D;
    if(fn<3) then
        fn = 3;
    end
    o = o:getDrawable().cag_node;
    local offset = p.offset;
    if(offset)then
        o:transform(Matrix4.translation(offset));
    end
    local ps = {};
    for i = 1, fn do
        -- o.{x,y} -> rotate([0,0,i:0..360], obj->{o.x,0,o.y})
        for j = 1, #(o.sides) do
            -- has o.sides[j].vertex{0,1}.pos (only x,y)
            local p = {};
            local m;

            m = Matrix4.rotationZ(i/fn*360);
            p[1] = vector3d:new(o.sides[j].vertex0.pos[1],0,o.sides[j].vertex0.pos[2]);
            p[1] = math3d.MatrixMultiplyVector(nil, m, p[1])
         
            p[2] = vector3d:new(o.sides[j].vertex1.pos[1],0,o.sides[j].vertex1.pos[2]);
            p[2] = math3d.MatrixMultiplyVector(nil, m, p[2])
         
            m = Matrix4.rotationZ((i+1)/fn*360);
            p[3] = vector3d:new(o.sides[j].vertex1.pos[1],0,o.sides[j].vertex1.pos[2]);
            p[3] = math3d.MatrixMultiplyVector(nil, m, p[3])
         
            p[4] = vector3d:new(o.sides[j].vertex0.pos[1],0,o.sides[j].vertex0.pos[2]);
            p[4] = math3d.MatrixMultiplyVector(nil, m, p[4])

            local p1 = CSGPolygon:new():init({
            CSGVertex:new():init(p[1]),
            CSGVertex:new():init(p[2]),
            CSGVertex:new():init(p[3]),
            CSGVertex:new():init(p[4]),      -- we make a square polygon (instead of 2 triangles)
            });
            table.insert(ps,p1);  
        end
    end
    local model = CSGModel:new():init(CSG.fromPolygons(ps));
	node:setDrawable(model);

   return node;
end
