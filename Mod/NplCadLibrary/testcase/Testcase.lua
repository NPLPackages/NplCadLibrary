NPL.load("npl_packages/NplCadLibrary/");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGLine3D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPlane.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPath2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGMatrix4x4.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGConnector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Drawable.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/matrix_decomp.lua");

local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGLine2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine2D");
local CSGLine3D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGLine3D");
local CSGPlane = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPlane");
local CSGPath2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPath2D");
local CSGMatrix4x4 = commonlib.gettable("Mod.NplCadLibrary.csg.CSGMatrix4x4");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");
local CSGConnector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnector");
local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local Drawable = commonlib.gettable("Mod.NplCadLibrary.core.Drawable");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local vector3d = commonlib.gettable("mathlib.vector3d");
local Quaternion = commonlib.gettable("mathlib.Quaternion");

local Testcase = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.Testcase"));

function Testcase.Run()
	Testcase.TestUtil();
	Testcase.TestCSGVector2D();
	Testcase.TestCAGVertex();
	Testcase.TestCSGVector3D();
	Testcase.TestCSGVertex();
	Testcase.TestLine2D();
	Testcase.TestLine3D();
	Testcase.TestPlane();
	Testcase.TestPath2D();
	Testcase.TestSide();
	Testcase.TestConnector();
	Testcase.TestConnectorList();
	Testcase.TestOrthoNormalBasis();
	Testcase.TestCAGFactory();
	Testcase.TestMatrix4x4();
	Testcase.TestCAG();
	Testcase.TestClass();
	Testcase.MatrixDecomp();
end

function Testcase.TestUtil()
	
	echo("mathext.round(1.7) = "..mathext.round(1.7));
	echo("mathext.round(2.3) = "..mathext.round(2.3));
	echo("mathext.pi = "..mathext.pi);

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

function Testcase.TestCSGVector2D()
	echo(CSGVector2D:new():init(5.1,6.3));
	echo(CSGVector2D:new():init(5.1,6.3):clone());
	echo(CSGVector2D:new_from_pool(6.1,7.3):clone_from_pool());
	echo(CSGVector2D.fromAngleDegrees(30));
	echo(CSGVector2D.fromAngleRadians(mathext.pi / 6));
	echo(CSGVector2D.fromAngle(mathext.pi / 6));

	local v2d = CSGVector2D:new():init(5.2,6.4);
	local v2d2 = CSGVector2D:new():init(7.3,9.8);
	echo(CSGVector2D:new():init({5.2,6.4}));
	echo(v2d:negated());
	echo(v2d:negatedInplace());
	echo(v2d:plus(v2d2));
	echo(v2d:plusInplace(v2d2));
	echo(v2d:minus(v2d2));
	echo(v2d:minusInplace(v2d2));
	echo(v2d:times(2.0));
	echo(v2d:timesInplace(2.0));
	echo(v2d:dividedBy(2.0));
	echo(v2d:dividedByInplace(2.0));
	echo(v2d:dot(v2d2));
	echo(v2d:lerp(v2d2,0.3));
	echo(v2d:length());
	echo(v2d:lengthSquared());
	echo(v2d:unit());
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
	echo(v2d:equals(CSGVector2D:new():init(v2d:getX(),v2d:getY())));
	echo(v2d:multiply4x4(CSGMatrix4x4:new():init()));
	echo(v2d:transform(CSGMatrix4x4:new():init()));
	echo(v2d:angle());
	echo(v2d:angleDegrees());
	echo(v2d:angleRadians());
	echo(v2d:min(v2d2));
	echo(v2d:max(v2d2));
	echo(v2d:distanceTo(v2d2));
	echo(v2d:distanceToSquared(v2d2));
end

