--[[
Title: TestCSG
Author(s): leio
Date: 2017/5/12
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestCSG.lua");
local TestCSG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCSG");
TestCSG.test_read_cube();
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
    CSGService.saveAsSTL(scene,filename,true);
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
    end
    local next_x;
    if(index ~= 0)then
        next_x = last_x + gap;
    else
        next_x = last_x;
    end
    local next_y = last_y ;
    local next_z = last_z ;
    if(index ~= 0 and i == 0)then
        next_x = 0;
        next_z = next_z + gap;
    end
    node:translate(next_x,next_y,next_z);
    scene:addChild(node);
    return next_x,next_y,next_z;
end
function TestCSG.test_read_cube()
    local options = {
        {},
        1,
        {size = 1},
        {size = { 1, 2, 3 } },
        {size = 1, center = true, },
        {size = 1, center = { false, false, false}, },
        {size = { 1, 2, 3 }, round = true, },
        { center = { 0, 0, 0}, radius = 0.2, fn = 8, },
        { corner1 = { 0, 0, 0}, corner2 = { 5, 4, 2 }, },

    }
    TestCSG.create_objects("cube",options,"test/test_read_cube.stl");
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
