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

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");

local CSGLine3D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D"));

local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");    
	
-- # class Line3D
function CSGLine3D:ctor()
    --self.point;
    --self.direction;
end

-- Represents a line in 3D space
-- direction must be a unit vector
-- point is a random point on the line
function CSGLine3D:init(point, direction)
    point = CSGVector:new():init(point);
    direction = CSGVector:new():init(direction);
    self.point = point;
    self.direction = direction:unit();
	return self;
end

function CSGLine3D.fromPoints(p1, p2)
    p1 = CSGVector:new():init(p1);
    p2 = CSGVector:new():init(p2);
    local direction = p2:minus(p1);
    return CSGLine3D:new():init(p1, direction);
end

function CSGLine3D.fromPlanes(p1, p2)
    local direction = p1.normal:cross(p2.normal);
    local l = direction:length();
    if (l < tonumber("1e-10")) then
		LOG.std(nil, "error", "CSGLine3D.fromPlanes", "Parallel planes");
		return nil;
    end
    direction = direction:times(1.0 / l);

    local mabsx = math.abs(direction[1]);
    local mabsy = math.abs(direction[2]);
    local mabsz = math.abs(direction[3]);
    local origin;
    if ((mabsx >= mabsy) and (mabsx >= mabsz)) then
        -- direction vector is mostly pointing towards x
        -- find a point p for which x is zero:
        local r = CSG.solve2Linear(p1.normal[2], p1.normal[3], p2.normal[2], p2.normal[3], p1.w, p2.w);
        origin = CSGVector:new():init(0, r[1], r[2]);
    elseif ((mabsy >= mabsx) and (mabsy >= mabsz)) then
        -- find a point p for which y is zero:
        local r = CSG.solve2Linear(p1.normal[1], p1.normal[3], p2.normal[1], p2.normal[3], p1.w, p2.w);
        origin = CSGVector:new():init(r[1], 0, r[2]);
    else
        -- find a point p for which z is zero:
        local r = CSG.solve2Linear(p1.normal[1], p1.normal[2], p2.normal[1], p2.normal[2], p1.w, p2.w);
        origin = CSGVector:new():init(r[1], r[2], 0);
    end
    return CSGLine3D:new():init(origin, direction);
end


function CSGLine3D:intersectWithPlane(plane)
    -- plane: plane.normal * p = plane.w
    -- line: p=line.point + labda * line.direction
    local labda = (plane.w - plane.normal:dot(self.point)) / plane.normal:dot(self.direction);
    local point = self.point:plus(self.direction:times(labda));
    return point;
end

function CSGLine3D:clone(line)
    return CSGLine3D:new():init(self.point:clone(), self.direction:clone());
end

function CSGLine3D:reverse()
    return CSGLine3D:new():init(self.point:clone(), self.direction:negated());
end

function CSGLine3D:transform(matrix4x4)
    local newpoint = self.point:multiply4x4(matrix4x4);
    local pointPlusDirection = self.point:plus(self.direction);
    local newPointPlusDirection = pointPlusDirection:multiply4x4(matrix4x4);
    local newdirection = newPointPlusDirection:minus(newpoint);
    return CSGLine3D:new():init(newpoint, newdirection);
end

function CSGLine3D:closestPointOnLine(point)
    point = CSGVector:new():init(point);
    local t = point:minus(self.point):dot(self.direction) / self.direction:dot(self.direction);
    local closestpoint = self.point:plus(self.direction:times(t));
    return closestpoint;
end

function CSGLine3D:distanceToPoint(point)
    point = CSGVector:new():init(point);
    local closestpoint = self:closestPointOnLine(point);
    local distancevector = point:minus(closestpoint);
    local distance = distancevector:length();
    return distance;
end

function CSGLine3D:equals(line3d)
    if (not self.direction:equals(line3d.direction)) then
		return false;
	end
    local distance = self:distanceToPoint(line3d.point);
    if (distance > tonumber("1e-8")) then
		return false;
	end
    return true;
end
