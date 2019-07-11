DROP PROCEDURE IF EXISTS dba.sp_update_row;

DELIMITER //
CREATE PROCEDURE dba.sp_update_row(
  IN database_name VARCHAR(64),
  IN table_name    VARCHAR(64),
  IN column_name   VARCHAR(64),
  IN new_value     TEXT,
  IN primary_key   INT
)
COMMENT 'Update row and save old data to recover.'
audit:BEGIN
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

    SET @tmp_sql = CONCAT('SELECT ',
                          COALESCE(column_name, 'NULL'),
                          ' INTO @old_value ',
                          'FROM ',
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
                            'new_value,'
                            'user_name,'
                            'created_at) '
                          'VALUES ('
                            '\'U\',\'',
                            database_name,
                            '\',\'',
                            table_name,
                            '\',\'',
                            column_name,
                            '\',\'',
                            primary_key,
                            '\',',
                            COALESCE(CONCAT('\'', @old_value, '\''), 'NULL'),
                            ',',
                            COALESCE(CONCAT('\'', new_value, '\''), 'NULL'),
                            ',\'',
                            @user_name,
                            '\',\'',
                            CURRENT_TIMESTAMP,
                            '\')'
                          );

    PREPARE s1 FROM @tmp_sql;
    EXECUTE s1;
    DEALLOCATE PREPARE s1;

    SET @tmp_sql = CONCAT('UPDATE ',
                          database_name,
                          '.',
                          table_name,
                          ' SET ',
                          column_name,
                          ' = \'',
                          new_value,
                          '\' WHERE id = ',
                          primary_key
                          );

    PREPARE s1 FROM @tmp_sql;
    EXECUTE s1;
    DEALLOCATE PREPARE s1;

    COMMIT;
END//
DELIMITER ;
