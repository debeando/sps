DROP FUNCTION dba.fn_clean_spacial_chars;
DELIMITER //
CREATE FUNCTION fn_clean_spacial_chars(
  textvalue VARCHAR(1024)
)
RETURNS varchar(1024)
NOT DETERMINISTIC
COMMENT 'Remove or replace all special chars on string.'
BEGIN
  -- ACCENTS
  SET @withaccents = 'ŠšŽžÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝŸÞàáâãäåæçèéêëìíîïñòóôõöøùúûüýÿþƒ';
  SET @withoutaccents = 'SsZzAAAAAAACEEEEIIIINOOOOOOUUUUYYBaaaaaaaceeeeiiiinoooooouuuuyybf';
  SET @count = LENGTH(@withaccents);

  WHILE @count > 0 DO
    SET textvalue = REPLACE(textvalue, SUBSTRING(@withaccents, @count, 1), SUBSTRING(@withoutaccents, @count, 1));
    SET @count = @count - 1;
  END WHILE;

  -- SPECIAL CHARS
  SET @special = '«»’”“!@#$%¨&()-_+=§¹²³£¢¬"`´{[^~}]<,>.:;?/°ºª+*|\'\\';
  SET @count = LENGTH(@special);

  WHILE @count > 0 do
    SET textvalue = REPLACE(textvalue, SUBSTRING(@special, @count, 1), '');
    SET @count = @count - 1;
  END WHILE;

  RETURN textvalue;
END//
DELIMITER ;
