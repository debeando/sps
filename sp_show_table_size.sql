DROP PROCEDURE IF EXISTS dba.sp_show_table_size;

DELIMITER //
CREATE PROCEDURE dba.sp_show_table_size(
  IN database_name VARCHAR(64),
  IN table_name    VARCHAR(64)
)
COMMENT 'Show table size.'
BEGIN
  SELECT table_schema AS 'schema',
         table_name AS 'table',
         CONCAT(ROUND(table_rows / 1000000, 2), 'M') AS 'rows',
         CONCAT(ROUND(data_length / ( 1024 * 1024 * 1024 ), 2), 'G') AS 'data',
         CONCAT(ROUND(index_length / ( 1024 * 1024 * 1024 ), 2), 'G') AS 'idx',
         CONCAT(ROUND(( data_length + index_length ) / ( 1024 * 1024 * 1024 ), 2), 'G') AS 'total_size',
         ROUND(index_length / data_length, 2) AS 'idxfrac'
  FROM   information_schema.TABLES
  WHERE table_schema NOT IN ('information_schema',
                             'performance_schema',
                             'mysql')
    AND table_schema = database_name
    AND information_schema.TABLES.table_name = table_name
  ORDER BY data_length + index_length DESC;
END//
DELIMITER ;
