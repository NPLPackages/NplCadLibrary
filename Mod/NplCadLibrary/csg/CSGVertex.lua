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

NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");
NPL.load("(gl)script/ide/math/vector.lua");

local vector3d = commonlib.gettable("mathlib.vector3d");
local CSGVertex = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex"));

function CSGVertex:ctor()
	if(commonlib.use_object_pool) then
		self.pos = self.pos or vector3d:new_from_pool(0,0,0);
		self._normal=  self._normal or vector3d:new_from_pool(0,0,0);
	else
		self.pos = self.pos or vector3d:new();
		self._normal= self._normal or vector3d:new();
	end
	self.normal= nil;
end

function CSGVertex:init(pos,normal)
	self.pos:set(pos);
	if(normal~= nil) then
		self.normal= self._normal:set(normal);
    else
		self.normal= vector3d:new_from_pool(0,0,0);
	end	
	return self;
end

function CSGVertex:clone()
	return  CSGVertex:new():init(self.pos,self.normal);
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
	self.pos = self.pos:interpolate(other.pos,t);
	self.normal = self.normal and self.normal:interpolate(other.normal,t);
	return self;
end

function CSGVertex:equals(v,epsilon)
	epsilon = epsilon or 0;
	return self.pos:equals(v.pos,epsilon)
			and ((self.normal == nil and v.normal == nil) or 
				 (self.normal and v.normal and self.normal:equals(v.normal,epsilon))
			);
end

function CSGVertex:transform(m)
	self.pos = self.pos:transform(m);
	self.normal = self.normal and self.normal:transform_normal(m);
	return self;
end