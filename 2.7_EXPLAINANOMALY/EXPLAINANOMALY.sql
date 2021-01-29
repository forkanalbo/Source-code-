
/* (c) 2020 furqan albo jwaid  */
/* Вычисление причины аномалии
rules_table - имя таблицы правил
anomaly - аномалия
Возвращаемые значения:
1 – Брак сырья, 2 – Неясно, 3 – Неисправные сенсоры */
DROP FUNCTION IF EXISTS anomaly_cause(TEXT, REAL[]);
CREATE FUNCTION anomaly_cause(rules_table TEXT, anomaly REAL[])
RETURNS INTEGER
AS $$
DECLARE
	maxSensors INTEGER;
	maxRules INTEGER;
BEGIN
	EXECUTE format(E'select max(sim(\'%s\', rule_array)) as maxSensors from %s;', anomaly, rules_table) INTO maxSensors;	
	IF maxSensors = array_upper(anomaly, 1) THEN
		RETURN 1;
	END IF;
	EXECUTE format(E'select count(rule_array) from %s where sim(\'%s\', rule_array) = %s;', rules_table, anomaly, maxSensors) INTO maxRules;
	IF maxSensors < array_upper(anomaly, 1) AND maxRules = 1 THEN
		RETURN 3;
	END IF;
	
	RETURN 2;
	
END ;
$$
LANGUAGE plpgsql;


/* Список неисправных сенсоров
rules_table - имя таблицы правил
anomaly - аномалия
*/
DROP FUNCTION IF EXISTS faulty_sensors(TEXT, REAL[]);
CREATE FUNCTION faulty_sensors(rules_table TEXT, anomaly REAL[])
RETURNS INTEGER[]
AS $$
DECLARE
	res INTEGER[];
	maxSensors INTEGER;
BEGIN
	EXECUTE format(E'select max(sim(\'%s\', rule_array)) as maxSensors from %s;', anomaly, rules_table) INTO maxSensors;
	
	EXECUTE format(E'select array_positions(CoordDiff(\'%s\', rule_array), 0) from %s where sim(\'%s\', rule_array) = %s; ', anomaly, rules_table, anomaly,  maxSensors) INTO res;	
	
	
	
	RETURN res;
	
END ;
$$
LANGUAGE plpgsql;


/* Количество совпадений показаний сенсоров в аномалии и правиле  
anomaly - аномалия
_rule - правило
*/
DROP FUNCTION IF EXISTS Sim( REAL[], REAL[]);
CREATE FUNCTION Sim(anomaly REAL[], _rule REAL[])
RETURNS INTEGER
AS $$
DECLARE
	counter INTEGER := 0;
	
BEGIN
FOR i IN array_lower(_rule, 1) .. array_upper(_rule, 1)
LOOP
  IF _rule[i] = anomaly[i] THEN
  	counter := counter +1;
  END IF;
END LOOP;
RETURN 	counter;
END;
$$
LANGUAGE plpgsql;

/* Проверка равенства координат аномалии и правила
anomaly - аномалия
_rule - правило
Возвращаемое значение:
Массив из результатов проверки равенства координат (1 – равны, 0 – не равны)
*/
DROP FUNCTION IF EXISTS CoordDiff(REAL[], REAL[]);
CREATE FUNCTION CoordDiff(anomaly REAL[], _rule REAL[])
RETURNS INTEGER[]
AS $$
DECLARE
	res INTEGER[];	
BEGIN
FOR i IN array_lower(_rule, 1) .. array_upper(_rule, 1)
LOOP
  IF _rule[i] = anomaly[i] THEN
  	res[i] = 1;
  ELSE
    res[i] = 0;
  END IF;
END LOOP;
RETURN 	res;
END;
$$
LANGUAGE plpgsql;

/* Создание таблиц правил
tableName - имя таблицы
sensorNum - количество сенсоров
ruleNum - количество правил
Результат выполения:
Создана таблица правил с заданным именем
*/
DROP PROCEDURE IF EXISTS create_rules(TEXT, INT, INT);
CREATE PROCEDURE create_rules( tableName TEXT, sensorNum INT, ruleNum INT)
AS $$
DECLARE
	create_query TEXT := '';
	counter INT := 0;
BEGIN
		create_query := format('DROP TABLE IF EXISTS %s;CREATE TABLE %s ( N serial PRIMARY KEY, rule_array REAL[]);', tableName, tableName);		
		EXECUTE create_query;
		CALL generate_rules_data(tableName, sensorNum, ruleNum);
END ;
$$
LANGUAGE plpgsql ;

