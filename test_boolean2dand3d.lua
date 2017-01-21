-- 2d元素和3d元素进行布尔运算，2d元素将被转换成3d元素，结果也是3d元素    

push();
translate(0, 0, 1);
    difference();
        push();
            translate(0.25,0.5,0.25);
            cube({size={0.5,1,0.5},center = true});
        pop();
        push();
            translate(0.125,0.75,0.125);
            square({size={0.25,0.25},center = true});
        pop();
pop();

push();
translate(0, 0, 3);
    difference();
        push();
            translate(0.25,0.75,0.25);
            square({size={0.5,0.5},center = true});
        pop();
        push();
            translate(0.125,0.5,0.125);
            cube({size={0.25,1,0.25},center = true});
        pop();
pop();