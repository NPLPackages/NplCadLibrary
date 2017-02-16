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

NPL.load("(gl)Mod/NplCadLibrary/utils/commonlib_ext.lua");
-- include CAGVertex
NPL.load("(gl)script/ide/math/vector2d.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");

local vector2d = commonlib.gettable("mathlib.vector2d");
local CAGVertex = commonlib.gettable("Mod.NplCadLibrary.cag.CAGVertex");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");

-- we inherit from nil
local CAGSide = commonlib.inherit_ex(nil, commonlib.gettable("Mod.NplCadLibrary.cag.CAGSide"));

function CAGSide:ctor()
	self.vertex0 = self.vertex0 or CAGVertex:new();
	self.vertex1=  self.vertex1 or CAGVertex:new();
end

function CAGSide:init(vertex0, vertex1)
	self.vertex0:init(vertex0.pos);
	self.vertex1:init(vertex1.pos);
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

	for k,v in ipairs(polygon.vertices) do
		if (math.abs(v.pos[2]) - 1.0) > 0.001 then
			LOG.std(nil, "error", "CAGSide:_fromFakePolygon", "expects abs y values of 0.0001");
			return nil;
		end
		-- filter out when v.pos[3] <= 0
		if v.pos[2] > 0 then
			table.insert(vert1Indices,k);
			table.insert(pts2d,vector2d:new(v.pos[1], v.pos[3]));
        end
 	end
		
	if #pts2d ~= 2 then
		LOG.std(nil, "error", "CAGSide:_fromFakePolygon", "not enough points found");
		return nil;
    end
    local d = vert1Indices[2] - vert1Indices[1];
    if d == 1 or d == 3 then
        if d == 1 then
            pts2d = tableext.reverse(pts2d);
       end
    else
 		LOG.std(nil, "error", "CAGSide:_fromFakePolygon", "unknown index ordering");
		return nil;
    end
	return CAGSide:new():init( CAGVertex:new():init(pts2d[2]), CAGVertex:new():init(pts2d[1]));
end

function CAGSide:toPolygon3D(y0, y1) 
    local vertices = {
        CSGVertex:new():init(self.vertex0.pos:toVector3D(y0))	,
		CSGVertex:new():init(self.vertex0.pos:toVector3D(y1))	,
		CSGVertex:new():init(self.vertex1.pos:toVector3D(y1))	,
		CSGVertex:new():init(self.vertex1.pos:toVector3D(y0))
    };
    return CSGPolygon:new():init(vertices);
end

function CAGSide:flipped()
	-- because our memory mode,dot not swap instance only.
	local x,y = self.vertex0.pos:get();
	self.vertex0.pos:set(self.vertex1.pos);
	self.vertex1.pos:set(x,y);
	return self;
end

function CAGSide:direction()
    return self.vertex1.pos - self.vertex0.pos;
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
    self.vertex0.pos:transform(matrix4x4);
    self.vertex1.pos:transform(matrix4x4);
    return self;
end

