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

NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");

local Plane = commonlib.gettable("mathlib.Plane");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");

local CSGPolygon = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon"));

-- {vertices, shared, plane(optional)}
function CSGPolygon:ctor()
	self.vertices = self.vertices or {};
	self.plane = self.plane or Plane:new();
	self.shared = nil;
	tableext.clear(self.vertices);
end

function CSGPolygon:init(vertices, shared)
	vertices = vertices or {};
	--[[
	local function clone(v)
		return v:clone();
	end
	--]]
	tableext.copy(self.vertices,vertices,nil);
	self.shared = shared;
	self.plane:set(Plane.fromPoints(vertices[1].pos, vertices[2].pos, vertices[3].pos));	
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