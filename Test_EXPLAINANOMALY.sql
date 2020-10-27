


/* (c) 2020 furqan albo jwaid  */
DROP TABLE IF EXISTS rules;
CREATE TABLE rules (
	N serial PRIMARY KEY,
	A1S1 REAL,
	A1S2 REAL,
	A1S3 REAL,
	A2S1 REAL,
	A2S2 REAL,
	A2S3 REAL,
	A3S1 REAL,
	A3S2 REAL,
	A3S3 REAL,
	A3S4 REAL
);

INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 2, NULL, NULL, 3, 33, NULL, 4, 44, NULL, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 2, 22, 12, 3, NULL, 13, 4, NULL, 14, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 2, NULL, 12, 3, 33, NULL, 4, 44, 14, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 2, 22, NULL, 3, NULL, 13, NULL, 44, 14, 18);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 2, 22, 12, 3, 33, 13, 4, 44, 14, 18);

INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 11, 23, 13, 4, 20, 10, 3, 23, NULL, 20);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 4, NULL, 10, NULL, 19, NULL, NULL, 33, 23, 22);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 6, 18, NULL, 7, 30, NULL, 6, 35, 12, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( NULL, 20, 8, 7, NULL, 12, 7, NULL, 13, 13);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( NULL, NULL, 4, 8, NULL, 9, 6, 40, 9, 14);

INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 4, 12, 12, 3, 33, 13, 4, 40, 14, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 4, 12, 12, NULL, 33, 13, 4, NULL, 14, 18);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 4, 12, 12, 3, 33, NULL, 4, 40, 14, 18);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( NULL, 12, 12, 3, NULL, 13, NULL, 40, 14, 18);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 4, 12, NULL, NULL, 33, 13, 4, 40, 14, 18);

INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( 2, 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( NULL, NULL, 12, 3, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( NULL, NULL, NULL, NULL, 33, 13, NULL, NULL, NULL, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( NULL, NULL, NULL, NULL, NULL, NULL, 4, 44, NULL, NULL);
INSERT INTO rules (A1S1, A1S2, A1S3, A2S1, A2S2, A2S3, A3S1, A3S2, A3S3,A3S4) VALUES ( NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14, 18);



DO $$
DECLARE
	item RECORD;
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
	sthreshold JSON := '[0.5,0.7,0.3]';
BEGIN
	RAISE NOTICE 'anomaly_cause: %', anomaly_cause('rules', anomaly) ;
END ;
$$