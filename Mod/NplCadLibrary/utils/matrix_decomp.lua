NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Quaternion = commonlib.gettable("mathlib.Quaternion");

function Matrix4:Decompose()
	local m00, m01, m02, m03 = self[1], self[2], self[3], self[4];
    local m10, m11, m12, m13 = self[5], self[6], self[7], self[8];
    local m20, m21, m22, m23 = self[9], self[10],self[11],self[12];
    local m30, m31, m32, m33 = self[13],self[14],self[15],self[16];

	local scaling_x = math.sqrt((m00 * m00) + (m01 * m01) + (m02 * m02));
	local scaling_y = math.sqrt((m10 * m10) + (m11 * m11) + (m12 * m12));
	local scaling_z = math.sqrt((m20 * m20) + (m21 * m21) + (m22 * m22));

	m00 = m00 / scaling_x;		m01 = m01 / scaling_x;		m02 = m02 / scaling_x;
	m10 = m10 / scaling_y;		m11 = m11 / scaling_y;		m12 = m12 / scaling_y;
	m20 = m20 / scaling_z;		m21 = m21 / scaling_z;		m22 = m22 / scaling_z;

	--Use tq to store the largest trace
	tq = {
		1 + m00+m11+m22,
		1 + m00-m11-m22,
		1 - m00+m11-m22,
		1 - m00-m11+m22
	};

    -- Find the maximum (could also use stacked if's later)
    local i,j = 1,1;
    for i=1, 4 do
		if (tq[i]>tq[j]) then
			j = i;
		end
	end

	-- check the diagonal
	local QW,QX,QY,QZ = 1,0,0,0;
    if (j==1) then
        -- perform instant calculation
        QW = tq[1];
        QX = m12-m21;
        QY = m20-m02;
        QZ = m01-m10;
    elseif (j==1) then

        QW = m12-m21;
        QX = tq[2];
        QY = m01+m10;
        QZ = m20+m02;
    elseif (j==2) then

        QW = m20-m02;
        QX = m01+m10;
        QY = tq[3];
        QZ = m12+m21;

    else --[[if (j==4) ]]--

        QW = m01-m10;
        QX = m20+m02;
        QY = m12+m21;
        QZ = tq[4];
	end

	local s = math.sqrt(0.25/tq[j]);
    QW = QW * s;
    QX = QX * s;
    QY = QY * s;
    QZ = QZ * s;

	return {translation={m30, m31, m32},scaling={scaling_x,scaling_y,scaling_z},rotation={QX,QY,QZ,QW}};
end

function Matrix4.canCombineToShape(cur,pre)
	local cur_result = cur:Decompose();
	local pre_result = pre:Decompose();
	
	local cur_quatDecomp = Quaternion:new():set(cur_result.rotation);
	local cur_yaw, cur_roll, cur_pitch = cur_quatDecomp:ToEulerAngles();
	local pre_quatDecomp = Quaternion:new():set(pre_result.rotation);
	local pre_yaw, pre_roll, pre_pitch = pre_quatDecomp:ToEulerAngles();

	local is2D = ((cur_result.translation[2] == 0) and (cur_result.scaling[2] == 1) and (cur_roll == 0) and (cur_pitch == 0));
	local sameIn2D = ((cur_result.translation[2] == pre_result.translation[2]) and (cur_result.scaling[2] == pre_result.scaling[2]) and (cur_roll == pre_roll) and (cur_pitch == pre_pitch));
	local new_transform,new_cur,new_pre = nil,nil,nil;

	if(sameIn2D and not is2D) then
		local mt = Matrix4:new():identity():makeTrans(0,cur_result.translation[2],0);
		local ms = Matrix4:new():identity();
		ms:setScale(1,cur_result.scaling[2],1);
				
		local rotationQuat = Quaternion:new();
		rotationQuat = rotationQuat:FromEulerAngles(0, cur_roll, cur_pitch);
		local mr = rotationQuat:ToRotationMatrix();
		new_transform = ms * mr * mt;


		mt = Matrix4:new():identity():makeTrans(cur_result.translation[1],0,cur_result.translation[3]);
		ms = Matrix4:new():identity();
		ms:setScale(cur_result.scaling[1],1,cur_result.scaling[3]);
		rotationQuat = rotationQuat:FromEulerAngles(cur_yaw, 0, 0);
		mr = rotationQuat:ToRotationMatrix();
		new_cur = ms * mr * mt;

		mt = Matrix4:new():identity():makeTrans(pre_result.translation[1],0,pre_result.translation[3]);
		ms = Matrix4:new():identity();
		ms:setScale(pre_result.scaling[1],1,pre_result.scaling[3]);
		rotationQuat = rotationQuat:FromEulerAngles(pre_yaw, 0, 0);
		mr = rotationQuat:ToRotationMatrix();
		new_pre = ms * mr * mt;
	else
		new_cur = cur;
		new_pre = pre;
	end

	return sameIn2D,new_transform,new_cur,new_pre;
end