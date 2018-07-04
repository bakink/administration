select 'select '||high_value||' as high_value, count(*) from '||table_owner||'.'||table_name||' partition('||partition_name||') union all' 
from 
(with xml as (
  select dbms_xmlgen.getxmltype('select table_owner,table_name, partition_name, high_value,partition_position from dba_tab_partitions where table_owner=''CUSTOMER'' and table_name = ''GWS_BANK_OUTGOING_SERVICE_LOG''') as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_OWNER') table_owner,
         extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition_name,
         replace(extractValue(rws.object_value, '/ROW/HIGH_VALUE'),'TIMESTAMP',null) high_value,
         to_number(extractValue(rws.object_value, '/ROW/PARTITION_POSITION')) partition_position         
  from   xml x, 
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws
         order by partition_position
)     

--- for partition 
select -- 'select '''||a.table_owner||''','''||a.table_name||''',' ||a.high_value||' as p_date, count(*) from '||a.table_owner||'.'||a.table_name||' partition('||a.partition_name||');', 
 'insert into log_counts select /*+parallel(12)*/'''||a.table_owner||''','''||a.table_name||''',' ||a.high_value||' as p_date, count(*) from '||a.table_owner||'.'||a.table_name||' PARTITION FOR('||a.high_value||');'
||chr(13)||'commit;'

from 
(with xml as (
  select dbms_xmlgen.getxmltype('select * from (      
select a.table_owner,a.table_name, a.partition_name, a.high_value,a.partition_position,
 MAX(a.partition_position) KEEP ( DENSE_RANK LAST ORDER BY a.partition_position) OVER ( PARTITION BY a.table_owner,a.table_name) AS lastpart_position 
 from dba_tab_partitions a,alzadmin.archived_tab_params b where 
 a.table_owner=b.owner and 
 a.table_name=b.table_name
) 
where 1=1') as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_OWNER') table_owner,
         extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition_name,
         extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value,
         to_number(extractValue(rws.object_value, '/ROW/PARTITION_POSITION')) partition_position         
  from   xml x, 
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws
         order by partition_position
) a
where a.high_value like '%2018-07-01%'
order by a.table_owner,a.table_name,a.partition_position;
