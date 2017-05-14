--[[
Title: TestCAG
Author(s): leio
Date: 2017/5/14
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestCAG.lua");
local TestCAG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCAG");
TestCAG.test_rectangle();
-------------------------------------------------------
--]]
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");

local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");

local TestCAG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCAG");
function TestCAG.test_rectangle()
    local cag = CAGFactory.rectangle()
    commonlib.echo("========cag");
    commonlib.echo(cag);
    local csg = cag:toCSG(10);
    CSG.saveAsSTL(csg,"test/test_rectangle.stl");
end


