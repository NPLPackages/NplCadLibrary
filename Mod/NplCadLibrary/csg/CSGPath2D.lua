--[[
Title: CSGPath2D
Author(s): Skeleton
Date: 2016/11/28
Desc: 
Represents a Path in 2D space.
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPath2D.lua");
local CSGPath2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPath2D");
-------------------------------------------------------
--]]   

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");

local CSGPath2D = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.csg.CSGPath2D"));

local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");
local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");


------------------------------------------
-- CSG Path2D
------------------------------------------
function CSGPath2D:ctor()
    --self.points;
    --self.closed;
	--self lastBezierControlPoint
end

function CSGPath2D:init(points, closed)
    closed = closed or false;
    points = points or {};
    -- re-parse the points into CSGVector2D
    -- and remove any duplicate points
	local prevpoint = nil;
    if (closed and (#points > 0)) then
        prevpoint = CSGVector2D:new():init(points[#points]);
    end
    local newpoints = {};

	for k,v in ipairs(points) do
		local vector2d = CSGVector2D:new():init(v);
		local skip = false;
        if prevpoint ~= nil then
            local distance = vector2d:distanceTo(prevpoint);
            skip = distance < tonumber("1e-5");
        end
        if not skip then
			table.insert(newpoints,vector2d);
		end
        prevpoint = vector2d;
	end
    self.points = newpoints;
    self.closed = closed;
	return self;
end
 
--[[
Construct a (part of a) circle. Parameters:
    options.center: the center point of the arc (CSGVector2D or array [x,y])
    options.radius: the circle radius (float)
    options.startangle: the starting angle of the arc, in degrees
    0 degrees corresponds to [1,0]
    90 degrees to [0,1]
    and so on
    options.endangle: the ending angle of the arc, in degrees
    options.resolution: number of points per 360 degree of rotation
    options.maketangent: adds two extra tiny line segments at both ends of the circle
    this ensures that the gradients at the edges are tangent to the circle
Returns a CSGPath2D. The path is not closed (even if it is a 360 degree arc).
close() the resulting path if you want to create a true circle.
--]]

function CSGPath2D.arc(options)
    local center = CSGFactory.parseOptionAs2DVector(options, "center", 0);
    local radius = CSGFactory.parseOptionAsFloat(options, "radius", 1);
    local startangle = CSGFactory.parseOptionAsFloat(options, "startangle", 0);
    local endangle = CSGFactory.parseOptionAsFloat(options, "endangle", 360);
    local resolution = CSGFactory.parseOptionAsInt(options, "resolution", CSGFactory.defaultResolution2D);
    local maketangent = CSGFactory.parseOptionAsBool(options, "maketangent", false);
    -- no need to make multiple turns:
    while (endangle - startangle >= 720) do
        endangle = endangle - 360;
    end
    while (endangle - startangle <= -720) do
        endangle = endangle + 360;
    end
    local points = {},
        point;
    local absangledif = math.abs(endangle - startangle);
    if (absangledif < tonumber("1e-5")) then
        point = CSGVector2D.fromAngle(startangle / 180.0 * mathext.pi):times(radius);
        points.push(point:plus(center));
    else 
        local numsteps = math.floor(resolution * absangledif / 360) + 1;
        local edgestepsize = numsteps * 0.5 / absangledif; -- step size for half a degree
        if (edgestepsize > 0.25) then
			edgestepsize = 0.25;
		end
        local numsteps_mod;
		if maketangent then
			numsteps_mod = (numsteps + 2)
		else
			numsteps_mod = numsteps;
		end

		local i;
        for i = 0, numsteps_mod, 1 do
            local step = i;
            if (maketangent) then
                step = (i - 1) * (numsteps - 2 * edgestepsize) / numsteps + edgestepsize;
                if (step < 0) then
					step = 0;
				end
                if (step > numsteps) then
					step = numsteps;
				end
            end
            local angle = startangle + step * (endangle - startangle) / numsteps;
            point = CSGVector2D.fromAngle(angle / 180.0 * mathext.pi):times(radius);
			table.insert(points,point:plus(center));
        end
    end
    return CSGPath2D:new():init(points, false);
end

function CSGPath2D:concat(otherpath)
    if (self.closed or otherpath.closed) then
		LOG.std(nil, "error", "CSGPath2D:concat", "Paths must not be closed");
		return nil;
    end
	local newpoints = tableext.concat(self.points,otherpath.points);
    return CSGPath2D:new():init(newpoints);
end

function CSGPath2D:appendPoint(point)
    if (self.closed) then
		LOG.std(nil, "error", "CSGPath2D:concat", "Paths must not be closed");
		return nil;
    end
	local newpoints = {};
	for i,v in pairs(self.points) do
		table.insert(newpoints,v);
	end

    local vector2d = CSGVector2D:new():init(point); -- cast to Vector2D
	table.insert(newpoints,vector2d);
    return CSGPath2D:new():init(newpoints);
end

function CSGPath2D:appendPoints(points)
    if (self.closed) then
		LOG.std(nil, "error", "CSGPath2D:concat", "Paths must not be closed");
		return nil;
    end
	local newpoints = {};
	for i,v in pairs(self.points) do
		table.insert(newpoints,v);
	end
	for i,v in pairs(points) do
		table.insert(newpoints,CSGVector2D:new():init(v));
	end
    return CSGPath2D:new():init(newpoints);
end

function CSGPath2D:close()
    return CSGPath2D:new():init(self.points, true);
end

-- options = {resolution = ?}
function CSGPath2D:appendBezier(controlpoints, options) 
	options = options or {};

    if (self.closed) then
		LOG.std(nil, "error", "CSGPath2D:appendBezier", "Paths must not be closed");
		return nil;
	end
    if (not tableext.is_array(controlpoints)) then
		LOG.std(nil, "error", "CSGPath2D:appendBezier", "should pass an array of control points");
		return nil;
    end
    if (#controlpoints < 1) then
		LOG.std(nil, "error", "CSGPath2D:appendBezier", " need at least 1 control point");
		return nil;
    end
    if (#self.points < 1) then
		LOG.std(nil, "error", "CSGPath2D:appendBezier", "path must already contain a point (the endpoint of the path is used as the starting point for the bezier curve)");
		return nil;
	end
    local resolution = CSGFactory.parseOptionAsInt(options, "resolution", CSGFactory.defaultResolution2D);
    if (resolution < 4) then
		resolution = 4;
	end
    
	local factorials = {};
    local controlpoints_parsed = {};
	table.insert(controlpoints_parsed,self.points[#self.points]);	-- start at the previous end point
	local i;
    for i = 1, #controlpoints, 1 do
        local p = controlpoints[i];
        if (p == nil) then
            -- we can pass nil as the first control point. In that case a smooth gradient is ensured:
            if (i ~= 1) then
				LOG.std(nil, "error", "CSGPath2D:appendBezier", "nil can only be passed as the first control point");
				return nil;
            end
            if (#controlpoints < 2) then
				LOG.std(nil, "error", "CSGPath2D:appendBezier", "nil can only be passed if there is at least one more control point");
				return nil;
            end
            local lastBezierControlPoint;
            if (self.lastBezierControlPoint ~= nil) then
                lastBezierControlPoint = self.lastBezierControlPoint;
            else
                if (#self.points < 2) then
					LOG.std(nil, "error", "CSGPath2D:appendBezier", "nil is passed as a control point but this requires a previous bezier curve or at least two points in the existing path");
					return nil;
                end
                lastBezierControlPoint = self.points[#self.points - 1];
            end
            -- mirror the last bezier control point:
            p = self.points[#self.points]:times(2):minus(lastBezierControlPoint);
        else
            p = CSGVector2D:new():init(p); -- cast to Vector2D
        end
        table.insert(controlpoints_parsed,p);
    end

    local bezier_order = #controlpoints_parsed-1;
    
	-- factorials array. 1,1,2,
	local fact = 1;
    for i = 0,  bezier_order, 1 do
        if (i > 0) then
			fact = fact * i;
		end
        table.insert(factorials,fact);
    end
    
	local binomials = {};
    for i = 1, bezier_order+1, 1 do
        local binomial = factorials[bezier_order+1] / (factorials[i] * factorials[bezier_order +2 - i]);
        table.insert(binomials,binomial);
    end
    
	local getPointForT = function(t) 
		local t_k = 1; -- = pow(t,k)
        local one_minus_t_n_minus_k = math.pow(1 - t, bezier_order); -- = pow( 1-t, bezier_order - k)
        local inv_1_minus_t = 1;
		if (t ~= 1) then
			inv_1_minus_t = (1 / (1 - t));
		end
        local point = CSGVector2D:new():init(0, 0);
		local k;
		
		-- bezier_order+1 index out of range
		for k = 1, bezier_order+1, 1 do		-- for k = 1, bezier_order+1, 1 do
            if (k == (bezier_order+1)) then		-- if (k == (bezier_order+1)) then
				one_minus_t_n_minus_k = 1;
			end
            local bernstein_coefficient = binomials[k] * t_k * one_minus_t_n_minus_k;
            point = point:plus(controlpoints_parsed[k]:times(bernstein_coefficient));
            t_k = t_k * t;
            one_minus_t_n_minus_k = one_minus_t_n_minus_k * inv_1_minus_t;
        end
        return point;
    end

    local newpoints = {};
    local newpoints_t = {};
    local numsteps = bezier_order + 1;
    for i = 0, numsteps-1, 1 do
        local t = i / (numsteps - 1);
        local point = getPointForT(t);
        table.insert(newpoints,point);
        table.insert(newpoints_t,t);
    end
    -- subdivide each segment until the angle at each vertex becomes small enough:
    local subdivide_base = 2;
    local maxangle = mathext.pi * 2 / resolution; -- segments may have differ no more in angle than this
    local maxsinangle = math.sin(maxangle);
    while (subdivide_base < #newpoints) do
        local dir1 = newpoints[subdivide_base]:minus(newpoints[subdivide_base - 1]):unit();
        local dir2 = newpoints[subdivide_base + 1]:minus(newpoints[subdivide_base]):unit();
        local sinangle = dir1:cross(dir2); -- this is the sine of the angle
        if (math.abs(sinangle) > maxsinangle) then
            -- angle is too big, we need to subdivide
            local t0 = newpoints_t[subdivide_base - 1];
            local t1 = newpoints_t[subdivide_base + 1];
            local t0_new = t0 + (t1 - t0) * 1 / 3;
            local t1_new = t0 + (t1 - t0) * 2 / 3;
            local point0_new = getPointForT(t0_new);
            local point1_new = getPointForT(t1_new);
            
			-- remove the point at subdivide_base and replace with 2 new points:
			tableext.splice(newpoints, subdivide_base, 1, point0_new, point1_new);
			tableext.splice(newpoints_t, subdivide_base, 1, t0_new, t1_new);

            -- re - evaluate the angles, starting at the previous junction since it has changed:
            subdivide_base = subdivide_base -1;
            if (subdivide_base < 2) then
				subdivide_base = 2;
			end
        else
            subdivide_base = subdivide_base + 1;
        end
    end
    -- append to the previous points, but skip the first new point because it is identical to the last point:
    -- newpoints = self.points.concat(newpoints.slice(1));
	newpoints = tableext.concat(self.points,newpoints);
	local result = CSGPath2D:new():init(newpoints);
    result.lastBezierControlPoint = controlpoints_parsed[#controlpoints_parsed - 1];
    return result;
end
--[[
    options:
    .resolution -- smoothness of the arc (number of segments per 360 degree of rotation)
    -- to create a circular arc:
    .radius
    -- to create an elliptical arc:
    .xradius
    .yradius
    .xaxisrotation  -- the rotation (in degrees) of the x axis of the ellipse with respect to the x axis of our coordinate system
    -- this still leaves 4 possible arcs between the two given points. The following two flags select which one we draw:
    .clockwise -- = true | false (default is false). Two of the 4 solutions draw clockwise with respect to the center point, the other 2 counterclockwise
    .large     -- = true | false (default is false). Two of the 4 solutions are an arc longer than 180 degrees, the other two are <= 180 degrees
    This implementation follows the SVG arc specs. For the details see
    http:--www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands
    --]]
function CSGPath2D:appendArc(endpoint, options)
    local decimals = 100000;

    options = options or {};

    if (self.closed) then
		LOG.std(nil, "error", "CSGPath2D:appendArc", "Paths must not be closed");
		return nil;
	end
    if (#self.points < 1) then
		LOG.std(nil, "error", "CSGPath2D:appendArc", "path must already contain a point (the endpoint of the path is used as the starting point for the bezier curve)");
		return nil;
	end

    local resolution = CSGFactory.parseOptionAsInt(options, "resolution", CSGFactory.defaultResolution2D);
    if (resolution < 4) then
		resolution = 4;
	end
    local xradius, yradius;
    if (options.xradius or options.yradius) then
        if (options.radius) then
			LOG.std(nil, "error", "CSGPath2D:appendArc", "Should either give an xradius and yradius parameter, or a radius parameter");
			return nil;
        end
        xradius = CSGFactory.parseOptionAsFloat(options, "xradius", 0);
        yradius = CSGFactory.parseOptionAsFloat(options, "yradius", 0);
    else
        xradius = CSGFactory.parseOptionAsFloat(options, "radius", 0);
        yradius = xradius;
    end
    local xaxisrotation = CSGFactory.parseOptionAsFloat(options, "xaxisrotation", 0);
    local clockwise = CSGFactory.parseOptionAsBool(options, "clockwise", false);
    local largearc = CSGFactory.parseOptionAsBool(options, "large", false);
    local startpoint = self.points[#self.points];
    endpoint = CSGVector2D:new():init(endpoint);
    -- round to precision in order to have determinate calculations
    xradius = mathext.round(xradius*decimals)/decimals;
    yradius = mathext.round(yradius*decimals)/decimals;
    endpoint = CSGVector2D:new():init(mathext.round(endpoint[1]*decimals)/decimals,mathext.round(endpoint[2]*decimals)/decimals);


    local sweep_flag = not clockwise;
    local newpoints = {};
    if ((xradius == 0) or (yradius == 0)) then
        -- http:--www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes:
        -- If rx = 0 or ry = 0, then treat this as a straight line from (x1, y1) to (x2, y2) and stop
        table.insert(newpoints,endpoint);
    else
        xradius = math.abs(xradius);
        yradius = math.abs(yradius);

        -- see http:--www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes :
        local phi = xaxisrotation * mathext.pi / 180.0;
        local cosphi = math.cos(phi);
        local sinphi = math.sin(phi);
        local minushalfdistance = startpoint:minus(endpoint):times(0.5);
        -- F.6.5.1:
        -- round to precision in order to have determinate calculations
        local x = mathext.round((cosphi * minushalfdistance[1] + sinphi * minushalfdistance[2])*decimals)/decimals;
        local y = mathext.round((-sinphi * minushalfdistance[1] + cosphi * minushalfdistance[2])*decimals)/decimals;
        local start_translated = CSGVector2D:new():init(x,y);
        -- F.6.6.2:
        local biglambda = (start_translated[1] * start_translated[1]) / (xradius * xradius) + (start_translated[2] * start_translated[2]) / (yradius * yradius);

        if (biglambda > 1.0) then
            -- F.6.6.3:
            local sqrtbiglambda = math.sqrt(biglambda);
            xradius = xradius * sqrtbiglambda;
            yradius = yradius * sqrtbiglambda;
            -- round to precision in order to have determinate calculations
            xradius = mathext.round(xradius*decimals)/decimals;
            yradius = mathext.round(yradius*decimals)/decimals;
        end
        -- F.6.5.2:
        local multiplier1 = math.sqrt((xradius * xradius * yradius * yradius - xradius * xradius * start_translated[2] * start_translated[2] - yradius * yradius * start_translated[1] * start_translated[1]) / (xradius * xradius * start_translated[2] * start_translated[2] + yradius * yradius * start_translated[1] * start_translated[1]));
        if (sweep_flag == largearc) then 
			multiplier1 = -multiplier1;
		end
        local center_translated = CSGVector2D:new():init(xradius * start_translated[2] / yradius, -yradius * start_translated[1] / xradius):times(multiplier1);
        -- F.6.5.3:
        local center = CSGVector2D:new():init(cosphi * center_translated[1] - sinphi * center_translated[2], sinphi * center_translated[1] + cosphi * center_translated[2]):plus((startpoint:plus(endpoint)):times(0.5));
        -- F.6.5.5:
        local vec1 = CSGVector2D:new():init((start_translated[1] - center_translated[1]) / xradius, (start_translated[2] - center_translated[2]) / yradius);
        local vec2 = CSGVector2D:new():init((-start_translated[1] - center_translated[1]) / xradius, (-start_translated[2] - center_translated[2]) / yradius);
        local theta1 = vec1:angleRadians();
        local theta2 = vec2:angleRadians();
        local deltatheta = theta2 - theta1;
        deltatheta = deltatheta % (2 * mathext.pi);
        if ((not sweep_flag) and (deltatheta > 0)) then
            deltatheta = deltatheta - 2 * mathext.pi;
        elseif ((sweep_flag) and (deltatheta < 0)) then
            deltatheta = deltatheta + 2 * mathext.pi;
        end

        -- Ok, we have the center point and angle range (from theta1, deltatheta radians) so we can create the ellipse
        local numsteps = math.ceil(math.abs(deltatheta) / (2 * mathext.pi) * resolution) + 1;
        if (numsteps < 1) then 
			numsteps = 1;
		end
		local step;
        for step = 1, numsteps, 1 do
            local theta = theta1 + step / numsteps * deltatheta;
            local costheta = math.cos(theta);
            local sintheta = math.sin(theta);
            -- F.6.3.1:
            local point = CSGVector2D:new():init(cosphi * xradius * costheta - sinphi * yradius * sintheta, sinphi * xradius * costheta + cosphi * yradius * sintheta):plus(center);
            table.insert(newpoints,point);
        end
	end
    newpoints = tableext.concat(self.points,newpoints);
    local result = CSGPath2D:new():init(newpoints);
    return result;
end

-- Expand the path to a CAG
-- This traces the path with a circle with radius pathradius
function CSGPath2D:expandToCAG(pathradius, resolution) 
    local sides = {};
    local numpoints = #self.points;
    local startindex = 1;
    if (self.closed and (numpoints > 2)) then
		startindex = 0;
	end
    local prevvertex;
	local i;
    for i = startindex, numpoints,1 do
        local pointindex = i;
        if (pointindex < 1) then
			pointindex = numpoints;
		end
        local point = self.points[pointindex];
        local vertex = CAGVertex:new():init(point);
        if (i > startindex) then
            local side = CAGSide:new():init(prevvertex, vertex);
            table.insert(sides,side);
        end
        prevvertex = vertex;
    end
    local shellcag = CAG.fromSides(sides);
    local expanded = shellcag:expandedShell(pathradius, resolution);
    return expanded;
end

-- Extrude the path by following it with a rectangle (upright, perpendicular to the path direction)
-- Returns a CSG solid
--   width: width of the extrusion, in the z=0 plane
--   height: height of the extrusion in the z direction
--   resolution: number of segments per 360 degrees for the curve in a corner
function CSGPath2D:rectangularExtrude(width, height, resolution) 
    local cag = self:expandToCAG(width / 2, resolution);
    local result = cag:toCSG(height);
    return result;
end

function CSGPath2D:innerToCAG() 
    if (not self.closed) then
		LOG.std(nil, "error", "CSGPath2D:innerToCAG", "The path should be closed!");
		return nil;
	end
    return CAG.fromPoints(self.points);
end

function CSGPath2D:transform(matrix4x4)
    local newpoints = {};
	for k,point in ipairs(self.points) do
        table.insert(newpoints, point:multiply4x4(matrix4x4));
    end
    return CSGPath2D:new():init(newpoints, self.closed);
end