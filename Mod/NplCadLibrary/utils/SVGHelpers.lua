--[[
Title: SVGHelpers
Author(s): chenjinxian 
Date: 2017/11/10
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/utils/SVGHelpers.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/utils/mathext.lua");
local mathext = commonlib.gettable("Mod.NplCadLibrary.utils.mathext");
local SVGHelpers = commonlib.gettable("Mod.NplCadLibrary.utils.SVGHelpers");

SVGHelpers.pxPmm = 1 / 0.2822222 -- used for scaling SVG coordinates(PX) to CAG coordinates(MM)
SVGHelpers.inchMM = 1 / (1 / 0.039370) -- used for scaling SVG coordinates(IN) to CAG coordinates(MM)
SVGHelpers.ptMM = 1 / (1 / 0.039370 / 72) -- used for scaling SVG coordinates(IN) to CAG coordinates(MM)
SVGHelpers.pcMM = 1 / (1 / 0.039370 / 72 * 12) -- used for scaling SVG coordinates(PC) to CAG coordinates(MM)
SVGHelpers.cssPxUnit = 0.2822222 -- standard pixel size at arms length on 90dpi screens

function SVGHelpers.svg2cagX(v, svgUnitsPmm)
	return (v / svgUnitsPmm[1])
end

function SVGHelpers.svg2cagY(v, svgUnitsPmm)
	return 0 - (v / svgUnitsPmm[2])
end

function SVGHelpers.cagLengthX(css, svgUnitsPmm, svgUnitsX)
	if not css then return 0.0 end
	if not string.find(css, "%%") then
		return SVGHelpers.css2cag(css, svgUnitsPmm[1])
	else
		local v = SVGHelpers.parseFloat(css)
		if not v then return 0.0 end
		if v == 0 then return v end

		v = v * svgUnitsX / 100
		v = v / svgUnitsPmm[1]
		return mathext.round(v / -100000) * -100000
	end
end

function SVGHelpers.cagLengthY(css, svgUnitsPmm, svgUnitsY)
	if not css then return 0.0 end
	if not string.find(css, "%%") then
		return SVGHelpers.css2cag(css, svgUnitsPmm[2])
	else
		local v = SVGHelpers.parseFloat(css)
		if not v then return 0.0 end
		if v == 0 then return v end

		v = v * svgUnitsY / 100
		v = v / svgUnitsPmm[2]
		return mathext.round(v / -100000) * -100000
	end
end

function SVGHelpers.cagLengthP(css, svgUnitsPmm, svgUnitsV)
	if not css then return 0.0 end
	if not string.find(css, "%%") then
		return SVGHelpers.css2cag(css, svgUnitsPmm[2])
	else
		local v = SVGHelpers.parseFloat(css)
		if not v then return 0.0 end
		if v == 0 then return v end

		v = v * svgUnitsV / 100
		v = v / svgUnitsPmm[1]
		return v
	end
end

function SVGHelpers.css2cag(css, unit)
	local v = SVGHelpers.parseFloat(css)
	if not v then return 0.0 end
	if v == 0 then return v end

	if string.match(css, "EM") then
		-- v = v
	elseif string.match(css, "EX") then
		-- v = v
	elseif string.match(css, "MM") then
		-- v = v
	elseif string.match(css, "CM") then
		v = v * 10
	elseif string.match(css, "IN") then
		v = v / SVGHelpers.inchMM
	elseif string.match(css, "PT") then
		v = v / SVGHelpers.ptMM
	elseif string.match(css, "PC") then
		v = v / SVGHelpers.pcMM
	else
		v = v / unit
	end
	
	return v
end

function SVGHelpers.cssStyle(xmlNode, name)
	local v
	local style = xmlNode.attr.style
	if (style) then
		v = string.match(style, name.."%s*:%s*(.-);")
	end
	return v
end

function SVGHelpers.reflect(x, y, px, py)
	local ox = x - px
	local oy = y - py
	if (x == px and y == py) then return x, y end
	if (x == px) then return x, py - oy end
	if (y == py) then return px - ox, y end
	return px - ox, py - oy
end

function SVGHelpers.groupValue(svgGroups, name)
end

function SVGHelpers.parseFloat(str)
	if (type(str) == "number") then
		return str
	elseif (type(str) == "string") then
		local v = tonumber(str)
		if (not v) then
			local n = #str
			for i = #str, 1, -1 do
				local c = string.sub(str, i, i)
				if (c >= '0' and c <= '9') then n = i break end
			end
			commonlib.echo(str)
			str = string.sub(str, 1, n)
			commonlib.echo(str)
			v = tonumber(str)
		end
		return v			
	else
		return nil
	end
end