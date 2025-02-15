-- DROP FUNCTION ho_his.tb_his_mz_reg(timestamp, timestamp);

CREATE OR REPLACE FUNCTION ho_his.tb_his_mz_reg(start_time timestamp without time zone, end_time timestamp without time zone)
 RETURNS TABLE(GHRQ varchar, GHBM varchar, GTHBZ varchar, YLJGDM varchar, STFBH varchar, GTHSJ varchar, GHLB varchar, GHLBMC varchar, GHFS varchar, GHFSMC varchar, BXLX varchar, BXLXMC varchar, KSBM varchar, TXBZ varchar, WDBZ varchar, ZFZLF varchar, ZLF varchar, QTF varchar, KH varchar, KLX varchar, GHRCBS varchar, XGBZ varchar, YLYL1 varchar, YLYL2 varchar)
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec RECORD; -- 声明 rec 为记录类型
	updateDate varchar; updateDatetime varchar; returnFlag varchar; regtypeCode varchar;
	regtypeDesc varchar; regMethod varchar; chargetypeCode varchar; lookprice varchar; regMethodDesc varchar;
BEGIN
    -- 1. 循环数据
	FOR rec IN 
        SELECT 
			p.id AS episodeId,
			p.admno AS admno,
			p.admtype AS admtype,
			p.visitstatus AS visitstatus,
			p.adm_datetime AS admDatetime,
			p.create_datetime AS createDatetime,
			p.update_datetime AS updateDatetime,
            coh.code AS hospCode,
            coh.displayname AS hospDesc,
			aptp.code AS regfromCode,
			aptp.displayname AS regfromDesc,
			chgtp.code AS chargetypeCode,
			chgtp.displayname AS chargetypeDesc,
			regfee.lookprice AS lookprice,
			hobu.code AS locCode,
			hobu."name" AS locDesc,
            ppm."no" AS patNo
        FROM 
            paadm p
        LEFT JOIN 
            ct_org_hospital coh ON p.admhosp_dr = coh.id
        LEFT JOIN 
            ct_rb_appointtype aptp ON p.admditch = aptp.id
        LEFT JOIN 
            ct_pa_chargetype chgtp ON p.charge_type_dr = chgtp.id
        LEFT JOIN 
            hos_org_business_unit hobu ON p.admloc_dr = hobu.id
        LEFT JOIN 
            paadm_op_registration_fee regfee ON p.id = regfee.adm_dr
        LEFT JOIN 
            pa_pat_mast ppm ON p.papmi_dr = ppm.id
        WHERE 
            DATE(p.update_datetime) >= start_time AND 
            DATE(p.update_datetime) <= end_time AND 
            p.admtype IN ('O', 'E')
        ORDER BY 
            p.update_datetime
	
    LOOP
        -- 2. 处理数据
		updateDate = TO_CHAR(rec.updateDatetime, 'YYYYMMDD');
		IF updateDate IS NULL OR updateDate = '' THEN
            RAISE NOTICE '挂/退号日期为空,对应就诊id: %', rec.episodeId;
        END IF;

		updateDatetime = TO_CHAR(rec.updateDatetime, 'YYYY-MM-DD HH24:MI:SS');
		IF updateDatetime IS NULL OR updateDatetime = '' THEN
            RAISE NOTICE '挂/退号时间为空,对应就诊id: %', rec.episodeId;
        END IF;

		IF rec.visitstatus = 'C' THEN
            returnFlag := '2';
		ELSE
			returnFlag := '1';
		END IF;

		regtypeCode := (SELECT extcode FROM ho_his.sp_ct_dic_basedatamapdetail('QMJKXXPT','regtype',rec.admtype));
		IF regtypeCode IS NULL OR regtypeCode = '' THEN
            RAISE NOTICE '挂号类别代码为空,对应就诊id: %', rec.episodeId;
        END IF;

		regtypeDesc := (SELECT extname FROM ho_his.sp_ct_dic_basedatamapdetail('QMJKXXPT','regtype',rec.admtype));
		IF regtypeDesc IS NULL OR regtypeDesc = '' THEN
            RAISE NOTICE '挂号类别描述为空,对应就诊id: %', rec.episodeId;
        END IF;

		IF TO_CHAR(rec.createDatetime, 'YYYY-MM-DD') = TO_CHAR(rec.admDatetime, 'YYYY-MM-DD') THEN
            regMethod := '1';
		ELSE
			regMethod := '2';
		END IF;
		regMethodDesc = rec.regfromDesc;
		IF regMethodDesc IS NULL OR regMethodDesc = '' THEN
			IF regMethod = '1' THEN
	            regMethodDesc := '当日挂号';
			ELSE
				regMethodDesc := '预约挂号';
			END IF;
            RAISE NOTICE '医院挂号方式名称为空,对应就诊id: %,默认为: %', rec.episodeId, regMethodDesc;
        END IF;

		chargetypeCode := (SELECT toCode FROM ho_his.compare_chargetype(rec.chargetypeCode));
		IF chargetypeCode IS NULL OR chargetypeCode = '' THEN
            RAISE NOTICE '保险类型为空,对应就诊id: %', rec.episodeId;
        END IF;
		lookprice := COALESCE(rec.lookprice, '0');

        -- 3. 对照字段
        GHRQ := updateDate;				--挂/退号日期(复合主键；格式为YYYYMMDD)
        GHBM := rec.episodeId;			--门诊就诊流水号
		GTHBZ := returnFlag;			--退号标志(1:挂号,2:退号)
		YLJGDM := rec.hospCode;			--医疗机构代码
		STFBH := rec.admno;				--收/退费编号(见说明(3))
		GTHSJ := updateDatetime;		--挂/退号时间(YYYY-MM-DD HH:MM:SS)
		GHLB := regtypeCode;			--挂号类别
		GHLBMC := regtypeDesc;			--医院挂号类别名称(填医院内部挂号类别名称)
		GHFS := regMethod;				--挂号方式(1:现场窗口挂号,2:预约挂号(包括电话、网站、自助机等),9:其他)
		GHFSMC := regMethodDesc;		--医院挂号方式名称(填医院内部挂号方式名称)
		BXLX := chargetypeCode;			--保险类型(用来区分该次收费的医疗保险类别。见说明(5))
		BXLXMC := rec.chargetypeDesc;	--医院保险类型名称(填医院内部的保险类型名称)
		KSBM := rec.locCode;			--科室编码(填医院内定义的科室编号)
		TXBZ := '0';					--特需标志(0:非特需,1:特需) 
		WDBZ := '5';					--外地标志(1：本地；2：外地；3：境外(港澳台)；4：外国；5：未知)
		ZFZLF := lookprice;				--自费诊疗费(含挂号费)	(退号的费用也以正数表示,通过退号标志进行区分。若挂号时暂未收费则填入0；见说明(6))
		ZLF := lookprice;				--诊疗费(同上)
		QTF := '0';						--其它费(同上)
		KH := rec.patNo;				--卡号(见说明(7))
		KLX := '2';						--卡类型(0：社保卡；1：医保卡；2：统一自费卡；3：非统一自费卡；5：新农合卡；6:居民健康卡；9：其他卡)
		GHRCBS := '1';					--计入挂号人次标识(1：计入挂号人次；2：不计入挂号人次)
		XGBZ := '0';					--修改标志(0：正常、1：撤销)
		YLYL1 := '';					--预留一(为系统处理该数据而预留)
		YLYL2 := '';					--数据采集时间(不填,已有系统默认值)
		
        RETURN NEXT;
    END LOOP;

    -- 结束函数
    RETURN;
END;
$function$
;
