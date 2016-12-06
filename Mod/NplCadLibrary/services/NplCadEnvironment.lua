--[[
Title: NplCadEnvironment 
Author(s): leio
Date: 2016/8/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Transform.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/core/Scene.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/doms/DomParser.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/CSGService.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/Color.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Transform = commonlib.gettable("Mod.NplCadLibrary.core.Transform");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local Scene = commonlib.gettable("Mod.NplCadLibrary.core.Scene");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local DomParser = commonlib.gettable("Mod.NplCadLibrary.doms.DomParser");
local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");
local Color = commonlib.gettable("Mod.NplCadLibrary.utils.Color");
local math_pi = 3.1415926;
local function is_string(input)
	if(input and type(input) == "string")then
		return true;
	end
end
local function is_table(input)
	if(input and type(input) == "table")then
		return true;
	end
end
local function is_number(input)
	if(input and type(input) == "number")then
		return true;
	end
end
local function is_array(input)
	if(input and type(input) == "table" and (#input) > 0)then
		return true;
	end
end

-- number pi are exposed
NplCadEnvironment.PI = 3.1415926;
NplCadEnvironment.pi = NplCadEnvironment.PI;

function NplCadEnvironment:new()
	local o = {
		scene =  Scene.create("nplcad_scene");
		nodes_stack = {},
		math = math,
		specified_indexs = {},
	};
	setmetatable(o, self);
	self.__index = self
	return o;
end

function NplCadEnvironment.getNode()
	local self = getfenv(2);
	return self:getNode__();
end
function NplCadEnvironment:getNode__()
	if(self.nodes_stack)then
		local len = #self.nodes_stack;
		local node = self.nodes_stack[len];
		if(node)then
			return node;
		end
		return self.scene;
	end
end
function NplCadEnvironment.push()
	local self = getfenv(2);
	self:push__(true);
end
function NplCadEnvironment:push__(bSpecified)
	local parent = self:getNode__()
	local node = Node.create("");
	table.insert(self.nodes_stack,node);
	parent:addChild(node);
	if(bSpecified)then
		table.insert(self.specified_indexs,#self.nodes_stack)
	end
	return node;
end
function NplCadEnvironment.pop()
	local self = getfenv(2);
	self:pop__(true);
end
function NplCadEnvironment:pop__(bSpecified)
	if(self.nodes_stack)then
		if(bSpecified)then
			local len = #self.specified_indexs;
			local start_index = self.specified_indexs[len];
			local end_index = #self.nodes_stack;
			while (end_index >= start_index) do
				table.remove(self.nodes_stack,end_index);
				end_index = end_index - 1;
			end
			table.remove(self.specified_indexs,len);
		else
			local len = #self.nodes_stack;
			table.remove(self.nodes_stack,len);
		end
	end
end
function NplCadEnvironment.current()
	local self = getfenv(2);
	local node = self:getNode__();
	return node;
end

function NplCadEnvironment.log(...)
	local self = getfenv(2);
	self:log__(...);
end

function NplCadEnvironment:log__(...)
	self.scene:log(...);
end

function NplCadEnvironment.union()
	local self = getfenv(2);
	self:union__();
end
function NplCadEnvironment:union__()
	local node = self:push__();
	if(node)then
		node:setTag("csg_action","union");
	end
end
function NplCadEnvironment.difference()
	local self = getfenv(2);
	self:difference__();
end
function NplCadEnvironment:difference__()
	local node = self:push__();
	if(node)then
		node:setTag("csg_action","difference");
	end
end
function NplCadEnvironment.intersection()
	local self = getfenv(2);
	self:intersection__();
end
function NplCadEnvironment:intersection__()
	local node = self:push__();
	if(node)then
		node:setTag("csg_action","intersection");
	end
end
function NplCadEnvironment.cube(options)
	local self = getfenv(2);
	return self:cube__(options);
end

function NplCadEnvironment.read_cube(p)
	local node = Node.create("");
	local s = 1;
	local v = nil;
	local off = {0,0,0};
	local round = false;
	local r = 0;
	local fn = 8;

	if(is_array(p))then
		v = p;
	end
	if(is_table(p) and p.size and is_array(p.size))then v = p.size; end --{ size: [1,2,3] }
	if(is_table(p) and p.size and not is_array(p.size))then s = p.size; end --{ size: 1 }
	if(not is_table(p)) then s = p; end -- (2)
	if(is_table(p) and p.round == true)then
		round = true;
		if(v)then
			if(is_array(v))then
				r = (v[1]+v[2]+v[3])/30;
			else 
				r = s / 10;
			end
		end
	end
	if(is_table(p) and p.radius)then
		round = true;
		r = p.radius;
	end
	if(is_table(p) and p.fn)then
		fn = p.fn; --applies in case of round: true
	end

	local x = s;
	local y = s;
	local z = s; 
	if(v and is_array(v))then
		x = v[1];
		y = v[2];
		z = v[3]; 
	end
   
	off = {x/2,y/2,z/2}; -- center: false default
	local o;
	if(round)then
		--NOTE:Unimplemented
		--o = CSGModel:new():init(CSGFactory.roundedCube({radius = {x/2,y/2,z/2}, roundradius = r, resolution = fn}),"roundedCube");
		o = CSGModel:new():init(CSGFactory.cube({radius = {x/2,y/2,z/2}}),"cube");
	else
		o = CSGModel:new():init(CSGFactory.cube({radius = {x/2,y/2,z/2}}),"cube");
	end
	if(is_table(p) and p.center and is_array(p.center))then
		if(p.center[1])then off[1] = 0; else off[1] = x/2;end
		if(p.center[2])then off[2] = 0; else off[2] = y/2;end
		if(p.center[3])then off[3] = 0; else off[3] = z/2;end
	elseif(is_table(p) and p.center == true)then
		off = {0,0,0};
	elseif(is_table(p) and p.center == false)then
		off = {x/2,y/2,z/2};
	end
	node:setDrawable(o);
	if(off[1] ~= 0 or off[2] ~= 0 or off[3] ~= 0)then
		node:translate(off[1],off[2],off[3]);
	end
	return node;
end
--[[
cube(); // openscad like
cube(1);
cube({size = 1});
cube({size = {1,2,3}});
cube({size = 1, center = true}); // default center:false
cube({size = 1, center = {true,true,false}}); // individual axis center true or false
--]]
function NplCadEnvironment:cube__(options)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_cube(options);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.sphere(options)
	local self = getfenv(2);
	return self:sphere__(options);
end
function NplCadEnvironment.read_sphere(p)
	local node = Node.create("");
	
	local r = 1;
	local fn = 32;
	local off = {0,0,0};      
	local type = 'normal';
   
	if(is_table(p) and p.r) then 
		r = p.r;
	end
	if(is_table(p) and p.fn) then
		fn = p.fn;
	end
	if(is_table(p) and p.type) then
		type = p.type;
	end

	if(not is_table(p)) then
		r = p;
	end
	off = {0,0,0};       -- center: false (default)

	local o;
	if(type=='geodesic')then
		--NOTE:Unimplemented
		--o = geodesicSphere(p);
		o = CSGModel:new():init(CSGFactory.sphere({radius = r, resolution = fn}),"sphere");
	else 
		o = CSGModel:new():init(CSGFactory.sphere({radius = r, resolution = fn}),"sphere");
	end
	if(is_table(p) and p.center and is_table(p.center)) then         -- preparing individual x,y,z center
		if(p.center[1])then
			off[1] = 0
		else
			off[1] = r
		end
		if(p.center[2])then
			off[2] = 0
		else
			off[2] = r
		end
		if(p.center[3])then
			off[3] = 0
		else
			off[3] = r
		end
	elseif(is_table(p) and p.center==true) then
		off = {0,0,0};
	elseif(is_table(p) and p.center==false) then
		off = {r,r,r};
	end
	node:setDrawable(o);
	if(off[1] ~= 0 or off[2] ~= 0 or off[3] ~= 0)then
		node:translate(off[1],off[2],off[3]);
	end
	return node;
end
--[[
	sphere();                          // openscad like
	sphere(1);
	sphere({r = 2});                    // Note: center = true is default (unlike other primitives, as OpenSCAD)
	sphere({r = 2, center = false});     // Note: OpenSCAD doesn't support center for sphere but we do
	sphere({r = 2, center = {true, true, false}}); // individual axis center 
	sphere({r = 10, fn = 100 });
--]]
function NplCadEnvironment:sphere__(options)
	options = options or {};
	local parent = self:getNode__();
	local node = NplCadEnvironment.read_sphere(options);
	parent:addChild(node);
	return node;
end

function NplCadEnvironment.cylinder(options,...)
	local self = getfenv(2);
	return self:cylinder__(options);
end

function NplCadEnvironment.read_cylinder(p,...)
	local node = Node.create("");
	local r1 = 1;
	local r2 = 1;
	local h = 1;
	local fn = 32;
	local round = false; 
	local a = {...};
	local off = {0,0,0};

	if(is_table(p) and p.d) then
		r1 = p.d/2;
		r2 = r1;
	end
	if(is_table(p) and p.r) then
		r1 = p.r; 
		r2 = p.r; 
	end
	if(is_table(p) and p.h) then
		h = p.h;
	end
	if(is_table(p) and (p.r1 or p.r2)) then
		r1 = p.r1; 
		r2 = p.r2; 
		if(p.h)then
		h = p.h;
		end
	end
	if(is_table(p) and (p.d1 or p.d2)) then
		r1 = p.d1/2; 
		r2 = p.d2/2;
	end
    
	if(is_array(a) and a[1] and is_array(a[1])) then
		a = a[1]; 
		r1 = a[1]; 
		r2 = a[2]; 
		h = a[3]; 
		if(#a == 4)then
		fn = a[4];
		end
	end
	if(is_table(p) and p.fn) then
		fn = p.fn;
	end
	if(is_table(p) and p.round==true) then
		round = true;
	end
	local o;
	if(is_table(p) and (p.from and p.to)) then
		if(round)then
			--NOTE:Unimplemented
			--o = CSGModel:new():init(CSGFactory.roundedCylinder({from = p.from, to = p.to, radiusStart = r1,radiusEnd = r2, resolution = fn}),"roundedCylinder");
			o = CSGModel:new():init(CSGFactory.cylinder({from = p.from,to = p.to,radiusStart = r1,radiusEnd = r2,resolution = fn}),"cylinder");
		else
			o = CSGModel:new():init(CSGFactory.cylinder({from = p.from,to = p.to,radiusStart = r1,radiusEnd = r2,resolution = fn}),"cylinder");
		end
	else
		if(round)then
			--NOTE:Unimplemented
			--o = CSGModel:new():init(CSGFactory.roundedCylinder({from = {0,0,0}, to = {0,0,h},radiusStart = r1, radiusEnd = r2, resolution = fn}),"roundedCylinder");
			o = CSGModel:new():init(CSGFactory.cylinder({from = {0,0,0}, to = {0,h,0}, radiusStart = r1, radiusEnd = r2, resolution = fn}),"cylinder");
		else
			o = CSGModel:new():init(CSGFactory.cylinder({from = {0,0,0}, to = {0,h,0}, radiusStart = r1, radiusEnd = r2, resolution = fn}),"cylinder");
		end
		local r;
		if(r1>r2)then
			r = r1;
		else
			r = r2;
		end
			if(is_table(p) and p.center and is_table(p.center)) then         -- preparing individual x,y,z center
			if(p.center[1])then
				off[1] = 0;
			else
				off[1] = r;
			end
			if(p.center[2])then
				off[2] = 0;
			else
				off[2] = r;
			end
			if(p.center[3])then
				off[3] = -h/2;
			else
				off[3] = 0;
			end
			elseif(is_table(p) and p.center==true) then 
				off = {0,0,-h/2};
			elseif(is_table(p) and p.center==false) then
				off = {0,0,0};
			end
			--if(off[0]||off[1]||off[2]) o = o.translate(off);
			if(off[1] ~= 0 or off[2] ~= 0 or off[3] ~= 0)then
				node:translate(off[1],off[2],off[3]);
			end
	end
	node:setDrawable(o);
	return node;
end
--[[
	cylinder({r = 1, h = 10});                 -- openscad like
	cylinder({d = 1, h = 10});
	cylinder({r = 1, h = 10, center = true});   -- default: center = false
	cylinder({r = 1, h = 10, center = {true, true, false}});  -- individual x,y,z center flags
	cylinder({r1 = 3, r2 = 0, h = 10});
	cylinder({d1 = 1, d2 = 0.5, h = 10});
	cylinder({from = {0,0,0}, to = {0,0,10}, r1 = 1, r2 = 2, fn = 50});
]]
function NplCadEnvironment:cylinder__(options,...)
	options = options or {};
	local parent = self:getNode__();
	local node = NplCadEnvironment.read_cylinder(options,...)
	parent:addChild(node);
	return node;
end
--[[
translate({0,0,10});		--create a new parent node and set translation value 
translate({0,0,10},obj);	--set translation value with obj          
translate(0,1,0, obj);		--set translation 
--]]
function NplCadEnvironment.translate(...)
	local self = getfenv(2);
	self:translate__(...);
end
function NplCadEnvironment:translate__(p1,p2,p3,p4)
	local x,y,z, options,obj;
	if(type(p1) == "table") then
		options = p1;
		x = options[1];
		y = options[2];
		z = options[3];
		obj = p2;
	elseif(type(p1) == "number") then
		x=p1;
		y=tonumber(p2);
		z=tonumber(p3);
		obj = p4;
	end
	if(not obj)then
		obj = self:push__();
	end
	if(obj and obj.setTranslation)then
		obj:setTranslation(x or 0, y or 0, z or 0);
	end
end
--[[
rotate(2);				--create a new parent node and set rotation value          
rotate(2,obj);			--set rotation value with obj          
rotate({1,2,3});		--create a new parent node and set rotation value          
rotate({1,2,3},obj);	--set rotation value with obj  
--]]
function NplCadEnvironment.rotate(options,obj)
	local self = getfenv(2);
	self:rotate__(options,obj);
end
function NplCadEnvironment:rotate__(options,obj)
	if(not options)then return end
	local x_angle,y_angle,z_angle;
	if(is_number(options))then
		x_angle = options;
		y_angle = options;
		z_angle = options;
	end
	if(is_array(options))then
		x_angle = options[1] or 0;
		y_angle = options[2] or 0;
		z_angle = options[3] or 0;
	end
	if(not obj)then
		obj = self:push__();
	end
	local x = x_angle * math_pi / 180;
	local y = y_angle * math_pi / 180;
	local z = z_angle * math_pi / 180;

	if(obj and obj.setRotation)then
		local q =  Quaternion:new();
		local yaw = y;
		local roll = z;
		local pitch = x;
		q =  q:FromEulerAngles(yaw,roll,pitch);
		obj:setRotation(q[1],q[2],q[3],q[4]);
	end
end
--[[
scale(2);			--create a new parent node and set scale value          
scale(2,obj);		--set scale value with obj          
scale({1,2,3});		--create a new parent node and set scale value          
scale({1,2,3},obj); --set scale value with obj          
--]]
function NplCadEnvironment.scale(options,obj)
	local self = getfenv(2);
	self:scale__(options,obj);
end
function NplCadEnvironment:scale__(options,obj)
	if(not options)then return end
	local x,y,z;
	if(is_number(options))then
		x = options;
		y = options;
		z = options;
	end
	if(is_array(options))then
		x = options[1] or 1;
		y = options[2] or 1;
		z = options[3] or 1;
	end
	if(not obj)then
		obj = self:push__();
	end
	if(obj and obj.setScale)then
		obj:setScale(x,y,z);
	end
end
--[[
color({r,g,b});		--create a new parent node and set color value 
color({r,g,b},obj); --set color value with obj 
color(color_name);		--create a new parent node and set color value with color name
color(color_name,obj)		--set color value with obj 
--]]
function NplCadEnvironment.color(options,obj)
	local self = getfenv(2);
	self:color__(options,obj);
end
function NplCadEnvironment:color__(options,obj)
	if(not options)then return end
	local r,g,b;
	if(is_string(options))then
		local v = Color.getValue(options);
		r = v[1];
		g = v[2];
		b = v[3];
	end
	if(is_array(options))then
		r = options[1] or 1;
		g = options[2] or 1;
		b = options[3] or 1;
	end
	if(not obj)then
		obj = self:push__();
	end
	if(obj and obj.setTag)then
		obj:setTag("color",{r,g,b});
	end
end
function NplCadEnvironment.loadXml(str)
	local self = getfenv(2);
	self:loadXml__(str);
end
function NplCadEnvironment:loadXml__(str)
	local parent = self:getNode__();
	local node = DomParser.loadStr(str)
	if(node)then
		parent:addChild(node);
	end
end

--[[
		circle
--]]
function NplCadEnvironment.circle(options,...)
	local self = getfenv(2);
	return self:circle__(options);
end

function NplCadEnvironment.read_circle(p,...)
	local node = Node.create("");
	local r = 1;
	local fn = 32;
	local a = {...};
	local off = {0,0,0};

	--x
	if(not is_table(p)) then
		r = p;
	end
	-- {d=x}
	if(is_table(p) and p.d) then
		r = p.d/2;
	end
	-- {r=x}
	if(is_table(p) and p.r) then
		r = p.r; 
	end
	--[r,fn]
	if(is_array(a) and a[1] and is_array(a[1])) then
		r = a[1]; 
		if(#a == 2)then
		fn = a[2];
		end
	end
	-- {fn=x}
	if(is_table(p) and p.fn) then
		fn = p.fn;
	end

	local o;
	o = CSGModel:new():init(CSGFactory.cylinder({from = {0,0,0}, to = {0,0.0001,0}, radiusStart = r, radiusEnd = r, resolution = fn}),"circle");

	-- {center={}}
	if(is_table(p) and p.center and is_table(p.center)) then         -- preparing individual x,y,z center
		if(p.center[1])then
			off[1] = 0;
		else
			off[1] = r;
		end
		if(p.center[2])then
			off[2] = 0;
		else
			off[2] = r;
		end
	-- {center=true}
	elseif(is_table(p) and p.center==true) then 
		off = {0,0,0};
	-- {center=false}
	elseif(is_table(p) and p.center==false) then
		off = {r,0,r};
	end
	
	--if(off[0]||off[1]||off[2]) o = o.translate(off);
	if(off[1] ~= 0 or off[2] ~= 0 or off[3] ~= 0)then
		node:translate(off[1],off[2],off[3]);
	end

	node:setDrawable(o);
	return node;
end
--[[
	circle();                        -- openscad like
	circle(1); 
	circle({d: 2, fn:5});
	circle({r: 2, fn:5});
	circle({r: 3, center: true});    -- center: false (default)
	circle({r: 3, center:  = {true, true}});    -- individual x,z center flags
]]
function NplCadEnvironment:circle__(options,...)
	options = options or {};
	local parent = self:getNode__();
	local node = NplCadEnvironment.read_circle(options,...)
	parent:addChild(node);
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
	local s = 1;
	local v = nil;
	local off = {0,0,0};
	local round = false;
	local r = 0;
	local fn = 8;

	-- [w,h]
	if(is_array(p))then
		v = p;
	end
	--{ size: [w.h] }
	if(is_table(p) and p.size and is_array(p.size))then 
		v = p.size; 
	end 
	--{ size: 1 }
	if(is_table(p) and p.size and not is_array(p.size))then 
		s = p.size; 
	end 
	-- (2)
	if(not is_table(p)) then 
		s = p; 
	end 
	if(is_table(p) and p.round == true)then
		round = true;
		if(v)then
			if(is_array(v))then
				r = (v[1]+v[2])/30;
			else 
				r = s / 10;
			end
		end
	end
	if(is_table(p) and p.radius)then
		round = true;
		r = p.radius;
	end
	if(is_table(p) and p.fn)then
		fn = p.fn; --applies in case of round: true
	end

	local x = s;
	local z = s; 
	if(v and is_array(v))then
		x = v[1];
		z = v[2]; 
	end
   
	off = {x/2,0,z/2}; -- center: false default
	local o;
	if(round)then
		--NOTE:Unimplemented
		--o = CSGModel:new():init(CSGFactory.roundedCube({radius = {x/2,y/2,z/2}, roundradius = r, resolution = fn}),"roundedSquare");
		o = CSGModel:new():init(CSGFactory.cube({radius = {x/2,0.0001,z/2}}),"square");
	else
		o = CSGModel:new():init(CSGFactory.cube({radius = {x/2,0.0001,z/2}}),"square");
	end
	if(is_table(p) and p.center and is_array(p.center))then
		if(p.center[1])then off[1] = 0; else off[1] = x/2;end
		if(p.center[2])then off[2] = 0; else off[2] = z/2;end
	elseif(is_table(p) and p.center == true)then
		off = {0,0,0};
	elseif(is_table(p) and p.center == false)then
		off = {x/2,0,z/2};
	end
	node:setDrawable(o);
	if(off[1] ~= 0 or off[2] ~= 0 or off[3] ~= 0)then
		node:translate(off[1],off[2],off[3]);
	end
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
	parent:addChild(node);
	return node;
end