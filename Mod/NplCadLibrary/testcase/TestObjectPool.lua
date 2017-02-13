NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");

local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestObjectPool = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestObjectPool"));

function TestObjectPool.test_ObjectPool()
	local v1 = CSGVertex:new():init({1,2,3},{0,1,0});
	local v2 = CSGVertex:new():init({2,3,4},{0.7,0.7,0.7});

	local x,y,z = v1.pos:get();
	local nx,ny,nz = v1.normal:get();
	assert(x == 1 and y == 2 and z == 3 and nx == 0 and ny == 1 and nz == 0);
	x,y,z = v2.pos:get();
	nx,ny,nz = v2.normal:get();
	assert(x == 2 and y == 3 and z == 4 and nx == 0.7 and ny == 0.7 and nz == 0.7);
end