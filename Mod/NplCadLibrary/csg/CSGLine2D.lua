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
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");

NPL.load("(gl)script/ide/math/vector.lua");

NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");

local vector2d = commonlib.gettable("mathlib.vector2d");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");

local CSGLine2D = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine2D"));

-- # class Line2D

function CSGLine2D:ctor()
	if(commonlib.use_object_pool) then
		self.normal = self.normal or vector2d:new_from_pool(0,0);
	else
		self.normal = self.normal or vector2d:new();
	end
    self.w = 0;
end

-- Represents a directional line in 2D space
-- A line is parametrized by its normal vector (perpendicular to the line, rotated 90 degrees counter clockwise)
-- and w. The line passes through the point <normal>.times(w).
-- normal must be a unit vector!
-- Equation: p is on line if normal.dot(p)==w
function CSGLine2D:init(normal, w) 
	self.normal:set(normal);
    
	local l = self.normal:length();
    w = w * l;
    
	self.normal:MulByFloat(1.0 / l);
    self.w = w;
	return self;
end

function CSGLine2D:clone(line)
    return CSGLine2D:new():init(self.normal, self.w);
end

function CSGLine2D.fromPoints(p1, p2)
    local direction = p2 - p1;
    local normal = direction:normal():negated():normalize();
    local w = p1:dot(normal);
    return CSGLine2D:new():init(normal, w);
end



-- same line but opposite direction:
function CSGLine2D:reverse()
    self.normal:negated();
	self.w = -self.w;
	return self;
end

function CSGLine2D:equals(l,epsilon)
	epsilon = epsilon or 0;
    return (l.normal:equals(self.normal,epsilon) and (math.abs(l.w - self.w)<=epsilon));
end

function CSGLine2D:origin()
    return self.normal * self.w;
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
    local point_projected = point:dot(self.normal);
    local distance = math.abs(point_projected - self.w);
    return distance;
end

--[[FIXME: has error - origin is not defined, the method is never used
function CSGLine2D:closestPoint(point)
    point = vector2d:new(point);
    local vector = point.dot(self.direction());
    return origin.plus(vector);
end
--]]

-- intersection between two lines, returns point as Vector2D
function CSGLine2D:intersectWithLine(line2d)
    local point = CSG.solve2Linear(self.normal[1], self.normal[2], line2d.normal[1], line2d.normal[2], self.w, line2d.w);
    point = vector2d:new(point); -- make  vector2d
    return point;
end

function CSGLine2D:transform(matrix4x4)
	local old_normal = self.normal:clone();
	self.normal = self.normal:transform_normal(matrix4x4):normalize(); 
   
    local newpointOnPlane = old_normal:MulByFloat(self.w):transform(matrix4x4);
    self.w = self.normal:dot(newpointOnPlane);
    return self;
end
