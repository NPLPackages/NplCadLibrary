--[[
Title: CSG Node
Author(s): leio, LiXizhi, based on http://evanw.github.com/csg.js/
Date: 2016/3/29
Desc: 
A CSG node stores array of polygons, representing a solid, and exposing boolean operations. 
Internally, it uses temporary BSP node(a binary space partition tree representing a 3D solid) to perform csg operations. 
Two solids can be combined using the `union()`, `subtract()`, and `intersect()` methods.

We use copy on write policy for all CSG stuffs, like vertext, polygon, plane, bsp node, csg node, etc.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/bit.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPlane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGBSPNode.lua");

local vector3d = commonlib.gettable("mathlib.vector3d");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPlane = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGBSPNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGBSPNode");
local CSG = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSG"));
function CSG:ctor()
	self.polygons = {};
end

--Construct a CSG solid from an array of Polygons
function CSG.fromPolygons(polygons)
	local csg = CSG:new();
	csg.polygons = polygons;
	return csg;
end

-- compute total number of vertices
function CSG:getVertexCnt()
	local cnt = 0;
	for k,p in ipairs(self.polygons) do
		cnt  = cnt  + p:getVertexCnt();
	end
	return cnt;
end

-- performs a deep copy of all its internal data. 
-- used whenever data is about to be modified for implicit copy-on-write object.
function CSG:detach()
	local result = {};
	for k,p in ipairs(self.polygons) do
		result[#result+1] = p:clone();
	end
	self.polygons = result;
	return self;
end

-- clone csg node and polygons
-- @param bDeepCopy: if true, we will perform deep copy, otherwise it is a shallow copy on write clone
function CSG:clone(bDeepCopy)
	local o = CSG.fromPolygons(self.polygons);
	if(bDeepCopy) then
		-- almost never called
		o:detach();
	end
	return o;
end

function CSG:GetPolygons()
	return self.polygons;
end

function CSG:GetPolygonCount()
	return self.polygons and #(self.polygons) or 0;
end

-- Return a new CSG solid representing space in either this solid or in the
-- solid `csg`. Neither this solid nor the solid `csg` are modified.
-- 
--     A.union(B)
-- 
--     +-------+            +-------+
--     |       |            |       |
--     |   A   |            |       |
--     |    +--+----+   =   |       +----+
--     +----+--+    |       +----+       |
--          |   B   |            |       |
--          |       |            |       |
--          +-------+            +-------+
-- 
function CSG:union(csg)
	LOG.std(nil, "info", "CSG:union", "==============");
	LOG.std(nil, "info", "CSG:union", "vertex length of self:%d,csg:%d", self:getVertexCnt(), csg:getVertexCnt());
	local aa = self:clone();
	local bb = csg:clone();
	LOG.std(nil, "info", "CSG:union", "vertex length of aa:%d,bb:%d", aa:getVertexCnt(), bb:getVertexCnt());
	local a = CSGBSPNode:new():init(aa.polygons);
	local b = CSGBSPNode:new():init(bb.polygons);
	LOG.std(nil, "info", "CSG:union", "vertex length of a:%d,b:%d", a:getVertexCnt(), b:getVertexCnt());
	a:clipTo(b);
	b:clipTo(a);
    b:invert();
    b:clipTo(a);
    b:invert();
    a:build(b:allPolygons());
	return CSG.fromPolygons(a:allPolygons());
end
-- Return a new CSG solid representing space in this solid but not in the
-- solid `csg`. Neither this solid nor the solid `csg` are modified.
-- 
--     A.subtract(B)
-- 
--     +-------+            +-------+
--     |       |            |       |
--     |   A   |            |       |
--     |    +--+----+   =   |    +--+
--     +----+--+    |       +----+
--          |   B   |
--          |       |
--          +-------+
-- 
function CSG:subtract(csg)
	LOG.std(nil, "info", "CSG:subtract", "==============");
	LOG.std(nil, "info", "CSG:subtract", "vertex length of self:%d,csg:%d", self:getVertexCnt(), csg:getVertexCnt());
	local aa = self:clone();
	local bb = csg:clone();
	LOG.std(nil, "info", "CSG:subtract", "vertex length of aa:%d,bb:%d", aa:getVertexCnt(), bb:getVertexCnt());
	local a = CSGBSPNode:new():init(aa.polygons);
	local b = CSGBSPNode:new():init(bb.polygons);
	LOG.std(nil, "info", "CSG:subtract", "vertex length of a:%d,b:%d", a:getVertexCnt(), b:getVertexCnt());
	a:invert();
    a:clipTo(b);
    b:clipTo(a);
    b:invert();
    b:clipTo(a);
    b:invert();
    a:build(b:allPolygons());
    a:invert();
    return CSG.fromPolygons(a:allPolygons());
end
-- Return a new CSG solid representing space both this solid and in the
-- solid `csg`. Neither this solid nor the solid `csg` are modified.
-- 
--     A.intersect(B)
-- 
--     +-------+
--     |       |
--     |   A   |
--     |    +--+----+   =   +--+
--     +----+--+    |       +--+
--          |   B   |
--          |       |
--          +-------+
-- 
function CSG:intersect(csg)
	LOG.std(nil, "info", "CSG:intersect", "==============");
	LOG.std(nil, "info", "CSG:intersect", "vertex length of self:%d,csg:%d", self:getVertexCnt(), csg:getVertexCnt());
	local aa = self:clone();
	local bb = csg:clone();
	LOG.std(nil, "info", "CSG:intersect", "vertex length of aa:%d,bb:%d", aa:getVertexCnt(), bb:getVertexCnt());
	local a = CSGBSPNode:new():init(aa.polygons);
	local b = CSGBSPNode:new():init(bb.polygons);
	LOG.std(nil, "info", "CSG:intersect", "vertex length of a:%d,b:%d", a:getVertexCnt(), b:getVertexCnt());
	a:invert();
    b:clipTo(a);
    b:invert();
    a:clipTo(b);
    b:clipTo(a);
    a:build(b:allPolygons());
    a:invert();
    return CSG.fromPolygons(a:allPolygons());
end


--Return a new CSG solid with solid and empty space switched. This solid is not modified.
function CSG:inverse()
	local csg = self:clone(true);
	for k,p in ipairs(self.polygons) do
		p:flip();
	end
	return csg;
end

function CSG.toMesh(csg,r,g,b)
	if(not csg)then return end
	local vertices = {};
	local indices = {};
	local normals = {};
	local colors = {};
	for __,polygon in ipairs(csg.polygons) do
		local start_index = #vertices+1;
		for __,vertex in ipairs(polygon.vertices) do
			table.insert(vertices,{vertex.pos[1],vertex.pos[2],vertex.pos[3]});
			table.insert(normals,{vertex.normal[1],vertex.normal[2],vertex.normal[3]});
			table.insert(colors,{r,g,b});
		end
		local size = #(polygon.vertices) - 1;
		for i = 2,size do
			table.insert(indices,start_index);
			table.insert(indices,start_index + i-1);
			table.insert(indices,start_index + i);
		end
	end
	return vertices,indices,normals,colors;
end
function CSG.saveAsSTL(csg,output_file_name)
	if(not csg)then return end
	ParaIO.CreateDirectory(output_file_name);
	local function write_face(file,vertex_1,vertex_2,vertex_3)
		local a = vertex_3 - vertex_1;
		local b = vertex_3 - vertex_2;
		local normal = a*b;
		normal:normalize();
		if(isYUp) then
			file:WriteString(string.format(" facet normal %f %f %f\n", normal[1], normal[2], normal[3]));
			file:WriteString(string.format("  outer loop\n"));
			file:WriteString(string.format("  vertex %f %f %f\n", vertex_1[1], vertex_1[2], vertex_1[3]));
			file:WriteString(string.format("  vertex %f %f %f\n", vertex_2[1], vertex_2[2], vertex_2[3]));
			file:WriteString(string.format("  vertex %f %f %f\n", vertex_3[1], vertex_3[2], vertex_3[3]));
		else
			-- invert y,z and change the triangle winding
			file:WriteString(string.format(" facet normal %f %f %f\n", normal[1], normal[3], normal[2]));
			file:WriteString(string.format("  outer loop\n"));
			file:WriteString(string.format("  vertex %f %f %f\n", vertex_1[1], vertex_1[3], vertex_1[2]));
			file:WriteString(string.format("  vertex %f %f %f\n", vertex_3[1], vertex_3[3], vertex_3[2]));
			file:WriteString(string.format("  vertex %f %f %f\n", vertex_2[1], vertex_2[3], vertex_2[2]));
		end
		file:WriteString(string.format("  endloop\n"));
		file:WriteString(string.format(" endfacet\n"));
	end
	local file = ParaIO.open(output_file_name, "w");
	if(file:IsValid()) then
		local name = "ParaEngine";
		file:WriteString(string.format("solid %s\n",name));

		local vertices,indices,normals,colors = CSG.toMesh(csg);
		local size = #indices;
		local k;
		for k = 1,size do
			local t = math.mod(k,3);
			if(t == 0)then
				local v1 = vertices[indices[k-2]];    
				local v2 = vertices[indices[k-1]];  
				local v3 = vertices[indices[k]];  
				if(v1 and v2 and v3)then
					write_face(file,vector3d:new(v1[1],v1[2],v1[3]),vector3d:new(v2[1],v2[2],v2[3]),vector3d:new(v3[1],v3[2],v3[3]));
				end
			end
		end
		file:WriteString(string.format("endsolid %s\n",name));
		file:close();
		return true;
	end
end