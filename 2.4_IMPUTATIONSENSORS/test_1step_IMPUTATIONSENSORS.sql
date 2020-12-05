/* (c) 2020 furqan albo jwaid  */
/* Butterfly test */
DO $$
DECLARE
	centroids REAL[][];
BEGIN
	call load_sensors(1, '/csv/butterfly.csv');
	centroids := clasterisation('a1', 2, 2, 2, 0.01);
	raise notice 'Centroids: %', centroids;
END ;
$$


/*-------------------- Test Result -------------------------------
NOTICE:  delta: 0.87602115
NOTICE:  delta: 0.27929646
NOTICE:  delta: 0.091024056
NOTICE:  delta: 0.022183187
NOTICE:  delta: 0.0036141947
NOTICE:  Centroids: {{0.8560151,1.999863},{5.140382,2.0001292}}

*/

/*-------------------- Test Result -------------------------------
NOTICE:  delta: 0.5295262
NOTICE:  delta: 0.3049509
NOTICE:  delta: 0.2220055
NOTICE:  delta: 0.10703262
NOTICE:  delta: 0.02512148
NOTICE:  delta: 0.0037157089
NOTICE:  Centroids: {{0.85828876,2.000624},{5.1405687,1.9993886}}
*/

/* теста из 16 точек, расположенных в виде квадрата 4x4*/

DO $$
DECLARE
	centroids REAL[][];
BEGIN
	call load_sensors(1, '/csv/16dots.csv');
	centroids := clasterisation('a1', 2, 4, 2, 0.01);
	raise notice 'Centroids: %', centroids;
END ;
$$


/*-------------------- Test Result -------------------------------
NOTICE:  delta: 0.56016195
NOTICE:  delta: 0.27952176
NOTICE:  delta: 0.23150378
NOTICE:  delta: 0.38981688
NOTICE:  delta: 0.13694924
NOTICE:  delta: 0.124264985
NOTICE:  delta: 0.091710925
NOTICE:  delta: 0.07231051
NOTICE:  delta: 0.046367407
NOTICE:  delta: 0.027150035
NOTICE:  delta: 0.016366303
NOTICE:  delta: 0.009912908
NOTICE:  Centroids: {{0.4811877,2.5382948},{0.47280583,0.49953845},{2.5374534,2.5051851},{2.5085676,0.44975996}}

*/

/*-------------------- Test Result -------------------------------
NOTICE:  delta: 0.53942347
NOTICE:  delta: 0.18857172
NOTICE:  delta: 0.21918896
NOTICE:  delta: 0.3123992
NOTICE:  delta: 0.21646589
NOTICE:  delta: 0.14976707
NOTICE:  delta: 0.10174066
NOTICE:  delta: 0.062874496
NOTICE:  delta: 0.033094108
NOTICE:  delta: 0.016373456
NOTICE:  delta: 0.008432686
NOTICE:  Centroids: {{2.5199158,2.5075965},{2.5234184,0.46677488},{0.47124484,0.49320394},{0.48574385,2.543889}}
*/