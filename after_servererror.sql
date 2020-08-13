
CREATE SEQUENCE ALZADMIN.LOG_ERRORS_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 2000
  NOORDER;

CREATE TABLE ALZADMIN.LOG_ERRORS_TAB
(
  LOG_ID        NUMBER,
  LOG_DATE      DATE,
  LOG_USR       VARCHAR2(30 BYTE),
  TERMINAL      VARCHAR2(50 BYTE),
  OS_USER       VARCHAR2(50 BYTE),
  SQL_STMT      VARCHAR2(4000 BYTE),
  ERR_NR        NUMBER(10),
  ERR_MSG       VARCHAR2(4000 BYTE),
  SID           NUMBER,
  INST_ID       NUMBER,
  LOG_ORDER_NO  NUMBER
)
NOCOMPRESS 
TABLESPACE AZS_TMPERR_DATA_TS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            BUFFER_POOL      DEFAULT
           )
LOGGING
PARTITION BY RANGE (LOG_DATE)
INTERVAL( NUMTOYMINTERVAL(1, 'MONTH'))
(  
  PARTITION P201805 VALUES LESS THAN (TO_DATE(' 2018-06-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    COMPRESS FOR QUERY HIGH ,  
  PARTITION VALUES LESS THAN (TO_DATE(' 2018-07-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
    LOGGING
    NOCOMPRESS
)
NOPARALLEL
MONITORING;

CREATE OR REPLACE TRIGGER SYS.LOG_ERRORS_TRIG
  after servererror on database
declare
 cnt binary_integer;
 v_stmt VARCHAR2(4000);
 sql_text ora_name_list_t;
 v_ip_address varchar2(50);
 v_os_user varchar2(50);
 v_log_id number;
 v_log_order_no number;
begin
  if ora_login_user in('A','B') then
-- IF (IS_SERVERERROR (1)) then
    cnt := ora_sql_txt(sql_text);
    FOR i IN 1..cnt LOOP
       v_stmt := v_stmt || sql_text(i);
    END LOOP;
    v_stmt := substr(v_stmt,1,4000);
    v_ip_address := sys_context('USERENV','IP_ADDRESS');
    v_os_user := sys_context('USERENV','OS_USER');
    select alzadmin.log_errors_seq.nextval into v_log_id from dual;
    v_log_order_no := 1;
    FOR n IN 1..ora_server_error_depth LOOP
      insert into alzadmin.log_errors_tab  (log_id,
                                            log_date,
                                            log_usr,
                                            terminal,
                                            os_user,
                                            sql_stmt,
                                            err_nr,
                                            err_msg,
                                            sid,
                                            inst_id,
                                            log_order_no)
                                    values (v_log_id,
                                            sysdate,
                                            ora_login_user,
                                            v_ip_address,
                                            v_os_user,
                                            v_stmt,
                                            ora_server_error(n),
                                            ora_server_error_msg(n),
                                            sys_context('USERENV','SID'),
                                            sys_context('USERENV','INSTANCE'),
                                            v_log_order_no);
      v_log_order_no := v_log_order_no + 1;                                      
    END LOOP;
  end if;
end log_errors_trig;
/
--ykb
                              
drop TRIGGER master.LOG_ERRORS_ALL;
drop TABLE master.DB_ERROR_LOG purge;
CREATE TABLE master.DB_ERROR_LOG( ERROR_DATE DATE,SID NUMBER, USERNAME VARCHAR2(30 BYTE), OSUSER VARCHAR2(30 BYTE), HOST_IP VARCHAR2(128 BYTE), 
MODULE VARCHAR2(128 BYTE), INSTANCE_NAME VARCHAR2(30 BYTE), ERROR_TEXT VARCHAR2(3000 BYTE), STATEMENT VARCHAR2(4000 BYTE), ERRORNO NUMBER,TERMINAL VARCHAR2(30 BYTE)) 
NOCOMPRESS TABLESPACE USERS PCTUSED 0 PCTFREE 10 INITRANS 16 MAXTRANS 255 
STORAGE ( BUFFER_POOL DEFAULT ) PARTITION BY HASH (ERROR_DATE) PARTITIONS 128 STORE IN (USERS) NOCACHE NOPARALLEL MONITORING ;

CREATE OR REPLACE TRIGGER master.LOG_ERRORS_ALL AFTER servererror ON DATABASE WHEN (nvl(USER,'NULL') NOT IN ('1DBSNMP','1SYS') )
DECLARE
sql_text ora_name_list_t;
stmt VARCHAR2(4000) := NULL;
BEGIN
BEGIN
if ora_server_error(1)<>1017 then
FOR i IN 1 .. ora_sql_txt(sql_text) LOOP
stmt := stmt || sql_text(i);
END LOOP;
end if;
EXCEPTION WHEN OTHERS THEN stmt:='';
END;
IF nvl(ora_server_error(1),999999999) not in(1,1035,2001,1400,1775) THEN
INSERT INTO master.db_error_log VALUES(SYSDATE,sys_context('USERENV','SID'), USER, sys_context('USERENV','OS_USER'), sys_context('USERENV','HOST')||':'||sys_context('USERENV','IP_ADDRESS'),
sys_context('USERENV','MODULE'),sys_context('USERENV','INSTANCE_NAME')||' -- '||sys_context('USERENV','DB_NAME'),
dbms_utility.format_error_stack, stmt, ora_server_error(1),sys_context('USERENV','TERMINAL'));
END IF;
END;
/


                              
