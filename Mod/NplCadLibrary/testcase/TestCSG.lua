--[[
Title: TestCSG
Author(s): leio
Date: 2017/5/12
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestCSG.lua");
local TestCSG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCSG");
TestCSG.test_read_cube();
TestCSG.test_read_square();
-------------------------------------------------------
--]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/CSGService.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Scene.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");
local Plane = commonlib.gettable("mathlib.Plane");
local vector3d = commonlib.gettable("mathlib.vector3d");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");
local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local Scene = commonlib.gettable("Mod.NplCadLibrary.core.Scene");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");


local TestCSG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCSG");

function TestCSG.create_objects(type,options,filename)
    local scene = Scene:new();
    if(not options)then
        return
    end
    local k,v;
    local last_x, last_y, last_z = 0, 0, 0;
    for k, v in ipairs(options) do
        last_x, last_y, last_z = TestCSG.create(type, v, scene, k - 1, last_x, last_y, last_z);
    end
    CSGService.saveAsSTL(scene,filename);
end
function TestCSG.create(type, options, scene, index, last_x, last_y, last_z, stride, gap)
    stride = stride or 5
    local i = math.mod(index,stride)
    gap = gap or 2;
    last_x = last_x or 0;
    last_y = last_y or 0;
    last_z = last_z or 0;
    local node;
    if(type == "cube")then
        node = NplCadEnvironment.read_cube(options);
    elseif(type == "sphere")then
        node = NplCadEnvironment.read_sphere(options);
    elseif(type == "cylinder")then
        node = NplCadEnvironment.read_cylinder(options);
    elseif(type == "square")then
        node = NplCadEnvironment.read_square(options);
    end
    local next_x;
    if(index ~= 0)then
        next_x = last_x + gap;
    else
        next_x = last_x;
    end
    local next_y = last_y; 
    if(index ~= 0 and i == 0)then
        next_x = 0;
        next_y = next_y + gap;
    end
    local next_z = last_z ;

    
    node:translate(next_x,next_y,next_z);
    scene:addChild(node);
    return next_x,next_y,next_z;
end
function TestCSG.test_read_cube()
    local options = {
--        {},
--        1,
--        {size = 1},
--        {size = { 1, 2, 3 } },
--        {size = 1, center = true, },
--        {size = 1, center = { false, false, false}, },
        {size = { 1, 2, 3 }, radius = {0.1,0.5,0.1}, round = true, },
--        { center = { 0, 0, 0}, radius = 0.2, fn = 8, },
--        { corner1 = { 0, 0, 0}, corner2 = { 5, 4, 2 }, },

    }
    TestCSG.create_objects("cube",options,"test/test_read_cube.stl");
end
function TestCSG.test_stretchAtPlane()
    local scene = Scene:new();
    local csg = CSGFactory.sphere({radius = 1, resolution = 8});
    local roundradius = {1,2,3};
    --csg = csg:scale(roundradius);

    local innerradius = {3,4,5};
    csg = csg:stretchAtPlane(vector3d:new({1, 0, 0}), vector3d:new({0, 0, 0}), 2*innerradius[1]);
    csg = csg:stretchAtPlane(vector3d:new({0, 1, 0}), vector3d:new({0, 0, 0}), 2*innerradius[2]);
    csg = csg:stretchAtPlane(vector3d:new({0, 0, 1}), vector3d:new({0, 0, 0}), 2*innerradius[3]);

	local node = Node.create("");
    local o = CSGModel:new():init(csg);

    node:setDrawable(o);
    scene:addChild(node);

    CSGService.saveAsSTL(scene,"test/test_stretchAtPlane.stl");
end
function TestCSG.test_read_sphere()
    local scene = Scene:new();
    
    local node_1 = NplCadEnvironment.read_sphere({});
    scene:addChild(node_1);
    CSGService.saveAsSTL(scene,"test/test_read_sphere.stl",true);
end

function TestCSG.test_read_cylinder()
    local scene = Scene:new();
    local node = NplCadEnvironment.read_cylinder({ r1 = 3, r2 = 0, h = 10});
    scene:addChild(node);
    CSGService.saveAsSTL(scene,"test/test_read_cylinder.stl",true);
end
--passed
function TestCSG.test_read_square()
    local options = {
    {},
    {1,2}
    }
    TestCSG.create_objects("square",options,"test/test_read_square.stl");
end
--passed
function TestCSG.test_rectangle_extrude()
    local scene = Scene:new();
    local cag = CAGFactory.rectangle(options)
    local csg = cag:extrude({offset = {0,0,10}, twistangle = 360, twiststeps = 100, });

	local node = Node.create("");
    local o = CSGModel:new():init(csg,"rectangular_extrude");
    node:setDrawable(o);
    node:setTag("shape","rectangular_extrude");
    scene:addChild(node);

    CSGService.saveAsSTL(scene,"test/test_rectangle_extrude.stl");
end


