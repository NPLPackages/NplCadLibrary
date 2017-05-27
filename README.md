# NplCadLibrary

## NplCad Programming Guide
 - [Primitives 3D](#primitives-3d)
	* [Cube](#cube)
	* [Sphere](#sphere)
	* [Cylinder](#cylinder)
	* **Todo:** [Torus](#torus)
	* [Polyedron](#polyedron)
	* **Todo:**  [Text](#text)
 - [Transformations 3D](#transformations-3d)
    * [Scale](#scale)
    * [Rotate](#rotate)
    * [Translate](#translate)
    * [Center](#center)
    * **Todo:**  [Matrix Operations](#matrix-operations)
    * **Todo:**  [Mirror](#mirror)
    * [Union](#union)
    * [Intersection](#intersection)
    * [Difference(Subtraction)](#difference)
 - [Primitives 2D](#primitives-2d)
    * [Circle](#circle)
    * [Square](#square)
    * [Rectangle](#rectangle)
    * [Polygon](#polygon)
 - [Transformations 2D](#transformations-2d)
 - [Paths 2D](#paths-2d)
 - **Todo:** [Hull](#hull)
 - **Todo:** [Chain Hull](#chain-hull)
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
cube({size = 1, center = {true,true,false}}); -- individual axis center true or false

roundedCube();-- todo
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

roundedCylinder(); -- todo
```
### Torus
```lua
-- todo
```
### Polyhedron
```lua
polyhedron({ 
         points = {
               {0, -10, 60}, {0, 10, 60}, {0, 10, 0}, {0, -10, 0}, {60, -10, 60}, {60, 10, 60}, 
               {10, -10, 50}, {10, 10, 50}, {10, 10, 30}, {10, -10, 30}, {30, -10, 50}, {30, 10, 50}
               }, 
         triangles = {
                  {0,3,2},  {0,2,1},  {4,0,5},  {5,0,1},  {5,2,4},  {4,2,3},
                  {6,8,9},  {6,7,8},  {6,10,11},{6,11,7}, {10,8,11},
                  {10,9,8}, {3,0,9},  {9,0,6},  {10,6, 0},{0,4,10},
                  {3,9,10}, {3,10,4}, {1,7,11}, {1,11,5}, {1,8,7},  
                  {2,8,1},  {8,2,11}, {5,11,2}
                  }
      });
```
### Text
```lua
-- todo
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
### Matrix Operations
```lua
-- todo
```
### Mirror
```lua
-- todo
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
circle({r=3, center = {true, true}}); -- individual x,z center flags
```
### Square
```lua
translate(4,0,0,square());
translate(4,0,4,square(2));
translate(4,0,8,square({size = 1.5}));
translate(4,0,12,square({size = {1,2}}));
translate(4,0,16,square({size = 1, center = true}));
translate(4,0,20,square({size = 1, center = {true,true}}));
```
### Rectangle
```lua
translate(12,0,0,rectangle());
translate(12,0,4,rectangle({center = 1}));
translate(12,0,8,rectangle({center = {1,2}}));
translate(12,0,12,rectangle({radius = 2}));
translate(12,0,16,rectangle({radius = {2,4}}));
translate(12,0,20,rectangle({center = {1,2}, radius = {2,4}}));

translate(16,0,0,roundedRectangle());
translate(16,0,4,roundedRectangle({center = 1}));
translate(16,0,8,roundedRectangle({center = {1,2}}));
translate(16,0,12,roundedRectangle({radius = 2}));
translate(16,0,16,roundedRectangle({radius = {2,4}}));
translate(16,0,20,roundedRectangle({center = {1,2}, radius = {2,4}}));
translate(16,0,24,roundedRectangle({center = {1,2}, radius = {2,4},roundradius = 1,resolution = 32}));
```
### Polygon
```lua
polygon({ {0,0},{3,0},{3,3} }); -- openscad like
translate(0,0,4,polygon({ points = { {0,0},{3,0},{3,3},{0,6} }})); 
```
## Transformations 2D
```lua
```
## Paths 2D
```lua
local path = path2d({ points = { {0,0},{3,0},{3,3},{0,6} }, closed = false});
translate({1,0,0},expandToCAG(path));
path = path:appendPoint({-1,5});
translate({-3,0,0},expandToCAG(path));
path = path:appendPoints({{-1,4},{-2,3}});
translate({-7,0,0},expandToCAG(path));
local path2 = path2d({ arc = {center={0,0,0},radius=2,startangle=30,endangle= 270,resolution=16,maketangent=false}, closed = false});
translate({2,0,-4},expandToCAG(path2));

local path3 = path2d( {{0,3},{2,2}});
path3 = path3:appendBezier({{0,2},{2,1},{2,0},{0,0},{-2,0},{-2,1}},{resolution =16});
translate({-3,0,-4},expandToCAG(path3));
```
## Hull
```lua
-- todo
```
## Chain Hull
```lua
-- todo
```
## Extruding Extrusion
### Linear Extrude
```lua
translate({5,0,7},linear_extrude(square(1)));
translate({1,0,7},linear_extrude(square(1),{offset = {0,5,0}, twistangle = 360, twiststeps = 100}));
translate({-3,0,7},linear_extrude(square(1),{offset = {1,4,1}, twistangle = 90, twiststeps = 16}));
```
### Rectangular Extrude
```lua
translate({-7,0,0},rectangular_extrude(path,{width = 0.3, height = 0.4, fn = 16}));
path.closed = false;
translate({-11,0,0},rectangular_extrude(path));
```
### Rotate Extrude
```lua
translate({-7,2,7},rotate_extrude(polygon({ {1,0},{0,2},{2,2} })));
translate({-11,2,7},rotate_extrude(polygon({ {1,0},{0,2},{2,2} }),{angle = 270,fn = 12}));
```
## Colors
[svg colors](https://www.w3.org/TR/css3-color/#svg-color)
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
