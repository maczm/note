--查询订单信息 added by zhoufei
SELECT
    /*订单号*/
    WO.WIPORDERNO,
    /*订单类型-编码*/
    WO.WIPORDERTYPE,
    /*订单类型*/
    TT1.MEDIUM                                                                                              AS WIPORDERTYPESTR,
    /*订单状态*/
    TT3.MEDIUM                                                                                              AS PROGRESSSTATUS,
    /*物料简码*/
    IPF.PRODUCTALIAS,
    /*物料编码*/
    P.PRODUCTNO,
    /*物料描述*/
    TT2.MEDIUM                                                                                              AS PRODUCTDESC,
    /*批次号*/
    WOL.LOTNO,
    /*序列号/钢印号*/
    WOSN.SERIALNO,
    /*订单数量*/
    WO.ORDERQUANTITY,
    /*完工数量*/
    WO.COMPLETEDQUANTITY,
    NVL(WSN_WOP.TOTALPROCESSED, 0) || '/' || WO.ORDERQUANTITY                                               AS QTY,
    /*入库地点*/
    TWO1.PUTAWAYLOCATION,
    /*入库数量*/
    TWO1.STORAGEQTY,
    /*接收前工序*/
    (CASE
         WHEN WSN_WOP.RECEIVESTATUS = '0'
             THEN '未接收'
         WHEN WSN_WOP.RECEIVESTATUS = '1'
             THEN '成功'
         WHEN WSN_WOP.RECEIVESTATUS = '2'
             THEN '失败'
        END)                                                                                                AS RECEIVESTATUS,
    /*计划开工时间*/
    WO.SCHEDULEDSTARTDATE,
    /*实际开工实际*/
    WO.ACTUALSTARTDATE,
    /*计划完工时间*/
    WO.SCHEDULEDCOMPLETIONDATE,
    /*实际完工时间*/
    WO.ACTUALCOMPLETIONDATE,
    ILT.ECONO,
    /*工艺变更单*/
    LISTAGG(TO_CHAR(EO.ENGINEERINGCHANGEORDERNO), ',')
            WITHIN GROUP (ORDER BY EO.ENGINEERINGCHANGEORDERNO )                                            AS ENGINEERINGCHANGEORDERNO,

    /*在制工位-编码*/
    --    tmp.workStationDesc
    TMP.WORKSTATION_ING,
    /*在制工序*/
    LASTOPR.OPRSEQUENCENO || '-' || TT_LASTOPR.MEDIUM                                                       AS LASTOPR,
    /*订单创建时间*/
    WO.CREATEDON,
    --序列号数量
    WOSNC.SERIALCOUNT,
    /*Add by hanlin.Zhang 2021/1/22*/
    IWOPPP.FRISTSENDIOTSTATUS
    /*Add by hanlin.Zhang 2021/1/22*/
        ,
    TWO1.MRPCONTROL

