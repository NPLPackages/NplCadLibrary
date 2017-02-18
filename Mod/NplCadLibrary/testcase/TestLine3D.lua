NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine3D.lua");

local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestLine3D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestLine3D"));

function TestLine3D.test_Init()
	local pos =  TestFrame.randomVector3d();
	local normal = TestFrame.randomVector3d();
	local line3d = CSGLine3D:new():init(pos,normal);
	assert(line3d.point:equals(pos,tonumber("1e-5")) and line3d.direction:equals(normal:normalize(),tonumber("1e-5")));
end

function TestLine3D.test_Clone()
	local pos =  TestFrame.randomVector3d();
	local normal = TestFrame.randomVector3d();
	local line3d = CSGLine3D:new():init(pos,normal);
	local line3d2 = line3d:clone();
	--[[echo(line3d.point);
	echo(line3d2.point);
	echo(line3d.direction);
	echo(line3d2.direction);--]]
	assert(line3d.point:equals(line3d2.point,tonumber("1e-5")));
	assert(line3d.direction:equals(line3d2.direction,tonumber("1e-5")));
end
function TestLine3D.test_FromPoints()
	local p1 =  TestFrame.randomVector3d();
	local p2 =  TestFrame.randomVector3d();
	local line3d = CSGLine3D.fromPoints(p1,p2);

	local normal = p2-p1;
	normal:normalize();
	assert(p1:equals(line3d.point,tonumber("1e-5")) and line3d.direction:equals(normal,tonumber("1e-5")));		
end
function TestLine3D.test_FromPlanes()
	local p1 =  TestFrame.randomPlane();
	local p2 =  TestFrame.randomPlane();
	local line3d = CSGLine3D.fromPlanes(p1,p2);

	-- start point and end point should on these two planes
	local ohter = line3d:onePointOnLine(10);
	local d = p1:signedDistanceToPoint(line3d.point);
	--echo(d);
	assert(TestFrame.numberIsZero(d));
	d = p1:signedDistanceToPoint(ohter);
	--echo(d);
	assert(TestFrame.numberIsZero(d));
	d = p2:signedDistanceToPoint(line3d.point);
	--echo(d);
	assert(TestFrame.numberIsZero(d));
	d = p2:signedDistanceToPoint(ohter);
	--echo(d);
	assert(TestFrame.numberIsZero(d));
end
function TestLine3D.test_Reverse()
	local pos =  TestFrame.randomVector3d();
	local norm =  TestFrame.randomNormal3d();
	local line3d = CSGLine3D:new():init(pos,norm);
	line3d:reverse();
	norm:negated();
	assert(pos:equals(line3d.point,tonumber("1e-5")));
	assert(line3d.direction:equals(norm,tonumber("1e-5")));	
end
function TestLine3D.test_onePointOnLine()
	local pos =  TestFrame.randomVector3d();
	local norm =  TestFrame.randomNormal3d();
	local line3d = CSGLine3D.fromPoints(pos,norm);
	local ohter = line3d:onePointOnLine(math.random()*10);
	assert(TestFrame.numberIsZero(line3d:distanceToPoint(ohter)));	
end
function TestLine3D.test_Transform()
	local p1 =  TestFrame.randomVector3d();
	local p2 =  TestFrame.randomVector3d();
	local line3d = CSGLine3D.fromPoints(p1,p2);
	local matrix = TestFrame.randomMatrix();

	line3d:transform(matrix);
	p2:transform(matrix);
	p1:transform(matrix);
	local normal = p2 - p1;
	normal:normalize();
	assert(p1:equals(line3d.point,tonumber("1e-5")));	
	assert(normal:equals(line3d.direction,tonumber("1e-5")));		
end
function TestLine3D.test_IntersectWithPlane()
	local pos =  TestFrame.randomVector3d();
	local norm =  TestFrame.randomNormal3d();
	local line3d = CSGLine3D.fromPoints(pos,norm);
	local plane =  TestFrame.randomPlane();
	local p = line3d:intersectWithPlane(plane);
	local d = line3d:distanceToPoint(p);
	--echo(d);
	assert(TestFrame.numberIsZero(d));
	d = plane:signedDistanceToPoint(p);
	--echo(d);
	assert(TestFrame.numberIsZero(d));
end
function TestLine3D.test_closestPointOnLine()
	local pos =  TestFrame.randomVector3d();
	local norm =  TestFrame.randomNormal3d();
	local line3d = CSGLine3D.fromPoints(pos,norm);

	local point =  TestFrame.randomVector3d();
	local p = line3d:closestPointOnLine(point);
	local vector = point - p;
	assert(TestFrame.numberIsZero(line3d:distanceToPoint(p)));	
	local angle = vector:angleAbsolute(line3d.direction);	
	assert(TestFrame.numberIsZero(math.cos(angle)));
end

function TestLine3D.test_Equals()
	local pos =  TestFrame.randomVector3d();
	local norm =  TestFrame.randomNormal3d();
	local line3d = CSGLine3D.fromPoints(pos,norm);

	local line3d2 =  line3d:clone();
	assert(line3d:equals(line3d2,tonumber("1e-5")));
end

function TestLine3D.test_DistanceToPoint()
	local pos =  TestFrame.randomVector3d();
	local norm =  TestFrame.randomNormal3d();
	local line3d = CSGLine3D.fromPoints(pos,norm);

	local point =  TestFrame.randomVector3d();
	local distance = line3d:distanceToPoint(point);	

	local p = line3d:closestPointOnLine(point);
	local vector = point - p;
	vector:length()
	assert(assert(TestFrame.numberEquals(vector:length(),distance)));
end
