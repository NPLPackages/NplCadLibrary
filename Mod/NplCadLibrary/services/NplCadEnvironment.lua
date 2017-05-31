--[[
Title: NplCadEnvironment 
Author(s): leio
Date: 2016/8/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");
------------------------------------------------------------
]]

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
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");
local Color = commonlib.gettable("Mod.NplCadLibrary.utils.Color");
local CSGBuildContext = commonlib.gettable("Mod.NplCadLibrary.services.CSGBuildContext");
local ArrayMap = commonlib.gettable("commonlib.ArrayMap");
local vector3d = commonlib.gettable("mathlib.vector3d");
local math3d = commonlib.gettable("mathlib.math3d");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");


NplCadEnvironment.pi = 3.1415926;

function NplCadEnvironment.is_string(input)
	if(input and type(input) == "string")then
		return true;
	end
end
function NplCadEnvironment.is_table(input)
	if(input and type(input) == "table")then
		return true;
	end
end
function NplCadEnvironment.is_number(input)
	if(input and type(input) == "number")then
		return true;
	end
end
function NplCadEnvironment.is_array(input)
	if(input and type(input) == "table" and (#input) > 0)then
		return true;
	end
end

function NplCadEnvironment.is_node(input)
	if(input and type(input) == "table" and (input.getTypeName) and input.getTypeName()=="Node")then
		return true;
	end
end
function NplCadEnvironment.is_shape(input)
	if(NplCadEnvironment.is_node(input) and input.hasTag and input:hasTag("shape")) then
		return true;
	end
end
function NplCadEnvironment.is_path(input)
	if(input and type(input) == "table" and input.expandToCAG and input.innerToCAG and input.rectangularExtrude) then
		return true;
	end
end

local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Primitive3d.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Primitive2d.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Transformation.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Boolean.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Extrusion.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Others.lua");

function NplCadEnvironment:new(params)
	params = params or {}
	local o = {
		root_scene_node = params.root_scene_node or Node.create(""),
		nodes_stack = {},
		math = math,
		string = string,
		specified_indexs = {},

	};
	-- also expose the _G for explaining npl only. 
	o._G = o; 
	setmetatable(o, self);
	self.__index = self;
	return o;
end

function NplCadEnvironment.getNode()
	local self = getfenv(2);
	return self:getNode__();
end
function NplCadEnvironment:getNode__()
	if(self.nodes_stack)then
		local len = #self.nodes_stack;
		local node = self.nodes_stack[len];
		if(node)then
			return node;
		end
		return self.root_scene_node;
	end
end
function NplCadEnvironment.push()
	local self = getfenv(2);
	self:push__(true);
end
function NplCadEnvironment:push__(bSpecified)
	local parent = self:getNode__()
	local node = Node.create("");
	table.insert(self.nodes_stack,node);
	parent:addChild(node);
	if(bSpecified)then
		table.insert(self.specified_indexs,#self.nodes_stack)
	end
	return node;
end
function NplCadEnvironment.pop()
	local self = getfenv(2);
	self:pop__(true);
end
function NplCadEnvironment:pop__(bSpecified)
	if(self.nodes_stack)then
		if(bSpecified)then
			local len = #self.specified_indexs;
			local start_index = self.specified_indexs[len];
			local end_index = #self.nodes_stack;
			while (end_index >= start_index) do
				table.remove(self.nodes_stack,end_index);
				end_index = end_index - 1;
			end
			table.remove(self.specified_indexs,len);
		else
			local len = #self.nodes_stack;
			table.remove(self.nodes_stack,len);
		end
	end
end
function NplCadEnvironment.current()
	local self = getfenv(2);
	local node = self:getNode__();
	return node;
end

-- NplCadEnvironment.log() belongs to NplCadEnvironment, Use NplCadEnvironment:internalLog() to debug code.
function NplCadEnvironment.log(...)
	local self = getfenv(2);
	self:internalLog(...);
end
function NplCadEnvironment:internalLog(...)
	self.root_scene_node:log(...);
end
--defineProperty--------------------------------------------------------------------------------------------
function NplCadEnvironment.defineProperty(property_list)
	local self = getfenv(2);
	CSGBuildContext.defineProperty(property_list)
end
function NplCadEnvironment.get(name)
	local self = getfenv(2);
	return CSGBuildContext.getPropertyValue(name);
end
function NplCadEnvironment.set(name,value)
	local self = getfenv(2);
	CSGBuildContext.setPropertyValue(name,vlaue);
end
function NplCadEnvironment.findPropertyFromFile(filepath)
	local code = NplCadEnvironment.loadFileContent__(filepath);
	return NplCadEnvironment.findPropertyFromText(code);
end
function NplCadEnvironment.findPropertyFromText(text)
	if(not text)then return end
	local s = string.match(text,"^defineProperty%s*%((.-)%)");
	return s;
end
--end defineProperty--------------------------------------------------------------------------------------------
--include----------------------------------------------------------------------------------------------------
function NplCadEnvironment.include(filepath)
	local self = getfenv(2);
	local node = self:push__();
	self:include__(node,filepath);
end
function NplCadEnvironment:include__(node,filepath)
	if(not filepath)then return end
	local full_filepath = CSGBuildContext.input.root .. filepath;
	--create a new env node
	local env_node = NplCadEnvironment:new();
	env_node:buildFile(node,full_filepath);
end
function NplCadEnvironment.loadFileContent__(filepath)
	if(not filepath)then
		return
	end
	local full_path = ParaIO.GetCurDirectory(0)..filepath;
	local file = ParaIO.open(full_path, "r");
	if(file:IsValid()) then
		local text = file:GetText();
		file:close();
		return text;
	end
end
function NplCadEnvironment:buildFile(parent_scene_node,filepath)
	local code = NplCadEnvironment.loadFileContent__(filepath);
	self.root_scene_node:log("start to build file:%s",filepath);
	self:build(parent_scene_node,code);
end
function NplCadEnvironment:build(parent_scene_node,code)
	local code_func, errormsg = loadstring(code);
	if(code_func) then
		setfenv(code_func, self);
		local ok, result = pcall(code_func);
		if(ok)then
			if(parent_scene_node)then
				parent_scene_node:addChild(self.root_scene_node);
			end
		end
		CSGBuildContext.output.successful = ok;
		CSGBuildContext.output.compile_error = result;

		CSGBuildContext.output.log = CSGBuildContext.output.log or {};
		local log = table.concat(self.root_scene_node:GetAllLogs() or {}, "\n");

		CSGBuildContext.output.log[#(CSGBuildContext.output.log)+1] = log;

	else
		CSGBuildContext.output.successful = false;
		CSGBuildContext.output.compile_error =  errormsg;
		CSGBuildContext.output.log = errormsg;
	end
end
--end include----------------------------------------------------------------------------------------------------



