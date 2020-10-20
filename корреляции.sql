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

/*---------------- FUNCTION Pearson correlation procedure ----------------*/


include('f_pearson_correlation.sql') /*including all the insert code*/


/*---------------- Pearson correlationg procedure ----------------*/


/*----------------FUNCTION Correlation threshold ----------------*/

include('f_correlation_threhold.sql') /*including all the insert code*/

/*---------------- Correlation correlationg procedure ----------------*/

