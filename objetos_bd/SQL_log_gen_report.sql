--parametros
--La idea es que se cree un dashboard donde se tenga una caja de parametros con Fecha Inicio :date_from/ Fecha Fin :date_to/ Campus :camp
--a partir de los datos captutados se muestran los registros devueltos por la siguiente consulta, reemplazando los valores
--de :date_from :date_to :camp

select guboutp_one_up_no id_proceso, guboutp_date_saved fecha_ejecucion, guboutp_username usuario, gjbprun_value campus
from   guboutp, gjbprun
where  guboutp_job = 'SZPDNRC'
and    guboutp_one_up_no = gjbprun_one_up_no
and gjbprun_number = '03'
and guboutp_file_number = 1
and to_date(guboutp_date_saved,'DD/MM/RRRR') between :date_from and :date_to
and gjbprun_value = nvl2(:camp,:camp,gjbprun_value)
order by 3 desc

--salida
--La idea es que dependiendo del registro que el usuario seleccione en la caja de parámetros
--se filtre la siguiente consulta con el dato id_proceso como parametro :one_up_no obtenido en la anterior consulta
select guroutp_line
from   guroutp
where guroutp_one_up_no = :one_up_no
and guroutp_file_number=1
order by guroutp_seq_no asc;