FROM WIP_ORDER                                                               WO
         LEFT JOIN ILT_ECM_WIP_ORDER                                         ILT
         ON WO.WIPORDERNO = ILT.WIPORDERNO
         LEFT JOIN ECM_ORDER                                                 EO
         ON ILT.ECMORDERID = EO.ID
                       --INNER JOIN RESOURCE_GROUP RG ON RG.GROUP_ = wo.PRODUCTIONLINENO AND RG.RESOURCENAME = @EmployeeID
                       --INNER JOIN GROUP_CLASS GC ON RG.GROUPCLASSID = GC.ID AND GC.NAME = 'EmployeeProductionLine'
                       --LEFT JOIN PRODUCT p on WO.PRODUCTID = p.id
                       --取在制工位
         LEFT JOIN (
                       SELECT
                           --订单号
                           WOP_TMP.WIPORDERNO,
                           --订单类型
                           WOP_TMP.WIPORDERTYPE,
                           --工位编码
                           LISTAGG(WOP_TMP.WORKCENTER, ',') AS WORKSTATION_ING
                           --            /*工位描述*/
                           --            listagg(tt4_tmp.Medium,',') AS workStationDesc
                       FROM WIP_OPERATION             WOP_TMP
                                --取工位编码、工位描述
                                LEFT JOIN WORK_CENTER WC1_TMP
                                ON WOP_TMP.WORKCENTER = WC1_TMP.WORKCENTER
                                    --工位类型：WorkStation
                                    AND WC1_TMP.OBJECTCLASS = 'WorkStation'
                            --            LEFT JOIN TEXT_TRANSLATION tt4_tmp
                            --                ON tt4_tmp.textId = wc1_tmp.textId
                            --                AND tt4_tmp.languageid = 2052
                       WHERE
                           --在制状态
                           WOP_TMP.PROGRESSSTATUS = '130'
                       GROUP BY WOP_TMP.WIPORDERNO,
                                WOP_TMP.WIPORDERTYPE
                   )                                                         TMP
         ON TMP.WIPORDERNO = WO.WIPORDERNO
             AND TMP.WIPORDERTYPE = WO.WIPORDERTYPE
         LEFT JOIN ILT_WIP_ORDER                                             TWO1
         ON TWO1.WIPORDERNO = WO.WIPORDERNO
             AND TWO1.WIPORDERTYPE = WO.WIPORDERTYPE
                       --and two1.textid = '2052'
         LEFT JOIN PROGRESS_STATUS                                           PS
         ON PS.PROGRESSSTATUS = WO.PROGRESSSTATUS
         LEFT JOIN TEXT_TRANSLATION                                          TT3
         ON PS.TEXTID = TT3.TEXTID
             AND TT3.LANGUAGEID = '2052'
         LEFT JOIN WIP_ORDER_LOT                                             WOL
         ON WO.WIPORDERNO = WOL.WIPORDERNO
             AND WO.WIPORDERTYPE = WOL.WIPORDERTYPE
                       --LEFT JOIN WIP_ORDER_SERIAL_NO wosn
         LEFT JOIN PRODUCT                                                   P
         ON WO.PRODUCTID = P.ID
         LEFT JOIN TEXT_TRANSLATION                                          TT2
         ON P.TEXTID = TT2.TEXTID
             AND TT2.LANGUAGEID = '2052'
         LEFT JOIN ILT_PRODUCT_FACILITY                                      IPF
         ON P.PRODUCTNO = IPF.PRODUCTNO
             AND IPF.FACILITY = '1820'

                       --取最后一个完工工序
         LEFT JOIN (
                       SELECT WIPORDERNO,
                              WIPORDERTYPE,
                              MAX(OPRSEQUENCENO) AS OPRSEQUENCENO
                       FROM WIP_OPERATION
                       WHERE PROGRESSSTATUS = '140'
                         AND OPRSEQUENCENO LIKE '000000%'
                       GROUP BY WIPORDERNO,
                                WIPORDERTYPE
                   )                                                         LASTOPR
         ON LASTOPR.WIPORDERNO = WO.WIPORDERNO
             AND LASTOPR.WIPORDERTYPE = WO.WIPORDERTYPE

                       --取首工序下发
         LEFT JOIN (
                       SELECT CASE
                                  WHEN IWOP.SENDIOTSTATUS = 0 THEN '失败'
                                  WHEN IWOP.SENDIOTSTATUS = 1 THEN '已下发'
                                                              ELSE '未下发' END AS FRISTSENDIOTSTATUS,
                              IWOP.WIPORDERNO,
                              IWOP.WIPORDERTYPE,
                              IWOP.OPRSEQUENCENO
                       FROM ILT_WIP_OPERATION       IWOP
                                JOIN
                            (SELECT WIPORDERNO,
                                    WIPORDERTYPE,
                                    MIN(OPRSEQUENCENO) AS OPRSEQUENCENO
                             FROM ILT_WIP_OPERATION
                             WHERE OPRSEQUENCENO LIKE '000000%'
                             GROUP BY WIPORDERNO,
                                      WIPORDERTYPE) IWOPP
                                ON IWOP.WIPORDERNO = IWOPP.WIPORDERNO AND IWOP.WIPORDERTYPE = IWOPP.WIPORDERTYPE AND
                                   IWOP.OPRSEQUENCENO = IWOPP.OPRSEQUENCENO) IWOPPP
         ON IWOPPP.WIPORDERNO = WO.WIPORDERNO AND IWOPPP.WIPORDERTYPE = WO.WIPORDERTYPE

         LEFT JOIN WIP_OPERATION                                             WOP_LAST
         ON LASTOPR.WIPORDERNO = WOP_LAST.WIPORDERNO
             AND LASTOPR.WIPORDERTYPE = WOP_LAST.WIPORDERTYPE
             AND LASTOPR.OPRSEQUENCENO = WOP_LAST.OPRSEQUENCENO
         LEFT JOIN TEXT_TRANSLATION                                          TT_LASTOPR
         ON WOP_LAST.TEXTID = TT_LASTOPR.TEXTID
             AND TT_LASTOPR.LANGUAGEID = '2052'

         LEFT JOIN(SELECT WIPORDERNO,
                          WIPORDERTYPE,
                          (CASE
                               WHEN COUNT(SERIALNO) = 1
                                   THEN MIN(SERIALNO)
                                   ELSE MIN(SERIALNO) || '...'
                              END) AS SERIALNO
                          --substr(listagg(serialno,','),1,2000) AS serialno
                   FROM WIP_ORDER_SERIAL_NO
                   GROUP BY WIPORDERNO,
                            WIPORDERTYPE)                                    WOSN
         ON WO.WIPORDERNO = WOSN.WIPORDERNO
             AND WO.WIPORDERTYPE = WOSN.WIPORDERTYPE

                       --取得序列号数量
         LEFT JOIN(SELECT COUNT(SERIALNO) AS SERIALCOUNT,
                          WIPORDERNO,
                          WIPORDERTYPE
                   FROM WIP_ORDER_SERIAL_NO
                   GROUP BY WIPORDERNO,
                            WIPORDERTYPE)                                    WOSNC
         ON WO.WIPORDERNO = WOSNC.WIPORDERNO
             AND WO.WIPORDERTYPE = WOSNC.WIPORDERTYPE

                       --取最后一道工序的数量
         LEFT JOIN
                   (
                       SELECT WOP.WIPORDERNO,
                              WOP.WIPORDERTYPE,
                              WOP.OPRSEQUENCENO,
                              WCO_QTY.TOTALPROCESSED,
                              WOS.RECEIVESTATUS,
                              WOS.SENDIOTSTATUS
                       FROM WIP_OPERATION             WOP
                                --取得最后一道工序 Start
                                JOIN      (
                                              SELECT T1.WIPORDERNO,
                                                     T1.WIPORDERTYPE,
                                                     T1.OPRSEQUENCENO,
                                                     T1.RECEIVESTATUS,
                                                     T1.SENDIOTSTATUS
                                              FROM (
                                                       SELECT WO.WIPORDERNO,
                                                              WO.WIPORDERTYPE,
                                                              WO.OPRSEQUENCENO,
                                                              NVL(WS.SEQUENCETYPE, '1')                      SEQUENCETYPE,
                                                              IWO.RECEIVESTATUS,
                                                              CASE
                                                                  WHEN IWO.SENDIOTSTATUS = '' THEN '未下发'
                                                                  WHEN IWO.SENDIOTSTATUS = 0  THEN '失败'
                                                                  WHEN IWO.SENDIOTSTATUS = 1  THEN '已下发'
                                                                                              ELSE '' END AS SENDIOTSTATUS
                                                       FROM WIP_OPERATION                        WO
                                                                JOIN      ILT_WIP_OPERATION      IWO
                                                                ON WO.WIPORDERNO = IWO.WIPORDERNO
                                                                    AND WO.WIPORDERTYPE = IWO.WIPORDERTYPE
                                                                    AND WO.OPRSEQUENCENO = IWO.OPRSEQUENCENO
                                                                              --AND IWO.CONTROLCODE NOT IN ( 'SY03', 'SY12' )
                                                                              -- 				{result}
                                                                LEFT JOIN WIP_OPERATION_SEQUENCE WS
                                                                ON WO.WIPORDERNO = WS.WIPORDERNO
                                                                    AND WO.WIPORDERTYPE = WS.WIPORDERTYPE
                                                                    AND WO.OPRSEQUENCENO = WS.OPRSEQUENCENO
                                                                    AND WS.SEQUENCETYPE = 'NEXT'
                                                       WHERE SUBSTR(WO.OPRSEQUENCENO, 0, 6) = '000000'
                                                   ) T1
                                              WHERE T1.SEQUENCETYPE = '1'
                                          )           WOS
                                              --取得最后一道工序 End
                                ON WOS.WIPORDERNO = WOP.WIPORDERNO
                                    AND WOS.WIPORDERTYPE = WOP.WIPORDERTYPE
                                    AND WOS.OPRSEQUENCENO = WOP.OPRSEQUENCENO

                                LEFT JOIN WIP_CONTENT WCO_QTY
                                ON WOP.WIPORDERNO = WCO_QTY.WIPORDERNO
                                    AND WOP.WIPORDERTYPE = WCO_QTY.WIPORDERTYPE
                                    AND WOP.OPRSEQUENCENO = WCO_QTY.OPRSEQUENCENO
                                    AND WCO_QTY.WIPCONTENTCLASS = 1
                   )                                                         WSN_WOP
         ON WO.WIPORDERNO = WSN_WOP.WIPORDERNO
             AND WO.WIPORDERTYPE = WSN_WOP.WIPORDERTYPE
        ,
     WIP_ORDER_TYPE                                                          WOT
         LEFT JOIN TEXT_TRANSLATION                                          TT1
         ON WOT.TEXTID = TT1.TEXTID
             AND TT1.LANGUAGEID = '2052'
     --PRODUCT p

