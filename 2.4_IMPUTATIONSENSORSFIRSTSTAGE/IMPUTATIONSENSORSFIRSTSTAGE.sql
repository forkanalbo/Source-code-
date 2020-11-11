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
BEGIN
		create_query := format('DROP TABLE IF EXISTS A%s;CREATE TABLE A%s ( N serial PRIMARY KEY, sensors REAL[]);', numAgr, numAgr);
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
	sensors REAL[];
	insert_query TEXT := '';
BEGIN
	FOR i IN 1..numRows LOOP
		 EXECUTE format('select array_agg(generate_sensor_value_null(%s)) from generate_series (1, %s)', null_probability, numSensor) INTO sensors;
		 insert_query = format(E'INSERT INTO A%s(sensors) VALUES(\'%s\');', numAgr, sensors);
		 EXECUTE insert_query;
	END LOOP;
END ;
$$
LANGUAGE plpgsql;

/* Сгенерировать случайное показание сенсора с возможным NULL 
null_probability - вероятность того, что показание сенсора будет равно NULL
Возвращаемое значение: показание сенсора
*/
DROP FUNCTION IF EXISTS generate_sensor_value_null(REAL);
CREATE FUNCTION generate_sensor_value_null(null_probability REAL)
RETURNS REAL
AS $$
DECLARE
	sensors REAL[];
	insert_query TEXT := '';
BEGIN
	IF random() < null_probability THEN
		RETURN NULL;
	END IF;
	RETURN random() * 100;
END ;
$$
LANGUAGE plpgsql;

/* Проверка имеют ли показания сенсоров значения NULL 
sensors - показания сенсоров
Возвращаемое значение: TRUE если показания сенсоров не имеют значения NULL
*/
DROP FUNCTION IF EXISTS sensors_without_null(REAL[]);
CREATE FUNCTION sensors_without_null(sensors REAL[])
RETURNS BOOLEAN
AS $$
DECLARE
	s REAL;
BEGIN
   FOREACH s IN ARRAY sensors
   LOOP
      IF s IS NULL THEN
	  	RETURN FALSE;
	  END IF;
   END LOOP;
   RETURN TRUE;
END ;
$$
LANGUAGE plpgsql;

/* Кластеризация показаний сенсоров
tbl - имя таблицы с показаниями сенсоров
sensorNumber - количество сенсоров
clNumber - количество кластеров
m - степень размытости кластеров >1 
stopThreshold - параметр остановки алгоритма
Возвращаемое значение: массив координат центроидов кластеров
*/
DROP FUNCTION IF EXISTS clasterisation(TEXT,INTEGER, INTEGER, REAL, REAL);
CREATE FUNCTION clasterisation(tbl TEXT, sensorNumber INTEGER, clNumber INTEGER, m REAL, stopThreshold REAL)
RETURNS REAL[][]
AS $$
DECLARE
	res REAL[][]; /* матрица центроидов */
	tbl_without_null TEXT;
	pm REAL[][]; /* матрицы вероятностей */
	pm2 REAL[][];
	pointNumber INTEGER;
	delta REAL := 1;
	cx REAL[][];
	a REAL;
	b REAL;
BEGIN
	tbl_without_null := tbl || '_without_null';
	EXECUTE format('CREATE TEMP TABLE %s as  select sensors from %s where sensors_without_null(sensors);', tbl_without_null, tbl);
	EXECUTE format('SELECT count(*) FROM  %s;', tbl_without_null) INTO pointNumber;
	
	IF pointNumber < clNumber THEN
		
		RAISE NOTICE 'Количество показаний без NULL: %', pointNumber;
		RAISE NOTICE 'Количество кластеров: %', clNumber;
		RAISE EXCEPTION 'Ошибка количество показаний меньше количества кластеров';
		RETURN NULL;
	END IF;
	 
	/* Инициализируем матрицы центроидов и вероятностей */ 
	pm := init_pm(pointNumber, clNumber);
	pm2 := init_pm(pointNumber, clNumber);	
	res  := array_fill(0, ARRAY[clNumber, sensorNumber]);	
	EXECUTE format('SELECT ARRAY(SELECT sensors FROM  %s);', tbl_without_null) INTO cx;
	LOOP
		/* Вычисляем матрицу центроидов */
		FOR i IN 1..clNumber LOOP
    		FOR j IN 1..sensorNumber LOOP
				a := 0;
				b := 0;
				FOR k IN 1..pointNumber LOOP
					a := a + (pm[k][i] ^ m) * cx[k][j];
					b := b + (pm[k][i] ^ m);
				END LOOP;
				res[i][j] := a/b;
			END LOOP;
		END LOOP;
		
		/* Вычисляем матрицу вероятностей */
		FOR i IN 1..pointNumber LOOP
			FOR j IN 1..clNumber LOOP
				a := point_dist(get_matrix_row(cx, i), get_matrix_row(res, j)) ^ (2/(1-m)));
				b  := 0;
				FOR k IN 1..clNumber LOOP
					b := b + point_dist(get_matrix_row(cx, i), get_matrix_row(res, k)) ^ (2/(1-m));
				END LOOP;
				pm2[i][j] := a / b;
			END LOOP;
		END LOOP;
		
		delta := 0;
		/* Вычисляем условие завершения */
		FOR i IN 1..pointNumber LOOP
			FOR j IN 1..clNumber LOOP
				a := abs(pm2[i][j] - pm[i][j]);
				IF delta < a THEN
					delta := a;
				END IF;
				
			END LOOP;
		END LOOP;
		RAISE NOTICE 'delta: %', delta;
		IF delta <= stopThreshold THEN
			EXIT;
		END IF;
		pm := pm2;
	END LOOP;
	RETURN res;
