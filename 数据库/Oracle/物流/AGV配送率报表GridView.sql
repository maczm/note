SELECT
    LISTAGG(TT.MEDIUM, ',')                                                                               AS LINENAME,
    LISTAGG(WL.PRODUCTIONLINENO, ',')                                                                     AS PRODUCTIONLINENO,
    AG.WORKCENTER,
    TT1.MEDIUM                                                                                            AS WORKCENTERNAME,
    NVL(AGVDISTATOL, 0)                                                                                   AS AGVDISTATOL,
    NVL(QUANTITY, 0)                                                                                      AS QUANTITY,
    TO_CHAR(DECODE(QUANTITY, 0, 0, NVL(ROUND(AGVDISTATOL / QUANTITY * 100, 2), 0)), 'fm999990.00') || '%' AS DISRATE
FROM
    (SELECT
         WL.WORKCENTER,
         NVL(SUM(AGVDISTATOL), 0) AS AGVDISTATOL
     FROM
         (SELECT
              WL.LOCATION,
              WL.WORKCENTER
          FROM
              WAREHOUSE_LOCATION                   WL
                  LEFT JOIN
                            ILT_WAREHOUSE_LOCATION IWL
                            ON WL.ID = IWL.LOCATIONID
                                AND IWL.ACTIVE = '1'
                  LEFT JOIN
                            EMPLOYEE               EMUP
                            ON EMUP.EMPLOYEENO = WL.LASTUPDATEDBY
                  LEFT JOIN
                            EMPLOYEE               EMCR
                            ON EMCR.EMPLOYEENO = WL.LASTUPDATEDBY
                  LEFT JOIN
                            TEXT_TRANSLATION       TTL
                            ON WL.TEXTID = TTL.TEXTID
                                AND TTL.LANGUAGEID = @LanguageID
                  LEFT JOIN WAREHOUSE              WH
                            ON WL.WAREHOUSE = WH.WAREHOUSE AND WH.FACILITY = @Facility
                  LEFT JOIN TEXT_TRANSLATION       WHTT
                            ON WH.TEXTID = WHTT.TEXTID AND WHTT.LANGUAGEID = @LanguageID
          WHERE
                WL.FACILITY = @Facility
            AND WL.WORKCENTER IS NOT NULL) WL
             LEFT JOIN (SELECT
                            COUNT(IOH.FROMLOCATION) AS AGVDISTATOL,
                            IOH.FROMLOCATION        AS LOCATION
                        FROM
                            ILT_ORDER_HEADER                    IOH
                                LEFT JOIN WAREHOUSE_LOCATION    WL
                                          ON IOH.TOLOCATION = WL.LOCATION
                                JOIN      ORDER_HEADER          OH
                                          ON (IOH.ORDERNO = OH.ORDERNO)
                                LEFT JOIN (SELECT DISTINCT
                                               ORDERNO,
                                               ORDERTYPE
                                           FROM
                                               ILT_ORDER_DETAIL
                                           WHERE
                                               ORDERTYPE = '8') IOD
                                          ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                        WHERE
                              TASKTYPE IN (4, 5, 6, 7, 46, 49)
                              {SqlFilterAgvTime}
                          AND PROGRESSSTATUS = 230
                        GROUP BY
                            FROMLOCATION
                        UNION ALL
                        SELECT
                            COUNT(
                                    IOH.TOLOCATION) AS AGVDISTATOL,
                            IOH.TOLOCATION          AS LOCATION
                        FROM
                            ILT_ORDER_HEADER                    IOH
                                LEFT JOIN WAREHOUSE_LOCATION    WL
                                          ON IOH.TOLOCATION = WL.LOCATION
                                JOIN      ORDER_HEADER          OH
                                          ON (IOH.ORDERNO = OH.ORDERNO)
                                LEFT JOIN (SELECT DISTINCT
                                               ORDERNO,
                                               ORDERTYPE
                                           FROM
                                               ILT_ORDER_DETAIL
                                           WHERE
                                               ORDERTYPE = '8') IOD
                                          ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                        WHERE
                                TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                {SqlFilterAgvTime}
                          AND   PROGRESSSTATUS = 230
                        GROUP BY
                            TOLOCATION)    DIS
                       ON WL.LOCATION = DIS.LOCATION
     WHERE
         WL.WORKCENTER IS NOT NULL
     GROUP BY
         WL.WORKCENTER)                AG
        -- 理论完工
        LEFT JOIN (SELECT
                       SAPWORKCENTER,
                       NVL(SUM(QUANTITY), 0) AS QUANTITY
                   FROM
                       (SELECT
                            DECODE(MATERIALQUANTITY, 0, 0, ROUND(QUANTITY / MATERIALQUANTITY * 2, 0)) AS QUANTITY,
                            SAPWORKCENTER
                        FROM
                            (SELECT
                                 SC.PRODUCTNO,
                                 SUM(SC.QUANTITY) AS QUANTITY,
                                 SC.SAPWORKCENTER
                             FROM
                                 -- SAP异常报工
                                 (SELECT
                                      -- 物料编码
                                      P.PRODUCTNO,
                                      -- 良品数
                                      IRSH.GOODQUANTITY AS QUANTITY,
                                      IWO.SAPWORKCENTER
                                  FROM
                                      ILT_REPORT_SAP_HIS                 IRSH
                                          -- 订单号
                                          JOIN      WIP_ORDER            WO
                                                    ON WO.WIPORDERNO = IRSH.WIPORDERNO
                                                        -- 订单号，订单类型
                                          JOIN      ILT_WIP_ORDER        IW
                                                    ON WO.WIPORDERNO = IW.WIPORDERNO AND WO.WIPORDERTYPE = IW.WIPORDERTYPE
                                                        -- 订单工序号
                                          LEFT JOIN WIP_OPERATION        WOP
                                                    ON IRSH.WIPORDERNO = WOP.WIPORDERNO AND
                                                       IRSH.WIPOPRSEQUENCENO = WOP.OPRSEQUENCENO
                                                        -- 订单类型 工序号
                                          LEFT JOIN ILT_WIP_OPERATION    IWO
                                                    ON WOP.WIPORDERNO = IWO.WIPORDERNO AND
                                                       WOP.WIPORDERTYPE = IWO.WIPORDERTYPE AND
                                                       WOP.OPRSEQUENCENO = IWO.OPRSEQUENCENO
                                                        -- 报工状态
                                          LEFT JOIN PROGRESS_STATUS      PS
                                                    ON IRSH.REPROTSAPSTATUS = PS.PROGRESSSTATUS
                                                        -- 物料ID
                                          LEFT JOIN PRODUCT              P
                                                    ON P.ID = WO.PRODUCTID
                                                        -- 物料工厂绑定关系
                                          LEFT JOIN ILT_PRODUCT_FACILITY IPF
                                                    ON P.PRODUCTNO = IPF.PRODUCTNO AND IPF.FACILITY = @Facility
                                  WHERE
                                      -- 160 为完工状态
                                      IRSH.REPROTSAPSTATUS = '160'
                                     -- 完工时间区间
                                     {SqlFilterReportTime}
                                 ) SC
                             GROUP BY
                                 SC.SAPWORKCENTER,
                                 SC.PRODUCTNO)    SC2 -- 工作中心 物料编码 良品数        配盘数
                                LEFT JOIN (SELECT
                                               NVL(MATERIALQUANTITY / MATERIALQUANTITYPARAMS, 0) AS MATERIALQUANTITY,
                                               PRODUCTNO
                                           FROM
                                               (SELECT
                                                    -- 物料编码
                                                    DISTINCT
                                                    P.PRODUCTNO,
                                                    -- 叫料数量
                                                    IOW.MATERIALQUANTITY,
                                                    -- 配盘参数
                                                    IOW.MATERIALQUANTITYPARAMS
                                                FROM
                                                    ILT_OPRSEQUENCE_WAREHOUSE_ZX       IOW
                                                        LEFT JOIN PRODUCT              P
                                                                  ON IOW.PRODUCTID = P.ID
                                                        LEFT JOIN ILT_PRODUCT_FACILITY IPF
                                                                  ON IPF.PRODUCTNO = P.PRODUCTNO
                                                        LEFT JOIN WAREHOUSE            WH
                                                                  ON WH.WAREHOUSE = IOW.WAREHOUSE AND WH.FACILITY = @Facility
                                                WHERE
                                                      IOW.ACTIVE = 1
                                                  AND IPF.FACILITY = @Facility
                                               )) P -- 物料编码 配盘数
                                          ON P.PRODUCTNO = SC2.PRODUCTNO
                       )
                   GROUP BY
                       SAPWORKCENTER)  O
                  ON O.SAPWORKCENTER = AG.WORKCENTER
                      -- 取工作中心名称
        LEFT JOIN WORK_CENTER          WC
                  ON AG.WORKCENTER = WC.WORKCENTER
        LEFT JOIN TEXT_TRANSLATION     TT1
                  ON WC.TEXTID = TT1.TEXTID
                      AND TT1.LANGUAGEID = @LanguageID
                      -- 取厂线及厂线名称
        LEFT JOIN WIP_LINE_WORK_CENTER WLWC
                  ON AG.WORKCENTER = WLWC.WORKCENTER
        LEFT JOIN WIP_LINE             WL
                  ON WLWC.PRODUCTIONLINENO = WL.PRODUCTIONLINENO
        LEFT JOIN TEXT_TRANSLATION     TT
                  ON TT.TEXTID = WL.TEXTID
                      AND TT.LANGUAGEID = @LanguageID
WHERE
    1 = 1
    {SqlFilterProDuctLineName}
    {SqlFilterOperationName}
    {SqlFilterWorkCenter}
GROUP BY
    AG.WORKCENTER,
    AGVDISTATOL,
    QUANTITY,
    TT1.MEDIUM