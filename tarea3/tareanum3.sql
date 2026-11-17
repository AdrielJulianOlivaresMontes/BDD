use covidHistorico;

select * from dbo.cat_entidades;
select * from dbo.casos_confirmados;

USE covidHistorico;
GO
SELECT * FROM sys.Tables;
GO

-- 1) Listar todos los registros con datos de personas fallecidas


-- solucion 1
SELECT *
FROM dbo.datoscovid
WHERE NOT (FECHA_DEF = '9999-99-99'
           OR FECHA_DEF IS NULL);
  -- solucion 2
SELECT DISTINCT *
FROM dbo.datoscovid
WHERE FECHA_DEF IS NOT NULL
  AND FECHA_DEF <> '9999-99-99';

-- 2) Listar que estado tiene la mayor cantidad de casos confirmados  por estudios de laboratorio
-- solucion 1

SELECT TOP 1
    E.entidad AS ESTADO,
    COUNT(*) AS TOTAL_CASOS
FROM dbo.datoscovid D
INNER JOIN dbo.cat_entidades E
    ON TRY_CONVERT(INT, D.ENTIDAD_RES) =
       TRY_CONVERT(INT, E.clave)
WHERE D.RESULTADO_LAB = 1
GROUP BY E.entidad
ORDER BY TOTAL_CASOS DESC;



-- 3) Listar el mes con mayor  /  menor numero de casos por estado para el año 2020
WITH casos_mes AS (
    SELECT ce.entidad,
           MONTH(c.FECHA_SINTOMAS) AS mes,
           COUNT(*) AS casos
    FROM covidHistorico.dbo.cp_covid_completa c
    JOIN covidHistorico.dbo.cat_entidades ce
         ON ce.clave = c.ENTIDAD_RES
    WHERE YEAR(c.FECHA_SINTOMAS) = 2020
      AND c.CLASIFICACION_FINAL IN (1,2,3)
    GROUP BY ce.entidad, MONTH(c.FECHA_SINTOMAS)
),
rankeado AS (
    SELECT entidad, mes, casos,
           ROW_NUMBER() OVER (PARTITION BY entidad ORDER BY casos DESC) AS rn_max,
           ROW_NUMBER() OVER (PARTITION BY entidad ORDER BY casos ASC ) AS rn_min
    FROM casos_mes
)
SELECT entidad, mes, casos, 'MÁS CASOS'   AS tipo FROM rankeado WHERE rn_max = 1
UNION ALL
SELECT entidad, mes, casos, 'MENOS CASOS' AS tipo FROM rankeado WHERE rn_min = 1
ORDER BY entidad, tipo;