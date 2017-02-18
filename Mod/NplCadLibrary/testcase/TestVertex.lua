NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");

local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestVertex = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestVertex"));

function TestVertex.test_init()
	local pos =  TestFrame.randomVector3d();
	local normal = TestFrame.randomNormal3d();
	local v1 = CSGVertex:new():init(pos,normal);
	assert(v1.pos:equals(pos,tonumber("1e-5")) and v1.normal:equals(normal,tonumber("1e-5")));
end
function TestVertex.test_clone()
	local pos =  TestFrame.randomVector3d();
	local normal = TestFrame.randomNormal3d();
	local v1 = CSGVertex:new():init(pos,normal);
	local v2 = v1:clone();
	assert(v1.pos:equals(v2.pos,tonumber("1e-5")) and v1.normal:equals(v2.normal,tonumber("1e-5")));
end
function TestVertex.test_clone()
	local pos =  TestFrame.randomVector3d();
	local normal = TestFrame.randomNormal3d();
	local v1 = CSGVertex:new():init(pos,normal);
	local v2 = v1:clone();
	assert(v1:equals(v2,tonumber("1e-5")));

	local v3 = CSGVertex:new():init(pos,nil);
	local v4 = v3:clone();
	assert(v3:equals(v4,tonumber("1e-5")));
end
function TestVertex.test_flip()
	local pos =  TestFrame.randomVector3d();
	local normal = TestFrame.randomNormal3d();
	local v1 = CSGVertex:new():init(pos,normal);
	v1:flip();
	assert(v1.pos:equals(pos,tonumber("1e-5")) and v1.normal:equals(normal:negated(),tonumber("1e-5")));
end
function TestVertex.test_interpolate()
	local pos1 =  TestFrame.randomVector3d();
	local normal1 = TestFrame.randomNormal3d();
	local v1 = CSGVertex:new():init(pos1,normal1);

	local pos2 =  TestFrame.randomVector3d();
	local normal2 = TestFrame.randomNormal3d();
	local v2 = CSGVertex:new():init(pos2,normal2);

	t = math.random();
	v1:interpolate(v2,t);

	pos1:interpolate(pos2,t);
	normal1:interpolate(normal2,t);

	assert(v1.pos:equals(pos1,tonumber("1e-5")) and v1.normal:equals(normal1,tonumber("1e-5")));
end	