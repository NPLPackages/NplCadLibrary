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
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine3D.lua");

local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
local CSGPlane = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane"));

local bor = mathlib.bit.bor;

--`function CSGPlane.EPSILON` is the tolerance used by `splitPolygon()` to decide if a
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
    return CSGPlane.fromVector3Ds(a, b, c);
end

function CSGPlane.fromVector3Ds(a, b, c)
	local n = b:minus(a):crossInplace(c:clone_from_pool():minusInplace(a)):unitInplace();
	local plane = CSGPlane:new():init(n,n:dot(a));
	return plane;
end

-- like fromVector3Ds, but allow the vectors to be on one point or one line
-- in such a case a random plane through the given points is constructed
function CSGPlane.anyPlaneFromVector3Ds(a, b, c)
    local v1 = b:minus(a);
    local v2 = c:minus(a);
    if (v1:length() < tonumber("1e-5")) then
        v1 = v2:randomNonParallelVector();
    end
    if (v2:length() < tonumber("1e-5")) then
        v2 = v1:randomNonParallelVector();
    end
    local normal = v1:cross(v2);
    if (normal:length() < tonumber("1e-5")) then
        -- self would mean that v1 == v2.negated()
        v2 = v1:randomNonParallelVector();
        normal = v1:cross(v2);
    end
    normal = normal:unit();
    return CSGPlane:new():init(normal, normal:dot(a));
end
function CSGPlane.fromNormalAndPoint(normal, point)
    normal = CSGVector:new():init(normal);
    point = CSGVector:new():init(point);
    normal = normal:unit();
    local w = point:dot(normal);
    return CSGPlane:new():init(normal, w);
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
<<<<<<< HEAD
<<<<<<< HEAD
local dots = {};
=======
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
=======
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace

local COPLANAR = 0;
local FRONT = 1;
local BACK = 2;
local SPANNING = 3;

-- Split `polygon` by self plane if needed, then put the polygon or polygon
-- fragments in the appropriate lists. Coplanar polygons go into either
-- `coplanarFront` or `coplanarBack` depending on their orientation with
-- respect to self plane. Polygons in front or in back of self plane go into
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
<<<<<<< HEAD
<<<<<<< HEAD
		dots[i] = t;
=======
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
=======
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
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
<<<<<<< HEAD
<<<<<<< HEAD
				local t = (-dots[i]) / (dots[j] - dots[i]);
=======
				local t = (self.w - self.normal:dot(vi.pos)) / self.normal:dot(vj.pos:clone_from_pool():minusInplace(vi.pos));
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
=======
				local t = (self.w - self.normal:dot(vi.pos)) / self.normal:dot(vj.pos:clone_from_pool():minusInplace(vi.pos));
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
				local v = vi:interpolate(vj, t);
				frontCount = frontCount + 1;
				f[frontCount] = v;
				backCount = backCount + 1;
				b[backCount] = v:clone();
			end
		end
		if(frontCount >= 3)then
			front = front or {};
<<<<<<< HEAD
<<<<<<< HEAD
			front[#front+1] = CSGPolygon:new():init(f,polygon.shared,polygon.plane);
		end
		if(backCount >= 3)then
			back = back or {};
			back[#back+1] = CSGPolygon:new():init(b,polygon.shared,polygon.plane);
=======
=======
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
			front[#front+1] = CSGPolygon:new():init(f,polygon.shared);
		end
		if(backCount >= 3)then
			back = back or {};
			back[#back+1] = CSGPolygon:new():init(b,polygon.shared);
<<<<<<< HEAD
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
=======
>>>>>>> parent of 55ec7d1... Merge pull request #8 from lighter-cd/pool_and_inplace
		end
	end
	return front, back, coplanarFront, coplanarBack;
end

function CSGPlane:equals(n)
    return self.normal:equals(n.normal) and self.w == n.w;
end

function CSGPlane:transform(matrix4x4)
    local ismirror = matrix4x4:isMirroring();
    -- get two vectors in the plane:
    local r = self.normal:randomNonParallelVector();
    local u = self.normal:cross(r);
    local v = self.normal:cross(u);
    -- get 3 points in the plane:
    local point1 = self.normal:times(self.w);
    local point2 = point1:plus(u);
    local point3 = point1:plus(v);
    -- transform the points:
    point1 = point1:multiply4x4(matrix4x4);
    point2 = point2:multiply4x4(matrix4x4);
    point3 = point3:multiply4x4(matrix4x4);
    -- and create a new plane from the transformed points:
    local newplane = CSGPlane.fromVector3Ds(point1, point2, point3);
    if (ismirror) then
        -- the transform is mirroring
        -- We should mirror the plane:
        newplane = newplane:flip();
    end
    return newplane;
end

-- robust splitting of a line by a plane
-- will work even if the line is parallel to the plane
function CSGPlane:splitLineBetweenPoints(p1, p2)
    local direction = p2:minus(p1);
    local labda = (self.w - self.normal:dot(p1)) / self.normal:dot(direction);
    if (labda ~= labda) then	-- test for nan
		labda = 0;
	end
    if (labda > 1) then
		labda = 1;
	end
    if (labda < 0) then
		labda = 0;
	end
    local result = p1:plus(direction:times(labda));
    return result;
end

-- returns CSG.Vector3D
function CSGPlane:intersectWithLine(line3d)
    return line3d:intersectWithPlane(self);
end

-- intersection of two planes
function CSGPlane:intersectWithPlane(plane)
    return CSGLine3D.fromPlanes(self, plane);
end

function CSGPlane:signedDistanceToPoint(point)
    local t = self.normal:dot(point) - self.w;
    return t;
end

function CSGPlane:mirrorPoint(point3d)
    local distance = self:signedDistanceToPoint(point3d);
    local mirrored = point3d:minus(self.normal:times(distance * 2.0));
    return mirrored;
end