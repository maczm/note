SELECT e.location,
       tt.medium AS locationname,
       CASE
           WHEN a.warehouselocationflag = 0 THEN '上料点'
           WHEN a.warehouselocationflag = 1 THEN '下料点'
           WHEN a.warehouselocationflag = 2 THEN '通用料点'
           ELSE ''
           END   AS warehouselocationflagName,
       warehouselocationflag,
       CASE
           WHEN a.warehouselocationstatus = 0 THEN '空闲'
           WHEN a.warehouselocationstatus = 1 THEN '占用'
           WHEN a.warehouselocationstatus = 2 THEN '预占用'
           ELSE ''
           END   AS warehouselocationstatusName,
       warehouselocationstatus,
       whtt.MEDIUM,
       e.warehouse,
       a.container,
       CASE
           WHEN containerstatus = '1' THEN '可移动'
           WHEN containerstatus = '2' THEN '不可移动'
           ELSE ''
           END      containerstatus,
       a.lastupdateon,
       CASE
           WHEN b.ProgressStatus = '100001010' THEN '已拣配'
           WHEN b.ProgressStatus = '100001020' THEN '已叫料'
           WHEN b.ProgressStatus = '100001030' THEN '已配送'
           WHEN b.ProgressStatus = '100001040' THEN '空'
           END      ProgressStatus
FROM warehouse_location e
         LEFT JOIN
     ilt_warehouse_location a
     ON e.id = a.locationid
         LEFT JOIN
     container b
     ON a.container = b.container
         LEFT JOIN
     text_translation tt
     ON tt.textid = e.textid
         AND tt.languageid = '2052' --@LanguageID
-- wangzm add
         LEFT JOIN
     WAREHOUSE wh
     ON e.WAREHOUSE = wh.WAREHOUSE
         LEFT JOIN
     TEXT_TRANSLATION whtt
     ON whtt.TEXTID = wh.TEXTID AND whtt.languageid = '2052' --@LanguageID
-- wangzm end
WHERE E.ACTIVE = 1
  AND a.CONTAINER = 'BK00005915';

-- 料框物料信息
SELECT C.container,
       c.QUANTITY AS QUANTITY,
       P.PRODUCTNO,
       IPF.PRODUCTALIAS,              --物料简码
       TT1.MEDIUM AS PRODUCTNAME,
       IA.WIPORDERNO,
       IA.OPRSEQUENCENO,
       TT2.MEDIUM AS OPRSEQUENCENAME, --工序名
       c.SERIALNO AS SERIALNO
FROM (
         SELECT sia.container,
                sia.inventoryallocationid,
                sia.productid,
                NVl(SUM(sia.quantity), 0)  AS quantity,
                listagg(sia.serialno, ',') AS serialno
         FROM soft_inventory2_allocation sia
         GROUP BY sia.container,
                  sia.inventoryallocationid,
                  sia.productid
     ) c
         LEFT JOIN
     INVENTORY2_ALLOCATION IA
     ON c.INVENTORYALLOCATIONID = IA.ID
         LEFT JOIN
     PRODUCT P
     ON P.ID = c.PRODUCTID
         LEFT JOIN
     TEXT_TRANSLATION TT1
     ON TT1.TEXTID = P.TEXTID
         AND TT1.LANGUAGEID = '2052'--'2052' --@LanguageID
         LEFT JOIN
     WIP_OPERATION WO
     ON WO.WIPORDERNO = IA.WIPORDERNO
         AND WO.OPRSEQUENCENO = IA.OPRSEQUENCENO
         LEFT JOIN
     TEXT_TRANSLATION TT2
     ON TT2.TEXTID = WO.TEXTID
         AND TT2.LANGUAGEID = '2052'--'2052' --@LanguageID
         LEFT JOIN
     ILT_PRODUCT_FACILITY IPF
     ON IPF.PRODUCTNO = P.PRODUCTNO
WHERE C.CONTAINER = 'BK00005915'--@CONTAINER
  AND IPF.FACILITY = '5802'--@Facility
;


select wl.location
from WAREHOUSE_LOCATION wl
         left join ilt_warehouse_location iwl on wl.id = iwl.LOCATIONID
         left join text_translation tt on tt.TEXTID = wl.TEXTID
where iwl.WAREHOUSELOCATIONSTATUS = '0'
  and tt.MEDIUM like '%接驳区%'