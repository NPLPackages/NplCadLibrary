--[[
Title: Transformation.lua
Author(s): leio
Date: 2017/5/31
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Transformation.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)script/ide/math/vector.lua");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Plane = commonlib.gettable("mathlib.Plane");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local vector3d = commonlib.gettable("mathlib.vector3d");

local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;

--[[
translate({0,0,10});		--create a new parent node and set translation value 
translate({0,0,10},obj);	--set translation value with obj          
translate(0,1,0, obj);		--set translation 
--]]
function NplCadEnvironment.translate(...)
	local self = getfenv(2);
	self:translate__(...);
end
function NplCadEnvironment:translate__(p1,p2,p3,p4)
	local x,y,z, options,obj;
	if(type(p1) == "table") then
		options = p1;
		if #options == 3 then
			x = options[1];
			y = options[2];
			z = options[3];
		elseif #options == 2 then
			x = options[1];
			y = 0;
			z = options[2];
		else
			self:internalLog("translate should have 2 or 3 coords");
			return;
		end
		obj = p2;
	elseif(type(p1) == "number") then
		if ( type(p2) == "number" and type(p3) == "number" ) then
			x = p1;
			y = tonumber(p2);
			z = tonumber(p3);
			obj = p4;
		elseif (type(p2) == "number" and type(p3) ~= "number") then
			x = p1;
			y = 0;
			z = tonumber(p2);
			obj = p3;	
		else 
			self:internalLog("translate should have 2 or 3 coords");	
		end
	else
		self:internalLog("translate should have a coords array");
		return;		
	end
	if(not obj)then
		obj = self:push__();
	end
	if(obj and obj.setTranslation)then
		obj:setTranslation(x or 0, y or 0, z or 0);
	end
end
--[[
rotate(2);				--create a new parent node and set rotation value          
rotate(2,obj);			--set rotation value with obj          
rotate({1,2,3});		--create a new parent node and set rotation value          
rotate({1,2,3},obj);	--set rotation value with obj  
--]]
function NplCadEnvironment.rotate(options,obj)
	local self = getfenv(2);
	self:rotate__(options,obj);
end
function NplCadEnvironment:rotate__(options,obj)
	if(not options)then return end
	local x_angle,y_angle,z_angle;
	if(is_number(options))then
		x_angle = options;
		y_angle = options;
		z_angle = options;
	end
	if(is_array(options))then
		x_angle = options[1] or 0;
		y_angle = options[2] or 0;
		z_angle = options[3] or 0;
	end
	if(not obj)then
		obj = self:push__();
	end
	local x = x_angle * NplCadEnvironment.pi / 180;
	local y = y_angle * NplCadEnvironment.pi / 180;
	local z = z_angle * NplCadEnvironment.pi / 180;

	if(obj and obj.setRotation)then
		local q =  Quaternion:new();
		local yaw = y;
		local roll = z;
		local pitch = x;
		q =  q:FromEulerAngles(yaw,roll,pitch);
		obj:setRotation(q[1],q[2],q[3],q[4]);
	end
end
--[[
scale(2);			--create a new parent node and set scale value          
scale(2,obj);		--set scale value with obj          
scale({1,2,3});		--create a new parent node and set scale value          
scale({1,2,3},obj); --set scale value with obj          
--]]
function NplCadEnvironment.scale(options,obj)
	local self = getfenv(2);
	self:scale__(options,obj);
end
function NplCadEnvironment:scale__(options,obj)
	if(not options)then return end
	local x,y,z;
	if(is_number(options))then
		x = options;
		y = options;
		z = options;
	elseif(is_array(options))then
		if #options == 3 then
			x = options[1] or 1;
			y = options[2] or 1;
			z = options[3] or 1;
		elseif #options == 2 then
			x = options[1] or 1;
			y = 1;
			z = options[2] or 1;
		else
			self:internalLog("scale should have 2 or 3 coords");
			return;
		end
	else
		self:internalLog("scale should have a coords array");
		return;		
	end
	if(not obj)then
		obj = self:push__();
	end
	if(obj and obj.setScale)then
		obj:setScale(x,y,z);
	end
end
function NplCadEnvironment.mirror(options,obj)
	local self = getfenv(2);
	self:mirror__(options,obj);
end
function NplCadEnvironment:mirror__(options,obj)
    NplCadEnvironment.read_mirror(options,obj);
end
function NplCadEnvironment.read_mirror(options,obj)
    if(not options)then return end
	local x,y,z;
	if(is_number(options))then
		x = options;
		y = options;
		z = options;
	elseif(is_array(options))then
		if #options == 3 then
			x = options[1] or 1;
			y = options[2] or 1;
			z = options[3] or 1;
		else
			self:internalLog("mirror should have 3 coords");
			return;
		end
	else
		self:internalLog("mirror should have a coords array");
		return;		
	end
	if(not obj)then
		self:internalLog("mirror need a object");
        return 
    end
    local csg_node = obj:getDrawable().csg_node;
    if(not csg_node)then
		self:internalLog("mirror need a csg_node");
        return
    end
    local v = vector3d:new(x,y,z);
    v = v:normalize();
    local plane = Plane:new({v[1],v[2],v[3],0});
    csg_node:mirrored(plane);
end