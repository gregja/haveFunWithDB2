
-- Original version by Yaroslav Sergienko :
--    https://observablehq.com/@pallada-92/sql-3d-engine
-- Adaptation for DB2 for LUW by Gregory Jarrige

WITH
numbers (n) AS (
  SELECT 0 AS n FROM SYSIBM.sysdummy1 
  UNION ALL 
  SELECT n+1 AS n FROM numbers WHERE n<89
),
pixels AS (
  SELECT rows.n as row, cols.n as col
  FROM numbers as rows 
  CROSS JOIN numbers as cols
  WHERE rows.n > 4 AND rows.n < 40 AND cols.n > 1 AND cols.n < 89
),
rawRays AS (
  SELECT
    row, col,
    FLOAT(-0.9105 + col * 0.0065 + row * 0.0057) as x,
    FLOAT(-0.1315 + row * -0.0171) as y,
    FLOAT(0.6794 + col * 0.0045 + row * -0.0081) as z
  FROM pixels
), 
norms AS
  (SELECT ROW,
          col,
          x,
          y,
          z,
          (1 + x * x + y * y + z * z) / 2.0 AS n
   FROM rawRays
),
rays AS (
  SELECT row, col, x / n AS x, y / n AS y, z / n AS z FROM norms
), 
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
lastIters AS (
   SELECT it0.row,
          it0.col,
          it0.v AS v0,
          it1.v AS v1,
          it2.v AS v2
   FROM iters AS it0
   JOIN iters AS it1 ON it0.col = it1.col AND it0.row = it1.row
   JOIN iters AS it2 ON it0.col = it2.col AND it0.row = it2.row
   WHERE it0.it = 15 
     AND it1.it = 14
     AND it2.it = 13
),
Z AS (
  SELECT ROW AS IY, col AS IX, CASE WHEN (v1 - v2) <> 0 THEN (v0 - v1) / (v1 - v2) ELSE 0.0 END as v FROM lastIters
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
