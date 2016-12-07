--[[
Title: CSGPolygon2D
Author(s): Skeleton
Date: 2016/11/28
Desc: 
Represents a polygon in 2D space.

    2D polygons are now supported through the CAG class.
    With many improvements (see documentation):
      - shapes do no longer have to be convex
      - union/intersect/subtract is supported
      - expand / contract are supported

    But we'll keep CSG.Polygon2D as a stub for backwards compatibility

-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine2D.lua");
local CSGPolygon2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon2D");
-------------------------------------------------------
]]  

NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSGPolygon2D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon2D"));


function CSGPolygon2D:init(points) 
    local cag = CAG.fromPoints(points);
    self.sides = cag.sides;
end