--[[
Title: Primitive2d.lua
Author(s): leio
Date: 2017/5/31
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Primitive2d.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");


local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;

--[[
		circle
--]]
function NplCadEnvironment.circle(options)
	local self = getfenv(2);
	return self:circle__(options);
end
--[[
	circle();                        -- openscad like
	circle(1); 
	circle({d: 2, fn:5});
	circle({r: 2, fn:5});
	circle({r: 3, center = true});    -- center: false (default)
	circle({r: 3, center = {true, true}});    -- individual x,z center flags
]]
function NplCadEnvironment:circle__(options)
	options = options or {};
	local parent = self:getNode__();
	local node = NplCadEnvironment.read_circle(options)
    if(self:check_attach_value(options))then
	    parent:addChild(node);
    end
	return node;
end
function NplCadEnvironment.read_circle(p)
	local node = Node.create("");
    local r = 1;
    local off;
    local fn = CSGFactory.defaultResolution2D;
    if(is_table(p) and p.r)then
        r = p.r;
    end
    if(is_table(p) and p.fn)then
        fn = p.fn;
    end
    if(is_number(p))then
        r = p;
    end
    off = { r, r};
    if(is_table(p) and p.center == true)then
        off = { 0, 0 };
    end
	local o = CAGModel:new():init(CAGFactory.circle({ center = off, radius = r, resolution = fn}),"circle");
    node:setDrawable(o);
	node:setTag("shape","circle");
	return node;
end
--[[
		square
--]]
function NplCadEnvironment.square(options)
	local self = getfenv(2);
	return self:square__(options);
end

function NplCadEnvironment.read_square(p)
	local node = Node.create("");
    local v = { 1, 1 };
    local off;
    if(is_number(p))then
        v = { p, p };
    end
    if(is_array(p))then
        v = p;
    end
    if(is_table(p) and p.size)then
        if(is_number(p.size))then
            v[1] = p.size;
            v[2] = p.size;
        end
        if(is_array(p.size))then
            v = p.size
        end
    end
    off = { v[1] /2, v[2] /2, }
    if(is_table(p) and p.center == true)then
        off = { 0, 0 };
    end
	local o = CAGModel:new():init(CAGFactory.rectangle({ center = off, radius = { v[1] / 2, v[2] / 2 } }),"square");
    node:setDrawable(o);
	node:setTag("shape","square");
	return node;
end
--[[
square(); // openscad like
square(1);
square({size = 1});
square({size = {1,2}});
square({size = 1, center = true}); // default center:false
square({size = 1, center = {true,true}}); // individual axis center true or false
--]]
function NplCadEnvironment:square__(options)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_square(options);
	if(self:check_attach_value(options))then
	    parent:addChild(node);
    end
	return node;
end
--[[
		polygon
--]]
function NplCadEnvironment.polygon(options)
	local self = getfenv(2);
	return self:polygon__(options);
end
--[[
polygon({ {0,0},{3,0},{3,3} });                // openscad like
polygon({ points = { {0,0},{3,0},{3,3},{0,6} });                    
--]]
function NplCadEnvironment:polygon__(options)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_polygon(options);
	if(self:check_attach_value(options))then
	    parent:addChild(node);
    end
	return node;
end

function NplCadEnvironment.read_polygon(p)
	local node = Node.create("");
	local points = {};
    if(p.paths and is_array(p.paths) and is_array(p.paths[1]))then  -- pa(th): [[0,1,2],[2,3,1]] (two paths)
        for j = 1, #(p.paths) do
            for i = 1, #(p.paths[j]) do
                points[i] = p.points[p.paths[j][i]];
            end
        end
    elseif(p.paths and is_array(p.paths))then  -- pa(th): [0,1,2,3,4] (single path)
        for i = 1, #(p.paths) do
            points[i] = p.points[p.paths[i]];
        end
    else
        if(is_array(p))then
            points = p;
        else
            points = p.points;
        end
    end
	local o = CAGModel:new():init(CAGFactory.polygon(points),"polygon");
    node:setDrawable(o);
	node:setTag("shape","polygon");
	return node;
end

--[[
		path2d
		-- { {0,0},{3,0},{3,3} }
		--{ points = { {0,0},{3,0},{3,3},{0,6} }
		-- { arc = {center={0,0,0},radius=1,startangle=0,endangle= 360,resolution=32,maketangent=false}}

A path can be converted to a CAG in two ways:
expandToCAG()
innerToCAG()
--]]
function NplCadEnvironment.path2d(p)
	-- { {0,0},{3,0},{3,3} }
    local path;
	if(is_array(p)) then
		path = CAGFactory.path2dFromPoints(p);

	--{ points = { {0,0},{3,0},{3,3},{0,6} }
	elseif(is_table(p)) then 
		local closed = false;
		if(p.closed) then
			closed = p.closed;
		end
		if(p.points) then
			path = CAGFactory.path2dFromPoints(p.points);
		elseif(p.arc) then
			path = CAGFactory.path2dFromArc(p.arc);
		end
		path.closed = closed;
	else
		path = CAGFactory.path2dFromPoints({});
	end 
	return path;
end

--[[
rectangle();
rectangle({center = x});
rectangle({center = {x,y}});
rectangle({radius = w});
rectangle({radius = {w,h}});
rectangle({center = {0,0}, radius = {w,h}});
--]]
function NplCadEnvironment.rectangle(options)
	local self = getfenv(2);
	return self:rectangle__(options);
end
function NplCadEnvironment:rectangle__(options)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_rectangle(options);
	if(self:check_attach_value(options))then
	    parent:addChild(node);
    end
	return node;
end
function NplCadEnvironment.read_rectangle(p)
	local node = Node.create("");
	local center = {0,0};
	local radius = {1,1};

	if(is_table(p))then 
		if(p.center) then
			if(is_array(p.center))then
				center[1] = p.center[1];
				center[2] = p.center[2]; 
			elseif(is_number(p.center)) then
				center[1] = p.center;
				center[2] = p.center; 				
			end
		end
		if(p.radius)then
			if(is_array(p.radius))then
				radius[1] = p.radius[1];
				radius[2] = p.radius[2]; 
			elseif(is_number(p.radius)) then
				radius[1] = p.radius;
				radius[2] = p.radius; 				
			end			
		end
	end 

	local o = CAGModel:new():init(CAGFactory.rectangle({center = center,  radius = radius}),"rectangle");
	node:setDrawable(o);
	node:setTag("shape","rectangle");
	return node;
end

--[[
roundedRectangle();
roundedRectangle({center = x});
roundedRectangle({center = {x,y}});
roundedRectangle({radius = w});
roundedRectangle({radius = {w,h}});
roundedRectangle({center = {0,0}, radius = {w,h}});
roundedRectangle({center = {0,0}, radius = {w,h},roundradius = 1,resolution = 32});
--]]
function NplCadEnvironment.roundedRectangle(options)
	local self = getfenv(2);
	return self:roundedRectangle__(options);
end
function NplCadEnvironment:roundedRectangle__(options)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_roundedRectangle(options);
	if(self:check_attach_value(options))then
	    parent:addChild(node);
    end
	return node;
end
function NplCadEnvironment.read_roundedRectangle(p)
	local node = Node.create("");
	local center = {0,0};
	local radius = {1,1};
	local roundradius  = 0.2;
	local resolution = 8;

	if(is_table(p))then 
		if(p.center) then
			if(is_array(p.center))then
				center[1] = p.center[1];
				center[2] = p.center[2]; 
			elseif(is_number(p.center)) then
				center[1] = p.center;
				center[2] = p.center; 				
			end
		end
		if(p.radius)then
			if(is_array(p.radius))then
				radius[1] = p.radius[1];
				radius[2] = p.radius[2]; 
			elseif(is_number(p.radius)) then
				radius[1] = p.radius;
				radius[2] = p.radius; 				
			end			
		end
		if(p.roundradius and is_number(p.roundradius))then
			roundradius = p.roundradius;
		end
		if(p.resolution and is_number(p.resolution))then
			resolution = p.resolution;
		end
	end 

	local o = CAGModel:new():init(CAGFactory.roundedRectangle({center = center,  radius = radius, roundradius = roundradius, resolution = resolution}),"roundedRectangle");
	node:setDrawable(o);
	node:setTag("shape","roundedRectangle");
	return node;
end

--[[
ellipse();
ellipse({center = x});
ellipse({center = {x,y}});
ellipse({radius = w});
ellipse({radius = {w,h}});
ellipse({center = {0,0}, radius = {w,h}});
--]]
function NplCadEnvironment.ellipse(options)
	local self = getfenv(2);
	return self:ellipse__(options);
end
function NplCadEnvironment:ellipse__(options)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_ellipse(options);
	if(self:check_attach_value(options))then
	    parent:addChild(node);
    end
	return node;
end
function NplCadEnvironment.read_ellipse(p)
	local node = Node.create("");
	local center = {0,0};
	local radius = {1,1};

	if(is_table(p))then 
		if(p.center) then
			if(is_array(p.center))then
				center[1] = p.center[1];
				center[2] = p.center[2]; 
			elseif(is_number(p.center)) then
				center[1] = p.center;
				center[2] = p.center; 				
			end
		end
		if(p.radius)then
			if(is_array(p.radius))then
				radius[1] = p.radius[1]/2;
				radius[2] = p.radius[2]/2; 
			elseif(is_number(p.radius)) then
				radius[1] = p.radius/2;
				radius[2] = p.radius/2; 				
			end			
		end
	end 

	local o = CAGModel:new():init(CAGFactory.ellipse({center = center,  radius = radius}),"ellipse");
	node:setDrawable(o);
	node:setTag("shape","ellipse");
	return node;
end
function NplCadEnvironment:check_attach_value(options)
    local attach = true;
    if(options)then
        local v = tostring(options.attach);
        if(v == "false" or v == "false" or v == "False")then
            attach = false;
        end
    end
    return attach;
end