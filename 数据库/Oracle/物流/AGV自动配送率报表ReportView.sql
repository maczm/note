SELECT
    TT1.MEDIUM AS PRODUCTIONLINENAME,
    NVL(ROUND(DECODE(SUM(WLLP.AGVDISTATOL), 0, 0, SUM(WLLP.AGVDISAUTOTOTAL * 100) / SUM(WLLP.AGVDISTATOL)), 2),
        0)     AS AGVDISTATOLRATE
FROM
    WIP_LINE                                       WLP
        LEFT JOIN WIP_LINE_WORK_CENTER             WLWC
                  ON WLP.PRODUCTIONLINENO = WLWC.PRODUCTIONLINENO
        LEFT JOIN (SELECT
                       WOA.WORKCENTER,
                       WOA.OPRSEQUENCENO,
                       WOA2.AGVDISTATOL AS AGVDISAUTOTOTAL,
                       WOA.AGVDISTATOL
                   FROM
                       (SELECT
                            WL.WORKCENTER,
                            NVL(WLLP.OPRSEQUENCENO, WL.WORKCENTER) AS OPRSEQUENCENO,
                            SUM(WLLP.AGVDISTATOL)                  AS AGVDISTATOL
                        FROM
                            (SELECT
                                 LOCATION,
                                 OPRSEQUENCENO,
                                 SUM(AGVDISTATOL) AS AGVDISTATOL
                             FROM
                                 ((SELECT
                                       COUNT(IOH.FROMLOCATION) AS AGVDISTATOL,
                                       IOH.FROMLOCATION        AS LOCATION,
                                       IOD.OPRSEQUENCENO
                                   FROM
                                       ILT_ORDER_HEADER                    IOH
                                           LEFT JOIN WAREHOUSE_LOCATION    WL
                                                     ON IOH.TOLOCATION = WL.LOCATION
                                           JOIN      ORDER_HEADER          OH
                                                     ON (IOH.ORDERNO = OH.ORDERNO)
                                           LEFT JOIN (SELECT DISTINCT
                                                          ORDERNO,
                                                          ORDERTYPE,
                                                          TT.MEDIUM AS OPRSEQUENCENO
                                                      FROM
                                                          ILT_ORDER_DETAIL               IOD
                                                              LEFT JOIN WIP_OPERATION    WO
                                                                        ON WO.OPRSEQUENCENO = IOD.OPRSEQUENCENO
                                                                            AND WO.WIPORDERNO = IOD.WIPORDERNO
                                                                            AND WO.WIPORDERTYPE = IOD.WIPORDERTYPE
                                                              LEFT JOIN TEXT_TRANSLATION TT
                                                                        ON TT.TEXTID = WO.TEXTID
                                                                            AND TT.LANGUAGEID = @LanguageID
                                                      WHERE
                                                          ORDERTYPE = '8') IOD
                                                     ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                   WHERE
                                         TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                         {SqlFilterAgvTime}
                                     AND PROGRESSSTATUS = 230
                                   GROUP BY
                                       FROMLOCATION,
                                       IOD.OPRSEQUENCENO)
                                  UNION ALL
                                  (SELECT
                                       COUNT(IOH.TOLOCATION) AS AGVDISTATOL,
                                       IOH.TOLOCATION        AS LOCATION,
                                       IOD.OPRSEQUENCENO
                                   FROM
                                       ILT_ORDER_HEADER                    IOH
                                           LEFT JOIN WAREHOUSE_LOCATION    WL
                                                     ON IOH.TOLOCATION = WL.LOCATION
                                           JOIN      ORDER_HEADER          OH
                                                     ON (IOH.ORDERNO = OH.ORDERNO)
                                           LEFT JOIN (SELECT DISTINCT
                                                          ORDERNO,
                                                          ORDERTYPE,
                                                          TT.MEDIUM AS OPRSEQUENCENO
                                                      FROM
                                                          ILT_ORDER_DETAIL               IOD
                                                              LEFT JOIN WIP_OPERATION    WO
                                                                        ON WO.OPRSEQUENCENO = IOD.OPRSEQUENCENO
                                                                            AND WO.WIPORDERNO = IOD.WIPORDERNO
                                                                            AND WO.WIPORDERTYPE = IOD.WIPORDERTYPE
                                                              LEFT JOIN TEXT_TRANSLATION TT
                                                                        ON TT.TEXTID = WO.TEXTID
                                                                            AND TT.LANGUAGEID = @LanguageID
                                                      WHERE
                                                          ORDERTYPE = '8') IOD
                                                     ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                   WHERE
                                         TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                         {SqlFilterAgvTime}
                                     AND PROGRESSSTATUS = 230
                                   GROUP BY
                                       TOLOCATION,
                                       IOD.OPRSEQUENCENO)) WLLP
                             GROUP BY
                                 LOCATION,
                                 OPRSEQUENCENO)              WLLP
                                --取工作中心
                                LEFT JOIN WAREHOUSE_LOCATION WL
                                          ON WL.LOCATION = WLLP.LOCATION
                        GROUP BY
                            WL.WORKCENTER,
                            WLLP.OPRSEQUENCENO)               WOA
                           LEFT JOIN (SELECT
                                          WL.WORKCENTER,
                                          NVL(WLLP.OPRSEQUENCENO, WL.WORKCENTER) AS OPRSEQUENCENO,
                                          SUM(WLLP.AGVDISTATOL)                  AS AGVDISTATOL
                                      FROM
                                          (SELECT
                                               LOCATION,
                                               OPRSEQUENCENO,
                                               SUM(AGVDISTATOL) AS AGVDISTATOL
                                           FROM
                                               ((SELECT
                                                     COUNT(IOH.FROMLOCATION) AS AGVDISTATOL,
                                                     IOH.FROMLOCATION        AS LOCATION,
                                                     IOD.OPRSEQUENCENO
                                                 FROM
                                                     ILT_ORDER_HEADER                    IOH
                                                         LEFT JOIN WAREHOUSE_LOCATION    WL
                                                                   ON IOH.TOLOCATION = WL.LOCATION
                                                         JOIN      ORDER_HEADER          OH
                                                                   ON (IOH.ORDERNO = OH.ORDERNO)
                                                         LEFT JOIN (SELECT DISTINCT
                                                                        ORDERNO,
                                                                        ORDERTYPE,
                                                                        TT.MEDIUM AS OPRSEQUENCENO
                                                                    FROM
                                                                        ILT_ORDER_DETAIL               IOD
                                                                            LEFT JOIN WIP_OPERATION    WO
                                                                                      ON WO.OPRSEQUENCENO = IOD.OPRSEQUENCENO
                                                                                          AND
                                                                                         WO.WIPORDERNO = IOD.WIPORDERNO
                                                                                          AND
                                                                                         WO.WIPORDERTYPE = IOD.WIPORDERTYPE
                                                                            LEFT JOIN TEXT_TRANSLATION TT
                                                                                      ON TT.TEXTID = WO.TEXTID
                                                                                          AND TT.LANGUAGEID = @LanguageID
                                                                    WHERE
                                                                        ORDERTYPE = '8') IOD
                                                                   ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                                 WHERE
                                                       TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                                       {SqlFilterAgvTime}
                                                   AND (SUBSTR(REQID, 0, 1) = 'Z' OR SUBSTR(REQID, 0, 1) = 'k')
                                                   AND PROGRESSSTATUS = 230
                                                 GROUP BY
                                                     FROMLOCATION,
                                                     IOD.OPRSEQUENCENO)
                                                UNION ALL
                                                (SELECT
                                                     COUNT(IOH.TOLOCATION) AS AGVDISTATOL,
                                                     IOH.TOLOCATION        AS LOCATION,
                                                     IOD.OPRSEQUENCENO
                                                 FROM
                                                     ILT_ORDER_HEADER                    IOH
                                                         LEFT JOIN WAREHOUSE_LOCATION    WL
                                                                   ON IOH.TOLOCATION = WL.LOCATION
                                                         JOIN      ORDER_HEADER          OH
                                                                   ON (IOH.ORDERNO = OH.ORDERNO)
                                                         LEFT JOIN (SELECT DISTINCT
                                                                        ORDERNO,
                                                                        ORDERTYPE,
                                                                        TT.MEDIUM AS OPRSEQUENCENO
                                                                    FROM
                                                                        ILT_ORDER_DETAIL               IOD
                                                                            LEFT JOIN WIP_OPERATION    WO
                                                                                      ON WO.OPRSEQUENCENO = IOD.OPRSEQUENCENO
                                                                                          AND
                                                                                         WO.WIPORDERNO = IOD.WIPORDERNO
                                                                                          AND
                                                                                         WO.WIPORDERTYPE = IOD.WIPORDERTYPE
                                                                            LEFT JOIN TEXT_TRANSLATION TT
                                                                                      ON TT.TEXTID = WO.TEXTID
                                                                                          AND TT.LANGUAGEID = @LanguageID
                                                                    WHERE
                                                                        ORDERTYPE = '8') IOD
                                                                   ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                                 WHERE
                                                       TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                                       {SqlFilterAgvTime}
                                                   AND (SUBSTR(REQID, 0, 1) = 'Z' OR SUBSTR(REQID, 0, 1) = 'k')
                                                   AND PROGRESSSTATUS = 230
                                                 GROUP BY
                                                     TOLOCATION,
                                                     IOD.OPRSEQUENCENO)) WLLP
                                           GROUP BY
                                               LOCATION,
                                               OPRSEQUENCENO)              WLLP
                                              --取工作中心
                                              LEFT JOIN WAREHOUSE_LOCATION WL
                                                        ON WL.LOCATION = WLLP.LOCATION
                                      GROUP BY
                                          WL.WORKCENTER,
                                          WLLP.OPRSEQUENCENO) WOA2
                                     ON WOA.WORKCENTER = WOA2.WORKCENTER AND WOA.OPRSEQUENCENO = WOA2.OPRSEQUENCENO
                   WHERE
                       WOA.WORKCENTER IS NOT NULL) WLLP
                  ON WLWC.WORKCENTER = WLLP.WORKCENTER
        LEFT JOIN TEXT_TRANSLATION                 TT1
                  ON TT1.TEXTID = WLP.TEXTID
