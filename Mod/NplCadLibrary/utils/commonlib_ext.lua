NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/ObjectPool.lua");
local ObjectPool = commonlib.gettable("Mod.NplCadLibrary.utils.ObjectPool");

commonlib.use_object_pool = false;

function commonlib.create_new_table(baseClass, class_mt)
	local o = {}
	if(baseClass) then
		-- this ensures that the constructor of all base classes are called. 
		if(baseClass.new~=nil) then
			baseClass:new(o);
		end	
	end
	setmetatable( o, class_mt )
	return o;
end

-- create a new class inheriting from a baseClass.
-- the new class has new(), _super, isa() function.
-- @param baseClass: the base class from which to inherit the new one. it can be nil if there is no base class.
-- @param new_class: nil or a raw table. 
-- @param ctor: nil or the constructor function(o) end, one may init dynamic table fields in it. One can also define new_class:ctor() at a later time. 
--  note: inside ctor function, parent class virtual functions are not available,since meta table of parent is not set yet. 
-- @return the new class is created. One can later create and instance of the new class by calling its new function(). 
function commonlib.inherit_ex(baseClass, new_class)
	if(baseClass ~= nil and type(baseClass) ~= "table") then
		log("Fatal error: "..baseClass.." must be a table instead of other type\n");
	end
	if(type(new_class) ~= "table") then
		log("Fatal error: "..new_class.." must be a table instead of string\n");
	end

	local new_class = new_class or {}
    local class_mt = { __index = new_class }

	-- this ensures that the base class new function is also called. 
    function new_class:new()
        local o;
		if(commonlib.use_object_pool) then
			local pool = ObjectPool.GetInstance(new_class);
			o = pool:GetObject(commonlib.create_new_table,baseClass,class_mt);
		else
			o = commonlib.create_new_table(baseClass,class_mt);
        end
			
		-- please note inside ctor function, parent class virtual functions are not available,since meta table of parent is not set yet. 
		local ctor = rawget(new_class, "ctor");
		if(type(ctor) == "function") then
			ctor(o);
		end

        return o;
    end

    if (baseClass~=nil) then
        setmetatable( new_class, { __index = baseClass } )
    end

	--------------------------------
    -- Implementation of additional OO properties
    --------------------------------

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    new_class._super = baseClass
    
    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class._super
            end
        end

        return b_isa
    end

    return new_class
end