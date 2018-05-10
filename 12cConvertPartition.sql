--https://jonathanlewis.wordpress.com/2017/06/09/12-2-partitions/

alter table t1 modify 
partition by list (date_start, date_end) automatic (
        partition p11 values (to_date('01-Jan-2017'),to_date('08-Jan-2017')) indexing off read only,
        partition p12 values (to_date('01-Jan-2017'),to_date('15-Jan-2017')) indexing off read only,
        partition p13 values (to_date('01-Jan-2017'),to_date('22-Jan-2017')) indexing off read only,
        partition p21 values (to_date('08-Jan-2017'),to_date('15-Jan-2017')) indexing off read only,
        partition p22 values (to_date('08-Jan-2017'),to_date('22-Jan-2017')) indexing off read only,
        partition p23 values (to_date('08-Jan-2017'),to_date('29-Jan-2017')) indexing off read only,
        partition p31 values (to_date('15-Jan-2017'),to_date('22-Jan-2017')) indexing off read only,
        partition p32 values (to_date('15-Jan-2017'),to_date('29-Jan-2017')) indexing off read only,
        partition p33 values (to_date('15-Jan-2017'),to_date('05-Feb-2017')) indexing off read only
)
including rows where uk_flag is null or (date_start > to_date('01-feb-2017','dd-mon-yyyy'))
online
update indexes (
        t1_client_idx local indexing partial,
        t1_resort_idx local,
        t1_ukflag_idx indexing partial
)
;


CREATE OR REPLACE procedure bakis.convert_partition(p_owner varchar2, p_table_name varchar2, p_parallel_degree number default 16)
is
 l_constraint_name VARCHAR2 (30); 
 l_index_name      VARCHAR2 (30);
 l_indexed_cols    VARCHAR2 (150); 
 l_Sql_Stmt   VARCHAR2 (1000);
 l_Error      VARCHAR2 (255);
begin
 select constraint_name into l_constraint_name from all_constraints a where owner=p_owner and table_name=p_table_name and constraint_type='P'; 
 
 select index_name into l_index_name from all_indexes a where owner=p_owner and table_name=p_table_name;
 
 select listagg('"'||a.column_name||'"',',') within group ( order by a.position ) into  l_indexed_cols
 from ALL_CONS_COLUMNS a 
 where a.owner=p_owner and a.table_name=p_table_name and constraint_name =l_constraint_name
 group by constraint_name; 

-- select index_name into l_index_name from all_indexes a where owner=p_owner and table_name=p_table_name;
  
--1. drop PK  
l_Sql_Stmt:='ALTER TABLE '||p_owner||'.'||p_table_name||' DROP CONSTRAINT '||l_constraint_name;

execute immediate l_Sql_Stmt;

--DBMS_OUTPUT.PUT_LINE(l_Sql_Stmt);
--2. convert table to partition
l_Sql_Stmt:='ALTER TABLE  '||p_owner||'.'||p_table_name||' MODIFY
  PARTITION BY RANGE ("HEADER_timestamp") INTERVAL( NUMTODSINTERVAL(1, ''DAY'')) 
  (
     PARTITION P201801 VALUES LESS THAN (TIMESTAMP'' 2018-02-01 00:00:00'') ,
     PARTITION P201802 VALUES LESS THAN (TIMESTAMP'' 2018-03-01 00:00:00'') ,
     PARTITION P201803 VALUES LESS THAN (TIMESTAMP'' 2018-04-01 00:00:00'') 
  ) ONLINE
parallel '||p_parallel_degree;

execute immediate l_Sql_Stmt;

--DBMS_OUTPUT.PUT_LINE(l_Sql_Stmt);
--3. create index 
l_Sql_Stmt:='CREATE UNIQUE INDEX '||p_owner||'.'||l_index_name||' ON '||p_owner||'.'||p_table_name||'
('||l_indexed_cols||',"HEADER_timestamp")
NOLOGGING
TABLESPACE ALZ_OPUS_DATA_TS
LOCAL
PARALLEL '||p_parallel_degree;

execute immediate l_Sql_Stmt;

--DBMS_OUTPUT.PUT_LINE(l_Sql_Stmt);
--4. noparallel index 
l_Sql_Stmt:='ALTER INDEX '||p_owner||'.'||l_index_name||' NOPARALLEL ';

execute immediate l_Sql_Stmt;

--DBMS_OUTPUT.PUT_LINE(l_Sql_Stmt);
--5. add constraint
l_Sql_Stmt:='ALTER TABLE '||p_owner||'.'||p_table_name||' ADD (
  CONSTRAINT '||l_constraint_name||'
  PRIMARY KEY ('||l_indexed_cols||',"HEADER_timestamp")
  USING INDEX '||p_owner||'.'||l_index_name||'
  ENABLE VALIDATE)';

execute immediate l_Sql_Stmt;

--DBMS_OUTPUT.PUT_LINE(l_Sql_Stmt);    
exception
  when others then
   l_error :=substr (sqlerrm|| '--'|| dbms_utility.format_error_backtrace (),1,255);
   dbms_output.put_line(l_error);
   raise;
end;
/
