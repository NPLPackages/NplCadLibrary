polygon({ {0,0},{3,0},{3,3} }); -- openscad like
translate(0,0,4,polygon({ points = { {0,0},{3,0},{3,3},{0,6} }})); 

translate(4,0,0,square());
translate(4,0,4,square(2));
translate(4,0,8,square({size = 1.5}));
translate(4,0,12,square({size = {1,2}}));
translate(4,0,16,square({size = 1, center = true}));
translate(4,0,20,square({size = 1, center = {true,true}}));

translate(8,0,0,circle());                        -- openscad like
translate(8,0,4,circle(1)); 
translate(8,0,8,circle({d= 2, fn=5}));
translate(8,0,12,circle({r= 2, fn=5}));
translate(8,0,16,circle({r= 3, center = true}));    -- center: false (default)
translate(8,0,20,circle({r=3, center = {true, true}}));    -- individual x,z center flags

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

translate(20,0,0,ellipse());
translate(20,0,4,ellipse({center = 1}));
translate(20,0,8,ellipse({center = {1,2}}));
translate(20,0,12,ellipse({radius = 2}));
translate(20,0,16,ellipse({radius = {2,4}}));
translate(20,0,20,ellipse({center = {1,2}, radius = {2,4}}));
