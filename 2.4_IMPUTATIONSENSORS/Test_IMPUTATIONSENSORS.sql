/* (c) 2020 furqan albo jwaid  */

DO $$
DECLARE
	centroids REAL[][];
	sensorsNumber INTEGER := 10;
	clusterNumber INTEGER := 3;
BEGIN
	call create_sensors_null(1 ,sensorsNumber, 100, 0.2);
	centroids := clasterisation('a1', sensorsNumber, clusterNumber, 2, 0.0001);
	call sensors_restoration('a1', centroids);
END ;
$$


