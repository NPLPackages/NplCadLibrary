NPL.load("npl_packages/NplCadLibrary/");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/vector2d.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPath2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGConnector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Drawable.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/matrix_decomp.lua");

NPL.load("(gl)Mod/NplCadLibrary/testcase/TestObjectPool.lua");
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestLine3D.lua");
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestLine2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestConnector.lua");
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestOrthoNormalBasis.lua");
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestVector3D.lua");

local vector3d = commonlib.gettable("mathlib.vector3d");
local vector2d = commonlib.gettable("mathlib.vector2d");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Plane = commonlib.gettable("mathlib.Plane");

local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CSGPath2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPath2D");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");
local CSGConnector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnector");
local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local Drawable = commonlib.gettable("Mod.NplCadLibrary.core.Drawable");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");

local TestFrame = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame"));
local TestObjectPool = commonlib.gettable("Mod.NplCadLibrary.testcase.TestObjectPool");
local TestVertex = commonlib.gettable("Mod.NplCadLibrary.testcase.TestVertex");
local TestLine3D = commonlib.gettable("Mod.NplCadLibrary.testcase.TestLine3D");
local TestLine2D = commonlib.gettable("Mod.NplCadLibrary.testcase.TestLine2D");
local TestConnector = commonlib.gettable("Mod.NplCadLibrary.testcase.TestConnector");
local TestOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.testcase.TestOrthoNormalBasis");
local TestPolygon = commonlib.gettable("Mod.NplCadLibrary.testcase.TestPolygon");
local TestVector3D = commonlib.gettable("Mod.NplCadLibrary.testcase.TestVector3D");

local suits = {};

