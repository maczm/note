SELECT
    --退库单号
    OH.ORDERNO,
    --退库单类型
    OH.ORDERTYPE,
    --退库单类型描述
    TT1.MEDIUM AS ORDERTYPEDESC,
    --订单号
    OH.WIPORDERNO,
    --订单类型
    OH.WIPORDERTYPE,
    --预留号
    --IOH.RESERVEDPORTNO,
    --工厂
    IOH.FACILITY,
    --工厂描述
    TT2.MEDIUM AS FACILITYDESC,
    --状态编码
    OH.PROGRESSSTATUS,
    --状态描述
    TT.MEDIUM  AS PROGRESSSTATUSDESC,
    --创建人
    EMP.NAME,
    --创建时间
    OH.CREATEDON,
    CASE
        -- 新建 、提交、质检
        WHEN PS.PROGRESSSTATUS IN (100002010, 100002015, 100002020)
            THEN 0
            ELSE 1
        END    AS READONLYBUTTON,
    IODD.ORDERNOS,
    IOH.FAULT_CLASS,
    CASE
        WHEN IOH.FAULT_CLASS = '1'
            THEN '生产订单退料'
        WHEN IOH.FAULT_CLASS = '2'
            THEN '成本中心退料'
        WHEN IOH.FAULT_CLASS = '3'
            THEN '线边库存退料'
        --WHEN IOH.FAULT_CLASS = '4' THEN '副产品入库'
            ELSE '--'
        END    AS CLASSNAME
FROM
    ORDER_HEADER                      OH
        JOIN      ILT_ORDER_HEADER    IOH
                  ON OH.ORDERNO = IOH.ORDERNO
                      --取雇员名称
        LEFT JOIN EMPLOYEE            EMP
                  ON EMP.EMPLOYEENO = OH.CREATEDBY
                      --取退库单状态描述
        LEFT JOIN PROGRESS_STATUS     PS
                  ON OH.PROGRESSSTATUS = PS.PROGRESSSTATUS
        LEFT JOIN TEXT_TRANSLATION    TT
                  ON TT.TEXTID = PS.TEXTID
                      AND TT.LANGUAGEID = '2052'--@LANGUAGEID
                      --取退库单类型描述
        LEFT JOIN WIP_ORDER_TYPE      WOT
                  ON WOT.WIPORDERTYPE = OH.ORDERTYPE
        LEFT JOIN TEXT_TRANSLATION    TT1
                  ON TT1.TEXTID = WOT.TEXTID
                      AND TT1.LANGUAGEID = '2052'--@LANGUAGEID
                      --取工厂描述字段
        LEFT JOIN FACILITY            FAC
                  ON FAC.FACILITY = IOH.FACILITY
        LEFT JOIN TEXT_TRANSLATION    TT2
                  ON TT2.TEXTID = FAC.TEXTID
                      AND TT2.LANGUAGEID = '2052'--@LANGUAGEID
        LEFT JOIN (SELECT
                       LISTAGG(IOD.WIPORDERNO, ',') ORDERNOS,
                       IOD.ORDERNO,
                       IOD.ORDERTYPE
                   FROM
                       (SELECT DISTINCT ORDERNO, ORDERTYPE, WIPORDERNO
                        FROM
                            ILT_ORDER_DETAIL) IOD
                   GROUP BY
                       IOD.ORDERNO,
                       IOD.ORDERTYPE) IODD
                  ON OH.ORDERNO = IODD.ORDERNO
                      AND OH.ORDERTYPE = IODD.ORDERTYPE
WHERE
      OH.ACTIVE = 1
  AND PS.PROGRESSSTATUS IN (100002010, 100002015, 100002020, 100002030, 100002040)
      --30 不合格退库  32 合格退库
  AND OH.ORDERTYPE IN (30, 32)
  AND IOH.FAULT_CLASS != '4'

UNION ALL

SELECT
    --退库单号
    OH.ORDERNO,
    --退库单类型
    OH.ORDERTYPE,
    --退库单类型描述
    TT1.MEDIUM AS ORDERTYPEDESC,
    --订单号
    OH.WIPORDERNO,
    --订单类型
    OH.WIPORDERTYPE,
    --预留号
    --IOH.RESERVEDPORTNO,
    --工厂
    IOH.FACILITY,
    --工厂描述
    TT2.MEDIUM AS FACILITYDESC,
    --状态编码
    OH.PROGRESSSTATUS,
    --状态描述
    TT.MEDIUM  AS PROGRESSSTATUSDESC,
    --创建人
    EMP.NAME,
    --创建时间
    OH.CREATEDON,
    CASE
        -- 新建 、提交、质检
        WHEN PS.PROGRESSSTATUS IN (100002010, 100002015, 100002020)
            THEN 0
            ELSE 1
        END    AS READONLYBUTTON,
    IODD.ORDERNOS,
    IOH.FAULT_CLASS,
    CASE
--         WHEN IOH.FAULT_CLASS = '1'
--             THEN '生产订单退料'
--         WHEN IOH.FAULT_CLASS = '2'
--             THEN '成本中心退料'
--         WHEN IOH.FAULT_CLASS = '3'
--             THEN '线边库存退料'
        WHEN IOH.FAULT_CLASS = '4' THEN '副产品入库'
            ELSE '--'
        END    AS CLASSNAME
FROM
    ORDER_HEADER                      OH
        JOIN      ILT_ORDER_HEADER    IOH
                  ON OH.ORDERNO = IOH.ORDERNO
                      --取雇员名称
        LEFT JOIN EMPLOYEE            EMP
                  ON EMP.EMPLOYEENO = OH.CREATEDBY
                      --取退库单状态描述
        LEFT JOIN PROGRESS_STATUS     PS
                  ON OH.PROGRESSSTATUS = PS.PROGRESSSTATUS
        LEFT JOIN TEXT_TRANSLATION    TT
                  ON TT.TEXTID = PS.TEXTID
                      AND TT.LANGUAGEID = '2052'--@LANGUAGEID
                      --取退库单类型描述
        LEFT JOIN WIP_ORDER_TYPE      WOT
                  ON WOT.WIPORDERTYPE = OH.ORDERTYPE
        LEFT JOIN TEXT_TRANSLATION    TT1
                  ON TT1.TEXTID = WOT.TEXTID
                      AND TT1.LANGUAGEID = '2052'--@LANGUAGEID
                      --取工厂描述字段
        LEFT JOIN FACILITY            FAC
                  ON FAC.FACILITY = IOH.FACILITY
        LEFT JOIN TEXT_TRANSLATION    TT2
                  ON TT2.TEXTID = FAC.TEXTID
                      AND TT2.LANGUAGEID = '2052'--@LANGUAGEID
        LEFT JOIN (SELECT
                       LISTAGG(IOD.WIPORDERNO, ',') ORDERNOS,
                       IOD.ORDERNO,
                       IOD.ORDERTYPE
                   FROM
                       (SELECT DISTINCT ORDERNO, ORDERTYPE, WIPORDERNO
                        FROM
                            ILT_ORDER_DETAIL) IOD
                   GROUP BY
                       IOD.ORDERNO,
                       IOD.ORDERTYPE) IODD
                  ON OH.ORDERNO = IODD.ORDERNO
                      AND OH.ORDERTYPE = IODD.ORDERTYPE
WHERE
      OH.ACTIVE = 1
  AND PS.PROGRESSSTATUS IN (100002020, 100002030, 100002040)
      --30 不合格退库  32 合格退库
  AND OH.ORDERTYPE IN (30, 32)
  AND IOH.FAULT_CLASS = '4'