NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
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
