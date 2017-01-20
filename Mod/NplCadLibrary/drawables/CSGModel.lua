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
	for __,polygon in ipairs(self.csg_node.polygons) do
		for __,vertex in ipairs(polygon.vertices) do
			-- by lighter:2017.1.20 23:46
			-- fixed mesh transform error.diffrent vertex pos may be used same pos.cause pos be transformed multi times.
			vertex:detach();

			math3d.VectorMultiplyMatrix(vertex.pos, vertex.pos, matrix);
		end
		polygon.plane = nil;
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