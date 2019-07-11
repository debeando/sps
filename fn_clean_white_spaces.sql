DROP FUNCTION dba.fn_clean_white_spaces;
DELIMITER //
CREATE FUNCTION dba.fn_clean_white_spaces(
  str VARCHAR(1024)
)
RETURNS VARCHAR(1024)
NOT DETERMINISTIC
COMMENT 'Remove all duplicate white spaces on string.'
BEGIN
  WHILE INSTR(str, '  ') > 0 DO
    set str := REPLACE(str, '  ', ' ');
  END WHILE;
  RETURN TRIM(str);
END//
DELIMITER ;