function Testcase.TestCAGVertex()
	local vertex = CAGVertex:new():init(CSGVector2D:new():init(4.8,-9.2));
	echo(vertex);
	echo(vertex:clone(true));
	echo(vertex:clone():detach());
	local other = CAGVertex:new():init(CSGVector2D:new():init(6.3,-1.5));
	echo(vertex:interpolate(other,0.3));
	echo(vertex:getPosition());
end

function Testcase.TestCSGVector3D()
	echo(CSGVector:new():init(5.1,6.3,7.9));
	echo(CSGVector:new():init(5.1,6.3,7.9):clone());
	echo(CSGVector:new_from_pool(6.1,7.3,7.9):clone_from_pool());

	local v3d = CSGVector:new():init(5.2,6.4,7.6);
	local v3d2 = CSGVector:new():init(7.3,9.8,2.4);
	echo(v3d:negated());
	echo(v3d:negatedInplace());
	echo(v3d:plus(v3d2));
	echo(v3d:plusInplace(v3d2));
	echo(v3d:minus(v3d2));
	echo(v3d:minusInplace(v3d2));
	echo(v3d:times(2.0));
	echo(v3d:timesInplace(2.0));
	echo(v3d:dividedBy(2.0));
	echo(v3d:dividedByInplace(2.0));
	echo(v3d:dot(v3d2));
	echo(v3d:lerp(v3d2,0.3));
	echo(v3d:length());
	echo(v3d:lengthSquared());
	echo(v3d:unit());
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
	echo(v3d:equals(CSGVector:new():init(v3d:getX(),v3d:getY(),v3d:getZ())));	
	echo(v3d:multiply4x4(CSGMatrix4x4:new():init()));
	echo(v3d:transform(CSGMatrix4x4:new():init()));
	echo(v3d:randomNonParallelVector());
	echo(v3d:min(v3d2));
	echo(v3d:max(v3d2));
	echo(v3d:distanceTo(v3d2));
	echo(v3d:distanceToSquared(v3d2));
end

function Testcase.TestCSGVertex()
	echo("Testcase.TestCSGVertex");
	local vertex = CSGVertex:new():init(CSGVector:new():init(4.8,-9.2,7.9),CSGVector:new():init(0,1,0));
	echo(vertex);
	echo(vertex:clone(true));
	echo(vertex:clone():detach());
	local other = CSGVertex:new():init(CSGVector:new():init(6.3,-1.5,7.2),CSGVector:new():init(0,1,0));
	echo(vertex:interpolate(other,0.3));
end

function Testcase.TestLine2D()
	echo("Testcase.TestLine2D");
	local v2d = CSGVector2D:new():init(5.1,6.3);
	local line2d = CSGLine2D:new():init(v2d:unit(),2.3);
	local line2d2 = CSGLine2D.fromPoints(v2d,CSGVector2D:new():init(7.3,9.8));
	local line2d3 = CSGLine2D:new():init(line2d.normal,line2d.w);
	echo(line2d);
	echo(line2d2);
	echo(line2d:reverse());
	echo(line2d:equals(line2d2));
	echo(line2d:equals(line2d3));
	echo(line2d:origin());
	echo(line2d:direction());
	echo(line2d:xAtY(12));
	echo(line2d:absDistanceToPoint(CSGVector2D:new():init(7.3,9.8)));
	echo(line2d:transform(CSGMatrix4x4:new():init()));
end
function Testcase.TestLine3D()
	echo("Testcase.TestLine3D");
	local v3d = CSGVector:new():init(5.1,6.3,7.9);
	local v3d2 = CSGVector:new():init(-5.1,-6.3,-7.9);
	local line3d = CSGLine3D:new():init(CSGVector:new():init(0,1,0),v3d);
	local line3d2 = CSGLine3D:new():init(CSGVector:new():init(1,0,0),v3d);
	echo(line3d);
	echo(line3d2);
	echo(CSGLine3D.fromPoints(v3d,v3ds));
	echo(CSGLine3D.fromPlanes(
		CSGPlane:new():init(
			CSGVector:new():init(0,1,0),
			2
		),
		CSGPlane:new():init(
			CSGVector:new():init(0,0,1),
			2
		)));
	echo(line3d:intersectWithPlane(CSGPlane:new():init(CSGVector:new():init(0,1,0),2)));
	echo(line3d:clone(line3d));
	echo(line3d:reverse());
	echo(line3d:transform(CSGMatrix4x4:new():init()));
	echo(line3d:closestPointOnLine(CSGVector:new():init(1,0,0)));
	echo(line3d:distanceToPoint(CSGVector:new():init(1,0,0)));
	echo(line3d:equals(line3d2));
	echo(line3d:equals(line3d:clone()));
