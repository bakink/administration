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