WHERE
      WLLP.WORKCENTER IS NOT NULL
  AND TT1.MEDIUM IS NOT NULL
GROUP BY
    TT1.MEDIUM;

SELECT
    CASE
        WHEN INSTR(LINENAME, ',') > 0
            THEN '小件线'
            ELSE LINENAME
        END                                                                                                 AS OLIMENAME,
    TO_CHAR(DECODE(SUM(AGVDISTATOL), 0, 0, SUM(AGVDISAUTOTOTAL) / SUM(AGVDISTATOL) * 100), '990.99') || '%' AS DISRATE
FROM
    (SELECT
         -- 产线名称
         LISTAGG(TT1.MEDIUM, ',')           AS LINENAME,
         -- 产线编码
         LISTAGG(WLP.PRODUCTIONLINENO, ',') AS LINENO,
         -- 工作中心名称
         TT.MEDIUM                          AS WORKCENTERNAME,
         WLLP.WORKCENTER,
         SUM(NVL(WLLP.AGVDISAUTOTOTAL, 0))  AS AGVDISAUTOTOTAL,
         SUM(NVL(WLLP.AGVDISTATOL, 0))      AS AGVDISTATOL
     FROM
         (SELECT
              WOA.WORKCENTER,
              NVL(WOA2.AGVDISTATOL, 0) AS AGVDISAUTOTOTAL,
              NVL(WOA.AGVDISTATOL, 0)  AS AGVDISTATOL
          FROM
              (SELECT
                   WL.WORKCENTER,
                   SUM(WLLP.AGVDISTATOL) AS AGVDISTATOL
               FROM
                   --取工作中心
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
                                      LOCATION,
                                      SUM(AGVDISTATOL) AS AGVDISTATOL
                                  FROM
                                      ((SELECT
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
                                                               ILT_ORDER_DETAIL IOD
                                                           WHERE
                                                               ORDERTYPE = '8') IOD
                                                          ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                        WHERE
                                              TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                              {SqlFilterAgvTime} --AND IOH.AGVENDTIME is not null
                                          AND PROGRESSSTATUS = 230
                                        GROUP BY
                                            FROMLOCATION)
                                       UNION ALL
                                       (SELECT
                                            COUNT(IOH.TOLOCATION) AS AGVDISTATOL,
                                            IOH.TOLOCATION        AS LOCATION
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
                                                               ILT_ORDER_DETAIL IOD
                                                           WHERE
                                                               ORDERTYPE = '8') IOD
                                                          ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                        WHERE
                                              TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                              {SqlFilterAgvTime} --AND IOH.AGVENDTIME is not null
                                          AND PROGRESSSTATUS = 230
                                        GROUP BY
                                            TOLOCATION)) WLLP
                                  GROUP BY
                                      LOCATION)      WLLP
                                 ON WL.LOCATION = WLLP.LOCATION
               GROUP BY
                   WL.WORKCENTER)               WOA
                  LEFT JOIN (SELECT
                                 WL.WORKCENTER,
                                 SUM(WLLP.AGVDISTATOL) AS AGVDISTATOL
                             FROM
                                 --取工作中心
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
                                                    LOCATION,
                                                    SUM(AGVDISTATOL) AS AGVDISTATOL
                                                FROM
                                                    ((SELECT
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
                                                                             ILT_ORDER_DETAIL IOD
                                                                         WHERE
                                                                             ORDERTYPE = '8') IOD
                                                                        ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                                      WHERE
                                                            TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                                            {SqlFilterAgvTime} --AND IOH.AGVENDTIME is not null
                                                        AND (SUBSTR(REQID, 0, 1) = 'Z' OR SUBSTR(REQID, 0, 1) = 'k')
                                                        AND PROGRESSSTATUS = 230
                                                      GROUP BY
                                                          FROMLOCATION)
                                                     UNION ALL
                                                     (SELECT
                                                          COUNT(IOH.TOLOCATION) AS AGVDISTATOL,
                                                          IOH.TOLOCATION        AS LOCATION
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
                                                                             ILT_ORDER_DETAIL IOD
                                                                         WHERE
                                                                             ORDERTYPE = '8') IOD
                                                                        ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOD.ORDERTYPE)
                                                      WHERE
                                                            TASKTYPE IN (4, 5, 6, 7, 46, 49)
                                                            {SqlFilterAgvTime} --AND IOH.AGVENDTIME is not null
                                                        AND (SUBSTR(REQID, 0, 1) = 'Z' OR SUBSTR(REQID, 0, 1) = 'k')
                                                        AND PROGRESSSTATUS = 230
                                                      GROUP BY
                                                          TOLOCATION)) WLLP
                                                GROUP BY
                                                    LOCATION)      WLLP
                                               ON WL.LOCATION = WLLP.LOCATION
                             GROUP BY
                                 WL.WORKCENTER) WOA2
                            ON WOA.WORKCENTER = WOA2.WORKCENTER
          WHERE
              WOA.WORKCENTER IS NOT NULL)   WLLP
             LEFT JOIN WIP_LINE_WORK_CENTER WLWC
                       ON WLWC.WORKCENTER = WLLP.WORKCENTER
             LEFT JOIN WIP_LINE             WLP
                       ON WLP.PRODUCTIONLINENO = WLWC.PRODUCTIONLINENO
             LEFT JOIN TEXT_TRANSLATION     TT1
                       ON TT1.TEXTID = WLP.TEXTID
                           AND TT1.LANGUAGEID = @LanguageID
             LEFT JOIN WORK_CENTER          WC
                       ON WLLP.WORKCENTER = WC.WORKCENTER
             LEFT JOIN TEXT_TRANSLATION     TT
                       ON WC.TEXTID = TT.TEXTID
                           AND TT.LANGUAGEID = @LanguageID
     WHERE
           WLLP.WORKCENTER IS NOT NULL
       AND TT1.MEDIUM IS NOT NULL
     GROUP BY
         WLLP.WORKCENTER,
         TT.MEDIUM
    )
GROUP BY
    LINENAME
