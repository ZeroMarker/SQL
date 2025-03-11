-- DROP FUNCTION ho_his.tb_cis_dradvice_detail(timestamp, timestamp);

CREATE OR REPLACE FUNCTION ho_his.tb_cis_dradvice_detail(start_time timestamp without time zone, end_time timestamp without time zone)
 RETURNS TABLE(YLJGDM varchar, YZID varchar, JZLSH varchar, CXBZ varchar, KH varchar, KLX varchar, BQ varchar, XDKSBM varchar, XDKSMC varchar, XDRGH varchar, XDRXM varchar, YZXDSJ varchar, ZXKSBM varchar, ZXKSMC varchar, ZXRGH varchar, ZXRXM varchar, YZZXSJ varchar, YZZZSJ varchar, YZSM varchar, YZZH varchar, YZLB varchar, YZMXBM varchar, YZMXMC varchar, YZLX varchar, JXDM varchar, JXMC varchar, YPGG varchar, YPYF varchar, YYPD varchar, JL varchar, DW varchar, MCSL varchar, MCDW varchar, YF varchar, JE varchar, YYTS varchar, SFPS varchar, YPSL varchar, YPDW varchar, JYDM varchar, ZYSYLBDM varchar, JCBW varchar, CFYPZH varchar, DZSQDBH varchar, YZXMLXDM varchar, YZXMNR varchar, YZJHKSR varchar, YZJHJSRQ varchar, YZBZXX varchar, YZSHRQM varchar, YZSHRGH varchar, YZSHRQSJ varchar, HDYZHSQM varchar, HDYZHSGH varchar, YZHDRQSJ varchar, TZYZZQM varchar, TZYZZGH varchar, YZQXRQSJ varchar, QXYZZQM varchar, QXYZZGH varchar, BZ varchar, XGBZ varchar, MJ varchar, YLYL1 varchar, YLYL2 varchar)
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec RECORD;
    issueTimeFormatted varchar;
    executeTimeFormatted varchar;
    endTimeFormatted varchar;
    auditTimeFormatted varchar;
    checkTimeFormatted varchar;
    cancelTimeFormatted varchar;
    planStartTimeFormatted varchar;
    planEndTimeFormatted varchar;
	cancelFlag varchar;
	cancelEmpName varchar;
	cancelEmpId varchar;
	skinTestFlag varchar;
	adviceCategory varchar;
	isDrug varchar;
	itemTypeCode varchar;
