# NplCadLibrary

## NplCad Programming Guide
 - [Primitives 3D](#primitives-3d)
	* [Cube](#cube)
	* [Sphere](#sphere)
	* [Cylinder](#cylinder)
	* [Torus](#torus)
	* [Polyhedron](#polyhedron)
	* [Text](#text)
 - [Transformations 3D](#transformations-3d)
    * [Scale](#scale)
    * [Rotate](#rotate)
    * [Translate](#translate)
    * [Center](#center)
    * [Mirror](#mirror)
    * [Union](#union)
    * [Intersection](#intersection)
    * [Difference(Subtraction)](#difference)
 - [Primitives 2D](#primitives-2d)
    * [Circle](#circle)
    * [Ellipse](#ellipse)
    * [Square](#square)
    * [Rectangle](#rectangle)
    * [Polygon](#polygon)
 - [Transformations 2D](#transformations-2d)
 - [Paths 2D](#paths-2d)
 - [Group](#group)
 - [Extruding / Extrusion](#extruding-extrusion)
   * [Linear Extrude](#linear-extrude)
   * [Rectangular Extrude](#rectangular-extrude)
   * [Rotate Extrude](#rotate-extrude)
 - [Colors](#colors)
 - [Log](#log)
 - [Mathematical Functions](#mathematical-functions)
 - [Including Files](#including-files)
 - [Interactive Parametric Models](#interactive-parametric-models)
 - [Scene Node Tags](#scene-node-tags)
 - [Screenshot](#screenshot)
## Primitives 3D
### Cube
```lua
cube(); 
cube(1);
cube({size = 1});
cube({size = {1,2,3}});
cube({size = 1, center = true}); -- default center:false
cube({size = 1, center = {false,false,false}}); -- individual axis center true or false
cube({size = {1,2,3}, round = true, }); -- round cube
cube({size = {4,4,4}, radius = {1,1,1},}); -- round cube
cube({size = {1,2,3}, radius = 0.2, fn = 8, }); -- round cube
```
### Sphere
```lua
sphere();                          
sphere(1);
sphere({r = 2});                    -- Note: center = true is default 
sphere({r = 2, center = false});    
sphere({r = 2, center = {true, true, false}}); -- individual axis center 
sphere({r = 2, fn = 100 });
```
### Cylinder
```lua
cylinder({r = 1, h = 10});                 
cylinder({d = 1, h = 10});
cylinder({r = 1, h = 10, center = true});   -- default: center = false
cylinder({r = 1, h = 10, center = {true, true, false}});  -- individual x,y,z center flags
cylinder({r1 = 3, r2 = 0, h = 10});
cylinder({d1 = 1, d2 = 0.5, h = 10});
cylinder({from = {0,0,0}, to = {0,0,10}, r1 = 1, r2 = 2, fn = 50});
cylinder({r1 = 3, r2 = 0, h = 10, round = true, });
cylinder({r = 1, h = 10, round = true, fn = 16}); -- round cylinder
```
### Torus
- ri = inner radius (default: 1)
- ro = outer radius (default: 4)
- fni = inner resolution (default: 16)
- fno = outer resolution (default: 32)
- roti = inner rotation (default: 0)
```lua
torus(); -- ri = 1, to = 4
torus({ ri = 1.5, ro = 3, });
torus({ ri = 0.2 });
torus({ fni = 4,  }); -- make inner circle fn = 4 => square
torus({ fni = 4, roti = 45, });
torus({ fni = 4, fno = 4, roti = 45, });
torus({ fni = 4, fno = 5, roti = 45, });
```
### Polyhedron
```lua
polyhedron();
polyhedron({
    points = { { 0,0,0 }, { 2,0,0 }, { 2,2,0 } },
    triangles = { { 1,2,3 } }       -- first index is 1 in lua table                             
});
polyhedron({
    points = { { 10,10,0 }, { 10,-10,0 }, { -10,-10,0 }, { -10,10,0 }, -- the four points at base
                { 0,0,10 } },                                           -- the apex point 
    triangles = { { 1,2,5 }, { 2,3,5 }, { 3,4,5 }, { 4,1,5 },          -- each triangle side
            { 2,1,4 },{ 3,2,4 } }                                       -- two triangles for square base
});
```
### Text
```lua
local segments = vector_text(0,0,"Hello NPL");
local k,points;
for k,points in ipairs(segments) do
    rectangular_extrude({ w = 3, h = 1, }, path2d(points));
end
```
## Transformations 3D
### Scale
```lua
scale(2); --create a new parent node and set scale value          
scale(2,obj); --set scale value with obj          
scale({1,2,3}); --create a new parent node and set scale value          
scale({1,2,3},obj); --set scale value with obj  
```
### Rotate
```lua
rotate(2);	--create a new parent node and set rotation value          
rotate(2,obj);	--set rotation value with obj          
rotate({1,2,3}); --create a new parent node and set rotation value          
rotate({1,2,3},obj); --set rotation value with obj  
```
### Translate
```lua
translate({0,0,10}); --create a new parent node and set translation value 
translate({0,0,10},obj);	--set translation value with obj  
```
### Mirror
```lua
mirror({1,0,0},cube(1));
mirror({10,20,90},cube(1));
```
### Union
```lua
union();
```
### Intersection
```lua
intersection();
```
### Difference
```lua
difference();
```
## Primitives 2D
### Circle
```lua
circle(); -- openscad like
circle(1); 
circle({d= 2, fn=5});
circle({r= 2, fn=5});
circle({r= 3, center = true}); -- center: false (default)
```
### Ellipse
```lua
ellipse();
ellipse({center = {1,2}});
ellipse({r = 2});
ellipse({r = {1,2}});
ellipse({center = {1,2}, r = {1,2}, });
```
### Square
```lua
square();
square(1); -- 1x1
square({2,3}); -- 2x3
square({size = {2,4}, center = true}); --2x4, center = false is default
```
### Rectangle
```lua
rectangle();
rectangle({center = 1});
rectangle({center = {1,2}});
rectangle({r = 2});
rectangle({r = {2,4}});
rectangle({center = {1,2}, r = {2,4}});

roundedRectangle();
roundedRectangle({center = 1});
roundedRectangle({center = {1,2}});
roundedRectangle({r = 2});
roundedRectangle({r = {2,4}});
roundedRectangle({center = {1,2}, r = {2,4}});
roundedRectangle({center = {1,2}, r = {2,4},roundradius = 1,resolution = 32});
```
### Polygon
```lua
polygon({ {0,0},{3,0},{3,3} }); -- openscad like
polygon({ points = { {0,0},{3,0},{3,3},{0,6} }});
polygon({ points = { {0,0},{3,0},{3,3},{0,6} }, paths = { {1,2,3},{2,3,4} } }); -- note: start index is 1 in lua table
```
## Transformations 2D
```lua
```
## Paths 2D
```lua
local path = path2d({ points = { {0,0},{3,0},{3,3},{0,6} }, closed = false});
translate({1,0,0},expandToCAG(0.1,path));
path = path:appendPoint({-1,5});
translate({-3,0,0},expandToCAG(0.1,path));
path = path:appendPoints({{-1,4},{-2,3}});
translate({-7,0,0},expandToCAG(0.1,path));
local path2 = path2d({ arc = {center={0,0,0},radius=2,startangle=30,endangle= 270,resolution=16,maketangent=false}, closed = false});
translate({2,0,-4},expandToCAG(0.1,path2));

local path3 = path2d( {{0,3},{2,2}});
path3 = path3:appendBezier({{0,2},{2,1},{2,0},{0,0},{-2,0},{-2,1}},{resolution =16});
translate({-3,0,-4},expandToCAG(0.1,path3));
```
## Group
```lua
local a = square({size = { 1, 4 }, center = true, attach = false,});
local b = circle({ r = 1, center = true, attach = false, });
local c = circle({ r = 0.5, center = true, attach = false, });

local node1 = group({attach = false, action = "union", },a,b) -- union/difference/intersection, default is union.
local node2 = group({attach = false, action = "difference", },node1,c)
linear_extrude({ offset = { 0, 0, 10 }, twistangle = 360, twiststeps = 100, },node2);
```
## Extruding Extrusion
### Linear Extrude
```lua
linear_extrude({ offset = {0,0,10} , } ,square({ size = { 2, 2 }, center = true, attach = false, }));
linear_extrude({ offset = {0,0,10} , twistangle = 180, twiststeps = 100, } , square({ size = { 2, 2 }, center = true, attach = false, }));
linear_extrude({ offset = {0,0,10} , twistangle = 360, twiststeps = 100, } , rectangle({ center = {0,0}, r = {1,1}, attach = false, }));
linear_extrude({ offset = {0,0,10} , twistangle = 360, twiststeps = 100, } , roundedRectangle({ center = {0,0}, r = {1,1}, attach = false, }));
linear_extrude({ offset = {0,0,10} , twistangle = 360, twiststeps = 100, } , circle({ r = 1, center = true, attach = false, }));
linear_extrude({ offset = {0,0,10} } , ellipse({ r = {2,4}, attach = false, }));
linear_extrude({ offset = {0,0,10}, } , polygon({ points = { {0,0},{3,0},{3,3},{0,6} }, attach = false, }));
```
### Rectangular Extrude
```lua
rectangular_extrude({ w = 1, h = 0.2, fn = 64 },path2d({ points = { {0,0},{3,0},{3,3} }, }));
rectangular_extrude({ w = 0.1, h = 0.2, fn = 64 },path2d({ points = { {0,0},{3,0},{3,3},{0,6} } ,closed = true  } ));
```
### Rotate Extrude
```lua
rotate_extrude({ offset = {4,0,0} , fn = 12, } ,square({ size = { 2, 2 }, attach = false, }));
rotate_extrude({ offset = {4,0,0}, fn = 160, } ,rectangle({ attach = false, }));
rotate_extrude({ offset = {4,0,0}, fn = 220, } ,roundedRectangle({ attach = false, }));
rotate_extrude({ offset = {4,0,0}, } ,circle({r = 1, fn = 30, center = true, attach = false, }));
rotate_extrude({ offset = {4,0,0}, fn = 160, } ,polygon({ points = { {0,0},{3,0},{3,3} }, attach = false, }));
```
## Colors
Color by names: [svg colors](https://www.w3.org/TR/css3-color/#svg-color)
```lua
color("red")
color({255/255,0,0})
color({r,g,b});		--create a new parent node and set color value 
color({r,g,b},obj);     --set color value with obj 
color(color_name);	--create a new parent node and set color value with color name
color(color_name,obj)	--set color value with obj 
```
## Log
```lua
log("Hello Npl Cad.");
```
## Mathematical Functions
[MathLibraryTutorial](http://lua-users.org/wiki/MathLibraryTutorial)
```lua
math.abs
math.acos
math.asin
math.atan
math.ceil
math.cos
math.deg
math.exp
math.floor
math.fmod
math.huge
math.log
math.max
math.maxinteger
math.min
math.mininteger
math.modf
math.pi
math.rad
math.random
math.randomseed
math.sin
math.sqrt
math.tan
math.tointeger
math.type
math.ult
```
## Including Files
```lua
include("a.npl")
include("b/c.npl")
```
## Interactive Parametric Models
```lua
defineProperty({
    { name =  'key_group',		type =  'group',		caption =  'Group' }, 
    { name =  'key_choice',		type =  'choice',		caption = 'Choice:', values = {0, 1}, initial = 1, captions = {"No", "Yes"} },
    { name =  'key_text',		type =  'text',			initial =  '', size =  20, maxLength =  20, caption =  'Text', placeholder =  '20 characters' }, 
    { name =  'key_int',		type =  'int',			initial =  20, min =  1, max =  100, step =  1, caption =  'Int' }, 
    { name =  'key_float',		type =  'float',		initial =  0, caption =  'Float' }, 
    { name =  'key_checkbox',	type =  'checkbox',		checked =  true, initial =  '20', caption =  'Checkbox' }, 
    { name =  'key_color',		type =  'color',		initial =  '#FFB431', caption =  'Color' }, 
    { name =  'key_date',		type =  'date',			initial =  '', min =  '1915-01-01', max =  '2015-12-31', caption =  'Date', placeholder =  'YYYY-MM-DD' }, 
    { name =  'key_email',		type =  'email',		initial =  '', caption =  'Email' }, 
    { name =  'key_password',	type =  'password',		initial =  '', caption =  'Password' }, 
    { name =  'key_url',		type =  'url',			initial =  '', caption =  'Url' }, 
    { name =  'key_slider',		type =  'slider',		initial =  3, min =  1, max =  10, step =  1, caption =  'Slider' }, 
});
```
## Scene Node Tags
|Name|Value|Desc|
|:----:|:----:|:----:|
|csg_action|union/intersection/difference
|color|{r,g,b}|
## Screenshot
![image](https://cloud.githubusercontent.com/assets/5885941/26521519/cae75e9c-431c-11e7-916d-792a5df72092.png)
