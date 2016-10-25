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
local CSGService = commonlib.gettable("Mod.NplCadLibrary.services.CSGService");
local CSGVector = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVector");
local CSGVertex = commonlib.gettable("Mod.NplCadLibrary.csg.CSGVertex");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CSGModel = commonlib.inherit(commonlib.gettable("Mod.NplCadLibrary.core.Drawable"), commonlib.gettable("Mod.NplCadLibrary.drawables.CSGModel"));
CSGModel.csg_node = nil;
CSGModel.model_type = nil;
CSGModel.options = nil;
function CSGModel:init(csg_node,model_type)
	self.csg_node = csg_node;
	self.model_type = model_type;
	return self;
end
function CSGModel:ctor()
	self.csg_node = nil;
end
function CSGModel:getTypeName()
	return "Model";
end
function CSGModel:getCSGNode()
	return self.csg_node;
end
function CSGModel:toMesh()
	return CSGService.toMesh(self.csg_node);
end
function CSGModel:applyMatrix(matrix)
	CSGService.applyMatrix(self.csg_node,matrix);
end
