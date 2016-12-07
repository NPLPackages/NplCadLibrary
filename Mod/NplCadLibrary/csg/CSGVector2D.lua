--[[
Title: CSGVector2D
Author(s): Skeleton
Date: 2016/11/26
Desc: 
Represents a Vector in 2D space.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");

local v1 = CSGVector2D:new():init(1,1);
local v2 = CSGVector2D:new():init(2,2);
echo(v1:plus(v2));
echo(v1:minus(v2));
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");

local math_abs = math.abs;
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGVector2D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D"));
local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");

--------------------
-- private vector pool
--------------------
local VectorPool = {};
VectorPool.__index = VectorPool;

-- we will automatically reuse from beginning when reaching self value. 
VectorPool.maxPoolSize = 300;

function VectorPool:new()
	local o = {};
	-- Number of times self Pool has been cleaned
	o.numCleans = 0;
	-- List of vector stored in self Pool
	o.listVector2D = commonlib.vector:new();
	-- Next index to use when adding a Pool Entry.
	o.nextPoolIndex = 1;
	-- Largest index reached by self Pool since last CleanPool operation. 
	o.maxPoolIndex = 0;
	-- Largest index reached by self Pool since last Shrink operation. 
	o.maxPoolIndexFromLastShrink = 0;
	o.maxPoolSize = VectorPool.maxPoolSize;
	setmetatable(o, self);
	return o;
end

-- Creates a new Vector, or reuses one that's no longer in use. 
-- @param x,y,z:
-- returns from self function should only be used for one frame or tick, as after that they will be reused.
function VectorPool:GetVector(x,y)
    local vec2d;

    if (self.nextPoolIndex > self.listVector2D:size()) then
		vec2d = CSGVector2D:new():set(x,y);
        self.listVector2D:add(vec2d);
    else
        vec2d = self.listVector2D:get(self.nextPoolIndex);
		vec2d:set(x,y);
    end

    self.nextPoolIndex = self.nextPoolIndex + 1;
	if(self.nextPoolIndex > self.maxPoolSize) then
		self.maxPoolIndex = self.maxPoolSize;
		self.nextPoolIndex = 1;
	end
    return vec2d;
end

local default_pool = VectorPool:new();

------------------------------------------
-- CSG Vector
------------------------------------------

function CSGVector2D.fromAngle(radians)
   return CSGVector2D.fromAngleRadians(radians);
end
function CSGVector2D.fromAngleDegrees(degrees)
   local radians = math.pi * degrees / 180;
   return CSGVector2D.fromAngleRadians(radians);
end
function CSGVector2D.fromAngleRadians(radians)
   return CSGVector2D:new():init(math.cos(radians), math.sin(radians));
end

function CSGVector2D:ctor()
	self[1] = 0;
	self[2] = 0;
end

function CSGVector2D:init(x,y)
	if y == nil then
		if(type(x) == "table")then
			self[1] = x[1];
			self[2] = x[2];
 		elseif(type(x) == "number")then
			self[1] = x;
			self[2] = x;
		end
    else
        self[1] = x;
        self[2] = y;
    end
	return self;
end

CSGVector2D.set = CSGVector2D.init;

function CSGVector2D:clone()
	return CSGVector2D:new():init(self[1],self[2]);
end

function CSGVector2D:new_from_pool(x,y)
	return default_pool:GetVector(x,y);
end

function CSGVector2D:clone_from_pool()
	return default_pool:GetVector(self[1],self[2]);
end

function CSGVector2D:negated()
	return CSGVector2D:new():init(-self[1],-self[2]);
end
function CSGVector2D:negatedInplace()
	self[1], self[2] = -self[1],-self[2];
	return self;
end
function CSGVector2D:plus(a)
	return CSGVector2D:new():init(self[1] + a[1],self[2] + a[2]);
end
function CSGVector2D:plusInplace(a)
	self[1], self[2] = self[1] + a[1],self[2] + a[2];
	return self;
end
function CSGVector2D:minus(a)
	return CSGVector2D:new():init(self[1] - a[1],self[2] - a[2]);
end
function CSGVector2D:minusInplace(a)
	self[1], self[2] = self[1] - a[1],self[2] - a[2];
	return self;
end
function CSGVector2D:times(a)
	return CSGVector2D:new():init(self[1] * a,self[2] * a);
end
function CSGVector2D:timesInplace(a)
	self[1], self[2] = self[1] * a,self[2] * a;
	return self;
end

function CSGVector2D:dividedBy(a)
	return CSGVector2D:new():init(self[1] / a,self[2] / a);
end

function CSGVector2D:dividedByInplace(a)
	self[1], self[2] = self[1] / a,self[2] / a;
	return self;
end

function CSGVector2D:dot(a)
	return self[1] * a[1] + self[2] * a[2];
end
function CSGVector2D:lerp(a,t)
	return a:minus(self):timesInplace(t):plusInplace(self);
end
function CSGVector2D:length()
	return math.sqrt(self:dot(self));
end
function CSGVector2D:lengthSquared()
	return self:dot(self);
end
function CSGVector2D:unit()
	return self:dividedBy(self:length());
end
function CSGVector2D:unitInplace()
	return self:dividedByInplace(self:length());
end

function CSGVector2D:cross(a)
	return CSGVector2D:new():init( 
		self[1] * a[2] - self[2] * a[1]);
end

function CSGVector2D:crossInplace(a)
	self[1], self[2] = 
			self[1] * a[2] - self[2] * a[1];
	return self;
end
-- returns the vector rotated by 90 degrees clockwise
function CSGVector2D:normal()
    return CSGVector2D:new():init(self[2], -self[1]);
end
function CSGVector2D:abs()
	return CSGVector2D:new():init(math_abs(self[1]),math_abs(self[2]));
end

function CSGVector2D:absInplace()
	self[1], self[2] = math_abs(self[1]),math_abs(self[2]);
	return self;
end
function CSGVector2D:getX() 
    return self[1];
end
function CSGVector2D:getY() 
    return self[2];
end
-- extend to a 3D vector by adding a y coordinate:
function CSGVector2D:toVector3D(y)
    return CSGVector:new():init(self[1], y, self[2]);
end

function CSGVector2D:equals(a)
	return (self[1] == a[1]) and (self[2] == a[2]);
end

function CSGVector2D:multiply4x4(matrix4x4)
    return matrix4x4:leftMultiply1x2Vector(self);
end

function CSGVector2D:transform(matrix4x4)
    return matrix4x4:leftMultiply1x2Vector(self);
end

function CSGVector2D:angle()
    return self:angleRadians();
end

function CSGVector2D:angleDegrees()
    local radians = self:angleRadians();
    return 180 * radians / mathext.pi;
end

function CSGVector2D:angleRadians()
    -- y=sin, x=cos
    return math.atan2(self[2], self[1]);
end

function CSGVector2D:min(p)
    return CSGVector2D:new():init(
        math.min(self[1], p[1]), math.min(self[2], p[2]));
end

function CSGVector2D:max(p)
    return CSGVector2D:new():init(
        math.max(self[1], p[1]), math.max(self[2], p[2]));
end
function CSGVector2D:distanceTo(a)
	return self:minus(a):length();
end
function CSGVector2D:distanceToSquared(a)
	return self:minus(a):lengthSquared();
end
