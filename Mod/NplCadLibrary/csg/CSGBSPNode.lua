--[[
Title: CSGBSPNode
Author(s): leio
Date: 2016/3/29
Desc: 
Holds a node in a BSP tree. A BSP tree is built from a collection of polygons
by picking a polygon to split along. That polygon (and all other coplanar
polygons) are added directly to that node and the other polygons are added to
the front and/or back subtrees. This is not a leafy BSP tree since there is
no distinction between internal and leaf nodes.

This class uses copy on write policy
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGBSPNode.lua");
local CSGBSPNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGBSPNode");
-------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPlane.lua");

local CSGBSPNode = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGBSPNode"));

-- move polygons from source to result, if result is nil, a new table is created. 
-- @param source: array of polygons
-- @param result: [inout] nil or target polygon tables.
-- @return result
local function movePolygons(source, result)
	if(not source)then
		return
	end
	result = result or {};
	for i = 1, #source do
		result[#result+1] = source[i];
	end
	return result;
end

function CSGBSPNode:ctor()
end

function CSGBSPNode:init(polygons)
	self.plane = nil;
	self.front = nil;
	self.back = nil;
	if (polygons) then
		self:build(polygons);
	end
	return self;
end

-- this is a copy on write clone
function CSGBSPNode:clone()
	local node = CSGBSPNode:new();
	node.plane = self.plane;
	if(self.front)then
		node.front = self.front:clone();
	end
	if(self.back)then
		node.back = self.back:clone();
	end
	if(self.polygons) then
		node.polygons = movePolygons(self.polygons);
	end
	return node;
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CSGBSPNode:detach()
	self.plane = self.plane and self.plane:clone();
	local polygons = self.polygons;
	if(polygons) then
		for i=1, #polygons do
			polygons[i] = polygons[i]:clone();
		end
	end
	return self;
end

--Convert solid space to empty space and empty space to solid space.
function CSGBSPNode:invert(bInplace)
	local polygons = self.polygons;
	if(polygons) then
		for i=1, #polygons do
			polygons[i] = polygons[i]:clone():flip();
		end
	end
	if(self.plane)then
		self.plane = self.plane:clone():flip();
	end
	if(self.front)then
		self.front:invert(bInplace);
	end
	if(self.back)then
		self.back:invert(bInplace);
	end
	self.front, self.back = self.back, self.front;
end

--Recursively remove all polygons in `polygons` that are inside this BSP tree.
function CSGBSPNode:clipPolygons(polygons)
	if(not polygons) then
		return
	end
	if(not self.plane)then
		return movePolygons(polygons);
	end
	local front, back;
	for k,p in ipairs(polygons) do
		local front1, back1, coplanarFront, coplanarBack = self.plane:splitPolygon(p,front, back, front, back);
		if(not front) then
			front = front1 or coplanarFront;
		end
		if(not back) then
			back = back1 or coplanarBack;
		end
	end
	if(self.front)then
		front = self.front:clipPolygons(front);
	end
	if(self.back)then
		back = self.back:clipPolygons(back);
	else
		back = nil; 
	end
	return front and movePolygons(front, back) or back;
end

--Remove all polygons in this BSP tree that are inside the other BSP tree 'bsp'.
-- @param bsp: another CSGBSPNode
function CSGBSPNode:clipTo(bsp)
	if(not bsp)then return end
	if(self.polygons) then
		self.polygons = bsp:clipPolygons(self.polygons);
	end
	if(self.front)then
		self.front:clipTo(bsp);
	end
	if(self.back)then
		self.back:clipTo(bsp);
	end
end

--Return a list of all polygons in this BSP tree.
-- @param result: inout, array of polygons
function CSGBSPNode:allPolygons(result)
	result = result or {};
	if(self.polygons) then
		movePolygons(self.polygons, result);
	end
	if(self.front)then
		self.front:allPolygons(result);
	end
	if(self.back)then
		self.back:allPolygons(result);
	end
	return result;
end

--Build a BSP tree out of `polygons`. When called on an existing tree, the
--new polygons are filtered down to the bottom of the tree and become new
--nodes there. Each set of polygons is partitioned using the first polygon
--(no heuristic is used to pick a good split).
function CSGBSPNode:build(polygons)
	if(not polygons or #polygons == 0)then
		return;
	end
	local front;
	local back;

	if(not self.plane) then
		self.plane = polygons[1]:GetPlane();
		
		self.polygons = self.polygons or {};
		self.polygons[#self.polygons+1] = polygons[1];

		for i = 2, #polygons do
			front, back, self.polygons = self.plane:splitPolygon(polygons[i], self.polygons, self.polygons, front, back);
		end	
	else
		for i = 1, #polygons do
			front, back, self.polygons = self.plane:splitPolygon(polygons[i], self.polygons, self.polygons, front, back);
		end	
	end
	
	
	if(front)then
		if(not self.front)then
			self.front = CSGBSPNode:new():init();
		end
		self.front:build(front);
	end
	if(back)then
		if(not self.back)then
			self.back = CSGBSPNode:new():init();
		end
		self.back:build(back);
	end
end

function CSGBSPNode:getVertexCnt()
	local cnt = 0;
	if(self.polygons) then
		for k,p in ipairs(self.polygons) do
			cnt  = cnt  + p:getVertexCnt();
		end
	end
	return cnt;
end