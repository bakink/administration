
select count(*) from dba_segments where tablespace_name in ('NWB_2017_2018') ; -- 0
select count(*) from dba_tables where tablespace_name in ('NWB_2017_2018'); -- 0
select count(*) from dba_tab_partitions where tablespace_name in ('NWB_2017_2018'); -- 57
select count(*) from dba_tab_subpartitions where tablespace_name in ('NWB_2017_2018'); -- 0
select count(*) from dba_indexes where tablespace_name in ('NWB_2017_2018');  -- 0
select count(*) from dba_ind_partitions where tablespace_name in ('NWB_2017_2018');  -- 19
select count(*) from dba_ind_subpartitions where tablespace_name in ('NWB_2017_2018')  ; -- 0
select count(*) from dba_lobs where tablespace_name in ('NWB_2017_2018') ;  -- 4
select count(*) from dba_lob_partitions where tablespace_name in ('NWB_2017_2018');  -- 114
select count(*) from dba_lob_subpartitions where tablespace_name in ('NWB_2017_2018');  -- 0
select count(*) from dba_part_tables where def_tablespace_name='NWB_2017_2018';  -- 0
select count(*) from dba_part_indexes where def_tablespace_name='NWB_2017_2018';  -- 4
select count(*) from dba_part_lobs where def_tablespace_name='NWB_2017_2018';  -- 4
select count(*) from dba_users where default_tablespace='NWB_2017_2018';  -- 0
select count(*) from dba_users where temporary_tablespace='NWB_2017_2018';  -- 0
