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
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGBSPNode.lua");
local CSGBSPNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGBSPNode");
-------------------------------------------------------
]]
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
	for k,v in ipairs(source) do
		result[#result+1] = v;
	end
	return result;
end

function CSGBSPNode:ctor()
end
function CSGBSPNode:init(polygons)
	self.plane = nil;
	self.front = nil;
	self.back = nil;
	self.polygons = {};
	if (polygons) then
		self:build(polygons);
	end
	return self;
end
function CSGBSPNode:clone()
	local node = CSGBSPNode:new();
	if(self.plane)then
		node.plane = self.plane:clone();
	end
	if(self.front)then
		node.front = self.front:clone();
	end
	if(self.back)then
		node.back = self.back:clone();
	end
	local polygons = {};
	for k,p in ipairs(self.polygons) do
		table.insert(polygons,p:clone());
	end
	node.polygons = polygons;
	return node;
end
--Convert solid space to empty space and empty space to solid space.
function CSGBSPNode:invert()
	for k,p in ipairs(self.polygons) do
		p:flip();
	end
	if(self.plane)then
		self.plane:flip();
	end
	if(self.front)then
		self.front:invert();
	end
	if(self.back)then
		self.back:invert();
	end
	local temp = self.front;
	self.front = self.back;
	self.back = temp;
end
--Recursively remove all polygons in `polygons` that are inside this BSP tree.
function CSGBSPNode:clipPolygons(polygons)
	if(not self.plane)then
		return movePolygons(polygons);
	end
	local front = {};
	local back = {};
	for k,p in ipairs(polygons) do
		self.plane:splitPolygon(p,front, back, front, back);
	end
	if(self.front)then
		front = self.front:clipPolygons(front);
	end
	if(self.back)then
		back = self.back:clipPolygons(back);
	else
		back = {};
	end
	return movePolygons(front,back);
end
--Remove all polygons in this BSP tree that are inside the other BSP tree 'bsp'.
function CSGBSPNode:clipTo(bsp)
	if(not bsp)then return end
	self.polygons = bsp:clipPolygons(self.polygons);
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
	movePolygons(self.polygons, result);
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

	if(not self.plane)then
		self.plane = polygons[1].plane:clone();
	end
	for i = 1, #polygons do
		front, back = self.plane:splitPolygon(polygons[i], self.polygons, self.polygons, front, back);
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
	for k,p in ipairs(self.polygons) do
		cnt  = cnt  + p:getVertexCnt();
	end
	return cnt;
end