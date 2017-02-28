--[[
Title: CSGConnector
Author(s): Skeleton
Date: 2016/11/28
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGConnector.lua");
local CSGConnector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnector");
-------------------------------------------------------
]]   

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPlane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGBSPNode.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine3D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGMatrix4x4.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");

local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPlane = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGBSPNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGBSPNode");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");
local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
local CSGMatrix4x4 = commonlib.gettable("Mod.NplCadLibrary.csg.CSGMatrix4x4");
local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");

local CSGConnector = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnector"));


--------------------------------------
-- # class Connector
-- A connector allows to attach two objects at predefined positions
-- For example a servo motor and a servo horn:
-- Both can have a Connector called 'shaft'
-- The horn can be moved and rotated such that the two connectors match
-- and the horn is attached to the servo motor at the proper position.
-- Connectors are stored in the properties of a CSG solid so they are
-- ge the same transformations applied as the solid

function CSGConnector:ctor()
	self._class = "CSGConnector";
    --self.point;
    --self.axisvector;
	--self normalvector
end

function CSGConnector:init(point, axisvector, normalvector)
    self.point = CSGVector:new():init(point);
    self.axisvector = CSGVector:new():init(axisvector):unit();
    self.normalvector = CSGVector:new():init(normalvector):unit();
	return self;
end

	
function CSGConnector:normalized()
    local axisvector = self.axisvector:unit();
    -- make the normal vector truly normal:
    local n = self.normalvector:cross(axisvector):unit();
    local normalvector = axisvector:cross(n);
    return CSGConnector:new():init(self.point, axisvector, normalvector);
end

function CSGConnector:transform(matrix4x4)
    local point = self.point:multiply4x4(matrix4x4);
    local axisvector = self.point:plus(self.axisvector):multiply4x4(matrix4x4):minus(point);
    local normalvector = self.point:plus(self.normalvector):multiply4x4(matrix4x4):minus(point);
    return CSGConnector:new():init(point, axisvector, normalvector);
end

-- Get the transformation matrix to connect this Connector to another connector
--   other: a CSG.Connector to which this connector should be connected
--   mirror: false: the 'axis' vectors of the connectors should point in the same direction
--           true: the 'axis' vectors of the connectors should point in opposite direction
--   normalrotation: degrees of rotation between the 'normal' vectors of the two
--                   connectors
function CSGConnector:getTransformationTo(other, mirror, normalrotation)
	mirror = mirror or false;
    normalrotation = normalrotation or 0.0;
    local us = self:normalized();
    other = other:normalized();
    -- shift to the origin:
    local transformation = CSGMatrix4x4.translation(self.point:negated());
    -- construct the plane crossing through the origin and the two axes:
    local axesplane = CSGPlane.anyPlaneFromVector3Ds(
        CSGVector:new():init(0, 0, 0), us.axisvector, other.axisvector);
    local axesbasis = CSGOrthoNormalBasis:new():init(axesplane);
    local angle1 = axesbasis:to2D(us.axisvector):angle();
    local angle2 = axesbasis:to2D(other.axisvector):angle();
    local rotation = 180.0 * (angle2 - angle1) / mathext.pi;
    if (mirror) then
		rotation = rotation + 180.0;
	end;
    transformation = transformation:multiply(axesbasis:getProjectionMatrix());
    transformation = transformation:multiply(CSGMatrix4x4.rotationZ(rotation));
    transformation = transformation:multiply(axesbasis:getInverseProjectionMatrix());

    local usAxesAligned = us:transform(transformation);

    -- Now we have done the transformation for aligning the axes.
    -- We still need to align the normals:
    local normalsplane = CSGPlane.fromNormalAndPoint(other.axisvector, CSGVector:new():init(0, 0, 0));
    local normalsbasis = CSGOrthoNormalBasis:new():init(normalsplane);

    angle1 = normalsbasis:to2D(usAxesAligned.normalvector):angle();
	angle2 = normalsbasis:to2D(other.normalvector):angle();
    rotation = 180.0 * (angle2 - angle1) / mathext.pi;
    rotation = rotation + normalrotation;
    transformation = transformation:multiply(normalsbasis:getProjectionMatrix());
    transformation = transformation:multiply(CSGMatrix4x4.rotationZ(rotation));
    transformation = transformation:multiply(normalsbasis:getInverseProjectionMatrix());
    -- and translate to the destination point:
    transformation = transformation:multiply(CSGMatrix4x4.translation(other.point));
    -- local usAligned = us:transform(transformation);
    return transformation;
end

function CSGConnector:axisLine()
    return CSGLine3D:new():init(self.point, self.axisvector);
end

-- creates a new Connector, with the connection point moved in the direction of the axisvector
function CSGConnector:extend(distance)
	distance = distance or 1;
    local newpoint = self.point:plus(self.axisvector:unit():times(distance));
    return CSGConnector:new():init(newpoint, self.axisvector, self.normalvector);
end
