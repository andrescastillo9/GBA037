CREATE OR REPLACE PACKAGE            "TZKPRFA" AS
  -- Function and procedure implementations

  /**********************************************************************/
  FUNCTION F_ValidateValue( a_Value    IN VARCHAR2,
                            a_Column     IN VARCHAR2,
                            a_Table      IN VARCHAR2,
                            a_Conditions IN VARCHAR2 DEFAULT NULL
                          ) RETURN VARCHAR2 ;	

	-- Cursor que recupera los estudiantes de una seleccion de poblacion
  PROCEDURE p_cancel_prefac_mduu;
end TZKPRFA;


/


CREATE OR REPLACE PACKAGE BODY            "TZKPRFA" is
  -- Function and procedure implementations
  
FUNCTION F_ValidateValue( a_Value    IN VARCHAR2,
                            a_Column     IN VARCHAR2,
                            a_Table      IN VARCHAR2,
                            a_Conditions IN VARCHAR2 DEFAULT NULL
                          ) RETURN VARCHAR2 AS

    TYPE CursorType IS REF CURSOR;
    vDynCursor CursorType;

    v_SQLCmd VARCHAR2(4000);

    v_Result VARCHAR2(1);

  BEGIN
    v_SQLCmd := 'SELECT ''Y'' FROM ' || a_Table || ' WHERE ' || a_Column || ' = ''' || a_Value || '''';
    IF a_Conditions IS NOT NULL THEN
      v_SQLCmd := v_SQLCmd || ' AND ' || a_Conditions;
    END IF;

    OPEN vDynCursor FOR v_SQLCmd;
    FETCH vDynCursor
     INTO v_Result;
    IF vDynCursor%NOTFOUND THEN
      v_Result := 'N';
    END IF;
    CLOSE vDynCursor;

    RETURN v_Result;
  END F_ValidateValue;

PROCEDURE p_cancel_prefac_mduu IS

	 --cursor que devuelvee datos para cancelar prefactura
	 cursor cur_dat_prefact (p_pidm number, p_term varchar2, lv_proc number) is
	 select  distinct tzrfact_pidm, tzrfact_sdoc_code, tzrfact_doc_number, tzrfact_curr_program,tzrfact_user 
		from tzrfact 
		where tzrfact_term_code  = nvl(p_term,tzrfact_term_code)
		and tzrfact_pidm = nvl(p_pidm,tzrfact_pidm)
		and exists (select 'y' from tvbsdoc where tvbsdoc_doc_number = tzrfact_doc_number and tvbsdoc_pidm = tzrfact_pidm and tvbsdoc_doc_cancel_ind is null) 
		and tzrfact_doc_number in (select fact.tzrfact_doc_number
                                   from tzrfact fact
                                   where fact.tzrfact_doc_number=tzrfact_doc_number
                                   and   fact.tzrfact_term_code=tzrfact_term_code
                                   group by fact.tzrfact_doc_number
                                   having sum(TZRFACT_AMNT_TRANS)=0
                                  )
        and tzrfact_doc_number in (select dprf.tzrdprf_doc_number
                                   from tzrdprf dprf
                                   where dprf.tzrdprf_doc_number=tzrfact_doc_number
                                   and   dprf.tzrdprf_term_code=tzrfact_term_code
                                   and   dprf.tzrdprf_doc_status not in ('ANULADA','ACEPTADO')
                                   and   (dprf.tzrdprf_doc_amount is null or dprf.tzrdprf_doc_amount = 0)
                                  )
		and tzrfact_pidm in (select distinct sfrstcr_pidm from aud_sfrstcr where proceso = lv_proc)
        and tzrfact_sri_docnum is null;


-- Variables  
  lv_err_msg          VARCHAR2(200);
  lv_flag             NUMBER(8) := 0;

  p_error_ind            varchar2(3);
  p_error_msg            varchar2(2000);
  lv_student_id		  SPRIDEN.SPRIDEN_ID%TYPE;
  lv_term_code        SFBETRM.SFBETRM_TERM_CODE%TYPE;
  lv_pidm             SGRCHRT.SGRCHRT_PIDM%TYPE;
  lv_proc             NUMBER;

  BEGIN

     GKKPSQL.API_RETRIEVERULESETPARAMETER ('001_1_TERM_CODE', lv_term_code, lv_err_msg);
     GKKPSQL.API_RETRIEVERULESETPARAMETER ('001_2_STUDENT_ID', lv_student_id, lv_err_msg);
     GKKPSQL.API_RETRIEVERULESETPARAMETER ('001_3_PROC_ID', lv_proc, lv_err_msg);

		--Por id_estudiante
		IF (lv_student_id IS NOT NULL) THEN
			GKKPSQL.WRITEDIAGNOSTICTODB(40,'Ejecucion por Id en TZKPRFA  ' || lv_student_id );
			BEGIN
				SELECT GB_COMMON.F_GET_PIDM(lv_student_id) INTO lv_pidm FROM DUAL;
			EXCEPTION 
					WHEN NO_DATA_FOUND THEN 
						GKKPSQL.WRITEDIAGNOSTICTODB(40,'ID de Estudiante no encontrado:'|| lv_student_id);
						lv_flag := lv_flag + 1;
			END;
		ELSE
				GKKPSQL.WRITEDIAGNOSTICTODB(40,'ID is null. Ejecucion para todos los Id en TZKPRFA  ' || lv_student_id );
        END IF; 

		IF (lv_term_code IS NOT NULL) THEN
         IF F_ValidateValue( lv_term_code, 'STVTERM_CODE', 'STVTERM') = 'N' THEN
            GKKPSQL.WRITEDIAGNOSTICTODB(40, 'No existe el periodo acad.: '|| lv_term_code);
            lv_flag := lv_flag + 1;
         END IF;
		ELSE
		      GKKPSQL.WRITEDIAGNOSTICTODB(40, 'Term is null. Debe ingresar un periodo: '|| lv_term_code);
              lv_flag := lv_flag + 1;
        END IF;		
		IF (lv_proc IS NOT NULL) THEN
         IF F_ValidateValue( lv_proc, 'PROCESO', 'AUD_SFRSTCR') = 'N' THEN
            GKKPSQL.WRITEDIAGNOSTICTODB(40, 'No existe el proceso: '|| lv_proc);            
         END IF;
		ELSE
		      GKKPSQL.WRITEDIAGNOSTICTODB(40, 'Proceso is null. Debe ingresar un numero de proceso ejecutado: '|| lv_proc);
			  lv_flag := lv_flag + 1;
		END IF;			
                  IF lv_flag = 0 THEN																	
					IF 	lv_student_id IS NULL THEN
					lv_pidm := NULL;
					ELSE
					lv_pidm := gb_common.f_get_pidm(lv_student_id);
					END IF;

					FOR rec_tzrfact in cur_dat_prefact(lv_pidm,lv_term_code,lv_proc) 
					LOOP
						begin
							GKKPSQL.WRITEDIAGNOSTICTODB(40,'Anular prefactura:'|| rec_tzrfact.tzrfact_doc_number||
												   ' ID '||rec_tzrfact.tzrfact_pidm
										);
								baninst1.tzkpufc.p_cancel_sales_doc(
									p_pidm => rec_tzrfact.tzrfact_pidm,
									p_sdoc_code => rec_tzrfact.tzrfact_sdoc_code,
									p_doc_num => rec_tzrfact.tzrfact_doc_number,
									p_data_origin => 'script', -- valor para identificar el origen de la cancelaciÃ³n.
									p_user_id => 'usrprefact', -- puede quedarse Ã©ste valor
									p_error_ind => p_error_ind, -- variable de salida
									p_error_msg => p_error_msg -- variable de salida
								  );
								  GKKPSQL.WRITEDIAGNOSTICTODB(40,' Error: '|| p_error_ind ||' '|| p_error_msg
										);

									update tzrdprf
									   set tzrdprf_doc_status = 'ANULADA',
										   tzrdprf_user_id = user,
										   tzrdprf_activity_date = sysdate
									 where     tzrdprf_pidm = rec_tzrfact.tzrfact_pidm
										   and tzrdprf_sdoc_code = rec_tzrfact.tzrfact_sdoc_code
										   and tzrdprf_doc_number = rec_tzrfact.tzrfact_doc_number;

								    update tzrfact
									   set tzrfact_pref_cancel_ind = 'Y',
										   tzrfact_user = user,
										   tzrfact_activity_date = sysdate
									 where     tzrfact_pidm = rec_tzrfact.tzrfact_pidm
										   and tzrfact_sdoc_code = rec_tzrfact.tzrfact_sdoc_code
										   and tzrfact_doc_number = rec_tzrfact.tzrfact_doc_number;
								  commit;

							EXCEPTION WHEN OTHERS THEN
							GKKPSQL.WRITEDIAGNOSTICTODB(40,'Error al Anular prefactura:'|| rec_tzrfact.tzrfact_doc_number||
														   ' ID '||rec_tzrfact.tzrfact_pidm ||
														   ' Error: '|| p_error_ind ||' '|| p_error_msg||' '||sqlerrm
											);
						End;
					END LOOP;
					ELSE
						GKKPSQL.WRITEDIAGNOSTICTODB(40,'Error al validar parametros, no se ejecuta proceso:'||
														   ' ID '||lv_student_id ||
														   ' Error: '|| p_error_ind ||' '|| p_error_msg||' '||sqlerrm
											);
                  END IF;        
        --END IF;      
	END p_cancel_prefac_mduu;

--begin
   --Initialization
  --null;
end TZKPRFA;



/