END ;
$$
LANGUAGE plpgsql;


/* Вычисление расстояния между точками
point1, point2 - координаты точек
Возвращаемое значение: расстояние между точками
*/
DROP FUNCTION IF EXISTS point_dist(REAL[], REAL[]);
CREATE FUNCTION point_dist(point1 REAL[],point2 REAL[])
RETURNS REAL
AS $$
DECLARE
	summ REAL := 0;
BEGIN
	FOR i IN 1 .. array_upper(point1, 1) LOOP
    	summ := summ + 	(point2[i] - point1[i]) ^ 2;
	END LOOP;
	RETURN summ ^ 0.5;
END ;
$$
LANGUAGE plpgsql;


/* Инициализация массив вероятностей
pointNumber - количество точек без значений NULL в координатах
clNumber - количество кластеров
Возвращаемое значение: массив вероятностей
*/
DROP FUNCTION IF EXISTS init_pm(INTEGER,INTEGER);
CREATE FUNCTION init_pm(pointNumber INTEGER,clNumber INTEGER)
RETURNS REAL[][]
AS $$
DECLARE
	i INTEGER;
	j INTEGER;
	prop real;
	tprop real;
	pm REAL[][]; /* матрица вероятностей */
BEGIN
	pm  := array_fill(0, ARRAY[pointNumber,clNumber]);
	FOR i IN 1..pointNumber LOOP
		prop := 1;
    	FOR j IN 1..clNumber LOOP
			IF j = clNumber THEN
				tprop := prop;
			ELSE
				LOOP
					tprop := random() / (clNumber /3) * prop;
					IF tprop != 0 AND tprop != 1 THEN
						EXIT;
					END IF;
				END LOOP;	
				prop := prop - tprop;
			END IF;
    		pm[i][j] := tprop;
		END LOOP;
	END LOOP;
	RETURN pm;
END ;
$$
LANGUAGE plpgsql;

/* Получение строки матрицы по номеру
matrix - матрица
rowIndex - номер строки
Возвращаемое значение: строка матрицы
*/
DROP FUNCTION IF EXISTS get_matrix_row(REAL[][],INTEGER);
CREATE FUNCTION get_matrix_row(matrix REAL[][], rowIndex INTEGER)
RETURNS REAL[]
AS $$
DECLARE
	i INTEGER;
	res REAL[];
BEGIN
	res  := array_fill(0, ARRAY[array_upper(matrix, 2)]);
	FOR i IN 1 .. array_upper(matrix, 2) LOOP
    	res[i] := matrix[rowIndex][i];
	END LOOP;
	RETURN res;
END ;
$$
LANGUAGE plpgsql;

/* Получение прототипов точек
centroids - массив центроидов
sensors - исходные показания сенсоров с NULL
Возвращаемое значение: массив прототипов исходной тоски
*/
DROP FUNCTION IF EXISTS get_prototypes(REAL[][],REAL[]);
CREATE FUNCTION get_prototypes(centroids REAL[][], sensors REAL[])
RETURNS REAL[][]
AS $$
DECLARE
	i INTEGER;
	res REAL[][];
BEGIN
	res  := array_fill(0, ARRAY[array_upper(centroids, 1), array_upper(sensors, 1)]);
	FOR i IN 1 .. array_upper(centroids, 1) LOOP
    	FOR j IN 1 .. array_upper(sensors, 1) LOOP
			IF sensors[j] IS NULL THEN
				res[i][j] := centroids[i][j];
			ELSE	
				res[i][j] := sensors[j];
			END IF;
		END LOOP;
	END LOOP;
	RAISE NOTICE 'res: %', res;
	RETURN res;
END ;
$$
LANGUAGE plpgsql;

/* Выбор нужного прототипа точки
centroids - массив центроидов
prototypes - массив прототипов
Возвращаемое значение: Прототип точки
*/
DROP FUNCTION IF EXISTS select_prototype(REAL[][],REAL[][]);
CREATE FUNCTION select_prototype(centroids REAL[][], prototypes REAL[][])
RETURNS REAL[]
AS $$
DECLARE
	res REAL[];
	res_dist REAL;
	centroid REAL[];
	prototype REAL[];
BEGIN
	res  := get_matrix_row(prototypes, 1);
	FOR i IN 1 .. array_upper(centroids, 1) LOOP
		FOR j IN 1 .. array_upper(prototypes, 1) LOOP
			prototype := get_matrix_row(prototypes, j);
			centroid := get_matrix_row(centroids, i);
			IF point_dist(prototype, centroid) < point_dist(res, centroid) THEN
				res := prototype;
			END IF;
    	END LOOP;
	END LOOP;
	RETURN res;
END ;
$$
LANGUAGE plpgsql;

/* Восстановление значений сенсоров
tbl - имя таблицы с показаниями сенсоров
centroids - массив центроидов
Результат выполнения: Значения NULL в таблице показаний сенсоров восстановлено в соответствии с алгоритмом
*/
DROP PROCEDURE IF EXISTS sensors_restoration(TEXT, REAL[][]);
CREATE PROCEDURE sensors_restoration(tbl TEXT, centroids REAL[][])
AS $$
DECLARE
	update_query TEXT := '';
BEGIN
		update_query := format(E'UPDATE %s SET sensors = select_prototype(\'%s\', get_prototypes(\'%s\', sensors)) WHERE NOT sensors_without_null(sensors);', tbl, centroids, centroids);
		EXECUTE update_query;
END ;
$$
LANGUAGE plpgsql ;



