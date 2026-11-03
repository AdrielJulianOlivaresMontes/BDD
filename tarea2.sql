use gestion_escolar;

-- 1. Listar el nombre de la materia con el mayor número de alumnos no aprobados.

with Oferta_total AS (
	select C.id_oferta, count(distinct A.boleta) total_alumno
    from gestion_escolar.cursa C
    join gestion_escolar.alumno A
    on C.id_alumno = A.id_alumno
    where C.calificacion<6
    group by C.id_oferta),    
Maximo AS(
	select max(total_alumno) AS maximo
	from Oferta_total
)    
select  distinct M.clave_materia, M.nombre_materia, OT.total_alumno
from gestion_escolar.materia M
join gestion_escolar.oferta_academica OA
on M.id_materia = OA.id_materia
join Oferta_total OT
on OT.id_oferta = OA.id_oferta
cross join Maximo MA
where OT.total_alumno = MA.maximo;

-- 2 Listar el nombre del profesor que tiene al menos un
-- curso con todos sus alumnos aprobados.    

SELECT distinct P.nombre, M.clave_materia
FROM gestion_escolar.profesor P
JOIN gestion_escolar.oferta_academica OA
    ON P.id_profesor = OA.id_profesor
JOIN gestion_escolar.cursa C
    ON OA.id_oferta = C.id_oferta
JOIN gestion_escolar.materia M
	ON OA.id_materia = M.id_materia
join gestion_escolar.alumno A
	ON A.id_alumno = C.id_alumno
GROUP BY P.numero_empleado, P.nombre,
         OA.id_oferta, M.clave_materia
HAVING COUNT(DISTINCT A.boleta) =
       COUNT(DISTINCT CASE
           WHEN C.calificacion > 5.9 THEN A.boleta
       END);
