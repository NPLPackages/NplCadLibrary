--[[
Title: CSGPolygonTreeNode
Author(s): leio
Date: 2017/5/23
Desc: 
    // This class manages hierarchical splits of polygons
    // At the top is a root node which doesn hold a polygon, only child PolygonTreeNodes
    // Below that are zero or more 'top' nodes; each holds a polygon. The polygons can be in different planes
    // splitByPlane() splits a node by a plane. If the plane intersects the polygon, two new child nodes
    // are created holding the splitted polygon.
    // getPolygons() retrieves the polygon from the tree. If for PolygonTreeNode the polygon is split but
    // the two split parts (child nodes) are still intact, then the unsplit polygon is returned.
    // This ensures that we can safely split a polygon into many fragments. If the fragments are untouched,
    //  getPolygons() will return the original unsplit polygon instead of the fragments.
    // remove() removes a polygon from the tree. Once a polygon is removed, the parent polygons are invalidated
    // since they are no longer intact.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygonTreeNode.lua");
local CSGPolygonTreeNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygonTreeNode");
-------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CSGPolygonTreeNode = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygonTreeNode"));

local function indexOf(list,child)
    local index = 0;
    if(list and child)then
        for k,v in ipairs(list) do
            if(v == child)then
                return k;
            end
        end
    end
    return index;
end
function CSGPolygonTreeNode:ctor()
    self.parent = nil;
    self.children = {};
    self.polygon = nil;
    self.removed = false;
end
-- fill the tree with polygons. Should be called on the root node only; child nodes must
-- always be a derivate (split) of the parent node.
function CSGPolygonTreeNode:addPolygons(polygons)
    if(not self:isRootNode())then
        -- new polygons can only be added to root node; children can only be splitted polygons
        return
    end
    local polygon;
    for __,polygon in ipairs(polygons) do
        self:addChild(polygon);
    end
end
-- remove a node
-- - the siblings become toplevel nodes
-- - the parent is removed recursively
function CSGPolygonTreeNode:remove()
    if(not self:isRemoved())then
        self.removed = true;

        -- remove ourselves from the parent's children list:
        local parentschildren = self.parent.children;
        local i = indexOf(parentschildren,self);
        if(i > 0)then
            tableext.splice(parentschildren,i,1);
            -- invalidate the parent's polygon, and of all parents above it:
            self.parent:recursivelyInvalidatePolygon();
        end
    end
end
function CSGPolygonTreeNode:isRemoved()
     return self.removed;
end
function CSGPolygonTreeNode:isRootNode()
     return not self.parent;
end
-- invert all polygons in the tree. Call on the root node
function CSGPolygonTreeNode:invert()
    if(self:isRootNode())then
         self:invertSub();
    end
end
function CSGPolygonTreeNode:getPolygon()
    return self.polygon;
end
function CSGPolygonTreeNode:getPolygons(result)
    local children = {self};
    local queue = {children};
    local i, j, l, node;
    -- queue size can change in loop, don't cache length
    for i = 1,table.getn(queue) do
        children = queue[i];
        for j = 1,table.getn(children) do
            node = children[j];
            if (node.polygon) then
                -- the polygon hasn't been broken yet. We can ignore the children and return our polygon:
                table.insert(result,node.polygon);
            else
                -- our polygon has been split up and broken, so gather all subpolygons from the children
                table.insert(queue,node.children);
            end
        end
    end
end
-- split the node by a plane; add the resulting nodes to the frontnodes and backnodes array
-- If the plane doesn't intersect the polygon, the 'this' object is added to one of the arrays
-- If the plane does intersect the polygon, two new child nodes are created for the front and back fragments,
--  and added to both arrays.
function CSGPolygonTreeNode:splitByPlane(plane, coplanarfrontnodes, coplanarbacknodes, frontnodes, backnodes)
    if(#self.children > 0)then
         local queue = {self.children};
         local i, j, l, node, nodes;
         -- queue.length can increase, do not cache
         for i = 1,table.getn(queue) do
            nodes = queue[i];
            for j = 1,table.getn(nodes) do
                node = nodes[j];
                if (table.getn(node.children) > 0) then
                    table.insert(queue,node.children);
                else
                    -- no children. Split the polygon:
                    node:_splitByPlane(plane, coplanarfrontnodes, coplanarbacknodes, frontnodes, backnodes);
                end
            end
         end
    else
        self:_splitByPlane(plane, coplanarfrontnodes, coplanarbacknodes, frontnodes, backnodes);
    end
end
-- only to be called for nodes with no children
function CSGPolygonTreeNode:_splitByPlane(plane, coplanarfrontnodes, coplanarbacknodes, frontnodes, backnodes)
    local polygon = self.polygon;
    if (polygon) then
        local bound = polygon:boundingSphere();
        local sphereradius = bound[2] + tonumber("1e-4");
        local planenormal = plane:GetNormal();
        local spherecenter = bound[1];
        local d = planenormal:dot(spherecenter) - plane[4];
        if (d > sphereradius) then
            table.insert(frontnodes,self);
        elseif(d < -sphereradius) then
            table.insert(backnodes,self);
        else
            local splitresult = plane:splitPolygon(polygon);
            if(splitresult.type == 0)then
                -- coplanar front:
                table.insert(coplanarfrontnodes,self);
            elseif(splitresult.type == 1)then
                -- coplanar back:
                table.insert(coplanarbacknodes,self);
            elseif(splitresult.type == 2)then
                -- front:
                table.insert(frontnodes,self);
            elseif(splitresult.type == 3)then
                -- back:
                table.insert(backnodes,self);
            elseif(splitresult.type == 4)then
                -- spanning:
                if (splitresult.front) then
                    local frontnode = self:addChild(splitresult.front);
                    table.insert(frontnodes,frontnode);
                end
                if (splitresult.back) then
                    local backnode = self:addChild(splitresult.back);
                    table.insert(backnodes,backnode);
                end
            end
        end
    end
end
-- PRIVATE methods from here:
-- add child to a node
-- this should be called whenever the polygon is split
-- a child should be created for every fragment of the split polygon
-- returns the newly created child
function CSGPolygonTreeNode:addChild(polygon)
    local newchild = CSGPolygonTreeNode:new();
    newchild.parent = self;
    newchild.polygon = polygon;
    table.insert(self.children,newchild);
    return newchild;
end
function CSGPolygonTreeNode:invertSub()
    local children = {self};
    local queue = {children};
    local i, j, l, node;
    for i = 1,#queue do
        children = queue[i];
        for j = 1,#children do
            node = children[j];
            if (node.polygon) then
                node.polygon = node.polygon:flip();
            end
            table.insert(queue,node.children);
        end
    end
end
function CSGPolygonTreeNode:recursivelyInvalidatePolygon()
    local node = self;
    while (node.polygon) do
        node.polygon = nil;
        if (node.parent) then
            node = node.parent;
        end
    end
end