end
function Testcase.TestPlane()
	echo("Testcase.TestPlane");
	local plane = CSGPlane:new():init(CSGVector:new():init(0,1,0),2);
	local plane2 = CSGPlane:new():init(CSGVector:new():init(1,0,0),2);
	echo(plane);
	echo(CSGPlane.fromPoints(CSGVector:new():init(0,1,0),CSGVector:new():init(0,0,1),CSGVector:new():init(1,0,0)));
	echo(CSGPlane.fromVector3Ds(CSGVector:new():init(0,1,0),CSGVector:new():init(0,0,1),CSGVector:new():init(1,0,0)));
	echo(CSGPlane.fromNormalAndPoint(CSGVector:new():init(0,1,0),CSGVector:new():init(1,1,1)));
	echo(CSGPlane.anyPlaneFromVector3Ds(CSGVector:new():init(1,1,10),CSGVector:new():init(2,2,2),CSGVector:new():init(2,2,2)));
	echo(plane:clone());
	echo(plane:flip());
	echo(plane:equals(plane:clone()));
	echo(plane:equals(plane2));
	echo(plane:transform(CSGMatrix4x4:new():init()));
	echo(plane:splitLineBetweenPoints(CSGVector:new():init(0,3,0),CSGVector:new():init(0,-1,0)));
	echo(plane:intersectWithLine(CSGLine3D.fromPoints(CSGVector:new():init(0,3,0),CSGVector:new():init(0,-1,0))));
	echo(plane:intersectWithPlane(plane2));
	echo(plane:signedDistanceToPoint(CSGVector:new():init(0,3,0)));
	echo(plane:mirrorPoint(CSGVector:new():init(0,3,0)));
end
function Testcase.TestPath2D()
	echo("Testcase.TestPlane");
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
	echo(path2d_arc:transform(CSGMatrix4x4:new():init()));
	echo("expandToCAG");
	echo(path2d_opened:expandToCAG(0.2,8));
	echo("rectangularExtrude");
	echo(path2d_opened:rectangularExtrude(0.2,0.2,8));
	path2d_arc.closed = true;
	echo(path2d_arc:innerToCAG());
end
function Testcase.TestSide()
	echo("Testcase.TestSide");
	local vertex = CAGVertex:new():init(CSGVector2D:new():init(4.8,-9.2));
	local other = CAGVertex:new():init(CSGVector2D:new():init(6.3,-1.5));
	local side = CAGSide:new():init(vertex,other);
	echo(side);
	echo(side:toPolygon3D(1,0.7));
	echo(side:flipped());
	echo(side:direction());
	echo(side:lengthSquared());
	echo(side:length());
	echo(side:transform(CSGMatrix4x4:new():init()));
	-- _fromFakePolygon
end
function Testcase.TestConnector()
	echo("Testcase.TestConnector");
	local origin = {0, 0, 0};
	local defaultAxis = {0, 0, 1};
	local defaultNormal = {0, 1, 0};
    local connector = CSGConnector:new():init(origin, defaultAxis, defaultNormal);
	local other = CSGConnector:new():init(origin, defaultAxis, defaultNormal);
	echo(connector);
	echo(connector:normalized());
	echo(connector:transform(CSGMatrix4x4:new():init()));
	echo(connector:axisLine());
	echo(connector:extend(3));
	echo(connector:getTransformationTo(other,false,0));
