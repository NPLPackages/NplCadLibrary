--[[
Title: DomScene 
Author(s): leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)npl_packages/NplCadLibrary/doms/DomScene.lua");
local DomScene = commonlib.gettable("NplCad.doms.DomScene");
------------------------------------------------------------
]]
NPL.load("(gl)npl_packages/NplCadLibrary/core/Scene.lua");
NPL.load("(gl)npl_packages/NplCadLibrary/doms/DomBase.lua");
NPL.load("(gl)npl_packages/NplCadLibrary/doms/DomNode.lua");
local DomNode = commonlib.gettable("NplCad.doms.DomNode");
local Scene = commonlib.gettable("NplCad.core.Scene");
local DomScene = commonlib.inherit(commonlib.gettable("NplCad.doms.DomNode"), commonlib.gettable("NplCad.doms.DomScene"));
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
