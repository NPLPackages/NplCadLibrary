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
innerToCAG( path);
--]]
function NplCadEnvironment.innerToCAG(path)
	local self = getfenv(2);
	return self:innerToCAG__(path);
end
function NplCadEnvironment:innerToCAG__(path)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_innerToCAG(path);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_innerToCAG(path)
	local node = Node.create("");
	local obj = nil;
	local o;
	if(is_path(path)) then
		obj = path;
		if(obj.closed == true) then
			o = CAGModel:new():init(obj:innerToCAG(),"innerToCAG");
			node:setDrawable(o);
			node:setTag("shape","innerToCAG");
		else
			log("the path which innerToCAG should be CLOSED.");
		end
	else
		log("obj isn't a path,cannot be innerToCAG.");
	end
	return node;
end

--[[
expandToCAG(0.1,path);
expandToCAG({pathradius = 0.1, fn = 8},path);
-- pathradius default is 0.1
-- fn default is 32
--]]
function NplCadEnvironment.expandToCAG(options,path)
	local self = getfenv(2);
	return self:expandToCAG__(options,path);
end
function NplCadEnvironment:expandToCAG__(options,path)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_expandToCAG(options,path);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_expandToCAG(options,path)
	local node = Node.create("");
	local obj = nil;
	local o;
	local pathradius = 0.1;
	local fn = 32;
	if(is_path(path)) then
		obj = path;
		if (is_number(options)) then 
			pathradius = options;
		elseif (is_table(options)) then
			if(is_number(options.pathradius)) then
				pathradius = options.pathradius;
			end
			if(is_number(options.fn)) then
				fn = options.fn;
			end
		end

		o = CAGModel:new():init(obj:expandToCAG(pathradius,fn),"expandToCAG");
		node:setDrawable(o);
		node:setTag("shape","expandToCAG");
	else
		log("obj isn't a path,cannot be expandToCAG.");
	end
	return node;
end
--[[
color({r,g,b});		--create a new parent node and set color value 
color({r,g,b},obj); --set color value with obj 
color(color_name);		--create a new parent node and set color value with color name
color(color_name,obj)		--set color value with obj 
--]]
function NplCadEnvironment.color(options,obj)
	local self = getfenv(2);
	self:color__(options,obj);
end
function NplCadEnvironment:color__(options,obj)
	if(not options)then return end
	local r,g,b;
	if(is_string(options))then
		local v = Color.getValue(options);
		r = v[1];
		g = v[2];
		b = v[3];
	end
	if(is_array(options))then
		r = options[1] or 1;
		g = options[2] or 1;
		b = options[3] or 1;
	end
	if(not obj)then
		obj = self:push__();
	end
	if(obj and obj.setTag)then
		obj:setTag("color",{r,g,b});
	end
end
function NplCadEnvironment.loadXml(str)
	local self = getfenv(2);
	self:loadXml__(str);
end
function NplCadEnvironment:loadXml__(str)
	local parent = self:getNode__();
	local node = DomParser.loadStr(str)
	if(node)then
		parent:addChild(node);
	end
end