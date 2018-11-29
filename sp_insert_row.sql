CREATE PROCEDURE dba.sp_insert_row(
  IN database_name VARCHAR(64),
  IN table_name    VARCHAR(64),
  IN list_fields   TEXT,
  IN list_values   TEXT
)
COMMENT 'Insert row and save new data to delete.'
BEGIN
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


    START TRANSACTION;


    SET @tmp_sql = CONCAT('INSERT INTO ',
                          database_name,
                          '.',
                          table_name,
                          ' (',
                          list_fields,
                          ') VALUES (',
                          list_values,
                          ')');

    PREPARE s1 FROM @tmp_sql;
    EXECUTE s1;
    DEALLOCATE PREPARE s1;

    SET @primary_key = LAST_INSERT_ID();

    IF (@primary_key = 0) THEN
      LEAVE audit;
    END IF;

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
                            ' INTO @new_value FROM ',
                            database_name,
                            '.',
                            table_name,
                            ' WHERE id = ',
                            @primary_key);

      PREPARE s1 FROM @tmp_sql;
      EXECUTE s1;
      DEALLOCATE PREPARE s1;


      SET @tmp_sql = CONCAT('INSERT INTO dba.audits ('
                              'action,'
                              'database_name,'
                              'table_name,'
                              'column_name,'
                              'primary_key,'
                              'new_value,'
                              'user_name,'
                              'created_at) '
                            'VALUES ('
                              '\'I\',\'',
                              database_name,
                              '\',\'',
                              table_name,
                              '\',\'',
                              column_name,
                              '\',\'',
                              @primary_key,
                              '\',',
                              COALESCE(CONCAT('\'', @new_value, '\''), 'NULL'),
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
    COMMIT;
  END
