DROP PROCEDURE IF EXISTS dba.sp_drop_table;

DELIMITER //
CREATE PROCEDURE dba.sp_drop_table(
  IN database_name VARCHAR(64),
  IN table_name    VARCHAR(64)
)
COMMENT 'Move dropped table into trash database to recover before.'
drop_table:BEGIN
  SELECT DISTINCT table_schema, table_name AS 'table'
  INTO @table_schema, @table_name
  FROM INFORMATION_SCHEMA.COLUMNS AS c
  WHERE c.table_schema = table_schema
    AND c.table_name   = table_name;

  IF (@table_name IS NULL) THEN
    SELECT CONCAT('Table not exist: ', database_name, '.', table_name) INTO @message;

    SIGNAL SQLSTATE '45001'
    SET MESSAGE_TEXT = @message;

    LEAVE drop_table;
  END IF;

  SET @user_name = (SELECT USER());

  SET @tmp_sql = CONCAT('INSERT INTO dba.trash ('
                          'database_name,'
                          'table_name,'
                          'user_name,'
                          'created_at) '
                        'VALUES (\'',
                          database_name,
                          '\',\'',
                          table_name,
                          '\',\'',
                          @user_name,
                          '\',\'',
                          CURRENT_TIMESTAMP,
                          '\')'
                        );

  PREPARE s1 FROM @tmp_sql;
  EXECUTE s1;
  DEALLOCATE PREPARE s1;

  SET @id = (SELECT LAST_INSERT_ID());

  SET @tmp_sql = CONCAT('RENAME TABLE ',
                        database_name,
                        '.',
                        table_name,
                        ' TO trash.',
                        @id,
                        '_',
                        table_name
                        );

  PREPARE s1 FROM @tmp_sql;
  EXECUTE s1;
  DEALLOCATE PREPARE s1;
END//
DELIMITER ;
