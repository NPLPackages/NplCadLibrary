NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");

local Plane = commonlib.gettable("mathlib.Plane");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestPolygon = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestPolygon"));

function TestPolygon.test_Init()
	local p1 =  TestFrame.randomVector3d();
	local p2 =  TestFrame.randomVector3d();
	local p3 =  TestFrame.randomVector3d();
	local plane = Plane.fromPoints(p1,p2,p3);
	local normal = plane:GetNormal();
	local v1 = CSGVertex:new():init(p1,normal);
	local v2 = CSGVertex:new():init(p2,normal);
	local v3 = CSGVertex:new():init(p3,normal);
	local vertices = {v1,v2,v3};

	local polygon = CSGPolygon:new():init(vertices);
	local i;
	for i=1, #vertices, 1 do
		assert(polygon.vertices[i]:equals(vertices[i]));
	end
	assert(polygon.plane:equals(plane));
	assert(polygon:getVertexCnt() == #vertices);
end

function TestPolygon.test_Clone()
	local p1 =  TestFrame.randomVector3d();
	local p2 =  TestFrame.randomVector3d();
	local p3 =  TestFrame.randomVector3d();
	local plane = Plane.fromPoints(p1,p2,p3);
	local normal = plane:GetNormal();
	local v1 = CSGVertex:new():init(p1,normal);
	local v2 = CSGVertex:new():init(p2,normal);
	local v3 = CSGVertex:new():init(p3,normal);
	local vertices = {v1,v2,v3};

	local polygon = CSGPolygon:new():init(vertices);
	local polygon2 = polygon:clone();
	for i=1, #polygon.vertices, 1 do
		assert(polygon.vertices[i]:equals(polygon2.vertices[i]));
	end
	assert(polygon.plane:equals(polygon2.plane));
	assert(#polygon.vertices == #polygon2.vertices);
	assert(polygon:getVertexCnt() == #polygon.vertices);
	assert(polygon2:getVertexCnt() == #polygon2.vertices);
end

function TestPolygon.test_GetPlane()
	local p1 =  TestFrame.randomVector3d();
	local p2 =  TestFrame.randomVector3d();
	local p3 =  TestFrame.randomVector3d();
	local plane = Plane.fromPoints(p1,p2,p3);
	local normal = plane:GetNormal();
	local v1 = CSGVertex:new():init(p1,normal);
	local v2 = CSGVertex:new():init(p2,normal);
	local v3 = CSGVertex:new():init(p3,normal);
	local vertices = {v1,v2,v3};

	local polygon = CSGPolygon:new():init(vertices);
	polygon:detach();
	local p_plane = polygon:GetPlane();
	assert(p_plane:equals(plane));
end

function TestPolygon.test_flip()
	local p1 =  TestFrame.randomVector3d();
	local p2 =  TestFrame.randomVector3d();
	local p3 =  TestFrame.randomVector3d();
	local plane = Plane.fromPoints(p1,p2,p3);
	local normal = plane:GetNormal();
	local v1 = CSGVertex:new():init(p1,normal);
	local v2 = CSGVertex:new():init(p2,normal);
	local v3 = CSGVertex:new():init(p3,normal);
	local vertices = {v1,v2,v3};

	local polygon = CSGPolygon:new():init(vertices);
	polygon:detach();
	polygon:flip();
	for i=1, #vertices, 1 do
		assert(polygon.vertices[i]:equals(vertices[i]:flip()));
	end
	assert(polygon.plane:equals(plane:inverse()));
end

function TestPolygon.test_transform()
	local p1 =  TestFrame.randomVector3d();
	local p2 =  TestFrame.randomVector3d();
	local p3 =  TestFrame.randomVector3d();
	local plane = Plane.fromPoints(p1,p2,p3);
	local normal = plane:GetNormal();
	local v1 = CSGVertex:new():init(p1,normal);
	local v2 = CSGVertex:new():init(p2,normal);
	local v3 = CSGVertex:new():init(p3,normal);
	local vertices = {v1,v2,v3};

	local polygon = CSGPolygon:new():init(vertices);
	polygon:detach();
	local matrix = TestFrame.randomMatrix();
	polygon:transform(matrix);
	for i=1, #vertices, 1 do
		assert(polygon.vertices[i]:equals(vertices[i]:transform(matrix)));
	end
	assert(polygon.plane:equals(plane:transform(matrix)));
end

-- todo
-- function TestPolygon.test_transform_mirror()