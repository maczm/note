--查询订单BOM
SELECT
    --工序名称
    TTOPR.MEDIUM AS OPRSEQUENCENAME,
    --物料编码
    PRO.PRODUCTNO,
    --物料描述
    TT.MEDIUM    AS PRODUCTDESC,
    TEMP.WIPORDERNO,
    TEMP.SCHEDULEDSTARTDATE,
    TEMP.SAPWIPORDERTYPE
FROM WIP_COMPONENT                                        WCO
         JOIN      COMPONENT                              COM
         ON WCO.COMPONENTID = COM.ID
         JOIN      PRODUCT                                PRO
         ON COM.PRODUCTID = PRO.ID
         LEFT JOIN TEXT_TRANSLATION                       TT
         ON TT.TEXTID = PRO.TEXTID
             AND TT.LANGUAGEID = '2052'
         JOIN      ILT_PRODUCT_FACILITY                   IPF
         ON IPF.PRODUCTNO = PRO.PRODUCTNO
             AND IPF.FACILITY = '5802'
             AND IPF.ACTIVE = 1
         LEFT JOIN WIP_OPERATION                          WO
         ON WCO.WIPORDERNO = WO.WIPORDERNO
             AND WCO.WIPORDERTYPE = WO.WIPORDERTYPE
             AND WCO.OPRSEQUENCENO = WO.OPRSEQUENCENO
         LEFT JOIN TEXT_TRANSLATION                       TTOPR
         ON TTOPR.TEXTID = WO.TEXTID
             AND TTOPR.LANGUAGEID = '2052'
         JOIN      (SELECT WO.WIPORDERNO,
                           WO.SCHEDULEDSTARTDATE,
                           IWO.SAPWIPORDERTYPE,
                           WO.WIPORDERTYPE
                    FROM WIP_ORDER              WO
                             JOIN ILT_WIP_ORDER IWO
                             ON IWO.WIPORDERNO = WO.WIPORDERNO
                    WHERE IWO.SAPWIPORDERTYPE LIKE 'ZF%') TEMP
         ON WCO.WIPORDERTYPE = TEMP.WIPORDERTYPE
             AND WCO.WIPORDERNO = TEMP.WIPORDERNO
WHERE TEMP.SCHEDULEDSTARTDATE <= TO_DATE(TO_CHAR(SYSDATE + 2, 'yyyy-MM-dd'), 'yyyy-MM-dd')
  AND TEMP.SCHEDULEDSTARTDATE > TO_DATE(TO_CHAR(SYSDATE, 'yyyy-MM-dd'), 'yyyy-MM-dd')
  AND PRO.PRODUCTNO = 'BCB005675940'
ORDER BY TEMP.SCHEDULEDSTARTDATE DESC;