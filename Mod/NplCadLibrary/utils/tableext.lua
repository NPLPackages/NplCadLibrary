local tableext = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.utils.tableext"));

function tableext.concat(t1,t2)
	local t = {};
	for k,v in ipairs(t1) do
		table.insert(t,v);
	end
	for k,v in ipairs(t2) do
		table.insert(t,v);
	end
	return t;
end

-- Notice!! index begin from 1 !!! not 0
function tableext.splice(t,index,howmany,...)
	index = index or 1;
	howmany = howmany or 0;

	local i;
	for i=1,howmany,1 do
		table.remove(t,index);
	end
	local a = {...};
	for k,v in ipairs(a) do
		table.insert(t,index,v);
		index = index + 1;
	end
	return t;
end

function tableext.slice(t,_start,_end)
	_start = _start or 1;
	_end = _end or #t;
	local new_table = {};
	local i;
	for i=_start,_end,1 do
		table.insert(new_table,t[i]);
	end
	return new_table;
end

function tableext.reverse(tab)  
    local tmp = {}  
    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)  
    end  
  
    return tmp ;
end  
function tableext.is_array(input)
	if(input and type(input) == "table" and (#input) > 0)then
		return true;
	end
end