--[[
Title: TestCSG
Author(s): leio
Date: 2017/5/12
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestCSG.lua");
local TestCSG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCSG");
TestCSG.test_roundedCube();
-------------------------------------------------------
--]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");

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
    local options = {
           center = {0, 0, 0},
           radius = 1,
           roundradius = 0.2,
           resolution = 8,
    }
    local csg = CSGFactory.roundedCube(options)

    CSG.saveAsSTL(csg,"test/test_roundedCube.stl");
end

