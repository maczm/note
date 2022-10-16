-- 返空清单
SELECT IOH.REQID,
       IOH.ORDERNO,
       IOH.ORDERTYPE,
       IOH.TASKTYPE,
       IOH.CONTAINER,--                                                                      料框,
       IOH.FROMLOCATION,--                                                                   起点,
       IOH.TOLOCATION,
       IOH.AGVNO,
       CASE
           WHEN AGVGETTIME IS NULL      THEN
               N'新增'
           WHEN AGVGETTIME IS NOT NULL
               AND AGVSTARTTIME IS NULL THEN
               N'已接收'
           WHEN AGVSTARTTIME IS NOT NULL
               AND AGVENDTIME IS NULL   THEN
               N'在途'
           --WHEN agvendtime IS NOT NULL THEN
           --    N'已送达'
           END                                            AS                 STATUS, --状态,
       ROUND(((NVL(AGVENDTIME, SYSDATE - 1 / 3)) - IOH.CREATEDON) * 24 * 60) USETIME, --耗时,
       TO_CHAR(IOH.CREATEDON, 'yyyy-mm-dd hh24:mi:ss')    AS                 CREATETIME, --创建时间,
       TO_CHAR(IOH.AGVGETTIME, 'yyyy-mm-dd hh24:mi:ss')   AS                 AGVRECEIVETIME, --agv分配,
       TO_CHAR(IOH.AGVSTARTTIME, 'yyyy-mm-dd hh24:mi:ss') AS                 AGVSTARTTIME, --agv开始,
       TO_CHAR(IOH.AGVENDTIME, 'yyyy-mm-dd hh24:mi:ss')   AS                 AGVENDTIME, --agv结束,
       E.NAME
FROM ILT_ORDER_HEADER       IOH
         LEFT JOIN EMPLOYEE E
         ON IOH.CREATEDBY = E.EMPLOYEENO
WHERE IOH.TASKTYPE = '6'
  AND IOH.ORDERTYPE = '8'
  --AND ioh.fromlocation = ''--@Location
  AND AGVENDTIME IS NULL
ORDER BY IOH.CREATEDON DESC;