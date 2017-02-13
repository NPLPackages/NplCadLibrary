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
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");

NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/vector2d.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine3D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine2D.lua");

local vector3d = commonlib.gettable("mathlib.vector3d");
local vector2d = commonlib.gettable("mathlib.vector2d");
local Plane = commonlib.gettable("mathlib.Plane");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");

local CSGLine2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine2D");
local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
local CSGOrthoNormalBasis = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis"));

-- # class OrthoNormalBasis
-- Reprojects points on a 3D plane onto a 2D plane
-- or from a 2D plane back onto the 3D plane

function CSGOrthoNormalBasis:ctor()
	if(commonlib.use_object_pool) then
		self.u = self.u or vector3d:new_from_pool(0,0,0); -- right
		self.v = self.v or vector3d:new_from_pool(0,0,0);	-- forword
		self.plane = self.plane or Plane:new(); -- up & w
		self.planeorigin = self.planeorigin or vector3d:new_from_pool(0,0,0);	-- origin
	else
		self.u = self.u or vector3d:new();
		self.v = self.v or vector3d:new();
		self.plane = self.plane or Plane:new();
		self.planeorigin = self.planeorigin or vector3d:new();	
	end
end

function CSGOrthoNormalBasis:init(plane, rightvector)
    local plane_normal = plane:GetNormal();
	if (rightvector == nil) then
        -- choose an arbitrary right hand vector, making sure it is somewhat orthogonal to the plane normal:
        rightvector = plane_normal:randomPerpendicularVector();
    end
    self.v:set((plane_normal * rightvector):normalize());
    self.u:set(self.v * plane_normal);
    self.plane:set(plane);
    self.planeorigin:set(plane_normal:MulByFloat(plane[4]));
	return self;
end

function CSGOrthoNormalBasis:clone()
	return CSGOrthoNormalBasis:new():init(self.plane,self.plane:GetNormal():randomPerpendicularVector());
end

-- Get an orthonormal basis for the standard XYZ planes.
-- Parameters: the names of two 3D axes. The 2d x axis will map to the first given 3D axis, the 2d y 
-- axis will map to the second.
-- Prepend the axis with a "-" to invert the direction of self axis.
-- For example: CSGOrthoNormalBasis.GetCartesian("-Y","Z")
--   will return an orthonormal basis where the 2d X axis maps to the 3D inverted Y axis, and
--   the 2d Y axis maps to the 3D Z axis.
function CSGOrthoNormalBasis.GetCartesian(xaxisid, yaxisid)
    local axisid = xaxisid .. "/" .. yaxisid;
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
	planenormal[4] = 0; 
    return CSGOrthoNormalBasis:new():init(Plane:new(planenormal), vector3d:new(rightvector));
end


-- test code for CSGOrthoNormalBasis.GetCartesian()
function CSGOrthoNormalBasis.GetCartesian_Test()
    local axisnames={"X","Y","Z","-X","-Y","-Z"};
    local axisvectors={{1,0,0}, {0,1,0}, {0,0,1}, {-1,0,0}, {0,-1,0}, {0,0,-1}};
    local axis1;
	for	axis1=1,3,1 do
		local axis1inverted;
		for axis1inverted=1, 2, 1 do
			local axis1name=axisnames[axis1+3*(axis1inverted-1)];
			local axis1vector=axisvectors[axis1+3*(axis1inverted-1)];
			local axis2;
			for axis2=1,3,1 do
				if(axis2 ~= axis1) then
					local axis2inverted;
					for axis2inverted=1,2,1 do
						local axis2name=axisnames[axis2+3*(axis1inverted-1)];
						local axis2vector=axisvectors[axis2+3*(axis1inverted-1)];
						local orthobasis=CSGOrthoNormalBasis.GetCartesian(axis1name, axis2name);
						local test1=orthobasis:to3D(vector2d.unit_x);
						local test2=orthobasis:to3D(vector2d.unit_z);
						local expected1=vector3d:new(axis1vector);
						local expected2=vector3d:new(axis2vector);
						local d1=test1:dist(expected1);
						local d2=test2:dist(expected2);
						if( (d1 > 0.01) or (d2 > 0.01) ) then
							LOG.std(nil, "error", "CSGOrthoNormalBasis.GetCartesian_Test", "Wrong!!");
							return false;
						end
					end
				end
			end
		end
	end
	LOG.std(nil, "error", "CSGOrthoNormalBasis.GetCartesian_Test", "OK!!");
	return true;
end

-- The z=0 plane, with the 3D x and y vectors mapped to the 2D x and y vector
function CSGOrthoNormalBasis.Z0Plane()
    local plane = Plane:new():init(0,0,1,0);
    return CSGOrthoNormalBasis:new():init(plane, vector3d.unit_x);
end


function CSGOrthoNormalBasis:getProjectionMatrix()
    return Matrix4:new({
        self.u[1], self.v[1], self.plane[1], 0,
        self.u[2], self.v[2], self.plane[2], 0,
        self.u[3], self.v[3], self.plane[3], 0,
        0, 0, -self.plane[4], 1
    });
end

function CSGOrthoNormalBasis:getInverseProjectionMatrix()
    local p = self.plane:GetNormal();
	p = p:MulByFloat(self.plane[4]);
    return Matrix4:new({
        self.u[1], self.u[2], self.u[3], 0,
        self.v[1], self.v[2], self.v[3], 0,
        self.plane[1], self.plane[2], self.plane[3], 0,
        p[1], p[2], p[3], 1
    });
end

function CSGOrthoNormalBasis:to2D(vec3)
    return vector2d:new(vec3:dot(self.u), vec3:dot(self.v));
end

function CSGOrthoNormalBasis:to3D(vec2)
    return self.planeorigin + self.u * vec2[1] + self.v * vec2[2];
end

function CSGOrthoNormalBasis:line3Dto2D(line3d)
    local a2d = self:to2D(line3d.point);
    local b2d = self:to2D(line3d.point + line3d.direction);
    return CSGLine2D.fromPoints(a2d, b2d);
end

function CSGOrthoNormalBasis:line2Dto3D(line2d)
    local a3d = self:to3D(line2d:origin());
    local b3d = self:to3D(line2d:origin() + line2d:direction());
    return CSGLine3D.fromPoints(a3d, b3d);
end

function CSGOrthoNormalBasis:transform(matrix4x4)
    self.plane:transform(matrix4x4);
    self.v:transform_normal(matrix4x4):normalize();
    self.u:transform_normal(matrix4x4):normalize();
    self.planeorigin:set(self.plane:GetNormal()*self.plane[4]);
	return self;
end
