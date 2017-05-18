--[[
Title: TestCSG
Author(s): leio
Date: 2017/5/12
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestCSG.lua");
local TestCSG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCSG");
TestCSG.test_roundedCube();
TestCSG.test_CSGOrthoNormalBasis();
TestCSG.test_translate();
-------------------------------------------------------
--]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGOrthoNormalBasis.lua");
local CSGOrthoNormalBasis = commonlib.gettable("Mod.NplCadLibrary.csg.CSGOrthoNormalBasis");
NPL.load("(gl)script/ide/math/Plane.lua");
local Plane = commonlib.gettable("mathlib.Plane");
NPL.load("(gl)script/ide/math/vector.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
NPL.load("(gl)script/ide/math/Matrix4.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");

local TestCSG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCSG");
--[[
roundedCube({
    center = {0, 0, 0},
    radius = 1,
    roundradius = 0.2,
    resolution = 8,
});
--]]
function TestCSG.test_roundedCube()
    CSG.test_index = 0;
    local options = {
           center = {0, 0, 0},
           radius = 1,
           roundradius = 0.2,
           resolution = 8,
    }
    local csg = CSGFactory.roundedCube(options)

    CSG.saveAsSTL(csg,"test/test_roundedCube.stl",true);
end
function TestCSG.test_CSGOrthoNormalBasis()
    local normal = vector3d:new({0, 1, 0});
    local point = vector3d:new({0, 0, 0});
    local plane = Plane.fromNormalAndPoint(normal, point);
    local orthonormalbasis = CSGOrthoNormalBasis:new()
    orthonormalbasis:init(plane);
    local matrix = orthonormalbasis:getInverseProjectionMatrix();
    --local matrix = orthonormalbasis:getLeftHandProjectionMatrix();
    --local matrix = orthonormalbasis:getProjectionMatrix();
    local depth = 10;
    local cag = CAGFactory.rectangle()
    local csg = cag:extrude({offset = {0, depth, 0}});
    --csg = csg:transform(matrix);

    CSG.saveAsSTL(csg,"test/test_CSGOrthoNormalBasis.stl",true);
end
function TestCSG.test_translate()
    local a = CSGFactory.cube()
    local x = CSGFactory.cube()
    x:translate(vector3d:new({15, 0, 0}));

    local y = CSGFactory.sphere({radius = 2})
    y:translate(vector3d:new({0, 15, 0}));

    local z = CSGFactory.sphere()
    z:translate(vector3d:new({0, 0, 15}));

    

    local csg = a:union(x):union(y):union(z);
    CSG.saveAsSTL(csg,"test/test_translate.stl",true);
end
function TestCSG.test_Plane()
    local normal = vector3d:new(0,1,0); 
    local point = vector3d:new(0,0,0); 
    local plane = Plane.fromNormalAndPoint(normal, point);
    local w = plane[4];

    local planeorigin = normal:MulByFloat(w);
    commonlib.echo("=======planeorigin");
    commonlib.echo(w);
    commonlib.echo(planeorigin);
end
function TestCSG.test_CSGOrthoNormalBasis2()
    local normal = vector3d:new({0, 1, 0});
    local point = vector3d:new({0, 0, 0});
    local plane = Plane.fromNormalAndPoint(normal, point);
    local orthonormalbasis = CSGOrthoNormalBasis:new()
    orthonormalbasis:init(plane);
    
    local vec3 = vector3d:new({3, 3, 3});

    local vec2 = orthonormalbasis:to2D(vec3);

    local result = orthonormalbasis:to3D(vec2);
    commonlib.echo("============test_CSGOrthoNormalBasis2");
    commonlib.echo(orthonormalbasis);
    commonlib.echo(vec3);
    commonlib.echo(vec2);
    commonlib.echo(result);
end