BEGIN
    FOR rec IN 
        SELECT
            coh.code AS hospCode,                        -- 医疗机构代码
            ooi.id AS adviceId,                  -- 医嘱ID
            p.id AS visitSerialNo,               -- 住院就诊流水号
            ooi.item_stat_code AS statusCode,              -- 撤销标志
            ppm."no" AS cardNo,                       -- 卡号
            cpctd.description AS cardType,                         -- 卡类型
            cow.displayname AS wardName,                        -- 病区
            d1.code AS issueDeptCode,                  -- 下达科室编码
            d1."name" AS issueDeptName,                  -- 下达科室名称
            e1.code AS issueEmpId,              -- 医嘱下达人工号
            e1.displayname AS issueEmpName,                   -- 医嘱下达人姓名
            ooi.create_datetime AS issueDatetime,        -- 医嘱下达时间
			-- 接收科室
            d2.code AS execDeptCode,                   -- 执行科室编码
            d2."name" AS execDeptName,                   -- 执行科室名称
			-- 执行
            e2.code AS execEmpId,               -- 医嘱执行人工号
            e2.displayname AS execEmpName,                    -- 医嘱执行人姓名
            ooi.create_datetime AS executeDatetime,    -- 医嘱执行时间
            -- 停止
			ooi.end_datetime AS endDatetime,            -- 医嘱终止时间

            coi.displayname AS adviceDescription,       -- 医嘱说明
            ooie2.item_group AS groupNo,                    -- 医嘱组号
            ooi.priority_code AS adviceCategory,             -- 医嘱类别
            coi.code AS detailCode,              -- 医嘱明细编码
            coi.displayname AS detailName,              -- 医嘱明细名称
            sub.type_dr AS isDrug,                      -- 是否药品
            coi.code AS dosageFormCode,     -- 剂型代码
            coi.code AS dosageFormName,     -- 医院剂型名称
            coi.code AS drugSpec,              -- 药品规格
            cpi.displayname AS drugUsage,                -- 药品用法
            cpf.displayname AS frequency,                 -- 用药频度
            ooi.dose_qty AS dosePerTime,           -- 每次使用剂量
            cdu1.displayname AS doseUnit,                  -- 每次使用剂量单位
            ooi.pack_qty AS qtyPerTime,        -- 每次使用数量
            cdu2.displayname AS qtyUnit,               -- 每次使用数量单位
            cpi.displayname AS adminRoute,              -- 给药途径(用法)
            ooi.pack_qty AS amount,                       -- 金额
            cpd.displayname AS drugDays,                       -- 用药天数
            ooi.action_code AS skinTestFlag,         -- 皮试判别
            ooi.pack_qty AS dispenseQty,            -- 发药数量
            cdu3.displayname AS dispenseUnit,          -- 发药数量单位
            '' AS decoctionCode,        -- 中药煎煮法代码
            '' AS tcmUsageCode,         -- 中药使用类别代码
            '' AS examPart,                  -- 检查部位
            ooi.presc_seqno AS presGroupNo,   -- 处方药品组号
            '-' AS eReqNo,            -- 电子申请单编号
            sub.type_dr AS itemTypeCode,         -- 医嘱项目类型代码
            coi.displayname AS itemContent,            -- 医嘱项目内容

            '' AS planStartDatetime, -- 医嘱计划开始日期时间
            '' AS planEndDatetime,   -- 医嘱计划结束日期时间
            ooi.dep_proc_notes AS adviceRemarks,               -- 医嘱备注信息
            -- 审核 开立
			e3.displayname AS auditEmpName,                   -- 医嘱审核人姓名
            e3.code AS auditEmpId,              -- 医嘱审核人工号
            ooie.audit_datetime AS auditDatetime,        -- 医嘱审核日期时间
			-- 处理
            e4.displayname AS checkNurseName,                 -- 核对医嘱护士姓名
            e4.code AS checkNurseId,            -- 核对医嘱护士工号
            ooie.create_datetime AS checkDatetime,        -- 医嘱核对日期时间
			-- 停止
            e5.displayname AS stopEmpName,                    -- 停止医嘱者姓名
            e5.code AS stopEmpId,               -- 停止医嘱者工号
			-- 撤销
            ooi.update_datetime AS cancelDatetime,      -- 医嘱取消日期时间
            e6.name AS cancelEmpName,                  -- 取消医嘱者姓名
            e6.code AS cancelEmpId,             -- 取消医嘱者工号
            ooi.dep_proc_notes AS notes,                         -- 备注
            '' AS updateFlag,              -- 修改标志
            '' AS securityLevel         -- 密级
        FROM
            oe_ord_item ooi
		LEFT JOIN
			oe_ord_itemext ooie ON ooi.id = ooie.oe_ord_item_id
		LEFT JOIN
			oe_ord_itemext2 ooie2 ON ooi.id = ooie2.oe_ord_item_id
		LEFT JOIN
			oe_order oo ON oo.id = ooi.oe_order_parref
		LEFT JOIN
            ct_oe_itmmast coi ON ooi.itm_mast_dr = coi.id
		LEFT JOIN
			ct_oe_subcategory sub ON sub.id = coi.subcategory_dr
        LEFT JOIN
            paadm p ON p.id = oo.adm_dr
		LEFT JOIN
			pa_pat_mast ppm ON ppm.id = p.papmi_dr
        LEFT JOIN
            pa_card_ref pcr ON pcr.papmi_dr = ppm.id
        LEFT JOIN
            ct_org_hospital coh ON p.admhosp_dr = coh.id
        LEFT JOIN
            ct_pa_card_type_def cpctd ON pcr.card_type_dr = cpctd.id
        LEFT JOIN
            ct_org_ward cow ON p.currentward_dr = cow.id
        LEFT JOIN
            hos_org_business_unit d1 ON ooi.orddept_dr = d1.id
        LEFT JOIN
            hos_org_business_unit d2 ON ooi.orddept_dr = d2.id
        LEFT JOIN
            ct_rb_careprov e1 ON ooi.doctor_dr = e1.id
        LEFT JOIN
            ct_rb_careprov e2 ON ooi.doctor_dr = e2.id
        LEFT JOIN
            ct_rb_careprov e3 ON ooie.audit_doc_dr = e3.id
        LEFT JOIN
            ct_rb_careprov e4 ON ooi.doctor_dr = e4.id
        LEFT JOIN
            ct_rb_careprov e5 ON ooi.stop_ctcp_dr = e5.id
       	LEFT JOIN
            hos_user_account e6 ON ooi.update_user = e6.id
		LEFT JOIN
			ct_ph_freq cpf ON ooi.freq_dr = cpf.id
		LEFT JOIN
			ct_ph_instruc cpi ON ooi.instr_dr = cpi.id
		LEFT JOIN
			ct_ph_duration cpd ON ooi.durat_dr = cpd.id
		LEFT JOIN
			ct_dic_uom cdu1 ON cdu1.id = ooi.unit_dr
		LEFT JOIN
			ct_dic_uom cdu2 ON cdu2.id = ooi.unit_dr
		LEFT JOIN
			ph_oe_dispensing pod ON pod.oeori_dr = ooi.id
		LEFT JOIN
			ct_dic_uom cdu3 ON cdu3.id = pod.qtyuom
        WHERE 
            DATE(ooi.create_datetime) >= start_time AND 
            DATE(ooi.create_datetime) <= end_time
        ORDER BY 
            ooi.create_datetime
    LOOP
        -- Format timestamps
        issueTimeFormatted := TO_CHAR(rec.issueDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF issueTimeFormatted IS NULL THEN issueTimeFormatted := ''; END IF;

        executeTimeFormatted := TO_CHAR(rec.executeDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF executeTimeFormatted IS NULL THEN executeTimeFormatted := ''; END IF;

        endTimeFormatted := TO_CHAR(rec.endDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF endTimeFormatted IS NULL THEN endTimeFormatted := ''; END IF;

        planStartTimeFormatted := TO_CHAR(rec.planStartDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF planStartTimeFormatted IS NULL THEN planStartTimeFormatted := ''; END IF;

        planEndTimeFormatted := TO_CHAR(rec.planEndDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF planEndTimeFormatted IS NULL THEN planEndTimeFormatted := ''; END IF;

        auditTimeFormatted := TO_CHAR(rec.auditDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF auditTimeFormatted IS NULL THEN auditTimeFormatted := ''; END IF;

        checkTimeFormatted := TO_CHAR(rec.checkDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF checkTimeFormatted IS NULL THEN checkTimeFormatted := ''; END IF;

        cancelTimeFormatted := TO_CHAR(rec.cancelDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF cancelTimeFormatted IS NULL THEN cancelTimeFormatted := ''; END IF;

		IF rec.statusCode = 'D' THEN
			cancelFlag := '2';
			cancelEmpId := rec.cancelEmpId;
			cancelEmpName := rec.cancelEmpName;
		ELSE
			cancelFlag := '1';
			cancelTimeFormatted := '';
			cancelEmpId := '';
			cancelEmpName := '';
		END IF;
		
		IF rec.skinTestFlag IS NULL THEN
			skinTestFlag := 0;
		ELSE
			skinTestFlag := 1;
		END IF;
	
		IF rec.isDrug = 'R' IS NULL THEN
			isDrug := 1;
		ELSE
			isDrug := 0;
		END IF;
		
		adviceCategory := CASE rec.adviceCategory
	        WHEN 'S' THEN 1
	        WHEN 'NORM' THEN 2
	        WHEN 'OUT' THEN 3
	        ELSE 9 -- or handle the default case as needed
    	END;

		
		/*
1：长期(在院)；2：临时(在院)；3：出院带药；9：其他
V	核实
U	作废
H	On Hold
D	停止
P	预开
E	执行
Q	In Queue
PO	Post-Operation Order
S	Postponed
I	未审核
IP	处理中
C	撤销
*/
		
		/*
1.药品 0.非药品
*/
		/*
1	口服	经口吞服药物
2	直肠给药	将药物经肛门塞入或注入直肠
3	舌下给药	将药物置于舌下/颊部的给药方法
4	注射给药	将药物经过表皮注入体内
401	皮下注射	将药物注射于皮下组织
402	皮内注射	将药物注射于皮内组织
403	肌肉注射	将药物注射于肌肉组织内
404	静脉注射或静脉滴注	将药物注入静脉血管内
5	吸入给药	将药物呈雾状物而由呼吸道吸入
6	局部用药	主要发挥局部作用的给药方法
601	椎管内给药	将药物注入椎管内
602	关节腔内给药	将药物注入关节腔内
603	胸膜腔给药	将药物注入胸膜腔内
604	腹腔给药	将药物注入腹腔内
605	阴道用药	将药物置于阴道中
606	滴眼	将药物经眼滴入
607	滴鼻	将药物经鼻滴入
608	喷喉	将药物喷于喉部粘膜表面
609	含化	将药物置于口腔内含化
610	敷伤口	将药物直接敷于伤口表面
611	擦皮肤	用药物擦拭皮肤
6XX	局部用药扩充内容	
699	其他局部给药途径	其他局部用药途径
9	其他给药途径	增补的用药途径内容
喷雾吸入	喷雾吸入
雾化吸入	雾化吸入
直肠给药	直肠给药
配药用	配药用
其他	其他
滴鼻	滴鼻
冲服	冲服
导管导入	导管导入
舌下含服	舌下含服
含化	含化
肌肉注射	肌肉注射
缓慢静滴	缓慢静滴
皮下注射	皮下注射
静脉滴注[避光]	静脉滴注[避光]
气管内给药	气管内给药
静脉泵入	静脉泵入
局部麻醉	局部麻醉
关节腔注射	关节腔注射
局部注射	局部注射
硬膜外注射	硬膜外注射
封管用	封管用
皮试	皮试
皮内注射	皮内注射
椎管内注射	椎管内注射
腹腔注射	腹腔注射
涂眼	涂眼
滴耳	滴耳
含漱	含漱
膀胱冲洗	膀胱冲洗
烊化兑服	烊化兑服
水煎服	水煎服
入丸散	入丸散
水冲服	水冲服
保留灌肠[中药]	保留灌肠[中药]
外用擦洗	外用擦洗
坐浴用	坐浴用
8ces 测试22	测试名称2
吸入	吸入
喷鼻	喷鼻
ZS.JMZS	静脉注射
代茶饮	代茶饮
口服	口服
ZS.JMDZ	静脉滴注
滴眼	滴眼
外用	外用
研末冲服	研末冲服
555	test
		*/
		itemTypeCode := CASE rec.itemTypeCode
	        WHEN 'R' THEN '01'
	        WHEN 'X' THEN '02'
	        WHEN 'L' THEN '03'
			WHEN 'N' THEN '03'
			WHEN 'L' THEN '03'
			WHEN 'M' THEN '06'
			WHEN 'L' THEN '03'
	        ELSE '99' -- or handle the default case as needed
    	END;
		/*

		01	药品类医嘱
02	检查类医嘱
03	检验类医嘱
04	手术类医嘱
05	处置类医嘱
06	材料类医嘱
07	嘱托医嘱
08	输血类医嘱
99	其他医嘱
M
D
X
L
R
N 输血 嘱托 处置
P

1	未使用
2	中成药
3	中草药
9	其他中药*/
        -- Map fields to RETURN TABLE columns
        YLJGDM := rec.hospCode;                -- 医疗机构代码
        YZID := rec.adviceId;                  -- 医嘱ID
        JZLSH := rec.visitSerialNo;            -- 住院就诊流水号
        CXBZ := cancelFlag;                -- 撤销标志
        KH := rec.cardNo;                      -- 卡号
        KLX := '2';                   -- 卡类型
        BQ := rec.wardName;                    -- 病区
        XDKSBM := rec.issueDeptCode;           -- 下达科室编码
        XDKSMC := rec.issueDeptName;           -- 下达科室名称
        XDRGH := rec.issueEmpId;               -- 医嘱下达人工号
        XDRXM := rec.issueEmpName;             -- 医嘱下达人姓名
        YZXDSJ := issueTimeFormatted;          -- 医嘱下达时间
        ZXKSBM := rec.execDeptCode;            -- 执行科室编码
        ZXKSMC := rec.execDeptName;            -- 执行科室名称
        ZXRGH := rec.execEmpId;                -- 医嘱执行人工号
        ZXRXM := rec.execEmpName;              -- 医嘱执行人姓名
        YZZXSJ := executeTimeFormatted;        -- 医嘱执行时间
        YZZZSJ := endTimeFormatted;            -- 医嘱终止时间
        YZSM := rec.adviceDescription;         -- 医嘱说明
        YZZH := rec.groupNo;                   -- 医嘱组号
        YZLB := adviceCategory;            -- 医嘱类别
        YZMXBM := rec.detailCode;              -- 医嘱明细编码
        YZMXMC := rec.detailName;              -- 医嘱明细名称
        YZLX := rec.isDrug;                    -- 是否药品
        JXDM := rec.dosageFormCode;            -- 剂型代码
        JXMC := rec.dosageFormName;            -- 医院剂型名称
        YPGG := rec.drugSpec;                  -- 药品规格
        YPYF := rec.drugUsage;                 -- 药品用法
        YYPD := rec.frequency;                 -- 用药频度
        JL := rec.dosePerTime;                 -- 每次使用剂量
        DW := rec.doseUnit;                    -- 每次使用剂量单位
        MCSL := rec.qtyPerTime;                -- 每次使用数量
        MCDW := rec.qtyUnit;                   -- 每次使用数量单位
        YF := rec.adminRoute;                  -- 给药途径(用法)
        JE := rec.amount;                      -- 金额
        YYTS := rec.drugDays;                  -- 用药天数
        SFPS := skinTestFlag;              -- 皮试判别
        YPSL := rec.dispenseQty;               -- 发药数量
        YPDW := rec.dispenseUnit;              -- 发药数量单位
        JYDM := rec.decoctionCode;             -- 中药煎煮法代码
        ZYSYLBDM := rec.tcmUsageCode;          -- 中药使用类别代码
        JCBW := rec.examPart;                  -- 检查部位
        CFYPZH := rec.presGroupNo;             -- 处方药品组号
        DZSQDBH := rec.eReqNo;                 -- 电子申请单编号
        YZXMLXDM := rec.itemTypeCode;          -- 医嘱项目类型代码
        YZXMNR := rec.itemContent;             -- 医嘱项目内容
        YZJHKSR := planStartTimeFormatted;     -- 医嘱计划开始日期时间
        YZJHJSRQ := planEndTimeFormatted;      -- 医嘱计划结束日期时间
        YZBZXX := rec.adviceRemarks;           -- 医嘱备注信息
        YZSHRQM := rec.auditEmpName;           -- 医嘱审核人姓名
        YZSHRGH := rec.auditEmpId;             -- 医嘱审核人工号
        YZSHRQSJ := auditTimeFormatted;        -- 医嘱审核日期时间
		-- 处理
        HDYZHSQM := rec.checkNurseName;        -- 核对医嘱护士姓名
        HDYZHSGH := rec.checkNurseId;          -- 核对医嘱护士工号
        YZHDRQSJ := checkTimeFormatted;        -- 医嘱核对日期时间
		-- 停止
        TZYZZQM := rec.stopEmpName;            -- 停止医嘱者姓名
        TZYZZGH := rec.stopEmpId;              -- 停止医嘱者工号
		-- 撤销
        YZQXRQSJ := cancelTimeFormatted;       -- 医嘱取消日期时间
        QXYZZQM := cancelEmpName;          -- 取消医嘱者姓名
        QXYZZGH := cancelEmpId;            -- 取消医嘱者工号
        BZ := rec.notes;                       -- 备注
        XGBZ := '0';                -- 修改标志
        MJ := '000000';               -- 密级
        YLYL1 := '';                           -- 预留一
        YLYL2 := ''; 							-- 数据采集时间

        RETURN NEXT;
    END LOOP;

    RETURN;
END;
$function$
;