end
function Testcase.TestConnectorList()
	-- not be used
end

function Testcase.TestOrthoNormalBasis()
	echo("Testcase.TestOrthoNormalBasis");
	local plane = CSGPlane:new():init(CSGVector:new():init(0,1,0),2);
	local onb = CSGOrthoNormalBasis:new():init(plane);
	echo(onb);
	echo(onb:Z0Plane());
	echo(onb:getProjectionMatrix());
	echo(onb:getInverseProjectionMatrix());
	echo(onb:transform(CSGMatrix4x4:new():init()));
	echo(onb:to2D(CSGVector:new():init(0,3,0)));
	echo(onb:to3D(CSGVector2D:new():init(0,2,0)));
	--line3Dto2D
	local v3d = CSGVector:new():init(0,3,0);
	local v3d2 = CSGVector:new():init(3,3,3);
	local line3d = CSGLine3D.fromPoints(v3d,v3d2);
	echo(onb:line3Dto2D(line3d));
	--line2Dto3D
	local v2d = CSGVector:new():init(0,0);
	local v2d2 = CSGVector:new():init(3,3);
	local line2d = CSGLine2D.fromPoints(v2d,v2d2);
	echo(onb:line2Dto3D(line2d));

	echo(CSGOrthoNormalBasis.GetCartesian_Test());
end

function Testcase.TestMatrix4x4()
	echo("Testcase.TestMatrix4x4");
	local m1 = CSGMatrix4x4:new():init();
	local mt = CSGMatrix4x4.translation(CSGVector:new():init(1,2,3));
	local mr = CSGMatrix4x4.rotation({1,2,3},{0,1,0},30);
	local ms = CSGMatrix4x4.scaling(CSGVector:new():init(3,2,1));
	local m2 = mt:multiply(mr):multiply(ms);
	echo(m1);
	echo(mt);
	echo(mr);
	echo(ms);
	echo(CSGMatrix4x4.unity());
	echo(CSGMatrix4x4.rotationX(30));
	echo(CSGMatrix4x4.rotationY(15));
	echo(CSGMatrix4x4.rotationZ(60));
	local plane = CSGPlane:new():init(CSGVector:new():init(3,1,2),2);
	echo(CSGMatrix4x4.mirroring(plane));
	echo(m1:plus(m2));
	echo(m1:minus(m2));
	echo(m1:clone());
	echo(m2:isMirroring());
	local v3d2 = CSGVector:new():init(4,3,2);
	echo(m2:leftMultiply1x3Vector(v3d2));
	echo(m2:rightMultiply1x3Vector(v3d2));
	local v2d2 = CSGVector2D:new():init(4,3);
	echo(m2:leftMultiply1x2Vector(v2d2));
	echo(m2:rightMultiply1x2Vector(v2d2));

	echo("*****CSGMatrix4x4.rotationZ****")
	local m = CSGMatrix4x4.rotationZ(45);
	echo(m);
	echo(m:leftMultiply1x3Vector(v3d2));
	echo("*****CSGMatrix4x4.rotationZ****")
end

function Testcase.TestCAGFactory()
	echo("Testcase.TestCAGFactory");
	echo(CAGFactory.rectangle({corner1={1,2},corner2 = {3,4}}));
	echo(CAGFactory.rectangle({center={1,2},radius = {2,2}}));
	echo(CAGFactory.circle({center={1,2},radius = 1.5,resolution = 8}));
	echo(CAGFactory.ellipse({center={1,2},radius ={2,2},resolution = 8}));
end
function Testcase.TestCAG()
	echo("Testcase.TestCAG");
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

function Testcase.TestClass()
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

function Testcase.MatrixDecomp()
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

		local mr = rotationQuat:ToRotationMatrix(resultMatrix);
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