--[[
Title: CSGNode
Author(s): leio
Date: 2017/5/23
Desc: 
// Holds a node in a BSP tree. A BSP tree is built from a collection of polygons
// by picking a polygon to split along.
// Polygons are not stored directly in the tree, but in PolygonTreeNodes, stored in
// this.polygontreenodes. Those PolygonTreeNodes are children of the owning
// CSG.Tree.polygonTree
// This is not a leafy BSP tree since there is
// no distinction between internal and leaf nodes.

This class uses copy on write policy
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGNode.lua");
local CSGNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGNode");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)script/ide/STL.lua");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGNode = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGNode"));

function CSGNode:ctor()
end
function CSGNode:init(parent)
    self.plane = nil;
    self.front = nil;
    self.back = nil;
    self.polygontreenodes = {};
    self.parent = parent;
    return self;
end
-- Convert solid space to empty space and empty space to solid space.
function CSGNode:invert()
    local queue = {self};
    local i,node;
    for i = 1, #queue do
        node = queue[i];
         if(node.plane)then
            node.plane = node.plane:clone():inverse();
        end
        if(node.front)then 
            table.insert(queue,node.front);
        end
        if(node.back)then 
            table.insert(queue,node.back);
        end
        local temp = node.front;
        node.front = node.back;
        node.back = temp;
    end
end
-- clip polygontreenodes to our plane
-- calls remove() for all clipped PolygonTreeNodes
function CSGNode:clipPolygons(polygontreenodes, alsoRemovecoplanarFront)
    local args = { node = self, polygontreenodes = polygontreenodes,};
    local node;
    local stack = commonlib.Stack:Create();
    while(args) do
        node = args.node;
        polygontreenodes = args.polygontreenodes;
        if(node.plane)then
            local backnodes = {};
            local frontnodes = {};
            local coplanarfrontnodes;
            if(alsoRemovecoplanarFront)then
                coplanarfrontnodes = backnodes;
            else
                coplanarfrontnodes = frontnodes;
            end
            local plane = node.plane;
            local numpolygontreenodes = #polygontreenodes;
            for i = 1,numpolygontreenodes do
                local node1 = polygontreenodes[i];
                if(not node1:isRemoved())then
                    node1:splitByPlane(plane, coplanarfrontnodes, backnodes, frontnodes, backnodes);
                end
            end
            if(node.front and #frontnodes > 0) then
                stack:push({ node = node.front, polygontreenodes = frontnodes});
            end
            local numbacknodes = #backnodes;
            if (node.back and numbacknodes > 0) then
                stack:push({ node = node.back, polygontreenodes = backnodes});
            else
                -- there's nothing behind this plane. Delete the nodes behind this plane:
                for i = 1,numbacknodes do
                    backnodes[i]:remove();
                end
            end
        end
        args = stack:pop();
    end
end
-- Remove all polygons in this BSP tree that are inside the other BSP tree
function CSGNode:clipTo(tree, alsoRemovecoplanarFront)
    local node = self;
    local stack = commonlib.Stack:Create();
    while(node) do
        if(#node.polygontreenodes > 0)then
            tree.rootnode:clipPolygons(node.polygontreenodes, alsoRemovecoplanarFront);
        end
        if(node.front)then
            stack:push(node.front);
        end
        if(node.back)then
            stack:push(node.back);
        end
        node = stack:pop();
    end
end
function CSGNode:addPolygonTreeNodes(polygontreenodes)
    local args = { node = self, polygontreenodes = polygontreenodes,};
    local node;
    local stack = commonlib.Stack:Create();
    while(args) do
        node = args.node;
        polygontreenodes = args.polygontreenodes;
        local continue = true
        if(#polygontreenodes == 0)then
            args = stack:pop();
            continue = false;
        end
        if(continue)then
            local _this = node;
            if(not node.plane)then
                local bestplane = polygontreenodes[1]:getPolygon():GetPlane();
                node.plane = bestplane;
            end
            local frontnodes = {};
            local backnodes = {};
            for i = 1,#polygontreenodes do
                polygontreenodes[i]:splitByPlane(_this.plane, _this.polygontreenodes, backnodes, frontnodes, backnodes);
            end
            if(#frontnodes > 0)then
                if(not node.front)then
                    node.front = CSGNode:new():init(node);
                    stack:push({ node = node.front, polygontreenodes = frontnodes});
                end
            end
            if(#backnodes > 0)then
                if(not node.back)then
                    node.back = CSGNode:new():init(node);
                    stack:push({ node = node.back, polygontreenodes = backnodes});
                end
            end
            args = stack:pop();
        end
    end
end
function CSGNode:getParentPlaneNormals(normals, maxdepth)
    if (maxdepth > 0) then
        if (self.parent) then
            table.insert(normals,self.parent.plane:GetNormal());
            self.parent:getParentPlaneNormals(normals, maxdepth - 1);
        end
    end
end