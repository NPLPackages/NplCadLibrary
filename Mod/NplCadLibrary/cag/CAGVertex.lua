--[[
Title: CAGVertex
Skeleton
Date: 2016/11/26
Desc: 
Represents a vertex of a side.
for 2D space ,there isn't normal.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
-------------------------------------------------------
--]]
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");
NPL.load("(gl)script/ide/math/vector2d.lua");

local vector2d = commonlib.gettable("mathlib.vector2d");
local CAGVertex = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex"));

function CAGVertex:ctor()
	if(commonlib.use_object_pool) then
		self.pos = self.pos or vector2d:new_from_pool(0,0);
	else
		self.pos = self.pos or vector2d:new();
	end
end

function CAGVertex:init(pos)
	self.pos:set(pos);
	return self;
end

-- copy on write policy
-- @param bDeepCopy: if true, we will perform deep copy, otherwise it is a shallow copy on write clone
function CAGVertex:clone()
	return CAGVertex:new(self.pos);
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CAGVertex:detach()
	return self;
end

--Create a new vertex between this vertex and `other` by linearly
--interpolating all properties using a parameter of `t`. Subclasses should
--override this to interpolate additional properties.
function CAGVertex:interpolate(other, t)
	self.pos:lerp(other.pos,t);
	return self;
end

function CAGVertex:getPosition()
	return self.pos;
end