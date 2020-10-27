/*---------------- Create table procedure ----------------*/
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
/*---------------- Create table procedure ----------------*/

/*---------------- Generate sensors data procedure ----------------*/
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
/*---------------- Generate sensors data procedure ----------------*/

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
			
			N := 1 + floor(log(2, num));
			
			EXECUTE format('SELECT (max(%s) - min(%s))/%s FROM %s;', field, field, N, tname) INTO Width; 
			
			EXECUTE format('update %s set %s = floor(%s / %s) + 1;', tname, field, field, Width);
			
			
		END LOOP;
END ;
$$
LANGUAGE plpgsql;
/*---------------- Data sampling procedure ----------------*/

/*---------------- Pearson correlation procedure ----------------*/
include('correlationsensors.sql') /*including all the insert code*/
/*---------------- Pearson correlationg procedure ----------------*/

/*---------------- Correlation threshold ----------------*/
include('pearson_correlation.sql') /*including all the insert code*/

/*---------------- Correlation correlationg procedure ----------------*/

