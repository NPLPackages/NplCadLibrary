local tableext = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.utils.tableext"));

function tableext.copy(t1,t2,each_fun)
	for k,v in ipairs(t2) do
		if each_fun ~= nil then
			v = each_fun(v);
		end
		t1[#t1 + 1] = v;
	end
end
function tableext.copy_fn(t1,t2,each_fun)
	for k,v in ipairs(t2) do
		t1[#t1 + 1] = each_fun(v);
	end
end
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

function tableext.reverse(tab,each_fun)  
    local p = 1;
	local q = #tab;
	while q > p do
		if each_fun ~= nil then
			tab[p],tab[q] = each_fun(tab[q]),each_fun(tab[p]);
		else
			tab[p],tab[q] = tab[q],tab[p];
		end
		p = p + 1;
		q = q - 1;
		if(p == q) and (each_fun ~= nil) then
			tab[p] = each_fun(tab[q]);
		end
	end
    return tab;
end  
function tableext.is_array(input)
	if(input and type(input) == "table" and (#input) >= 0)then
		return true;
	end
end
function tableext.clear(input)
	if(input and type(input) == "table" and (#input) >= 0) then
		count = #input
		for i=0, count do 
			input[i]=nil 
		end
	end
end
