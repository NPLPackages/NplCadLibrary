--[[
Title: Boolean.lua
Author(s): leio
Date: 2017/5/31
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Boolean.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

function NplCadEnvironment.union()
	local self = getfenv(2);
	self:union__();
end
function NplCadEnvironment:union__()
	local node = self:push__();
	if(node)then
		node:setTag("csg_action","union");
	end
end
function NplCadEnvironment.difference()
	local self = getfenv(2);
	self:difference__();
end
function NplCadEnvironment:difference__()
	local node = self:push__();
	if(node)then
		node:setTag("csg_action","difference");
	end
end
function NplCadEnvironment.intersection()
	local self = getfenv(2);
	self:intersection__();
end
function NplCadEnvironment:intersection__()
	local node = self:push__();
	if(node)then
		node:setTag("csg_action","intersection");
	end
end