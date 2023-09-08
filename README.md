# haveFunWithDB2
This project proposes some SQL tips and techniques to have fun with the DB2 databases.
Some tehchiques have been tested on different versions of DB2, principally :
- DB2 Express C (free version of DB2 LUW), version 11.1 minimum
- DB2 for i (embedded version in IBM i servers), V7R2 minimum

NB : DB2, DB2 Express C, DB2 for i, DB2 for Z/OS are trademarks of the IBM Company.

Sometimes, there are some small differences of implementation between the different versions of DB2, differences that require adaptations of the SQL code.
I try to identify them and report them when this happens.

In the mandelbrot directory, you'll find a SQL query to draw the Mandelbrot Set (in french "Ensemble de Mandelbrot"). 
This query works fine with DB2 Express C and DB2 for i. I adapted for DB2 a query proposed in the official documentation of PostgreSQL. 
This query contains several CTE (Common Table Expressions), it's a very good stuff, very interesting to learn and very powerful. 


