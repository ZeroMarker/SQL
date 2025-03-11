-- DROP FUNCTION ho_his.tb_yl_patient_information(timestamp, timestamp);

CREATE OR REPLACE FUNCTION ho_his.tb_yl_patient_information(start_time timestamp without time zone, end_time timestamp without time zone)
 RETURNS TABLE(KH varchar, KLX varchar, YLJGDM varchar, JKKH varchar, FKDQ varchar, ZJHM varchar, ZJLX varchar, ZJLXMC varchar, XB varchar, XBMC varchar, XM varchar, HZLX varchar, HYZK varchar, HYZKMC varchar, CSRQ varchar, CSD varchar, MZ varchar, MZMC varchar, GJ varchar, GJMC varchar, DHHM varchar, SJHM varchar, GZDWYB varchar, GZDWMC varchar, GZDWDZ varchar, JZDZ varchar, HKDZ varchar, HKDZYB varchar, LXRXM varchar, LXRGX varchar, LXRGXMC varchar, LXRDZ varchar, LXRYB varchar, LXRDH varchar, CXJMJKDABH varchar, GZDWDHHM varchar, JDRQSJ varchar, JDYLJGZZDM varchar, JDZXM varchar, MJ varchar, XGBZ varchar, YWSCSJ varchar, YYDAH varchar, YLYL1 varchar, YLYL2 varchar)
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec RECORD; -- 声明 rec 为记录类型
	dateOfBirth varchar; 
	createDatetime varchar;
	dataDatetime varchar;
