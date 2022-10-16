SELECT
    OH.ORDERNO,                      --配送单号,
    IOH.REQID,--请求ID
    OH.CREATEDON,                    --创建时间
    --        -- 日期
    --        SUBSTR(TO_CHAR(OH.CREATEDON, 'YYYY-MM-DD HH24:MI:SS'), 0, 10) AS DD,
    --        -- 时间
    --        SUBSTR(TO_CHAR(OH.CREATEDON, 'YYYY-MM-DD HH24:MI:SS'), 11, 9) AS DT,
    --        --IOH.TASKTYPE,--单据类型（配送类型）
    CASE
        WHEN IOH.TASKTYPE = 4 AND NVL(IOH.REQSYS, 'XX') <> 'MOM'
            THEN
            '生产叫料'
        WHEN IOH.TASKTYPE = 5
            THEN
            '生产入库'
        WHEN IOH.TASKTYPE = 6 AND IOH.REQTYPE = 0
            THEN
            '空料框需求'
        WHEN IOH.TASKTYPE = 6 AND IOH.REQTYPE = 1 AND
             NVL(IOH.REQSYS, 'XX') <> 'MOM'
            THEN
            '空料框回库'
        WHEN (IOH.TASKTYPE = 7 OR IOH.TASKTYPE = 46) AND IOH.REQTYPE = 0 AND
             NVL(IOH.REQSYS, 'XX') <> 'MOM'
            THEN
            '工序间空料框需求'
        WHEN (IOH.TASKTYPE = 7 OR IOH.TASKTYPE = 46) AND IOH.REQTYPE = 1 AND
             NVL(IOH.REQSYS, 'XX') <> 'MOM'
            THEN
            '满料框搬运'
        WHEN (IOH.TASKTYPE = 7 OR IOH.TASKTYPE = 46) AND IOH.REQTYPE = 3 AND NVL(IOH.REQSYS, 'XX') <> 'MOM'
            THEN
            '空料框回缓存区'
        WHEN (IOH.TASKTYPE = 7 OR IOH.TASKTYPE = 46) AND IOH.REQTYPE = 0 AND IOH.REQSYS = 'MOM'
            THEN
            '人工分选空料框需求'
        WHEN IOH.TASKTYPE = 6 AND IOH.REQTYPE = 1 AND IOH.REQSYS = 'MOM'
            THEN
            '手工空料框回库'
        WHEN (IOH.TASKTYPE = 7 OR IOH.TASKTYPE = 46) AND IOH.REQTYPE = 1 AND IOH.REQSYS = 'MOM'
            THEN
            '手工满料框搬运'
        WHEN (IOH.TASKTYPE = 7 OR IOH.TASKTYPE = 46) AND IOH.REQTYPE = 3 AND IOH.REQSYS = 'MOM'
            THEN
            '手工空料框搬运'
        -- 焊接涂装满料框。ADD 2021-01-12
        WHEN IOH.TASKTYPE = 49 AND IOH.REQTYPE = 9 AND NVL(IOH.REQSYS, 'XX') <> 'MOM'
            THEN
            '焊涂手工满料框搬运'
        WHEN IOH.TASKTYPE = 4 AND IOH.REQSYS = 'MOM'
            THEN
            '手工生产叫料'
        ELSE
            '--'
        END          AS TASKTYPE,
    IOH.FROMLOCATION AS F,           --起点
    IOH.TOLOCATION   AS T,           --终点
    FWL_TT.MEDIUM    AS FROMLOCATION,
    TWL_TT.MEDIUM    AS TOLOCATION,
    IOH.AGVSTARTTIME AS REQUIRETIME, --需求时间
    IOH.AGVENDTIME   AS SENDTIME,    --发送时间
    IOH.CONTAINER,                   --料框
    CASE
        WHEN PROGRESSSTATUS = 200
            THEN
            '创建'
        WHEN PROGRESSSTATUS = 210
            THEN
            'AGV任务已接收'
        WHEN PROGRESSSTATUS = 220
            THEN
            '到达起点'
        WHEN PROGRESSSTATUS = 230
            THEN
            '配送完成'
        WHEN PROGRESSSTATUS = 231
            THEN
            'WMS任务下发失败'
        END          AS STATUS,
    --OH.CREATEDBY,
    E.NAME           AS CREATEDBY,
    IOD.WIPORDERNOS

FROM
    ILT_ORDER_HEADER                 IOH
        JOIN      ORDER_HEADER       OH
                  ON (IOH.ORDERNO = OH.ORDERNO)
        LEFT JOIN (SELECT
                       ORDERNO,
                       ORDERTYPE,
                       LISTAGG(WIPORDERNO, ',') AS WIPORDERNOS
                   FROM
                       (SELECT DISTINCT
                            ORDERNO,
                            ORDERTYPE,
                            WIPORDERNO
                        FROM
                            ILT_ORDER_DETAIL
                        WHERE
                            ORDERTYPE = '8')
                   GROUP BY
                       ORDERNO,
                       ORDERTYPE)    IOD
                  ON (OH.ORDERNO = IOD.ORDERNO AND OH.ORDERTYPE = IOH.ORDERTYPE)
        LEFT JOIN WAREHOUSE_LOCATION FWL
                  ON FWL.LOCATION = IOH.FROMLOCATION
        LEFT JOIN WAREHOUSE_LOCATION TWL
                  ON TWL.LOCATION = IOH.TOLOCATION
        LEFT JOIN TEXT_TRANSLATION   FWL_TT
                  ON FWL.TEXTID = FWL_TT.TEXTID AND FWL_TT.LANGUAGEID = '2052'
        LEFT JOIN TEXT_TRANSLATION   TWL_TT
                  ON TWL.TEXTID = TWL_TT.TEXTID AND TWL_TT.LANGUAGEID = '2052'
        LEFT JOIN EMPLOYEE           E
                  ON E.EMPLOYEENO = OH.CREATEDBY
WHERE
      TASKTYPE IN (4, 5, 6, 7, 46, 49)
  AND PROGRESSSTATUS = 230


