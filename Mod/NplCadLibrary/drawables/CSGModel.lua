--[[
Title: CSGModel 
Author(s): leio
Date: 2016/8/17
Desc: 
Defines a drawable object that can be attached to a Node.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/core/Drawable.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVector.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/CSGService.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");

local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CSGModel = commonlib.inherit(commonlib.gettable("Mod.NplCadLibrary.core.Drawable"), commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel"));
local math3d = commonlib.gettable("mathlib.math3d");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");

CSGModel.csg_node = nil;
CSGModel.cag_node = nil;
CSGModel.model_type = nil;
CSGModel.options = nil;
CSGModel.worldMatrix= Matrix4.IDENTITY;

function CSGModel:init(node,model_type,is2D)
	is2D = is2D or false;
	if not is2D then
		self.csg_node = node;
	else
		self.cag_node = node;
		self.csg_node= self.cag_node:toCSG(0.01);
	end
	self.model_type = model_type;
	self.worldMatrix = Matrix4.IDENTITY;
	return self;
end
function CSGModel:ctor()
	self.csg_node = nil;
	self.cag_node = nil;
end
function CSGModel:getTypeName()
	return "Model";
end
function CSGModel:getCSGNode()
	return self.csg_node;
end

function CSGModel.equalsColor(color_1,color_2)
	return color_1 and color_2 and (color_1[1] == color_2[1] and color_1[2] == color_2[2] and color_1[3] == color_2[3]);
end

CSGModel.default_color = {1,1,1};
function CSGModel.setColor(color)
	if(not self.csg_node or  not self.csg_node.polygons)then 
		return 
	end

	if(CSGModel.equalsColor(color,CSGModel.default_color))then
		return;
	end

	color = color or {};
	color[1] = color[1] or 1;
	color[2] = color[2] or 1;
	color[3] = color[3] or 1;
	for k,v in ipairs(self.csg_node.polygons) do
		v.shared = v.shared or {};
		v.shared.color = color;
	end
end

function CSGModel.applyMatrix(matrix,applyMeshTransform)
	if(not self.csg_node)then 
		return 
	end

	if(applyMeshTransform) then
		if(matrix) then
			for __,polygon in ipairs(self.csg_node.polygons) do
				for __,vertex in ipairs(polygon.vertices) do
					math3d.VectorMultiplyMatrix(vertex.pos, vertex.pos, matrix);
				end
				polygon.plane = nil;
			end
		end
	else
		self.worldMatrix = matrix;
	end

end

function CSGModel.toMesh()
	if(not self.csg_node)then 
		return 
	end
	
	local vertices = {};
	local indices = {};
	local normals = {};
	local colors = {};
	
	for __,polygon in ipairs(self.csg_node.polygons) do
		local start_index = #vertices+1;
		local normal = polygon:GetPlane().normal;
		for __,vertex in ipairs(polygon.vertices) do
			vertices[#vertices+1] = vertex.pos;
			normals[#normals+1] = normal;
			colors[#colors+1] = polygon.shared and polygon.shared.color or white;
		end
		local size = #(polygon.vertices) - 1;
		for i = 2,size do
			indices[#indices+1] = start_index;
			indices[#indices+1] = start_index + i-1;
			indices[#indices+1] = start_index + i;
		end
	end
	return self.worldMatrix,vertices,indices,normals,colors;
end
