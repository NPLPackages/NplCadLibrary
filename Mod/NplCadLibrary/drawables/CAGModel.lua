--[[
Title: CAGModel 
Author(s): lighter
Date: 2016/12/17
Desc: 
Defines a 2d cag drawable object that can be attached to a Node.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NplCadLibrary/drawables/CAGModel.lua");
local CAGModel = commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NplCadLibrary/core/Drawable.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGMatrix4x4.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");

local math3d = commonlib.gettable("mathlib.math3d");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local CSGMatrix4x4 = commonlib.gettable("Mod.NplCadLibrary.csg.CSGMatrix4x4");

local CAGModel = commonlib.inherit(commonlib.gettable("Mod.NplCadLibrary.core.Drawable"), commonlib.gettable("Mod.NplCadLibrary.drawables.CAGModel"));

CAGModel.cag_node= nil;

function CAGModel:init(node,model_type,is2D)
	self.model_type = model_type;
	self.cag_node = node;
	return self;
end
function CAGModel:ctor()
	self.cag_node = nil;
end
function CAGModel:getTypeName()
	return "Shape";
end
function CAGModel:getModelNode()
	return self.cag_node;
end
function CAGModel:applyMeshTransform(matrix)
	local matrix4x4 = CSGMatrix4x4:new():init(matrix);
	for key,side in ipairs(self.cag_node.sides) do
		-- once we need to be transform to vertices,we should lost it's height.
		self.cag_node.sides[key] = side:transform(matrix4x4);
	end
end

function CAGModel:toMesh()
	if(not self.cag_node)then 
		return 
	end
	return self:csgToMesh(self.cag_node:toCSG(0.01));
end

function CAGModel:union(other)
	local result_node = self.cag_node:union(other:getModelNode());
	return CAGModel:new():init(result_node,"shape");
end

function CAGModel:subtract(other)
	local result_node = self.cag_node:subtract(other:getModelNode());
	return CAGModel:new():init(result_node,"shape");
end

function CAGModel:intersect(other)
	local result_node = self.cag_node:intersect(other:getModelNode());
	return CAGModel:new():init(result_node,"shape");
end

function CAGModel:getElements()
	if(self.cag_node == nil) then
		return 0;
	end
	return self.cag_node:GetSideCount();
end