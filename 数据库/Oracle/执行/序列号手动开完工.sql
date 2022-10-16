SELECT
    WOP.WORKCENTER,                   --工位
    TTWC.MEDIUM  AS WCNAME,           --工位描述
    WO.WIPORDERNO,                    --工单
    WOSN.SERIALNO,--SN
    CASE WSNC.REFERENCEID
        WHEN 1
            THEN N'在制'
        WHEN 2
            THEN N'完工'
            ELSE N'派工'
        END      AS SERIALNOSTATUS,   --序列号状态
    IPF.PRODUCTALIAS,--物料简码
    P.PRODUCTNO,                      --物料编码
    TTP.MEDIUM   AS PNAME,            --物料描述
    IWO.CONTROLCODE,--工序控制码
    WOP.OPRSEQUENCENO,                --工序
    TTWOP.MEDIUM AS OPRSEQUENCENODESC,--工序号描述
    WOP.PROGRESSSTATUS,               --工序状态
    TTPS.MEDIUM  AS PSNAME,           --工序状态描述
    WOP.SCHEDULEDSTARTDATE,           --计划开工时间
    WOP.SCHEDULEDCOMPLETIONDATE       --计划完工时间
FROM
    WIP_ORDER                           WO
        JOIN
                  PRODUCT               P
                  ON P.ID = WO.PRODUCTID
        JOIN
                  WIP_ORDER_SERIAL_NO   WOSN
                  ON WO.WIPORDERNO = WOSN.WIPORDERNO
                      AND WO.WIPORDERTYPE = WOSN.WIPORDERTYPE
                      AND WO.PRODUCTID = WOSN.PRODUCTID
        LEFT JOIN
                  TEXT_TRANSLATION      TTP
                  ON TTP.TEXTID = P.TEXTID
                      AND TTP.LANGUAGEID = '2052'
        JOIN
                  WIP_OPERATION         WOP
                  ON WO.WIPORDERNO = WOP.WIPORDERNO
                      AND WO.WIPORDERTYPE = WOP.WIPORDERTYPE
                      --工序号描述
        LEFT JOIN TEXT_TRANSLATION      TTWOP
                  ON WOP.TEXTID = TTWOP.TEXTID
                      AND TTWOP.LANGUAGEID = '2052'
        JOIN
                  WIP_CONTENT           WCO
                  ON WOP.WIPORDERNO = WCO.WIPORDERNO
                      AND WOP.WIPORDERTYPE = WCO.WIPORDERTYPE
                      AND WOP.OPRSEQUENCENO = WCO.OPRSEQUENCENO
                      AND WCO.WIPCONTENTCLASS = 1
        JOIN
                  WIP_SERIAL_NO_CONTENT WSNC
                  ON WSNC.PRODUCTID = WOSN.PRODUCTID
                      AND WSNC.SERIALNO = WOSN.SERIALNO
                      AND WSNC.WIPCONTENTID = WCO.ID
        LEFT JOIN
                  WORK_CENTER           WC
                  ON WC.WORKCENTER = WOP.WORKCENTER
        LEFT JOIN
                  TEXT_TRANSLATION      TTWC
                  ON TTWC.TEXTID = WC.TEXTID
                      AND TTWC.LANGUAGEID = '2052'
                      --取工序状态编码
        LEFT JOIN
                  PROGRESS_STATUS       PS
                  ON WOP.PROGRESSSTATUS = PS.PROGRESSSTATUS
                      --取工序状态描述
        LEFT JOIN
                  TEXT_TRANSLATION      TTPS
                  ON TTPS.TEXTID = PS.TEXTID
                      AND TTPS.LANGUAGEID = '2052'
        JOIN
                  EMPLOYEE_WORK_CENTER  EWC
                  ON EWC.WORKCENTER = WOP.WORKCENTER
                      --         JOIN
                      --                   EMPLOYEE              E
                      --                   ON E.ID = EWC.EMPLOYEEID
                      --                       AND E.EMPLOYEENO = @EMPLOYEENO
        LEFT JOIN ILT_PRODUCT_FACILITY  IPF
                  ON P.PRODUCTNO = IPF.PRODUCTNO
                      AND IPF.FACILITY = '5802'
                      --取工序控制码
        LEFT JOIN ILT_WIP_OPERATION     IWO
                  ON WOP.WIPORDERNO = IWO.WIPORDERNO
                      AND WOP.WIPORDERTYPE = IWO.WIPORDERTYPE
                      AND WOP.OPRSEQUENCENO = IWO.OPRSEQUENCENO
WHERE
      WOP.PROGRESSSTATUS IN ('120', '130')
  AND WOSN.SERIALNO = 's618004'--IS NOT NULL
  AND (WSNC.REFERENCEID IS NULL OR WSNC.REFERENCEID = 0 OR WSNC.REFERENCEID = 1)
      --   AND @SEARCHFLAG = 1
      --   {SqlWhere}
ORDER BY
    WOP.OPRSEQUENCENO,
    WOP.WORKCENTER,
    WOP.SCHEDULEDSTARTDATE;