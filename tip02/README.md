# SQL 3D Engine in ASCII Art style

This directory contains 2 SQL queries which are almost identical.

Both are adaptations for DB2 of an SQL query written by Yaroslav Sergienko. This query is a mini 3D rendering engine, which draws a shape in an ASCII Art style.

Link to the original version of Yaroslav Sergienko :
https://observablehq.com/@pallada-92/sql-3d-engine

One of the 2 queries is an adaptation I wrote for DB2 for LUW, and the other is for DB2 for i.
Why 2 queries ? 
Because I had difficulties to adapt, on DB2 for LUW, the CTE (Common Table Expression) "iters" which is a recursive CTE. This CTE is special because it uses a JOIN between the pseudo table "iters" and another CTE ("rays") .

The version of the CTE "iters" which works fine on DB2 for i :

```SQL
iters (line, col, it, v) AS (
   SELECT line,
         col,
         INTEGER(0) AS it,
         FLOAT(0.0) AS v
   FROM rays
   UNION ALL 
   SELECT rays.line,
        rays.col,
        it + 1 AS it,
        v + MAX(
                ABS(0.7+v*x) - 0.3, 
                ABS(0.7+v*y) - 0.3, 
                ABS(-1.1+v*z) - 0.3, 
                -((0.7+v*x) * (0.7+v*x) + (0.7+v*y) * (0.7+v*y) + (-1.1+v*z) * (-1.1+v*z)) * 1.78 + 0.28
            ) AS v
   FROM iters
   JOIN rays ON rays.line = iters.line
   AND rays.col = iters.col
   WHERE it < 15
),
```

If you test the code above with DB2 for LUW, the SQL engine will return this error message :

```
SQL Error [42836]: The FULLSELECT of the recursive common table expression "ITERS" must be the UNION of two or more FULLSELECT and cannot include a column function, a GROUP BY, HAVING or ORDER BY clause, or an explicit join with an ON clause.. SQLCODE=-345, SQLSTATE=42836, DRIVER=4.31.10
```

On DB2 for LUW, I can't use a JOIN between the CTE "iters" and "rays", so I found a workaround, using a group of scalar subqueries on the CTE "rays". The result is not a pretty code, and it is certainly less efficient than the version for DB2... but it works.
 
Here is the version of the recursive CTE "iters", which works on DB2 for LUW :

```SQL
iters (ROW, col, it, v) AS
  (SELECT row,
          col,
          INTEGER(0) AS it,
          FLOAT(0.0) AS v
   FROM rays
   UNION ALL 
   SELECT row,
        col,
        it + 1 AS it,    
        v + MAX(
           ABS(0.7 + v * (SELECT r.x FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) - 0.3, 
           ABS(0.7 + v * (SELECT r.y FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) - 0.3, 
           ABS(-1.1 + v * (SELECT r.z FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) - 0.3, 
           -((0.7 + v * (SELECT r.x FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) * 
             (0.7 + v * (SELECT r.x FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) + 
             (0.7 + v * (SELECT r.y FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) *
             (0.7 + v * (SELECT r.y FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) + 
             (-1.1 + v * (SELECT r.z FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col)) * 
             (-1.1 + v * (SELECT r.z FROM rays r WHERE r.row = itr.ROW AND r.col = itr.col))) * 1.78 + 0.28 
          ) AS v
   FROM iters itr
   WHERE it < 15
),
```
