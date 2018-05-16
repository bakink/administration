--https://community.toadworld.com/platforms/oracle/w/wiki/4902.script-to-report-table-partition-keys

SELECT   owner, NAME, column_name, column_position
    FROM dba_part_key_columns
   WHERE owner LIKE UPPER ('&&ENTER_OWNER_NAME')
     AND NAME LIKE UPPER ('&&ENTER_TABLE_NAME')
ORDER BY owner, NAME;
