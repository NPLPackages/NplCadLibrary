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
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");

local CAGVertex = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex"));


function CAGVertex:ctor()
	--self.pos;
end

function CAGVertex:init(pos)
	self.pos = pos or self.pos;
	return self;
end

-- copy on write policy
-- @param bDeepCopy: if true, we will perform deep copy, otherwise it is a shallow copy on write clone
function CAGVertex:clone(bDeepCopy)
	local v = CAGVertex:new();
	v.pos = self.pos;
	if(bDeepCopy) then
		v:detach();
	end
	return v;
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CAGVertex:detach()
	self.pos = self.pos:clone();
	return self;
end

--Create a new vertex between this vertex and `other` by linearly
--interpolating all properties using a parameter of `t`. Subclasses should
--override this to interpolate additional properties.
function CAGVertex:interpolate(other, t)
	return CAGVertex:new():init(
		self.pos:lerp(other.pos,t)
	);
end

function CAGVertex:getPosition()
	return self.pos;
end