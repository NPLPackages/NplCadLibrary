--[[
Title: CSGTree
Author(s): leio
Date: 2017/5/23
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGTree.lua");
local CSGTree = commonlib.gettable("Mod.NplCadLibrary.csg.CSGTree");
-------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygonTreeNode.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGNode.lua");
local CSGPolygonTreeNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygonTreeNode");
local CSGNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGNode");

local CSGTree = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGTree"));

function CSGTree:ctor()
end
function CSGTree:init(polygons)
    self.polygonTree = CSGPolygonTreeNode:new();
    self.rootnode = CSGNode:new();
    if (polygons) then
        self:addPolygons(polygons);
    end
    return self;
end
function CSGTree:invert()
    self.polygonTree:invert();
    self.rootnode:invert();
end
-- Remove all polygons in this BSP tree that are inside the other BSP tree
function CSGTree:clipTo(tree, alsoRemovecoplanarFront)
    self.rootnode:clipTo(tree, alsoRemovecoplanarFront);
end
function CSGTree:allPolygons()
    local result = {};
    self.polygonTree:getPolygons(result);
    return result;
end
function CSGTree:addPolygons(polygons)
    local polygontreenodes = {};
    local p;
    for __,p in ipairs(polygons) do
        local child = self.polygonTree:addChild(p);
        table.insert(polygontreenodes,child);
    end
    self.rootnode:addPolygonTreeNodes(polygontreenodes);
end
