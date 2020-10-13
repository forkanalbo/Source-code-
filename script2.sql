/*Задачи
2. Программирование
2.1. Вычисление таблицы с данными о корреляции сенсоров
Разработать подпрограмму для вычисления таблицы с данными о корреляции сенсоров технологической линии (см. раздел 2.2. Выявление корреляции между сенсорами).
Вход: список ИД агрегатов (JSON)
Выход: таблица Correlation
Указание: в реализации использовать ранее написанную функцию, вычисляющую корреляцию Пирсона между двумя сенсорами.
Разработать тестовую программу. Сценарий работы тестовой программы:
1. Создание БД сенсоров (использовать ранее разработанный генератор).
2. Вычисление таблицы с данными о корреляции сенсоров (использовать разработанную подпрограмму). Выдача результата на экран.
3. Дискретизация БД сенсоров. Выдача результата на экран.*/

DO $$
DECLARE
   agrs JSON := '[
		{
			"agr": 1,
			"sensors": [1,2,3]
		},
		{
			"agr": 2,
			"sensors": [2,3]
		}
		,
		{
			"agr": 4,
			"sensors": [4,5]
		}
		,
		{
			"agr": 5,
			"sensors": [1,5]
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

    call create_sensors(1, 5, 20);
	call create_sensors(2, 5, 20);
	call create_sensors(3, 5, 20);
	call create_sensors(4, 5, 20);
	call create_sensors(5, 5, 20);
	
	FOR agr_json IN SELECT * FROM json_array_elements(agrs)
	LOOP
			
		join_table := join_table || format('A%s', agr_json->>'agr');
		
		FOR agr_sensor IN SELECT * FROM json_array_elements(agr_json->'sensors')
		LOOP
			join_sensors := array_append(join_sensors, format('A%sS%s', agr_json->>'agr', agr_sensor));
		END LOOP;
	END LOOP;

	call join_sensors(agrs);
	
	DROP TABLE IF EXISTS correlation;
	CREATE TABLE correlation ( sensors text NOT NULL, correlation real NOT NULL, threshold BOOLEAN NOT NULL);
	
	FOR counter in array_lower(join_sensors, 1)..(array_upper(join_sensors, 1)-1) loop
		FOR counter2 in counter..(array_upper(join_sensors, 1)-1) loop
			correlation_value := pearson_correlation(join_table, join_sensors[counter2], join_sensors[counter2+1]);
			INSERT INTO correlation VALUES(join_sensors[counter] || ' - ' || join_sensors[counter+1], correlation_value, correlation_threshold(correlation_value, corr_threshold));
		end loop;
	end loop;
	
	RAISE NOTICE 'Sensors correlation';
	FOR item IN SELECT * FROM correlation LOOP
        RAISE NOTICE 'sensors: %, correlation: %, threshold: %', quote_ident(item.sensors), item.correlation, item.threshold;
    END LOOP;
	
	EXECUTE format('DROP TABLE IF EXISTS %s;', sample_table);
	EXECUTE format('CREATE TABLE %s AS (SELECT * FROM %s);', sample_table,join_table);	
	CALL sensors_data_sampling(sample_table, join_sensors);
	
END;
$$;