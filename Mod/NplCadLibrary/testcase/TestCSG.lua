--[[
Title: TestCSG
Author(s): leio
Date: 2017/5/12
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/testcase/TestCSG.lua");
local TestCSG = commonlib.gettable("Mod.NplCadLibrary.testcase.TestCSG");
TestCSG.test_read_cube();
TestCSG.test_stretchAtPlane();
TestCSG.test_read_sphere();
TestCSG.test_read_cylinder();
TestCSG.test_read_torus()
TestCSG.test_read_polyhedron();
TestCSG.test_read_circle();
TestCSG.test_read_ellipse();
TestCSG.test_read_square();
TestCSG.test_read_rectangle();
TestCSG.test_read_roundedRectangle();
TestCSG.test_read_polygon();
TestCSG.test_read_path2d();
TestCSG.test_read_linear_extrude();
TestCSG.test_read_rectangular_extrude();
TestCSG.test_read_rotate_extrude();
TestCSG.test_read_mirror();
TestCSG.test_read_group();
TestCSG.test_read_vector_text();

--TODO:test expandToCAG();
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
    elseif(type == "torus")then
        node = NplCadEnvironment.read_torus(options);
    elseif(type == "polyhedron")then
        node = NplCadEnvironment.read_polyhedron(options)
    elseif(type == "circle")then
        node = NplCadEnvironment.read_circle(options);
    elseif(type == "ellipse")then
        node = NplCadEnvironment.read_ellipse(options);
    elseif(type == "square")then
        node = NplCadEnvironment.read_square(options);
    elseif(type == "rectangle")then
        node = NplCadEnvironment.read_rectangle(options);
    elseif(type == "roundedRectangle")then
        node = NplCadEnvironment.read_roundedRectangle(options);
    elseif(type == "polygon")then
        node = NplCadEnvironment.read_polygon(options);
    elseif(type == "path2d")then
        local path = NplCadEnvironment.path2d(options);
        node = NplCadEnvironment.read_expandToCAG(nil,path)
    elseif(type == "linear_extrude")then
        local shape = options.shape;
        local options = options.options;
        node = NplCadEnvironment.read_linear_extrude(options,shape)    
    elseif(type == "rectangular_extrude")then
        local path = options.path;
        local options = options.options;
        node = NplCadEnvironment.read_rectangular_extrude(options,path)    
    elseif(type == "rotate_extrude")then
        local shape = options.shape;
        local options = options.options;
        node = NplCadEnvironment.read_rotate_extrude(options,shape)    
    elseif(type == "mirror")then
        local plane = options.plane;
        local obj = options.obj;
        NplCadEnvironment.read_mirror(plane,obj);
        node = obj;
    elseif(type == "group")then
        local children = options.children;
        local options = options.options;
        node = NplCadEnvironment.read_group(options,unpack(children));
    elseif(type == "vector_text")then
        local x = options.x;
        local y = options.y;
        local w = options.w;
        local h = options.h;
        local text = options.text;
        local segments = NplCadEnvironment.vector_text(x,y,text);
	    node = Node.create("");
        for __,points in ipairs(segments) do
            local path = NplCadEnvironment.path2d(points);
            local child = NplCadEnvironment.read_rectangular_extrude({w = w, h = h,},path);
            node:addChild(child);
        end
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
--passed
function TestCSG.test_read_cube()
    local options = {
--        {},
        1,
--        {size = 1},
--        {size = { 1, 2, 3 } },
--        {size = 1, center = true, },
--        {size = 1, center = { false, false, false}, },
--        {size = { 1, 2, 3 }, radius = {0.1,0.2,0.3}, round = true, },
--        {size = { 4, 4, 4 }, radius = {1,1,1}, round = true, },
--        {center = { 0, 0, 0}, radius = 0.2, fn = 8, },
    }
    TestCSG.create_objects("cube",options,"test/test_read_cube.stl");
end
--passed
function TestCSG.test_stretchAtPlane()
    local scene = Scene:new();
    local csg = CSGFactory.sphere({radius = 1, resolution = 8});
    local roundradius = {1,2,3};
    csg = csg:scale(roundradius);

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
--passed
function TestCSG.test_read_sphere()
    local options = {
        {},
        1, -- center = true is default
        {r = 2, fn = 100, center = false},
    }
    TestCSG.create_objects("sphere",options,"test/test_read_sphere.stl");
end
--passed
function TestCSG.test_read_cylinder()
    local options = {
        {},
        { r = 1, h = 10, },
        { r = 1, h = 10, center = true, }, --center = false is default
        { r = 1, h = 10, center = {true,true,false}, }, 
        { r = 5, h = 10, round = true, }, 
        { r1 = 3, r2 = 0, h = 10, },
        { d1 = 1, d2 = 0.5, h = 10, },
        { from = {0,0,0}, to = {0,0,10}, r1 = 1, r2 = 2, fn = 50, },
    }
    TestCSG.create_objects("cylinder",options,"test/test_read_cylinder.stl");
end
--passed
function TestCSG.test_read_torus()
    local options = {
        {}, -- ri = 1, ro = 4
        { ri = 1.5, ro = 3, },
        { ri = 0.2 },
        { fni = 4,  },  -- make inner circle fn = 4 => square
        { fni = 4, roti = 45, },
        { fni = 4, fno = 4, roti = 45, },
        { fni = 4, fno = 5, roti = 45, },
    }
    TestCSG.create_objects("torus",options,"test/test_read_torus.stl");
end
--passed
function TestCSG.test_read_polyhedron()
    local options = {
        {
            points = { { 0,0,0 }, { 2,0,0 }, { 2,2,0 } },
            triangles = { { 1,2,3 } } -- first index is 1 in lua table
        },
        {
            points = { { 10,10,0 }, { 10,-10,0 }, { -10,-10,0 }, { -10,10,0 }, -- the four points at base
                { 0,0,10 } },                                           -- the apex point 
            triangles = { { 1,2,5 }, { 2,3,5 }, { 3,4,5 }, { 4,1,5 },          -- each triangle side
                    { 2,1,4 },{ 3,2,4 } }                                       -- two triangles for square base
        },
    }
    TestCSG.create_objects("polyhedron",options,"test/test_read_polyhedron.stl");
end
--passed
function TestCSG.test_read_circle()
    local options = {
        2,
        {2},
        { r = 2, fn = 5, },
        { r = 3, center = true, } -- center = false is default
    }
    TestCSG.create_objects("circle",options,"test/test_read_circle.stl");
end
--passed
function TestCSG.test_read_ellipse()
    local options = {
        {},
        {center = {1,2}, },
        {r = 2},
        {r = {1,2}, },
        {center = {1,2}, r = {1,2}, },
    }
    TestCSG.create_objects("ellipse",options,"test/test_read_ellipse.stl");
end
--passed
function TestCSG.test_read_square()
    local options = {
        {},
        2,
        {2,3},
        { size = { 2, 2 }, center = true, }
    }
    TestCSG.create_objects("square",options,"test/test_read_square.stl");
end
--passed
function TestCSG.test_read_rectangle()

    local options = {
        { center = {0,0}, r = {1,2}, },
    }
    TestCSG.create_objects("rectangle",options,"test/test_read_rectangle.stl");

end
--passed
function TestCSG.test_read_roundedRectangle()
    local options = {
        { center = {0,0}, r = {1,2}, roundradius = 1, resolution = 16, },
    }
    TestCSG.create_objects("roundedRectangle",options,"test/test_read_roundedRectangle.stl");
end

--passed
function TestCSG.test_read_polygon()
    local options = {
        { {0,0},{3,0},{3,3} },
        { points = { {0,0},{3,0},{3,3} } },
        { points = { {0,0},{3,0},{3,3},{0,6} }, paths = { {1,2,3},{2,3,4} } }, -- note: start index is 1 in lua table
    }
    TestCSG.create_objects("polygon",options,"test/test_read_polygon.stl");
end
--passed
function TestCSG.test_read_path2d()
    local options = {
        --{ {0,0},{3,0},{3,3} },
		{ points = { {0,0},{3,0},{3,3},{0,6} } },
		--{ arc = {center={0,0,0},radius=1,startangle=0,endangle= 360,resolution=32,maketangent=false}},
    }
    TestCSG.create_objects("path2d",options,"test/test_read_path2d.stl");
end
--passed
function TestCSG.test_read_linear_extrude()
    local options = {
        {
            shape = NplCadEnvironment.read_square( { size = { 3, 3 }, center = true, }),
            options = { offset = { 0, 0, 10 }, twistangle = 360, twiststeps = 100, },
        },
--        {
--            shape = NplCadEnvironment.read_rectangle( { center = {0,0}, r = {3,3}, }),
--            options = { offset = { 0, 0, 10 }, twistangle = 360, twiststeps = 100, },
--        },
--        {
--            shape = NplCadEnvironment.read_roundedRectangle( { center = {0,0}, r = {3,3}, }),
--            options = { offset = { 0, 0, 10 }, twistangle = 360, twiststeps = 100, },
--        },
--        {
--            shape = NplCadEnvironment.read_circle({ r = 3, center = true, }),
--            options = { offset = { 0, 0, 10 }, twistangle = 360, twiststeps = 100, },
--        },
    }
    TestCSG.create_objects("linear_extrude",options,"test/test_read_linear_extrude.stl");
end
-- passed
function TestCSG.test_read_rectangular_extrude()
    local options = {
--        {
--            path = NplCadEnvironment.path2d({ points = { {0,0},{3,0},{3,3} }, }),
--            options = { w = 1, h = 0.2, fn = 64 },
--        },
        {
            path = NplCadEnvironment.path2d({ points = { {0,0},{3,0},{3,3},{0,6} } ,closed = true  } ),
            options = { w = 0.1, h = 0.2, fn = 64 },
        },
    }
    TestCSG.create_objects("rectangular_extrude",options,"test/test_read_rectangular_extrude.stl");
end
--passed
function TestCSG.test_read_rotate_extrude()
    local options = {
--        {
--            shape = NplCadEnvironment.read_square( { size = { 3, 3 }, }),
--            options = { offset = {10,0,0}, fn = 5, },
--        },
--        {
--            shape = NplCadEnvironment.read_rectangle(),
--            options = { offset = {10,0,0}, fn = 160, },
--        },
--        {
--            shape = NplCadEnvironment.read_roundedRectangle(),
--            options = { offset = {10,0,0}, fn = 250, },
--        },
        {
            shape = NplCadEnvironment.read_circle( { r = 3, }),
            options = { offset = {10,0,0}, fn = 36, },
        },
--        {
--            shape = NplCadEnvironment.read_polygon({ points = { {0,0},{3,0},{3,3} } }),
--            options = { offset = {10,0,0}, fn = 160, },
--        },
    }
    TestCSG.create_objects("rotate_extrude",options,"test/test_read_rotate_extrude.stl");
end
--passed
function TestCSG.test_read_mirror()
    local options = {
        {
            obj = NplCadEnvironment.read_cube(1),
            plane = {10,20,90},
        },
    }
    TestCSG.create_objects("mirror",options,"test/test_read_mirror.stl");
end
--passed
function TestCSG.test_read_group()
    local options = {
        {
            options = { attach = false, action = "difference", }, -- union/difference/intersection, default is union.
            children = {
                NplCadEnvironment.read_square({size = { 1, 4 }, center = true, attach = false,}),             
                NplCadEnvironment.read_circle({ r = 1, center = true, attach = false, }),             
            }
        },
    }
    TestCSG.create_objects("group",options,"test/test_read_group.stl");
end
--passed
function TestCSG.test_read_vector_text()
    local options = {
        { w = 2, h = 2, x = 0, y = 0, text = "Hello NPL!", },
    }
    TestCSG.create_objects("vector_text",options,"test/test_vector_text.stl");
end