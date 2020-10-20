DO $$
DECLARE
   agrs JSON := '[
		{
			"agr": 1,
			"sensors": [1,2,3]
		},
		{
			"agr": 2,
			"sensors": [4,5,6]
		}
		,
		{
			"agr": 3,
			"sensors": [7,8,9,10]
		}
		
	]';
	join_sensors TEXT[];
	join_table TEXT := '';
	sample_table TEXT := 'sampled';
	agr_sensor JSON;
	agr_json JSON;
	counter INTEGER;
	counter2 INTEGER;
	correlation_value REAL;
	corr_threshold REAL := 0.2;
	msg TEXT;
	item RECORD;

BEGIN

    call create_sensors(2, 2, 2, 2, 2);
	call create_sensors(-, 22, -, 22, 22);
	call create_sensors(-, 12, 12, -, 12);
	call create_sensors(3, 3, 3, 3, 3);
	call create_sensors(33, -, 33, -, 33);
	call create_sensors(-, 13, -, 13, 13);
	call create_sensors(4, -, 44, 44, 44);
	call create_sensors(-, 14, 14, 14, 14);
        call create_sensors(-, -, -, 18, 18);
