--查询订单BOM
SELECT
	--工序号
	WCO.OPRSEQUENCENO
	--工序名称
	,TTOPR.MEDIUM AS OPRSEQUENCENAME
    --组件数量
	/** add by chenkui 2021-01-29 用于组件出现负数 start**/
    ,case when IWC.PLUSMINUSFLAG='S' then (0-COM.QUANTITY) ELSE COM.QUANTITY END AS QUANTITY
	/** add by chenkui 2021-01-29 用于组件出现负数 end**/
	--物料简码
	,IPF.PRODUCTALIAS
    --物料编码
    ,PRO.PRODUCTNO
	--物料描述
    ,TT.MEDIUM AS PRODUCTDESC
    --是否为关重件
    ,CASE
      WHEN IPF.importantPROduct is not null THEN '是'
      ELSE '否' END
      AS IMPORTANTPRODUCTDESC
	,CASE
      WHEN IPF.importantPROduct is not null THEN 1
      ELSE 0 END
      AS IMPORTANTPRODUCTSEQ
FROM WIP_COMPONENT WCO
    JOIN COMPONENT COM
        ON WCO.COMponentID = COM.id
	/** add by chenkui 2021-01-29 用于组件出现负数 start**/
	JOIN ILT_WIP_COMPONENT IWC
		ON IWC.COMPONENTID=COM.ID
	/** add by chenkui 2021-01-29 用于组件出现负数 end**/
    JOIN PRODUCT PRO
        ON COM.PROductID = PRO.id
    LEFT JOIN TEXT_TRANSLATION TT
        ON TT.textId = PRO.textId
        AND TT.languageId = @LanguageID
    JOIN ILT_PRODUCT_FACILITY IPF
        ON IPF.PROductNo = PRO.PROductNo
		AND IPF.facility = @Facility
        AND IPF.active = 1
	LEFT JOIN WIP_OPERATION WO
		ON WCO.WIPORDERNO = WO.WIPORDERNO
		AND WCO.WIPORDERTYPE = WO.WIPORDERTYPE
		AND WCO.OPRSEQUENCENO = WO.OPRSEQUENCENO
	LEFT JOIN TEXT_TRANSLATION TTOPR
		ON TTOPR.TEXTID = WO.TEXTID
		AND TTOPR.LANGUAGEID = @LanguageID
	--LEFT JOIN ILT_PRODUCT_FACILITY IPF
		--ON PRO.productno=IPF.productno
		--AND IPF.FACILITY=@Facility
WHERE 1 = 1
    AND WCO.wipordertype = @WipOrderType
    AND WCO.wiporderno = @WipOrderNo;


SELECT *
FROM
    FLXUSER.ILT_WIP_COMPONENT
WHERE PLUSMINUSFLAG = 'S' ;