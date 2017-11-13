--[[
Title: Import_svg.lua
Author(s): leio
Date: 2017/6/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/interface/Import_svg.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

NPL.load("(gl)Mod/NplCadLibrary/core/Node.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/cag/CAG.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/SVGHelpers.lua");
local Node = commonlib.gettable("Mod.NplCadLibrary.core.Node");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CAGFactory = commonlib.gettable("Mod.NplCadLibrary.cag.CAGFactory");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");
local CAG = commonlib.gettable("Mod.NplCadLibrary.cag.CAG");
local XPath = commonlib.XPath
local SVGHelpers = commonlib.gettable("Mod.NplCadLibrary.utils.SVGHelpers");

local pi = NplCadEnvironment.pi;
local is_string = NplCadEnvironment.is_string;
local is_table = NplCadEnvironment.is_table;
local is_number = NplCadEnvironment.is_number;
local is_array = NplCadEnvironment.is_array;
local is_node = NplCadEnvironment.is_node;
local is_shape = NplCadEnvironment.is_shape;
local is_path = NplCadEnvironment.is_path;

function NplCadEnvironment.import_svg(filename)
	local self = getfenv(2);
	return self:import_svg__(filename);
end
function NplCadEnvironment:import_svg__(filename)
	local parent = self:getNode__();

	local node = NplCadEnvironment.read_import_svg(filename);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.read_import_svg(filename)
	commonlib.echo("=============read_import_svg");
	commonlib.echo(filename);

	local node
	if (not ParaIO.DoesFileExist(filename, false)) then
		commonlib.echo("File "..filename.." not exist!")
	else
		node = NplCadEnvironment.SVGParser(filename)
	end

	return node;
end

function NplCadEnvironment.SVGParser(filename)
	local node = Node.create("")
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename)
	if not xmlRoot then
		return node
	end

	--[[
	local svgObjectMap = {
		["svg"] = NplCadEnvironment.svgGroup,
		["rect"] = NplCadEnvironment.svgRect,
		["circle"] = NplCadEnvironment.svgCircle,
		["ellipse"] = NplCadEnvironment.svgEllipse,
		["line"] = NplCadEnvironment.svgLine,
		["polyline"] = NplCadEnvironment.svgPolyline,
		["polygon"] = NplCadEnvironment.svgPolygon,
		["path"] = NplCadEnvironment.svgPath,
		["use"] = NplCadEnvironment.svgUse,
		["defs"] = NplCadEnvironment.svgIgnored,
		["desc"] = NplCadEnvironment.svgIgnored,
		["title"] = NplCadEnvironment.svgIgnored,
		["style"] = NplCadEnvironment.svgIgnored,
	} ]]

	local svgObj = NplCadEnvironment.svgSvg(xmlRoot)
	if svgObj then
		node = NplCadEnvironment.svgGroup(xmlRoot) or node
		commonlib.echo("svgGroup")
		NplCadEnvironment.svgRect(xmlRoot, svgObj, node)
		NplCadEnvironment.svgCircle(xmlRoot, svgObj, node)
		NplCadEnvironment.svgEllipse(xmlRoot, svgObj, node)
		NplCadEnvironment.svgLine(xmlRoot, svgObj, node)
		NplCadEnvironment.svgPolyline(xmlRoot, svgObj, node)
		NplCadEnvironment.svgPolygon(xmlRoot, svgObj, node)
		NplCadEnvironment.svgPath(xmlRoot, svgObj, node)
	end

	return node
end

function NplCadEnvironment.svgSvg(xmlRoot)
	local svgObj
	local svgNode = XPath.selectNode(xmlRoot, "/svg")
	if (svgNode and svgNode.attr) then
		svgObj = svgObj or {}
		svgObj.pxPmm = svgNode.attr.pxpmm or SVGHelpers.pxPmm
		svgObj.unitsPmm = {svgObj.pxPmm, svgObj.pxPmm}
		svgObj.width= svgNode.attr.width
		svgObj.height= svgNode.attr.height

		local viewBox = svgNode.attr.viewBox
		if viewBox then
			local v1, v2, v3, v4 = string.match(viewBox, "[%s]*(.-)[%s,]+(.-)[%s,]+(.-)[%s,]+(.+)[%s,]*")
			svgObj.viewX = SVGHelpers.parseFloat(v1)
			svgObj.viewY = SVGHelpers.parseFloat(v2)
			svgObj.viewW = SVGHelpers.parseFloat(v3)
			svgObj.viewH = SVGHelpers.parseFloat(v4)
			
			if string.find(svgObj.width, "%%") then
				local u = svgObj.unitsPmm[1] * (SVGHelpers.parseFloat(svgObj.width) / 100.0)
				svgObj.unitsPmm[1] = u
			else
				local s = SVGHelpers.css2cag(svgObj.width, SVGHelpers.pxPmm)
				s = svgObj.viewW / s
				svgObj.unitsPmm[1] = s
			end

			if string.find(svgObj.height, "%%") then
				local u = svgObj.unitsPmm[2] * (SVGHelpers.parseFloat(svgObj.height) / 100.0)
				svgObj.unitsPmm[2] = u
			else
				local s = SVGHelpers.css2cag(svgObj.height, SVGHelpers.pxPmm)
				s = svgObj.viewH / s
				svgObj.unitsPmm[2] = s
			end
		else
			svgObj.viewX = 0
			svgObj.viewY = 0
			svgObj.viewW = 1920 / svgObj.unitsPmm[1] -- average screen size / pixels per unit
			svgObj.viewH = 1080 / svgObj.unitsPmm[2] -- screen size 1920 * 1080
		end
		svgObj.viewP = math.sqrt(svgObj.viewW * svgObj.viewW + svgObj.viewH * svgObj.viewH) / math.sqrt(2)
	end
	return svgObj
end

function NplCadEnvironment.svgGroup(xmlRoot, svgObj, node)
end

function NplCadEnvironment.svgRect(xmlRoot, svgObj, nodeGroup)
	for xmlNode in XPath.eachNode(xmlRoot, "/svg/rect") do
		commonlib.echo(xmlNode.name)
		if (xmlNode.attr) then
			local x = SVGHelpers.cagLengthX(xmlNode.attr.x, svgObj.unitsPmm, svgObj.viewW)
			local y = 0 - SVGHelpers.cagLengthY(xmlNode.attr.y, svgObj.unitsPmm, svgObj.viewH)
			local w = SVGHelpers.cagLengthX(xmlNode.attr.width, svgObj.unitsPmm, svgObj.viewW)
			local h = SVGHelpers.cagLengthY(xmlNode.attr.height, svgObj.unitsPmm, svgObj.viewH)
			local rx = SVGHelpers.cagLengthX(xmlNode.attr.rx, svgObj.unitsPmm, svgObj.viewW)
			local ry = SVGHelpers.cagLengthY(xmlNode.attr.ry, svgObj.unitsPmm, svgObj.viewH)
			if (w > 0 and h > 0) then
				x = x + w / 2
				y = y - h / 2
				if (rx > 0 and ry > 0) then
					rx = math.min(rx, ry)
				else
					rx = math.max(rx, ry)
				end
				local options = {center = {x, y}, radius = {w/2, h/2}, roundradius = rx, resolution = 32}
				local node = NplCadEnvironment.read_roundedRectangle(options)
				NplCadEnvironment.svgTransform(xmlNode, svgObj, node)
				nodeGroup:addChild(node)
			end
		end
	end
end

function NplCadEnvironment.svgCircle(xmlRoot, svgObj, nodeGroup)
	for xmlNode in XPath.eachNode(xmlRoot, "/svg/circle") do
		commonlib.echo(xmlNode.name)
		if (xmlNode.attr) then
			local x1 = SVGHelpers.cagLengthX(xmlNode.attr.cx, svgObj.unitsPmm, svgObj.viewW)
			local y1 = 0 - SVGHelpers.cagLengthY(xmlNode.attr.cy, svgObj.unitsPmm, svgObj.viewH)
			local radius = SVGHelpers.cagLengthP(xmlNode.attr.r, svgObj.unitsPmm, svgObj.viewP)

			if (radius > 0) then
				local options = {r = radius, center = {x1, y1}}
				local node = NplCadEnvironment.read_circle(options)
				NplCadEnvironment.svgTransform(xmlNode, svgObj, node)
				nodeGroup:addChild(node)
			end
		end
	end
end

function NplCadEnvironment.svgEllipse(xmlRoot, svgObj, nodeGroup)
	for xmlNode in XPath.eachNode(xmlRoot, "/svg/ellipse") do
		commonlib.echo(xmlNode.name)
		if (xmlNode.attr) then
			local x1 = SVGHelpers.cagLengthX(xmlNode.attr.cx, svgObj.unitsPmm, svgObj.viewW)
			local y1 = 0 - SVGHelpers.cagLengthY(xmlNode.attr.cy, svgObj.unitsPmm, svgObj.viewH)
			local rx = SVGHelpers.cagLengthP(xmlNode.attr.rx, svgObj.unitsPmm, svgObj.viewW)
			local ry = SVGHelpers.cagLengthP(xmlNode.attr.ry, svgObj.unitsPmm, svgObj.viewH)

			if (rx> 0 and ry > 0) then
				local options = {center = {x1, y1}, radius = {rx, ry}}
				commonlib.echo(options)
				local node = NplCadEnvironment.read_ellipse(options)
				NplCadEnvironment.svgTransform(xmlNode, svgObj, node)
				nodeGroup:addChild(node)
			end
		end
	end
end

function NplCadEnvironment.svgLine(xmlRoot, svgObj, nodeGroup)
	for xmlNode in XPath.eachNode(xmlRoot, "/svg/line") do
		commonlib.echo(xmlNode.name)
		if (xmlNode.attr) then
			local x1 = SVGHelpers.cagLengthX(xmlNode.attr.x1, svgObj.unitsPmm, svgObj.viewW)
			local y1 = 0 - SVGHelpers.cagLengthY(xmlNode.attr.y1, svgObj.unitsPmm, svgObj.viewH)
			local x2 = SVGHelpers.cagLengthX(xmlNode.attr.x2, svgObj.unitsPmm, svgObj.viewW)
			local y2 = 0 - SVGHelpers.cagLengthY(xmlNode.attr.y2, svgObj.unitsPmm, svgObj.viewH)

			local r = SVGHelpers.cssPxUnit
			if (xmlNode.attr.strokeWidth) then
				r = SVGHelpers.cagLengthP(xmlNode.attr.strokeWidth, svgObj.unitsPmm, svgObj.viewP) / 2
			else
				
			end
			local options = {{x1, y1}, {x2, y2}}
			local node = NplCadEnvironment.read_expandToCAG(r, NplCadEnvironment.path2d(options))
			NplCadEnvironment.svgTransform(xmlNode, svgObj, node)
			nodeGroup:addChild(node)
		end
	end
end

function NplCadEnvironment.svgPolyline(xmlRoot, svgObj, nodeGroup)
	for xmlNode in XPath.eachNode(xmlRoot, "/svg/polyline") do
		if (xmlNode.attr and xmlNode.attr.points) then
			commonlib.echo(xmlNode.attr.points)
			local options = {}
			local points = commonlib.split(xmlNode.attr.points, " ")
			for i = 0, #points do
				local v = commonlib.split(points[i], ",")
				local x = tonumber(v[1])
				local y = tonumber(v[2])
				if (x and y) then
					x = SVGHelpers.cagLengthX(x, svgObj.unitsPmm, svgObj.viewW)
					y = 0 - SVGHelpers.cagLengthY(y, svgObj.unitsPmm, svgObj.viewH)
					commonlib.echo("points: "..x..", "..y)
					table.insert(options, {x, y})	
				end
			end

			local r = SVGHelpers.cssPxUnit
			if (xmlNode.attr.strokeWidth) then
				r = SVGHelpers.cagLengthP(xmlNode.attr.strokeWidth, svgObj.unitsPmm, svgObj.viewP) / 2
			else
				
			end
			local node = NplCadEnvironment.read_expandToCAG(r, NplCadEnvironment.path2d(options))
			NplCadEnvironment.svgTransform(xmlNode, svgObj, node)
			nodeGroup:addChild(node)
		end
	end
end

function NplCadEnvironment.svgPolygon(xmlRoot, svgObj, nodeGroup)
	for xmlNode in XPath.eachNode(xmlRoot, "/svg/polygon") do
		if (xmlNode.attr and xmlNode.attr.points) then
			commonlib.echo(xmlNode.attr.points)
			local options = {}
			local points = commonlib.split(xmlNode.attr.points, ", ")
			for i = 1, (#points)-1, 2 do
				local x = tonumber(points[i])
				local y = tonumber(points[i + 1])
				if (x and y) then
					x = SVGHelpers.cagLengthX(x, svgObj.unitsPmm, svgObj.viewW)
					y = 0 - SVGHelpers.cagLengthY(y, svgObj.unitsPmm, svgObj.viewH)
					commonlib.echo("points: "..x..", "..y)
					table.insert(options, {x, y})	
				end
			end

			local node = NplCadEnvironment.read_innerToCAG(NplCadEnvironment.path2d({points = options, closed = true}))
			NplCadEnvironment.svgTransform(xmlNode, svgObj, node)
			nodeGroup:addChild(node)
		end
	end
end

function NplCadEnvironment.svgPath(xmlRoot, svgObj, nodeGroup)
	for xmlNode in XPath.eachNode(xmlRoot, "/svg/path") do
		if (xmlNode.attr and xmlNode.attr.d) then
			commonlib.echo(xmlNode.attr.d)
			local path
			local bf = ""
			local command
			for i = 1, #xmlNode.attr.d do
				local c = string.sub(xmlNode.attr.d, i, i)
				if (c == '-') then
					if (#bf > 0) then
						table.insert(path[command], bf)
						bf = ""
					end
					bf = bf..c
				elseif (c == '.') then
					if (#bf > 0 and string.find(bf, "%.")) then
						table.insert(path[command], bf)
						bf = ""
					end
					bf = bf..c
				elseif (c >= '0' and c <= '9') then
					bf = bf..c
				elseif ((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z')) then
					if (path) then
						if (#bf > 0) then
							table.insert(path[command], bf)
							bf = ""
						end
					else
						path = {}
					end
					command = c
					path[command] = {}
				elseif (c == ',' or c == ' ' or c == '\n') then
					if (path) then
						if (#bf > 0) then
							table.insert(path[command], bf)
							bf = ""
						end
					end
				else
					commonlib.echo("warnning: the path has invalid data")
				end
			end

			if (path) then
				if (#bf > 0) then
					table.insert(path[command], bf)
				end
			end
		end
	end
end

function NplCadEnvironment.readSvgPath(obj, svgObj)
	local r = SVGHelpers.cssPxUnit
	if (xmlNode.attr.strokeWidth) then
		r = SVGHelpers.cagLengthP(xmlNode.attr.strokeWidth, svgObj.unitsPmm, svgObj.viewP) / 2
	else
	end

	local paths = {}
	local on = ""
	local sx = 0 sy = 0 cx = 0 cy = 0
	local pi = 1 pc = false
	local bx = 0 by = 0 qx = 0 qy = 0

	local begin = true
	for command, points in pairs(obj) do
		if (command == 'm') then
			if (begin) then cx = 0 cy = 0 end
			if (pi > 1 and (not pc)) then
				NplCadEnvironment.read_expandToCAG(paths[pi])	
			end

			if (#points >= 2) then
				cx = cx + SVGHelpers.parseFloat(points[1])
				cy = cy + SVGHelpers.parseFloat(points[2])
				pi = pi + 1
				pc = false
				paths[pi] = NplCadEnvironment.path2d(
					{points = {SVGHelpers.svg2cagX(cx, svgObj.unitsPmm), SVGHelpers.svg2cagY(cy, svgObj.unitsPmm)}, closed = false})
				sx = cx
				sy = cy
			end
			

		elseif (command == 'M') then
		elseif (command == 'a') then
		elseif (command == 'A') then
		elseif (command == 'c') then
		elseif (command == 'C') then
		elseif (command == 'q') then
		elseif (command == 'Q') then
		elseif (command == 't') then
		elseif (command == 'T') then
		elseif (command == 's') then
		elseif (command == 'S') then
		elseif (command == 'h') then
		elseif (command == 'H') then
		elseif (command == 'l') then
		elseif (command == 'L') then
		elseif (command == 'v') then
		elseif (command == 'V') then
		elseif (command == 'z') then
		elseif (command == 'Z') then
		else
			commonlib.echo("Warning: Unknow PATH command: "..command)
		end
	end
end

function NplCadEnvironment.svgUse(xmlRoot, svgObj, nodeGroup)
end

function NplCadEnvironment.svgIgnored(xmlRoot, svgObj, nodeGroup)
end

function NplCadEnvironment.svgTransform(xmlNode, svgObj, node)
	local transform = xmlNode.attr.transform
	transform = transform or SVGHelpers.cssStyle(xmlNode, "transform")
	if (not transform) then return end

	-- do scale
	local scale = commonlib.split(string.match(transform, "%s*scale%s*%(%s*(.-)%s*%)"), ", ")
	if (#scale > 0) then
		commonlib.echo(scale)
		local x = tonumber(scale[1])
		local y = tonumber(scale[2])
		x = x or 1
		y = y or x
		NplCadEnvironment:scale__({x, y, 1}, node)
	end

	-- do rotate
	local rotate = commonlib.split(string.match(transform, "%s*rotate%s*%(%s*(.-)%s*%)"), ", ")
	if (#rotate > 0) then
		commonlib.echo(rotate)
		local x = tonumber(rotate[1])
		x = x or 0
		NplCadEnvironment:rotate__({0, 0, x}, node)
	end

	-- do translate
	local translate = commonlib.split(string.match(transform, "%s*translate%s*%(%s*(.-)%s*%)"), ", ")
	if (#translate > 0) then
		commonlib.echo(translate)
		local x = tonumber(translate[1])
		local y = tonumber(translate[2])
		x = SVGHelpers.cagLengthX(x, svgObj.unitsPmm, svgObj.viewW)
		y = 0 - SVGHelpers.cagLengthY(y, svgObj.unitsPmm, svgObj.viewH)
		NplCadEnvironment:translate__(x, y, 0, node)
	end
end
