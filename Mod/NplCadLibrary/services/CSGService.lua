--[[
Title: CSGService 
Author(s): leio
Date: 2016/8/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/services/CSGService.lua");
local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local output = CSGService.buildPageContent("cube();")
commonlib.echo(output);
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGMatrix4x4.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/NplCadEnvironment.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGMatrix4x4");
local CSGMatrix4x4 = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local math3d = commonlib.gettable("mathlib.math3d");
local NplCadEnvironment = commonlib.gettable("Mod.NplCadLibrary.services.NplCadEnvironment");

function CSGService.operateTwoNodes(pre_drawable_node,cur_drawable_node,drawable_action)
	local bResult = false;
	if(pre_drawable_node and cur_drawable_node)then
		if(drawable_action == "union")then
			cur_drawable_node = pre_drawable_node:union(cur_drawable_node);
			bResult = true;
		elseif(drawable_action == "difference")then
			cur_drawable_node = pre_drawable_node:subtract(cur_drawable_node);
			bResult = true;
		elseif(drawable_action == "intersection")then
			cur_drawable_node = pre_drawable_node:intersect(cur_drawable_node);
			bResult = true;
		else
			-- Default action is "union".
			--cur_drawable_node = pre_drawable_node:union(cur_drawable_node);
		end
	end
	return cur_drawable_node,bResult;
end

-- find tag value in all of its parent recursively
-- @return tagValue, sceneNode: if no tagValue is found, the sceneNode is the rootNode.
function CSGService.findTagValue(node,name)
	if(not node)then
		return
	end
	local p = node;
	local lastNode;
	while(p) do
		local v = p:getTag(name);
		if(v)then
			return v,p;
		end
		lastNode = p;
		p = p:getParent();
	end
	return nil, lastNode;
end

function CSGService.equalsColor(color_1,color_2)
	return color_1 and color_2 and (color_1[1] == color_2[1] and color_1[2] == color_2[2] and color_1[3] == color_2[3]);
end
-- build code from an existed file.
function CSGService.buildFile(filepath)
	if(not filepath)then
		return
	end
	local full_path = ParaIO.GetCurDirectory(0)..filepath;
	local file = ParaIO.open(full_path, "r");
	if(file:IsValid()) then
		local text = file:GetText();
		file:close();
		return CSGService.buildPageContent(text);
	end
end
--[[
	return {
		successful = successful,
		csg_node_values = csg_node_values,
		compile_error = compile_error,
		log = string, 
	}
--]]
function CSGService.buildPageContent(code)
	code = CSGService.appendLoadXmlFunction(code)
	if(not code or code == "") then
		return;
	end
	local output = {}
	local code_func, errormsg = loadstring(code);
	if(code_func) then
		local fromTime = ParaGlobal.timeGetTime();
		LOG.std(nil, "info", "CSG", "\n------------------------------\nbegin render scene\n");

		local env = NplCadEnvironment:new();
		setfenv(code_func, env);
		local ok, result = pcall(code_func);
		if(ok) then
			if(type(env.main) == "function") then
				setfenv(env.main, env);
				ok, result = pcall(env.main);
			end
		end
		CSGService.scene = env.scene;
		env.scene:log("finished compile scene in %.3f seconds", (ParaGlobal.timeGetTime()-fromTime)/1000);
		LOG.std(nil, "info", "CSG", "\nfinished compile scene in %.3f seconds\n", (ParaGlobal.timeGetTime()-fromTime)/1000);
		
		local render_list = CSGService.getRenderList(env.scene)

		env.scene:log("finished render scene in %.3f seconds", (ParaGlobal.timeGetTime()-fromTime)/1000);
		LOG.std(nil, "info", "CSG", "\n\nfinished render scene in %.3f seconds\n------------------------------", (ParaGlobal.timeGetTime()-fromTime)/1000);

		output.successful = ok;
		output.csg_node_values = render_list;
		output.compile_error = result;
		output.log = table.concat(env.scene:GetAllLogs() or {}, "\n");

	else
		output.successful = false;
		output.compile_error =  errormsg;
		output.log = errormsg;
	end
	return output;
end
function CSGService.appendLoadXmlFunction(code)
	if(code)then
		local first_line;
		for line in string.gmatch(code,"[^\r\n]+") do
			first_line = line;
			break;
		end
		if(first_line)then
			if(string.find(first_line,"nplcad"))then
				code = string.format("loadXml([[%s]])",code);
				return code;
			end
		end
		return code;
	end
end

function CSGService.getRenderList(scene)
	if(not scene)then
		return
	end
	
	-- apply color to drawable.
	local function applyColor(node,drawable)
		local color = CSGService.findTagValue(node,"color");
		if(color)then
			drawable:setColor(color);
		end
	end

	local function BeforeChildVisit_(node)
		node:getWorldMatrix();
		
		local actionName, actionNode = CSGService.findTagValue(node,"csg_action");
		local drawable = node:getDrawable();
		if(drawable and drawable:getModelNode())then
			applyColor(node,drawable);
			actionNode:pushActionParam(drawable);
			LOG.std(nil, "info", "CSG", "begin drawable_node with %d polygons/sides", drawable:getElements());
		else
			LOG.std(nil, "info", "CSG", "begin node with (%s) tag", node:getTag("csg_action") or "empty");
		end
	end

	local function AfterChildVisit_(node)
		local action_params = node:popAllActionParams();
		if(action_params) then
			local actionName = node:getTag("csg_action");
			local fromTime = ParaGlobal.timeGetTime();
			local result_drawable = CSGService.doDrawablelAction(actionName, action_params,node);
			LOG.std(nil, "info", "CSG", "drawable_node action (%s: with %d nodes) finished in %.3f seconds with %d polygons(sides)", 
				actionName or "none", action_params and #action_params or 0, 
				(ParaGlobal.timeGetTime()-fromTime)/1000, result_drawable and result_drawable:getElements() or 0);
			local actionName, actionNode = CSGService.findTagValue(node:getParent() or scene,"csg_action");
			if(actionNode ~= node) then
				-- result_drawable is build from other drawables,it's node hasn't apply yet.then apply it before be pushed. 
				result_drawable:setNode(node);
				applyColor(node,result_drawable);
				actionNode:pushActionParam(result_drawable);
			end
		end
	end

	scene:visit(BeforeChildVisit_, AfterChildVisit_);

	-- convert all resulting drawable_nodes to meshes
	local render_list = {};

	local result = scene:popAllActionParams();
	if(result) then
		for i = 1, #result do
			local world_matrix,vertices,indices,normals,colors = result[i]:toMesh();
			table.insert(render_list,{
				world_matrix = world_matrix,
				vertices = vertices,
				indices = indices,
				normals = normals,
				colors = colors,
			});
		end
	end
	
	return render_list;
end

-- @param csg_action: name of the operation. 
-- @param drawable_nodes: array of csg node operands
-- @return csgNode, bSucceed:  csgNode is the result.
function CSGService.doDrawablelAction(drawable_action, drawable_nodes, operation_node)
	local len = #drawable_nodes;
	if(len == 0)then
		return;
	end
	local first_node = drawable_nodes[1];
	local first_node_transform = first_node:applyTransform(operation_node);
	local result_node = first_node;
	local bSucceed = true;
	for i=2, len do
		local drawable_node_transform = drawable_nodes[i]:applyTransform(operation_node);

		result_node, bSucceed = CSGService.operateTwoNodes(result_node, drawable_nodes[i], drawable_action);
		if(not bSucceed) then
			break;
		end
	end
	return result_node, bSucceed;
end

function CSGService.visitNode(node,input_params)
	if(not node)then return end
	local nodes_map = input_params.nodes_map;
	if(nodes_map[node]["drawable_node"])then
		return
	end
	local child = node:getFirstChild();
	local top_csg_action = CSGService.findTagValue(node,"csg_action");
	local temp_list = {};
	while(child) do
		local drawable_node = nodes_map[child]["drawable_node"];
		if(drawable_node)then
			if(top_csg_action)then
				table.insert(temp_list,{
					drawable_node = drawable_node,
				});	
			else
				table.insert(input_params.result,{
					drawable_node = drawable_node,
				});	
			end
			
		end
		nodes_map[child]["drawable_node"] = nil;
		child = child:getNextSibling();
	end	
	local drawable_node = CSGService.doCSGOperation(top_csg_action, temp_list);
	nodes_map[node]["drawable_node"] = drawable_node;
end

-- Read csg code from a file.
function CSGService.readFile(filepath)
	if(not filepath)then return end
	local file = ParaIO.open(filepath, "r");
	if(file:IsValid()) then
		local text = file:GetText();
		file:close();
		return text;
	end
end
function CSGService.saveFile(filepath,content)
	if(filepath and content)then
		ParaIO.CreateDirectory(filepath);
		local file = ParaIO.open(filepath, "w");
		if(file:IsValid()) then
			file:WriteString(content);
			file:close();

			return true;
		end
	end
end
