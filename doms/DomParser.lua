--[[
Title: DomParser
Author(s):  leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)npl_packages/NplCadLibrary/doms/DomParser.lua");
local DomParser = commonlib.gettable("NplCad.doms.DomParser");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)npl_packages/NplCadLibrary/doms/DomScene.lua");
NPL.load("(gl)npl_packages/NplCadLibrary/doms/DomNode.lua");
NPL.load("(gl)npl_packages/NplCadLibrary/doms/DomCSGModel.lua");
local DomScene = commonlib.gettable("NplCad.doms.DomScene");
local DomNode = commonlib.gettable("NplCad.doms.DomNode");
local DomCSGModel = commonlib.gettable("NplCad.doms.DomCSGModel");
local DomParser = commonlib.gettable("NplCad.doms.DomParser");
DomParser.parsers = {};
function DomParser.initParser()
	if(not DomParser.is_init)then
		DomParser.is_init = true;
		
		DomParser.parsers["Scene"] = DomScene:new();
		DomParser.parsers["Node"] = DomNode:new();
		DomParser.parsers["Model"] = DomCSGModel:new();


	end
end
function DomParser.getParser(name)
	if(not name)then
		return;
	end
	return DomParser.parsers[name];
end
function DomParser.loadStr(content)
	local xmlRoot = ParaXML.LuaXML_ParseString(content);
	return DomParser.loadNode(xmlRoot);
end
function DomParser.load(filename)
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	return DomParser.loadNode(xmlRoot);
end
function DomParser.write(root_node)
	DomParser.initParser();
	if(not root_node)then
		return
	end
	local s = DomParser.write_internal(root_node);
	s = string.format(
[[<!--nplcad-->
%s
]],s);
	return s
end
function DomParser.write_internal(root_node)
	DomParser.initParser();
	if(not root_node)then
		return
	end
	local name = root_node:getTypeName();
	local p = DomParser.getParser(name);
	local s = p:write(root_node);
	return s
end
function DomParser.writeToFile(filename,obj)
	if(not filename)then
		return;
	end
	ParaIO.CreateDirectory(filename);
	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		file:WriteString(DomParser.write(obj) or "");
		file:close();
	end
end
function DomParser.loadNode(xmlnode)
	DomParser.initParser();
	if(xmlnode) then
		local obj;
		local len = #xmlnode;
		for k = 1,len do
			local node = xmlnode[k];
			local p = DomParser.getParser(node.name);
			if(p)then
				obj = p:read(node);
				return obj;
			else
				obj = DomParser.loadNode(node)
			end
		end
		return obj;
	end
end
function DomParser.write_children(obj)
	local output_str = "";
	if(obj)then
		local name = obj:getTypeName();
		if(obj.getFirstChild)then
			local child = obj:getFirstChild();
			while(child) do
				local child_name = child:getTypeName();
				local p = DomParser.getParser(child_name);
				output_str = output_str .. p:write(child);
				child = child:getNextSibling();
			end
		end
	end
	return output_str;
end

