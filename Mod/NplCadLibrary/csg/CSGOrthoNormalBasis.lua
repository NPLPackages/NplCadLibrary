--[[
Title: CSGOrthoNormalBasis
Author(s): Skeleton
Date: 2016/12/1
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");
local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");
-------------------------------------------------------
]]  

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPlane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine3D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGMatrix4x4.lua");

local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");
local CSGPlane = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane");
local CSGLine2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine2D");
local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
local CSGMatrix4x4 = commonlib.gettable("Mod.NplCadLibrary.csg.CSGMatrix4x4");

local CSGOrthoNormalBasis = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis"));

-- # class OrthoNormalBasis
-- Reprojects points on a 3D plane onto a 2D plane
-- or from a 2D plane back onto the 3D plane

function CSGOrthoNormalBasis:ctor()
    -- self.v
    -- self.u
    -- self.plane
    -- self.planeorigin
end

function CSGOrthoNormalBasis:init(plane, rightvector)
    if (rightvector == nil) then
        -- choose an arbitrary right hand vector, making sure it is somewhat orthogonal to the plane normal:
        rightvector = plane.normal:randomNonParallelVector();
    else
        rightvector = CSGVector:new():init(rightvector);
    end
    self.v = plane.normal:cross(rightvector):unit();
    self.u = self.v:cross(plane.normal);
    self.plane = plane;
    self.planeorigin = plane.normal:times(plane.w);
	return self;
end

-- Get an orthonormal basis for the standard XYZ planes.
-- Parameters: the names of two 3D axes. The 2d x axis will map to the first given 3D axis, the 2d y 
-- axis will map to the second.
-- Prepend the axis with a "-" to invert the direction of self axis.
-- For example: CSGOrthoNormalBasis.GetCartesian("-Y","Z")
--   will return an orthonormal basis where the 2d X axis maps to the 3D inverted Y axis, and
--   the 2d Y axis maps to the 3D Z axis.
function CSGOrthoNormalBasis.GetCartesian(xaxisid, yaxisid)
    local axisid = xaxisid + "/" + yaxisid;
    local planenormal, rightvector;
    if (axisid == "X/Y") then
        planenormal = {0, 0, 1};
        rightvector = {1, 0, 0};
    elseif (axisid == "Y/-X") then
        planenormal = {0, 0, 1};
        rightvector = {0, 1, 0};
    elseif (axisid == "-X/-Y") then
        planenormal = {0, 0, 1};
        rightvector = {-1, 0, 0};
    elseif (axisid == "-Y/X") then
        planenormal = {0, 0, 1};
        rightvector = {0, -1, 0};
    elseif (axisid == "-X/Y") then
        planenormal = {0, 0, -1};
        rightvector = {-1, 0, 0};
    elseif (axisid == "-Y/-X") then
        planenormal = {0, 0, -1};
        rightvector = {0, -1, 0};
    elseif (axisid == "X/-Y") then
        planenormal = {0, 0, -1};
        rightvector = {1, 0, 0};
    elseif (axisid == "Y/X") then
        planenormal = {0, 0, -1};
        rightvector = {0, 1, 0};
    elseif (axisid == "X/Z") then
        planenormal = {0, -1, 0};
        rightvector = {1, 0, 0};
    elseif (axisid == "Z/-X") then
        planenormal = {0, -1, 0};
        rightvector = {0, 0, 1};
    elseif (axisid == "-X/-Z") then
        planenormal = {0, -1, 0};
        rightvector = {-1, 0, 0};
    elseif (axisid == "-Z/X") then
        planenormal = {0, -1, 0};
        rightvector = {0, 0, -1};
    elseif (axisid == "-X/Z") then
        planenormal = {0, 1, 0};
        rightvector = {-1, 0, 0};
    elseif (axisid == "-Z/-X") then
        planenormal = {0, 1, 0};
        rightvector = {0, 0, -1};
    elseif (axisid == "X/-Z") then
        planenormal = {0, 1, 0};
        rightvector = {1, 0, 0};
    elseif (axisid == "Z/X") then
        planenormal = {0, 1, 0};
        rightvector = {0, 0, 1};
    elseif (axisid == "Y/Z") then
        planenormal = {1, 0, 0};
        rightvector = {0, 1, 0};
    elseif (axisid == "Z/-Y") then
        planenormal = {1, 0, 0};
        rightvector = {0, 0, 1};
    elseif (axisid == "-Y/-Z") then
        planenormal = {1, 0, 0};
        rightvector = {0, -1, 0};
    elseif (axisid == "-Z/Y") then
        planenormal = {1, 0, 0};
        rightvector = {0, 0, -1};
    elseif (axisid == "-Y/Z") then
        planenormal = {-1, 0, 0};
        rightvector = {0, -1, 0};
    elseif (axisid == "-Z/-Y") then
        planenormal = {-1, 0, 0};
        rightvector = {0, 0, -1};
    elseif (axisid == "Y/-Z") then
        planenormal = {-1, 0, 0};
        rightvector = {0, 1, 0};
    elseif (axisid == "Z/Y") then
        planenormal = {-1, 0, 0};
        rightvector = {0, 0, 1};
    else
        --throw new Error("CSGOrthoNormalBasis.GetCartesian: invalid combination of axis identifiers. Should pass two string arguments from [X,Y,Z,-X,-Y,-Z], being two different axes.");
    end
    return CSGOrthoNormalBasis:new():init(CSGPlane:new():init(CSGVector:new():init(planenormal), 0), CSGVector:new():init(rightvector));
