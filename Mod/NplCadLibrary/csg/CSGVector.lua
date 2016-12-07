--[[
Title: CSGVector
Author(s): leio, LiXizhi
Date: 2016/3/29
Desc: 
Represents a plane in 3D space.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");

local v1 = CSGVector:new():init(1,1,1);
local v2 = CSGVector:new():init(2,2,2);
echo(v1:plus(v2));
echo(v1:minus(v2));
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");

local math_abs = math.abs;
local CSGVector = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector"));
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");

--------------------
-- private vector pool
--------------------
local VectorPool = {};
VectorPool.__index = VectorPool;

-- we will automatically reuse from beginning when reaching this value. 
VectorPool.maxPoolSize = 300;

function VectorPool:new()
	local o = {};
	-- Number of times this Pool has been cleaned
	o.numCleans = 0;
	-- List of vector stored in this Pool
	o.listVector3D = commonlib.vector:new();
	-- Next index to use when adding a Pool Entry.
	o.nextPoolIndex = 1;
	-- Largest index reached by this Pool since last CleanPool operation. 
	o.maxPoolIndex = 0;
	-- Largest index reached by this Pool since last Shrink operation. 
	o.maxPoolIndexFromLastShrink = 0;
	o.maxPoolSize = VectorPool.maxPoolSize;
	setmetatable(o, self);
	return o;
end

-- Creates a new Vector, or reuses one that's no longer in use. 
-- @param x,y,z:
-- returns from this function should only be used for one frame or tick, as after that they will be reused.
function VectorPool:GetVector(x,y,z)
    local vec3d;

    if (self.nextPoolIndex > self.listVector3D:size()) then
		vec3d = CSGVector:new():set(x,y,z);
        self.listVector3D:add(vec3d);
    else
        vec3d = self.listVector3D:get(self.nextPoolIndex);
		vec3d:set(x,y,z);
    end

    self.nextPoolIndex = self.nextPoolIndex + 1;
	if(self.nextPoolIndex > self.maxPoolSize) then
		self.maxPoolIndex = self.maxPoolSize;
		self.nextPoolIndex = 1;
	end
    return vec3d;
end

local default_pool = VectorPool:new();

------------------------------------------
-- CSG Vector
------------------------------------------
function CSGVector:ctor()
	self[1] = 0;
	self[2] = 0;
	self[3] = 0;
end

function CSGVector:init(x,y,z)
	if y == nil then
		if(type(x) == "table")then
        self[1] = x[1];
        self[2] = x[2];
        self[3] = x[3];       
		elseif(type(x) == "number")then
			self[1] = x;
			self[2] = x;
			self[3] = x;
		end
    else
        self[1] = x;
        self[2] = y;
        self[3] = z;
    end
	return self;
end

CSGVector.set = CSGVector.init;

function CSGVector:clone()
	return CSGVector:new():init(self[1],self[2],self[3]);
end

function CSGVector:new_from_pool(x,y,z)
	return default_pool:GetVector(x,y,z);
end

function CSGVector:clone_from_pool()
	return default_pool:GetVector(self[1],self[2],self[3]);
end

function CSGVector:negated()
	return CSGVector:new():init(-self[1],-self[2],-self[3]);
end
function CSGVector:negatedInplace()
	self[1], self[2], self[3] = -self[1],-self[2],-self[3];
	return self;
end
function CSGVector:plus(a)
	return CSGVector:new():init(self[1] + a[1],self[2] + a[2],self[3] + a[3]);
end
function CSGVector:plusInplace(a)
	self[1], self[2], self[3] = self[1] + a[1],self[2] + a[2],self[3] + a[3];
	return self;
end
function CSGVector:minus(a)
	return CSGVector:new():init(self[1] - a[1],self[2] - a[2],self[3] - a[3]);
end
function CSGVector:minusInplace(a)
	self[1], self[2], self[3] = self[1] - a[1],self[2] - a[2],self[3] - a[3];
	return self;
end
function CSGVector:times(a)
	return CSGVector:new():init(self[1] * a,self[2] * a,self[3] * a);
end
function CSGVector:timesInplace(a)
	self[1], self[2], self[3] = self[1] * a,self[2] * a,self[3] * a;
	return self;
end

function CSGVector:dividedBy(a)
	return CSGVector:new():init(self[1] / a,self[2] / a,self[3] / a);
end

function CSGVector:dividedByInplace(a)
	self[1], self[2], self[3] = self[1] / a,self[2] / a,self[3] / a;
	return self;
end

function CSGVector:dot(a)
	return self[1] * a[1] + self[2] * a[2] + self[3] * a[3];
end
function CSGVector:lerp(a,t)
	return a:minus(self):timesInplace(t):plusInplace(self);
end
function CSGVector:length()
	return math.sqrt(self:dot(self));
end
function CSGVector:lengthSquared()
	return self:dot(self);
end
function CSGVector:unit()
	return self:dividedBy(self:length());
end
function CSGVector:unitInplace()
	return self:dividedByInplace(self:length());
end

function CSGVector:cross(a)
	return CSGVector:new():init( 
		self[2] * a[3] - self[3] * a[2],
		self[3] * a[1] - self[1] * a[3],
		self[1] * a[2] - self[2] * a[1]);
end

function CSGVector:crossInplace(a)
	self[1], self[2], self[3] = 
			self[2] * a[3] - self[3] * a[2],
			self[3] * a[1] - self[1] * a[3],
			self[1] * a[2] - self[2] * a[1];
	return self;
end

function CSGVector:abs()
	return CSGVector:new():init(math_abs(self[1]),math_abs(self[2]),math_abs(self[3]));
end

function CSGVector:absInplace()
	self[1], self[2], self[3] = math_abs(self[1]),math_abs(self[2]),math_abs(self[3]);
	return self;
end
function CSGVector:getX() 
    return self[1];
end
function CSGVector:getY() 
    return self[2];
end
function CSGVector:getZ() 
    return self[3];
end
-- extend to a 3D vector by adding a y coordinate:
function CSGVector:toVector2D()
    return CSGVector2D:new():init(self[1], self[3]);
end

function CSGVector:equals(a)
	return (self[1] == a[1]) and (self[2] == a[2]) and (self[3] == a[3]);
end

function CSGVector:multiply4x4(matrix4x4)
	return matrix4x4:leftMultiply1x3Vector(self);
end

function CSGVector:transform(matrix4x4)
	return matrix4x4:leftMultiply1x3Vector(self);
end

-- find a vector that is somewhat perpendicular to this one
function CSGVector:randomNonParallelVector()
	local abs = self:abs();
	if ((abs[1] <= abs[2]) and (abs[1] <= abs[3])) then
		return CSGVector:new():init(1, 0, 0);
	elseif ((abs[2] <= abs[1]) and (abs[2] <= abs[3])) then
		return CSGVector:new():init(0, 1, 0);
	else
		return CSGVector:new():init(0, 0, 1);
	end
end

function CSGVector:min(p)
	return CSGVector:new():init(
		math.min(self[1], p[1]), math.min(self[2], p[2]), math.min(self[3], p[3]));
end

function CSGVector:max(p)
	return CSGVector:new():init(
		math.max(self[1], p[1]), math.max(self[2], p[2]), math.max(self[3], p[3]));
end

function CSGVector:distanceTo(a)
	return self:minus(a):length();
end
function CSGVector:distanceToSquared(a)
	return self:minus(a):lengthSquared();
end