-- DROP FUNCTION ho_his.tb_diagnosis_detail(timestamp, timestamp);

CREATE OR REPLACE FUNCTION ho_his.tb_diagnosis_detail(start_time timestamp without time zone, end_time timestamp without time zone)
 RETURNS TABLE(ZYZDLSH varchar, YLJGDM varchar, JZLSH varchar, MZZYBZ varchar, KH varchar, KLX varchar, ZDLXQF varchar, ZDLB varchar, ZDLBMC varchar, ZDSJ varchar, ZDBM varchar, ZDBMMC varchar, BMLX varchar, ZDSM varchar, CYZDBZ varchar, YZDBZ varchar, RYBQ varchar, CYQKBM varchar, BAGDSJ varchar, MJ varchar, XGBZ varchar, YLYL1 varchar, YLYL2 varchar)
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec RECORD;
    diagTimeFormatted varchar;
    archiveTimeFormatted varchar;
	mainDiagFlag varchar;
	admType varchar;
	diagType varchar;
	dischargeConditionCode varchar;
	diagCategoryCode varchar;
BEGIN
    FOR rec IN 
        SELECT
            md.id AS diagNo,           -- 诊断流水号
            coh.code AS hospCode,                       -- 医疗机构代码
			p.id AS visitNo,				-- 就诊流水号
            p.admtype AS admType,  -- 门诊/住院标志 (e.g., 'O' for outpatient, 'I' for inpatient)
            pcr.card_no AS cardNo,                      -- 卡号
            cpctd.code AS cardType,                        -- 卡类型
            cmi.diag_type AS diagType,         -- 诊断类型区分
            cmd.displayname AS diagCategoryCode, -- 诊断类别代码
            cmd.displayname AS diagCategoryName, -- 医院诊断类别代码名称
            cmi.code AS diagCode,                  -- 诊断编码
			md.datetime AS diagDatetime,				-- 诊断时间
            cmi.displayname AS diagName,                  -- 医院诊断编码名称
            '' AS codeType,                  -- 诊断编码类型
            md.description AS diagDescription,    -- 诊断说明
            md.main_diag_flag AS mainDiagFlag,   -- 主要诊断标志
            '' AS suspectedDiagFlag, -- 疑似诊断标志
            '' AS admissionCondition, -- 入院病情
            cpd.displayname AS dischargeConditionCode, -- 出院情况编码
            '' AS archiveDatetime,    -- 病案归档时间
            '' AS secretLevel,        -- 密级
            '' AS updateFlag               -- 修改标志
        FROM
            mr_diagnos md
		LEFT JOIN
			mr_adm ma on ma.id = md.mr_adm_parref
		LEFT JOIN
			paadm p on p.id = ma.adm_dr
		LEFT JOIN
			paadm_ip ip on ip.paadm_parref = ip.id
		LEFT JOIN
			pa_pat_mast ppm on ppm.id = p.papmi_dr
        LEFT JOIN
            pa_card_ref pcr ON pcr.papmi_dr = ppm.id
        LEFT JOIN
            ct_org_hospital coh ON p.admhosp_dr = coh.id
        LEFT JOIN
            ct_pa_card_type_def cpctd ON pcr.card_type_dr = cpctd.id
		LEFT JOIN
			ct_mr_icddx cmi ON cmi.id = md.icd_code_dr
		LEFT JOIN
			ct_mr_diagnostype cmd ON cmd.id = md.diag_type_dr
		LEFT JOIN
			ct_pa_dischargecondition cpd ON cpd.id = ip.dischcond_dr
        WHERE 
            DATE(md.datetime) >= start_time AND 
            DATE(md.datetime) <= end_time
        ORDER BY 
            md.datetime
    LOOP
        -- Format diagnosis time
        diagTimeFormatted := TO_CHAR(rec.diagDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF diagTimeFormatted IS NULL THEN
            diagTimeFormatted := '';
        END IF;

        -- Format archive time
        archiveTimeFormatted := TO_CHAR(rec.archiveDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF archiveTimeFormatted IS NULL THEN
            archiveTimeFormatted := '';
        END IF;
		/*
		诊断类型区分
		1-	中医病名；
		2-	中医证候；
		3-	西医；

		*/
		
		diagType := CASE rec.diagType
	        WHEN '西医诊断' THEN 1
	        WHEN '中医诊断' THEN 2
	        WHEN '中医证候' THEN 3
	        ELSE NULL -- or handle the default case as needed
    	END;
		
		/*
		出院情况编码
		1：治愈、2：好转、3：未愈、4：死亡、5：其它(出院时 必填)
治愈
好转
稳定
恶化
死亡
		*/
		dischargeConditionCode := CASE TRIM(rec.dischargeConditionCode)
	        WHEN '治愈' THEN 1
	        WHEN '好转' THEN 2
	        WHEN '稳定' THEN 3
			WHEN '死亡' THEN 4
	        ELSE 5 -- or handle the default case as needed
    	END;

		CASE rec.diagType
	        WHEN '西医诊断' THEN
			diagCategoryCode := CASE TRIM(rec.diagCategoryCode)
		        WHEN '出院诊断' THEN 1
		        WHEN '门诊诊断' THEN 2
		        WHEN '入院诊断' THEN 3
				WHEN '补充诊断' THEN 13
		        ELSE 99 -- or handle the default case as needed
	    	END;
	        WHEN '中医诊断' THEN
			diagCategoryCode := CASE TRIM(rec.diagCategoryCode)
				WHEN '门诊诊断' THEN 1
				WHEN '入院诊断' THEN 2
		        WHEN '出院诊断' THEN 3
		        ELSE 99 -- or handle the default case as needed
	    	END;
	        WHEN '中医证候' THEN
			diagCategoryCode := CASE TRIM(rec.diagCategoryCode)
		        WHEN '门诊诊断' THEN 4
				WHEN '入院诊断' THEN 5
		        WHEN '出院诊断' THEN 6
		        ELSE 99 -- or handle the default case as needed
	    	END;
	        ELSE
			diagCategoryCode := 99; -- or handle the default case as needed
    	END CASE;
		
		/*
		1	出院诊断	住院期间所发现并明确的一切疾病诊断及伤残名称。
2	门诊诊断	在门诊、急诊所下诊断,含疗养的接诊诊断
3	入院初步诊断	入院后首次诊断
4	术前诊断	
5	术后诊断	
6	尸检诊断	死亡患者的尸检诊断
7	放射诊断	放射线检查明确的诊断
8	超声诊断	超声波检查明确的诊断
9	病理诊断	病理组织学检查明确的诊断
10	并发症诊断	在已患疾病的基础上发生的病症
11	院内感染诊断	入院48小时以上,由于病原体侵入而发生的各种病症
12	主要诊断	一次就医或住院的主要原因
13	次要诊断	一次就医或住院伴随主要诊断的疾病
99	其他	无法按上述类别归类

1	门诊中医诊断病名	指患者在门诊或急诊确定的中医诊断病名
2	入院中医诊断病名	指患者在住院后第一次确定的中医诊断病名
3	出院中医诊断病名	指患者在住院期间经治医师确定的最后中医诊断病名
4	门诊中医诊断证候	指患者在门诊或急诊确定的中医诊断证候
5	入院中医诊断证候	指患者在住院后第一次确定的中医诊断证候
6	出院中医诊断证候	指患者在住院期间经治医师确定的最后中医诊断证候

		补充诊断
入院诊断
门诊诊断
修正诊断
初步诊断
出院诊断
体检诊断

*/

		IF rec.mainDiagFlag THEN
			mainDiagFlag := '1';
		ELSE
			mainDiagFlag := '2';
		END IF;

		IF rec.admType = 'I' THEN
			admType := '2';
		ELSE
			admType := '1';
		END IF;
        -- Map fields to RETURN TABLE columns
        ZYZDLSH := rec.diagNo;           -- 诊断流水号
        YLJGDM := rec.hospCode;                -- 医疗机构代码
        JZLSH := rec.visitNo;            -- 就诊流水号
        MZZYBZ := rec.admType; 				-- 门诊/住院标志
        KH := rec.cardNo;                      -- 卡号
        KLX := '2';                   -- 卡类型
        ZDLXQF := diagType;            -- 诊断类型区分
        ZDLB := diagCategoryCode;          -- 诊断类别代码
        ZDLBMC := rec.diagCategoryName;        -- 医院诊断类别代码名称
        ZDSJ := diagTimeFormatted;             -- 诊断时间
        ZDBM := rec.diagCode;                  -- 诊断编码
        ZDBMMC := rec.diagName;                -- 医院诊断编码名称
        BMLX := '01';                  -- 诊断编码类型
        ZDSM := rec.diagDescription;           -- 诊断说明
        CYZDBZ := mainDiagFlag;         -- 主要诊断标志
        YZDBZ := '0';        -- 疑似诊断标志
        RYBQ := '1';        -- 入院病情
        CYQKBM := dischargeConditionCode;  -- 出院情况编码
        BAGDSJ := archiveTimeFormatted;        -- 病案归档时间
        MJ := '000000';               -- 密级
        XGBZ := '0';                -- 修改标志
        YLYL1 := '';                           -- 预留一
        YLYL2 := ''; 							-- 数据采集时间 (current time)

        RETURN NEXT;
    END LOOP;

    RETURN;
END;
$function$
;
