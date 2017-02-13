--[[
Title: object pool
Author(s): Lighter
Date: 2017/1/26
Desc: useful when creating lots of pool objects in a single frame. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)(gl)Mod/NplCadLibrary/utils/ObjectPool.lua");
local ObjectPool = commonlib.gettable("Mod.NplCadLibrary.utils.ObjectPool");
local object_pool = ObjectPool.GetInstance(class);
-- create from pool. 
local vecPool = object_pool:GetObject(x,y,z)
-- called between tick(not necessary if maxPoolSize is used)
vecPool:CleanPool();
-------------------------------------------------------
]]
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local ObjectPool = commonlib.gettable("Mod.NplCadLibrary.utils.ObjectPool");
ObjectPool.__index = ObjectPool;

 -- Maximum number of times the pool can be "cleaned" before the pool is shrunk
 -- in most cases, we clear pool every frame move. so 900 is like 30 seconds. 
ObjectPool.maxNumCleansToShrink = 30*30;
-- max number of entry to remove every Shrink function. 
ObjectPool.numEntriesToRemove = 500;
-- we will automatically reuse from beginning when reaching this value. 
-- such that CleanPool() is not a must-call function. Depending on usage pattern.
ObjectPool.maxPoolSize = 1000;

function ObjectPool:new()
	local o = {};
	-- Number of times this Pool has been cleaned
	o.numCleans = 0;
	-- List of vector stored in this Pool
	o.listObjects = commonlib.vector:new();
	-- Next index to use when adding a Pool Entry.
	o.nextPoolIndex = 1;
	-- Largest index reached by this Pool since last CleanPool operation. 
	o.maxPoolIndex = 0;
	-- Largest index reached by this Pool since last Shrink operation. 
	o.maxPoolIndexFromLastShrink = 0;

	setmetatable(o, self);
	return o;
end

local pools = {};
function ObjectPool.GetInstance(class)
	
	if(pools[class] == nil) then
		pools[class] = ObjectPool:new();
		pools[class]:init(ObjectPool.maxNumCleansToShrink,ObjectPool.numEntriesToRemove, ObjectPool.maxPoolSize);
	end
	return pools[class];
end

function ObjectPool:init(maxNumCleansToShrink, numEntriesToRemove, maxPoolSize)
	self.maxNumCleansToShrink = maxNumCleansToShrink;
	self.numEntriesToRemove = numEntriesToRemove;
	self.maxPoolSize = maxPoolSize;
	self.listObjects:resize(maxPoolSize);
	return self;
end

-- Creates a new Object, or reuses one that's no longer in use. 
-- @param func_creator,baseClass, class_mt:
-- returns from this function should only be used for one frame or tick, as after that they will be reused.
function ObjectPool:GetObject(func_creator,baseClass,class_mt)
    local object;
    if (self.nextPoolIndex > self.listObjects:size()) then
		object = func_creator(baseClass,class_mt);
		self.listObjects.add(object);
    else
        object = self.listObjects:get(self.nextPoolIndex);
    end

    self.nextPoolIndex = self.nextPoolIndex + 1;
	if(self.nextPoolIndex > self.maxPoolSize) then
		LOG.std(nil, "debug", "ObjectPool", "maxPoolSize reached %d", self.maxPoolSize);
		self.maxPoolIndex = self.maxPoolSize;
		self.nextPoolIndex = 1;
	end
    return object;
end

-- Marks the pool as "empty", starting over when adding new entries. If this is called maxNumCleansToShrink times, the list
-- size is reduced
function ObjectPool:CleanPool()
    if (self.nextPoolIndex > self.maxPoolIndex) then
        self.maxPoolIndex = self.nextPoolIndex;
    end

	if(self.maxPoolIndexFromLastShrink < self.maxPoolIndex) then
		self.maxPoolIndexFromLastShrink = self.maxPoolIndex;
	end

	self.numCleans = self.numCleans + 1;
    if (self.numCleans >= self.maxNumCleansToShrink) then
		self:Shrink();
    end
    self.nextPoolIndex = 1;
end

-- this function is called automatically inside CleanPool(). 
function ObjectPool:Shrink()
	local maxHistorySize = math.max(self.maxPoolIndexFromLastShrink, self.maxPoolIndex)
	local newSize = math.max(maxHistorySize, self.listObjects:size() - self.numEntriesToRemove);
	self.listObjects:resize(newSize);
    self.maxPoolIndex = 0;
    self.numCleans = 0;
	self.nextPoolIndex = 1;
end

-- Clears the ObjectPool
function ObjectPool:clearPool()
    self.nextPoolIndex = 1;
    self.listObjects:clear();
end

function ObjectPool:GetListVector3Dsize()
    return self.listObjects:size();
end

function ObjectPool:GetNextPoolIndex()
    return self.nextPoolIndex;
end