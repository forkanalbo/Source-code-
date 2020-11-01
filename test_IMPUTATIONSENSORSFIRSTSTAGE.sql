
/* (c) 2020 furqan albo jwaid  */

/* Создание таблицы показаний сенсоров с пропущенными значениями 
numAgr - номер агрегата
numSensor - количество сенсоров
numRows - количество показаний сенсоров
null_probability - вероятность того, что значение сенсора будет равно NULL
*/
DROP PROCEDURE IF EXISTS create_sensors_null(INT, INT, INT, REAL);
CREATE PROCEDURE create_sensors_null(numAgr INT, numSensor INT, numRows INT, null_probability REAL)
AS $$
DECLARE
	create_query TEXT := '';
	counter INT := 0;
BEGIN
		create_query := format('DROP TABLE IF EXISTS A%s;CREATE TABLE A%s ( N serial PRIMARY KEY);', numAgr, numAgr);
		
		WHILE counter < numSensor 
		LOOP
			counter := counter + 1;
			create_query := create_query || format('ALTER TABLE A%s ADD COLUMN S%s REAL;', numAgr, counter);
	    END LOOP;
		
		EXECUTE create_query;
		
		CALL generate_sensors_data_null(numAgr, numSensor, numRows, null_probability);
END ;
$$
LANGUAGE plpgsql ;


/* Заполнение таблицы показаний сенсоров с пропущенными значениями 
numAgr - номер агрегата
numSensor - количество сенсоров
numRows - количество показаний сенсоров
null_probability - вероятность того, что значение сенсора будет равно NULL
*/
DROP PROCEDURE IF EXISTS generate_sensors_data_null(INT, INT, INT, REAL);
CREATE PROCEDURE generate_sensors_data_null(numAgr INT, numSensor INT, numRows INT, null_probability REAL)
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
				IF null_probability < random() THEN
					query_values := query_values || ', ' || (random() * 100);
				ELSE
					query_values := query_values || ', NULL';
				END IF;
			END LOOP;
			query_values := right(query_values, -2);
		    data_query := data_query || format('INSERT INTO A%s (' || query_fields || ') values (' || query_values || ');', numAgr);
	    END LOOP;
		EXECUTE data_query;
END ;
$$
LANGUAGE plpgsql;

/* Создание таблицы показаний сенсоров с без неопределленых значений на основе данных таблицы созданной процедурой  create_sensors_null
numAgr - номер агрегата
numSensor - количество сенсоров
*/
DROP PROCEDURE IF EXISTS get_not_null_records(INT, INT);
CREATE PROCEDURE get_not_null_records(numAgr INT, numSensor INT)
AS $$
DECLARE
	create_query TEXT := '';
	counter INT := 0;
BEGIN
		create_query := format('DROP TABLE IF EXISTS A%sC;CREATE TABLE A%sC AS SELECT * FROM A%s WHERE ', numAgr, numAgr, numAgr);
		WHILE counter < numSensor 
		LOOP
			counter := counter + 1;
			IF counter != 1 THEN
				create_query := create_query || 'AND ';
			END IF;
			create_query := create_query || format('S%s IS NOT NULL ', counter);
	    END LOOP;
		EXECUTE create_query;
END ;
$$
LANGUAGE plpgsql ;

/* Создание матрицы вероятностей принадлежности точек кластерам  
numAgr - номер агрегата
numClusters - количество кластеров
*/
DROP PROCEDURE IF EXISTS create_probability_matrix(INT, INT);
CREATE PROCEDURE create_probability_matrix(numAgr INT, numClusters INT)
AS $$
DECLARE
	create_query TEXT := '';
	counter INT := 0;
BEGIN
		create_query := format('DROP TABLE IF EXISTS U%s;CREATE TABLE U%s ( N INT);', numAgr, numAgr);
		
		WHILE counter < numClusters 
		LOOP
			counter := counter + 1;
			create_query := create_query || format('ALTER TABLE U%s ADD COLUMN C%s REAL;', numAgr, counter);
	    END LOOP;
		
		EXECUTE create_query;
END ;
$$
LANGUAGE plpgsql ;


/* Создание матрицы центроидов  
numAgr - номер агрегата
numSensor - количество сенсоров
*/
DROP PROCEDURE IF EXISTS create_centroid_matrix(INT, INT);
CREATE PROCEDURE create_centroid_matrix(numAgr INT, numSensor INT)
AS $$
DECLARE
	create_query TEXT := '';
	counter INT := 0;
BEGIN
		create_query := format('DROP TABLE IF EXISTS C%s;CREATE TABLE C%s ( N INT);', numAgr, numAgr);
		
		WHILE counter < numSensor 
		LOOP
			counter := counter + 1;
			create_query := create_query || format('ALTER TABLE C%s ADD COLUMN S%s REAL;', numAgr, counter);
	    END LOOP;
		
		EXECUTE create_query;
END ;
$$
LANGUAGE plpgsql ;