end

--[[
-- test code for CSGOrthoNormalBasis.GetCartesian()
CSGOrthoNormalBasis.GetCartesian_Test=function()
    local axisnames=["X","Y","Z","-X","-Y","-Z"};
    local axisvectors=[[1,0,0], [0,1,0], [0,0,1], [-1,0,0], [0,-1,0], [0,0,-1]};
    for(local axis1=0; axis1 < 3; axis1++)
    for(local axis1inverted=0; axis1inverted < 2; axis1inverted++)
        local axis1name=axisnames[axis1+3*axis1inverted};
        local axis1vector=axisvectors[axis1+3*axis1inverted};
        for(local axis2=0; axis2 < 3; axis2++)
        if(axis2 != axis1)
            for(local axis2inverted=0; axis2inverted < 2; axis2inverted++)
            local axis2name=axisnames[axis2+3*axis2inverted};
            local axis2vector=axisvectors[axis2+3*axis2inverted};
            local orthobasis=CSGOrthoNormalBasis.GetCartesian(axis1name, axis2name);
            local test1=orthobasis:to3D(CSGVector2D:new():init([1,0]));
            local test2=orthobasis:to3D(CSGVector2D:new():init([0,1]));
            local expected1=CSGVector:new():init(axis1vector);
            local expected2=CSGVector:new():init(axis2vector);
            local d1=test1.distanceTo(expected1);
            local d2=test2.distanceTo(expected2);
            if( (d1 > 0.01) || (d2 > 0.01) )
                throw new Error("Wrong!");
    }}}}}}
    throw new Error("OK");
end
--]]

-- The z=0 plane, with the 3D x and y vectors mapped to the 2D x and y vector
function CSGOrthoNormalBasis.Z0Plane()
    local plane = CSGPlane:new():init(CSGVector:new():init({0, 0, 1}), 0);
    return CSGOrthoNormalBasis:new():init(plane, CSGVector:new():init({1, 0, 0}));
end


function CSGOrthoNormalBasis:getProjectionMatrix()
    return CSGMatrix4x4:new():init({
        self.u.x, self.v.x, self.plane.normal.x, 0,
        self.u.y, self.v.y, self.plane.normal.y, 0,
        self.u.z, self.v.z, self.plane.normal.z, 0,
        0, 0, -self.plane.w, 1
    });
end

function CSGOrthoNormalBasis:getInverseProjectionMatrix()
    local p = self.plane.normal:times(self.plane.w);
    return CSGMatrix4x4:new():init({
        self.u.x, self.u.y, self.u.z, 0,
        self.v.x, self.v.y, self.v.z, 0,
        self.plane.normal.x, self.plane.normal.y, self.plane.normal.z, 0,
        p.x, p.y, p.z, 1
    });
end

function CSGOrthoNormalBasis:to2D(vec3)
    return CSGVector2D:new():init(vec3:dot(self.u), vec3:dot(self.v));
end

function CSGOrthoNormalBasis:to3D(vec2)
    return self.planeorigin:plus(self.u:times(vec2.x)):plus(self.v:times(vec2.y));
end

function CSGOrthoNormalBasis:line3Dto2D(line3d)
    local a = line3d.point;
    local b = line3d.direction:plus(a);
    local a2d = self:to2D(a);
    local b2d = self:to2D(b);
    return CSGLine2D.fromPoints(a2d, b2d);
end

function CSGOrthoNormalBasis:line2Dto3D(line2d)
    local a = line2d:origin();
    local b = line2d:direction():plus(a);
    local a3d = self:to3D(a);
    local b3d = self:to3D(b);
    return CSGLine3D.fromPoints(a3d, b3d);
end

function CSGOrthoNormalBasis:transform(matrix4x4)
    -- todo: self may not work properly in case of mirroring
    local newplane = self.plane:transform(matrix4x4);
    local rightpoint_transformed = self.u:transform(matrix4x4);
    local origin_transformed = CSGVector:new():init(0, 0, 0):transform(matrix4x4);
    local newrighthandvector = rightpoint_transformed.minus(origin_transformed);
    local newbasis = CSGOrthoNormalBasis:new():init(newplane, newrighthandvector);
    return newbasis;
end
