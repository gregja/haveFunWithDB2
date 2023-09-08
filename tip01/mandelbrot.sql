-- original version : https://wiki.postgresql.org/wiki/Mandelbrot_set
-- adapted for DB2 by Gregory Jarrige
-- this query works fine with DB2 Express C and DB2 for i

WITH 
x(i) AS (
	    SELECT 0 AS i FROM SYSIBM.SYSDUMMY1
	UNION ALL
	    SELECT i + 1 AS i FROM x WHERE i < 101
	),
Z(Ix, Iy, Cx, Cy, X, Y, I) AS (
    SELECT Ix, Iy, X, Y, X, Y, 0
    FROM
        (SELECT -2.2 + 0.031 * i, i FROM x) AS xgen(x,ix)
    CROSS JOIN
        (SELECT -1.5 + 0.031 * i, i FROM x) AS ygen(y,iy)
    UNION ALL
    SELECT Ix, Iy, Cx, Cy, X * X - Y * Y + Cx AS X, Y * X * 2 + Cy, I + 1
    FROM Z
    WHERE X * X + Y * Y < 16.0
    AND I < 27
),
iters(NI, CONTENT) AS (
  SELECT 1 AS NI, ' ' AS CONTENT FROM SYSIBM.SYSDUMMY1
  UNION ALL
  SELECT NI+1 as NI, SUBSTR('.,,,-----++++%%%%@@@@#### ', NI, 1) AS CONTENT  
    FROM iters WHERE NI < 27
),
Zt (Ix, Iy, I) AS (
    SELECT Ix, Iy, 
       (SELECT content FROM iters WHERE ni = MAX(I)) CONCAT 
       -- because the characters have a rectangular shape, we double them to get a better rendering
       (SELECT content FROM iters WHERE ni = MAX(I)) AS I 
    FROM Z
    GROUP BY Iy, Ix
    ORDER BY Iy, Ix
),
finale AS (
	SELECT IY, LISTAGG(I, '') AS fractal
	FROM Zt
	GROUP BY IY
)
SELECT fractal FROM finale
;
