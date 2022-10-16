-- 查询哪些对象被锁
SELECT object_name, machine, s.sid, s.serial#
  FROM v$locked_object l,
       dba_objects o,
       v$session s
 WHERE l.object_id = o.object_id
   AND l.session_id = s.sid;

-- 杀死一个进程
ALTER SYSTEM KILL SESSION '2505,15039';