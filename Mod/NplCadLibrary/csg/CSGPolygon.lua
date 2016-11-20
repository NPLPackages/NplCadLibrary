--[[
Title: CSGPolygon
Author(s): leio, LiXizhi
Date: 2016/3/29
Desc: 
Represents a convex polygon. The vertices used to initialize a polygon must
be coplanar and form a convex loop. They do not have to be `CSG.Vertex`
instances but they must behave similarly (duck typing can be used for
customization).
 
Each convex polygon has a `shared` property, which is shared between all
polygons that are clones of each other or were split from the same polygon.
This can be used to define per-polygon properties (such as surface color).

Uses Copy On Write policy
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
-------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPlane.lua");
local CSGPlane = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane");
local CSGPolygon = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon"));

-- {vertices, shared, plane(optional)}
function CSGPolygon:ctor()
end

function CSGPolygon:init(vertices, shared)
	self.vertices = vertices or {};
	self.shared = shared;
	return self;
end

-- get plane and create it if not exist. 
function CSGPolygon:GetPlane()
	if(not self.plane) then
		local vertices = self.vertices;
		self.plane = CSGPlane.fromPoints(vertices[1].pos, vertices[2].pos, vertices[3].pos);	
	end
	return self.plane;
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CSGPolygon:detach()
	local result = {};
	local vertices = self.vertices;
	for i=1, #vertices do
		result[#result+1] = vertices[i]:clone();
	end
	self.vertices = result;
	self.plane = self.plane and self.plane:clone();
	return self;
end

function CSGPolygon:clone()
	local p = CSGPolygon:new();
	p.vertices = self.vertices;
	p.shared = self.shared;
	p.plane = self.plane;
	return p;
end

function CSGPolygon:flip()
	local result = {};
	local vertices = self.vertices;
	for i = #vertices, 1, -1 do
		result[#result+1] = vertices[i]:clone():flip();
	end
	self.vertices = result;

	if(self.plane) then
		self.plane = self.plane:clone():flip();
	end
	return self;
end

function CSGPolygon:getVertexCnt()
	if(self.vertices)then
		return #self.vertices;
	end
	return 0;
end