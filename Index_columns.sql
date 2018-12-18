
--http://anjo.pt/wp/keyword-oracle/2018/12/11/index-columns-query/

select c.index_name,
       c.table_name||'('||listagg(column_name,',') within group (order by column_position)||')' as columns,
       decode(status,'VALID',null,status||' ')
       ||decode(visibility,'VISIBLE',null,visibility||' ')
       ||decode(segment_created,'YES',null,'EMPTY ')
       ||decode(uniqueness,'NONUNIQUE',null,uniqueness||' ')
       ||funcidx_status as STATUS
 from dba_ind_columns c, dba_indexes i
where i.table_name=c.table_name and i.index_name=c.index_name
  and c.table_name='&TABLE_NAME'
group by c.table_name,c.index_name,i.status,visibility, segment_created,uniqueness,funcidx_status
order by c.table_name,c.index_name;
