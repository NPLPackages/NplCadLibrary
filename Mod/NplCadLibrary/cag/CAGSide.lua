--[[
Title: CAGSide
Skeleton
Date: 2016/11/26
Desc: 
	side is a line between 2 points (initialize with CAGVertex)
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGSide.lua");
local CAGSide = commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide");
-------------------------------------------------------
--]]

-- include CAGVertex
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector2D.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");

local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CSGVector2D = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector2D");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");

-- we inherit from nil
local CAGSide = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide"));

function CAGSide:ctor()
	
end

function CAGSide:init(vertex0, vertex1)
	self.vertex0 = vertex0 or self.vertex0;
	self.vertex1 = vertex1 or self.vertex1;
	return self;
end

function CAGSide._fromFakePolygon(polygon)
    --[[
		FakePolygon: should be came from CAGSide.
		expects abs z values of 0.0001 for all vertices
		vertrices count should be 4
	--]]

	--this can happen based on union, seems to be residuals -
    --return null and handle in caller
    if #polygon.vertices ~= 4 then
		LOG.std(nil, "error", "CAGSide:_fromFakePolygon", "polygon.vertices should be 4");
        return nil;
    end

    local reverse = false;
    local vert1Indices = {};
	local pts2d = {}

	for k,v in polygon.vertices do
		if math.abs(v.pos[3] - 0.0001) > tonumber("1e-5") then
			LOG.std(nil, "error", "CAGSide:_fromFakePolygon", "expects abs z values of 0.0001");
			return nil;
		end
		-- filter out when v.pos[3] <= 0
		if v.pos[3] > 0 then
			table.insert(vert1Indices,k);
			table.insert(pts2d,CSGVector2D:new():init(v.pos[1], v.pos[2]));
        end
 	end
		
	if #pts2d ~= 2 then
		LOG.std(nil, "error", "CAGSide:_fromFakePolygon", "not enough points found");
		return nil;
    end
    local d = vert1Indices[2] - vert1Indices[1];
    if d == 1 or d == 3 then
        if d == 1 then
            pts2d:reverse();
       end
    else
 		LOG.std(nil, "error", "CAGSide:_fromFakePolygon", "unknown index ordering");
		return nil;
    end
	local result = CAGSide:new():init( CAGVertex:new():init(pts2d[1]), CAGVertex:new():init(pts2d[2]));
    return result;
end

function CAGSide:toPolygon3D(y0, y1) 
    local vertices = {
        CSGVertex:new():init(self.vertex0.pos:toVector3D(y0))	,
		CSGVertex:new():init(self.vertex1.pos:toVector3D(y0))	,
		CSGVertex:new():init(self.vertex1.pos:toVector3D(y1))	,
		CSGVertex:new():init(self.vertex0.pos:toVector3D(y1))	
    };
    return CSGPolygon:new():init(vertices);
end

function CAGSide:flipped()
	return CAGSide:new():init(self.vertex1, self.vertex0);
end

function CAGSide:direction()
    return self.vertex1.pos:minus(self.vertex0.pos);
end

function CAGSide:lengthSquared()
	local x = self.vertex1.pos[1] - self.vertex0.pos[1];
	local y = self.vertex1.pos[2] - self.vertex0.pos[2];
	return x * x + y * y;
end

function CAGSide:length()
	return math.sqrt(self:lengthSquared());
end

function CAGSide:transform(matrix4x4)
    local newp1 = self.vertex0.pos:transform(matrix4x4);
    local newp2 = self.vertex1.pos:transform(matrix4x4);
    return CAGSide:new():init(CAGVertex:new():init(newp1), CAGVertex:new():init(newp2));
end

