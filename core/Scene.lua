--[[
Title: Scene 
Author(s): leio
Date: 2016/8/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)npl_packages/NplCadLibrary/core/Scene.lua");
local Scene = commonlib.gettable("NplCad.core.Scene");
------------------------------------------------------------
]]
NPL.load("(gl)npl_packages/NplCadLibrary/core/Node.lua");
local Scene = commonlib.inherit(commonlib.gettable("NplCad.core.Node"), commonlib.gettable("NplCad.core.Scene"));
function Scene.create(id)
	local scene = Scene:new();
	scene:setId(id);
	return scene;
end

function Scene:getTypeName()
	return "Scene";
end
function Scene:visit(visitMethod)
	local node = self:getFirstChild();
	while(node) do
		self:visitNode(node,visitMethod);
		node = node:getNextSibling();
	end
end
function Scene:visitNode(node,visitMethod)
	if(not node)then
		return;
	end
	if(visitMethod)then
		visitMethod(node);
	end
	local child = node:getFirstChild();
	while(child) do
		self:visitNode(child,visitMethod);
		child = child:getNextSibling();
	end
end