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