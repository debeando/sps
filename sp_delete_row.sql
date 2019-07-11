DROP PROCEDURE IF EXISTS dba.sp_delete_row;

DELIMITER //
CREATE PROCEDURE dba.sp_delete_row(
  IN database_name VARCHAR(64),
  IN table_name    VARCHAR(64),
  IN primary_key   INT
)
COMMENT 'Delete row and save old data to recover.'
audit:BEGIN
  DECLARE no_more_rows BOOLEAN;
  DECLARE num_rows     INT DEFAULT 0;
  DECLARE column_name  VARCHAR(64);

  DECLARE columns_cursors CURSOR FOR
  SELECT c.column_name AS column_name
  FROM information_schema.columns c
  WHERE c.table_schema = database_name
    AND c.table_name   = table_name;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = TRUE;

  SET @user_name = (SELECT USER());

  SET @tmp_sql = CONCAT('SELECT COUNT(id) INTO @exist_row FROM ',
                        database_name,
                        '.',
                        table_name,
                        ' WHERE id = ',
                        primary_key
                        );

  PREPARE s1 FROM @tmp_sql;
  EXECUTE s1;
  DEALLOCATE PREPARE s1;

  IF (@exist_row = 0) THEN
    LEAVE audit;
  END IF;

  START TRANSACTION;

  OPEN columns_cursors;
  SELECT FOUND_ROWS() INTO num_rows;

  columns_loop: LOOP
    FETCH columns_cursors INTO column_name;

    IF no_more_rows THEN
      CLOSE columns_cursors;
      LEAVE columns_loop;
    END IF;

    SET @tmp_sql = CONCAT('SELECT ',
                          COALESCE(column_name, 'NULL'),
                          ' INTO @old_value FROM ',
                          database_name,
                          '.',
                          table_name,
                          ' WHERE id = ',
                          primary_key);

    PREPARE s1 FROM @tmp_sql;
    EXECUTE s1;
    DEALLOCATE PREPARE s1;

    SET @tmp_sql = CONCAT('INSERT INTO dba.audits ('
                            'action,'
                            'database_name,'
                            'table_name,'
                            'column_name,'
                            'primary_key,'
                            'old_value,'
                            'user_name,'
                            'created_at) '
                          'VALUES ('
                            '\'D\',\'',
                            database_name,
                            '\',\'',
                            table_name,
                            '\',\'',
                            column_name,
                            '\',\'',
                            primary_key,
                            '\',',
                            COALESCE(CONCAT('\'', @old_value, '\''), 'NULL'),
                            ',\'',
                            @user_name,
                            '\',\'',
                            CURRENT_TIMESTAMP,
                            '\')'
                          );

    PREPARE s1 FROM @tmp_sql;
    EXECUTE s1;
    DEALLOCATE PREPARE s1;

  END LOOP columns_loop;

  SET @tmp_sql = CONCAT('DELETE FROM ',
                        database_name,
                        '.',
                        table_name,
                        ' WHERE id = ',
                        primary_key
                        );

  PREPARE s1 FROM @tmp_sql;
  EXECUTE s1;
  DEALLOCATE PREPARE s1;

  COMMIT;
END//
DELIMITER ;
