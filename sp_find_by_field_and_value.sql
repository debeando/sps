DROP PROCEDURE IF EXISTS dba.sp_find_by_field_and_value;

DELIMITER //
CREATE PROCEDURE dba.sp_find_by_field_and_value(
  IN column_search VARCHAR(64),
  IN column_value TEXT
)
COMMENT 'Find and create select statement by column name and value in many tables into database.'
BEGIN
  DECLARE no_more_rows     BOOLEAN;
  DECLARE select_statement TEXT;

  DECLARE select_cursors CURSOR FOR
  SELECT concat('SELECT `',COLUMN_NAME,'` FROM `',TABLE_SCHEMA,'`.`',TABLE_NAME,'` WHERE `',COLUMN_NAME,'`= "', column_value, '";') AS sql_text
  FROM information_schema.columns
  WHERE column_name LIKE column_search
  ORDER BY table_schema, table_name;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = TRUE;
  OPEN select_cursors;

  columns_loop: LOOP
    FETCH select_cursors INTO select_statement;

    IF no_more_rows THEN
      CLOSE select_cursors;
      LEAVE columns_loop;
    END IF;

    SET @tmp_sql = select_statement;

    SELECT @tmp_sql AS query;
    PREPARE s1 FROM @tmp_sql;
    EXECUTE s1;
    DEALLOCATE PREPARE s1;
  END LOOP columns_loop;
END//
DELIMITER ;
