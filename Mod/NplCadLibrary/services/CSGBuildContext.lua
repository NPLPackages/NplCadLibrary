--[[
Title: CSGBuildContext
Author(s): leio
Date: 2017/3/7
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/CSGBuildContext.lua");
local CSGBuildContext = commonlib.gettable("Mod.NplCadLibrary.services.CSGBuildContext");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
local ArrayMap = commonlib.gettable("commonlib.ArrayMap");
local CSGBuildContext = commonlib.gettable("Mod.NplCadLibrary.services.CSGBuildContext");
CSGBuildContext.property_fields = ArrayMap:new();
CSGBuildContext.property_values = {};
CSGBuildContext.is_defined = false;
CSGBuildContext.input = {
	root = nil,-- the location of first file which is being built.
};
CSGBuildContext.output = {
	successful = nil,
	compile_error = nil,
	log = nil,
	csg_node_values = nil,
};

function CSGBuildContext.clear()
	CSGBuildContext.input = {};
	CSGBuildContext.output = {};
	CSGBuildContext.is_defined = false;
	CSGBuildContext.property_fields:clear();
	CSGBuildContext.property_values = {};
end
function CSGBuildContext.getFileRoot(filepath)
	if(not filepath)then return end
	local index = string.find(filepath, "/[^/]*$")
	local cur_dir = string.sub(filepath,1,index);
	return cur_dir;
end

local function write_logs(log_table)
	local logs = "";
	local log_table = log_table or {};
	local len = #log_table;
	while( len > 0) do
		local n = log_table[len];
		if(n)then
			logs = logs .. n .. "\n";
		end
		len = len - 1;
	end
	return logs;
end
function CSGBuildContext.getLogs()
	return write_logs(CSGBuildContext.output.log);
end
--[[
	{ type: "text", control: "text", required: ["index", "type", "name"], initial: "" },
	{ type: "int", control: "number", required: ["index", "type", "name"], initial: 0 },
	{ type: "float", control: "number", required: ["index", "type", "name"], initial: 0.0 },
	{ type: "number", control: "number", required: ["index", "type", "name"], initial: 0.0 },
	{ type: "checkbox", control: "checkbox", required: ["index", "type", "name", "checked"], initial: "" },
	{ type: "radio", control: "radio", required: ["index", "type", "name", "checked"], initial: "" },
	{ type: "color", control: "color", required: ["index", "type", "name"], initial: "#000000" },
	{ type: "date", control: "date", required: ["index", "type", "name"], initial: "" },
	{ type: "email", control: "email", required: ["index", "type", "name"], initial: "" },
	{ type: "password", control: "password", required: ["index", "type", "name"], initial: "" },
	{ type: "url", control: "url", required: ["index", "type", "name"], initial: "" },
	{ type: "slider", control: "range", required: ["index", "type", "name", "min", "max"], initial: 0, label: true },
--]]
--Only be defined once.
--@param property_list:a property table.
function CSGBuildContext.defineProperty(property_list)
	if(not property_list)then return end
	if(CSGBuildContext.is_defined)then
		return;
	end
	CSGBuildContext.is_defined = true;
	local k,v;
	for k,v in ipairs(property_list) do
		if(v.name)then
			CSGBuildContext.property_fields:add(v.name, v);
		end
	end
end
function CSGBuildContext.getPropertyValue(name)
	if(not name)then return end
	local value = CSGBuildContext.property_values[name];
	if(value ~= nil)then
		return value;
	end
	local node = CSGBuildContext.property_fields:get(name);
	if(node)then
		if(node.initial ~= nil)then
			return node.initial;
		end
	end
	return nil;
end
function CSGBuildContext.setPropertyValue(name,value)
	if(not name)then return end
	CSGBuildContext.property_values[name] = value;
end
function CSGBuildContext.setPropertyValueFromMap(values)
	if(not values)then return end
	local k,v;
	for k,v in pairs(values) do
		CSGBuildContext.setPropertyValue(k,v);
	end
end
function CSGBuildContext.getPropertyList()
	local result = {};
	for key, p in CSGBuildContext.property_fields:pairs() do
		if(key ~= "free_index")then
			p = commonlib.deepcopy(p);
			p.initial = CSGBuildContext.getPropertyValue(key);
			table.insert(result,p);
		end
	end
	return result;
end
