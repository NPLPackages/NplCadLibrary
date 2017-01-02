--[[
Title: Drawable 
Author(s): leio
Date: 2016/8/16
Desc: 
Defines a drawable object that can be attached to a Node.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/core/Drawable.lua");
local Drawable = commonlib.gettable("Mod.NplCadLibrary.core.Drawable");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Matrix4.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Drawable = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.core.Drawable"));

Drawable.default_color = {1,1,1};
Drawable.node = nil;
Drawable.model_type = nil;
Drawable.worldMatrix= Matrix4.IDENTITY;
Drawable.color= Drawable.default_color;

function Drawable:ctor()
	echo("Drawable:ctor()");
	self.node = nil;
	self.model_type = nil;
	self.worldMatrix= Matrix4.IDENTITY;
	self.color= Drawable.default_color;
end
function Drawable:getTypeName()
	error("pure virtual function be called: Drawable:getTypeName()");
	return "Drawable";
end
function Drawable:getElements()
	error("pure virtual function be called: Drawable:getElements()");
	return 0;
end
function Drawable:applyMeshTransform(matrix)
	error("pure virtual function be called: Drawable:applyMeshTransform()");
end
function Drawable:getModelNode()
	error("pure virtual function be called: Drawable:getModelNode()");
	return nil;
end

function Drawable:getNode()
	return self.node;
end

function Drawable:setNode(node)
	self.node = node;
end

function Drawable.equalsColor(color_1,color_2)
	return color_1 and color_2 and (color_1[1] == color_2[1] and color_1[2] == color_2[2] and color_1[3] == color_2[3]);
end

function Drawable:setColor(color)
	if(Drawable.equalsColor(color,Drawable.default_color))then
		return;
	end

	color = color or {};
	color[1] = color[1] or 1;
	color[2] = color[2] or 1;
	color[3] = color[3] or 1;

	self.color = color;
end

function Drawable:applyMatrix(matrix,applyMeshTransform)

	if(applyMeshTransform) then
		if(matrix) then
			self:applyMeshTransform(matrix);
		end
	else
		self.worldMatrix = matrix;
	end

end

function Drawable:csgToMesh(csg)

	local vertices = {};
	local indices = {};
	local normals = {};
	local colors = {};
	
	for __,polygon in ipairs(csg.polygons) do
		local start_index = #vertices+1;
		local normal = polygon:GetPlane().normal;
		for __,vertex in ipairs(polygon.vertices) do
			vertices[#vertices+1] = vertex.pos;
			normals[#normals+1] = normal;
			colors[#colors+1] = self.color;
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