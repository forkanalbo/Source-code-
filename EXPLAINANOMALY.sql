
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
	res INTEGER := 0;
	rules CURSOR FOR
        SELECT *
        FROM rules;
	maxSensors INTEGER := 0;
	maxRules INTEGER := 0;
	sensorsCount INTEGER :=0;
BEGIN
	FOR table_record IN rules LOOP
		sensorsCount := 0;
		IF table_record.A1S1 = anomaly[1] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A1S2 = anomaly[2] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A1S3 = anomaly[3] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A2S1 = anomaly[4] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A2S2 = anomaly[5] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A2S3 = anomaly[6] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A3S1 = anomaly[7] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A3S2 = anomaly[8] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A3S3 = anomaly[9] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF table_record.A3S4 = anomaly[10] THEN
			sensorsCount := sensorsCount + 1;
		END IF;
		IF maxSensors = sensorsCount THEN
			maxRules := maxRules + 1;
		END IF;
		IF maxSensors < sensorsCount THEN
			maxRules := 1;
			maxSensors := sensorsCount;
		END IF;
		
    END LOOP;
	
	IF maxSensors = array_upper(anomaly, 1) THEN
		RETURN 1;
	END IF;
	IF maxSensors < array_upper(anomaly, 1) AND maxRules = 1 THEN
		RETURN 3;
	END IF;
	
	RETURN 2;
	
END ;
$$
LANGUAGE plpgsql;