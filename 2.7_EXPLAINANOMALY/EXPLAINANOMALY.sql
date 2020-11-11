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


