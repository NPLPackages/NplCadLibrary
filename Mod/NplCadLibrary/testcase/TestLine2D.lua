NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine2D.lua");
NPL.load("(gl)script/ide/math/vector2d.lua");

local vector2d = commonlib.gettable("mathlib.vector2d");
local CSGLine2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine2D");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestLine2D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestLine2D"));

function TestLine2D.test_Init()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);
	assert(line2d.normal:equals(normal,tonumber("1e-5")));
	assert(TestFrame.numberEquals(line2d.w,w));
end

function TestLine2D.test_Clone()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);
	local line2d2 = line2d:clone();
	assert(line2d.normal:equals(line2d2.normal,tonumber("1e-5")));
	assert(TestFrame.numberEquals(line2d.w,line2d2.w));
end
function TestLine2D.test_FromPoints()
	local p1 =  TestFrame.randomVector2d();
	local p2 =  TestFrame.randomVector2d();
	local line2d = CSGLine2D.fromPoints(p1,p2);

    local direction = p2 - p1;
    local normal = direction:normal():negated():normalize();
    local w = p1:dot(normal);
	assert(normal:equals(line2d.normal,tonumber("1e-5")));
	assert(TestFrame.numberEquals(line2d.w,w));
end
function TestLine2D.test_Reverse()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);
	line2d:reverse();
	normal:negated();
	assert(line2d.normal:equals(normal,tonumber("1e-5")));
	assert(TestFrame.numberEquals(line2d.w,-w));	
end
function TestLine2D.test_equals()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);
	local line2d2 = line2d:clone();
	assert(line2d:equals(line2d2,tonumber("1e-5")));
end

function TestLine2D.test_origin()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);
	local origin = line2d:origin();
	assert(origin:equals(normal * w,tonumber("1e-5")));
end
function TestLine2D.test_direction()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);
	local direction = line2d:direction();
	assert(direction:equals(normal:normalize():normal(),tonumber("1e-5")));
end
function TestLine2D.test_xAtY()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);
	local y = math.random()*100;
	local x = line2d:xAtY(y);
	local point = vector2d:new(x,y);
	local d = line2d:absDistanceToPoint(point);
	assert(TestFrame.numberIsZero(d));
end
function TestLine2D.test_intersectWithLine()
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);

	local p1 =  TestFrame.randomVector2d();
	local p2 =  TestFrame.randomVector2d();
	local line2d2 = CSGLine2D.fromPoints(p1,p2);

	local ip = line2d:intersectWithLine(line2d2);
	local d1 = line2d:absDistanceToPoint(ip);
	local d2 = line2d2:absDistanceToPoint(ip);
	assert(TestFrame.numberIsZero(d1));
	assert(TestFrame.numberIsZero(d2));
end
function TestLine2D.test_absDistanceToPoint()
	local p1 =  vector2d:new(1,1);
	local p2 =  vector2d:new(2,2);
	local line2d = CSGLine2D.fromPoints(p1,p2);
	
	local _p1 = vector2d:new(3,3);
	local _p2 = vector2d:new(3,0);
	local d0 = line2d:absDistanceToPoint(_p1);
	local d1 = line2d:absDistanceToPoint(_p2);
	echo(d0);
	echo(d1);

	-- todo
	--[[
	local normal = TestFrame.randomNormal2d();
	local w = math.random()*100;
	local line2d = CSGLine2D:new():init(normal,w);

	local p1 =  TestFrame.randomVector2d();
	local p2 =  TestFrame.randomVector2d();
	local line2d2 = CSGLine2D.fromPoints(p1,p2);

	local ip = line2d:intersectWithLine(line2d2);
	local d0 = line2d:absDistanceToPoint(ip);
	local d1 = line2d:absDistanceToPoint(p1);
	local d2 = line2d:absDistanceToPoint(p2);
	local d3 = p1:dist(ip);
	local d4 = p2:dist(ip);
	echo(d0);
	echo(d1);
	echo(d2);
	echo(d3);
	echo(d4);
	echo((p1-p2):length());
	assert(TestFrame.numberEquals(d1,d2));
	--]]
end
function TestLine2D.test_transform()
	local p1 =  TestFrame.randomVector2d();
	local p2 =  TestFrame.randomVector2d();
	local line2d = CSGLine2D.fromPoints(p1,p2);
	local matrix = TestFrame.randomMatrix();

	line2d:transform(matrix);
	p1:transform(matrix);
	p2:transform(matrix);
	local line2d2 = CSGLine2D.fromPoints(p1,p2);

	echo(line2d);
	echo(line2d2);

	-- todo
	--assert(line2d:equals(line2d2));
end
