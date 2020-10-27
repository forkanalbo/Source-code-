CREATE FUNCTION correlation_threshold(correlation REAL, threshold REAL)
RETURNS BOOLEAN
AS $$
BEGIN
		RETURN abs(correlation)>=threshold;
END ;
$$
LANGUAGE plpgsql;
