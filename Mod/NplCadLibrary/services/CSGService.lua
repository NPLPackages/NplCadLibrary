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

local white = {1,1,1};

function CSGService.operateTwoNodes(pre_csg_node,cur_csg_node,csg_action)
	local bResult = false;
	if(pre_csg_node and cur_csg_node)then
		if(csg_action == "union")then
			cur_csg_node = pre_csg_node:union(cur_csg_node);
			bResult = true;
		elseif(csg_action == "difference")then
			cur_csg_node = pre_csg_node:subtract(cur_csg_node);
			bResult = true;
		elseif(csg_action == "intersection")then
			cur_csg_node = pre_csg_node:intersect(cur_csg_node);
			bResult = true;
		else
			-- Default action is "union".
			--cur_csg_node = pre_csg_node:union(cur_csg_node);
		end
	end
	return cur_csg_node,bResult;
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
	
	local function BeforeChildVisit_(node)
		node:getWorldMatrix();

		-- added by lighter
		-- check if this node and it's children should applyMeshTransform
		local actionName, actionNode = CSGService.findTagValue(node,"csg_action");
		if(actionNode ~= nil and node.applyMeshTransform == false) then
			node:markApplyMeshTransform();
		end

		-- apply color and transform if need.
		local draw_model = CSGService.applayCSGNodeColorAndTransform(node);
		if(draw_model)then
			actionNode:pushActionParam(draw_model);
			LOG.std(nil, "info", "CSG", "begin csg_node with %d polygons", draw_model.csg_node:GetPolygonCount());
		else
			LOG.std(nil, "info", "CSG", "begin node with (%s) tag", node:getTag("csg_action") or "empty");
		end
	end

	local function AfterChildVisit_(node)
		local action_params = node:popAllActionParams();
		if(action_params) then
			local actionName = node:getTag("csg_action");
			local fromTime = ParaGlobal.timeGetTime();
			local result_draw_model = CSGService.doCSGNodeAction(actionName, action_params);
			LOG.std(nil, "info", "CSG", "csg_node action (%s: with %d nodes) finished in %.3f seconds with %d polygons", 
				actionName or "none", action_params and #action_params or 0, 
				(ParaGlobal.timeGetTime()-fromTime)/1000, result_draw_model and result_draw_model:getCSGNode() and result_draw_model:getCSGNode():GetPolygonCount() or 0);
			local actionName, actionNode = CSGService.findTagValue(node:getParent() or scene,"csg_action");
			if(actionNode ~= node) then
				actionNode:pushActionParam(result_draw_model);
			end
		end
	end

	scene:visit(BeforeChildVisit_, AfterChildVisit_);

	-- convert all resulting csg_nodes to meshes
	local render_list = {};

	local result = scene:popAllActionParams();
	if(result) then
		for i = 1, #result do
			local world_matrix,vertices,indices,normals,colors = result[i].toMesh();
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
-- @param csg_nodes: array of csg node operands
-- @return csgNode, bSucceed:  csgNode is the result.
function CSGService.doCSGNodeAction(csg_action, csg_nodes)
	local len = #csg_nodes;
	if(len == 0)then
		return;
	end
	local first_node = csg_nodes[1];
	local result_node = first_node;
	local bSucceed = true;
	for i=2, len do
		result_node, bSucceed = CSGService.operateTwoNodes(result_node, csg_nodes[i], csg_action);
		if(not bSucceed) then
			break;
		end
	end

	-- add by lighter
	-- unified return a drawable model
	local resultModel = nil;
	if(bSucceed) then
		resultModel = CSGModel:new():init(result_node,"mesh");
	end
	return resultModel, bSucceed;
end

function CSGService.findCsgNode(node)
		if(not node)then return end
		local drawable = node:getDrawable();
		if(drawable and drawable.getCSGNode)then
			local cur_csg_node = drawable:getCSGNode();
			return cur_csg_node;
		end
end
function CSGService.visitNode(node,input_params)
	if(not node)then return end
	local nodes_map = input_params.nodes_map;
	if(nodes_map[node]["csg_node"])then
		return
	end
	local child = node:getFirstChild();
	local top_csg_action = CSGService.findTagValue(node,"csg_action");
	local temp_list = {};
	while(child) do
		local csg_node = nodes_map[child]["csg_node"];
		if(csg_node)then
			if(top_csg_action)then
				table.insert(temp_list,{
					csg_node = csg_node,
				});	
			else
				table.insert(input_params.result,{
					csg_node = csg_node,
				});	
			end
			
		end
		nodes_map[child]["csg_node"] = nil;
		child = child:getNextSibling();
	end	
	local csg_node = CSGService.doCSGOperation(top_csg_action, temp_list);
	nodes_map[node]["csg_node"] = csg_node;
end


-- @param node: a scene node
-- @return csg_node, if scene node is a csg node and world transformation is applied to it. 
-- modified by lighter: function name changed form getTransformedCSGNode to "applayCSGNodeColorAndTransform"
--	I didn't understand why ** clone a new node for operation **
function CSGService.applayCSGNodeColorAndTransform(node)
	local drawable = node:getDrawable();
	if(drawable and drawable.getCSGNode)then
		local color = CSGService.findTagValue(node,"color");
		if(color)then
			drawable.setColor(color);
		end

		local world_matrix = node:getWorldMatrix();
		drawable.applyMatrix(world_matrix,node.applyMeshTransform);

		-- unified return a drawable model.
		return drawable;
	end
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
