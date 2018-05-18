--https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:18283723778263

select *
 from ( 
 select owner, segment_name, segment_type, block_id 
 from dba_extents 
 where file_id = ( select file_id 
 from dba_data_files 
 where file_name = '+DATAC1/opusdata/datafile/azs_cognos_data_ts.2066.939418521' ) 
 order by block_id desc 
 ) 
 where rownum <= 50 
 
