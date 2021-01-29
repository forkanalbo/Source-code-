/* (c) 2020 furqan albo jwaid  */

DROP TABLE IF EXISTS rules;
CREATE TABLE rules (
	N serial PRIMARY KEY,
	rule_array REAL[]
);

INSERT INTO rules (rule_array) VALUES ( '{2, NULL, NULL, 3, 33, NULL, 4, 44, NULL, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{2, 22, 12, 3, NULL, 13, 4, NULL, 14, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{2, NULL, 12, 3, 33, NULL, 4, 44, 14, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{2, 22, NULL, 3, NULL, 13, NULL, 44, 14, 18}');
INSERT INTO rules (rule_array) VALUES ( '{2, 22, 12, 3, 33, 13, 4, 44, 14, 18}');

INSERT INTO rules (rule_array) VALUES ( '{11, 23, 13, 4, 20, 10, 3, 23, NULL, 20}');
INSERT INTO rules (rule_array) VALUES ( '{4, NULL, 10, NULL, 19, NULL, NULL, 33, 23, 22}');
INSERT INTO rules (rule_array) VALUES ( '{6, 18, NULL, 7, 30, NULL, 6, 35, 12, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{NULL, 20, 8, 7, NULL, 12, 7, NULL, 13, 13}');
INSERT INTO rules (rule_array) VALUES ( '{NULL, NULL, 4, 8, NULL, 9, 6, 40, 9, 14}');

INSERT INTO rules (rule_array) VALUES ( '{4, 12, 12, 3, 33, 13, 4, 40, 14, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{4, 12, 12, NULL, 33, 13, 4, NULL, 14, 18}');
INSERT INTO rules (rule_array) VALUES ( '{4, 12, 12, 3, 33, NULL, 4, 40, 14, 18}');
INSERT INTO rules (rule_array) VALUES ( '{NULL, 12, 12, 3, NULL, 13, NULL, 40, 14, 18}');
INSERT INTO rules (rule_array) VALUES ( '{4, 12, NULL, NULL, 33, 13, 4, 40, 14, 18}');

INSERT INTO rules (rule_array) VALUES ( '{2, 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{NULL, NULL, 12, 3, NULL, NULL, NULL, NULL, NULL, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{NULL, NULL, NULL, NULL, 33, 13, NULL, NULL, NULL, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{NULL, NULL, NULL, NULL, NULL, NULL, 4, 44, NULL, NULL}');
INSERT INTO rules (rule_array) VALUES ( '{NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14, 18}');



DO $$
DECLARE
	item RECORD;
	sim_array INTEGER; 
	anomaly REAL[] := ARRAY[
		2,
		22,
		12,
		3,
		33,
		13,
		4,
		44,
		14,
		18
	];
	json_input JSON := '{
		"lineThreshold": 0.8,
		"units":[
			{
				"unitThreshold": 0.8,
				"rulesTable": "r1",
				"anomaly":[70, 7, 2, 75, 39, 21, 31, 34, 34, 13, 25, 64, 40] 
			},
			{
				"unitThreshold": 0.8,
				"rulesTable": "r2",
				"anomaly":[62, 95, 59, 31, 60, 64, 46, 23, 2]
			},
			{
				"unitThreshold": 0.8,
				"rulesTable": "r3",
				"anomaly":[56, 38, 44, 77, 29, 79, 99]
			},
			{
				"unitThreshold": 0.8,
				"rulesTable": "r4",
				"anomaly":[71, 96, 7, 12, 67, 86, 35, 36, 91, 75, 19]
			},
			{
				"unitThreshold": 0.8,
				"rulesTable": "r5",
				"anomaly":[33, 98, 80, 58, 37, 41, 81, 72, 43, 23, 83, 2, 29, 89, 49]
			}
		]
	}';
BEGIN
    
	RAISE NOTICE 'Причина аномалии: %', anomaly_cause('rules', anomaly) ;
	RAISE NOTICE 'Неисправные сенсоры: %', faulty_sensors('rules', anomaly) ;
	
	
	CALL create_rules('r1', 13, 25);
	CALL create_rules('r2', 9, 30);
	CALL create_rules('r3', 7, 20);
	CALL create_rules('r4', 11, 50);
	CALL create_rules('r5', 15, 45);
	RAISE NOTICE 'Проверка линии: %', testLine(json_input);
	
END ;
$$