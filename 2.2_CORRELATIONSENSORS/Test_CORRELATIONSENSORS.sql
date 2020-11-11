/*
Создание таблицы показаний сенсоров
numAgr - номер агрегата
numSensor - количество сенсоров
numRows - количество показаний сенсоров
*/
DROP PROCEDURE IF EXISTS create_sensors(INT, INT, INT);
CREATE PROCEDURE create_sensors(numAgr INT, numSensor INT, numRows INT)
AS $$
DECLARE
	create_query TEXT := '';
	counter INT := 0;
BEGIN
		create_query := format('DROP TABLE IF EXISTS A%s;CREATE TABLE A%s ( N serial PRIMARY KEY);', numAgr, numAgr);
		
		WHILE counter < numSensor 
		LOOP
			counter := counter + 1;
			create_query := create_query || format('ALTER TABLE A%s ADD COLUMN S%s REAL NOT NULL DEFAULT 0;', numAgr, counter);
	    END LOOP;
		
		EXECUTE create_query;
		
		CALL generate_sensors_data(numAgr, numSensor, numRows);
END ;
$$
LANGUAGE plpgsql ;


/*
Заполнение таблицы показаний сенсоров
numAgr - номер агрегата
numSensor - количество сенсоров
numRows - количество показаний сенсоров
*/
DROP PROCEDURE IF EXISTS generate_sensors_data(INT, INT, INT);
CREATE PROCEDURE generate_sensors_data(numAgr INT, numSensor INT, numRows INT)
AS $$
DECLARE
	data_query TEXT := '';
	query_fields TEXT := '';
	query_values TEXT := '';
	counter INT := 0;
	counterSensor INT := 0;
BEGIN
		WHILE counterSensor < numSensor 
		LOOP
			counterSensor := counterSensor + 1;
			query_fields := query_fields || ', S' || counterSensor;
		END LOOP;
		query_fields := right(query_fields, -2);
		
		WHILE counter < numRows 
		LOOP
			counter := counter + 1;
			query_values := '';
			counterSensor := 0;		
			
			WHILE counterSensor < numSensor 
			LOOP
				counterSensor := counterSensor + 1;
				query_values := query_values || ', ' || (random() * 100);
			END LOOP;
			query_values := right(query_values, -2);
		    data_query := data_query || format('INSERT INTO A%s (' || query_fields || ') values (' || query_values || ');', numAgr);
	    END LOOP;
		EXECUTE data_query;
END ;
$$
LANGUAGE plpgsql;


/*
Выбор данных для анализа.
Процедура производит выбор данных сенсоров из нескольких таблиц и создает новую таблицу с показаниями отобранных датчиков.

Входные параметры:
agrs: JSON-строка, содержащая массив объектов с номерами агрегатов и номерами датчиков этих агрегатов.
 '[
	{
		"agr": 1,
		"sensors": [1,2,3]
	},
	{
		"agr": 2,
		"sensors": [2,3]
	}
]'
- agr: номер агрегата;
- sensors: массив с номерами датчиков.

Результат выполнения:
Создана новая таблица с показаниями выбранных датчиков. 

*/
DROP PROCEDURE IF EXISTS join_sensors(JSON);
CREATE PROCEDURE join_sensors(agrs JSON)
AS $$
DECLARE
	res_table TEXT := '';
	res_sensors TEXT[];
	res_sensor TEXT;
	agrs_count INT;
	agrs_array JSON[];
	agr_json JSON;
	agr_sensor JSON;
	create_query TEXT := '';
	import_query TEXT := '';
	data_query TEXT := '';
	data_fields TEXT := '';
	data_query_from TEXT := '';
	counter INTEGER := 0;
	first_agr TEXT;
