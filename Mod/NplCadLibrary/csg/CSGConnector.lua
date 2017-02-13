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
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");

NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGBSPNode.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine3D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");

local vector3d = commonlib.gettable("mathlib.vector3d");
local Plane = commonlib.gettable("mathlib.Plane");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");

local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGBSPNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGBSPNode");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");

local CSGConnector = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnector"));


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
	if(commonlib.use_object_pool) then
		self.point = self.point or vector3d:new_from_pool(0,0,0);
		self.axisvector = self.axisvector or vector3d:new_from_pool(0,0,0);
		self.normalvector = self.normalvector or vector3d:new_from_pool(0,0,0);
	else
		self.normal = self.normal or vector3d:new();
		self.axisvector = self.axisvector or vector3d:new();
		self.normalvector = self.normalvector or vector3d:new();
	end
end

function CSGConnector:init(point, axisvector, normalvector)
    self.point:set(point);
    self.axisvector:set(axisvector):normalize();
    self.normalvector:set(normalvector):normalize();
	return self;
end

function CSGConnector:clone()
	return CSGConnector:new():init(self.point,self.axisvector,self.normalvector);
end
	
function CSGConnector:normalize()
	self.axisvector:normalize();
    local n = (self.normalvector * self.axisvector):normalize();
    self.normalvector = self.axisvector * n;
    return self;
end

function CSGConnector:transform(matrix4x4)
    self.axisvector:transform_normal(matrix4x4):normalize();
    self.normalvector:transform_normal(matrix4x4):normalize();
	self.point:transform(matrix4x4);
    return self;
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
    local us = self:clone():normalize();
    other = other:clone():normalize();
    -- shift to the origin:
    local transformation = Matrix4.translation(self.point);
    -- construct the plane crossing through the origin and the two axes:
    local axesplane = Plane.anyPlaneFromVector3Ds(
        vector3d.zero, us.axisvector, other.axisvector);
    local axesbasis = CSGOrthoNormalBasis:new():init(axesplane);
    local angle1 = axesbasis:to2D(us.axisvector):angle();
    local angle2 = axesbasis:to2D(other.axisvector):angle();
    local rotation = 180.0 * (angle2 - angle1) / math.pi;
    if (mirror) then
		rotation = rotation + 180.0;
	end;
    transformation = transformation:multiply(axesbasis:getProjectionMatrix());
    transformation = transformation:multiply(Matrix4.rotationZ(rotation));
    transformation = transformation:multiply(axesbasis:getInverseProjectionMatrix());

    local usAxesAligned = us:transform(transformation);

    -- Now we have done the transformation for aligning the axes.
    -- We still need to align the normals:
    local normalsplane = Plane.fromNormalAndPoint(other.axisvector, vector3d.zero);
    local normalsbasis = CSGOrthoNormalBasis:new():init(normalsplane);

    angle1 = normalsbasis:to2D(usAxesAligned.normalvector):angle();
	angle2 = normalsbasis:to2D(other.normalvector):angle();
    rotation = 180.0 * (angle2 - angle1) / math.pi;
    rotation = rotation + normalrotation;
    transformation = transformation:multiply(normalsbasis:getProjectionMatrix());
    transformation = transformation:multiply(Matrix4.rotationZ(rotation));
    transformation = transformation:multiply(normalsbasis:getInverseProjectionMatrix());
    -- and translate to the destination point:
    transformation = transformation:multiply(Matrix4.translation(other.point));
    -- local usAligned = us:transform(transformation);
    return transformation;
end

function CSGConnector:axisLine()
    return CSGLine3D:new():init(self.point, self.axisvector);
end

-- creates a new Connector, with the connection point moved in the direction of the axisvector
function CSGConnector:extend(distance)
	distance = distance or 1;
	local newpoint = self.axisvector:clone_from_pool():normalize():MulByFloat(distance):add(self.point);
    return CSGConnector:new():init(newpoint, self.axisvector, self.normalvector);
end
