DROP PROCEDURE IF EXISTS dba.sp_find_column;

DELIMITER //
CREATE PROCEDURE dba.sp_find_column(
  IN column_search VARCHAR(64)
)
COMMENT 'Find column name in many tables into database.'
BEGIN
  SELECT DISTINCT table_schema, table_name AS 'table', column_name AS 'column'
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE column_name LIKE column_search
  ORDER BY table_schema, table_name;
END//
DELIMITER ;
