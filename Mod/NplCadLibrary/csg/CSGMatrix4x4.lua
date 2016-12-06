--[[
Title: CSGMatrix4x4
Author(s): Skeleton
Date: 2016/12/1
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGMatrix4x4.lua");
local CSGMatrix4x4 = commonlib.gettable("Mod.NplCadLibrary.csg.CSGMatrix4x4");
-------------------------------------------------------
]]      

NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");

local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");

local CSGMatrix4x4 = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGMatrix4x4"));

----------
-- # class Matrix4x4:
function CSGMatrix4x4:ctor()
    -- self.elements
end

-- Represents a 4x4 matrix. Elements are specified in row order
function CSGMatrix4x4:init(elements)
    if (arguments.length >= 1) then
        self.elements = elements;
    else
        -- if no arguments passed: create unity matrix
        self.elements = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    end
end

function CSGMatrix4x4:plus(m)
    local r = {};
	local i ;
    for i = 1,16,1 do
        r[i] = self.elements[i] + m.elements[i];
    end
    return CSGMatrix4x4:new():init(r);
end

function CSGMatrix4x4:minus(m)
    local r = {};
    for i = 1,16,1 do
        r[i] = self.elements[i] - m.elements[i];
    end
    return CSGMatrix4x4:new():init(r);
end

-- right multiply by another 4x4 matrix:
function CSGMatrix4x4:multiply(m)
    -- cache elements in local variables, for speedup:
    local this0 = self.elements[1];
    local this1 = self.elements[2];
    local this2 = self.elements[3];
    local this3 = self.elements[4];
    local this4 = self.elements[5];
    local this5 = self.elements[6];
    local this6 = self.elements[7];
    local this7 = self.elements[8];
    local this8 = self.elements[9];
    local this9 = self.elements[10];
    local this10 = self.elements[11];
    local this11 = self.elements[12];
    local this12 = self.elements[13];
    local this13 = self.elements[14];
    local this14 = self.elements[15];
    local this15 = self.elements[16];
    local m0 = m.elements[1];
    local m1 = m.elements[2];
    local m2 = m.elements[3];
    local m3 = m.elements[4];
    local m4 = m.elements[5];
    local m5 = m.elements[6];
    local m6 = m.elements[7];
    local m7 = m.elements[8];
    local m8 = m.elements[9];
    local m9 = m.elements[10];
    local m10 = m.elements[11];
    local m11 = m.elements[12];
    local m12 = m.elements[13];
    local m13 = m.elements[14];
    local m14 = m.elements[15];
    local m15 = m.elements[16];

    local result = {};
    result[0] = this0 * m0 + this1 * m4 + this2 * m8 + this3 * m12;
    result[1] = this0 * m1 + this1 * m5 + this2 * m9 + this3 * m13;
    result[2] = this0 * m2 + this1 * m6 + this2 * m10 + this3 * m14;
    result[3] = this0 * m3 + this1 * m7 + this2 * m11 + this3 * m15;
    result[4] = this4 * m0 + this5 * m4 + this6 * m8 + this7 * m12;
    result[5] = this4 * m1 + this5 * m5 + this6 * m9 + this7 * m13;
    result[6] = this4 * m2 + this5 * m6 + this6 * m10 + this7 * m14;
    result[7] = this4 * m3 + this5 * m7 + this6 * m11 + this7 * m15;
    result[8] = this8 * m0 + this9 * m4 + this10 * m8 + this11 * m12;
    result[9] = this8 * m1 + this9 * m5 + this10 * m9 + this11 * m13;
    result[10] = this8 * m2 + this9 * m6 + this10 * m10 + this11 * m14;
    result[11] = this8 * m3 + this9 * m7 + this10 * m11 + this11 * m15;
    result[12] = this12 * m0 + this13 * m4 + this14 * m8 + this15 * m12;
    result[13] = this12 * m1 + this13 * m5 + this14 * m9 + this15 * m13;
    result[14] = this12 * m2 + this13 * m6 + this14 * m10 + this15 * m14;
    result[15] = this12 * m3 + this13 * m7 + this14 * m11 + this15 * m15;
    return CSGMatrix4x4:new():init(result);
end

function CSGMatrix4x4:clone()
    local elements = tableext.slice(self.elements);
    return CSGMatrix4x4:new():init(elements);
end

