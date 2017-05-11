--[[
    2d元素之间布尔运算时的2d transform 在Shape之间进行，运算结果仍为shape.
    1.2d元素自带的offset
    2.2d元素的自节点transform
    3.2d元素针对节点的变换
    4.专门的变换节点
]]

-- finally do a 3d rotation
rotate({0,0,-45});

-- 1.2d元素自带的offset
push();
translate(0, 0, 1);
    difference();
        square({1,1});
        square({0.5,0.5});
        translate(0.5, 0.5)
            difference();
                square({0.5,0.5});
                square({0.25,0.25});  
pop();
-- 2.2d元素的自节点transform
push();
translate(0, 0, 3);
    difference();
        square({size={1,1},center = true}):translate(0.5, 0.5);
        square({size={0.5,0.5},center = true}):translate(0.25, 0.25);
        translate(0.5, 0.5)
			difference();
				square({size={0.5,0.5},center = true}):translate(0.25, 0.25);
				square({size={0.25,0.25},center = true}):translate(0.125, 0.125);
pop();
-- 3.2d元素针对节点的变换
push();
translate(0, 0, 5);
    difference();
        translate(0.5,0.5,square({size={1,1},center = true}));
        translate(0.25,0.25,square({size={0.5,0.5},center = true}));
        translate(0.5, 0.5)
			difference();
				translate(0.25,0.25,square({size={0.5,0.5},center = true}));
				translate(0.125,0.125,square({size={0.25,0.25},center = true}));	
pop(); 
-- 4.专门的变换节点
push();
translate(0, 0, 7);
    difference();
        push();
            translate(0.5, 0.5);
            square({size={1,1},center = true});
        pop();
        push();
            translate(0.25, 0.25);
            square({size={0.5,0.5},center = true});
        pop();
        translate(0.5, 0.5)
			difference();
				push();
					translate(0.25, 0.25);
					square({size={0.5,0.5},center = true});
				pop();
				push();
					translate(0.125, 0.125);
					square({size={0.25,0.25},center = true});
				pop();
pop();  