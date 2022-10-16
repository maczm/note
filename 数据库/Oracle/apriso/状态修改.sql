UPDATE OPERATION
SET RevisionStatusID = 4
WHERE OperationCode = 'LES_AutoSortTaskQuery.GridView';

UPDATE SF_LAYOUT
SET RevisionStatusID = 4
WHERE OperationCode = 'LES_AutoSortTaskQuery.GridView';;

UPDATE SF_SCREEN_REVISION
SET RevisionStatusID = 4
WHERE SCREENID = (SELECT ID
                  FROM FLXUSER.SF_VIEW
                  WHERE SF_VIEW.NAME = 'LES_AutoSortTaskQueryFilter.FormView');

UPDATE SF_VIEW_REVISION
SET RevisionStatusID = 4
WHERE VIEWID = (SELECT ID
                FROM FLXUSER.SF_VIEW
                WHERE SF_VIEW.NAME = 'LES_AutoSortTaskQueryFilter.FormView');