--Iterator
function TestFrame.pairsByKeys(t)      
    local a = {}      
    for n in pairs(t) do          
        a[#a+1] = n      
    end      
    table.sort(a)      
    local i = 0      
    return function()          
		i = i + 1          
		return a[i], t[a[i]]      
    end  
end
function TestFrame.runSuit(name,suit)
	for key, value in TestFrame.pairsByKeys(suit) do
		if(string.sub (key, 1 ,5) == "test_" and type(value) == "function") then
			echo("*******" ..name..".".. key .. "*******");
			TestFrame.randomLoopShell(value);
		end	      
	end
end

function TestFrame.Run()
	commonlib.use_object_pool = true;

	TestFrame.registTestSuit("TestVector3D",TestVector3D);
	TestFrame.registTestSuit("TestObjectPool",TestObjectPool);
	TestFrame.registTestSuit("TestVertex",TestVertex);
	TestFrame.registTestSuit("TestLine3D",TestLine3D);
	TestFrame.registTestSuit("TestLine2D",TestLine2D);
	TestFrame.registTestSuit("TestConnector",TestConnector);
	TestFrame.registTestSuit("TestOrthoNormalBasis",TestOrthoNormalBasis);
	TestFrame.registTestSuit("TestPolygon",TestPolygon);

	for key, value in TestFrame.pairsByKeys(suits) do
		TestFrame.runSuit(key,value);	      
	end

--[[
	TestFrame.TestCSGVector2D();
	TestFrame.TestCSGVector3D();
	TestFrame.TestPlane();
	TestFrame.TestMatrix4x4();

	TestFrame.TestUtil();
	TestFrame.TestCAGVertex();
	TestFrame.TestPath2D();
	TestFrame.TestSide();
	TestFrame.TestCAGFactory();
	TestFrame.TestCAG();
	TestFrame.TestClass();
	TestFrame.MatrixDecomp();
	--]]
end
function TestFrame.registTestSuit(name,suit)
	if(type(suit) == "table") then
		suits[name] = suit;
	end
end

function TestFrame.randomVector3d()
	return vector3d:new(math.random()*math.random(100), math.random()*math.random(100), math.random()*math.random(100));
end
function TestFrame.randomNormal3d()
	return vector3d:new(math.random(), math.random(), math.random()):normalize();
end
function TestFrame.randomVector2d()
	return vector2d:new(math.random()*math.random(100), math.random()*math.random(100));
end
function TestFrame.randomNormal2d()
	return vector2d:new(math.random(), math.random()):normalize();
end
function TestFrame.randomEulerAngles()
	return vector3d:new(math.random()*math.pi*2, math.random()*math.pi, math.random()*math.pi);
end
function TestFrame.randomPlane()
	return Plane.fromNormalAndPoint(TestFrame.randomNormal3d(),TestFrame.randomVector3d());
end
function TestFrame.randomMatrix()
	local translate = TestFrame.randomVector3d();
	--local scaling = TestFrame.randomVector3d();
	local factor = math.random()*100;
	local scaling = vector3d:new(factor,factor,factor);
	local angles = TestFrame.randomEulerAngles();
	local quat = Quaternion:new():FromEulerAngles(angles[1],angles[2],angles[3]);
	
	local mt = Matrix4.translation(translate);
	local mr = quat:ToRotationMatrix();
	local ms = Matrix4.scaling(scaling);
	return mt:multiply(mr):multiply(ms);
end
function TestFrame.randomLoopShell(funcTest)
	local seed = os.time();
	echo("seed = " .. tostring(seed));
	math.randomseed(seed);  

	local i;
	for i=1,10,1 do
		echo("loop = " .. tostring(i)); 
		funcTest();
	end	
end
function TestFrame.replayRandom(seed,loopTimes,funcTest)
	math.randomseed(seed); 
	local i;
	for i=1,loopTimes-1,1 do
		echo("loop = " .. tostring(i)); 
		funcTest();
	end	
end
function TestFrame.numberEquals(a,b,epsilon)
	epsilon = epsilon or tonumber("1e-5");
	return math.abs(a-b)<epsilon;
end
function TestFrame.numberIsZero(a,epsilon)
	epsilon = epsilon or tonumber("1e-5");
	return math.abs(a)<epsilon;
end


function TestFrame.TestUtil()
	echo("mathext.round(1.7) = "..mathext.round(1.7));
	echo("mathext.round(2.3) = "..mathext.round(2.3));
	echo("math.pi = "..math.pi);

	local t1 = {"1",2,"4"};
	local t2 = {"5",8,"9"};
	local t3 = tableext.concat(t1,t2);
	echo("tableext.concat({'1',2,'4'},{'5',8,'9'})=,"..table.concat(t3,","));

	local t4 = tableext.splice(t1,2,0,7,8);
	echo("tableext.splice = "..table.concat(t4,","));
	local t5 = tableext.splice(t1,2,1,7,8); 
	echo("tableext.splice = "..table.concat(t5,","));

	local t6 = tableext.slice(t2,1,2);
	echo("tableext.slice = "..table.concat(t6,","));
	local t7 = tableext.slice(t3);
	echo("tableext.slice = "..table.concat(t7,","));

	local t8 = tableext.reverse(t2);
	echo("tableext.reverse = "..table.concat(t8,","));
end

function TestFrame.TestCSGVector2D()
	echo(vector2d:new(5.1,6.3));
	echo(vector2d:new(5.1,6.3):clone());
	echo(CSGVector2D:new_from_pool(6.1,7.3):clone_from_pool());
	echo(CSGVector2D.fromAngleDegrees(30));
	echo(CSGVector2D.fromAngleRadians(math.pi / 6));
	echo(CSGVector2D.fromAngle(math.pi / 6));

	local v2d = vector2d:new(5.2,6.4);
	local v2d2 = vector2d:new(7.3,9.8);
	echo(vector2d:new({5.2,6.4}));
	echo(v2d:negated());
	echo(v2d:negatedInplace());
	echo(v2d:add(v2d2));
	echo(v2d:plusInplace(v2d2));
	echo(v2d:sub(v2d2));
	echo(v2d:minusInplace(v2d2));
	echo(v2d:MulByFloat(2.0));
	echo(v2d:MulByFloat(2.0));
	echo(v2d:dividedBy(2.0));
	echo(v2d:dividedByInplace(2.0));
	echo(v2d:dot(v2d2));
	echo(v2d:lerp(v2d2,0.3));
	echo(v2d:length());
	echo(v2d:lengthSquared());
	echo(v2d:normalize());
	v2d:init(5.2,6.4);
	echo(v2d:unitInplace());
	echo(v2d:cross(v2d2));
	v2d:init(-5.2,-6.4);
	echo(v2d:abs());
	echo(v2d:absInplace());
	echo(v2d:getX());
	echo(v2d:getY());
	echo(v2d:toVector3D(1.1));
	echo(v2d:equals(v2d2));
	echo(v2d:equals(vector2d:new(v2d:getX(),v2d:getY())));
	echo(v2d:multiply4x4(Matrix4:new():identity()));
	echo(v2d:transform(Matrix4:new():identity()));
	echo(v2d:angle());
	echo(v2d:angleDegrees());
	echo(v2d:angleRadians());
	echo(v2d:min(v2d2));
	echo(v2d:max(v2d2));
	echo(v2d:distanceTo(v2d2));
	echo(v2d:distanceToSquared(v2d2));
end

function TestFrame.TestCAGVertex()
	local vertex = CAGVertex:new():init(vector2d:new(4.8,-9.2));
	echo(vertex);
	echo(vertex:clone(true));
	echo(vertex:clone():detach());
	local other = CAGVertex:new():init(vector2d:new(6.3,-1.5));
	echo(vertex:interpolate(other,0.3));
	echo(vertex:getPosition());
end

function TestFrame.TestCSGVector3D()
	echo(vector3d:new(5.1,6.3,7.9));
	echo(vector3d:new(5.1,6.3,7.9):clone());
	echo(vector3d:new_from_pool(6.1,7.3,7.9):clone_from_pool());

	local v3d = vector3d:new(5.2,6.4,7.6);
	local v3d2 = vector3d:new(7.3,9.8,2.4);
	echo(v3d:negated());
	echo(v3d:negatedInplace());
	echo(v3d:add(v3d2));
	echo(v3d:plusInplace(v3d2));
	echo(v3d:sub(v3d2));
	echo(v3d:minusInplace(v3d2));
	echo(v3d:MulByFloat(2.0));
	echo(v3d:MulByFloat(2.0));
	echo(v3d:dividedBy(2.0));
	echo(v3d:dividedByInplace(2.0));
	echo(v3d:dot(v3d2));
	echo(v3d:lerp(v3d2,0.3));
	echo(v3d:length());
	echo(v3d:lengthSquared());
	echo(v3d:normalize());
	v3d:init(5.2,6.4,3.1);
	echo(v3d:unitInplace());
	echo(v3d:cross(v3d2));
	echo(v3d:crossInplace(v3d2));
	v3d:init(-5.2,-6.4,-9.1);
	echo(v3d:abs());
	echo(v3d:absInplace());
	echo(v3d:getX());
	echo(v3d:getY());
	echo(v3d:getZ());
	echo(v3d:toVector2D());
	echo(v3d:equals(v3d2));
	echo(v3d:equals(vector3d:new(v3d:getX(),v3d:getY(),v3d:getZ())));	
	echo(v3d:multiply4x4(Matrix4:new():identity()));
	echo(v3d:transform(Matrix4:new():identity()));
	echo(v3d:randomNonParallelVector());
	echo(v3d:min(v3d2));
	echo(v3d:max(v3d2));
	echo(v3d:distanceTo(v3d2));
	echo(v3d:distanceToSquared(v3d2));
end

function TestFrame.TestLine2D()
	echo("TestFrame.TestLine2D");
	local v2d = vector2d:new(5.1,6.3);
	local line2d = CSGLine2D:new():init(v2d:normalize(),2.3);
	local line2d2 = CSGLine2D.fromPoints(v2d,vector2d:new(7.3,9.8));
	local line2d3 = CSGLine2D:new():init(line2d.normal,line2d.w);
	echo(line2d);
	echo(line2d2);
	echo(line2d:reverse());
	echo(line2d:equals(line2d2));
	echo(line2d:equals(line2d3));
	echo(line2d:origin());
	echo(line2d:direction());
	echo(line2d:xAtY(12));
	echo(line2d:absDistanceToPoint(vector2d:new(7.3,9.8)));
	echo(line2d:transform(Matrix4:new():identity()));
end
function TestFrame.TestPlane()
	echo("TestFrame.TestPlane");
	local plane = Plane:new():init(vector3d:new(0,1,0),2);
	local plane2 = Plane:new():init(vector3d:new(1,0,0),2);
	echo(plane);
	echo(Plane.fromPoints(vector3d:new(0,1,0),vector3d:new(0,0,1),vector3d:new(1,0,0)));
	echo(Plane.fromVector3Ds(vector3d:new(0,1,0),vector3d:new(0,0,1),vector3d:new(1,0,0)));
	echo(Plane.fromNormalAndPoint(vector3d:new(0,1,0),vector3d:new(1,1,1)));
	echo(Plane.anyPlaneFromVector3Ds(vector3d:new(1,1,10),vector3d:new(2,2,2),vector3d:new(2,2,2)));
	echo(plane:clone());
	echo(plane:inverse());
	echo(plane:equals(plane:clone()));
	echo(plane:equals(plane2));
	echo(plane:transform(Matrix4:new():identity()));
	echo(plane:splitLineBetweenPoints(vector3d:new(0,3,0),vector3d:new(0,-1,0)));
	echo(plane:intersectWithLine(CSGLine3D.fromPoints(vector3d:new(0,3,0),vector3d:new(0,-1,0))));
	echo(plane:intersectWithPlane(plane2));
	echo(plane:signedDistanceToPoint(vector3d:new(0,3,0)));
	echo(plane:mirrorPoint(vector3d:new(0,3,0)));
end
function TestFrame.TestPath2D()
	echo("TestFrame.TestPlane");
	-- the index of array problem coming! 
	local path2d_closed = CSGPath2D:new():init({{0,1},{1,1},{1,0},{0,0}},true);
	local path2d_opened = CSGPath2D:new():init({{0,1},{1,1},{1,0},{0,0}},false);
	echo(path2d_closed);
	echo(path2d_opened);
	local path2d_arc = CSGPath2D.arc({
		center = {1,1},
		radius = 2,
		startangle = 30,
		endangle = 330,
		resolution = 32,
		maketangent = true
	});
	echo(path2d_arc);
	echo(path2d_opened:concat(path2d_arc));
	echo(path2d_closed:concat(path2d_arc));
	echo(path2d_opened:appendPoint({0,0}));
	echo(path2d_closed:appendPoint({0,0}));
	echo(path2d_opened:appendPoints({{0,0},{0.2,0.1},{0.4,0.3}}));
	local path2d = CSGPath2D:new():init({{0,3},{1,2}},false);
	echo("appendBezier");
	echo(path2d:appendBezier({{0,1},{1,1},{1,0},{0,0}},{resolution =8}));
	echo("appendArc");
	echo(path2d:appendArc({0,1},{	--???
		resolution = 8,
		radius = 0.2,
		xaxisrotation = 30,
		clockwise = true,
		large = false;
	}));
	echo("appendArc");
	echo(path2d:appendArc({0,1},{	--???
		resolution = 8,
		xradius = 0.3,
		yradius = 0.1,
		xaxisrotation = 30,
		clockwise = true,
		large = false;
	}));
	echo("transform");
	echo(path2d_arc:transform(Matrix4:new():identity()));
	echo("expandToCAG");
	echo(path2d_opened:expandToCAG(0.2,8));
	echo("rectangularExtrude");
	echo(path2d_opened:rectangularExtrude(0.2,0.2,8));
	path2d_arc.closed = true;
	echo(path2d_arc:innerToCAG());
end
function TestFrame.TestSide()
	echo("TestFrame.TestSide");
	local vertex = CAGVertex:new():init(vector2d:new(4.8,-9.2));
	local other = CAGVertex:new():init(vector2d:new(6.3,-1.5));
	local side = CAGSide:new():init(vertex,other);
	echo(side);
	echo(side:toPolygon3D(1,0.7));
	echo(side:flipped());
	echo(side:direction());
	echo(side:lengthSquared());
	echo(side:length());
	echo(side:transform(Matrix4:new():identity()));
	-- _fromFakePolygon
end
function TestFrame.TestConnector()
	echo("TestFrame.TestConnector");
	local origin = {0, 0, 0};
	local defaultAxis = {0, 0, 1};
	local defaultNormal = {0, 1, 0};
    local connector = CSGConnector:new():init(origin, defaultAxis, defaultNormal);
	local other = CSGConnector:new():init(origin, defaultAxis, defaultNormal);
	echo(connector);
	echo(connector:normalize());
	echo(connector:transform(Matrix4:new():identity()));
	echo(connector:axisLine());
	echo(connector:extend(3));
	echo(connector:getTransformationTo(other,false,0));
end
function TestFrame.TestConnectorList()
	-- not be used
end

function TestFrame.TestOrthoNormalBasis()
	echo("TestFrame.TestOrthoNormalBasis");
	local plane = Plane:new():init(vector3d:new(0,1,0),2);
	local onb = CSGOrthoNormalBasis:new():init(plane);
	echo(onb);
	echo(onb:Z0Plane());
	echo(onb:getProjectionMatrix());
	echo(onb:getInverseProjectionMatrix());
	echo(onb:transform(Matrix4:new():identity()));
	echo(onb:to2D(vector3d:new(0,3,0)));
	echo(onb:to3D(vector2d:new(0,2,0)));
	--line3Dto2D
	local v3d = vector3d:new(0,3,0);
	local v3d2 = vector3d:new(3,3,3);
	local line3d = CSGLine3D.fromPoints(v3d,v3d2);
	echo(onb:line3Dto2D(line3d));
	--line2Dto3D
	local v2d = vector3d:new(0,0);
	local v2d2 = vector3d:new(3,3);
	local line2d = CSGLine2D.fromPoints(v2d,v2d2);
	echo(onb:line2Dto3D(line2d));

	echo(CSGOrthoNormalBasis.GetCartesian_Test());
end

function TestFrame.TestMatrix4x4()
	echo("TestFrame.TestMatrix4x4");
	local m1 = Matrix4:new():identity();
	local mt = Matrix4.translation(vector3d:new(1,2,3));
	local mr = Matrix4.rotation({1,2,3},{0,1,0},30);
	local ms = Matrix4.scaling(vector3d:new(3,2,1));
	local m2 = mt:multiply(mr):multiply(ms);
	echo(m1);
	echo(mt);
	echo(mr);
	echo(ms);
	echo(Matrix4.unity());
	echo(Matrix4.rotationX(30));
	echo(Matrix4.rotationY(15));
	echo(Matrix4.rotationZ(60));
	local plane = Plane:new():init(vector3d:new(3,1,2),2);
	echo(Matrix4.mirroring(plane));
	echo(m1:add(m2));
	echo(m1:sub(m2));
	echo(m1:clone());
	echo(m2:isMirroring());
	local v3d2 = vector3d:new(4,3,2);
	echo(m2:leftMultiply1x3Vector(v3d2));
	echo(m2:rightMultiply1x3Vector(v3d2));
	local v2d2 = vector2d:new(4,3);
	echo(m2:leftMultiply1x2Vector(v2d2));
	echo(m2:rightMultiply1x2Vector(v2d2));

	echo("*****Matrix4.rotationZ****")
	local m = Matrix4.rotationZ(45);
	echo(m);
	echo(m:leftMultiply1x3Vector(v3d2));
	echo("*****Matrix4.rotationZ****")
end

function TestFrame.TestCAGFactory()
	echo("TestFrame.TestCAGFactory");
	echo(CAGFactory.rectangle({corner1={1,2},corner2 = {3,4}}));
	echo(CAGFactory.rectangle({center={1,2},radius = {2,2}}));
	echo(CAGFactory.circle({center={1,2},radius = 1.5,resolution = 8}));
	echo(CAGFactory.ellipse({center={1,2},radius ={2,2},resolution = 8}));
end
function TestFrame.TestCAG()
	echo("TestFrame.TestCAG");
	echo(CAG.fromPoints());

	local cag = CAG.fromPoints({{-1,-1},{-1,1},{1,1},{1,-1}});
	echo(cag);
	echo(cag:area());
	echo(cag:flipped());
	echo("==============");
	echo(cag:extrude({offset={0,0.1,0}}));

	local spuare = CAGFactory.rectangle({center={0,0},radius = {1,1}})
	echo(spuare:rotateExtrude());
end

function TestFrame.TestClass()
	local model = CSGModel:new():init({node=1},"Model");
	local result = model:getNode();
	echo(result);
	echo(model.node);
	echo(model:getTypeName());

	local shape = CAGModel:new():init({node=2},"Shape");
	local result2 = shape:getNode();
	echo(result2);
	echo(shape.node);
	echo(shape:getTypeName());
end

function TestFrame.MatrixDecomp()
	echo("*****MatrixDecomp******");
	
	local rotationQuat = Quaternion:new();
	local i,x = 0,0;
	local math_pi = 3.1415926;

	for i=-180,180,1 do
		local mt = Matrix4:new():identity():makeTrans(11.32148229302237,7.626224465189316,-13.4092143985971);
		local ms = Matrix4:new():identity();
		ms:setScale(1.1,2.2,3.3);

		local yaw = i * math_pi / 180;
		local roll = i * math_pi / 180;
		local pitch = i * math_pi / 180;
		rotationQuat = rotationQuat:FromEulerAngles(yaw,roll,pitch);

		local mr = rotationQuat:ToRotationMatrix();
		local matrix = ms * mr * mt;
		echo(matrix);

		local result = matrix:Decompose();
		local quatDecomp = Quaternion:new():set(result.rotation);
		yaw, roll, pitch = quatDecomp:ToEulerAngles();
		local eulerAngles = {yaw * 180 / math_pi,roll * 180 / math_pi,pitch * 180 / math_pi};
		
		echo(result);
		echo(eulerAngles);
		echo("==================");
		--[[
		for x=1,4 do
			echo(math.abs(result.rotation[x]-rotationQuat[x]));
			assert(math.abs(result.rotation[x]-rotationQuat[x])<0.00001);  
		end
		]]--
	end
end