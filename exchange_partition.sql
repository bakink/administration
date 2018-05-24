
--exchange partition query
select 'alter table '||lower(table_owner)||'.'||lower(table_name)||' exchange partition '||partition_name||' WITH TABLE '||lower(table_owner)||'.'||lower(table_name)||'_'||partition_name||';' 
from dba_tab_partitions where table_owner='CUSTOMER' and table_name='ALZ_HLTH_MDLR_LOG' order by partition_name

