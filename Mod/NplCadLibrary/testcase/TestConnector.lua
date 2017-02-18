NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGConnector.lua");

local CSGConnector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnector");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestConnector = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestConnector"));

function TestConnector.test_Init()
	local point =  TestFrame.randomVector3d();
	local axisvector = TestFrame.randomVector3d();
	local normalvector = TestFrame.randomVector3d();
	local connector = CSGConnector:new():init(point,axisvector,normalvector);
	assert(connector.point:equals(point,tonumber("1e-5")));
	assert(connector.axisvector:equals(axisvector:normalize(),tonumber("1e-5")));
	assert(connector.normalvector:equals(normalvector:normalize(),tonumber("1e-5")));
end

function TestConnector.test_Clone()
	local point =  TestFrame.randomVector3d();
	local axisvector = TestFrame.randomVector3d();
	local normalvector = TestFrame.randomVector3d();
	local connector = CSGConnector:new():init(point,axisvector,normalvector);
	local connector2 = connector:clone();
	assert(connector.point:equals(connector2.point,tonumber("1e-5")));
	assert(connector.axisvector:equals(connector2.axisvector,tonumber("1e-5")));
	assert(connector.normalvector:equals(connector2.normalvector,tonumber("1e-5")));
end
function TestConnector.test_normalized()
	local point =  TestFrame.randomVector3d();
	local axisvector = TestFrame.randomVector3d();
	local normalvector = TestFrame.randomVector3d();
	local connector = CSGConnector:new():init(point,axisvector,normalvector);
	connector:normalize();
	assert(connector.point:equals(point),tonumber("1e-5"));
	assert(connector.axisvector:equals(axisvector:normalize(),tonumber("1e-5")));
	local dot = connector.normalvector:dot(connector.axisvector);
	assert(TestFrame.numberIsZero(dot));
end
function TestConnector.test_transform()
	local point =  TestFrame.randomVector3d();
	local axisvector = TestFrame.randomVector3d();
	local normalvector = TestFrame.randomVector3d();
	local matrix = TestFrame.randomMatrix();

	local connector = CSGConnector:new():init(point,axisvector,normalvector);
	connector:transform(matrix);

	point:transform(matrix);
	axisvector:transform_normal(matrix):normalize();
	normalvector:transform_normal(matrix):normalize();
	local connector2 = CSGConnector:new():init(point,axisvector,normalvector);

	assert(connector.point:equals(connector2.point,tonumber("1e-5")));
	assert(connector.axisvector:equals(connector2.axisvector,tonumber("1e-5")));
	assert(connector.normalvector:equals(connector2.normalvector,tonumber("1e-5")));
end
function TestConnector.test_getTransformationTo()
	local point =  TestFrame.randomVector3d();
	local axisvector = TestFrame.randomVector3d();
	local normalvector = TestFrame.randomVector3d();
	local matrix = TestFrame.randomMatrix();

	local connector = CSGConnector:new():init(point,axisvector,normalvector);
	connector:normalize();

	local connector2 = connector:clone();
	connector2:transform(matrix);

	local transform = connector:getTransformationTo(connector2);
	-- todo 
end
function TestConnector.test_axisLine()
	local point =  TestFrame.randomVector3d();
	local axisvector = TestFrame.randomVector3d();
	local normalvector = TestFrame.randomVector3d();
	local connector = CSGConnector:new():init(point,axisvector,normalvector);
	connector:normalize();
	
	local axis = connector:axisLine();
	assert(axis.point:equals(connector.point,tonumber("1e-5")));
	assert(axis.direction:equals(connector.axisvector,tonumber("1e-5")));
end
function TestConnector.test_extend()
	local point =  TestFrame.randomVector3d();
	local axisvector = TestFrame.randomVector3d();
	local normalvector = TestFrame.randomVector3d();
	local connector = CSGConnector:new():init(point,axisvector,normalvector);
	connector:normalize();

	local dis = math.random() * 100;
	local connector2 = connector:extend(dis);
	local newpoint = connector.point + connector.axisvector * dis;
	assert(connector2.normalvector:equals(connector.normalvector,tonumber("1e-5")));
	assert(connector2.axisvector:equals(connector.axisvector,tonumber("1e-5")));
	assert(connector2.point:equals(newpoint,tonumber("1e-5")));
end
