local mathext = commonlib.inherit(nil, commonlib.gettable("Mod.NplCadLibrary.utils.mathext"));

function mathext.round(decimal)
    if decimal % 1 >= 0.5 then 
            decimal=math.ceil(decimal)
    else
            decimal=math.floor(decimal)
    end
	return decimal;
end

mathext.pi = 3.1415926;
