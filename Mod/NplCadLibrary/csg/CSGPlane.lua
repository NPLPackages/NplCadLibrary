--[[
Title: CSGPlane
Author(s): leio, LiXizhi
Date: 2016/3/29
Desc: read-only plane. self.normal uses copy on write policy. 

Represents a plane in 3D space.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPlane.lua");
local CSGPlane = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane");
-------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGPlane = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane"));

local bor = mathlib.bit.bor;

--`CSG.Plane.EPSILON` is the tolerance used by `splitPolygon()` to decide if a
-- point is on the plane.
CSGPlane.EPSILON = 0.00001;


function CSGPlane:ctor()
end

function CSGPlane:init(normal, w)
	-- normal is read-only
	self.normal = normal;
	self.w = w;
	return self;
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CSGPlane:detach()
	self.normal = self.normal:clone();
	return self;
end

function CSGPlane.fromPoints(a, b, c)
	local n = b:minus(a):crossInplace(c:clone_from_pool():minusInplace(a)):unitInplace();
	local plane = CSGPlane:new():init(n,n:dot(a));
	return plane;
end
function CSGPlane:clone()
	local plane = CSGPlane:new():init(self.normal,self.w);
	return plane;
end

function CSGPlane:flip()
	self.normal = self.normal:negated();
	self.w = -self.w;
	return self;
end

local types = {};

local COPLANAR = 0;
local FRONT = 1;
local BACK = 2;
local SPANNING = 3;

-- Split `polygon` by this plane if needed, then put the polygon or polygon
-- fragments in the appropriate lists. Coplanar polygons go into either
-- `coplanarFront` or `coplanarBack` depending on their orientation with
-- respect to this plane. Polygons in front or in back of this plane go into
-- either `front` or `back`.
-- @param front: inout parameter.  if nil, it will be created and returned.
-- @param back: inout parameter.  if nil, it will be created and returned.
-- @return front, back, coplanarFront, coplanarBack
function CSGPlane:splitPolygon(polygon, coplanarFront, coplanarBack, front, back)
    --Classify each point as well as the entire polygon into one of the above four classes.
    local polygonType = 0;
    
	local EPSILON = CSGPlane.EPSILON;
	local vertices = polygon.vertices;
	for i = 1, #vertices do
		local v = vertices[i];
		local t = self.normal:dot(v.pos) - self.w;
		local type;
		if(t < -EPSILON)then
			type = BACK;
		elseif(t > EPSILON)then
			type = FRONT;
		else
			type = COPLANAR;
		end
		polygonType = bor(polygonType, type);
		types[i] = type;
	end
	if(polygonType == COPLANAR)then
		if(self.normal:dot(polygon:GetPlane().normal) > 0)then
			coplanarFront = coplanarFront or {};
			coplanarFront[#coplanarFront+1] = polygon;
		else
			coplanarBack = coplanarBack or {};
			coplanarBack[#coplanarBack+1] = polygon;
		end
	elseif(polygonType == FRONT)then
		front = front or {};
		front[#front+1] = polygon;
	elseif(polygonType == BACK)then
		back = back or {};
		back[#back+1] = polygon;
	elseif(polygonType == SPANNING)then
		local backCount, frontCount = 0, 0;
		local f = {};
		local b = {};
		local size = #vertices;
		for i = 1, size do
			local j = (i % size) + 1;
			local ti = types[i];
			local tj = types[j];
			local vi = vertices[i]
			local vj = vertices[j];
			if(ti ~= BACK)then
				frontCount = frontCount + 1;
				f[frontCount] = vi;
			end
			if(ti ~= FRONT)then
				if(ti ~= BACK)then
					backCount = backCount + 1;
					b[backCount] = vi:clone();
				else
					backCount = backCount + 1;
					b[backCount] = vi;
				end
			end
			if(bor(ti, tj) == SPANNING)then
				local t = (self.w - self.normal:dot(vi.pos)) / self.normal:dot(vj.pos:minus(vi.pos));
				local v = vi:interpolate(vj, t);
				frontCount = frontCount + 1;
				f[frontCount] = v;
				backCount = backCount + 1;
				b[backCount] = v:clone();
			end
		end
		if(frontCount >= 3)then
			front = front or {};
			front[#front+1] = CSGPolygon:new():init(f,polygon.shared);
		end
		if(backCount >= 3)then
			back = back or {};
			back[#back+1] = CSGPolygon:new():init(b,polygon.shared);
		end
	end
	return front, back, coplanarFront, coplanarBack;
end
