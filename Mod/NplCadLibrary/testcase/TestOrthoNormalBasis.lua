NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/Plane.lua");

local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");
local vector3d = commonlib.gettable("mathlib.vector3d");
local Plane = commonlib.gettable("mathlib.Plane");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestOrthoNormalBasis = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestOrthoNormalBasis"));

function TestOrthoNormalBasis.test_Init()
	local plane =  TestFrame.randomPlane();
	local onb = CSGOrthoNormalBasis:new():init(plane);
	assert(onb.plane:equals(plane));
end

function TestOrthoNormalBasis.test_Clone()
	local plane =  TestFrame.randomPlane();
	local onb = CSGOrthoNormalBasis:new():init(plane);
	local onb2 = onb:clone();
	assert(onb.u:equals(onb2.u));
	assert(onb.v:equals(onb2.v));
	assert(onb.plane:equals(onb2.plane));
	assert(onb.planeorigin:equals(onb2.planeorigin));
end

function TestOrthoNormalBasis.test_GetCartesian()
	CSGOrthoNormalBasis.GetCartesian_Test();
end

function TestOrthoNormalBasis.test_Z0Plane()
	local onb = CSGOrthoNormalBasis.Z0Plane();
	assert(onb.u:equals(vector3d.unit_x));
	assert(onb.v:equals(vector3d.unit_y));
	assert(onb.plane:equals(Plane:new():init(0,0,1,0)));
	assert(onb.planeorigin:equals(vector3d.zero));
end

function TestOrthoNormalBasis.test_getProjectionMatrix()
	local plane =  TestFrame.randomPlane();
	local onb = CSGOrthoNormalBasis:new():init(plane);
	local project = onb:getProjectionMatrix();
	assert(onb.u:equals(vector3d:new(project[1],project[5],project[9])));
	assert(onb.v:equals(vector3d:new(project[2],project[6],project[10])));
	assert(onb.plane:GetNormal():equals(vector3d:new(project[3],project[7],project[11])));
	assert(vector3d.zero:equals(vector3d:new(project[4],project[8],project[12])));
	local translate1 = vector3d:new(project[13],project[14],project[15]);
	local translate2 = vector3d:new(0,0,-onb.plane[4]);
	assert(translate1:equals(translate2));
	assert(project[16] == 1);
end
function TestOrthoNormalBasis.test_getInverseProjectionMatrix()
	local plane =  TestFrame.randomPlane();
	local onb = CSGOrthoNormalBasis:new():init(plane);
	local project = onb:getProjectionMatrix();
	project:inverse();
	assert(onb.u:equals(vector3d:new(project[1],project[5],project[9])));
	assert(onb.v:equals(vector3d:new(project[2],project[6],project[10])));
	assert(onb.plane:GetNormal():equals(vector3d:new(project[3],project[7],project[11])));
	assert(vector3d.zero:equals(vector3d:new(project[4],project[8],project[12])));
	local translate1 = vector3d:new(project[13],project[14],project[15]);
	local translate2 = vector3d:new(0,0,-onb.plane[4]);
	assert(translate1:equals(translate2));
	assert(project[16] == 1);
end

function TestOrthoNormalBasis.test_transform()
	local plane =  TestFrame.randomPlane();
	local onb = CSGOrthoNormalBasis:new():init(plane);
	local matrix4x4 = TestFrame.randomMatrix();

    local rightvector = (onb.u * matrix4x4);
	onb:transform(matrix4x4);

	assert(TestFrame.numberIsZero(onb.plane:GetNormal():dot(onb.u)));	
	assert(TestFrame.numberIsZero(onb.plane:GetNormal():dot(onb.v)));	
	assert(TestFrame.numberIsZero(onb.v:dot(onb.u)));	
	assert(TestFrame.numberEquals(1,onb.plane:GetNormal():length()));	
	assert(TestFrame.numberEquals(1,onb.u:length()));	
	assert(TestFrame.numberEquals(1,onb.v:length()));	
	assert(onb.plane:GetNormal():equals(onb.planeorigin * (1/onb.plane[4])));

    local origin_transformed = vector3d.zero * matrix4x4;
    rightvector:sub(origin_transformed):normalize();
    local plane = plane:clone():transform(matrix4x4);
    local plane_normal = plane:GetNormal();

    local v = (plane_normal * rightvector):normalize();
    local u = v * plane_normal;
    local planeorigin = plane_normal:MulByFloat(plane[4]);

	assert(onb.u:equals(u));
	assert(onb.v:equals(v));
	assert(onb.plane:equals(plane));
	assert(onb.planeorigin:equals(planeorigin));
end
	--[[
	to2D
	to3D
	line3Dto2D
	line2Dto3D
	--]]