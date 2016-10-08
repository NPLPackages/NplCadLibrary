--[[
Title: DomScene 
Author(s): leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/doms/DomScene.lua");
local DomScene = commonlib.gettable("Mod.NplCadLibrary.doms.DomScene");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/core/Scene.lua");
NPL.load("(gl)Mod/NplCadLibrary/doms/DomBase.lua");
NPL.load("(gl)Mod/NplCadLibrary/doms/DomNode.lua");
local DomNode = commonlib.gettable("Mod.NplCadLibrary.doms.DomNode");
local Scene = commonlib.gettable("Mod.NplCadLibrary.core.Scene");
local DomScene = commonlib.inherit(commonlib.gettable("Mod.NplCadLibrary.doms.DomNode"), commonlib.gettable("Mod.NplCadLibrary.doms.DomScene"));
function DomScene:ctor()
end
function DomScene:read(xmlnode,parentObj)
	if(not xmlnode)then
		return
	end
	self:checkAttr(xmlnode);
	local id = xmlnode.attr.id;
	local scene = Scene.create(id);

	self:readChildren(xmlnode,scene);
	return scene;
end
function DomScene:writeProperties(obj)
	return "";
end
