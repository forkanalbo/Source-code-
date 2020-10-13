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