-- Right multiply the matrix by a CSG.Vector3D (interpreted as 3 row, 1 column)
-- (result = M*v)
-- Fourth element is taken as 1
function CSGMatrix4x4:rightMultiply1x3Vector(v)
    local v0 = v._x;
    local v1 = v._y;
    local v2 = v._z;
    local v3 = 1;
    local x = v0 * self.elements[1] + v1 * self.elements[2] + v2 * self.elements[3] + v3 * self.elements[4];
    local y = v0 * self.elements[5] + v1 * self.elements[6] + v2 * self.elements[7] + v3 * self.elements[8];
    local z = v0 * self.elements[9] + v1 * self.elements[10] + v2 * self.elements[11] + v3 * self.elements[12];
    local w = v0 * self.elements[13] + v1 * self.elements[14] + v2 * self.elements[15] + v3 * self.elements[16];
    -- scale such that fourth element becomes 1:
    if (w ~= 1) then
        local invw = 1.0 / w;
        x = x * invw;
        y = y * invw;
        z = z * invw;
    end
    return CSGVector:new():init(x, y, z);
end

-- Multiply a CSG.Vector3D (interpreted as 3 column, 1 row) by self matrix
-- (result = v*M)
-- Fourth element is taken as 1
function CSGMatrix4x4:leftMultiply1x3Vector(v)
    local v0 = v._x;
    local v1 = v._y;
    local v2 = v._z;
    local v3 = 1;
    local x = v0 * self.elements[1] + v1 * self.elements[5] + v2 * self.elements[9] + v3 * self.elements[13];
    local y = v0 * self.elements[2] + v1 * self.elements[6] + v2 * self.elements[10] + v3 * self.elements[14];
    local z = v0 * self.elements[3] + v1 * self.elements[7] + v2 * self.elements[11] + v3 * self.elements[15];
    local w = v0 * self.elements[4] + v1 * self.elements[8] + v2 * self.elements[12] + v3 * self.elements[16];
    -- scale such that fourth element becomes 1:
    if (w ~= 1) then
        local invw = 1.0 / w;
        x = x * invw;
        y = y * invw;
        z = z * invw;
    end
    return CSGVector:new():init(x, y, z);
end

-- Right multiply the matrix by a CSG.Vector2D (interpreted as 2 row, 1 column)
-- (result = M*v)
-- Fourth element is taken as 1
function CSGMatrix4x4:rightMultiply1x2Vector(v)
    local v0 = v.x;
    local v1 = v.y;
    local v2 = 0;
    local v3 = 1;
    local x = v0 * self.elements[1] + v1 * self.elements[2] + v2 * self.elements[3] + v3 * self.elements[4];
    local y = v0 * self.elements[5] + v1 * self.elements[6] + v2 * self.elements[7] + v3 * self.elements[8];
    local z = v0 * self.elements[9] + v1 * self.elements[10] + v2 * self.elements[11] + v3 * self.elements[12];
    local w = v0 * self.elements[13] + v1 * self.elements[14] + v2 * self.elements[15] + v3 * self.elements[16];
    -- scale such that fourth element becomes 1:
    if (w ~= 1) then
        local invw = 1.0 / w;
        x = x * invw;
        y = y * invw;
        z = z * invw;
    end
    return CSGVector2D:new():init(x, y);
end

-- Multiply a CSG.Vector2D (interpreted as 2 column, 1 row) by self matrix
-- (result = v*M)
-- Fourth element is taken as 1
function CSGMatrix4x4:leftMultiply1x2Vector(v)
    local v0 = v.x;
    local v1 = v.y;
    local v2 = 0;
    local v3 = 1;
    local x = v0 * self.elements[1] + v1 * self.elements[5] + v2 * self.elements[9] + v3 * self.elements[13];
    local y = v0 * self.elements[2] + v1 * self.elements[6] + v2 * self.elements[10] + v3 * self.elements[14];
    local z = v0 * self.elements[3] + v1 * self.elements[7] + v2 * self.elements[11] + v3 * self.elements[15];
    local w = v0 * self.elements[4] + v1 * self.elements[8] + v2 * self.elements[12] + v3 * self.elements[16];
    -- scale such that fourth element becomes 1:
    if (w ~= 1) then
        local invw = 1.0 / w;
        x = x * invw;
        y = y * invw;
        z = z * invw;
    end
    return CSGVector2D:new():init(x, y);
end

