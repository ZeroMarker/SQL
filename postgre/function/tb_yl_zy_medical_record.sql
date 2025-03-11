-- DROP FUNCTION ho_his.tb_yl_zy_medical_record(timestamp, timestamp);

CREATE OR REPLACE FUNCTION ho_his.tb_yl_zy_medical_record(start_time timestamp without time zone, end_time timestamp without time zone)
 RETURNS TABLE(YLJGDM varchar, JZLSH varchar, CISID varchar, KH varchar, KLX varchar, HZXM varchar, JZLX varchar, JZLXMC varchar, BXLX varchar, BXLXMC varchar, TXBZ varchar, WDBZ varchar, JZKSBM varchar, JZKSMC varchar, CYKSBM varchar, CYKSMC varchar, ZYZZYSGH varchar, ZYZZYSXM varchar, ZDBM varchar, ZDMC varchar, BMLX varchar, RYSJ varchar, CYSJ varchar, XGBZ varchar, MJ varchar, YLYL1 varchar, YLYL2 varchar)
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec RECORD;
    admissionTimeFormatted varchar;
    dischargeTimeFormatted varchar;
	admtypeCode varchar;
	admtypeName varchar;
	chargetypeCode varchar;
BEGIN
    FOR rec IN 
        SELECT
            coh.code AS hospCode,                        -- 医疗机构代码
            p.id AS visitSerialNo,               -- 住院就诊流水号
            ip.inpatno AS inpatientNo,             -- 住院号
           	ppm."no" AS patNo,                       -- 卡号
            cpctd.code AS cardType,                         -- 卡类型
            ppm."name" AS patientName,                     -- 患者姓名
            p.admtype AS admtype,        -- 就诊类型
            '' AS visitTypeName,        -- 医院就诊类型名称
            cpc.code AS insuranceTypeCode,-- 保险类型
            cpc.displayname AS insuranceTypeName,-- 保险类型名称
            '' AS specialNeedFlag,    -- 特需标志
            '' AS nonLocalFlag,          -- 外地标志
            d1.code AS admissionDeptCode,              -- 入院科室编码
            d1.name AS admissionDeptName,              -- 入院科室名称
            d2.code AS dischargeDeptCode,              -- 出院科室编码
            d2.name AS dischargeDeptName,              -- 出院科室名称
            crc.code AS attendingDoctorId,      -- 主治医生工号
            crc.displayname AS attendingDoctorName,           -- 主治医生姓名
            cmi.icd10 AS diagCode,                -- 诊断编码
            cmi.displayname AS diagName,               -- 医院诊断名称
            '' AS codeType,                -- 诊断编码类型
            ip.admin_datetime AS admissionDatetime, -- 入院时间
            ip.discharge_datetime AS dischargeDatetime, -- 出院时间
            '' AS updateFlag,               -- 修改标志
            '' AS securityLevel          -- 密级
        FROM
            paadm p
		LEFT JOIN
			pa_pat_mast ppm ON p.papmi_dr = ppm.id
        LEFT JOIN
            pa_card_ref pcr ON pcr.papmi_dr = ppm.id
        LEFT JOIN 
			ct_org_hospital coh on p.admhosp_dr = coh.id
        LEFT JOIN
            ct_pa_card_type_def cpctd ON pcr.card_type_dr = cpctd.id
		LEFT JOIN
			paadm_ip ip ON ip.paadm_parref = p.id
        LEFT JOIN
            hos_org_business_unit d1 ON ip.adminloc_dr = d1.id
        LEFT JOIN
            hos_org_business_unit d2 ON ip.adminloc_dr = d2.id -- ? 出院科室
        LEFT JOIN
            ct_rb_careprov crc ON p.admdoc_dr = crc.id
		LEFT JOIN
			ct_pa_chargetype cpc ON cpc.id = p.charge_type_dr
		LEFT JOIN 
			mr_diagnos md on p.mradm_dr = md.mr_adm_parref and md.main_diag_flag = true and md.active_flag = true
		LEFT JOIN 
			ct_mr_icddx cmi on cmi.id = md.icd_code_dr
        WHERE 
			DATE(p.adm_datetime) >= start_time and 
			DATE(p.adm_datetime) <= end_time and 
			p.admtype IN ('I') and
			p.visitstatus IN ('A', 'D')
		ORDER BY 
            p.adm_datetime
    LOOP
        -- Format admission time
        admissionTimeFormatted := TO_CHAR(rec.admissionDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF admissionTimeFormatted IS NULL THEN
            admissionTimeFormatted := '';
        END IF;

        -- Format discharge time
        dischargeTimeFormatted := TO_CHAR(rec.dischargeDatetime, 'YYYY-MM-DD HH24:MI:SS');
        IF dischargeTimeFormatted IS NULL THEN
            dischargeTimeFormatted := '';
        END IF;

		admtypeCode := (SELECT toCode FROM ho_his.compare_admtype(rec.admtype));
		IF admtypeCode IS NULL OR admtypeCode = '' THEN
            RAISE NOTICE '就诊类型为空,对应就诊id: %', rec.episodeId;
        END IF;
		
		admtypeName := (SELECT toDesc FROM ho_his.compare_admtype(rec.admtype));
		IF admtypeName IS NULL OR admtypeName = '' THEN
            RAISE NOTICE '就诊类型为空,对应就诊id: %', rec.episodeId;
        END IF;

		chargetypeCode := (SELECT toCode FROM ho_his.compare_chargetype(rec.insuranceTypeCode));
		IF chargetypeCode IS NULL OR chargetypeCode = '' THEN
            RAISE NOTICE '保险类型为空,对应就诊id: %', rec.episodeId;
        END IF;
		

        -- Map fields to RETURN TABLE columns
        YLJGDM := rec.hospCode;                -- 医疗机构代码
        JZLSH := rec.visitSerialNo;            -- 住院就诊流水号
        CISID := rec.inpatientNo;              -- 住院号
        KH := rec.patNo;                      -- 卡号
        KLX := '2';                   -- 卡类型
        HZXM := rec.patientName;               -- 患者姓名
        JZLX := admtypeCode;             -- 就诊类型
        JZLXMC := admtypeName;           -- 医院就诊类型名称
        BXLX := chargetypeCode;         -- 保险类型
        BXLXMC := rec.insuranceTypeName;       -- 保险类型名称
        TXBZ := '0';           -- 特需标志
        WDBZ := '5';              -- 外地标志
        JZKSBM := rec.admissionDeptCode;       -- 入院科室编码
        JZKSMC := rec.admissionDeptName;       -- 入院科室名称
        CYKSBM := rec.dischargeDeptCode;       -- 出院科室编码
        CYKSMC := rec.dischargeDeptName;       -- 出院科室名称
        ZYZZYSGH := rec.attendingDoctorId;     -- 主治医生工号
        ZYZZYSXM := rec.attendingDoctorName;   -- 主治医生姓名
        ZDBM := rec.diagCode;                  -- 诊断编码
        ZDMC := rec.diagName;                  -- 医院诊断名称
        BMLX := '01';                  -- 诊断编码类型
        RYSJ := admissionTimeFormatted;        -- 入院时间
        CYSJ := dischargeTimeFormatted;        -- 出院时间
        XGBZ := '0';                -- 修改标志
        MJ := '000000';               -- 密级
        YLYL1 := '';                           -- 预留一
        YLYL2 := '';							-- 数据采集时间

        RETURN NEXT;
    END LOOP;

    RETURN;
END;
$function$
;
