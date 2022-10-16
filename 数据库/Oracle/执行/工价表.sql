SELECT
    ROWNUM,
    TT3.MEDIUM        AS FACILITY,
    IOP.WORKCENTER,
    TT2.MEDIUM           WORKCENTERNAME,
    IOP.OPERATIONNAME AS OPERATIONNAME,
    IOP.WORKPRICE,
    --TO_DATE(iop.EFFECTDATE,'YYYY-MM-DD HH24:MI:SS') AS EFFECTDATE
    IOP.EFFECTDATE
FROM
    (
        SELECT
            OPERATIONNAME,
            WORKCENTER,
            WORKPRICE,
            EFFECTDATE,
            FACILITY
        FROM
            ILT_OPERATION_PRICE
        WHERE
            ACTIVE = 1
          AND
            --工序名, 工作中心编码, 生效时间作为唯一标识
            (OPERATIONNAME, WORKCENTER, EFFECTDATE) IN (SELECT OPERATIONNAME, WORKCENTER, MAX(EFFECTDATE)
                                                        FROM
                                                            ILT_OPERATION_PRICE
                                                        GROUP BY
                                                            OPERATIONNAME,
                                                            WORKCENTER)
    )                              IOP
        LEFT JOIN WORK_CENTER      WC
                  ON WC.WORKCENTER = IOP.WORKCENTER
        LEFT JOIN TEXT_TRANSLATION TT2
                  ON TT2.TEXTID = WC.TEXTID
                      AND TT2.LANGUAGEID = '2052'
        LEFT JOIN FACILITY         F
                  ON F.FACILITY = IOP.FACILITY
        LEFT JOIN TEXT_TRANSLATION TT3
                  ON TT3.TEXTID = F.TEXTID
                      AND TT3.LANGUAGEID = '2052'