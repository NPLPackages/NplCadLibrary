NPL.load("(gl)Mod/NplCadLibrary/testcase/TestFrame.lua");
NPL.load("(gl)Mod/NplCadLibrary/utils/tableext.lua");

local tableext = commonlib.gettable("Mod.NplCadLibrary.utils.tableext");
local TestFrame = commonlib.gettable("Mod.NplCadLibrary.testcase.TestFrame");
local TestTableExt = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.testcase.TestTableExt"));

function TestTableExt.test_table()
	local t1 = {"1",2,"4"};
	local t2 = {"5",8,"9"};
	local t3 = tableext.concat(t1,t2);
	echo("tableext.concat({'1',2,'4'},{'5',8,'9'})=,"..table.concat(t3,","));

	local t4 = tableext.splice(t1,2,0,7,8);
	echo("tableext.splice = "..table.concat(t4,","));
	local t5 = tableext.splice(t1,2,1,7,8); 
	echo("tableext.splice = "..table.concat(t5,","));

	local t6 = tableext.slice(t2,1,2);
	echo("tableext.slice = "..table.concat(t6,","));
	local t7 = tableext.slice(t3);
	echo("tableext.slice = "..table.concat(t7,","));

	local t8 = tableext.reverse(t2);
	echo("tableext.reverse = "..table.concat(t8,","));
end

function TestTableExt.test_clear()
	local t1 = {};
	local i;
	for i=1,10,1 do
		table.insert(t1,i);
	end
	echo(#t1);
	tableext.clear(t1);
	echo(#t1);
end

function TestTableExt.test_reverse()
	local t = {1,2,3,4,5,6,7,8,9,10};
	echo(t);
	tableext.reverse(t);
	echo(t);

	t = {1,2,3,4,5,6,7,8,9};
	echo(t);
	tableext.reverse(t);
	echo(t);

	local function add(x)
		return x + 1;
	end
	t = {1,2,3,4,5,6,7,8,9,10};
	echo(t);
	tableext.reverse(t, add);
	echo(t);

	t = {1,2,3,4,5,6,7,8,9};
	echo(t);
	tableext.reverse(t, add);
	echo(t);
end