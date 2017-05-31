--[[
Title: Primitive3d.lua
Author(s): leio
Date: 2017/5/31
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Primitive3d.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");


local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;

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
		o = CSGModel:new():init(CSGFactory.roundedCube({radius = {x/2,y/2,z/2}, roundradius = r, resolution = fn}),"roundedCube");
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
			o = CSGModel:new():init(CSGFactory.roundedCylinder({from = p.from, to = p.to, radius = r1, resolution = fn}),"roundedCylinder");
		else
			o = CSGModel:new():init(CSGFactory.cylinder({from = p.from,to = p.to,radiusStart = r1,radiusEnd = r2,resolution = fn}),"cylinder");
		end
	else
		if(round)then
			o = CSGModel:new():init(CSGFactory.roundedCylinder({from = {0,0,0}, to = {0,0,h}, radius = r1, resolution = fn}),"roundedCylinder");
		else
			o = CSGModel:new():init(CSGFactory.cylinder({from = {0,0,0}, to = {0,0,h}, radiusStart = r1, radiusEnd = r2, resolution = fn}),"cylinder");
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
polyhedron
     Parameters:
       points: points list for this polyhedron
       faces: trangles list for this polyhedron
--]]
function NplCadEnvironment.polyhedron(options)
	local self = getfenv(2);
	return self:polyhedron__(options);
end
function NplCadEnvironment:polyhedron__(options)
	options = options or {};
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_polyhedron(options);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_polyhedron(options)
	local node = Node.create("");
	local o = CSGModel:new():init(CSGFactory.polyhedron(options));
	if(o ~= nil) then
		node:setDrawable(o);
	end
	return node;
end