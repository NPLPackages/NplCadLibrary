local path = path2d({{0,0},{3,0},{3,3},{0,6}});

-- path innerToCAG
path.closed = true;
translate({5,0,0},innerToCAG(path)); 

-- path expandToCAG
path.closed = false;
translate({1,0,0},expandToCAG(nil,path));
path.closed = true;
translate({-3,0,0},expandToCAG({pathradius = 0.2, fn = 8}, path));

-- path rectangular_extrude
translate({-7,0,0},rectangular_extrude({width = 0.3, height = 0.4, fn = 16},path));
path.closed = false;
translate({-11,0,0},rectangular_extrude(nil,path));

-- 2d shape linear_extrude
translate({5,0,7},linear_extrude(nil,square(1)));
translate({1,0,7},linear_extrude({offset = {0,5,0}, twistangle = 360, twiststeps = 100},square(1)));
translate({-3,0,7},linear_extrude({offset = {1,4,1}, twistangle = 90, twiststeps = 16},square(1)));

-- 2d shape rotate_extrude
translate({-7,2,7},rotate_extrude(nil,polygon({ {1,0},{0,2},{2,2} })));
translate({-11,2,7},rotate_extrude(nil,polygon({ {1,0},{0,2},{2,2} }),{angle = 270,fn = 12}));