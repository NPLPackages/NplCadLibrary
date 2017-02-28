NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)script/ide/math/vector.lua");

local vector3d = commonlib.gettable("mathlib.vector3d");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestVector3D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestVector3D"));

function TestVector3D.test_transform()
	local normal = TestFrame.randomNormal3d();
	local matrix = TestFrame.randomMatrix();
	local normal2 = normal:transform_normal(matrix):normalize();
	echo(normal);
	echo(normal2);
	assert(normal == normal2);
	assert(normal2:length()<= 1.0);
end

function TestVector3D.test_poolSpeed()
	local i;
	local v3d;
	local times = 100;

	local fromTime = ParaGlobal.timeGetTime();
	for i=1,times,1 do
		v3d = vector3d:new(1,2,3);
		echo(v3d);
	end
	local endTime = ParaGlobal.timeGetTime();
	LOG.std(nil, "info", "TestVector3D", "new directly used %.3f seconds\n", (endTime-fromTime)/1000);

	fromTime = ParaGlobal.timeGetTime();
	for i=1,times,1 do
		v3d = vector3d:new_from_pool(1,2,3);
		echo(v3d);
	end
	endTime = ParaGlobal.timeGetTime();
	LOG.std(nil, "info", "TestVector3D", "new new_from_pool first used %.3f seconds\n", (endTime-fromTime)/1000);

	local size = vector3d.getPoolSize();
	LOG.std(nil, "info", "TestVector3D", "pool size = %d\n", size);
	vector3d.clearPool();
	size = vector3d.getPoolSize();
	LOG.std(nil, "info", "TestVector3D", "pool size = %d\n", size);

	fromTime = ParaGlobal.timeGetTime();
	for i=1,times,1 do
		v3d = vector3d:new_from_pool(1,2,3);
		echo(v3d);
	end
	endTime = ParaGlobal.timeGetTime();
	LOG.std(nil, "info", "TestVector3D", "new new_from_pool second used %.3f seconds\n", (ParaGlobal.timeGetTime()-fromTime)/1000);
end 