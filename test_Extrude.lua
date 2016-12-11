local path = path2d({{0,0},{3,0},{3,3},{0,6}});

-- path innerToCAG
path.closed = true;
translate({5,0,0},innerToCAG(path)); 

-- path expandToCAG
path.closed = false;
translate({1,0,0},expandToCAG(path));
path.closed = true;
translate({-3,0,0},expandToCAG(path,{pathradius = 0.2, fn = 8}));

-- path rectangularExtrude
translate({-7,0,0},rectangularExtrude(path,{width = 0.3, height = 0.4, fn = 16}));
path.closed = false;
translate({-11,0,0},rectangularExtrude(path));

-- 2d shape linearExtrude
translate({5,0,7},linearExtrude(square(1)));
translate({1,0,7},linearExtrude(square(1),{offset = {0,5,0}, twistangle = 360, twiststeps = 100}));
translate({-3,0,7},linearExtrude(square(1),{offset = {1,4,1}, twistangle = 90, twiststeps = 16}));

-- 2d shape rotateExtrude
translate({-7,2,7},rotateExtrude(polygon({ {1,0},{0,2},{2,2} })));
translate({-11,2,7},rotateExtrude(polygon({ {1,0},{0,2},{2,2} }),{angle = 270,fn = 12}));