-- determine whether self matrix is a mirroring transformation
function CSGMatrix4x4:isMirroring()
    local u = CSGVector:new():init(self.elements[1], self.elements[5], self.elements[9]);
    local v = CSGVector:new():init(self.elements[2], self.elements[6], self.elements[10]);
    local w = CSGVector:new():init(self.elements[3], self.elements[7], self.elements[11]);

    -- for a true orthogonal, non-mirrored base, u.cross(v) == w
    -- If they have an opposite direction then we are mirroring
    local mirrorvalue = u.cross(v).dot(w);
    local ismirror = (mirrorvalue < 0);
    return ismirror;
end

-- return the unity matrix
function CSGMatrix4x4.unity()
    return CSGMatrix4x4:new():init();
end

-- Create a rotation matrix for rotating around the x axis
function CSGMatrix4x4.rotationX(degrees)
    local radians = degrees * mathext.pi * (1.0 / 180.0);
    local cos = math.cos(radians);
    local sin = math.sin(radians);
    local els = {
        1, 0, 0, 0, 0, cos, sin, 0, 0, -sin, cos, 0, 0, 0, 0, 1
    };
    return CSGMatrix4x4:new():init(els);
end

-- Create a rotation matrix for rotating around the y axis
function CSGMatrix4x4.rotationY(degrees)
    local radians = degrees * mathext.pi * (1.0 / 180.0);
    local cos = math.cos(radians);
    local sin = math.sin(radians);
    local els = {
        cos, 0, -sin, 0, 0, 1, 0, 0, sin, 0, cos, 0, 0, 0, 0, 1
    };
    return CSGMatrix4x4:new():init(els);
end

-- Create a rotation matrix for rotating around the z axis
function CSGMatrix4x4.rotationZ(degrees)
    local radians = degrees * mathext.pi * (1.0 / 180.0);
    local cos = math.cos(radians);
    local sin = math.sin(radians);
    local els = {
        cos, sin, 0, 0, -sin, cos, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1
    };
    return CSGMatrix4x4:new():init(els);
end

-- Matrix for rotation about arbitrary point and axis
function CSGMatrix4x4.rotation(rotationCenter, rotationAxis, degrees)
    rotationCenter = CSGVector:new():init(rotationCenter);
    rotationAxis = CSGVector:new():init(rotationAxis);
    local rotationPlane = CSG.Plane.fromNormalAndPoint(rotationAxis, rotationCenter);
    local orthobasis = new CSG.OrthoNormalBasis(rotationPlane);
    local transformation = CSGMatrix4x4.translation(rotationCenter.negated());
    transformation = transformation.multiply(orthobasis.getProjectionMatrix());
    transformation = transformation.multiply(CSGMatrix4x4.rotationZ(degrees));
    transformation = transformation.multiply(orthobasis.getInverseProjectionMatrix());
    transformation = transformation.multiply(CSGMatrix4x4.translation(rotationCenter));
    return transformation;
end

-- Create an affine matrix for translation:
function CSGMatrix4x4.translation(v)
    -- parse as CSG.Vector3D, so we can pass an array or a CSG.Vector3D
    local vec = CSGVector:new():init(v);
    local els = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, vec.x, vec.y, vec.z, 1};
    return CSGMatrix4x4:new():init(els);
end

-- Create an affine matrix for mirroring into an arbitrary plane:
function CSGMatrix4x4.mirroring(plane)
    local nx = plane.normal.x;
    local ny = plane.normal.y;
    local nz = plane.normal.z;
    local w = plane.w;
    local els = {
        (1.0 - 2.0 * nx * nx), (-2.0 * ny * nx), (-2.0 * nz * nx), 0,
        (-2.0 * nx * ny), (1.0 - 2.0 * ny * ny), (-2.0 * nz * ny), 0,
        (-2.0 * nx * nz), (-2.0 * ny * nz), (1.0 - 2.0 * nz * nz), 0,
        (2.0 * nx * w), (2.0 * ny * w), (2.0 * nz * w), 1
    };
    return CSGMatrix4x4:new():init(els);
end

-- Create an affine matrix for scaling:
function CSGMatrix4x4.scaling(v)
    -- parse as CSG.Vector3D, so we can pass an array or a CSG.Vector3D
    local vec = CSGVector:new():init(v);
    local els = {
        vec.x, 0, 0, 0, 0, vec.y, 0, 0, 0, 0, vec.z, 0, 0, 0, 0, 1
    };
    return CSGMatrix4x4:new():init(els);
end