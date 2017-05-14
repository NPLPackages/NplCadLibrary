--[[
Title: CSGPolygon
Author(s): leio, LiXizhi
Date: 2016/3/29
Desc: 
Represents a convex polygon. The vertices used to initialize a polygon must
be coplanar and form a convex loop. They do not have to be `CSG.Vertex`
instances but they must behave similarly (duck typing can be used for
customization).
 
Each convex polygon has a `shared` property, which is shared between all
polygons that are clones of each other or were split from the same polygon.
This can be used to define per-polygon properties (such as surface color).

Uses Copy On Write policy
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
-------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
local Plane = commonlib.gettable("mathlib.Plane");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");

local CSGPolygon = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon"));

-- {vertices, shared, plane(optional)}
function CSGPolygon:ctor()
	self.vertices = self.vertices or {};
	self.plane = self.plane or Plane:new();
	self.shared = nil;
	tableext.clear(self.vertices);
end

function CSGPolygon:init(vertices, shared, plane)
	vertices = vertices or {};
	local function clone(v)
		return v:clone();
	end
	tableext.copy_fn(self.vertices,vertices,clone);
	self.shared = shared;
	
	if(plane == nil) then 
		self.plane:set(Plane.fromPoints(vertices[1].pos, vertices[2].pos, vertices[3].pos));
	else
		self.plane:set(	plane);
	end
	return self;
end

-- get plane and create it if not exist. 
function CSGPolygon:GetPlane()
	if(not self.plane) then
		local vertices = self.vertices;
		self.plane:set(Plane.fromPoints(vertices[1].pos, vertices[2].pos, vertices[3].pos));	
	end
	return self.plane;
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CSGPolygon:detach()
	for i = #self.vertices, 1, -1 do
		self.vertices[i] = self.vertices[i]:clone();
	end
	return self;
end

function CSGPolygon:clone()
	return CSGPolygon:new():init(self.vertices,self.shared,self.plane);
end

function CSGPolygon:flip()
	self.vertices = tableext.reverse(self.vertices, CSGVertex.flip);
	if(self.plane) then
		self.plane:inverse();
	end
	return self;
end

function CSGPolygon:getVertexCnt()
	if(self.vertices)then
		return #self.vertices;
	end
	return 0;
end

-- Affine transformation of polygon. Returns a new CSG.Polygon
function CSGPolygon:transform(matrix4x4) 
	for k,v in ipairs(self.vertices) do 
        v:transform(matrix4x4);
    end
	self:GetPlane():transform(matrix4x4);
    if (matrix4x4:isMirroring()) then
		self.vertices = tableext.reverse(self.vertices);
    end
    return self;
end
function CSGPolygon:translate(offset)
    return self:transform(Matrix4.translation(offset));
end
-- Extrude a polygon into the direction offsetvector
-- Returns a CSG object
function CSGPolygon:extrude(offsetvector)
    local newpolygons = {};

    local polygon1 = self:clone();
    local direction = polygon1.plane:GetNormal():dot(offsetvector);
    if (direction > 0) then
        polygon1 = polygon1:flip();
    end
    table.insert(newpolygons,polygon1);
    local polygon2 = polygon1:clone();
    polygon2:translate(offsetvector);
    local numvertices = self:getVertexCnt();
    for i = 1, numvertices do
        local sidefacepoints = {};
        local nexti = 1;
        if(i < numvertices)then
            nexti = i + 1;
        end
        table.insert(sidefacepoints,polygon1.vertices[i].pos);
        table.insert(sidefacepoints,polygon2.vertices[i].pos);
        table.insert(sidefacepoints,polygon2.vertices[nexti].pos);
        table.insert(sidefacepoints,polygon1.vertices[nexti].pos);
        local sidefacepolygon = CSGPolygon.createFromPoints(sidefacepoints, self.shared);
        table.insert(newpolygons,sidefacepolygon);
    end
    polygon2 = polygon2:flip();
    table.insert(newpolygons,polygon2);
    return CSG.fromPolygons(newpolygons);
end
-- project the 3D polygon onto a plane
function CSGPolygon:projectToOrthoNormalBasis(orthobasis)
    local points2d = {};
	for k,vertex in ipairs(self.vertices) do 
        table.insert(points2d,orthobasis:to2D(vertex.pos));
    end

    local result = CAG.fromPointsNoCheck(points2d);
    local area = result:area();
    local EPS = tonumber("1e-5");
    if (math.abs(area) < EPS) then
        -- the polygon was perpendicular to the orthnormal plane. The resulting 2D polygon would be degenerate
        -- return an empty area instead:
        result = CAG:new();
    elseif (area < 0) then
        result = result:flipped();
    end
    return result;
end
-- Create a polygon from the given points
function CSGPolygon.createFromPoints(points, shared, plane)
    local normal;
    if(not plane)then
        normal = vector3d:new(0,0,0);
    else
        normal = plane:GetNormal();
    end
    
    local vertices = {};
    for k,p in ipairs(points) do
        local vec = vector3d:new(p);
        local vertex = CSGVertex:new():init(vec,normal);
        table.insert(vertices,vertex);
    end
    local polygon = CSGPolygon:new():init(vertices, shared, plane);
    return polygon;
end