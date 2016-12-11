--[[
Title: CSGLine2D
Author(s): Skeleton
Date: 2016/11/28
Desc: 
Represents a Line in 2D space.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine2D.lua");
local CSGLine2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine2D");
-------------------------------------------------------
]]  

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");

local CSGLine2D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine2D"));

local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");

-- # class Line2D

function CSGLine2D:ctor()
    --self.normal;
    --self.w;
end

-- Represents a directional line in 2D space
-- A line is parametrized by its normal vector (perpendicular to the line, rotated 90 degrees counter clockwise)
-- and w. The line passes through the point <normal>.times(w).
-- normal must be a unit vector!
-- Equation: p is on line if normal.dot(p)==w
function CSGLine2D:init(normal, w) 
    normal = CSGVector2D:new():init(normal);
    -- w = parseFloat(w);
    local l = normal:length();
    -- normalize:
    w = w * l;
    normal = normal:times(1.0 / l);
    self.normal = normal;
    self.w = w;
	return self;
end

function CSGLine2D.fromPoints(p1, p2)
    p1 = CSGVector2D:new():init(p1);
    p2 = CSGVector2D:new():init(p2);
    local direction = p2:minus(p1);
    local normal = direction:normal():negated():unit();
    local w = p1:dot(normal);
    return CSGLine2D:new():init(normal, w);
end



-- same line but opposite direction:
function CSGLine2D:reverse()
    return CSGLine2D:new():init(self.normal:negated(), -self.w);
end

function CSGLine2D:equals(l)
    return (l.normal:equals(self.normal) and (l.w == self.w));
end

function CSGLine2D:origin()
    return self.normal:times(self.w);
end

function CSGLine2D:direction()
    return self.normal:normal();
end

function CSGLine2D:xAtY(y)
    -- (py == y) and (normal * p == w)
    -- -> px = (w - normal.y * y) / normal.x
    local x = (self.w - self.normal[2] * y) / self.normal[1];
    return x;
end

function CSGLine2D:absDistanceToPoint(point)
    point = CSGVector2D:new():init(point);
    local point_projected = point:dot(self.normal);
    local distance = math.abs(point_projected - self.w);
    return distance;
end

--[[FIXME: has error - origin is not defined, the method is never used
function CSGLine2D:closestPoint(point)
    point = CSGVector2D:new():init(point);
    local vector = point.dot(self.direction());
    return origin.plus(vector);
end
--]]

-- intersection between two lines, returns point as Vector2D
function CSGLine2D:intersectWithLine(line2d)
    local point = CSG.solve2Linear(self.normal[1], self.normal[2], line2d.normal[1], line2d.normal[2], self.w, line2d.w);
    point = CSGVector2D:new():init(point); -- make  vector2d
    return point;
end

function CSGLine2D:transform(matrix4x4)
    local origin = CSGVector2D:new():init(0, 0);
    local pointOnPlane = self.normal:times(self.w);
    local neworigin = origin:multiply4x4(matrix4x4);
    local neworiginPlusNormal = self.normal:multiply4x4(matrix4x4);
    local newnormal = neworiginPlusNormal:minus(neworigin);
    local newpointOnPlane = pointOnPlane:multiply4x4(matrix4x4);
    local neww = newnormal:dot(newpointOnPlane);
    return CSGLine2D:new():init(newnormal, neww);
end