/* Генерация правил
tableName - имя таблицы
sensorNum - количество сенсоров
ruleNum - количество правил
Результат выполения:
В таблицу с именем tableName добавлены правила в количестве ruleNum
*/
DROP PROCEDURE IF EXISTS generate_rules_data(TEXT, INT, INT);
CREATE PROCEDURE generate_rules_data( tableName TEXT, sensorNum INT, ruleNum INT)
AS $$
DECLARE
	data_query TEXT := '';
	counter INT := 0;
	counterSensor INT := 0;
	rule_array REAL[];
BEGIN
		WHILE counter < ruleNum
		LOOP
			counter := counter + 1;
			counterSensor := 0;	
			rule_array :='{}';
			WHILE counterSensor < sensorNum 
			LOOP
				counterSensor := counterSensor + 1;
				IF random() > 0.8 THEN
					rule_array := array_append(rule_array, NULL);
				ELSE
					rule_array := array_append(rule_array, round((random() * 100))::real);
				END IF;
				
			END LOOP;
		    data_query := data_query || format('INSERT INTO %s (rule_array) values ( %L );', tableName, rule_array);
	    END LOOP;
		EXECUTE data_query;
END ;
$$
LANGUAGE plpgsql ;

/* Проверка линии агрегатов
unitLine - входные данные для проверки линии агрегатов
{
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
	}
	
unitLine->lineThreshold - порог исправности линии	
unitLine->units - массив с информацией об ашрегатах линии
unitLine->units[]->unitThreshold - порог исправности агрегата
unitLine->units[]->rulesTable - таблица правил для агрегата
unitLine->units[]->anomaly - аномалия
Возвращаемое значение:
результат проверки линии
{
	"is_faulty" : true, 
	"faulty_units" : [1,2,3,4,5], 
	"units" : [
		{
			"is_faulty" : true, 
			"anomaly_cause" : 2, 
			"faulty_sensors" : [1,2,3,4,5,6,7,8,9,11,12,13]
		},
		{
			"is_faulty" : true, 
			"anomaly_cause" : 2, 
			"faulty_sensors" : [2,3,4,5,6,7,8,9]
		}
	]
}
is_faulty - признак неисправности линии(true - неисправна, false - исправна)
faulty_units - массив неисправных агрегатов
units - массив с информацией по агрегатам
units->is_faulty - признак неисправности агрегата(true - неисправен, false - исправен)
units->anomaly_cause - код причины аномалии
units->faulty_sensors - массив неисправных сенсоров
*/
DROP FUNCTION IF EXISTS testLine(JSON);
CREATE FUNCTION testLine(unitLine JSON)
RETURNS JSON
AS $$
DECLARE
	res JSON;
	res_units JSON[];
	lineThreshold REAL;
	faulty_units  INTEGER[];
	unit_counter INTEGER := 0;
	
	unit_json JSON;
	unit_threshold REAL;
	unit_rules TEXT;
	unit_anomaly TEXT;
	unit_anomaly_array REAL[];
	unit_anomaly_cause INTEGER;
	unit_faulty_sensors INTEGER[];
	unit_is_faulty BOOLEAN;
	unit_res JSON;
BEGIN
	lineThreshold := unitLine->'lineThreshold';
	RAISE NOTICE 'lineThreshold: %', lineThreshold;
	FOR unit_json IN SELECT * FROM json_array_elements(unitLine->'units')
	LOOP
	    unit_counter := unit_counter + 1;
	    unit_threshold := unit_json->'unitThreshold';
		unit_rules :=  unit_json->>'rulesTable';
		unit_anomaly := replace(replace(unit_json->>'anomaly', '[', '{'),']','}');
		unit_anomaly_array := unit_anomaly::real[];

		unit_anomaly_cause = anomaly_cause(unit_rules, unit_anomaly_array);
		unit_faulty_sensors := faulty_sensors(unit_rules, unit_anomaly_array);
		
		unit_is_faulty := unit_threshold < array_length(unit_faulty_sensors, 1)::real/array_length(unit_anomaly_array, 1);
		unit_res := json_build_object(
			'is_faulty', unit_is_faulty,
			'anomaly_cause', unit_anomaly_cause,
			'faulty_sensors', unit_faulty_sensors
		);
		res_units := array_append(res_units, unit_res);
		IF unit_is_faulty THEN
			faulty_units = array_append(faulty_units, unit_counter);
		END IF;
	END LOOP;
	res := json_build_object(
		'is_faulty', lineThreshold < array_length(faulty_units, 1)::real/unit_counter,
		'faulty_units', faulty_units,
		'units', res_units
	);
RETURN 	res;
END;
$$
LANGUAGE plpgsql;

