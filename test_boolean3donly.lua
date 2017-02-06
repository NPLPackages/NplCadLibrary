--[[
    3d元素之间布尔运算时的transform
    1.3d元素自带的offset
    2.3d元素的自节点transform
    3.3d元素针对节点的变换
    4.专门的变换节点
]]
-- 1.3d元素自带的offset
push();
translate(0, 0, 1);
    difference();
        cube({1,2,1});
        cube({0.5,1.5,0.5});
        translate(0.5, 1, 0.5)
            difference();
                cube({0.5,1.5,0.5});
                cube({0.25,1.5,0.25});  
pop();
-- 2.3d元素的自节点transform
push();
translate(0, 0, 3);
    difference();
        cube({size={1,2,1},center = true}):translate(0.5,1,0.5);
        cube({size={0.5,1.5,0.5},center = true}):translate(0.25,0.75,0.25);
        translate(0.5, 1, 0.5)
			difference();
				cube({size={0.5,1.5,0.5},center = true}):translate(0.25,0.75,0.25);
				cube({size={0.25,1.5,0.25},center = true}):translate(0.125,0.75,0.125);
pop();
-- 3.3d元素针对节点的变换
push();
translate(0, 0, 5);
    difference();
        translate(0.5,1,0.5,cube({size={1,2,1},center = true}));
        translate(0.25,0.75,0.25,cube({size={0.5,1.5,0.5},center = true}));
        translate(0.5, 1, 0.5)
			difference();
				translate(0.25,0.75,0.25,cube({size={0.5,1.5,0.5},center = true}));
				translate(0.125,0.75,0.125,cube({size={0.25,1.5,0.25},center = true}));	
pop(); 
-- 4.专门的变换节点
push();
translate(0, 0, 7);
    difference();
        push();
            translate(0.5,1,0.5);
            cube({size={1,2,1},center = true});
        pop();
        push();
            translate(0.25,0.75,0.25);
            cube({size={0.5,1.5,0.5},center = true});
        pop();
        translate(0.5, 1, 0.5)
			difference();
				push();
					translate(0.25,0.75,0.25);
					cube({size={0.5,1.5,0.5},center = true});
				pop();
				push();
					translate(0.125,0.75,0.125);
					cube({size={0.25,1.5,0.25},center = true});
				pop();
pop();  