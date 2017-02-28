--[[
Title: CSGLine3D
Author(s): Skeleton
Date: 2016/11/28
Desc: 
Represents a Line in 3D space.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/function CSGLine3D.lua");
local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
-------------------------------------------------------
]] 
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");
 
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");

local vector3d = commonlib.gettable("mathlib.vector3d");
local Plane = commonlib.gettable("mathlib.Plane");
local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");

local CSGLine3D = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D"));
	
function CSGLine3D:ctor()
	if(commonlib.use_object_pool) then
		self.point = self.point or vector3d:new_from_pool(0,0,0);
		self.direction= self.direction or vector3d:new_from_pool(0,0,0);
	else
		self.point = self.point or vector3d:new();
		self.direction= self.direction or vector3d:new();
	end
end

-- Represents a line in 3D space
-- direction must be a unit vector
-- point is a random point on the line
function CSGLine3D:init(point, direction)
	self.point:set(point);
	self.direction:set(direction);
	self.direction:normalize();
	return self;
end

function CSGLine3D.fromPoints(p1, p2)
    return CSGLine3D:new():init(p1, p2-p1);
end

function CSGLine3D.fromPlanes(p1, p2)
    local direction = Plane.cross(p1,p2);	-- cross 
    local l = direction:length();
    if (l < tonumber("1e-10")) then
		LOG.std(nil, "error", "CSGLine3D.fromPlanes", "Parallel planes");
		return nil;
    end

    local mabsx = math.abs(direction[1]);
    local mabsy = math.abs(direction[2]);
    local mabsz = math.abs(direction[3]);
    local origin;
    if ((mabsx >= mabsy) and (mabsx >= mabsz)) then
        -- direction vector is mostly pointing towards x
        -- find a point p for which x is zero:
        local r = CSG.solve2Linear(p1[2], p1[3], p2[2], p2[3], p1[4], p2[4]);
        origin = vector3d:new(0, r[1], r[2]);
    elseif ((mabsy >= mabsx) and (mabsy >= mabsz)) then
        -- find a point p for which y is zero:
        local r = CSG.solve2Linear(p1[1], p1[3], p2[1], p2[3], p1[4], p2[4]);
        origin = vector3d:new(r[1], 0, r[2]);
    else
        -- find a point p for which z is zero:
        local r = CSG.solve2Linear(p1[1], p1[2], p2[1], p2[2], p1[4], p2[4]);
        origin = vector3d:new(r[1], r[2],0);
    end
    return CSGLine3D:new():init(origin, direction);
end


function CSGLine3D:intersectWithPlane(plane)
    -- plane: plane.normal * p = plane.w
    -- line: p=line.point + labda * line.direction
	local nx,ny,nz = self.direction:get();
    local labda = (-plane:signedDistanceToPoint(self.point)) / plane:PlaneDotNormal(nx,ny,nz);
    return self.point + (self.direction * labda);
end

function CSGLine3D:clone(line)
    return CSGLine3D:new():init(self.point, self.direction);
end

function CSGLine3D:reverse()
	self.direction:negated();
    return self;
end

function CSGLine3D:transform(matrix4x4)
	self.point:transform(matrix4x4);
	self.direction:transform_normal(matrix4x4):normalize();
    return self;
end

function CSGLine3D:closestPointOnLine(point)
    local t = (point - self.point):dot(self.direction) / self.direction:dot(self.direction);
    return self.point + (self.direction * t);
end

function CSGLine3D:distanceToPoint(point)
    local closestpoint = self:closestPointOnLine(point);
    local distancevector = point - closestpoint;
    return distancevector:length();
end

function CSGLine3D:equals(line3d,epsilon)
	epsilon = epsilon or 0;
    if (not self.direction:equals(line3d.direction,epsilon)) then
		return false;
	end
    local distance = self:distanceToPoint(line3d.point);
    if (distance > epsilon) then
		return false;
	end
    return true;
end

function CSGLine3D:onePointOnLine(distance)
	local p = self.direction * distance;
	return p:add(self.point);
end
