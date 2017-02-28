--[[
Title: CSGVertex
Author(s): leio, LiXizhi
Date: 2016/3/29
Desc: 
Represents a vertex of a polygon. Use your own vertex class instead of this
one to provide additional features like texture coordinates and vertex
colors. Custom vertex classes need to provide a `pos` property and `clone()`,
`flip()`, and `interpolate()` methods that behave analogous to the ones
defined by `CSG.Vertex`. This class provides `normal` so convenience
functions like `CSG.sphere()` can return a smooth vertex normal, but `normal`
is not used anywhere else.

This class uses Copy on write policy
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
-------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");

local CSGVertex = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex"));


function CSGVertex:ctor()
	--self.pos = s_zeroVector;
	--self.normal = s_zeroVector; -- normal is optional
end

function CSGVertex:init(pos, normal)
	self.pos = pos or self.pos;
	self.normal = normal or self.normal;
	return self;
end

-- copy on write policy
-- @param bDeepCopy: if true, we will perform deep copy, otherwise it is a shallow copy on write clone
function CSGVertex:clone(bDeepCopy)
	local v = CSGVertex:new();
	v.pos, v.normal = self.pos, self.normal;
	if(bDeepCopy) then
		v:detach();
	end
	return v;
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CSGVertex:detach()
	self.pos = self.pos:clone();
	self.normal = self.normal and self.normal:clone();
	return self;
end

--Invert all orientation-specific data (e.g. vertex normal). Called when the orientation of a polygon is flipped.
function CSGVertex:flip()
	self.normal = self.normal and self.normal:negated();
	return self;
end

--Create a new vertex between this vertex and `other` by linearly
--interpolating all properties using a parameter of `t`. Subclasses should
--override this to interpolate additional properties.
function CSGVertex:interpolate(other, t)
	return CSGVertex:new():init(
		self.pos:lerp(other.pos,t),
		self.normal and self.normal:lerp(other.normal,t)
	);
end
