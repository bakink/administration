--https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:9522731800346411985
--http://moinne.com/blog/ronald/oracle/keeping-the-first-and-last-in-your-result-with-analytic-functions-in-your-query
--https://stackoverflow.com/questions/14933828/drop-partitions-older-than-2-months?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

create or replace procedure bakis.drop_old_part 
is
l_sql_stmt varchar2(500);
l_retention_day number:=10;
l_part_high_val timestamp;
l_Error varchar2 (255);
begin
l_sql_stmt:='select table_owner,table_name, partition_name, high_value, partition_position, 
 MAX(partition_position) KEEP ( DENSE_RANK LAST ORDER BY partition_position) OVER ( PARTITION BY table_owner,table_name) AS lastpart_position 
 from all_tab_partitions where table_owner = ''BAKIS'' and table_name like ''%_XT'' escape ''\'' ' ; 
for l_part_tab in (
with xml as (
  select dbms_xmlgen.getxmltype(l_sql_stmt) as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_OWNER') table_owner,
         extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition_name,
         extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value,
         to_number(extractValue(rws.object_value, '/ROW/PARTITION_POSITION')) partition_position,         
         to_number(extractValue(rws.object_value, '/ROW/LASTPART_POSITION')) lastpart_position
  from   xml x, 
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws
order by table_owner,table_name,partition_position)
loop
 l_sql_stmt:='select '||l_part_tab.high_value||' from dual';
 execute immediate l_sql_stmt into l_part_high_val;
 if l_part_high_val < sysdate - l_retention_day and l_part_tab.partition_position<l_part_tab.lastpart_position then
  l_sql_stmt:='alter table '||l_part_tab.table_owner||'.'||l_part_tab.table_name||' drop partition '||l_part_tab.partition_name;
  --execute immediate l_sql_stmt;
  dbms_output.put_line(l_sql_stmt) ;
 end if  ;

end loop;

exception
  when others then
   l_error :=substr (sqlerrm|| '--'|| dbms_utility.format_error_backtrace (),1,255);
   dbms_output.put_line(l_error);
   raise;
end;         


---Based on parameter table:
create table ALZADMIN.ARCHIVED_TAB_PARAMS (
owner varchar2(30),
table_name varchar2(30),
retention_val number(2),  -- saklama suresi
)


insert into ALZADMIN.ARCHIVED_TAB_PARAMS values ('CUSTOMER','ALZ_TRAMER_MOD_WS',1);
insert into ALZADMIN.ARCHIVED_TAB_PARAMS values ('CUSTOMER','KOC_TRAMER_WS_LOG',1);
insert into ALZADMIN.ARCHIVED_TAB_PARAMS values ('CUSTOMER','G2_CONLOG',4);
insert into ALZADMIN.ARCHIVED_TAB_PARAMS values ('CUSTOMER','G2_LOG',4);
insert into ALZADMIN.ARCHIVED_TAB_PARAMS values ('CUSTOMER','ALZ_HLTPRV_LOG',4);
insert into ALZADMIN.ARCHIVED_TAB_PARAMS values ('CUSTOMER','ALZ_DOC_RECOVERY',1);
insert into ALZADMIN.ARCHIVED_TAB_PARAMS values ('CUSTOMER','GWS_BANK_OUTGOING_SERVICE_LOG',1);

select 'alter table '||a.table_owner||'.'||a.table_name||' drop partition '||a.partition_name||';' 
from 
(with xml as (
  select dbms_xmlgen.getxmltype('select table_owner,table_name, partition_name, high_value,partition_position from dba_tab_partitions where table_owner=''CUSTOMER'' and table_name = ''GWS_BANK_OUTGOING_SERVICE_LOG''') as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_OWNER') table_owner,
         extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition_name,
         replace(extractValue(rws.object_value, '/ROW/HIGH_VALUE'),'TIMESTAMP'' ','''') high_value,
         to_number(extractValue(rws.object_value, '/ROW/PARTITION_POSITION')) partition_position         
  from   xml x, 
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws
         order by partition_position
) A, ALZADMIN.ARCHIVED_TAB_PARAMS B
where a.table_owner=b.owner and 
      a.table_name=b.table_name and  
      to_date(replace(a.high_value,'''',null),' yyyy-mm-dd hh24:mi:ss') <  add_months(sysdate,-B.RETENTION_VAL)
