SELECT IOW.ID,
       IOW.PRODUCTID,
       P.PRODUCTNO,
       TT.MEDIUM AS PRODUCTNAME,
       --IOW.OPRSEQUENCENO,
       WL.LOCATION,
       IPF.PRODUCTALIAS,                 --物料简码
       --IOW.BOMPRODUCTID,
       IOW.PRIORITY,
       CASE
           WHEN IOW.PRIORITY = 1 THEN '优先级1'
           WHEN IOW.PRIORITY = 2 THEN '优先级2'
           END   AS PRI,
       IOW.WAREHOUSE,
       IOW.MATCHINGPATTERN,
       CASE
           WHEN IOW.MATCHINGPATTERN = 0 THEN '先叫料再匹配'
           WHEN IOW.MATCHINGPATTERN = 1 THEN '按订单匹配'
           WHEN IOW.MATCHINGPATTERN = 2 THEN '按物料匹配'
           END   AS MATCHINGPATTERNDESC, --匹配模式
       CASE
           WHEN WH.ALLOCATIONBASIS = 2 THEN '立库'
                                       ELSE '缓存区'
           END   AS WHC,
       -- 叫料数量
       IOW.MATERIALQUANTITY
FROM ILT_OPRSEQUENCE_WAREHOUSE_ZX       IOW
         LEFT JOIN PRODUCT              P
         ON IOW.PRODUCTID = P.ID
         LEFT JOIN TEXT_TRANSLATION     TT
         ON P.TEXTID = TT.TEXTID
             AND TT.LANGUAGEID = '2052'
         LEFT JOIN WAREHOUSE            WH
         ON WH.WAREHOUSE = IOW.WAREHOUSE
             AND WH.FACILITY = '1820'
         LEFT JOIN ILT_PRODUCT_FACILITY IPF
         ON IPF.PRODUCTNO = P.PRODUCTNO
         LEFT JOIN WAREHOUSE_LOCATION   WL
         ON IOW.LOCATIONID = WL.ID
WHERE IOW.ACTIVE = 1
  AND IPF.FACILITY = '1820'