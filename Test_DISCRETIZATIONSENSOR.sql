


/* (c) 2020 furqan albo jwaid  */

CREATE TABLE T (
	id serial PRIMARY KEY,
	val real  NOT NULL
);

do $$
declare 
   num integer := 100;
   counter integer := 0;
   N integer := 1;
   Width real := 0;
begin
	/* Generate random values 0-100 */
   while counter < num loop
      
	  counter := counter + 1;
	  insert into sensor (val) values (random() * 100);
   end loop;
   
   
   select count(val) into num from T;
   raise notice 'Number of values: %', num;  
   
   N := 1 + floor(log(2, num));
   raise notice 'N: %', N; 
   
   select (max(val) - min(val))/N into Width from T;
   raise notice 'Width: %', Width; 
   
   counter := 0;
   /* Update values */
   update T set val = floor(val / Width) + 1;
   
end$$;

