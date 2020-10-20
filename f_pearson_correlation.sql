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
		
	-- Подсчет количества элементов в таблице
	EXECUTE format('SELECT count(%s) FROM %s;', field1, tname) INTO num;
	
	-- Подсчет средних значений датчиков
	EXECUTE format('SELECT avg(%s) FROM %s;', field1, tname) INTO avg1;
	EXECUTE format('SELECT avg(%s) FROM %s;', field2, tname) INTO avg2;
	
	-- Подсчет среднеквадратичного отклониения значений датчиков
	EXECUTE format('SELECT |/sum((%s - %s)^2.0)/%s FROM %s;', field1, avg1, num, tname) INTO deviation1;
	EXECUTE format('SELECT |/sum((%s - %s)^2.0)/%s FROM %s;', field2, avg2, num, tname) INTO deviation2;

	-- Вычисление коэффициента корреляции Пирсона
	EXECUTE format('SELECT sum((%s - %s)*(%s - %s))/(%s*%s*%s) FROM %s;', field1, avg1, field2, avg2, num, deviation1, deviation2, tname) INTO correlation;

		RETURN correlation;
END ;
$$
LANGUAGE plpgsql;
