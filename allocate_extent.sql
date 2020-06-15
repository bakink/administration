
select 'alter table CBSLIVE.HSBLKLOG modify subpartition '||sp.SUBPARTITION_NAME||' allocate extent (SIZE 64M);',
sp.table_owner,sp.table_name,sp.partition_name,sp.SUBPARTITION_NAME,
seg.tablespace_name,seg.bytes
from dba_segments seg, dba_tab_subpartitions sp 
where seg.segment_name='HSBLKLOG' and
seg.segment_name=sp.table_name and
seg.owner=sp.table_owner
and seg.partition_name = sp.SUBPARTITION_NAME
and sp.partition_name='P_2020_06' order by  sp.SUBPARTITION_NAME
