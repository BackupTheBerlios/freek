DROP TABLE IF EXISTS documents;
delete from templates where page='doc';
delete from templates where page='upload';
delete from site_info where value='documents';
