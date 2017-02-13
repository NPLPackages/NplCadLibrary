--[[
Title: CSGModel 
Author(s): leio
Date: 2016/8/17
Desc: 
Defines a 3d csg drawable object that can be attached to a Node.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/drawables/CSGModel.lua");
local CSGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/core/Drawable.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGVertex.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
NPL.load("(gl)Mod/NplCadLibrary/services/CSGService.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");

local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CSGModel = commonlib.inherit(commonlib.gettable("Mod.NplCadLibrary.core.Drawable"), commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel"));
local math3d = commonlib.gettable("mathlib.math3d");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");

CSGModel.csg_node= nil;

function CSGModel:init(node,model_type)
	self.model_type = model_type;
	self.csg_node = node;
	return self;
end
function CSGModel:ctor()
	self.csg_node = nil;
end
function CSGModel:getTypeName()
	return "Model";
end
function CSGModel:getModelNode()
	return self.csg_node;
end
function CSGModel:applyMeshTransform(matrix)
	function NormalMultiplyMatrix(r,v,m)
		local x,y,z = v[1], v[2], v[3];
		r[1] = x*m[1] + y*m[5] + z*m[9];
		r[2] = x*m[2] + y*m[6] + z*m[10];
		r[3] = x*m[3] + y*m[7] + z*m[11];
	end

	for __,polygon in ipairs(self.csg_node.polygons) do
		for __,vertex in ipairs(polygon.vertices) do
			-- by lighter:2017.1.20 23:46
			-- fixed mesh transform error.diffrent vertex pos may be used same pos.cause pos be transformed multi times.
			vertex.pos = vertex.pos:clone();
			math3d.VectorMultiplyMatrix(vertex.pos, vertex.pos, matrix);
			
			if(vertex.normal ~= nil) then
				vertex.normal = vertex.normal:clone();
				NormalMultiplyMatrix(vertex.normal,vertex.normal,matrix);
			end
		end
		polygon.plane:transform(matrix);
	end
end
function CSGModel:applyColor(color)
	for __,polygon in ipairs(self.csg_node.polygons) do
		polygon.shared = polygon.shared or {};
		polygon.shared.color = color;
	end
end

function CSGModel:toMesh()
	if(not self.csg_node)then 
		return 
	end
	return self:csgToMesh(self.csg_node);
end

function CSGModel:union(other)
	local result_node = self.csg_node:union(other:getModelNode());
	return CSGModel:new():init(result_node,"model");
end

function CSGModel:subtract(other)
	local result_node = self.csg_node:subtract(other:getModelNode());
	return CSGModel:new():init(result_node,"model");
end

function CSGModel:intersect(other)
	local result_node = self.csg_node:intersect(other:getModelNode());
	return CSGModel:new():init(result_node,"model");
end

function CSGModel:getElements()
	if(self.csg_node == nil) then
		return 0;
	end
	return self.csg_node:GetPolygonCount();
end