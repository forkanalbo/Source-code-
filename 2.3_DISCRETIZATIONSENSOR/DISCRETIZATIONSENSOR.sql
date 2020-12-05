
/* (c) 2020 furqan albo jwaid  */
/*
Дескретизация показаний сенсоров
Входные параметры:
tname - имя таблицы с показаниями сенсоров
fields - массив имен столбцов с показаниями сенсоров
Результат выполнения:
Обновлены значения показаний сенсоров
*/
DROP PROCEDURE IF EXISTS sensors_data_sampling(TEXT, TEXT[]);
CREATE PROCEDURE sensors_data_sampling(tname TEXT, fields TEXT[])
AS $$
DECLARE
	field TEXT;
	num integer := 0;
	N integer := 1;
	Width real := 0;
	
BEGIN
		FOREACH field IN ARRAY fields
		LOOP
			EXECUTE format('SELECT count(%s) FROM %s;', field, tname) INTO num;
			
			N := 1 + floor(log(2, num));
			
			EXECUTE format('SELECT (max(%s) - min(%s))/%s FROM %s;', field, field, N, tname) INTO Width; 
			
			EXECUTE format('update %s set %s = floor(%s / %s) + 1;', tname, field, field, Width);
			
			
		END LOOP;
END ;
$$
LANGUAGE plpgsql;