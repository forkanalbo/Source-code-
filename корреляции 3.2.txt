-- call create_sensors('sensors', array['s1','s2','s3','s4']);
-- call generate_sensors_data('sensors', array['s1','s2','s3','s4'], 100, 10);
-- call sensors_data_sampling('sensors', array['s1','s2','s3','s4']);
-- select  pearson_correlation('sensors', 's1', 's2');
-- select  correlation_threshold(0.51, 0.8);



/*---------------- Create table procedure ----------------*/
DROP PROCEDURE IF EXISTS create_sensors(TEXT, TEXT[]);
CREATE PROCEDURE create_sensors(tname TEXT, fields TEXT[])
AS $$
DECLARE
	field TEXT;
	create_query TEXT := '';
BEGIN
		create_query := format('DROP TABLE IF EXISTS %s;CREATE TABLE %s ( id serial PRIMARY KEY);', tname , tname);
		
		FOREACH field IN ARRAY fields
   		LOOP
			create_query := create_query || format('ALTER TABLE %s ADD COLUMN %s REAL NOT NULL DEFAULT 0;', tname, field);	
   		END LOOP;
		
		EXECUTE create_query;
END ;
$$
LANGUAGE plpgsql ;
/*---------------- Create table procedure ----------------*/

/*---------------- Generate sensors data procedure ----------------*/
DROP PROCEDURE IF EXISTS generate_sensors_data(TEXT, TEXT[], INT, INT);
CREATE PROCEDURE generate_sensors_data(tname TEXT, fields TEXT[], max_value INT, count INT)
AS $$
DECLARE
	field TEXT;
	data_query TEXT := '';
	query_fields TEXT := '';
	query_values TEXT := '';
	counter integer := 0;
BEGIN
		WHILE counter < count 
		LOOP
			counter := counter + 1;
			query_fields := '';
			query_values := '';
			
			FOREACH field IN ARRAY fields
			LOOP
				query_fields := query_fields || ', ' || field;
				query_values := query_values || ', ' || (random() * 100);
			END LOOP;
			
			query_fields := right(query_fields, -2);
			query_values := right(query_values, -2);
		    data_query := data_query || format('INSERT INTO %s (' || query_fields || ') values (' || query_values || ');', tname);
	    END LOOP;
		EXECUTE data_query;
END ;
$$
LANGUAGE plpgsql;
/*---------------- Generate sensors data procedure ----------------*/

/*---------------- Data sampling procedure ----------------*/
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
			RAISE NOTICE 'num: %', num; 
			
			N := 1 + floor(log(2, num));
			RAISE NOTICE 'N: %', N; 
			
			EXECUTE format('SELECT (max(%s) - min(%s))/%s FROM %s;', field, field, N, tname) INTO Width;
			RAISE NOTICE 'Width: %', Width; 
			
			EXECUTE format('update %s set %s = floor(%s / %s) + 1;', tname, field, field, Width);
			
			
		END LOOP;
END ;
$$
LANGUAGE plpgsql;
/*---------------- Data sampling procedure ----------------*/

/*---------------- Pearson correlation procedure ----------------*/
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
/*---------------- Pearson correlationg procedure ----------------*/

/*---------------- Correlation threshold ----------------*/
DROP FUNCTION IF EXISTS correlation_threshold(REAL, REAL);
CREATE FUNCTION correlation_threshold(correlation REAL, threshold REAL)
RETURNS BOOLEAN
AS $$
BEGIN
		RETURN abs(correlation)>=threshold;
END ;
$$
LANGUAGE plpgsql;
/*---------------- Correlation correlationg procedure ----------------*/

