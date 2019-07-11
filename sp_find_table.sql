DROP PROCEDURE IF EXISTS dba.sp_find_table;

DELIMITER //
CREATE PROCEDURE dba.sp_find_table(
  IN table_search VARCHAR(64)
)
COMMENT 'Find column name in many tables into database.'
BEGIN
  SELECT DISTINCT table_schema, table_name AS 'table'
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE table_name LIKE table_search
  ORDER BY table_schema, table_name;
END//
DELIMITER ;