BEGIN
    -- 1. 循环数据
	FOR rec IN 
        SELECT
            /*
            (2)卡类型的编码 0：社保卡；1：医保卡；2：统一自费卡；
3：非统一自费卡；5：新农合卡；6:居民健康卡；9：其他卡。
            */
            pcr.card_no AS cardno,
			cpctd.id AS cardType,
			coh.code AS hospCode,
			ppm.insur_card_no AS insuCard,
	        '-' AS issueArea, -- ? 发卡地区 社保卡
			ppm.cred_no AS credNo,
			cpctd.code AS credType,
			cpctd.description AS credName,
			hcg.code AS genderCode,
			hcg.name AS genderName,
			ppm.name AS patName,
			'1' AS patType,
			hcms.code AS maritalCode,
			hcms.name AS maritalName,
			ppm.birth_day AS dateOfBirth,
			'' AS birthPlace,
			hcn.code AS nationCode,
			hcn.name AS nation,
			hcc.code AS countryCode,
			hcc.chn_short_desc AS country,
			ppm.tel_home AS telephone,
			ppm.mob_phone AS mobilePhone,
			ppm.company_zip AS companyPost,
			ppm.company AS company,
			pps.empl_company AS companyAddress,
			ppa.live_address_dr AS liveAddress,
			ppa.house_address AS homeAddress,
			ppa.house_zip_code AS homeAddressPost,
			pps.foreign_mobile AS foreignName,
			cdr.code AS foreignRelationCode,
			cdr.displayname AS foreignRelationName,
			ppc.address AS foreignAddress,
			ppc.zip_code AS foreignPost,
			pps.foreign_mobile AS foreignPhone,
			'-' AS healthNo,
			pps.company_contact_tel AS companyPhone,
			pcr.create_datetime AS createDatetime,
			coh.code AS createHospCode,
			hua.name AS createUser,
			'' AS secretLevel,
			'' AS updateFlag,
			pcr.datetime AS dataDatetime,
			ppm.no AS documentNo
        FROM
            pa_card_ref pcr
        LEFT JOIN
            pa_pat_mast ppm ON pcr.papmi_dr = ppm.id
		LEFT JOIN 
            ct_org_hospital coh ON ppm.hospital_dr = coh.id
        LEFT JOIN
            ct_pa_card_type_def cpctd ON pcr.card_type_dr = cpctd.id
       	LEFT JOIN
        	hos_ct_identity_type_dict hcitd ON ppm.cred_type_dr = hcitd.id
		LEFT JOIN
			hos_ct_gender hcg ON ppm.sex_dr = hcg.id
		LEFT JOIN
			pa_pat_social pps ON pps.pa_pat_mast_dr = ppm.id
		LEFT JOIN
			hos_ct_marriage_status hcms ON pps.marital_dr = hcms.id
		LEFT JOIN
			hos_user_account hua ON hua.id = pcr.user_dr
		LEFT JOIN
			hos_ct_nationality hcn ON hcn.id = pps.nation_dr
		LEFT JOIN
			pa_pat_address ppa ON ppa.pa_pat_mast_dr = ppm.id
		LEFT JOIN
			hos_ct_country hcc ON hcc.id = ppa.country_dr
		LEFT JOIN
			pa_pat_contacter ppc ON ppc.pa_pat_mast_parref = ppm.id
		LEFT JOIN
			ct_dic_relation cdr ON cdr.id = ppc.ctrlt_dr
        WHERE 
            DATE(pcr.update_datetime) >= start_time AND 
            DATE(pcr.update_datetime) <= end_time
        ORDER BY 
            pcr.update_datetime
	
    LOOP
        -- 2. 处理数据
		dateOfBirth = TO_CHAR(rec.dateOfBirth, 'YYYYMMDD');
		IF dateOfBirth IS NULL OR dateOfBirth = '' THEN
            -- RAISE NOTICE '出生日期为空,对应就诊id: %', rec.episodeId;
        END IF;

		createDatetime = TO_CHAR(rec.createDatetime, 'YYYY-MM-DD HH24:MI:SS');
		IF createDatetime IS NULL OR createDatetime = '' THEN
            -- RAISE NOTICE '建档日期时间为空,对应就诊id: %', rec.episodeId;
        END IF;

		dataDatetime = TO_CHAR(rec.dataDatetime, 'YYYY-MM-DD HH24:MI:SS');
		IF dataDatetime IS NULL OR dataDatetime = '' THEN
            -- RAISE NOTICE '数据日期时间为空,对应就诊id: %', rec.episodeId;
        END IF;
		
		-- 卡类型
		/*
		(2)卡类型的编码 0：社保卡；1：医保卡；2：统一自费卡；
3：非统一自费卡；5：新农合卡；6:居民健康卡；9：其他卡。
		*/
		
		
		-- 患者类型
		/*
		编码。1：本地；2：外地；3：境外(港澳台)；4：外国；5：未知
		*/

        
		
        -- 3. 对照字段
        KH := rec.cardNo;              -- 卡号
	    KLX := rec.cardType;             -- 卡类型
	    YLJGDM := rec.hospCode;          -- 医疗机构代码
	    JKKH := rec.insuCard;            -- 社保卡号
	    FKDQ := '-';            -- 发卡地区
	    ZJHM := rec.credNo;            -- 证件号码
	    ZJLX := rec.credType;            -- 证件类型
	    ZJLXMC := rec.credType;          -- 医院证件类型名称
	    XB := rec.genderName;              -- 性别
	    XBMC := rec.genderCode;            -- 性别名称
	    XM := rec.patName;              -- 姓名
	    --HZLX := rec.patType;            -- 患者类型
	    HYZK := rec.maritalCode;            -- 婚姻状况
	    HYZKMC := rec.maritalName;          -- 医院婚姻状况名称
	    CSRQ := dateOfBirth;            -- 出生日期
	    CSD := rec.birthPlace;             -- 出生地
	    MZ := rec.nationCode;              -- 民族
	    MZMC := rec.nation;            -- 医院民族名称
	    GJ := rec.countryCode;              -- 国籍
	    GJMC := rec.country;            -- 医院国籍名称
	    DHHM := rec.telephone;            -- 电话号码
	    SJHM := rec.mobilePhone;            -- 手机号码
	    GZDWYB := rec.companyPost;          -- 工作单位邮编
	    GZDWMC := rec.company;          -- 工作单位名称
	    GZDWDZ := rec.companyAddress;          -- 工作单位地址
	    JZDZ := rec.liveAddress;            -- 居住地址
	    HKDZ := rec.homeAddress;            -- 户口地址
	    HKDZYB := rec.homeAddressPost;          -- 户口地址邮编
	    LXRXM := rec.foreignName;           -- 联系人姓名
	    LXRGX := rec.foreignRelationCode;           -- 联系人关系
	    LXRGXMC := rec.foreignRelationName;         -- 联系人关系名称
	    LXRDZ := rec.foreignAddress;           -- 联系人地址
	    LXRYB := rec.foreignPost;           -- 联系人邮编
	    LXRDH := rec.foreignPhone;           -- 联系人电话
	    CXJMJKDABH := rec.healthNo;      -- 城乡居民健康档案编号
	    GZDWDHHM := rec.companyPhone;        -- 工作单位电话号码
	    JDRQSJ := rec.createDatetime;          -- 建档日期时间
	    JDYLJGZZDM := rec.createHospCode;      -- 建档医疗机构组织机构代码
	    JDZXM := rec.createUser;           -- 建档者姓名
	    -- MJ := rec.secretLevel;              -- 密级
		MJ := '000000';              -- 密级
	    --XGBZ := rec.updateFlag;            -- 修改标志
		XGBZ := '0';            -- 修改标志
	    YWSCSJ := dataDateTime;          -- 数据生成时间
	    YYDAH := rec.documentNo;           -- 医院内部档案号
	    YLYL1 := '';           -- 预留一
	    YLYL2 := '';            -- 数据采集时间
		
        RETURN NEXT;
    END LOOP;

    -- 结束函数
    RETURN;
END;
$function$
;
