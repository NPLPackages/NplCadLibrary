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
local CSGBuildContext = commonlib.gettable("Mod.NplCadLibrary.services.CSGBuildContext");
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
