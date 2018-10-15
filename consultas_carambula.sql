-- 1.Listado general de los Docentes de un Instituto Ordenado por Apellido y Nombre. (Apellido, Nombre)

select ( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido
	     from Personas
	     join Relacion_Docente_Trabaja_Instituto R
	     on  R.foranea_ci_docente = Personas.CI and foranea_id_instituto = 1
	     where Personas.baja = 'f'
	     order by Nombre_y_apellido;
	     
-- Listado general de los Institutos y Escuelas indicando para cada uno cantidad de grupos, 
-- cantidad de estudiantes y cantidad de docentes de cada uno. Ordenado por nombre alfabéticamente
	    
select Institutos.nombre, (
			select count(*)  FROM ( 
				select distinct foranea_ci_alumno 
				from Relacion_Alumno_Asignatura_Grupos where foranea_id_instituto = Institutos.id_instituto) as cnt_alumnos
			) as Cantidad_Alumnos,
			(
			select count(*)  FROM ( 
				select distinct foranea_ci_docente 
				from Relacion_Docente_Trabaja_Instituto where foranea_id_instituto = Institutos.id_instituto) as cnt_docentes
			) as Cantidad_Docentes,
			(
			select count(*)  FROM ( 
				select distinct foranea_id_grupo 
				from Relacion_Grupos_Formado_Asignaturas where foranea_id_instituto = Institutos.id_instituto) as cnt_docentes
			) as Cantidad_Grupos
		from Institutos
        where Institutos.baja = 'f';
	
	
-- 3. Cantidad de Docentes por Materia . Ordenado por cantidad de Docentes de mayor a menor. (Materia, Cantidad)

	select Asignaturas.nombre_asignatura,count(*) as Cantidad_Docentes
		from ( select distinct foranea_ci_docente,foranea_id_asignatura from Relacion_Docente_Asignatura_Grupos ) as docente_asignatura
		join Asignaturas on foranea_id_asignatura = id_asignatura
		where Asignaturas.baja = 'f'
		group by Asignaturas.nombre_asignatura;
	

-- 4. Listado de Docentes para un grupo dado. Ordenado por Materia. ( Materia , Apellido, Nombre )
	
	
select Asignaturas.nombre_asignatura,
	   ( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido
	   from Relacion_Docente_Asignatura_Grupos
	   join Personas on Personas.CI = foranea_ci_docente
	   join Asignaturas on Asignaturas.id_asignatura = foranea_id_asignatura
       where foranea_id_grupo = 4 and Asignaturas.baja = 'f';
      
-- 5.Materias y Grupo que cursa un Estudiante en particular. (Materia, Grupo)

select Asignaturas.nombre_asignatura,Grupos.nombre_grupo
	   from Relacion_Alumno_Asignatura_Grupos
	   join Asignaturas on Asignaturas.id_asignatura = foranea_id_asignatura
	   join Grupos on Grupos.id_grupo = foranea_id_grupo
	   where foranea_ci_alumno = 31814743 and Asignaturas.baja = 'f';

-- 6 Listado de todas las Calificaciones de un Estudiante en particular para una Materia. ( Fecha, Tipo, Calificación )

select fecha, categoria, nota
	   from Calificaciones
	   where ci_alumno = 31814743 and Calificaciones.baja = 'f';

-- 7. Calificación y juicio final de un Estudiante para todas las Materias que cursa. (Materia, Calificación, Juicio)

select Asignaturas.nombre_asignatura as Nombre,nota_final_asignatura,
	( CASE
	    when nota_final_asignatura < 4 then 'Examen_Febrero'
    	when nota_final_asignatura >= 4 and  nota_final_asignatura < 8 then 'Examen_Diciembre'
    	when nota_final_asignatura >= 8 then 'Aprobado'
  		end
  	) as Juicio
	from relacion_alumno_asignatura_grupos
	join Asignaturas on Asignaturas.id_asignatura = foranea_id_asignatura
	where foranea_ci_alumno = 39912206 and Asignaturas.baja = 'f';

	  
-- 8 Calificación final y juicio de todos los Estudiantes de un Grupo para una Materia en
-- particular. Ordenar por Apellido y  por Nombre.
-- (Apellido, Nombre, Calificación, Juicio)

select ( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido,	   
	Asignaturas.nombre_asignatura as Nombre,nota_final_asignatura,
	( CASE
	    when nota_final_asignatura < 4 then 'Examen_Febrero'
    	when nota_final_asignatura >= 4 and  nota_final_asignatura < 8 then 'Examen_Diciembre'
    	when nota_final_asignatura >= 8 then 'Aprobado'
  		end
  	) as Juicio
	from relacion_alumno_asignatura_grupos
	join Asignaturas on Asignaturas.id_asignatura = foranea_id_asignatura
	join Personas on Personas.CI = foranea_ci_alumno
	where foranea_id_asignatura = 57 and foranea_ci_alumno in ( select distinct foranea_ci_alumno
																from relacion_alumno_asignatura_grupos
																where foranea_id_grupo = 4);
																
-- 9. Calificación Final del Proyecto de pasaje de grado para cada Estudiante de un Grupo en
-- particular. ( Apellido, Nombre, Calificación)

select ( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido,
		(
        select  nvl(avg(nota),1)
          from calificaciones
            where  categoria 
             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
              and  CI_alumno = Personas.CI
		) as Nota_Final_Proyecto
		from Personas where Personas.baja = 'f' and Personas.CI in ( select distinct foranea_ci_alumno
																from relacion_alumno_asignatura_grupos
																where foranea_id_grupo = 4);

-- 10. Promedio, máximo, mínimo de calificaciones del Proyecto de pasaje de grado por Instituto
-- Ordenar por promedio de mayor a menor.. (Instituto, Promedio, Máxima, Mínima)

select I.nombre, 
	nvl(( 
	select avg(avg_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as avg_notas
	),1) as Nota_Promedio,
	nvl(( 
	select max(max_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as max_notas
	),1) as Nota_Maxima,
	nvl(( 
	select min(min_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as min_notas
	),1) as Nota_Minima
	from Institutos I
	order by Nota_Promedio DESC;
	
-- 11. Promedio, máximo, mínimo de Calificaciones del Proyecto de pasaje de grado para cada Turno de cada Instituto . 
-- Ordenar por promedio de mayor a menor.. (Instituto, Turno, Promedio, Máxima, Mínima)

select I.nombre, 
	nvl(( 
	select avg(avg_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Vespertino'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as avg_notas
	),1) as Nota_Promedio_Vespertino,
	nvl(( 
	select max(max_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Vespertino'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as max_notas
	),1) as Nota_Maxima_Vespertino,
	nvl(( 
	select min(min_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Vespertino'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as min_notas
	),1) as Nota_Minima_Vespertino,
	nvl(( 
	select avg(avg_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Matutino'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as avg_notas
	),1) as Nota_Promedio_Matutino,
	nvl(( 
	select max(max_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Matutino'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as max_notas
	),1) as Nota_Maxima_Matutino,
	nvl(( 
	select min(min_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Matutino'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as min_notas
	),1) as Nota_Minima_Matutino,
	nvl(( 
	select avg(avg_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Nocturno'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as avg_notas
	),1) as Nota_Promedio_Nocturno,
	nvl(( 
	select max(max_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Nocturno'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as max_notas
	),1) as Nota_Maxima_Nocturno,
	nvl(( 
	select min(min_notas.Nota_Final_Proyecto) from (
	select  distinct ( Personas.primer_nombre || ' ' || 
		     Personas.segundo_nombre || ' ' || 
		     Personas.primer_apellido || ' ' || 
		     Personas.segundo_apellido ) as Nombre_y_apellido,
		     (
	        select  nvl(avg(nota),1)
	          from calificaciones
	            where  categoria 
	             in ('Primera_entrega_proyecto','Segunda_entrega_proyecto','Tercera_entrega_proyecto','Defensa_individual','Defensa_grupal','Es_proyecto') 
	              and  CI_alumno = Personas.CI
			) as Nota_Final_Proyecto,
			Institutos.nombre
			from Personas 
			join Relacion_Alumno_Asignatura_Grupos on foranea_ci_alumno = Personas.CI
			join Institutos on Relacion_Alumno_Asignatura_Grupos.foranea_id_instituto = Institutos.id_instituto and Institutos.id_instituto = I.id_instituto
			join Grupos on Grupos.id_grupo = Relacion_Alumno_Asignatura_Grupos.foranea_id_grupo and Grupos.turno = 'Nocturno'
			where EXISTS ( select * from relacion_alumno_asignatura_grupos where foranea_ci_alumno = Personas.CI )
			and Personas.baja = 'f'
		) as min_notas
	),1) as Nota_Minima_Nocturno
	from Institutos I
	order by Nota_Promedio_Vespertino,Nota_Promedio_Matutino,Nota_Promedio_Nocturno DESC;


-- 12. Estudiante con el mejor promedio de Calificaciones de cada Instituto. Ordenar por promedio de calificaciones de 
-- mayor a menor. (Nombre Completto, Instituto, Turno, Grupo, Promedio )


select distinct tmp.nombre_y_apellido,Institutos.nombre,tmp.Promedio,Grupos.nombre_grupo,Grupos.turno
from 
Institutos
left join (
select  
		Institutos.id_instituto,
		Institutos.nombre,
		Personas.CI,
		( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido,
	     (
	     select avg(nota)
			from Calificaciones
			where Calificaciones.ci_alumno = Personas.CI
	     	) as Promedio
	    from Institutos
	    join Relacion_Alumno_Asiste_Instituto on Relacion_Alumno_Asiste_Instituto.foranea_id_instituto = Institutos.id_instituto 
	    	-- and Relacion_Alumno_Asiste_Instituto.foranea_ci_alumno = Personas.CI 
	    join Personas on Personas.CI = Relacion_Alumno_Asiste_Instituto.foranea_ci_alumno 
	    	and Personas.CI = (
				select ci_alumno from 
					( select first 1 ci_alumno,avg(nota) as Promedio
						from Calificaciones
						where Calificaciones.id_instituto = Institutos.id_instituto
						group by ci_alumno
						order by Promedio desc ) as avg_nota
					)
	  ) as tmp  on tmp.id_instituto = Institutos.id_instituto   
	 left join Personas on Personas.CI = tmp.CI
	 left join relacion_alumno_asignatura_grupos on relacion_alumno_asignatura_grupos.foranea_ci_alumno = Personas.CI
	 left join Grupos on Grupos.id_grupo = relacion_alumno_asignatura_grupos.foranea_id_grupo
	 where Institutos.baja = 'f';
	 order by tmp.Promedio desc;
	
-- 13. Estudiante con el mejor promedio de Calificaciones de cada Grupo de un Instituto en
-- particular. Ordenar por promedio de calificaciones de mayor a menor.
-- (Nombre Completto, Grupo, Turno, Promedio

select sumario_promedios.nombre_instituto,sumario_promedios.nombre_grupo,sumario_personas.turno,max_promedio
from 
(
select nombre_instituto,nombre_grupo,max(promedio) as max_promedio 
from ( 
select Personas.CI,
		( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido,
	     Institutos.nombre as nombre_instituto,
	     Grupos.nombre_grupo,
	     (select avg(nota) from Calificaciones where ci_alumno = Personas.CI) as Promedio
	     from Personas
	     join (select distinct foranea_ci_alumno,foranea_id_grupo,foranea_id_instituto from relacion_alumno_asignatura_grupos) as sumario_ins_grupos
	     on sumario_ins_grupos.foranea_ci_alumno = Personas.CI
	     join Institutos on Institutos.id_instituto = sumario_ins_grupos.foranea_id_instituto
	     join Grupos on Grupos.id_grupo = sumario_ins_grupos.foranea_id_grupo
	     order by Promedio DESC
	    ) as sumario_final
	    group by nombre_instituto,nombre_grupo
	    order by max_promedio   
) as sumario_promedios
join (
select Personas.CI,
		( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido,
	     Institutos.nombre as nombre_instituto,
	     Grupos.nombre_grupo,
	     Grupos.Turno,
	     (select avg(nota) from Calificaciones where ci_alumno = Personas.CI) as Promedio
	     from Personas
	     join (select distinct foranea_ci_alumno,foranea_id_grupo,foranea_id_instituto from relacion_alumno_asignatura_grupos) as sumario_ins_grupos
	     on sumario_ins_grupos.foranea_ci_alumno = Personas.CI
	     join Institutos on Institutos.id_instituto = sumario_ins_grupos.foranea_id_instituto
	     join Grupos on Grupos.id_grupo = sumario_ins_grupos.foranea_id_grupo
		) as sumario_personas 
on sumario_promedios.max_promedio = sumario_personas.Promedio and sumario_promedios.nombre_instituto = sumario_personas.nombre_instituto
and sumario_promedios.nombre_grupo = sumario_personas.nombre_grupo

-- 14. Estudiantes SIN Calificaciones para el Proyecto de pasaje de grado en un Instituto.
-- (Grupo, Datos Estudiante)

select Grupos.nombre_grupo,
	   Personas.CI,
	   ( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido	     
from Personas
join (select distinct foranea_id_grupo,foranea_ci_alumno from relacion_alumno_asignatura_grupos ) as tmp
on tmp.foranea_ci_alumno = Personas.CI
join Grupos on Grupos.id_grupo = tmp.foranea_id_grupo
where tipo = 'Alumno' and Personas.baja = 'f'
and not exists (
	select * from Calificaciones where ci_alumno = Personas.CI 
	and categoria in ( 'Primera_entrega_proyecto',
					   'Segunda_entrega_proyecto',
					   'Tercera_entrega_proyecto',
					   'Defensa_individual', 
					   'Defensa_grupal', 
					   'Es_proyecto'))	  
					   
-- 15. Docentes de un Instituto, indicando la cantidad de grupos/materias que tiene cada uno. (Datos Docente, Cantidad)

select ( Personas.primer_nombre || ' ' || 
	     Personas.segundo_nombre || ' ' || 
	     Personas.primer_apellido || ' ' || 
	     Personas.segundo_apellido ) as Nombre_y_apellido,
	     Personas.grado,
	     (
	     	select count(*)
	     		from ( select distinct foranea_id_asignatura 
	     					from Relacion_Docente_Asignatura_Grupos where
	     					foranea_ci_docente = Personas.CI ) as materias
	     ) as Cantidad_Asignaturas,
	     (
	     	select count(*)
	     		from ( select distinct foranea_id_grupo 
	     					from Relacion_Docente_Asignatura_Grupos where
	     					foranea_ci_docente = Personas.CI ) as materias
	     ) as Cantidad_Grupos
	     from Personas
	     where tipo = 'Docente' and baja = 'f';
	    
	    
-- 16. Institutos en los que se dictan un Curso en particular, indicando la cantidad de grupos.
-- (Nombre, Datos Ubicación, CantidadGrupos)


select Institutos.nombre,
	Orientaciones.nombre_orientacion,
	(
	select count(*) 
		from Grupos 
		where foranea_id_instituto = Institutos.id_instituto and foranea_id_orientacion = 12
	) as Cantidad_Grupos
	from Institutos
	join Orientaciones on Orientaciones.id_orientacion = 12
	where exists (
		select * from Grupos where foranea_id_instituto = Institutos.id_instituto and foranea_id_orientacion = 12 )
		and Institutos.baja = 'f';
		
		
-- 17. Historial de las acciones realizadas por un Usuario en particular. Ordenar cronológicamente.
-- (Fecha, Acción, Datos PC)
		
select * from Historial
	where foranea_CI_Persona = 48914198
	order by fecha_hora;


-- 18. Historial de las acciones realizadas por todos los Usuarios en un período de tiempo
-- determinado. Ordenar cronológicamente. (Fecha, Acción, Datos Usuario, Datos PC)

select * from Historial
	where fecha_hora > TO_DATE('10-28-1986','%m-%d-%Y') and fecha_hora < TO_DATE('01-01-2040','%m-%d-%Y');
	order by fecha_hora;

		