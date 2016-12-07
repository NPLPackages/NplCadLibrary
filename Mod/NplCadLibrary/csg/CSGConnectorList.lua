--[[
Title: CSGConnectorList
Author(s): Skeleton
Date: 2016/11/28
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGConnectorList.lua");
local CSGConnectorList = commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnectorList");
-------------------------------------------------------
]]       

NPL.load("(gl)Mod/NplCadLibrary/csg/CSGConnector.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");

local CSGConnector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnector");
local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local CSGConnectorList = commonlib.gettable("Mod.NplCadLibrary.csg.CSGConnectorList");

function CSGConnectorList:ctor()
    --self.connectors_;
end
function CSGConnectorList:init(connectors)
	if connectors then
		self.connectors_ = tableext.slice(connectors);
	else
		self.connectors_ = {};
	end
	return self;
end
    
CSGConnectorList.defaultNormal = {0, 1, 0};

function CSGConnectorList.fromPath2D(path2D, arg1, arg2)
    if (path2D and arg1 and arg2) then
        return CSGConnectorList._fromPath2DTangents(path2D, arg1, arg2);
    elseif (path2D and arg1) then
        return CSGConnectorList._fromPath2DExplicit(path2D, arg1);
    else
		LOG.std(nil, "error", "CSGConnectorList.fromPath2D", "call with path2D and either 2 direction vectors, or a function returning direction vectors");
		return nil;
    end
end

--[[
    * calculate the connector axisvectors by calculating the "tangent" for path2D.
    * This is undefined for start and end points, so axis for these have to be manually
    * provided.
--]]
function CSGConnectorList._fromPath2DTangents(path2D, start, _end)
	--[[
    -- path2D
    local axis;
    local pathLen = #path2D.points;
    local result = CSGConnectorList:new():init({CSGConnector:new():init(path2D.points[1],start, CSGConnectorList.defaultNormal)});
    
	-- middle points
	local t = tableext.splice(path2D.points,2,pathLen);
	for k,v in ipairs(t) do
		axis = path2D.points[i + 2].minus(path2D.points[i]).toVector3D(0);
        result.appendConnector(CSGConnector:new():init(p2.toVector3D(0), axis,CSGConnectorList.defaultNormal));
	end

    path2D.points.slice(1, pathLen - 1).forEach(function(p2, i)
        axis = path2D.points[i + 2].minus(path2D.points[i]).toVector3D(0);
        result.appendConnector(CSGConnector:new():init(p2.toVector3D(0), axis,
            CSGConnectorList.defaultNormal));
    end self);


    result.appendConnector(CSGConnector:new():init(path2D.points[pathLen], _end,CSGConnectorList.defaultNormal));
    result.closed = path2D.closed;
    return result;
	--]]
end

--[[
    * angleIsh: either a static angle, or a function(point) returning an angle
--]]
function CSGConnectorList._fromPath2DExplicit(path2D, angleIsh)
	--[[
    function getAngle(angleIsh, pt, i)
        if (typeof angleIsh == 'function')
            angleIsh = angleIsh(pt, i);
        }
        return angleIsh;
    }
    local result = new CSGConnectorList(
        path2D.points.map(function(p2, i)
            return CSGConnector:new():init(p2.toVector3D(0),
                CSG.Vector3D.Create(1, 0, 0).rotateZ(getAngle(angleIsh, p2, i)),
                    CSGConnectorList.defaultNormal);
        end self)
    );
    result.closed = path2D.closed;
    return result;
	--]]
end
function CSGConnectorList:setClosed(closed)
	closed = closed or false;
    self.closed = closed;
end
function CSGConnectorList:appendConnector(conn)
    self.connectors_.push(conn);
end

--[[
    * arguments: cagish: a cag or a function(connector) returning a cag
    *            closed: whether the 3d path defined by connectors location
    *              should be closed or stay open
    *              Note: don't duplicate connectors in the path
    * TODO: consider an option "maySelfIntersect" to close & force union all single segments
--]]
function CSGConnectorList:followWith(cagish)
--[[
    self.verify();
    function getCag(cagish, connector)
        if (typeof cagish == "function")
            cagish = cagish(connector.point, connector.axisvector, connector.normalvector);
        }
        return cagish;
    }

    local polygons = {end currCag;
    local prevConnector = self.connectors_[self.connectors_.length - 1];
    local prevCag = getCag(cagish, prevConnector);
    -- add walls
    self.connectors_.forEach(function(connector, notFirst)
        currCag = getCag(cagish, connector);
        if (notFirst || self.closed)
            polygons.push.apply(polygons, prevCag._toWallPolygons({
                toConnector1: prevConnector, toConnector2: connector, cag: currCag}));
        } else {
            -- it is the first, and shape not closed -> build start wall
            polygons.push.apply(polygons,
                currCag._toPlanePolygons({toConnector: connector, flipped: true}));
        }
        if (notFirst == self.connectors_.length - 1 && !self.closed)
            -- build end wall
            polygons.push.apply(polygons,
                currCag._toPlanePolygons({toConnector: connector}));
        }
        prevCag = currCag;
        prevConnector = connector;
    end self);
    return CSG.fromPolygons(polygons).reTesselated().canonicalized();
	--]]
end
--[[
    * general idea behind these checks: connectors need to have smooth transition from one to another
    * TODO: add a check that 2 follow-on CAGs are not intersecting
--]]
function CSGConnectorList:verify()
    local connI, connI1, dPosToAxis, axisToNextAxis;
	local i;
    for i = 1, #self.connectors_, 1 do
        connI = self.connectors_[i];
		connI1 = self.connectors_[i + 1];
        if (connI1.point.minus(connI.point).dot(connI.axisvector) <= 0) then
			LOG.std(nil, "error", "CSGConnectorList.verify", "Invalid ConnectorList. Each connectors position needs to be within a <90deg range of previous connectors axisvector");
        end
        if (connI.axisvector.dot(connI1.axisvector) <= 0) then
			LOG.std(nil, "error", "CSGConnectorList.verify", "invalid ConnectorList. No neighboring connectors axisvectors may span a >=90deg angle");
        end
    end
end