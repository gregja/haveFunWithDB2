# draw the Mandelbrot Set in ASCII Art style

This directory contains a SQL query to draw the Mandelbrot Set (in french "Ensemble de Mandelbrot") in ASCII Art style. 
This query works fine with DB2 Express C and DB2 for i. 
I adapted for DB2 a query proposed in the official documentation of PostgreSQL :

https://wiki.postgresql.org/wiki/Mandelbrot_set
(the author of the PostgreSQL request is not credited)

The query contains several CTE (Common Table Expressions), it's a good material, interesting to learn, and it's powerful. 

The adaptation for DB2 was pretty cool, but the ARRAY_AGG function used in the end of the PostgreSQL version doesn't exist on DB2. So I found an alternative solution using the LISTAGG function of DB2. 

The most interesting part of the query is probably the recursive CTE Z. Using a CROSS JOIN in a recursive CTE is not so usual... very interesting stuff.

The shape is in ASCII Art style, so I recommand to use a non-proportional font to display the output correctly.