WHERE WO.WIPORDERTYPE = WOT.WIPORDERTYPE
  AND WO.RELEASEDFACILITY = '1820'
  -- AND TRUNC(wo.scheduledStartDate) = TRUNC(@CurrentUtcDatetime)
    /***2020-10-21 Add By chenkui 增加筛选条件 Start ****/
  -- 	{sqlWhere}
    /***2020-10-21 Add By chenkui 增加筛选条件 End ****/
-- AND TT2.MEDIUM LIKE N'销轴%'
GROUP BY WO.WIPORDERNO,
    /*订单类型-编码*/
         WO.WIPORDERTYPE,
    /*订单类型*/
         TT1.MEDIUM,
    /*订单状态*/
         TT3.MEDIUM,
    /*物料简码*/
         IPF.PRODUCTALIAS,
    /*物料编码*/
         P.PRODUCTNO,
    /*物料描述*/
         TT2.MEDIUM,
    /*批次号*/
         WOL.LOTNO,
    /*序列号/钢印号*/
         WOSN.SERIALNO,
    /*订单数量*/
         WO.ORDERQUANTITY,
    /*完工数量*/
         WO.COMPLETEDQUANTITY,
         WSN_WOP.TOTALPROCESSED,
    /*入库地点*/
         TWO1.PUTAWAYLOCATION,
    /*入库数量*/
         TWO1.STORAGEQTY,
    /*接收前工序*/
         WSN_WOP.RECEIVESTATUS,
    /*计划开工时间*/
         WO.SCHEDULEDSTARTDATE,
    /*实际开工实际*/
         WO.ACTUALSTARTDATE,
    /*计划完工时间*/
         WO.SCHEDULEDCOMPLETIONDATE,
    /*实际完工时间*/
         WO.ACTUALCOMPLETIONDATE,
         ILT.ECONO,
    /*在制工位-编码*/
         --    tmp.workStationDesc
         TMP.WORKSTATION_ING,
    /**/
         LASTOPR.OPRSEQUENCENO || '-' || TT_LASTOPR.MEDIUM,
    /*订单创建时间*/
         WO.CREATEDON,
         --序列号数量
         WOSNC.SERIALCOUNT,
         --WSN_WOP.SENDIOTSTATUS
         IWOPPP.FRISTSENDIOTSTATUS
        ,
         TWO1.MRPCONTROL
ORDER BY WO.SCHEDULEDCOMPLETIONDATE ASC