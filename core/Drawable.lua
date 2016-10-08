--[[
Title: Drawable 
Author(s): leio
Date: 2016/8/16
Desc: 
Defines a drawable object that can be attached to a Node.
use the lib:
------------------------------------------------------------
NPL.load("(gl)NplCadLibrary/core/Drawable.lua");
local Drawable = commonlib.gettable("NplCad.core.Drawable");
------------------------------------------------------------
]]
local Drawable = commonlib.inherit(nil, commonlib.gettable("NplCad.core.Drawable"));
function Drawable:ctor()
	self.node = nil;
end
function Drawable:getTypeName()
	return "Drawable";
end
function Drawable:getNode()
	return self.node;
end
function Drawable:setNode(node)
	self.node = node;
end
