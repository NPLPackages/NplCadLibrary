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
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
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
function CSGPolygonTreeNode:invertSub()
    self:visit(function(node)
        if (node.polygon) then
            node.polygon = node.polygon:flip();
        end    
    end)
end
function CSGPolygonTreeNode:getPolygon()
    return self.polygon;
end
function CSGPolygonTreeNode:visit(func)
    if(not func)then return end
    func(self);
    local k,v;
    for k,v in ipairs (self.children) do
        v:visit(func(v));
    end
end
function CSGPolygonTreeNode:getPolygons(result)
    self:visit(function(node)
        if (node.polygon) then
            table.insert(result,node.polygon);
        end    
    end)
end
-- split the node by a plane; add the resulting nodes to the frontnodes and backnodes array
-- If the plane doesn't intersect the polygon, the 'this' object is added to one of the arrays
-- If the plane does intersect the polygon, two new child nodes are created for the front and back fragments,
--  and added to both arrays.
function CSGPolygonTreeNode:splitByPlane(plane, coplanarfrontnodes, coplanarbacknodes, frontnodes, backnodes)
    self:visit(function(node)
        node:_splitByPlane(plane, coplanarfrontnodes, coplanarbacknodes, frontnodes, backnodes);
    end)
end
-- only to be called for nodes with no children
function CSGPolygonTreeNode:_splitByPlane(plane, coplanarfrontnodes, coplanarbacknodes, frontnodes, backnodes)
    local polygon = self.polygon;
    if (polygon) then
        -- ignore self.polygon split itself
        local polygon_plane = polygon:GetPlane();
        if(polygon_plane:equals(plane))then
            return
        end
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
            local splitresult = CSGPolygonTreeNode.splitPolygon(plane,polygon);
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
-- Returns object:
-- .type:
--   0: coplanar-front
--   1: coplanar-back
--   2: front
--   3: back
--   4: spanning
-- In case the polygon is spanning, returns:
-- .front: a CSG.Polygon of the front part
-- .back: a CSG.Polygon of the back part
function CSGPolygonTreeNode.splitPolygon(plane,polygon)
    local result = {
        type = nil,
        front = nil,
        back = nil
    };
    if(not plane or not polygon)then
        return result;
    end
    local this_plane = plane;
    local planenormal = plane:GetNormal();
    local vertices = polygon.vertices;
    local numvertices = #vertices;
    local polygon_plane = polygon:GetPlane();
    if (polygon_plane:equals(this_plane)) then
        result.type = 0;
    else 
        local EPS = CSG.EPSILON;
        local thisw = this_plane[4];
        local hasfront = false;
        local hasback = false;
        local vertexIsBack = {};
        local MINEPS = -EPS;
        for i = 1,numvertices do
            local t = planenormal:clone():dot(vertices[i].pos) - thisw;
            local isback;
            if(t < 0)then
                isback = "true";
            else
                isback = "false";
            end
            table.insert(vertexIsBack,isback);
            if (t > EPS) then hasfront = true; end
            if (t < MINEPS) then hasback = true; end

        end
        if ((not hasfront) and (not hasback)) then
            -- all points coplanar
            local t = planenormal:clone():dot(polygon_plane:GetNormal());
            if(t >= 0)then
                result.type = 0;
            else
                result.type = 1;
            end
        elseif (not hasback) then
            result.type = 2;
        elseif (not hasfront) then
            result.type = 3;
        else
            -- spanning
            result.type = 4;
            local frontvertices = {};
            local backvertices = {};
            local isback = vertexIsBack[1];
            local vertexindex;
            for vertexindex = 1,numvertices do
                local vertex = vertices[vertexindex];
                local nextvertexindex = vertexindex + 1;
                if (nextvertexindex >= numvertices) then nextvertexindex = 1; end
                local nextisback = vertexIsBack[nextvertexindex];
                if (isback == nextisback) then
                    -- line segment is on one side of the plane:
                    if (isback == "true") then
                        table.insert(backvertices,vertex);
                    else
                        table.insert(frontvertices,vertex);
                    end
                else
                    -- line segment intersects plane:
                    local point = vertex.pos;
                    local nextpoint = vertices[nextvertexindex].pos;
                    local intersectionpoint = CSGPolygonTreeNode.splitLineBetweenPoints(this_plane, point, nextpoint);
                    local intersectionvertex = CSGVertex:new():init(intersectionpoint);
                    if (isback) then
                        table.insert(backvertices,vertex);
                        table.insert(backvertices,intersectionvertex);
                        table.insert(frontvertices,intersectionvertex);
                    else
                        table.insert(frontvertices,vertex);
                        table.insert(frontvertices,intersectionvertex);
                        table.insert(backvertices,intersectionvertex);
                    end
                end
                isback = nextisback;
            end -- for vertexindex
            -- remove duplicate vertices:
            local EPS_SQUARED = CSG.EPSILON * CSG.EPSILON;
            if (#backvertices >= 3) then
                local prevvertex = backvertices[#backvertices - 1];
                for vertexindex = 1, #backvertices do
                    local vertex = backvertices[vertexindex];
                    if (vertex and vertex.pos:dist2(prevvertex.pos) < EPS_SQUARED) then
                        tableext.splice(backvertices,vertexindex, 1);
                        vertexindex = vertexindex - 1;
                    end
                    prevvertex = vertex;
                end
            end
       
            if (#frontvertices >= 3) then
                local prevvertex = frontvertices[#frontvertices - 1];
                for vertexindex = 1, #frontvertices do
                    local vertex = frontvertices[vertexindex];
                    if (vertex and vertex.pos:dist2(prevvertex.pos) < EPS_SQUARED) then
                        tableext.splice(frontvertices,vertexindex, 1);
                        vertexindex = vertexindex - 1;
                    end
                    prevvertex = vertex;
                end
            end
            if (#frontvertices >= 3) then
                result.front = CSGPolygon:new():init(frontvertices, polygon.shared, polygon_plane);
            end
            if (#backvertices >= 3) then
                result.back = CSGPolygon:new():init(backvertices, polygon.shared, polygon_plane);
            end
        end
    end
    return result;
end
function CSGPolygonTreeNode.splitLineBetweenPoints(plane,p1,p2)
    local direction = p2 - p1;
    local w = plane[4];
    local normal = plane:GetNormal();
    local labda = (w - normal:clone():dot(p1)) / normal:clone():dot(direction);
    if (not labda) then labda = 0; end
    if (labda > 1) then labda = 1; end
    if (labda < 0) then labda = 0; end
    local result = p1 + (direction:MulByFloat(labda));
    return result;

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

function CSGPolygonTreeNode:recursivelyInvalidatePolygon()
    local node = self;
    while (node.polygon) do
        node.polygon = nil;
        if (node.parent) then
            node = node.parent;
        end
    end
end
