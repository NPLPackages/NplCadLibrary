--[[
Title: CAGFactory
Author(s): Skeleton
Date: 2016/11/27
Desc: This is a factory to create CAG object.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
-------------------------------------------------------
--]]

NPL.load("(gl)script/ide/math/vector2d.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPath2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");

local vector2d = commonlib.gettable("mathlib.vector2d");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");
local CSGPath2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPath2D");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");

--[[ 
Construct a circle
options:
    center: a 2D center point
    radius: a scalar
    resolution: number of sides per 360 degree rotation
returns a CAG object
--]]
function CAGFactory.circle(options)
    options = options or {};
    local center = CSGFactory.parseOptionAs2DVector(options, "center", {0, 0});
    local radius = CSGFactory.parseOptionAsFloat(options, "radius", 1);
    local resolution = CSGFactory.parseOptionAsInt(options, "resolution", CSGFactory.defaultResolution2D);
    local sides = {};
    local prevvertex;

	local i;
	for i=0,resolution do
        local radians = 2 * math.pi * i / resolution;
		local point = vector2d.fromAngleRadians(radians):MulByFloat(radius):add(center);
		local vertex = CAGVertex:new():init(point);
        if (i > 0) then
			local side = CAGSide:new():init(prevvertex, vertex);
			table.insert(sides,side);
		end
		prevvertex = vertex;	
	end
    return CAG.fromSides(sides);
end

--[[ Construct an ellispe
options:
    center: a 2D center point
    radius: a 2D vector with width and height
    resolution: number of sides per 360 degree rotation
returns a CAG object
--]]
function CAGFactory.ellipse(options)
    options = options or {};
    local c = CSGFactory.parseOptionAs2DVector(options, "center", {0, 0});
    local r = CSGFactory.parseOptionAs2DVector(options, "radius", {1, 1});
    r = r:abs(); --  negative radii make no sense
    local res = CSGFactory.parseOptionAsInt(options, "resolution", CSGFactory.defaultResolution2D);

    local e2 = CSGPath2D:new():init({{c[1],c[2] + r[2]}});
	e2 = e2:appendArc({c[1],c[2] - r[2]}, {
        xradius = r[1],
        yradius =  r[2],
        xaxisrotation =  0,
        resolution =  res,
        clockwise =  true,
        large =  false,
    });
    e2 = e2:appendArc({c[1],c[2] + r[2]}, {
        xradius =  r[1],
        yradius =  r[2],
        xaxisrotation =  0,
        resolution =  res,
        clockwise =  true,
        large =  false,
    });
    e2 = e2:close();
    return e2:innerToCAG();
end 
--[[ Construct a rectangle
options:
    center: a 2D center point
    radius: a 2D vector with width and height
    returns a CAG object
--]]
function CAGFactory.rectangle(options)
    options = options or {};
    local c, r;
    if ((options.corner1) or (options.corner2)) then
        if ((options.center) or (options.radius)) then
			LOG.std(nil, "error", "CAGFactory.rectangle", "should either give a radius and center parameter, or a corner1 and corner2 parameter");
			return nil;
        end
        corner1 = CSGFactory.parseOptionAs2DVector(options, "corner1", {0, 0});
        corner2 = CSGFactory.parseOptionAs2DVector(options, "corner2", {1, 1});
        c = corner1:add(corner2):MulByFloat(0.5);
        r = corner2:sub(corner1):MulByFloat(0.5);
	else
        c = CSGFactory.parseOptionAs2DVector(options, "center", {0, 0});
        r = CSGFactory.parseOptionAs2DVector(options, "radius", {1, 1});
    end
    r = r:abs(); -- negative radii make no sense
    local rswap = vector2d:new(r[1], -r[2]);
    local points = {
        c:clone():add(r), c:clone():add(rswap), c:clone():sub(r), c:clone():sub(rswap)
    };
    return CAG.fromPoints(points);
end

--     local r = CSG.roundedRectangle({
--       center: [0, 0],
--       radius: [2, 1],
--       roundradius: 0.2,
--       resolution: 8,
--     });
function CAGFactory.roundedRectangle(options)
    options = options or {};
    local center, radius;
    if ((options.corner1) or (options.corner2)) then
        if ((options.center) or (options.radius)) then
			LOG.std(nil, "error", "CAGFactory.roundedRectangle", "should either give a radius and center parameter, or a corner1 and corner2 parameter");
			return nil;
        end
        corner1 = CSGFactory.parseOptionAs2DVector(options, "corner1", {0, 0});
        corner2 = CSGFactory.parseOptionAs2DVector(options, "corner2", {1, 1});
        center = corner1:clone():add(corner2):MulByFloat(0.5);
        radius = corner2:clone():sub(corner1):MulByFloat(0.5);
	else
        center = CSGFactory.parseOptionAs2DVector(options, "center", {0, 0});
        radius = CSGFactory.parseOptionAs2DVector(options, "radius", {1, 1});
    end
    radius = radius:clone():abs(); -- negative radii make no sense
    local roundradius = CSGFactory.parseOptionAsFloat(options, "roundradius", 0.2);
    local resolution = CSGFactory.parseOptionAsInt(options, "resolution", CSGFactory.defaultResolution2D);
    local maxroundradius = math.min(radius[1], radius[2]);
    maxroundradius = maxroundradius - 0.1;
    roundradius = math.min(roundradius, maxroundradius);
    roundradius = math.max(0, roundradius);
    radius = vector2d:new(radius[1] - roundradius, radius[2] - roundradius);

    local rect = CAGFactory.rectangle({
        center = center,
        radius = radius
    });
    if (roundradius > 0) then
        rect = rect:expand(roundradius, resolution);
    end
    return rect;
end

function CAGFactory.polygon(points)
	return CAG.fromPoints(points);
end

function CAGFactory.path2dFromPoints(points)
	return CSGPath2D:new():init(points,false);
end
function CAGFactory.path2dFromArc(arc)
	return CSGPath2D.arc(arc);
end