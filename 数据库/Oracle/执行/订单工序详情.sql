-- 查询订单工序信息 added by zhoufei
SELECT
    /*订单号*/
    WOP.WIPORDERNO,
    /*订单类型*/
    WOP.WIPORDERTYPE,
    /*工序状态-编码*/
    WOP.PROGRESSSTATUS,
    /*工序状态*/
    TT2.MEDIUM                                     AS OPERATIONSTATUSDESC,
    /*工序号*/
    WOP.OPRSEQUENCENO,
    /*工序控制码*/
    IWO.CONTROLCODE,
    /*工序描述*/
    TT3.MEDIUM                                     AS OPERATIONNAME,
    /*工作中心-编码*/
    IWO.SAPWORKCENTER                              AS WORKCENTER,
    /*工作中心描述*/
    TT1.MEDIUM                                     AS WORKCENTERDESC,
    /*工位*/
    --wop.workCenter as workStation,
    NULLIF(WOP.WORKCENTER, IWO.SAPWORKCENTER)      AS WORKSTATION,
    /*工位描述*/
    TT4.MEDIUM                                     AS WORKSTATIONDESC,
    /*数量*/
    --NVL(wco.totalprocessed, 0) ||'/'||wco.totalreceived as amount,

    /*计划加工数量*/
    WO.ORDERQUANTITY                               AS PLANQTY,
    /*待加工数量*/
    WCO.QUANTITYALLOCATED                          AS STAYQTY,
    /*良品数*/
    WCO.TOTALPROCESSED                             AS GOODQTY,
    /*不良品数*/
    WCO2.TOTALPROCESSED                            AS BADQTY,


    /*计划开工时间*/
    WOP.SCHEDULEDSTARTDATE,
    /*实际开工时间*/
    WOP.ACTUALSTARTDATE,
    /*计划完工时间*/
    WOP.SCHEDULEDCOMPLETIONDATE,
    /*实际完工时间*/
    WOP.ACTUALCOMPLETIONDATE,
    /*报工人*/
    EM.NAME                                           LASTUPDATEDBY,


    --Add By Hanlin.Zhang 2020-12-24
    --接受状态
    CASE
        WHEN IWO.RECEIVESTATUS = 0 THEN '未接受'
        WHEN IWO.RECEIVESTATUS = 1 THEN '已接受'
        WHEN IWO.RECEIVESTATUS = 2 THEN '接受失败'
                                   ELSE '' END     AS RECEIVESTATUS,
    --接收人
    EM1.NAME                                          RECEPTBY,
    --接收时间
    IWO.RECEPTON,
    --报工状态
    CASE
        WHEN IWO.REPROTSAPSTATUS = 160 THEN '已报工'
        WHEN IWO.REPROTSAPSTATUS = 165 THEN '报工失败'
                                       ELSE '' END AS REPROTSAPSTATUS,
    --设备编号、
    A.EQUIP,
    CASE
        WHEN IWO.SENDIOTSTATUS = '' THEN '未下发'
        WHEN IWO.SENDIOTSTATUS = 0  THEN '失败'
        WHEN IWO.SENDIOTSTATUS = 1  THEN '成功'
                                    ELSE '' END    AS SENDIOTSTATUS

FROM WIP_OPERATION                   WOP
         --取工位编码、工位描述
         LEFT JOIN WORK_CENTER       WC1
         ON WOP.WORKCENTER = WC1.WORKCENTER
             --工位类型：WorkStation
             AND WC1.OBJECTCLASS = 'WorkStation'
         LEFT JOIN TEXT_TRANSLATION  TT4
         ON TT4.TEXTID = WC1.TEXTID
             AND TT4.LANGUAGEID = '2052'
                       --取工序描述
         LEFT JOIN TEXT_TRANSLATION  TT3
         ON TT3.TEXTID = WOP.TEXTID
             AND TT3.LANGUAGEID = '2052'
                       --取工序状态编码
         LEFT JOIN PROGRESS_STATUS   PS
         ON WOP.PROGRESSSTATUS = PS.PROGRESSSTATUS
                       --取工序状态描述
         LEFT JOIN TEXT_TRANSLATION  TT2
         ON TT2.TEXTID = PS.TEXTID
             AND TT2.LANGUAGEID = '2052'
                       --取工作中心编码
         LEFT JOIN ILT_WIP_OPERATION IWO
         ON WOP.WIPORDERNO = IWO.WIPORDERNO
             AND WOP.WIPORDERTYPE = IWO.WIPORDERTYPE
             AND WOP.OPRSEQUENCENO = IWO.OPRSEQUENCENO
                       --取工作中心描述
         LEFT JOIN WORK_CENTER       WC2
         ON IWO.SAPWORKCENTER = WC2.WORKCENTER
                       --工作中心类型：WorkCenter
                       --AND wc2.OBJECTCLASS = 'WorkCenter'
         LEFT JOIN TEXT_TRANSLATION  TT1
         ON TT1.TEXTID = WC2.TEXTID
             AND TT1.LANGUAGEID = '2052'
                       --取工序数量
         JOIN      WIP_CONTENT       WCO
         ON WOP.WIPORDERNO = WCO.WIPORDERNO
             AND WOP.WIPORDERTYPE = WCO.WIPORDERTYPE
             AND WOP.OPRSEQUENCENO = WCO.OPRSEQUENCENO
             -- 工序数量对应有三种类型：1合格 2报废 3不合格
             -- 这里只取合格
             AND WCO.WIPCONTENTCLASS = 1
                       --取不良数量
         LEFT JOIN WIP_CONTENT       WCO2
         ON WOP.WIPORDERNO = WCO2.WIPORDERNO
             AND WOP.WIPORDERTYPE = WCO2.WIPORDERTYPE
             AND WOP.OPRSEQUENCENO = WCO2.OPRSEQUENCENO
             -- 工序数量对应有三种类型：1合格 2报废 3不合格
             -- 这里只取合格
             AND WCO2.WIPCONTENTCLASS = 3
         LEFT JOIN EMPLOYEE          EM
         ON EM.EMPLOYEENO = WCO.LASTUPDATEDBY
         LEFT JOIN EMPLOYEE          EM1
         ON EM1.EMPLOYEENO = IWO.RECEPTBY

                       --取设备编号
         LEFT JOIN(
                       SELECT DISTINCT RESL.WIPORDERNO    AS WODER,
                                       RESL.OPRSEQUENCENO AS OPRNO,
                                       RESL.RESOURCENAME  AS RSNAME,
                                       EQM.EQUIPMENT      AS EQUIP
                       FROM EQUIPMENT                    EQM
                                LEFT JOIN RESOURCE_      RSE
                                ON EQM.RESOURCEID = RSE.ID
                                LEFT JOIN RESOURCE_LABOR RESL
                                ON RESL.RESOURCENAME = RSE.RESOURCENAME
                       ORDER BY RESL.WIPORDERNO
                   )                 A
         ON A.WODER = WOP.WIPORDERNO AND A.OPRNO = WOP.OPRSEQUENCENO
         LEFT JOIN WIP_ORDER         WO
         ON WO.WIPORDERNO = WOP.WIPORDERNO
WHERE --wop.wipordertype = @WipOrderType
      --AND wop.wiporderno = @WipOrderNo
      WCO.WIPCONTENTCLASS = 1
ORDER BY WOP.OPRSEQUENCENO ASC