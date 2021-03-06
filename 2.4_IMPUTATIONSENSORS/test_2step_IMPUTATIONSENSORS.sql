
/* (c) 2020 furqan albo jwaid  */
DO $$
DECLARE
	centroids REAL[][];
	null_coordinates INT[][];
	mape REAL;
BEGIN
	call load_sensors(1, '/csv/wine.csv');
	DROP TABLE IF EXISTS a1_complete;
	CREATE TABLE  a1_complete AS TABLE a1;
	
	select add_nulls_to_sensors(1,10) into null_coordinates;
	raise notice 'null_coordinates: %', null_coordinates;
	
	centroids := clasterisation('a1', 14, 3, 2, 0.01);
	raise notice 'Centroids: %', centroids;
	
	call sensors_restoration('a1', centroids);
	
	select get_MAPE('a1_complete', 'a1',null_coordinates) into mape;
	
	raise notice 'MAPE: %', mape;
END ;
$$


/*-------------------- Test Result -------------------------------
NOTICE:  null_coordinates: {{21,2},{18,7},{70,6},{83,12},{161,11},{99,2},{123,1},{114,12},{11,10},{53,11}}
NOTICE:  delta: 0.6742178
NOTICE:  delta: 0.44840455
NOTICE:  delta: 0.7158458
NOTICE:  delta: 0.96449417
NOTICE:  delta: 0.59074664
NOTICE:  delta: 0.17512846
NOTICE:  delta: 0.11064035
NOTICE:  delta: 0.071447104
NOTICE:  delta: 0.047602236
NOTICE:  delta: 0.034048498
NOTICE:  delta: 0.025913298
NOTICE:  delta: 0.02066505
NOTICE:  delta: 0.016899288
NOTICE:  delta: 0.0139372945
NOTICE:  delta: 0.011512697
NOTICE:  delta: 0.0094999075
NOTICE:  Centroids: {{2.2708797,12.546007,2.4229786,2.2869127,20.696627,92.57505,2.0547688,1.7697278,0.3857341,1.4495897,4.176332,0.9441479,2.4845371,464.7065},{1.0115536,13.7987995,1.8699397,2.459756,16.946241,104.88451,2.8322902,2.9918292,0.28915435,1.9198692,5.7877083,1.0789241,3.073345,1223.14},{2.1938703,13.02214,2.6423001,2.4107168,19.680347,103.72452,2.1275423,1.6159757,0.3945537,1.5080502,5.7237625,0.87760067,2.3880644,756.40106}}
NOTICE:  MAPE: 21.473904
DO

*/

/*-------------------- Test Result -------------------------------
NOTICE:  null_coordinates: {{19,6},{129,10},{122,12},{10,5},{5,1},{95,1},{148,13},{178,4},{58,11},{68,2}}
NOTICE:  delta: 0.8857092
NOTICE:  delta: 0.65593314
NOTICE:  delta: 0.90009123
NOTICE:  delta: 0.94044167
NOTICE:  delta: 0.4239145
NOTICE:  delta: 0.13341063
NOTICE:  delta: 0.07294667
NOTICE:  delta: 0.040434957
NOTICE:  delta: 0.023973107
NOTICE:  delta: 0.01660937
NOTICE:  delta: 0.013053238
NOTICE:  delta: 0.01000011
NOTICE:  delta: 0.0075690746
NOTICE:  Centroids: {{2.2628398,12.529398,2.443473,2.278562,20.602966,92.081665,2.0439038,1.7310631,0.3888426,1.4530058,4.062732,0.94645226,2.4575543,458.39716},{2.2468646,12.96988,2.5482285,2.3790858,19.634798,103.50666,2.1160586,1.594334,0.3897324,1.5184218,5.665468,0.8884392,2.380939,735.7876},{1.0166022,13.804445,1.8854078,2.4476166,17.001318,105.54637,2.848484,2.9959686,0.29058987,1.9281181,5.709128,1.0780658,3.080712,1205.2368}}
NOTICE:  MAPE: 15.785496
*/


DO $$
DECLARE
	centroids REAL[][];
	null_coordinates INT[][];
	mape REAL;
BEGIN
	call load_sensors(1, '/csv/wine2.csv');
	DROP TABLE IF EXISTS a1_complete;
	CREATE TABLE  a1_complete AS TABLE a1;
	
	select add_nulls_to_sensors(1,10) into null_coordinates;
	raise notice 'null_coordinates: %', null_coordinates;
	
	centroids := clasterisation('a1', 14, 3, 2, 0.01);
	raise notice 'Centroids: %', centroids;
	
	call sensors_restoration('a1', centroids);
	
	select get_MAPE('a1_complete', 'a1',null_coordinates) into mape;
	
	raise notice 'MAPE: %', mape;
END ;
$$

/*-------------------- Test Result -------------------------------
NOTICE:  null_coordinates: {{43,9},{127,4},{47,6},{85,10},{71,2},{1,3},{11,10},{155,11},{64,10},{68,11}}
NOTICE:  delta: 0.8379406
NOTICE:  delta: 0.86205053
NOTICE:  delta: 0.9525511
NOTICE:  delta: 0.6211355
NOTICE:  delta: 0.20446777
NOTICE:  delta: 0.115510315
NOTICE:  delta: 0.06929362
NOTICE:  delta: 0.04163617
NOTICE:  delta: 0.026436985
NOTICE:  delta: 0.017930508
NOTICE:  delta: 0.012757719
NOTICE:  delta: 0.009351313
NOTICE:  Centroids: {{13.014229,2.588591,2.397041,19.592987,104.324615,2.1710086,1.6707454,0.38517445,1.5377278,5.65321,0.8966144,2.4378865,746.3248,NULL},{12.534653,2.512488,2.300529,20.865822,92.849266,2.0365417,1.7281411,0.39547467,1.4320983,4.1552024,0.94290614,2.449911,461.87622,NULL},{13.780569,1.828186,2.4637847,17.026491,105.13236,2.8536608,3.0100439,0.29646975,1.9060303,5.8800893,1.0843066,3.0326495,1228.7961,NULL}}
NOTICE:  MAPE: 25.021479
DO
*/

/*-------------------- Test Result -------------------------------
NOTICE:  null_coordinates: {{85,4},{22,4},{167,5},{34,11},{34,8},{7,8},{110,9},{129,7},{22,10},{61,12}}
NOTICE:  delta: 0.7651306
NOTICE:  delta: 0.6415069
NOTICE:  delta: 0.94939756
NOTICE:  delta: 0.74133784
NOTICE:  delta: 0.22850376
NOTICE:  delta: 0.101242185
NOTICE:  delta: 0.05744165
NOTICE:  delta: 0.034805894
NOTICE:  delta: 0.022777557
NOTICE:  delta: 0.018911183
NOTICE:  delta: 0.015590727
NOTICE:  delta: 0.012698114
NOTICE:  delta: 0.010286331
NOTICE:  delta: 0.008320212
NOTICE:  Centroids: {{13.785024,1.8809186,2.4475827,16.95745,104.80201,2.872888,3.0478432,0.28417814,1.9360901,5.8406105,1.0766993,3.06093,1214.9187,NULL},{13.021715,2.5657272,2.3770182,19.654057,104.18658,2.1324854,1.615557,0.3877322,1.5227684,5.673969,0.88044953,2.3961272,745.0052,NULL},{12.527163,2.4600344,2.2908354,20.76751,92.462425,2.0716858,1.7720406,0.38982344,1.4342604,4.1807895,0.9485044,2.4776578,460.40323,NULL}}
NOTICE:  MAPE: 25.051783
DO
*/