
-- Original version by Yaroslav Sergienko :
--    https://observablehq.com/@pallada-92/sql-3d-engine
-- Adaptation for DB2 for i by Gregory Jarrige

WITH
numbers (n) AS (
  SELECT 0 AS n FROM SYSIBM.sysdummy1 
  UNION ALL 
  SELECT n+1 AS n FROM numbers WHERE n<89
),
pixels AS (
  SELECT lines.n as line, cols.n as col
  FROM numbers as lines 
  CROSS JOIN numbers as cols
  WHERE lines.n > 4 AND lines.n < 40 AND cols.n > 1 AND cols.n < 89
),
rawRays AS (
    SELECT px.line, px.col,
        FLOAT(-0.9105 + px.col * 0.0065 + px.line * 0.0057) as x,
        FLOAT(-0.1315 + px.line * -0.0171) as y,
        FLOAT(0.6794 + px.col * 0.0045 + px.line * -0.0081) as z
    FROM pixels px
), 
norms AS (
   SELECT ry.line,
          ry.col,
          ry.x,
          ry.y,
          ry.z,
          ((1 + ry.x * ry.x + ry.y * ry.y + ry.z * ry.z) / 2.0) AS n
   FROM rawRays ry
),
rays AS (
   SELECT nm.line, nm.col, FLOAT(x / n) AS x, FLOAT(y / n) AS y, FLOAT(z / n) AS z FROM norms nm
), 
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
lastIters AS (
   SELECT it0.line,
          it0.col,
          it0.v AS v0,
          it1.v AS v1,
          it2.v AS v2
   FROM iters AS it0
   JOIN iters AS it1 ON it0.col = it1.col AND it0.line = it1.line
   JOIN iters AS it2 ON it0.col = it2.col AND it0.line = it2.line
   WHERE it0.it = 15 
     AND it1.it = 14
     AND it2.it = 13
),
Z AS (
  SELECT li.line AS IY, col AS IX, CASE WHEN (v1 - v2) <> 0 THEN (v0 - v1) / (v1 - v2) ELSE 0.0 END as v FROM lastIters li
),
shapes(NI, CONTENT) AS (
  SELECT 1 AS NI, CHAR('$') AS CONTENT FROM SYSIBM.SYSDUMMY1
  UNION ALL
  SELECT NI+1 as NI, SUBSTR('@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/|()1{}[]?-_+~<>i!lI;:,"^. ', NI, 1) AS CONTENT  
    FROM shapes WHERE NI < 66
),
Zt AS (
    SELECT Ix, Iy, 
       COALESCE ((SELECT content FROM shapes WHERE ni = INTEGER( round(1 + MAX(0, MIN(66, Z.v * 67))))), ' ') AS I  
    FROM Z
),
finale AS (
	SELECT IY, LISTAGG(I, '') WITHIN GROUP(ORDER BY IX) AS image
	FROM Zt
	GROUP BY IY
)
SELECT image FROM finale
;


