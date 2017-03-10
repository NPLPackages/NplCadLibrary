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
  { name: 'balloon', type: 'group', caption: 'Balloons' }, 
    { name: 'checkbox', type: 'checkbox', checked: true, initial: '20', caption: 'Big?' }, 
    { name: 'color', type: 'color', initial: '#FFB431', caption: 'Color?' }, 
    { name: 'count', type: 'slider', initial: 3, min: 2, max: 10, step: 1, caption: 'How many?' }, 
    { name: 'friend', type: 'group', caption: 'Friend' }, 
    { name: 'name', type: 'text', initial: '', size: 20, maxLength: 20, caption: 'Name?', placeholder: '20 characters' }, 
    { name: 'date',  type: 'date', initial: '', min: '1915-01-01', max: '2015-12-31', caption: 'Birthday?', placeholder: 'YYYY-MM-DD' }, 
    { name: 'age', type: 'int', initial: 20, min: 1, max: 100, step: 1, caption: 'Age?' }, 
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
	for key, value in CSGBuildContext.property_fields:pairs() do
		if(key ~= "free_index")then
			table.insert(result,value);
		end
	end
	return result;
end