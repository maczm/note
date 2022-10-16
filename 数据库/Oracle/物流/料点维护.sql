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
                       AND TTL.LANGUAGEID = '2052'
         LEFT JOIN WAREHOUSE              WH
                   ON WL.WAREHOUSE = WH.WAREHOUSE AND WH.FACILITY = '1820'
         LEFT JOIN TEXT_TRANSLATION       WHTT
                   ON WH.TEXTID = WHTT.TEXTID AND WHTT.LANGUAGEID = '2052'
 WHERE
       WL.FACILITY = '1820'
   AND WL.WORKCENTER IS NOT NULL
)