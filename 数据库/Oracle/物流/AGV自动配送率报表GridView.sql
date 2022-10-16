SELECT
    LINENAME,
    LINENO,
    WORKCENTERNAME,
    WORKCENTER,
    AGVDISAUTOTOTAL,
    AGVDISTATOL,
    TO_CHAR(DECODE(AGVDISTATOL, 0, 0, AGVDISAUTOTOTAL / AGVDISTATOL * 100), '990.99') || '%' AS DISRATE
FROM
    (SELECT
         -- 产线名称
         LISTAGG(TT1.MEDIUM, ',')                                        AS LINENAME,
         -- 产线编码
         LISTAGG(WLP.PRODUCTIONLINENO, ',')                              AS LINENO,
         -- 工作中心名称
         TT.MEDIUM                                                       AS WORKCENTERNAME,
         WLLP.WORKCENTER,
         SUM(NVL(WLLP.AGVDISAUTOTOTAL, 0)) / COUNT(WLLP.AGVDISAUTOTOTAL) AS AGVDISAUTOTOTAL,
         SUM(NVL(WLLP.AGVDISTATOL, 0)) / COUNT(WLLP.AGVDISTATOL)         AS AGVDISTATOL
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
                                          AND TTL.LANGUAGEID = @LANGUAGEID
                            LEFT JOIN WAREHOUSE              WH
                                      ON WL.WAREHOUSE = WH.WAREHOUSE AND WH.FACILITY = @FACILITY
                            LEFT JOIN TEXT_TRANSLATION       WHTT
                                      ON WH.TEXTID = WHTT.TEXTID AND WHTT.LANGUAGEID = @LANGUAGEID
                    WHERE
                          WL.FACILITY = @FACILITY
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
                                              --                                           AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) <
                                              --                                               TO_DATE('2021-05-24 23:59:59', 'yyyy-MM-dd HH24:mi:ss')
                                              --                                           AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) >=
                                              --                                               TO_DATE('2021-05-18 00:00:00', 'yyyy-MM-dd HH24:mi:ss')
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
                                              --                                           AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) <
                                              --                                               TO_DATE('2021-05-24 23:59:59', 'yyyy-MM-dd HH24:mi:ss')
                                              --                                           AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) >=
                                              --                                               TO_DATE('2021-05-18 00:00:00', 'yyyy-MM-dd HH24:mi:ss')
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
                                                        AND TTL.LANGUAGEID = @LANGUAGEID
                                          LEFT JOIN WAREHOUSE              WH
                                                    ON WL.WAREHOUSE = WH.WAREHOUSE AND WH.FACILITY = @FACILITY
                                          LEFT JOIN TEXT_TRANSLATION       WHTT
                                                    ON WH.TEXTID = WHTT.TEXTID AND WHTT.LANGUAGEID = @LANGUAGEID
                                  WHERE
                                        WL.FACILITY = @FACILITY
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
                                                            --                                                         AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) <
                                                            --                                                             TO_DATE('2021-05-24 23:59:59', 'yyyy-MM-dd HH24:mi:ss')
                                                            --                                                         AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) >=
                                                            --                                                             TO_DATE('2021-05-18 00:00:00', 'yyyy-MM-dd HH24:mi:ss')
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
                                                            --                                                         AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) <
                                                            --                                                             TO_DATE('2021-05-24 23:59:59', 'yyyy-MM-dd HH24:mi:ss')
                                                            --                                                         AND (IOH.AGVENDTIME + INTERVAL '8' HOUR) >=
                                                            --                                                             TO_DATE('2021-05-18 00:00:00', 'yyyy-MM-dd HH24:mi:ss')
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
                       ON WLLP.WORKCENTER = WLWC.WORKCENTER
             LEFT JOIN WIP_LINE             WLP
                       ON WLP.PRODUCTIONLINENO = WLWC.PRODUCTIONLINENO
             LEFT JOIN TEXT_TRANSLATION     TT1
                       ON TT1.TEXTID = WLP.TEXTID
                           AND TT1.LANGUAGEID = @LANGUAGEID
             LEFT JOIN WORK_CENTER          WC
                       ON WLLP.WORKCENTER = WC.WORKCENTER
             LEFT JOIN TEXT_TRANSLATION     TT
                       ON WC.TEXTID = TT.TEXTID
                           AND TT.LANGUAGEID = @LANGUAGEID
     WHERE
         WLLP.WORKCENTER IS NOT NULL
        {SqlFilterProDuctLineName}
        {SqlFilterOperationName}
        {SqlFilterWorkCenter}
     GROUP BY
         WLLP.WORKCENTER,
         TT.MEDIUM
    )