BEGIN
	SELECT json_array_length(agrs) INTO agrs_count;	
	FOR agr_json IN SELECT * FROM json_array_elements(agrs)
	LOOP
		IF counter = 0
		THEN
			data_fields := format('A%s.N as N',agr_json->>'agr');
			first_agr := agr_json->>'agr';
			data_query_from := format('A%s',agr_json->>'agr');
		ELSE
			data_query_from := data_query_from || format(' INNER JOIN A%s on A%s.N = A%s.N', agr_json->>'agr', first_agr, agr_json->>'agr');
		END IF;
	
		res_table := res_table || format('A%s', agr_json->>'agr');
		
		FOR agr_sensor IN SELECT * FROM json_array_elements(agr_json->'sensors')
		LOOP
			res_sensors := array_append(res_sensors, format('A%sS%s', agr_json->>'agr', agr_sensor));
			data_fields := data_fields || format(', A%s.S%s as A%sS%s',agr_json->>'agr',agr_sensor,agr_json->>'agr',agr_sensor);
		END LOOP;
		counter := counter + 1;
	END LOOP;
	
	create_query := format('DROP TABLE IF EXISTS %s;CREATE TABLE %s ( N serial PRIMARY KEY);', res_table, res_table);
	
	FOREACH res_sensor IN ARRAY res_sensors
	LOOP
		create_query := create_query || format('ALTER TABLE %s ADD COLUMN %s REAL;', res_table, res_sensor);
	END LOOP;
		
	EXECUTE create_query;
	
	data_query := format('SELECT %s FROM %s', data_fields, data_query_from);
	
	import_query := format('INSERT INTO %s(%s);', res_table, data_query);
	
	EXECUTE import_query;
END ;
$$
LANGUAGE plpgsql;



/*
Вычисление корреляции значений сенсоров.
Функция производит вычисление коэффициента корреляции Пирсона данных двух датчиков.
Входные параметры:
­	tname: имя таблицы с данными датчиков;
­	field1: имя поля с данными датчика 1;
­	field2: имя поля с данными датчика 2.
Возвращаемое значение:
Коэффициент корреляции Пирсона данных двух датчиков, вещественное число.
*/
DROP FUNCTION IF EXISTS pearson_correlation(TEXT, TEXT, TEXT);
CREATE FUNCTION pearson_correlation(tname TEXT, field1 TEXT, field2 TEXT)
RETURNS REAL
AS $$
DECLARE
	avg1 REAL := 0;
	avg2 REAL := 0;
	num integer := 0;
	deviation1 REAL := 0;
	deviation2 REAL := 0;
	correlation REAL :=0;
BEGIN
		EXECUTE format('SELECT count(%s) FROM %s;', field1, tname) INTO num;
		EXECUTE format('SELECT avg(%s) FROM %s;', field1, tname) INTO avg1;
		EXECUTE format('SELECT avg(%s) FROM %s;', field2, tname) INTO avg2;
		EXECUTE format('SELECT |/sum((%s - %s)^2.0)/%s FROM %s;', field1, avg1, num, tname) INTO deviation1;
		EXECUTE format('SELECT |/sum((%s - %s)^2.0)/%s FROM %s;', field2, avg2, num, tname) INTO deviation2;
		EXECUTE format('SELECT sum((%s - %s)*(%s - %s))/(%s*%s*%s) FROM %s;', field1, avg1, field2, avg2, num, deviation1, deviation2, tname) INTO correlation;

		RETURN correlation;
END ;
$$
LANGUAGE plpgsql;


/*
Определение признака корреляции.
Входные параметры:
­	correlation: значение коэффициента корреляции данных датчиков;
­	threshold: пороговое значение коэффициент корреляции для определения признака корреляции.
Возвращаемое значение:
Функция возвращает TRUE если значение модуля коэффициента корреляции больше или равно пороговому значению, иначе – FALSE.

*/
DROP FUNCTION IF EXISTS correlation_threshold(REAL, REAL);
CREATE FUNCTION correlation_threshold(correlation REAL, threshold REAL)
RETURNS BOOLEAN
AS $$
BEGIN
		RETURN abs(correlation)>=threshold;
END ;
$$
LANGUAGE plpgsql;

