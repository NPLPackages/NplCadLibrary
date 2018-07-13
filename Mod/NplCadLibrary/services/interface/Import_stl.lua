--[[
Title: Import_stl.lua
Author(s): leio
Date: 2017/6/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Import_stl.lua");
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
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local vector3d = commonlib.gettable("mathlib.vector3d");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");

local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;

function NplCadEnvironment.import_stl(filename)
	local self = getfenv(2);
	return self:import_stl__(filename);
end
function NplCadEnvironment:import_stl__(filename)
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_import_stl(filename);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_import_stl(filename)
	commonlib.echo("=============read_import_stl");
	commonlib.echo(filename);

	local node;
	if (not ParaIO.DoesFileExist(filename, false)) then
		commonlib.echo("File "..filename.." not exist!")
		return node
	end

	local file = ParaIO.open(filename, "r")
	if (file:IsValid()) then
		commonlib.echo("test read successed")
		file:seekRelative(80)
		local binaryTest = {}
		file:ReadBytes(128, binaryTest);
		file:seek(0)
		local isAscii = true
		for i = 1, #binaryTest do
			-- compare with ascii '~'
			if binaryTest[i] > 126 then
				isAscii = false
				break
			end
		end

		if isAscii then
			local text = file:GetText();
			node = NplCadEnvironment.ReadAsciiSTL(text)
		else
			node = NplCadEnvironment.ReadBinarySTL(file)
		end
		file:close();
	end
	return node;
end

function NplCadEnvironment.AddPolygons(polygons, normal, vertex_1, vertex_2, vertex_3)
	local a = vertex_2 - vertex_1
	local b = vertex_3 - vertex_1
	local vertices = {}
	if normal:dot(a:cross(b)) < 0 then
		table.insert(vertices, CSGVertex:new():init(vertex_1, normal))
		table.insert(vertices, CSGVertex:new():init(vertex_3, normal))
		table.insert(vertices, CSGVertex:new():init(vertex_2, normal))
	else
		table.insert(vertices, CSGVertex:new():init(vertex_1, normal))
		table.insert(vertices, CSGVertex:new():init(vertex_2, normal))
		table.insert(vertices, CSGVertex:new():init(vertex_3, normal))
	end

	local polygon = CSGPolygon:new():init(vertices)
	table.insert(polygons, polygon)
end

function NplCadEnvironment.ReadBinarySTL(file)
	commonlib.echo("This is binary stl")
	local node = Node.create("")

	file:seekRelative(80)
	assert(file:getpos() == 80)

	local polygons = {}
	local count = file:ReadInt()
	commonlib.echo("triangle count: "..count)
	for i = 1, count do
		local normal = vector3d:new(file:ReadFloat(), file:ReadFloat(), file:ReadFloat())
		local vertex_1 = vector3d:new(file:ReadFloat(), file:ReadFloat(), file:ReadFloat())
		local vertex_2 = vector3d:new(file:ReadFloat(), file:ReadFloat(), file:ReadFloat())
		local vertex_3 = vector3d:new(file:ReadFloat(), file:ReadFloat(), file:ReadFloat())
		NplCadEnvironment.AddPolygons(polygons, normal, vertex_1, vertex_2, vertex_3)
		local o = {}
		file:ReadBytes(2, o)
	end

	local o = CSGModel:new():init(CSG.fromPolygons(polygons));
	if o then
		local child = Node.create("")
		child:setDrawable(o)
		node:addChild(child)
	end

	return node
end

function NplCadEnvironment.ReadAsciiSTL(stl)
	commonlib.echo("This is ascii stl")
	local node = Node.create("")
	
	for solid in string.gmatch(stl, "(.-)endsolid()") do
		local polygons = {}

		for face in string.gmatch(solid, "facet(.-)endfacet()") do
			local loopPattern = "normal%s+(.-)%s+(.-)%s+(.-)%s+outer%s+loop%s+vertex%s+(.-)%s+(.-)%s+(.-)%s+vertex%s+(.-)%s+(.-)%s+(.-)%s+vertex%s+(.-)%s+(.-)%s+(.-)%s+"
			local n_x, n_y, n_z, v1_x, v1_y, v1_z, v2_x, v2_y, v2_z, v3_x, v3_y, v3_z = string.match(face, loopPattern)
			n_x = tonumber(n_x) n_y = tonumber(n_y) n_z = tonumber(n_z)
			v1_x = tonumber(v1_x) v1_y = tonumber(v1_y) v1_z = tonumber(v1_z)
			v2_x = tonumber(v2_x) v2_y = tonumber(v2_y) v2_z = tonumber(v2_z)
			v3_x = tonumber(v3_x) v3_y = tonumber(v3_y) v3_z = tonumber(v3_z)
			if n_x and n_y and n_z and v1_x and v1_y and v1_z and v2_x and v2_y and v2_z and v3_x and v3_y and v3_z then
				NplCadEnvironment.AddPolygons(polygons, vector3d:new(n_x, n_y, n_z),
					vector3d:new(v1_x, v1_y, v1_z), vector3d:new(v2_x, v2_y, v2_z), vector3d:new(v3_x, v3_y, v3_z))
			else
				commonlib.echo("bad normal or triangle vertices")
			end
		end

		local o = CSGModel:new():init(CSG.fromPolygons(polygons));
		if o then
			local child = Node.create("")
			child:setDrawable(o)
			node:addChild(child)
		end	
	end

	return node
end