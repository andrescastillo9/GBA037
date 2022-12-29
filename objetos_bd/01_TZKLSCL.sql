CREATE OR REPLACE PACKAGE                     "TZKLSCL" is

  -- Author  : MARIO
  -- Created : 7/01/2020 8:45:11 a. m.
  -- Purpose : Paquete encargado de establecer la funcionalidad de Depuración de listas de clase
  const_application_name     CONSTANT VARCHAR2 (32) := 'SZPDNRC'; -- nombre del PRO-C
  const_package_name         CONSTANT VARCHAR2 (32) := 'TZKLSCL';



  PROCEDURE p_main (p_one_up_no IN NUMBER, p_user_id IN VARCHAR2);
FUNCTION f_obtener_tipo_alumno( p_term varchar2, 
								  p_camp varchar2,
								  p_program varchar2,
								  p_pidm number) 
  RETURN VARCHAR2;
  PROCEDURE p_AplicaTZPPFAC(p_term        IN VARCHAR2,
												p_id 		  in varchar2,
												p_sdoc_code   in varchar2,
												p_site_code   in varchar2,
												p_update_mode IN VARCHAR2,
												Output        OUT VARCHAR2);
  function f_valid_course_pospay(
    p_pidm number, 
    p_term varchar2,
    p_pay_date date
  ) return varchar;

 PROCEDURE p_Aplica_MDUU_BENEFICIOS (p_term number, p_id_student varchar2);
 function f_debe_pidm_accd (
    p_pidm number, 
    p_term varchar2	

  ) return varchar;
 function f_debe_pidm_accd_term (
    p_pidm number, 
    p_term varchar2	

  ) return varchar;
 function f_debe_pidm_term (
    p_pidm number, 
    p_term varchar2,
    p_camp varchar2	
  ) return varchar;

   function f_valid_matcurso_pidm (
    p_pidm number, 
    p_term varchar2,
    p_stsp number,
    p_pay_date date,
    p_subj_code varchar2,
    p_crse_numb varchar2

  ) return varchar; 
 function f_pay_pidm_term (
    p_pidm number, p_term varchar2, p_camp varchar2     
  ) return date;

 function f_verificar_materia(P_SUBJ_CODE varchar2,
                               P_CRSE_NUMB varchar2,
                               p_pidm      number) return number;
  --function f_execute_lc2(p_term       number,
                         --p_camp       VARCHAR2,
                         --p_student_id varchar2,
                         --p_tipo_estudiante varchar2 default 'NUEVO') return number ;

  --procedure p_execute_lc(p_term number,p_camp VARCHAR2,p_student_id varchar2 default null,p_tipo_alumno  varchar2);
  function f_valid_nrc_tckn (
    p_pidm number, 
    p_term varchar2,
    p_crn varchar2

  ) return varchar;
  procedure p_del_nrc_pidm(                        
                      par_term varchar2,
                      par_pidm number,  
                      par_stsp number,
                      par_usr  varchar2,
                      par_pro  number,
                      p_seq_no number);                      

procedure p_restore_process(p_proc number);
procedure p_restore_process_nrc(p_proc number,p_nrc varchar2);
procedure p_restore_process_pidm(p_proc number,p_pidm number);
procedure p_restore_process_pidm_nrc(p_proc number,p_pidm number,p_nrc varchar2);
procedure report_process(v_proc number);
end TZKLSCL;







/


CREATE OR REPLACE PACKAGE BODY                     "TZKLSCL" is

  -- Author  : MARIO
  -- Created : 7/01/2020 8:45:11 a. m.
  -- Purpose : Paquete encargado de establecer la funcionalidad de Depuración de listas de clase
  -- update 05 2020:  Andres Castillo se modifica y ajusta borrado parcial y total
  -- update 05 2020: Se modiifca funcion de calculo tipo de alumno
  v_nuevo   varchar2(20) := 'NUEVO';
  v_antiguo varchar2(20) := 'ANTIGUO';
  p_term    varchar2(6);   
  p_camp    varchar2(3);   
  p_student_id varchar2(20);   
  p_tipo_alumno varchar2(10);   

  procedure p_insert_log(id        varchar2,
                         v_paso    number,
                         v_desc    varchar2,
                         v_sqlerrm varchar2) is
    PRAGMA autonomous_transaction;
  begin
     insert into SATURN.iztprlc_log
       (iztprlc_id, iztprlc_log_obslog)
     values
       (id, v_paso || ' - ' ||TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS')||'-'||v_desc || ' - ' || v_sqlerrm);
     gb_common.p_commit;
  end; 

  procedure p_insert_log_bit(id        varchar2,
                         v_paso    number,
                         v_desc    varchar2,
                         v_sqlerrm varchar2) is
    PRAGMA autonomous_transaction;
    v_row_print         varchar2 (1000);
    v_page_width        number;
    v_status            varchar2 (10);
    v_comments          varchar2 (20000):='';
  begin
        v_page_width := gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

            v_row_print :=
                gz_report.f_colum_format (v_paso || ' - ' ||TO_CHAR(sysdate, 'HH24:MI:SS')||'-'||v_desc || ' - ' || nvl(v_sqlerrm,''),
											  70,
											  'LEFT',
											  ' | ');

          gz_report.p_put_line (p_one_up_no       => id,
                                p_user            => USER,
                                p_job_name        => const_application_name,
                                p_file_number     => 1,  --NVL (v_file_number, 1),
                                p_content_line    => v_row_print,
                                p_content_width   => v_page_width,
                                p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                                p_status          => v_status,
                                p_comments        => v_comments);
     gb_common.p_commit;
  end; 

  procedure p_delete_log is
    PRAGMA autonomous_transaction;
  begin
    delete SATURN.iztprlc_log;
    commit;
  end;

 FUNCTION f_obtener_tipo_alumno( p_term varchar2, 
								  p_camp varchar2,
								  p_program varchar2,
								  p_pidm number) 
  RETURN VARCHAR2 IS	  
	  v_tipo_alumno varchar2(20) := '';
  BEGIN
    begin
		select 'NUEVO'
		INTO v_tipo_alumno
		from SARADAP,
		 (select SARAPPD_PIDM,
				 SARAPPD_TERM_CODE_ENTRY,
				 SARAPPD_APPL_NO,
				 SARAPPD_APDC_CODE
			from SARAPPD,
				 (SELECT SARAPPD_PIDM PIDM,
						 MAX(SARAPPD_APDC_CODE) TERM1
					FROM SARAPPD
				   GROUP BY SARAPPD_PIDM) MS_PER
		   where 1 = 1
			 and SARAPPD_PIDM = MS_PER.PIDM
			 AND SARAPPD_APDC_CODE = MS_PER.TERM1
		  --and SARAPPD_PIDM = '360165'
		   group by SARAPPD_PIDM,
					SARAPPD_TERM_CODE_ENTRY,
					SARAPPD_APPL_NO,
					SARAPPD_APDC_CODE) DECIS,
		 --SMRPRLE,
		 SPRIDEN,
		 STVAPDC
	    WHERE 1 = 1
		 AND SARADAP_PIDM = DECIS.SARAPPD_PIDM
		 AND SARADAP_TERM_CODE_ENTRY = DECIS.SARAPPD_TERM_CODE_ENTRY
		 AND SARADAP_APPL_NO = DECIS.SARAPPD_APPL_NO
		 AND DECIS.SARAPPD_APDC_CODE = '35' ---35  (
		 --AND SARADAP_PROGRAM_1 = SMRPRLE_PROGRAM
		 AND SARADAP_PIDM = SPRIDEN_PIDM
		 AND SARAPPD_APDC_CODE = STVAPDC_CODE
		 AND SARADAP_TERM_CODE_ENTRY = p_term
		 AND SARADAP_CAMP_CODE = p_camp
		 --AND SMRPRLE_PROGRAM = p_program
		 AND SARADAP_PIDM = p_pidm
		 AND ROWNUM < 2;

		--RETURN v_tipo_alumno;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_tipo_alumno := 'ANTIGUO';
		END;	
		RETURN v_tipo_alumno;    
  END;

  function f_verificar_materia(P_SUBJ_CODE varchar2,
                               P_CRSE_NUMB varchar2,
                               p_pidm      number) return number is
    v_cant number;
  begin
    begin
      SELECT count(0)
        into v_cant
        FROM sfrstcr, ssbsect, scbcrse
       WHERE --sfrstcr_term_code = '202061'
      --AND 
       sfrstcr_pidm = p_pidm
       AND ssbsect_term_code = sfrstcr_term_code
       AND ssbsect_crn = sfrstcr_crn
      /*   AND EXISTS
      (SELECT 1
         FROM stvrsts
        WHERE     stvrsts_code = sfrstcr_rsts_code
              AND stvrsts_incl_sect_enrl = 'Y')*/
       AND ssbsect_subj_code = scbcrse_subj_code
       AND ssbsect_crse_numb = scbcrse_crse_numb
       AND SSBSECT_SUBJ_CODE = P_SUBJ_CODE
       AND ssbsect_crse_numb = P_CRSE_NUMB
       AND scbcrse_eff_term =
       (SELECT MAX(crse.scbcrse_eff_term)
          FROM scbcrse crse
         WHERE scbcrse.scbcrse_subj_code = crse.scbcrse_subj_code
           AND scbcrse.scbcrse_crse_numb = crse.scbcrse_crse_numb
           AND crse.scbcrse_eff_term <= ssbsect_term_code)
       group by SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB;
      return v_cant;
    exception
      when no_data_found then
        return 0;
    end;
    return v_cant;
  end;

  function f_obtener_creditos_maximos(p_term varchar2, p_pidm number)
    return number is
    v_credit number;
  begin
    begin
      SELECT max(SFRSTCR_CREDIT_HR)
        into v_credit
        FROM sfrstcr, ssbsect, scbcrse
       WHERE to_number(sfrstcr_term_code) < to_number(p_term)
         AND sfrstcr_pidm = p_pidm
         AND ssbsect_term_code = sfrstcr_term_code
         AND ssbsect_crn = sfrstcr_crn
         AND EXISTS
       (SELECT 1
                FROM stvrsts
               WHERE stvrsts_code = sfrstcr_rsts_code
                 AND stvrsts_incl_sect_enrl = 'Y')
         AND ssbsect_subj_code = scbcrse_subj_code
         AND ssbsect_crse_numb = scbcrse_crse_numb
            --    AND SSBSECT_SUBJ_CODE = P_SUBJ_CODE
            --   AND ssbsect_crse_numb = P_CRSE_NUMB
         AND scbcrse_eff_term =
             (SELECT MAX(crse.scbcrse_eff_term)
                FROM scbcrse crse
               WHERE scbcrse.scbcrse_subj_code = crse.scbcrse_subj_code
                 AND scbcrse.scbcrse_crse_numb = crse.scbcrse_crse_numb
                 AND crse.scbcrse_eff_term <= ssbsect_term_code)
       group by SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB;
      return v_credit;
    exception
      when no_data_found then
        return 0;
    end;
    return v_credit;
  end;


  procedure p_del_nrc_pidm( 
                      par_term varchar2,
                      par_pidm number,  
                      par_stsp number,
                      par_usr  varchar2,
                      par_pro  number,
                      p_seq_no number) is

       cursor nrc_pidm_term(v_term varchar2, v_pidm number, v_stsp varchar2) is

        SELECT
            sfrstcr_crn,
            sfrstcr_term_code,
            sfrstcr_pidm

        FROM
            sfrstcr,
            stvrsts
        WHERE
            sfrstcr_term_code = v_term
            AND sfrstcr_stsp_key_sequence = v_stsp
            AND sfrstcr_pidm = v_pidm
            AND sfrstcr_rsts_code <> 'DD'
            AND stvrsts_code = sfrstcr_rsts_code
            AND stvrsts_incl_sect_enrl = 'Y';

CURSOR GET_SOBTERM_IND(lx_term  STVTERM.STVTERM_CODE%TYPE ) IS
       SELECT 'N',--SOBTERM_DUPL_SEVERITY,
              'N',--SOBTERM_TIME_SEVERITY,
              'N',--SOBTERM_CORQ_SEVERITY,
              'N',--SOBTERM_LINK_SEVERITY,
              'N',--SOBTERM_PREQ_SEVERITY,
              'N',--SOBTERM_MAXH_SEVERITY,
              'N',--SOBTERM_MINH_SEVERITY,
              'N',--SOBTERM_MEXC_SEVERITY,
              'N',--SOBTERM_TIME_SEVERITY,
              'N',--SOBTERM_APPR_SEVERITY,
              'N',--SOBTERM_CAPC_SEVERITY,
              'N',--SOBTERM_MAJR_SEVERITY,
              'N',--SOBTERM_DEPT_SEVERITY,
              'N',--SOBTERM_COLL_SEVERITY,
              'N',--SOBTERM_LEVL_SEVERITY,
              'N',--SOBTERM_CLAS_SEVERITY,
              'N',--SOBTERM_RPTH_SEVERITY,
              'N',
              --SOBTERM_HOLD_SEVERITY,
              'N',--SOBTERM_REPT_SEVERITY,
              'N',--SOBTERM_CAMP_SEVERITY,
              'N',--SOBTERM_DEGREE_SEVERITY,
              'N',--SOBTERM_PROGRAM_SEVERITY,
              'N',--SOBTERM_ATTS_SEVERITY,
              'N'--SOBTERM_CHRT_SEVERITY
         FROM SOBTERM
      WHERE SOBTERM_TERM_CODE = lx_term;

  --Variables
  dupl_severity_in    sobterm.sobterm_dupl_severity%TYPE;
  corq_severity_in    sobterm.sobterm_corq_severity%TYPE;
  link_severity_in    sobterm.sobterm_link_severity%TYPE;
  preq_severity_in    sobterm.sobterm_preq_severity%TYPE;
  maxh_severity_in    sobterm.sobterm_maxh_severity%TYPE;
  minh_severity_in    sobterm.sobterm_minh_severity%TYPE;
  mexc_severity_in    sobterm.sobterm_mexc_severity%TYPE;
  time_severity_in    sobterm.sobterm_time_severity%TYPE;
  appr_severity_in    sobterm.sobterm_appr_severity%TYPE;
  capc_severity_in    sobterm.sobterm_capc_severity%TYPE;
  majr_severity_in    sobterm.sobterm_majr_severity%TYPE;
  dept_severity_in    sobterm.sobterm_dept_severity%TYPE;
  coll_severity_in    sobterm.sobterm_coll_severity%TYPE;
  levl_severity_in    sobterm.sobterm_levl_severity%TYPE;
  clas_severity_in    sobterm.sobterm_clas_severity%TYPE;
  rpth_severity_in    sobterm.sobterm_rpth_severity%TYPE;
  hold_severity_in    sobterm.sobterm_hold_severity%TYPE;
  rept_severity_in    sobterm.sobterm_rept_severity%TYPE;
  camp_severity_in    sobterm.sobterm_camp_severity%TYPE;
  degree_severity_in  sobterm.sobterm_degree_severity%TYPE;
  program_severity_in sobterm.sobterm_program_severity%TYPE;
  atts_severity_in    sobterm.sobterm_atts_severity%TYPE;
  chrt_severity_in    sobterm.sobterm_chrt_severity%TYPE;
  mhrs_over_in        sfbetrm.sfbetrm_mhrs_over%TYPE;
  min_hrs_in          sfbetrm.sfbetrm_min_hrs%TYPE;
  sessionid_in        sfrcolr.sfrcolr_sessionid%TYPE;
  system_in           VARCHAR2(1);
  reg_err_msg         VARCHAR2(4000) := '';
  reg_update_allowed  VARCHAR2(1)    := '';
  reg_msg             VARCHAR2(4000) := '';
  reg_out             VARCHAR2(4000) := '';

  v_save_act_date_out    varchar2(400);
  v_return_status_in_out varchar2(400);
  v_valida_nrc_tckn VARCHAR2(3);

  begin

  OPEN GET_SOBTERM_IND(par_term);
          FETCH GET_SOBTERM_IND INTO dupl_severity_in,
                                     time_severity_in,
                                     corq_severity_in,
                                     link_severity_in,
                                     preq_severity_in,
                                     maxh_severity_in,
                                     minh_severity_in,
                                     mexc_severity_in,
                                     time_severity_in,
                                     appr_severity_in,
                                     capc_severity_in,
                                     majr_severity_in,
                                     dept_severity_in,
                                     coll_severity_in,
                                     levl_severity_in,
                                     clas_severity_in,
                                     rpth_severity_in,
                                     hold_severity_in,
                                     rept_severity_in,
                                     camp_severity_in,
                                     degree_severity_in,
                                     program_severity_in,
                                     atts_severity_in,
                                     chrt_severity_in;
          CLOSE GET_SOBTERM_IND;

    for rec_data_nrc in nrc_pidm_term(par_term, par_pidm, par_stsp) loop
        begin
            --validar nrc en historia
            v_valida_nrc_tckn := 'Y';

            v_valida_nrc_tckn := f_valid_nrc_tckn (
                      rec_data_nrc.sfrstcr_pidm, 
                      rec_data_nrc.sfrstcr_term_code,
                      rec_data_nrc.sfrstcr_crn																										
                      );
            if (v_valida_nrc_tckn = 'N' ) then

              sfkmreg.p_process_registration ( p_pidm                 => rec_data_nrc.SFRSTCR_PIDM,
                                                 p_reg_term         => rec_data_nrc.SFRSTCR_TERM_CODE,
                                                 p_reg_date         => SYSDATE,
                                                 p_drop_crn         => rec_data_nrc.SFRSTCR_CRN,
                                                 p_drop_rsts_code   => 'DD',
                                                 p_dupl_severity    => dupl_severity_in,
                                                 p_link_severity    => link_severity_in,
                                                 p_corq_severity    => corq_severity_in,
                                                 p_preq_severity    => preq_severity_in,
                                                 p_minh_severity    => minh_severity_in,
                                                 p_maxh_severity    => maxh_severity_in,
                                                 p_time_severity    => time_severity_in,
                                                 p_appr_severity    => appr_severity_in,
                                                 p_capc_severity    => capc_severity_in,
                                                 p_majr_severity    => majr_severity_in,
                                                 p_dept_severity    => dept_severity_in,
                                                 p_coll_severity    => coll_severity_in,
                                                 p_levl_severity    => levl_severity_in,
                                                 p_clas_severity    => clas_severity_in,
                                                 p_rpth_severity    => rpth_severity_in,
                                                 p_hold_severity    => hold_severity_in,
                                                 p_rept_severity    => rept_severity_in,
                                                 p_camp_severity    => camp_severity_in,
                                                 p_degree_severity  => degree_severity_in,
                                                 p_program_severity => program_severity_in,
                                                 p_atts_severity    => atts_severity_in,
                                                 p_chrt_severity    => chrt_severity_in,
                                                 p_mexc_severity    => mexc_severity_in,
                                                 p_fee_assess_type  => 'REG_FEE_ASSESSMENT',
                                                 p_system_in        => 'devol_puce',
                                                 p_msg_out          => reg_msg,
                                                 p_update_out       => reg_out);
                p_insert_log_bit(id        => p_seq_no,
                               v_paso    => par_pro,
                               v_desc    => 'Actualizando nrc  a dd en borrado total '|| rec_data_nrc.SFRSTCR_CRN ||' PARA PIDM:' || rec_data_nrc.SFRSTCR_PIDM ||' reg_msg '||reg_msg||' reg_out '||reg_out,
                               v_sqlerrm => sqlerrm);
                INSERT INTO SATURN.AUD_SFRSTCR
                  (SELECT 'N', par_pro, par_usr, sysdate, SFRSTCR.*
                     FROM SFRSTCR
                    WHERE SFRSTCR_RSTS_CODE = 'DD'--v_rst
                      and SFRSTCR_TERM_CODE = rec_data_nrc.SFRSTCR_TERM_CODE
                      and SFRSTCR_PIDM = rec_data_nrc.SFRSTCR_PIDM
                      and SFRSTCR_CRN = rec_data_nrc.SFRSTCR_CRN);
            else
                p_insert_log_bit(id        => p_seq_no,
                               v_paso    => par_pro,
                               v_desc    => 'NRC existe en hist. No Actualiza nrc a dd en borrado total '|| rec_data_nrc.SFRSTCR_CRN ||' PARA PIDM:' || rec_data_nrc.SFRSTCR_PIDM ||' reg_msg '||reg_msg||' reg_out '||reg_out,
                               v_sqlerrm => sqlerrm);
            end if;
            exception
                when others then
                 --v_cont_ok := v_cont_ok - 1; 
                --v_cont_no_ok := v_cont_no_ok + 1; 

                  p_insert_log_bit(id        => p_seq_no,
                               v_paso    => par_pro,
                               v_desc    => 'PROBLEMA AL BORRAR DEL NRC '|| rec_data_nrc.SFRSTCR_CRN ||' PARA PIDM:' || rec_data_nrc.SFRSTCR_PIDM,
                               v_sqlerrm => sqlerrm);
              end;
    end loop;

    BEGIN     
         -- ESTIMA CUOTAS
          SFKFEES.p_processfeeassessment(term_in               => par_term,
                                       pidm_in               => par_pidm,
                                       fa_eff_date_in        => SYSDATE,
                                       rbt_rfnd_date_in      => SYSDATE,
                                       rule_entry_type_in    => 'R',
                                       create_accd_ind_in    => 'Y',
                                       source_pgm_in         => 'TZKLSCL',
                                       commit_ind_in         => 'Y',
                                       save_act_date_out     => v_save_act_date_out,
                                       ignore_sfrfmax_ind_in => 'N',
                                       return_status_in_out  => v_return_status_in_out);

          /*
          p_AplicaSFRFASC(p_id    => GB_COMMON.F_GET_ID(rec_data.tbraccd_pidm),
                                            p_term  => p_term,
                                            output  => v_return_status_in_out);
          */                                

          p_insert_log_bit(id        => p_seq_no,
                             v_paso    => par_pro,
                             v_desc    => 'ESTIMACION CUOTA FINALIZADA PARA PIDM:' ||
                                          par_pidm ||
                                          ', save_act_date_out:' ||
                                          V_save_act_date_out ||
                                          ',return_status_in_out:' ||
                                          V_return_status_in_out,
                             v_sqlerrm => sqlerrm);     
          exception
                when others then
                 --v_cont_ok := v_cont_ok - 1; 
                 --v_cont_no_ok := v_cont_no_ok + 1; 

                  p_insert_log_bit(id        => p_seq_no,
                               v_paso    => par_pro,
                               v_desc    => 'PROBLEMAS AL RE ESTIMAR LA CUOTA PARA PIDM:' ||
                                            par_pidm,
                               v_sqlerrm => sqlerrm);
         end;


    /* BORRADO DE CURSOS EN DD */
     DELETE FROM SFRSTCR
                 WHERE SFRSTCR_RSTS_CODE = 'DD'--v_rst
                   and SFRSTCR_TERM_CODE = par_term
                   and SFRSTCR_PIDM = par_pidm;
                   --and SFRSTCR_CRN = rec_data_nrc.SFRSTCR_CRN;
                COMMIT;    
end;

  function f_get_seq return number is
    v_out number;
  begin
    SELECT SATURN.seq_iztprlc.NEXTVAL into v_out FROM dual;
    return v_out;
  end;


  PROCEDURE p_Aplica_MDUU_BENEFICIOS (p_term number, p_id_student varchar2) is
--
-- FILE NAME..: p_Aplica_MDUU_CAMBIO_BENEFICIOS.sql
-- RELEASE....:
-- OBJECT NAME: p_Aplica_MDUU_CAMBIO_BENEFICIOS
-- PRODUCT....:
-- ANDRES CASTILLO marzo 2020
--
--
-- DESCRIPTION:
--   procedimiento para ejecutar el proceso MDUU_CAMBIO_BENEFICIOS
-- DESCRIPTION END
--


    v_message_sal   NUMBER;
    v_message_out   VARCHAR2(1000);
    v_param_str     VARCHAR2(1000);
    MESSAGE                         VARCHAR2 (2000);
    runsequencenum                  INTEGER;


    CURSOR get_ret_code_c IS

        --se busca los codigos de anio de ayuda e intervalo configurados
        SELECT 
              KVRAYPT_AIDY_CODE aidy, KVRAYPT_AIDP_CODE aidp
        FROM 
              KVRAYPT
        WHERE 
              KVRAYPT_TERM_CODE = p_term;        

BEGIN

    FOR ret_reg IN get_ret_code_c LOOP

        --v_param_str :='P1102_AIDP_CODE_SRC|'||ret_reg.aidp||'|P1101_AIDY_CODE_SRC|'||ret_reg.aidy||'';
        v_param_str :='P1101_ID|'||p_id_student||'|P1102_AIDP_CODE_SRC|'||ret_reg.aidp||'|P1101_AIDY_CODE_SRC|'||ret_reg.aidy||'';
				tzkpufc.p_ins_tzrrlog(0,  'MDUU_CAMBIO_BENEFICIOS', 'v_param_str ', v_param_str, user);

        gkkpsql.api_executeruleset(pprocess => 'MDUU_CAMBIO_BENEFICIOS',
                                      pruleset => 'MDUU_CAMBIO_BENEFICIOS',
                                      prulesetparameters => v_param_str,
                                      pdelimiter => '|',
                                      pexecutionmode => 'U',
                                      pexceptionmode => '1',
                                      pdiagnosticseverity => '30',
                                      prunsequencenum => runsequencenum,
                                      pmessage => MESSAGE);
                                      commit;

        IF
            MESSAGE IS NULL
        THEN
            dbms_output.put_line('p_Aplica_MDUU_CAMBIO_BENEFICIOS ejecutado para ' || ret_reg.aidy || ' ');
        ELSE
            dbms_output.put_line('Error al ejecutar p_Aplica_MDUU_CAMBIO_BENEFICIOS para ' || ret_reg.aidp || ' Error '||MESSAGE);
        END IF;

    END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
        NULL;
        dbms_output.put_line('Error no esperado: ' || sqlerrm);
 END p_Aplica_MDUU_BENEFICIOS;

  --busca la fecha de pago para un periodo y pidm
  function f_pay_pidm_term (
    p_pidm number, p_term varchar2, p_camp varchar2    
  ) return date is
    v_effective_date date := null;
    v_pago date := null;

    cursor c_pago is
    select tzrdprf_doc_number
        from tzrdprf
        where tzrdprf_pidm      = p_pidm
        and   tzrdprf_term_code = p_term
        and   tzrdprf_camp_code = p_camp
        and   tzrdprf_sdoc_code = 'BF';

    cursor c_fact (p_doc_num number) is
	select tzrfact_fact_date
    from tzrdprf rf
	inner join tzrfact ct on rf.tzrdprf_pidm = ct.tzrfact_pidm
                        and rf.tzrdprf_sdoc_code  = ct.tzrfact_sdoc_code  
						and  rf.tzrdprf_doc_number = ct.tzrfact_doc_number
						and rf.tzrdprf_term_code  = ct.tzrfact_term_code

	where rf.tzrdprf_doc_number = p_doc_num
    and rf.tzrdprf_sdoc_code = 'BF'
	and ct.tzrfact_sri_docnum is not null
	and ct.tzrfact_fact_cancel_ind is null
	and ct.tzrfact_fact_date is not null
	and exists (select unique 'y' 
				from tzrfact where tzrfact_sdoc_code = 'BT' 
				and tzrfact_pidm = rf.tzrdprf_pidm and tzrfact_doc_number = rf.tzrdprf_doc_number 
				and tzrfact_sri_docnum is not null
				and tzrfact_fact_cancel_ind is null)
	fetch first 1 rows only;

  begin        
      v_effective_date := null;  
      v_pago := null;  

      for pagos in c_pago loop
        open c_fact (pagos.tzrdprf_doc_number);
        fetch c_fact into v_effective_date;
        close c_fact;

        if v_effective_date is not null then
            v_pago := v_effective_date;
        end if;
      end loop;

        return v_pago;
      exception 
        when others then
            v_pago := sysdate;  
      return v_pago;
  end;

  --determina si un estudiante tiene deuda en un term especifico
  function f_debe_pidm_term (
    p_pidm number, 
    p_term varchar2,
	p_camp varchar2	

  ) return varchar is
    v_debe varchar2(2) := null;
	v_party varchar2(2)   := null;

    cursor c_val_fact_party (p_doc_num number) is    
    select 'Y'
    FROM tzrfact
    where tzrfact_doc_number = p_doc_num
    and   tzrfact_trdparty_id is not null
	fetch first 1 rows only;


    cursor c_pago is
    select tzrdprf_doc_number
        from tzrdprf
        where tzrdprf_pidm      = p_pidm
        and   tzrdprf_term_code = p_term
        and   tzrdprf_camp_code = p_camp
        AND   tzrdprf_sdoc_code = 'BF';

    cursor c_fact (p_doc_num number) is
    select 'Y'
    from tzrdprf rf
	inner join tzrfact ct on rf.tzrdprf_pidm = ct.tzrfact_pidm
                        and rf.tzrdprf_sdoc_code  = ct.tzrfact_sdoc_code  
						and  rf.tzrdprf_doc_number = ct.tzrfact_doc_number
						and rf.tzrdprf_term_code  = ct.tzrfact_term_code
	where rf.tzrdprf_doc_number = p_doc_num
    and rf.tzrdprf_sdoc_code = 'BF'
    and tzrfact_sri_docnum is null
    and tzrfact_fact_cancel_ind is null
    and tzrfact_pref_cancel_ind is null
	fetch first 1 rows only;

    cursor c_fact_party (p_doc_num number) is
    select 'Y'
    from tzrdprf rf
	inner join tzrfact ct on rf.tzrdprf_pidm = ct.tzrfact_pidm
                        and rf.tzrdprf_sdoc_code  = ct.tzrfact_sdoc_code  
						and  rf.tzrdprf_doc_number = ct.tzrfact_doc_number
						and rf.tzrdprf_term_code  = ct.tzrfact_term_code
	where rf.tzrdprf_doc_number = p_doc_num
    and rf.tzrdprf_sdoc_code = 'BF'
    and tzrfact_sri_docnum is null
    and tzrfact_fact_cancel_ind is null
    and tzrfact_pref_cancel_ind is null
    and tzrfact_trdparty_id is not null
	fetch first 1 rows only;

  begin        
      v_debe := 'N';  
      v_party := 'N';

      for pagos in c_pago loop

        open c_val_fact_party (pagos.tzrdprf_doc_number);
        fetch c_val_fact_party into v_party;
        close c_val_fact_party;

        if v_party = 'Y' then
            open c_fact_party (pagos.tzrdprf_doc_number);
            fetch c_fact_party into v_debe;
            close c_fact_party;
        else        
            open c_fact (pagos.tzrdprf_doc_number);
            fetch c_fact into v_debe;
            close c_fact;
        end if;        
      end loop;

    return v_debe;

  end;

function f_debe_pidm_accd (
    p_pidm number, 
    p_term varchar2	

  ) return varchar is
    v_debe varchar2(2) := null;

  begin  			

        select unique 'Y'
        INTO v_debe
        from tbraccd,
             tbbdetc,             
             sovlcur,
             smrprle                 
       where tbraccd_detail_code = tbbdetc_detail_code
         and tbraccd_term_code = p_term 
         and tbraccd_pidm = p_pidm
         and tbraccd_balance > 0
         and tbbdetc.tbbdetc_dcat_code in ('TUI')--, 'FEE')         
         and sovlcur_pidm = tbraccd_pidm
         AND sovlcur_current_ind = 'Y'
         AND sovlcur_active_ind = 'Y'
         and sovlcur_lmod_code = 'LEARNER'
         --and tbraccd_stsp_key_sequence = sovlcur_key_seqno
         and nvl2(tbraccd_stsp_key_sequence,tbraccd_stsp_key_sequence,sovlcur_key_seqno) = sovlcur_key_seqno
         --NVL2(tbraccd_stsp_key_sequence,tbraccd_stsp_key_sequence,'0')         
         --and decode(SOVLCUR_CAMP_CODE,'SDO','0',sovlcur_key_seqno) = NVL2(tbraccd_stsp_key_sequence,tbraccd_stsp_key_sequence,'0')         
         and smrprle_program = sovlcur_program
         and rownum=1; 
        return v_debe;
      exception 
        when NO_DATA_FOUND then
            v_debe := 'N';  
      return v_debe;
  end;

function f_debe_pidm_accd_term (
    p_pidm number, 
    p_term varchar2	

  ) return varchar is
    v_debe varchar2(2) := null;
    v_bal number(9);
  begin  			
        v_bal := 0;
        select sum(tbraccd_balance)
        INTO v_bal
        from tbraccd,
             tbbdetc,             
             sovlcur,
             smrprle                 
       where tbraccd_detail_code = tbbdetc_detail_code
         and tbraccd_term_code = p_term 
         and tbraccd_pidm = p_pidm
         --and tbraccd_balance = 0
         --and tbbdetc.tbbdetc_dcat_code in ('TUI')--, 'FEE')         
         and sovlcur_pidm = tbraccd_pidm
         AND sovlcur_current_ind = 'Y'
         AND sovlcur_active_ind = 'Y'
         and sovlcur_lmod_code = 'LEARNER'
         --and tbraccd_stsp_key_sequence = sovlcur_key_seqno
         and smrprle_program = sovlcur_program;
         --and rownum=1; 

         if v_bal = 0 then
            --no debe
            return 'Y';
         else
         --debe
            return 'N';
         end if;
      exception 
        when NO_DATA_FOUND then
            v_debe := 'N';  
      return v_debe;
  end;  
  --acastillo valida si el estudiante tiene determinada materia curso inscrita antes de una fecha p_pay_date  
  function f_valid_matcurso_pidm (
    p_pidm number, 
    p_term varchar2,
    p_stsp number,
    p_pay_date date,
    p_subj_code varchar2,
    p_crse_numb varchar2

  ) return varchar is
    v_existe VARCHAR2(2) := 'Y';

  begin  
        SELECT 'Y'
        into v_existe
        FROM sfrstcr, ssbsect, scbcrse
       --WHERE sfrstcr_rsts_date < p_pay_date
       --considerar evaluar sobre la fecha en que se agregó el registro, 
       --si se hace sobre la fecha de update de status siempre va a ser mayor a la de pago
       WHERE sfrstcr_add_date < p_pay_date 
         AND sfrstcr_term_code = p_term
         AND sfrstcr_pidm = p_pidm
         AND ssbsect_term_code = sfrstcr_term_code
         AND ssbsect_crn = sfrstcr_crn
         AND EXISTS
       (SELECT 1
                FROM stvrsts
               WHERE stvrsts_code = sfrstcr_rsts_code
                 AND stvrsts_incl_sect_enrl <> 'Y')
         AND ssbsect_subj_code = scbcrse_subj_code
         AND ssbsect_crse_numb = scbcrse_crse_numb
         AND ssbsect_subj_code = p_subj_code
         AND ssbsect_crse_numb = p_crse_numb
         AND scbcrse_eff_term =
             (SELECT MAX(crse.scbcrse_eff_term)
                FROM scbcrse crse
               WHERE scbcrse.scbcrse_subj_code = crse.scbcrse_subj_code
                 AND scbcrse.scbcrse_crse_numb = crse.scbcrse_crse_numb
                 AND crse.scbcrse_eff_term <= ssbsect_term_code)
       group by SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB;
       return v_existe;
      exception 
        when NO_DATA_FOUND then
            v_existe := 'N';  
      return v_existe;
  end;

 --acastillo valida si el estudiante tiene determinado nrc en historia academica
  function f_valid_nrc_tckn (
    p_pidm number, 
    p_term varchar2,
    p_crn varchar2

  ) return varchar is
    v_existe VARCHAR2(2) := 'Y';

  begin  
        SELECT 'Y'
        into v_existe
        FROM shrtckn
       WHERE shrtckn_term_code = p_term
         AND shrtckn_pidm = p_pidm
         AND shrtckn_crn = p_crn;

       return v_existe;
      exception 
        when NO_DATA_FOUND then
            v_existe := 'N';  
      return v_existe;
  end;


  --valida si tiene cursos despues del pago
  function f_valid_course_pospay(
    p_pidm number, 
    p_term varchar2,
    p_pay_date date
  ) return varchar is
    v_exist_courses VARCHAR2(2) := 'N';

  begin  
        SELECT 'Y'
        into v_exist_courses
        FROM sfrstcr, ssbsect, scbcrse
       WHERE sfrstcr_rsts_date > p_pay_date
         AND sfrstcr_term_code = p_term
         AND sfrstcr_pidm = p_pidm
         AND ssbsect_term_code = sfrstcr_term_code
         AND ssbsect_crn = sfrstcr_crn
         AND EXISTS
       (SELECT 1
                FROM stvrsts
               WHERE stvrsts_code = sfrstcr_rsts_code
                 AND stvrsts_incl_sect_enrl = 'Y')
         AND ssbsect_subj_code = scbcrse_subj_code
         AND ssbsect_crse_numb = scbcrse_crse_numb
            --    AND SSBSECT_SUBJ_CODE = P_SUBJ_CODE
            --   AND ssbsect_crse_numb = P_CRSE_NUMB
         AND scbcrse_eff_term =
             (SELECT MAX(crse.scbcrse_eff_term)
                FROM scbcrse crse
               WHERE scbcrse.scbcrse_subj_code = crse.scbcrse_subj_code
                 AND scbcrse.scbcrse_crse_numb = crse.scbcrse_crse_numb
                 AND crse.scbcrse_eff_term <= ssbsect_term_code)
				 AND ROWNUM=1;				 
       return v_exist_courses;
      exception 
        when NO_DATA_FOUND then
            v_exist_courses := 'N';  
      return v_exist_courses;
  end;

  --acastillo 
  --actualiza codigo en curso con DD
  --estima cuota
  --exee mduu beneficios
  --desaplica y aplica pagos
  procedure p_upd_nrc_pidm( 
                      par_nrc  varchar2,
                      par_term varchar2,
                      par_pidm number,  
                      par_stsp number,
                      par_usr  varchar2,
                      par_pro  number,
                      p_seq_no number) is

    lv_out_stat varchar2(1000);

       cursor nrc_pidm_term(v_nrc varchar2, v_term varchar2, v_pidm number, v_stsp varchar2) is

        SELECT
            sfrstcr_crn,
            sfrstcr_term_code,
            sfrstcr_pidm            
        FROM
            sfrstcr,
            stvrsts
        WHERE
            sfrstcr_term_code = v_term
            AND sfrstcr_stsp_key_sequence = v_stsp
			AND sfrstcr_crn = v_nrc
            AND sfrstcr_pidm = v_pidm
            AND sfrstcr_rsts_code <> 'DD'
            AND stvrsts_code = sfrstcr_rsts_code
            AND stvrsts_incl_sect_enrl = 'Y';

			CURSOR GET_SOBTERM_IND(lx_term  STVTERM.STVTERM_CODE%TYPE ) IS
				   SELECT 'N',--SOBTERM_DUPL_SEVERITY,
						  'N',--,SOBTERM_TIME_SEVERITY,
						  'N',--SOBTERM_CORQ_SEVERITY,
						  'N',--SOBTERM_LINK_SEVERITY,
						  'N',--SOBTERM_PREQ_SEVERITY,
						  'N',--SOBTERM_MAXH_SEVERITY,
						  'N',--SOBTERM_MINH_SEVERITY,
						  'N',--SOBTERM_MEXC_SEVERITY,
						  'N',--SOBTERM_TIME_SEVERITY,
						  'N',--SOBTERM_APPR_SEVERITY,
						  'N',--SOBTERM_CAPC_SEVERITY,
						  'N',--SOBTERM_MAJR_SEVERITY,
						  'N',--SOBTERM_DEPT_SEVERITY,
						  'N',--SOBTERM_COLL_SEVERITY,
						  'N',--SOBTERM_LEVL_SEVERITY,
						  'N',--SOBTERM_CLAS_SEVERITY,
						  'N',--SOBTERM_RPTH_SEVERITY,
						  'N',
                          --SOBTERM_HOLD_SEVERITY,
						  'N',--SOBTERM_REPT_SEVERITY,
						  'N',--SOBTERM_CAMP_SEVERITY,
						  'N',--SOBTERM_DEGREE_SEVERITY,
						  'N',--SOBTERM_PROGRAM_SEVERITY,
						  'N',--SOBTERM_ATTS_SEVERITY,
						  'N'--SOBTERM_CHRT_SEVERITY
					 FROM SOBTERM
				  WHERE SOBTERM_TERM_CODE = lx_term;

  --Variables
  dupl_severity_in    sobterm.sobterm_dupl_severity%TYPE;
  corq_severity_in    sobterm.sobterm_corq_severity%TYPE;
  link_severity_in    sobterm.sobterm_link_severity%TYPE;
  preq_severity_in    sobterm.sobterm_preq_severity%TYPE;
  maxh_severity_in    sobterm.sobterm_maxh_severity%TYPE;
  minh_severity_in    sobterm.sobterm_minh_severity%TYPE;
  mexc_severity_in    sobterm.sobterm_mexc_severity%TYPE;
  time_severity_in    sobterm.sobterm_time_severity%TYPE;
  appr_severity_in    sobterm.sobterm_appr_severity%TYPE;
  capc_severity_in    sobterm.sobterm_capc_severity%TYPE;
  majr_severity_in    sobterm.sobterm_majr_severity%TYPE;
  dept_severity_in    sobterm.sobterm_dept_severity%TYPE;
  coll_severity_in    sobterm.sobterm_coll_severity%TYPE;
  levl_severity_in    sobterm.sobterm_levl_severity%TYPE;
  clas_severity_in    sobterm.sobterm_clas_severity%TYPE;
  rpth_severity_in    sobterm.sobterm_rpth_severity%TYPE;
  hold_severity_in    sobterm.sobterm_hold_severity%TYPE;
  rept_severity_in    sobterm.sobterm_rept_severity%TYPE;
  camp_severity_in    sobterm.sobterm_camp_severity%TYPE;
  degree_severity_in  sobterm.sobterm_degree_severity%TYPE;
  program_severity_in sobterm.sobterm_program_severity%TYPE;
  atts_severity_in    sobterm.sobterm_atts_severity%TYPE;
  chrt_severity_in    sobterm.sobterm_chrt_severity%TYPE;
  mhrs_over_in        sfbetrm.sfbetrm_mhrs_over%TYPE;
  min_hrs_in          sfbetrm.sfbetrm_min_hrs%TYPE;
  sessionid_in        sfrcolr.sfrcolr_sessionid%TYPE;
  system_in           VARCHAR2(1);
  reg_err_msg         VARCHAR2(4000) := '';
  reg_update_allowed  VARCHAR2(1)    := '';
  reg_msg             VARCHAR2(4000) := '';
  reg_out             VARCHAR2(4000) := '';

  v_save_act_date_out    varchar2(400);
    v_return_status_in_out varchar2(400);

  begin

  OPEN GET_SOBTERM_IND(par_term);
          FETCH GET_SOBTERM_IND INTO dupl_severity_in,
                                     time_severity_in,
                                     corq_severity_in,
                                     link_severity_in,
                                     preq_severity_in,
                                     maxh_severity_in,
                                     minh_severity_in,
                                     mexc_severity_in,
                                     time_severity_in,
                                     appr_severity_in,
                                     capc_severity_in,
                                     majr_severity_in,
                                     dept_severity_in,
                                     coll_severity_in,
                                     levl_severity_in,
                                     clas_severity_in,
                                     rpth_severity_in,
                                     hold_severity_in,
                                     rept_severity_in,
                                     camp_severity_in,
                                     degree_severity_in,
                                     program_severity_in,
                                     atts_severity_in,
                                     chrt_severity_in;
          CLOSE GET_SOBTERM_IND;

    for rec_data_nrc in nrc_pidm_term(par_nrc, par_term, par_pidm, par_stsp) loop
        begin
			p_insert_log_bit(id        => p_seq_no,
                               v_paso    => par_pro,
                               v_desc    => 'Actualizacion NRC '|| rec_data_nrc.SFRSTCR_CRN ||
											'PARA PIDM:' || rec_data_nrc.SFRSTCR_PIDM,
                               v_sqlerrm => sqlerrm);
            sfkmreg.p_process_registration ( p_pidm                 => rec_data_nrc.SFRSTCR_PIDM,
                                                 p_reg_term         => rec_data_nrc.SFRSTCR_TERM_CODE,
                                                 p_reg_date         => SYSDATE,
                                                 p_drop_crn         => rec_data_nrc.SFRSTCR_CRN,
                                                 p_drop_rsts_code   => 'DD',
                                                 p_dupl_severity    => dupl_severity_in,
                                                 p_link_severity    => link_severity_in,
                                                 p_corq_severity    => corq_severity_in,
                                                 p_preq_severity    => preq_severity_in,
                                                 p_minh_severity    => minh_severity_in,
                                                 p_maxh_severity    => maxh_severity_in,
                                                 p_time_severity    => time_severity_in,
                                                 p_appr_severity    => appr_severity_in,
                                                 p_capc_severity    => capc_severity_in,
                                                 p_majr_severity    => majr_severity_in,
                                                 p_dept_severity    => dept_severity_in,
                                                 p_coll_severity    => coll_severity_in,
                                                 p_levl_severity    => levl_severity_in,
                                                 p_clas_severity    => clas_severity_in,
                                                 p_rpth_severity    => rpth_severity_in,
                                                 p_hold_severity    => hold_severity_in,
                                                 p_rept_severity    => rept_severity_in,
                                                 p_camp_severity    => camp_severity_in,
                                                 p_degree_severity  => degree_severity_in,
                                                 p_program_severity => program_severity_in,
                                                 p_atts_severity    => atts_severity_in,
                                                 p_chrt_severity    => chrt_severity_in,
                                                 p_mexc_severity    => mexc_severity_in,
                                                 p_fee_assess_type  => 'REG_FEE_ASSESSMENT',
                                                 p_system_in        => 'devol_puce',
                                                 p_msg_out          => reg_msg,
                                                 p_update_out       => reg_out);

                INSERT INTO SATURN.AUD_SFRSTCR
                  (SELECT 'N', par_pro, par_usr, sysdate, SFRSTCR.*
                     FROM SFRSTCR
                    WHERE SFRSTCR_RSTS_CODE = 'DD'--v_rst
                      and SFRSTCR_TERM_CODE = rec_data_nrc.SFRSTCR_TERM_CODE
                      and SFRSTCR_PIDM = rec_data_nrc.SFRSTCR_PIDM
                      and SFRSTCR_CRN = rec_data_nrc.SFRSTCR_CRN);
                    --v_cont_no_ok := v_cont_no_ok + 1; 

            exception
                when others then
                 --v_cont_ok := v_cont_ok - 1; 
                 --v_cont_no_ok := v_cont_no_ok + 1; 

                  p_insert_log_bit(id        => p_seq_no,
                               v_paso    => par_pro,
                               v_desc    => 'PROBLEMA AL ACTUALIZAR DD NRC '|| rec_data_nrc.SFRSTCR_CRN ||' PARA PIDM:' || rec_data_nrc.SFRSTCR_PIDM,
                               v_sqlerrm => sqlerrm);
              end;
    end loop;

		BEGIN     
         -- ESTIMA CUOTAS
          SFKFEES.p_processfeeassessment(term_in               => par_term,
                                       pidm_in               => par_pidm,
                                       fa_eff_date_in        => SYSDATE,
                                       rbt_rfnd_date_in      => SYSDATE,
                                       rule_entry_type_in    => 'R',
                                       create_accd_ind_in    => 'Y',
                                       source_pgm_in         => 'TZKLSCL',
                                       commit_ind_in         => 'Y',
                                       save_act_date_out     => v_save_act_date_out,
                                       ignore_sfrfmax_ind_in => 'N',
                                       return_status_in_out  => v_return_status_in_out);

          /*
          p_AplicaSFRFASC(p_id    => GB_COMMON.F_GET_ID(rec_data.tbraccd_pidm),
                                            p_term  => p_term,
                                            output  => v_return_status_in_out);
          */                                

          p_insert_log_bit(id        => p_seq_no,
                             v_paso    => par_pro,
                             v_desc    => 'ESTIMACION CUOTA FINALIZADA PARA PIDM:' ||
                                          par_pidm ||
                                          ', save_act_date_out:' ||
                                          V_save_act_date_out ||
                                          ',return_status_in_out:' ||
                                          V_return_status_in_out,
                             v_sqlerrm => sqlerrm);     
          exception
                when others then
                 --v_cont_ok := v_cont_ok - 1; 
                 --v_cont_no_ok := v_cont_no_ok + 1; 

                  p_insert_log_bit(id        => p_seq_no,
                               v_paso    => par_pro,
                               v_desc    => 'PROBLEMAS AL RE ESTIMAR LA CUOTA PARA PIDM:' ||
                                            par_pidm,
                               v_sqlerrm => sqlerrm);
        end;

		 BEGIN
         p_insert_log_bit(id        => p_seq_no,
                             v_paso    => par_pro,
                             v_desc    => 'Ejecución p_aplicatvrappl... 5.4..:' ||
                                          par_pidm ||
                                          ', par_term:' ||
                                          par_term,
                             v_sqlerrm => sqlerrm);     
			--p_post_borrado (par_pidm,par_term);

                     gb_common.p_set_context ('TB_RECEIVABLE',
                                  'PROCESS',
                                  'APPLPMNT',
                                  'N');
                      begin
					  	DBMS_LOCK.Sleep(15);

                        p_aplicatvrappl (p_id => gb_common.f_get_id(par_pidm),
                                             p_update_mode   => 'U',
                                             output          => lv_out_stat);

                        p_insert_log_bit(id        => p_seq_no,
								   v_paso    => par_pro,
								   v_desc    => 'Valor de output al aplicar pagos:' ||
												lv_out_stat,
								   v_sqlerrm => sqlerrm);                                             
                    end;
			exception
					when others then
					 --v_cont_ok := v_cont_ok - 1; 
					 --v_cont_no_ok := v_cont_no_ok + 1; 

					  p_insert_log_bit(id        => p_seq_no,
								   v_paso    => par_pro,
								   v_desc    => 'Problemas al desaplicar y aplicar para el pidm:' ||
												par_pidm,
								   v_sqlerrm => sqlerrm);
		 END;
         COMMIT;    
  end p_upd_nrc_pidm;

procedure p_execute_lc (p_seq_no        number default 999999999,
                        p_term VARCHAR2,
                        p_camp       VARCHAR2,
                        p_student_id varchar2 default null,
                        p_tipo_alumno  varchar2
                        )
						as

    v_pidm                 number;
    pr_tbraccd             tbraccd%rowtype;
    v_paso                 number;
    v_desc                 varchar2(4000);
    v_sqlerrm              varchar2(4000);
    lv_out_stat            varchar2(4000);
    v_saldo                number;
    v_cant_materia         number;
    v_cant_total           number;
    v_cant_mayor_cero      number;
    v_cant_menor_cero      number;
    v_cont_ok              number;
    v_cont_no_ok           number;
    v_pro                  NUMBER;
    v_save_act_date_out    varchar2(400);
    v_return_status_in_out varchar2(400);
    v_es_nuevo             varchar2(20);
    v_tiene_pago           varchar2(3);
    v_fecha_pago           date;
    v_fecha_inscripcion    date;
    v_credito_mayor        number;
    v_debe                 varchar2(3);
	v_valida_matcurso      varchar2(3);
	v_valida_nrc_tckn      varchar2(3);
    p_error_ind            varchar2(3);
    p_error_msg            varchar2(2000);
    p_err_msg_return       varchar2(2000);
	--p_term				   stvterm.stvterm_code%type;
	--p_camp				   stvcamp.stvcamp_code%type;
	--p_student_id		   spriden.spriden_id%type;
	--p_tipo_estudiante	   varchar2(20);

    p_doc_num              varchar2(20);
    output          VARCHAR2(2000);
    v_sqlerrormsg   varchar2(500);
    lv_err_msg		  varchar2(400);

	v_val_ests_end_date varchar2(1);
	v_rsts_end_date varchar2(1);
    cursor cur_student_exception is
      select * from iztlcpr;

    cursor data_log is
      select DISTINCT SFRSTCR_PIDM
        from SATURN.AUD_SFRSTCR
       where PROCESO = v_pro;

    --cursor de nuevos y antiguos, se filtra por parametro V_TIPO_ALUMNO, 
	--excluye programas parametrizados en gtvsdax con grupo GBA037 
    cursor cur_data_ini(p_term varchar2, p_camp varchar2, p_tipo_alumno varchar2) is		
	select         
            sovlcur_camp_code,
            gb_common.f_get_id(sfrstcr_pidm) ID,
            sfrstcr_pidm,
            sfrstcr_stsp_key_sequence,
            sfrstcr_term_code,
            sovlcur_program
        from
            sovlcur,
            (select SFRSTCR_STSP_KEY_SEQUENCE,SFRSTCR_TERM_CODE, SFRSTCR_PIDM 
                from sfrstcr, stvrsts where stvrsts_code = sfrstcr_rsts_code and stvrsts_incl_sect_enrl = 'Y' and sfrstcr_term_code >= 202060
            group by SFRSTCR_STSP_KEY_SEQUENCE,SFRSTCR_TERM_CODE, SFRSTCR_PIDM) sfrstcr         
        where sfrstcr_pidm = nvl2(p_student_id, p_student_id,sfrstcr_pidm)
            and sovlcur_pidm = sfrstcr_pidm
            and sovlcur_current_ind = 'Y'
            and sovlcur_active_ind = 'Y'
            and sovlcur_lmod_code = 'LEARNER'
            and sovlcur.sovlcur_program not in (
                select
                    gtvsdax_external_code
                from
                    gtvsdax
                where
                    gtvsdax_internal_code_group = 'GBA037'
                    and gtvsdax_concept = 'Y'
            )
            and sovlcur_key_seqno = sfrstcr_stsp_key_sequence
            and ( gb_common.f_get_id(sfrstcr_pidm),
                  sovlcur_program ) not in (
                select
                    iztlcpr_student_id,
                    iztlcpr_program
                from
                    iztlcpr
            )
            and tzklscl.f_obtener_tipo_alumno(sfrstcr_term_code, 
                       sovlcur_camp_code,
                       sovlcur_program,
                       sfrstcr_pidm) <> p_tipo_alumno
            and sfrstcr_term_code =p_term
            and sovlcur_camp_code =p_camp;


    --nrcs de estudiante por periodo, con fecha de inscripcion mayor a fecha de pago 
    cursor cur_nrc_pidm_term(p_pidm number, p_term varchar2, p_stsp number, p_rsts_date date) is 

    SELECT sfrstcr_pidm, 
           sfrstcr_crn,
           sfrstcr_term_code, 
           ssbsect_subj_code, 
           ssbsect_crse_numb,
           sfrstcr_rsts_date,
		   sfrstcr_bill_hr
        FROM sfrstcr, ssbsect, scbcrse
       WHERE sfrstcr_rsts_date > p_rsts_date
         AND sfrstcr_term_code = p_term
         AND sfrstcr_pidm = p_pidm
         AND ssbsect_term_code = sfrstcr_term_code
         AND ssbsect_crn = sfrstcr_crn
         --and sfrstcr_crn in (1504,2383)
         AND EXISTS
       (SELECT 1
                FROM stvrsts
               WHERE stvrsts_code = sfrstcr_rsts_code
                 AND stvrsts_incl_sect_enrl = 'Y')
         AND ssbsect_subj_code = scbcrse_subj_code
         AND ssbsect_crse_numb = scbcrse_crse_numb
            --    AND SSBSECT_SUBJ_CODE = P_SUBJ_CODE
            --   AND ssbsect_crse_numb = P_CRSE_NUMB
         AND scbcrse_eff_term =
             (SELECT MAX(crse.scbcrse_eff_term)
                FROM scbcrse crse
               WHERE scbcrse.scbcrse_subj_code = crse.scbcrse_subj_code
                 AND scbcrse.scbcrse_crse_numb = crse.scbcrse_crse_numb
                 AND crse.scbcrse_eff_term <= ssbsect_term_code)
       --group by SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB
       order by sfrstcr_rsts_date desc;

	 --record que devuelve datos para cancelar prefactura
	 cursor cur_dat_prefact (p_pidm number, p_term varchar2) is
	 --select  distinct tzrfact_pidm, tzrfact_sdoc_code, tzrfact_doc_number, tzrfact_curr_program,tzrfact_user 
     select  distinct *
		from tzrfact 
		where tzrfact_term_code  = p_term
		and tzrfact_pidm = p_pidm
		and exists (select 'y' from tvbsdoc where tvbsdoc_doc_number = tzrfact_doc_number and tvbsdoc_pidm = tzrfact_pidm and tvbsdoc_doc_cancel_ind is null) 
		and tzrfact_sri_docnum is null;
	rec_tzrfact tzrfact%ROWTYPE;

	--record que devuelve datos para generar prefactura
    type rec_tzvaccd is record
    (
        pidm tzvaccd.tzvaccd_pidm%type,
        sdoc_code tzvaccd.tzvaccd_sdoc_code%type,
        term_code tzvaccd.tzvaccd_term_code%type,
        doc_amount tzvaccd.tzvaccd_amount%type,
        trans varchar2(100),
        campus tzvaccd.tzvaccd_campus%type,
        levl varchar2(100),
        programa varchar2(100)
    );
	 cursor cur_dat_create_prefact (p_pidm number, p_term varchar2) is
	select tzvaccd_pidm,
           tzvaccd_sdoc_code,
           tzvaccd_term_code,
           sum (tzvaccd_balance) doc_amount,
           regexp_replace (
           listagg (tzvaccd_tran_number, ',')
                   within group (order by tzvaccd_pidm),
                   '([^,]+)(,\1)*(,|$)',
                   '\1\3') trans,
           tzvaccd_campus,
           tzkpufc.f_get_sovlcur(tzvaccd_pidm,tzvaccd_term_code, 'LEVL' ) levl, 
           tzkpufc.f_get_sovlcur(tzvaccd_pidm,tzvaccd_term_code, 'PROGRAM' ) programa
           from tzvaccd
           where     tzvaccd_term_code = p_term
		   and tzvaccd_pidm = p_pidm
           and tzvaccd_balance > 0
                    --tzvaccd_sdoc_code = 'bf' – si solo se quiere el tipo de document bf habilitarlo.
	group by tzvaccd_pidm, tzvaccd_sdoc_code, tzvaccd_term_code, tzvaccd_campus;             
  	--rec_tzvaccd tzvaccd%ROWTYPE;

        cursor c_desaplica (p_pidm number) 
        is
            select TBRAPPL_PIDM,  TBRAPPL_PAY_TRAN_NUMBER, TBRAPPL_CHG_TRAN_NUMBER, TBRAPPL_AMOUNT, rowid TBRAPPL_rowid
            from tbrappl
            where tbrappl_pidm = p_pidm 
            and TBRAPPL_REAPPL_IND is null
            and TBRAPPL_PAY_TRAN_NUMBER in 
            (
            select TBRACCD_TRAN_NUMBER 
            from tbraccd, tbbdetc 
            where tbraccd_detail_code = tbbdetc_detail_code
            and   tbbdetc_type_ind='C'
            and trunc(TBRACCD_TRANS_DATE) = trunc(sysdate)
            and  tbraccd_amount < 0
            and  tbraccd_pidm = p_pidm
        );
        cursor c_desaplica_bec (p_pidm number,  p_term_code varchar2) 
        is
        select TBRAPPL_PIDM,  TBRAPPL_PAY_TRAN_NUMBER, TBRAPPL_CHG_TRAN_NUMBER, TBRAPPL_AMOUNT, rowid TBRAPPL_rowid
        from tbrappl where tbrappl_pidm = p_pidm and TBRAPPL_REAPPL_IND is null
        and  TBRAPPL_PAY_TRAN_NUMBER in (
        select TBRACCD_TRAN_NUMBER 
        from tbraccd, tbbdetc where tbraccd_pidm = p_pidm 
        and TBRACCD_TERM_CODE = p_term_code
        and tbraccd_detail_code =  tbbdetc_detail_code
        and tbbdetc_type_ind = 'P'
        and tbbdetc_dcat_code in ('BEC', 'DES')
        );
        cursor c_val_ests_end_date (p_term varchar2) 
		is 
		select unique 'Y'
		from sfbests
		where sfbests_ests_code = 'EL'
		and   trunc(sfbests_end_date) >= trunc(sysdate)
		and   sfbests_term_code = p_term;

		cursor c_rsts_end_date (p_pidm number, v_term varchar2, v_camp varchar2)
        is
    	select unique 'Y'
		from sfrrsts
		where sfrrsts_rsts_code = 'DD'
		and sfrrsts_ptrm_code in (
			select sfrstcr_ptrm_code
				from sovlcur,sfrstcr,stvrsts
				where sfrstcr_pidm = p_pidm
				and sovlcur_pidm = sfrstcr_pidm
				and sovlcur_current_ind = 'Y'
				and sovlcur_active_ind = 'Y'
				and sovlcur_lmod_code = 'LEARNER'
				and stvrsts_code = sfrstcr_rsts_code
				and stvrsts_incl_sect_enrl = 'Y'   
				and sovlcur.sovlcur_program not in (
							select gtvsdax_external_code
							from gtvsdax where gtvsdax_internal_code_group='GBA037'
							and  gtvsdax_concept='Y')
				and sovlcur_key_seqno = sfrstcr_stsp_key_sequence
				and sfrstcr_term_code = v_term
				and sovlcur_camp_code = v_camp	                        
				group by sfrstcr_ptrm_code
		)
		and sfrrsts_term_code = v_term
		and trunc(sfrrsts_end_date) < trunc(sysdate);

    cursor nrc_pidm_term_tckn(v_term varchar2, v_pidm number) is

        SELECT
            'Y'

        FROM
            sfrstcr,
            stvrsts
        WHERE
            sfrstcr_term_code = v_term
            --AND sfrstcr_stsp_key_sequence = v_stsp
            AND sfrstcr_pidm = v_pidm
            AND sfrstcr_rsts_code <> 'DD'
            AND stvrsts_code = sfrstcr_rsts_code
            AND stvrsts_incl_sect_enrl = 'Y'
            and f_valid_nrc_tckn (
                      sfrstcr.sfrstcr_pidm, 
                      sfrstcr.sfrstcr_term_code,
                      sfrstcr.sfrstcr_crn																										
                      )='Y';

    v_row_print         varchar2 (1000);
    v_page_width        number;
    v_status            varchar2 (10);
    v_comments          varchar2 (20000):='';
    v_debe_bal number := 999999;
	p_error_msg_2 varchar2(2000);
	begin

		v_cont_ok    := 0;
		v_cont_no_ok := 0;
		v_debe := 'Y';
		v_valida_matcurso :='Y';
        v_valida_nrc_tckn :='Y';
		v_val_ests_end_date := 'N';

		open c_val_ests_end_date (p_term);
		fetch c_val_ests_end_date into v_val_ests_end_date;
		close c_val_ests_end_date;

		--secuencia del proceso a ejecutar
		select SATURN.seq_prlst.NEXTVAL into v_pro from dual;
		--gkkpsql.writediagnostictodb(40,p_student_id || ' ' || p_term || ' - ' ||TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS')||'-'|| p_camp || ' - ' || p_tipo_estudiante );

		--recorrer datos de estudiantes filtrados por parametro p_tipo_alumno
		if v_val_ests_end_date = 'Y' then 	
			for rec_data in cur_data_ini(p_term, p_camp, p_tipo_alumno) loop
                v_row_print :=
                gz_report.f_colum_format ('Periodo',7,'LEFT',' | ')
             || gz_report.f_colum_format ('ID Alumno',9,'LEFT',' | ')
             || gz_report.f_colum_format ('CAMPUS',35,'LEFT',' | ');

          gz_report.p_put_line (p_one_up_no       => p_seq_no,
                                p_user            => USER,
                                p_job_name        => const_application_name,
                                p_file_number     => 1,  --NVL (v_file_number, 1),
                                p_content_line    => v_row_print,
                                p_content_width   => v_page_width,
                                p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                                p_status          => v_status,
                                p_comments        => v_comments);	
        v_row_print :=
					gz_report.f_colum_format (rec_data.sfrstcr_term_code,
											  7,
											  'LEFT',
											  ' | ')
					|| gz_report.f_colum_format (rec_data.ID,
												 9,
												 'LEFT',
												 ' | ')
					|| gz_report.f_colum_format (rec_data.sovlcur_camp_code,
												 24,
												 'LEFT',
												 ' | ');

          gz_report.p_put_line (p_one_up_no       => p_seq_no,
                                p_user            => USER,
                                p_job_name        => const_application_name,
                                p_file_number     => 1,  --NVL (v_file_number, 1),
                                p_content_line    => v_row_print,
                                p_content_width   => v_page_width,
                                p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                                p_status          => v_status,
                                p_comments        => v_comments);

			 v_rsts_end_date := 'N';
			 open c_rsts_end_date (rec_data.sfrstcr_pidm, rec_data.sfrstcr_term_code, rec_data.sovlcur_camp_code);
			 fetch c_rsts_end_date into v_rsts_end_date;
			 close c_rsts_end_date;
				if v_rsts_end_date = 'Y' then		
 					p_insert_log_bit(id     => p_seq_no,
											 v_paso    => v_pro,
											 v_desc    => 'Proceso para pidm:'||rec_data.sfrstcr_pidm||' 
											 El estudiante tiene cursos con partes de periodo cerradas para status DD, no se procesa. verificar sfrrsts',
											 v_sqlerrm => sqlerrm);				
 				else
				  begin    
				  --calcula si el alumno debe en el periodo
					v_debe := f_debe_pidm_accd (
											rec_data.sfrstcr_pidm, 
											rec_data.sfrstcr_term_code
											--rec_data.sovlcur_camp_code
											);

					p_insert_log_bit(id     => p_seq_no,
											 v_paso    => v_pro,
											 v_desc    => 'Proceso para pidm:'||rec_data.sfrstcr_pidm,
											 v_sqlerrm => sqlerrm);

					--valida y devuelve fecha de pago, NUll=No
					v_fecha_pago := f_pay_pidm_term (
									rec_data.sfrstcr_pidm, 
									rec_data.sfrstcr_term_code,
									--rec_data.tbraccd_stsp_key_sequence
									rec_data.sovlcur_camp_code);
					p_insert_log_bit(id     => p_seq_no,
								 v_paso    => v_pro,
								 v_desc    => 'Pidm: '||rec_data.sfrstcr_pidm||
											  'Fecha de pago '||v_fecha_pago||' Debe '||v_debe,
											  v_sqlerrm => sqlerrm);

					--valida si tiene un pago para evaluar cada nrc, sino tiene un pago los borra todos
					if v_fecha_pago is not null then
						p_insert_log_bit(id     => p_seq_no,
												 v_paso    => v_pro,
												 v_desc    => 'Borrado parcial valida si tiene un pago para evaluar cada nrc, sino tiene un pago los borra todos Pidm: '||rec_data.sfrstcr_pidm||
															  'Fecha de pago '||v_fecha_pago||' Debe '||v_debe||
															  'v_valida_matcurso '||v_valida_matcurso,
												 v_sqlerrm => sqlerrm);

						 --valida si tiene deuda para matricula y arancel en el periodo Y o N
						 --mientras tenga deduda se debe cambiar status de curso, estimar cuota, 
						 --mduu beneficios, appr desappr transacciones
						begin		 
							if f_valid_course_pospay(
													rec_data.sfrstcr_pidm,
													rec_data.sfrstcr_term_code,
													v_fecha_pago)='Y' then 
								for rec_nrcs in cur_nrc_pidm_term(
									rec_data.sfrstcr_pidm, 
									rec_data.sfrstcr_term_code,
									rec_data.sfrstcr_stsp_key_sequence, 
									v_fecha_pago) loop
									begin
										--validar materia curso en fecha anterior al pago
										v_valida_matcurso := f_valid_matcurso_pidm (
														rec_nrcs.sfrstcr_pidm, 
														rec_nrcs.sfrstcr_term_code,
														rec_data.sfrstcr_stsp_key_sequence, 
														v_fecha_pago,
														rec_nrcs.ssbsect_subj_code,
														rec_nrcs.ssbsect_crse_numb												
														);

										--validar nrc en historia
                    v_valida_nrc_tckn := f_valid_nrc_tckn (
														rec_nrcs.sfrstcr_pidm, 
														rec_nrcs.sfrstcr_term_code,
														rec_nrcs.sfrstcr_crn																										
														);

										p_insert_log_bit(id     => p_seq_no,
										v_paso    => v_pro,
										v_desc    => ' Pidm: '||rec_data.sfrstcr_pidm||
													 ' Fecha de pago '||v_fecha_pago||' Debe '||v_debe||
													 ' v_valida_matcurso '||v_valida_matcurso||
                                                     ' v_valida_nrc_tckn '||v_valida_nrc_tckn||
													 ' NRC '||rec_nrcs.sfrstcr_crn||
													 ' Sub_code crse_numb '||rec_nrcs.ssbsect_subj_code||rec_nrcs.ssbsect_crse_numb,
													 v_sqlerrm => sqlerrm);				

										if (v_valida_matcurso = 'N' and v_valida_nrc_tckn = 'N' and v_debe ='Y' and rec_nrcs.sfrstcr_bill_hr <> 0) then
											--asignar codigo DD, estimar cuota, appr beneficios, appr desappr transacciones
										  begin
											p_insert_log_bit(id     => p_seq_no,
											v_paso    => v_pro,
											v_desc    => 'Matcurso no encontrado antes de fecha de pago ni nrc en his. y debe, asignar codigo DD, estimar cuota, appr beneficios, appr desappr transacciones, 
											v_valida_matcurso: '||v_valida_matcurso||' v_valida_nrc_tckn '||v_valida_nrc_tckn||' v_debe: '||v_debe||' 
											v_fecha_pago: '||v_fecha_pago||' valida deuda nrc: '||rec_nrcs.sfrstcr_crn,
											v_sqlerrm => sqlerrm);

											p_upd_nrc_pidm(rec_nrcs.sfrstcr_crn,
														   rec_nrcs.sfrstcr_term_code,
														   rec_nrcs.sfrstcr_pidm, 
														   rec_data.sfrstcr_stsp_key_sequence, 
														   user,
														   v_pro,
                                                           p_seq_no
														   );
														v_cont_ok := v_cont_ok+1;
											exception
											when others then
											v_cont_ok := v_cont_ok - 1; 
											v_cont_no_ok := v_cont_no_ok + 1; 
											p_insert_log_bit(id        => p_seq_no,
															   v_paso    => v_pro,
															   v_desc    => 'Problemas al actualizar nrc para PIDM:' ||
																			rec_data.sfrstcr_pidm,
															   v_sqlerrm => sqlerrm);
											end;
										else 
											--log
											p_insert_log_bit(id     => p_seq_no,
												 v_paso    => v_pro,
												 v_desc    => 'Materia curso,
												 registrada antes de fecha de pago, o nrc en historia, o con creditos 0, no se actualiza a DD'||
                                                ' v_valida_matcurso '||v_valida_matcurso||
                                                ' v_valida_nrc_tckn '||v_valida_nrc_tckn||
												' v_fecha_pago:'||v_fecha_pago||'valida deuda nrc:'||rec_nrcs.sfrstcr_crn,
												 v_sqlerrm => sqlerrm);
										end if;	
											--valida si despues de aplicar transacciones sigue en debe para seguir quitando NRCs al estudiante
											DBMS_LOCK.Sleep(5);
											begin
												tzkpufc.p_awards_courses (
																			p_pidm        => rec_nrcs.sfrstcr_pidm,
																			p_term_code   => rec_nrcs.sfrstcr_term_code,
																			p_error_msg => p_error_msg_2 
																			);

												p_insert_log_bit(id     => p_seq_no,
													 v_paso    => v_pro,
													 v_desc    => 'Calcula dism. becas:'||p_error_msg_2,
													 v_sqlerrm => sqlerrm);
											exception when others then
													p_insert_log_bit(id     => p_seq_no,
													 v_paso    => v_pro,
													 v_desc    => 'Error al calcular dism. becas:'||p_error_msg_2,
													 v_sqlerrm => sqlerrm);

											end;	
											--DBMS_LOCK.Sleep(20);
                                            begin
											select tbraccd_balance
                                                INTO v_debe_bal
                                                from tbraccd,
                                                     tbbdetc,             
                                                     sovlcur,
                                                     smrprle                 
                                               where tbraccd_detail_code = tbbdetc_detail_code
                                                 and tbraccd_term_code = rec_nrcs.sfrstcr_term_code 
                                                 and tbraccd_pidm = rec_nrcs.sfrstcr_pidm
                                                 and tbraccd_balance > 0
                                                 and tbbdetc.tbbdetc_dcat_code in ('TUI')--, 'FEE')         
                                                 and sovlcur_pidm = tbraccd_pidm
                                                 AND sovlcur_current_ind = 'Y'
                                                 AND sovlcur_active_ind = 'Y'
                                                 and sovlcur_lmod_code = 'LEARNER'
                                                 and tbraccd_stsp_key_sequence = sovlcur_key_seqno
                                                 and smrprle_program = sovlcur_program
                                                 and rownum=1; 
											exception when others then
												v_debe_bal := 0;
											end;
                                            p_insert_log_bit(id     => p_seq_no,
												 v_paso    => v_pro,
												 v_desc    => 'valor tbraccd_balance para TUI 0 = no encontrado v_debe_balance aft:'||v_debe_bal,
												 v_sqlerrm => sqlerrm);

											v_debe := f_debe_pidm_accd (
											rec_data.sfrstcr_pidm, 
											rec_data.sfrstcr_term_code
											--rec_data.sovlcur_camp_code
											);
									end;							

								end loop;
								--Generar prefactura   

										p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => 'Desaplica pagos por transaccion para Intentar generar prefactura:' ||rec_data.sfrstcr_pidm||
													 'id ' ||gb_common.f_get_id(rec_data.sfrstcr_pidm)||
													 'camp ' ||p_camp,
										v_sqlerrm => sqlerrm);

							begin
									gb_common.p_set_context ('TB_RECEIVABLE',
															  'PROCESS',
															  'APPLPMNT',
															  'N');
									FOR rec in c_desaplica(rec_data.sfrstcr_pidm) 
									LOOP
									   tv_application.p_process_unapplication (
											p_pidm              => rec.tbrappl_pidm,
											p_pay_tran_number   => rec.tbrappl_pay_tran_number,
											p_chg_tran_number   => rec.tbrappl_chg_tran_number,
											p_amount            => rec.tbrappl_amount,
											p_appl_rowid        => rec.tbrappl_rowid);

										p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => 'Desaplica pagos por transaccion para Intentar generar prefactura:' ||rec_data.sfrstcr_pidm||
													 ' id ' ||gb_common.f_get_id(rec_data.sfrstcr_pidm)||
													 ' p_pay_tran_number ' ||rec.tbrappl_pay_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_chg_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_amount,
										v_sqlerrm => sqlerrm);
										p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => ' p_pay_tran_number ' ||rec.tbrappl_pay_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_chg_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_amount,
										v_sqlerrm => sqlerrm);								
									END LOOP;
								commit;
							end;

									  begin                     
											 tzklscl.p_AplicaTZPPFAC (p_term,
																 gb_common.f_get_id(rec_data.sfrstcr_pidm),
																 'BF',--rec_data_prefac.tzvaccd_sdoc_code,
																 p_camp,
																 'U',
																 output
												);
												commit;
												IF output = 'Y' THEN
													dbms_output.put_line('TZPPFAC ejecutado para id '||gb_common.f_get_id(rec_data.sfrstcr_pidm));
													p_insert_log_bit(id        => p_seq_no,
																   v_paso    => v_pro,
																   v_desc    => 'OK al generar prefactura:' ||
																				rec_data.sfrstcr_pidm||' p_error_msg: '||p_error_msg,
																   v_sqlerrm => sqlerrm);
												ELSE
													dbms_output.put_line('Error al ejecutar TZPPFAC para '||gb_common.f_get_id(rec_data.sfrstcr_pidm));
													p_insert_log_bit(id        => p_seq_no,
																   v_paso    => v_pro,
																   v_desc    => 'Problemas al generar prefactura:' ||
																				rec_data.sfrstcr_pidm||' p_error_msg: '||p_error_msg,
																   v_sqlerrm => sqlerrm);
												END IF;

											 exception
													when others then
													 v_cont_ok := v_cont_ok - 1; 
													 v_cont_no_ok := v_cont_no_ok + 1; 

													  p_insert_log_bit(id        => p_seq_no,
																   v_paso    => v_pro,
																   v_desc    => 'Problemas al generar prefactura:' ||
																				rec_data.sfrstcr_pidm||' p_error_msg: '||p_error_msg,
																   v_sqlerrm => sqlerrm);
											--end;
										--end loop;
									  end;								

							else
								p_insert_log_bit(id     => p_seq_no,
											v_paso    => v_pro,
											v_desc    => 'No se encontraron cursos inscritos despues de pago, no se procesa pidm, 
											v_valida_matcurso: '||v_valida_matcurso||' v_debe: '||v_debe||' 
											v_fecha_pago: '||v_fecha_pago,
											v_sqlerrm => sqlerrm);
							end if;
						 v_cont_ok := v_cont_ok + 1;         

						 exception
											when others then
											v_cont_ok := v_cont_ok - 1; 
											v_cont_no_ok := v_cont_no_ok + 1; 
											p_insert_log_bit(id        => p_seq_no,
															   v_paso    => v_pro,
															   v_desc    => 'Error al procesar cursos inscritos despues de pago PIDM:' ||
																			rec_data.sfrstcr_pidm,
															   v_sqlerrm => sqlerrm);				
						end;	
						--return v_pro;
					--sino tiene ningun pago
					else 				
						 p_insert_log_bit(id     => p_seq_no,
											 v_paso    => v_pro,
											 v_desc    => 'No tiene pago v_fecha_pago se actualizan y eliminan todos los NRC:'||v_fecha_pago||'valida deuda v_debe:'||v_debe,
											 v_sqlerrm => sqlerrm);

								 -- BORRADO DE NRCs POR PIDM		 
						 p_del_nrc_pidm(    rec_data.sfrstcr_term_code,
											rec_data.sfrstcr_pidm,
											rec_data.sfrstcr_stsp_key_sequence,
											user,
											v_pro,
                                            p_seq_no);

						 v_cont_ok := v_cont_ok + 1;         

						BEGIN


						sb_calculo_seg_ter_matricula.p_assign_charges_student (
							p_student_pidm        => rec_data.sfrstcr_pidm,
							p_periodoprefactura   => rec_data.sfrstcr_term_code,
							sqlerrormsg           => v_sqlerrormsg);

							p_insert_log_bit(id     => p_seq_no,
												 v_paso    => v_pro,
												 v_desc    => 'sb_calculo_seg_ter_matricula: ',
												 v_sqlerrm => v_sqlerrormsg);
						--p_error_msg := sqlerrm;
						exception when others then 
									   p_insert_log_bit(id     => '0',
												 v_paso    => v_pro,
												 v_desc    => 'sb_calculo_seg_ter_matricula: ',
												 v_sqlerrm => v_sqlerrormsg);
						END;

						-- BORRADO DEL ENCABEZADO
						BEGIN

						  p_insert_log_bit(id        =>p_seq_no,
								   v_paso    => v_pro,
								   v_desc    => 'Borra Encabezado para pidm:'||rec_data.sfrstcr_pidm,
								   v_sqlerrm => sqlerrm);

						 delete from SFBETRM
						 WHERE SFBETRM_PIDM = rec_data.sfrstcr_pidm
						 AND SFBETRM_TERM_CODE = p_term;
						COMMIT;

						exception
							when others then
							  p_insert_log_bit(id        => p_seq_no,
										   v_paso    => v_pro,
										   v_desc    => 'PROBLEMAS AL BORRAR ENCABEZADO PARA PIDM:' ||
														rec_data.sfrstcr_pidm,
										   v_sqlerrm => sqlerrm);
						end; 

						-- Ejecucion de mduu de cambio de status de becas para el periodo
						BEGIN      
              p_insert_log_bit(id        =>p_seq_no,
								   v_paso    => v_pro,
								   v_desc    => 'Ejecuta p_Aplica_MDUU_BENEFICIOS pada ID :'||gb_common.f_get_id(rec_data.sfrstcr_pidm),
								   v_sqlerrm => sqlerrm);
							 p_Aplica_MDUU_BENEFICIOS(p_term => p_term, p_id_student => gb_common.f_get_id(rec_data.sfrstcr_pidm));
							 COMMIT;                     
						end;
						-- Desaplicacion y aplicación de pagos por pidm y periodo
						--for rec_data in cur_data_ini(p_term, p_camp, p_tipo_alumno) loop
						begin
							p_post_borrado (rec_data.sfrstcr_pidm,p_term);
							DBMS_LOCK.Sleep(5);
							exception
									when others then
									 v_cont_ok := v_cont_ok - 1; 
									 v_cont_no_ok := v_cont_no_ok + 1; 

									  p_insert_log_bit(id        => p_seq_no,
												   v_paso    => v_pro,
												   v_desc    => 'Problemas al desaplicar y aplicar para el pidm:' ||
																rec_data.sfrstcr_pidm,
												   v_sqlerrm => sqlerrm);
						  end;

                        /*begin
									gb_common.p_set_context ('TB_RECEIVABLE',
															  'PROCESS',
															  'APPLPMNT',
															  'N');
									FOR rec in c_desaplica(rec_data.sfrstcr_pidm) 
									LOOP
									   tv_application.p_process_unapplication (
											p_pidm              => rec.tbrappl_pidm,
											p_pay_tran_number   => rec.tbrappl_pay_tran_number,
											p_chg_tran_number   => rec.tbrappl_chg_tran_number,
											p_amount            => rec.tbrappl_amount,
											p_appl_rowid        => rec.tbrappl_rowid);

										p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => 'Desaplica pagos por transaccion para Intentar generar prefactura:' ||rec_data.sfrstcr_pidm||
													 ' id ' ||gb_common.f_get_id(rec_data.sfrstcr_pidm)||
													 ' p_pay_tran_number ' ||rec.tbrappl_pay_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_chg_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_amount,
										v_sqlerrm => sqlerrm);
										p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => ' p_pay_tran_number ' ||rec.tbrappl_pay_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_chg_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_amount,
										v_sqlerrm => sqlerrm);								
									END LOOP;
								commit;
							end;*/

						-- Cancelar prefactura							

						  begin
							p_insert_log_bit(id        => p_seq_no,
												   v_paso    => v_pro,
												   v_desc    => 'Cancelar prefactura:' ||
																rec_data.sfrstcr_pidm,
												   v_sqlerrm => sqlerrm);
							OPEN cur_dat_prefact(rec_data.sfrstcr_pidm,p_term);
							FETCH cur_dat_prefact  INTO rec_tzrfact;
							CLOSE cur_dat_prefact;
							baninst1.tzkpufc.p_cancel_sales_doc(
								p_pidm => rec_tzrfact.tzrfact_pidm,
								p_sdoc_code => rec_tzrfact.tzrfact_sdoc_code,
								p_doc_num => rec_tzrfact.tzrfact_doc_number,
								p_data_origin => 'script', -- valor para identificar el origen de la cancelación.
								p_user_id => 'usrprefact', -- puede quedarse éste valor
								p_error_ind => p_error_ind, -- variable de salida
								p_error_msg => p_error_msg -- variable de salida
							  );

							exception
									when others then
									 v_cont_ok := v_cont_ok - 1; 
									 v_cont_no_ok := v_cont_no_ok + 1; 

									  p_insert_log_bit(id        => p_seq_no,
												   v_paso    => v_pro,
												   v_desc    => 'Problemas al cancelar prefactura:' ||
																rec_data.sfrstcr_pidm,
												   v_sqlerrm => sqlerrm);
						  end;								

						--end loop; 
              v_valida_nrc_tckn := 'N';

              open nrc_pidm_term_tckn(p_term,rec_data.sfrstcr_pidm);
              fetch nrc_pidm_term_tckn into v_valida_nrc_tckn;
              close nrc_pidm_term_tckn;

              p_insert_log_bit(id        => p_seq_no,
              v_paso    => v_pro,
              v_desc    => 'Valida nrc calificados para generar prefact.: v_valida_nrc_tckn ' || v_valida_nrc_tckn ||' '||
                            rec_data.sfrstcr_pidm||' p_error_msg: '||p_error_msg,
              v_sqlerrm => sqlerrm);

              IF (v_valida_nrc_tckn='Y') then

                  	p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => 'Desaplica y aplica pagos por transaccion para Intentar generar prefactura:' ||rec_data.sfrstcr_pidm||
													 'id ' ||gb_common.f_get_id(rec_data.sfrstcr_pidm)||
													 'camp ' ||p_camp,
										v_sqlerrm => sqlerrm);

                            begin
									gb_common.p_set_context ('TB_RECEIVABLE',
															  'PROCESS',
															  'APPLPMNT',
															  'N');
									FOR rec in c_desaplica_bec(rec_data.sfrstcr_pidm, rec_data.sfrstcr_term_code) 
									LOOP
									   tv_application.p_process_unapplication (
											p_pidm              => rec.tbrappl_pidm,
											p_pay_tran_number   => rec.tbrappl_pay_tran_number,
											p_chg_tran_number   => rec.tbrappl_chg_tran_number,
											p_amount            => rec.tbrappl_amount,
											p_appl_rowid        => rec.tbrappl_rowid);

										p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => 'Desaplica pagos por transaccion para Intentar generar prefactura:' ||rec_data.sfrstcr_pidm||
													 ' id ' ||gb_common.f_get_id(rec_data.sfrstcr_pidm)||
													 ' p_pay_tran_number ' ||rec.tbrappl_pay_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_chg_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_amount,
										v_sqlerrm => sqlerrm);
										p_insert_log_bit(id        => p_seq_no,
										v_paso    => v_pro,
										v_desc    => ' p_pay_tran_number ' ||rec.tbrappl_pay_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_chg_tran_number||
													 ' p_pay_tran_number ' ||rec.tbrappl_amount,
										v_sqlerrm => sqlerrm);								
									END LOOP;
								commit;
							end;
                        --DBMS_LOCK.Sleep(10);                     

                        --p_aplicatvrappl (p_id => gb_common.f_get_id(rec_data.sfrstcr_pidm),
                        --                     p_update_mode   => 'U',
                        --                     output          => lv_out_stat);
                        --DBMS_LOCK.Sleep(10);                     
                  begin                     
											 tzklscl.p_AplicaTZPPFAC (p_term,
																 gb_common.f_get_id(rec_data.sfrstcr_pidm),
																 'BF',--rec_data_prefac.tzvaccd_sdoc_code,
																 p_camp,
																 'U',
																 output
												);
												commit;
												IF output = 'Y' THEN
													dbms_output.put_line('TZPPFAC ejecutado para id '||gb_common.f_get_id(rec_data.sfrstcr_pidm));
													p_insert_log_bit(id        => p_seq_no,
																   v_paso    => v_pro,
																   v_desc    => 'OK al generar prefactura tckn:' ||
																				rec_data.sfrstcr_pidm||' p_error_msg: '||p_error_msg,
																   v_sqlerrm => sqlerrm);
												ELSE
													dbms_output.put_line('Error al ejecutar TZPPFAC para '||gb_common.f_get_id(rec_data.sfrstcr_pidm));
													p_insert_log_bit(id        => p_seq_no,
																   v_paso    => v_pro,
																   v_desc    => 'Problemas al generar prefactura tckn:' ||
																				rec_data.sfrstcr_pidm||' p_error_msg: '||p_error_msg,
																   v_sqlerrm => sqlerrm);
												END IF;

											 exception
													when others then
													 v_cont_ok := v_cont_ok - 1; 
													 v_cont_no_ok := v_cont_no_ok + 1; 

													  p_insert_log_bit(id        => p_seq_no,
																   v_paso    => v_pro,
																   v_desc    => 'Problemas al generar prefactura tckn:' ||
																				rec_data.sfrstcr_pidm||' p_error_msg: '||p_error_msg,
																   v_sqlerrm => sqlerrm);
											--end;
										--end loop;
                end;	
          end if;
          --
						p_insert_log_bit(id        => p_seq_no,
									 v_paso    => v_pro,
									 v_desc    => 'Proceso finalizado=>' ||
												  'Procesos correctos:' || v_cont_ok ||
												  ',Procesos incorrectos:' || v_cont_no_ok,
									 v_sqlerrm => sqlerrm);

						if v_cont_ok = 0 then
						  rollback;
						  --return - 1;
						end if;
						---log de exceptciones de estudaintes
						for rec_s in cur_student_exception loop
						  p_insert_log_bit(id        => p_seq_no,
									   v_paso    => v_pro,
									   v_desc    => 'Estudiantes con excepción-->ID' ||
													rec_s.iztlcpr_STUDENT_ID || ', PROGRAM:' ||
													rec_s.iztlcpr_PROGRAM,
									   v_sqlerrm => sqlerrm);
						end loop;

					end if;				  
				  end;
				end if;  
			end loop;
		else
			p_err_msg_return := 'Fecha en SFBESTS_END_DATE no es >= '|| sysdate;
			p_insert_log_bit(id        => p_seq_no,
					   v_paso    => v_pro,
					   v_desc    => p_err_msg_return,
					   v_sqlerrm => sqlerrm);
		end if;
		commit;
		--return v_pro;
		 exception
		  when others then
			p_insert_log(id        => p_seq_no,
					   v_paso    => v_pro,
					   v_desc    => 'Error general',
					   v_sqlerrm => sqlerrm); 
		rollback; 
       --return v_pro;--||p_err_msg_return; 
    end p_execute_lc;



  PROCEDURE p_AplicaTZPPFAC(p_term        IN VARCHAR2,
                            p_id 		  in varchar2,
                            p_sdoc_code   in varchar2,
                        	p_site_code   in varchar2,
                            p_update_mode IN VARCHAR2,
                            Output        OUT VARCHAR2)
	--
	-- FILE NAME..: p_AplicaTZPPFAC.sql
	-- RELEASE....:
	-- OBJECT NAME: p_AplicaTZPPFAC
	-- PRODUCT....:
	-- COPYRIGHT..: Copyright (C) Neoris 2020. All rights reserved.
	--
	--
	-- DESCRIPTION:
	--   procedimiento para ejecutar el proceso Generación de Prefactura.
	-- DESCRIPTION END
	--
	AS

		 p_process_name  VARCHAR2(50) :=  'tzppfac';
		 p_process_type  VARCHAR2(50) :=  'C';
		 p_user_id       VARCHAR2(50) :=  'SAISUSR';
		 p_password_crip VARCHAR2(50) :=  'dV9waWNrX2l0';
         --password QA
         --p_Password_Crip VARCHAR2(50) := 'dV9wM2NrXzN0';

		 p_one_up        VARCHAR2(50);
		 p_printer       VARCHAR2(50) :=  'DATABASE';
		 --p_printer       VARCHAR2(50) :=  'NOPRINT';
		 p_form_name     VARCHAR2(50) :=  'LANDSCAPE';
		 p_submit_time   VARCHAR2(50) :=  '';

		 jobsub_shell         VARCHAR2(50);
		 password_decr        VARCHAR2(50);

		 return_pipe          varchar2(30)   := NULL;
		 command_type         varchar2(4)    := 'HOST';

		 command_string       varchar2(100);
		 max_wait_send        integer        := 10;
		 max_size             integer        := 8192;
		 max_wait_receive     integer        := 10;

		 send_status          number;
		 receive_status       number;
		 return_message       varchar2(100);
		 os_type              varchar2(50);

	BEGIN


	  IF (Upper(p_Update_Mode) <> 'U') THEN
		RETURN;
	  END IF;

	  select TWBKBSSF.F_DECODE_BASE64(p_password_crip)
		into password_decr
		from dual;

	  -- solicita siguiente secuencia de ejecucion PRO*C
	  select gjbpseq.nextval
		into p_one_up
		from dual;

	  -- asigna parametros de ejecucion del PRO*C
	  INSERT INTO GJBPRUN( GJBPRUN_JOB,
						   GJBPRUN_ONE_UP_NO,
						   GJBPRUN_NUMBER,
						   GJBPRUN_ACTIVITY_DATE,
						   GJBPRUN_VALUE
						 )
					SELECT GJBPDEF_JOB,
						   p_one_up,
						   GJBPDEF_NUMBER,
						   SYSDATE,
						   DECODE( GJBPDEF_NUMBER,
									1,	p_term	,
									2,	p_id,
									3,	p_sdoc_code,
									4,	''		,
									5,	''		,
									6,	''		,
									7,	''		,
									8,	'N',
									9,	p_site_code
								 )
					  FROM GJBPDFT A,
						   GJBPDFT B,
						   GJBPDEF
					 WHERE GJBPDEF_JOB = UPPER(p_process_name)
					   AND A.GJBPDFT_JOB (+) =  GJBPDEF_JOB
					   AND A.GJBPDFT_JPRM_CODE (+) IS NULL
					   AND A.GJBPDFT_NUMBER (+) = GJBPDEF_NUMBER
					   AND A.GJBPDFT_USER_ID (+) = USER
					   AND B.GJBPDFT_JOB (+) =  GJBPDEF_JOB
					   AND B.GJBPDFT_JPRM_CODE (+) IS NULL
					   AND B.GJBPDFT_NUMBER (+) = GJBPDEF_NUMBER
					   AND B.GJBPDFT_USER_ID (+) IS NULL;
	  commit;

	  return_pipe := gb_advq_util.f_get_unique_token;

	  --   Unix / Linux:  jobsub shell is:  gjajobs.shl
	  --   Windows:       jobsub shell is:  perl gjajobs.pl
	  --
	  select dbms_utility.port_string into os_type from dual;
	  if (os_type like '%WIN%') then
		jobsub_shell := 'perl gjajobs.pl';
	  else
		jobsub_shell := 'gjajobs.shl';
	  end if;

	  command_string := jobsub_shell            || ' ' ||
						p_process_name          || ' ' ||
						p_process_type          || ' ' ||
						p_user_id               || ' ' ||
						password_decr           || ' ' ||
						p_one_up                || ' ' ||
						p_printer               || ' ' ||
						p_form_name             || ' ' ||
						p_submit_time           || ' ';

	  dbms_pipe.pack_message (command_type);
	  dbms_pipe.pack_message (command_string);
	  dbms_pipe.pack_message (return_pipe);

	  --dbms_output.put_line ('Run GURJOBS: ' || command_string);
	  --
	  send_status := dbms_pipe.send_message ('GURJOBS', max_wait_send, max_size);
	  IF send_status = 0 THEN
		receive_status := dbms_pipe.receive_message (return_pipe, max_wait_receive);
		IF receive_status = 0 then
		  Output := 'Y';
		ELSE
		  Output := 'N';
		END IF;
	  ELSE
		Output := 'N';
	  END IF;
	-- -- --
	  EXCEPTION
		WHEN OTHERS THEN
		  Output := 'N';
	END;


      PROCEDURE p_create_header (in_seq_no           NUMBER,
                              in_user_id          VARCHAR2,
                              p_file_number   OUT NUMBER)
   IS
      --constants for '.lis' file report
      const_out_line_headerj CONSTANT VARCHAR2 (130)
            :=    RPAD ('DATE RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'mm/dd/yyyy'), 43, ' ')
               || 'REPORT PAGE' ;
      const_out_line_header2 CONSTANT VARCHAR2 (130)
            :=    RPAD ('TIME RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'hh12:mi:ss AM'), 31, ' ')
               || RPAD ('Reporte de Estudiantes', 70, ' ') ;

      --const_out_line_header3   CONSTANT VARCHAR2 (130) := CHR (01) || LPAD ( 'VERY BASIC APPLICAION MEANT TO TRAIN EMPLOYEES TO CREATE A BANNER JOB', 102, ' ') || LPAD (' ', 27, ' ') ;
      --
      v_status           VARCHAR2 (10);
      v_comments         VARCHAR2 (20000);
      v_file_name        guboutp.guboutp_file_name%TYPE;
      v_file_number      guboutp.guboutp_file_number%TYPE;
      v_environment      VARCHAR2 (25) := NULL;
      v_environment_nm   VARCHAR2 (25);
      v_page_width       NUMBER;
      v_page_break       NUMBER;
   BEGIN
      -- Allocates space for a report
      DBMS_OUTPUT.disable;

      -- Get the name of the instance for which this job is running
      SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') INTO v_environment FROM DUAL;

      --========================================================================
      -- create headers
      --========================================================================
      IF SUBSTR (v_environment, 1, 4) = 'PROD'
      THEN
         v_environment_nm := 'PRODUCTION INSTANCE';
      ELSIF SUBSTR (v_environment, 1, 4) = 'QA'
      THEN
         v_environment_nm := 'PRE-PRODUCTION INSTANCE';
      ELSIF SUBSTR (v_environment, 1, 4) = 'TEST'
      THEN
         v_environment_nm := 'TEST INSTANCE';
      ELSIF SUBSTR (v_environment, 1, 4) = 'DEVL'
      THEN
         v_environment_nm := 'DEVELOPMENT INSTANCE';
      ELSE
         v_environment_nm := 'OTHER INSTANCE';
      END IF;

      gz_report.p_lis_file_header (p_one_up_no         => in_seq_no,
                                   p_user              => in_user_id,
                                   p_job_name          => const_application_name,
                                   p_number_of_lines   => 0,
                                   p_file_number       => v_file_number,
                                   p_status            => v_status,
                                   p_comments          => v_comments);

      p_file_number := NVL (v_file_number, 1);

      -- obtenemos el ancho de la hoja
      v_page_width := gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

      -- obtenemos el numero de linea enq ue hace salto de hoja
      v_page_break :=
         gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');

      -- New page character
      --DBMS_OUTPUT.PUT_LINE ( CHR (12) );
      gz_report.p_put_line (p_one_up_no       => in_seq_no,
                            p_user            => in_user_id,
                            p_job_name        => const_application_name,
                            p_file_number     => v_file_number,
                            p_content_line    => CHR (12),
                            p_content_width   => v_page_width,
                            p_content_align   => 'CENTER', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

      gz_report.p_put_line (p_one_up_no       => in_seq_no,
                            p_user            => in_user_id,
                            p_job_name        => const_application_name,
                            p_file_number     => v_file_number,
                            p_content_line    => const_out_line_headerj,
                            p_content_width   => v_page_width,
                            p_content_align   => 'CENTER', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

      gz_report.p_put_line (p_one_up_no       => in_seq_no,
                            p_user            => in_user_id,
                            p_job_name        => const_application_name,
                            p_file_number     => v_file_number,
                            p_content_line    => const_out_line_header2,
                            p_content_width   => v_page_width,
                            p_content_align   => 'CENTER', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

      gz_report.p_put_line (p_one_up_no       => in_seq_no,
                            p_user            => in_user_id,
                            p_job_name        => const_application_name,
                            p_file_number     => v_file_number,
                            p_content_line    => v_environment_nm,
                            p_content_width   => v_page_width,
                            p_content_align   => 'CENTER', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

      COMMIT;
   --========================================================================

   --   EXCEPTION
   --      WHEN OTHERS
   --      THEN
   --         NULL;
   END p_create_header;


 /*   
  function f_execute_lc2(p_term            number,
                         p_camp            VARCHAR2,
                         p_student_id      varchar2,
                         p_tipo_estudiante varchar2 default 'NUEVO')
    return number is  
      v_param_str     VARCHAR2(1000);
      runsequencenum                  INTEGER;
      sqlErrorMsg varchar2(2000);
  BEGIN

  			v_param_str :='GBA037_4_TIPO|'||p_tipo_estudiante||'|004_3_CAMP|'||p_camp||'|004_2_TERM|'||p_term||'|004_1_ID|'||p_student_id||'';

			gkkpsql.api_executeruleset(pprocess => 'GBA037_MDUU',
										  pruleset => 'GBA037_MDUU_RS',
										  prulesetparameters => v_param_str,
										  pdelimiter => '|',
										  pexecutionmode => 'U',
										  pexceptionmode => '1',
										  pdiagnosticseverity => '30',
										  prunsequencenum => runsequencenum,
										  pmessage => sqlErrorMsg);		

    RETURN 0;
  END;
   */



PROCEDURE p_main (p_one_up_no IN NUMBER, p_user_id IN VARCHAR2)
   IS
      /* *
      * Parameter record type
      */
      TYPE gjbprun_rec IS RECORD (
         r_gjbprun_number   gjbprun.gjbprun_number%TYPE,
         r_gjbprun_value    gjbprun.gjbprun_value%TYPE,
         r_gjbprun_desc     gjbpdef.gjbpdef_desc%TYPE
      );

      /* *
      * Parameter cursor variable type
      */
      TYPE gjbprun_ref IS REF CURSOR
         RETURN gjbprun_rec;

      /* *
      * EXCEPTIONS - This exception is used to indicate that an error was logged so that the
      * calling procedure does not log the error again with an erroneous message.
      */
      exc_issue_already_logged EXCEPTION;

      --
      v_job_num         NUMBER := p_one_up_no;
      v_user_id         VARCHAR2 (50) := USER;
      v_job_ref         gjbprun_ref;
      v_job_rec         gjbprun_rec;
      v_env_nm_before   NUMBER;
      v_env_nm_after    NUMBER;
      v_line_cntr       NUMBER := 0;
      v_page_cntr       NUMBER := 0;
      v_file_number     guboutp.guboutp_file_number%TYPE;
      v_page_width      NUMBER;
      v_page_break      NUMBER;
      v_row_print       VARCHAR2 (1000);
      v_status          VARCHAR2 (10);
      v_comments        VARCHAR2 (20000);
      v_error_count     NUMBER := 0;

      v_err_code        VARCHAR2 (100) := NULL;
      v_err_msg         VARCHAR2 (200) := NULL;

      /*Parametros ProC*/
      v_term            VARCHAR2 (6);                             -- requerido
      v_campus          VARCHAR2 (4);                             -- requerido
      v_level           VARCHAR2 (4);
      v_program         VARCHAR2 (30);
	  v_tipo	 		VARCHAR2 (30);
      v_mod             VARCHAR2 (1);                             -- requerido
      v_pidm            NUMBER (9);
      v_id              varchar2 (20);
      v_name            VARCHAR (60) := NULL;
      v_run_type        VARCHAR2 (30) := NULL;
   BEGIN
      -- creamos archivo lis y pintamos encabezado
      -- RETURN;
      --p_log (p_one_up_no, v_user_id, 'SZKCCCC - p_create_header ');
      p_create_header (p_one_up_no, USER, v_file_number);
      -- obtenemos el ancho de la hoja
      v_page_width := gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

      -- obtenemos el numero de linea enq ue hace salto de hoja
      v_page_break :=
         gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');

      -- Obtener parámetros de GJBPRUN --
      -- Put all the job parm records into a cursor
      OPEN v_job_ref FOR
           SELECT gjbprun_number, gjbprun_value, gjbpdef_desc
             FROM gjbprun, gjbpdef
            WHERE     gjbprun_one_up_no = p_one_up_no
                  AND gjbprun_job = const_application_name
                  AND gjbpdef_job = gjbprun_job
                  AND gjbpdef_number = gjbprun_number
         ORDER BY gjbprun_number ASC;

      -- Work through the parameter records and assign them to the appropriate variable
      LOOP
         FETCH v_job_ref INTO v_job_rec;

         EXIT WHEN v_job_ref%NOTFOUND; -- When we run out of records we will exit the loop

         -- Se imprime en el archivo LIS las variables
         gz_report.p_put_line (
            p_one_up_no       => p_one_up_no,
            p_user            => v_user_id,
            p_job_name        => const_application_name,
            p_file_number     => NVL (v_file_number, 1),
            p_content_line    =>   v_job_rec.r_gjbprun_number
                                || ' - '
                                || v_job_rec.r_gjbprun_desc
                                || ' - '
                                || nvl(v_job_rec.r_gjbprun_value,'Se procesan todos.')
                                || '.',
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',                -- LEFT, RIGHT, CENTER
            p_status          => v_status,
            p_comments        => v_comments);

         --p_log (
            --p_one_up_no,
            --v_user_id,
            --   'SZKCCCC - Parámetros: '
            --|| v_job_rec.r_gjbprun_number
            --|| ' - '
            --|| v_job_rec.r_gjbprun_desc
            --|| ' - '
           -- || v_job_rec.r_gjbprun_value
            --|| '.');

         -- almacenamos en variables locales los valores a ocupar para procesar los datos
         CASE v_job_rec.r_gjbprun_number
            WHEN '01'
            THEN
			   v_id := v_job_rec.r_gjbprun_value;
            WHEN '02'
            THEN
               v_term := v_job_rec.r_gjbprun_value;
            WHEN '03'
            THEN
               v_campus := v_job_rec.r_gjbprun_value;
			WHEN '04'
            THEN
               v_tipo := v_job_rec.r_gjbprun_value;
            ELSE
               NULL;
         END CASE;
      END LOOP;

      -- If no parameters required are found, the job must be stopped
      IF (v_term IS NULL OR v_campus IS NULL OR v_tipo IS NULL)
      THEN
         -- Log the end of the job
         --p_log (
            --p_one_up_no,
            --v_user_id,
            --   'SZKCCCC - No parameters found. TERM: '
            --|| v_term
            --|| ', Run Mode: '
            --|| v_campus
           -- || '. ');


         -- se imprime mensaje en archivo LIS
         gz_report.p_put_line (
            p_one_up_no       => p_one_up_no,
            p_user            => v_user_id,
            p_job_name        => const_application_name,
            p_file_number     => 1,                           --v_file_number,
            p_content_line    => 'SZKDNRC - Invalid parameters found.',
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',                -- LEFT, RIGHT, CENTER
            p_status          => v_status,
            p_comments        => v_comments);

         --RAISE exc_issue_already_logged;
      END IF;

      CLOSE v_job_ref;

      --p_log (p_one_up_no, v_user_id, 'Inicio de Proceso de alumnos.');

      --Proceso que obtiene a los alumnos a reportar --

       p_term       := v_term;
       p_camp       := v_campus;
       p_student_id := v_id;
       p_tipo_alumno := v_tipo;

       if v_id is not null then            
            v_pidm := gb_common.f_get_pidm (p_student_id);
       else
        v_pidm := null;
       end if;

       p_execute_lc (p_one_up_no,v_term,v_campus,v_pidm,v_tipo);


      --p_log (p_one_up_no, v_user_id, 'Fin de Proceso de copia de componentes calificables.');


      --IF v_err_code = 'OK'
      --THEN
         v_row_print := 'Proceso SZKDNRC, ejecutado satisfactoriamente.';
         gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                               p_user            => v_user_id,
                               p_job_name        => const_application_name,
                               p_file_number     => NVL (v_file_number, 1),
                               p_content_line    => v_row_print,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
      -- Iniciamos con el pintado del log --      
      --END IF;

      gb_common.p_commit;
   End p_main;

  procedure p_restore_process(p_proc number) is
  begin

    insert into saturn.sfrstcr
      (sfrstcr_term_code,
       sfrstcr_pidm,
       sfrstcr_crn,
       sfrstcr_class_sort_key,
       sfrstcr_reg_seq,
       sfrstcr_ptrm_code,
       sfrstcr_rsts_code,
       sfrstcr_rsts_date,
       sfrstcr_error_flag,
       sfrstcr_message,
       sfrstcr_bill_hr,
       sfrstcr_waiv_hr,
       sfrstcr_credit_hr,
       sfrstcr_bill_hr_hold,
       sfrstcr_credit_hr_hold,
       sfrstcr_gmod_code,
       sfrstcr_grde_code,
       sfrstcr_grde_code_mid,
       sfrstcr_grde_date,
       sfrstcr_dupl_over,
       sfrstcr_link_over,
       sfrstcr_corq_over,
       sfrstcr_preq_over,
       sfrstcr_time_over,
       sfrstcr_capc_over,
       sfrstcr_levl_over,
       sfrstcr_coll_over,
       sfrstcr_majr_over,
       sfrstcr_clas_over,
       sfrstcr_appr_over,
       sfrstcr_appr_received_ind,
       sfrstcr_add_date,
       sfrstcr_activity_date,
       sfrstcr_levl_code,
       sfrstcr_camp_code,
       sfrstcr_reserved_key,
       sfrstcr_attend_hr,
       sfrstcr_rept_over,
       sfrstcr_rpth_over,
       sfrstcr_test_over,
       sfrstcr_camp_over,
       sfrstcr_user,
       sfrstcr_degc_over,
       sfrstcr_prog_over,
       sfrstcr_last_attend,
       sfrstcr_gcmt_code,
       sfrstcr_data_origin,
       sfrstcr_assess_activity_date,
       sfrstcr_dept_over,
       sfrstcr_atts_over,
       sfrstcr_chrt_over,
       sfrstcr_rmsg_cde,
       sfrstcr_wl_priority,
       sfrstcr_wl_priority_orig,
       sfrstcr_grde_code_incmp_final,
       sfrstcr_incomplete_ext_date,
       sfrstcr_mexc_over,
       sfrstcr_stsp_key_sequence,
       sfrstcr_surrogate_id,
       sfrstcr_version,
       sfrstcr_user_id,
       sfrstcr_vpdi_code,
       sfrstcr_brdh_seq_num,
       sfrstcr_blck_code,
       sfrstcr_strh_seqno,
       sfrstcr_strd_seqno,
       sfrstcr_sessionid,
       sfrstcr_current_time)

      (select sfrstcr_term_code,
              sfrstcr_pidm,
              sfrstcr_crn,
              sfrstcr_class_sort_key,
              sfrstcr_reg_seq,
              sfrstcr_ptrm_code,
              sfrstcr_rsts_code,
              sfrstcr_rsts_date,
              sfrstcr_error_flag,
              sfrstcr_message,
              sfrstcr_bill_hr,
              sfrstcr_waiv_hr,
              sfrstcr_credit_hr,
              sfrstcr_bill_hr_hold,
              sfrstcr_credit_hr_hold,
              sfrstcr_gmod_code,
              sfrstcr_grde_code,
              sfrstcr_grde_code_mid,
              sfrstcr_grde_date,
              sfrstcr_dupl_over,
              sfrstcr_link_over,
              sfrstcr_corq_over,
              sfrstcr_preq_over,
              sfrstcr_time_over,
              sfrstcr_capc_over,
              sfrstcr_levl_over,
              sfrstcr_coll_over,
              sfrstcr_majr_over,
              sfrstcr_clas_over,
              sfrstcr_appr_over,
              sfrstcr_appr_received_ind,
              sfrstcr_add_date,
              sfrstcr_activity_date,
              sfrstcr_levl_code,
              sfrstcr_camp_code,
              sfrstcr_reserved_key,
              sfrstcr_attend_hr,
              sfrstcr_rept_over,
              sfrstcr_rpth_over,
              sfrstcr_test_over,
              sfrstcr_camp_over,
              sfrstcr_user,
              sfrstcr_degc_over,
              sfrstcr_prog_over,
              sfrstcr_last_attend,
              sfrstcr_gcmt_code,
              sfrstcr_data_origin,
              sfrstcr_assess_activity_date,
              sfrstcr_dept_over,
              sfrstcr_atts_over,
              sfrstcr_chrt_over,
              sfrstcr_rmsg_cde,
              sfrstcr_wl_priority,
              sfrstcr_wl_priority_orig,
              sfrstcr_grde_code_incmp_final,
              sfrstcr_incomplete_ext_date,
              sfrstcr_mexc_over,
              sfrstcr_stsp_key_sequence,
              sfrstcr_surrogate_id,
              sfrstcr_version,
              sfrstcr_user_id,
              sfrstcr_vpdi_code,
              sfrstcr_brdh_seq_num,
              sfrstcr_blck_code,
              sfrstcr_strh_seqno,
              sfrstcr_strd_seqno,
              sfrstcr_sessionid,
              sfrstcr_current_time
         from aud_sfrstcr
        where proceso = p_proc
          and nvl(restaurado, 'N') <> 'Y');

    UPDATE aud_sfrstcr
       SET restaurado = 'Y'
     WHERE proceso = p_proc
       and nvl(restaurado, 'N') <> 'Y';
  end;

  procedure p_restore_process_nrc(p_proc number, p_nrc varchar2) is
  begin

    insert into saturn.sfrstcr
      (sfrstcr_term_code,
       sfrstcr_pidm,
       sfrstcr_crn,
       sfrstcr_class_sort_key,
       sfrstcr_reg_seq,
       sfrstcr_ptrm_code,
       sfrstcr_rsts_code,
       sfrstcr_rsts_date,
       sfrstcr_error_flag,
       sfrstcr_message,
       sfrstcr_bill_hr,
       sfrstcr_waiv_hr,
       sfrstcr_credit_hr,
       sfrstcr_bill_hr_hold,
       sfrstcr_credit_hr_hold,
       sfrstcr_gmod_code,
       sfrstcr_grde_code,
       sfrstcr_grde_code_mid,
       sfrstcr_grde_date,
       sfrstcr_dupl_over,
       sfrstcr_link_over,
       sfrstcr_corq_over,
       sfrstcr_preq_over,
       sfrstcr_time_over,
       sfrstcr_capc_over,
       sfrstcr_levl_over,
       sfrstcr_coll_over,
       sfrstcr_majr_over,
       sfrstcr_clas_over,
       sfrstcr_appr_over,
       sfrstcr_appr_received_ind,
       sfrstcr_add_date,
       sfrstcr_activity_date,
       sfrstcr_levl_code,
       sfrstcr_camp_code,
       sfrstcr_reserved_key,
       sfrstcr_attend_hr,
       sfrstcr_rept_over,
       sfrstcr_rpth_over,
       sfrstcr_test_over,
       sfrstcr_camp_over,
       sfrstcr_user,
       sfrstcr_degc_over,
       sfrstcr_prog_over,
       sfrstcr_last_attend,
       sfrstcr_gcmt_code,
       sfrstcr_data_origin,
       sfrstcr_assess_activity_date,
       sfrstcr_dept_over,
       sfrstcr_atts_over,
       sfrstcr_chrt_over,
       sfrstcr_rmsg_cde,
       sfrstcr_wl_priority,
       sfrstcr_wl_priority_orig,
       sfrstcr_grde_code_incmp_final,
       sfrstcr_incomplete_ext_date,
       sfrstcr_mexc_over,
       sfrstcr_stsp_key_sequence,
       sfrstcr_surrogate_id,
       sfrstcr_version,
       sfrstcr_user_id,
       sfrstcr_vpdi_code,
       sfrstcr_brdh_seq_num,
       sfrstcr_blck_code,
       sfrstcr_strh_seqno,
       sfrstcr_strd_seqno,
       sfrstcr_sessionid,
       sfrstcr_current_time)

      (select sfrstcr_term_code,
              sfrstcr_pidm,
              sfrstcr_crn,
              sfrstcr_class_sort_key,
              sfrstcr_reg_seq,
              sfrstcr_ptrm_code,
              sfrstcr_rsts_code,
              sfrstcr_rsts_date,
              sfrstcr_error_flag,
              sfrstcr_message,
              sfrstcr_bill_hr,
              sfrstcr_waiv_hr,
              sfrstcr_credit_hr,
              sfrstcr_bill_hr_hold,
              sfrstcr_credit_hr_hold,
              sfrstcr_gmod_code,
              sfrstcr_grde_code,
              sfrstcr_grde_code_mid,
              sfrstcr_grde_date,
              sfrstcr_dupl_over,
              sfrstcr_link_over,
              sfrstcr_corq_over,
              sfrstcr_preq_over,
              sfrstcr_time_over,
              sfrstcr_capc_over,
              sfrstcr_levl_over,
              sfrstcr_coll_over,
              sfrstcr_majr_over,
              sfrstcr_clas_over,
              sfrstcr_appr_over,
              sfrstcr_appr_received_ind,
              sfrstcr_add_date,
              sfrstcr_activity_date,
              sfrstcr_levl_code,
              sfrstcr_camp_code,
              sfrstcr_reserved_key,
              sfrstcr_attend_hr,
              sfrstcr_rept_over,
              sfrstcr_rpth_over,
              sfrstcr_test_over,
              sfrstcr_camp_over,
              sfrstcr_user,
              sfrstcr_degc_over,
              sfrstcr_prog_over,
              sfrstcr_last_attend,
              sfrstcr_gcmt_code,
              sfrstcr_data_origin,
              sfrstcr_assess_activity_date,
              sfrstcr_dept_over,
              sfrstcr_atts_over,
              sfrstcr_chrt_over,
              sfrstcr_rmsg_cde,
              sfrstcr_wl_priority,
              sfrstcr_wl_priority_orig,
              sfrstcr_grde_code_incmp_final,
              sfrstcr_incomplete_ext_date,
              sfrstcr_mexc_over,
              sfrstcr_stsp_key_sequence,
              sfrstcr_surrogate_id,
              sfrstcr_version,
              sfrstcr_user_id,
              sfrstcr_vpdi_code,
              sfrstcr_brdh_seq_num,
              sfrstcr_blck_code,
              sfrstcr_strh_seqno,
              sfrstcr_strd_seqno,
              sfrstcr_sessionid,
              sfrstcr_current_time
         from aud_sfrstcr
        where proceso = p_proc
          and sfrstcr_crn = p_nrc
          and nvl(restaurado, 'N') <> 'Y');
    UPDATE aud_sfrstcr
       SET restaurado = 'Y'
     where proceso = p_proc
       and sfrstcr_crn = p_nrc
       and nvl(restaurado, 'N') <> 'Y';
  end;

  procedure p_restore_process_pidm(p_proc number, p_pidm number) is
  begin
    insert into saturn.sfrstcr
      (sfrstcr_term_code,
       sfrstcr_pidm,
       sfrstcr_crn,
       sfrstcr_class_sort_key,
       sfrstcr_reg_seq,
       sfrstcr_ptrm_code,
       sfrstcr_rsts_code,
       sfrstcr_rsts_date,
       sfrstcr_error_flag,
       sfrstcr_message,
       sfrstcr_bill_hr,
       sfrstcr_waiv_hr,
       sfrstcr_credit_hr,
       sfrstcr_bill_hr_hold,
       sfrstcr_credit_hr_hold,
       sfrstcr_gmod_code,
       sfrstcr_grde_code,
       sfrstcr_grde_code_mid,
       sfrstcr_grde_date,
       sfrstcr_dupl_over,
       sfrstcr_link_over,
       sfrstcr_corq_over,
       sfrstcr_preq_over,
       sfrstcr_time_over,
       sfrstcr_capc_over,
       sfrstcr_levl_over,
       sfrstcr_coll_over,
       sfrstcr_majr_over,
       sfrstcr_clas_over,
       sfrstcr_appr_over,
       sfrstcr_appr_received_ind,
       sfrstcr_add_date,
       sfrstcr_activity_date,
       sfrstcr_levl_code,
       sfrstcr_camp_code,
       sfrstcr_reserved_key,
       sfrstcr_attend_hr,
       sfrstcr_rept_over,
       sfrstcr_rpth_over,
       sfrstcr_test_over,
       sfrstcr_camp_over,
       sfrstcr_user,
       sfrstcr_degc_over,
       sfrstcr_prog_over,
       sfrstcr_last_attend,
       sfrstcr_gcmt_code,
       sfrstcr_data_origin,
       sfrstcr_assess_activity_date,
       sfrstcr_dept_over,
       sfrstcr_atts_over,
       sfrstcr_chrt_over,
       sfrstcr_rmsg_cde,
       sfrstcr_wl_priority,
       sfrstcr_wl_priority_orig,
       sfrstcr_grde_code_incmp_final,
       sfrstcr_incomplete_ext_date,
       sfrstcr_mexc_over,
       sfrstcr_stsp_key_sequence,
       sfrstcr_surrogate_id,
       sfrstcr_version,
       sfrstcr_user_id,
       sfrstcr_vpdi_code,
       sfrstcr_brdh_seq_num,
       sfrstcr_blck_code,
       sfrstcr_strh_seqno,
       sfrstcr_strd_seqno,
       sfrstcr_sessionid,
       sfrstcr_current_time)

      (select sfrstcr_term_code,
              sfrstcr_pidm,
              sfrstcr_crn,
              sfrstcr_class_sort_key,
              sfrstcr_reg_seq,
              sfrstcr_ptrm_code,
              sfrstcr_rsts_code,
              sfrstcr_rsts_date,
              sfrstcr_error_flag,
              sfrstcr_message,
              sfrstcr_bill_hr,
              sfrstcr_waiv_hr,
              sfrstcr_credit_hr,
              sfrstcr_bill_hr_hold,
              sfrstcr_credit_hr_hold,
              sfrstcr_gmod_code,
              sfrstcr_grde_code,
              sfrstcr_grde_code_mid,
              sfrstcr_grde_date,
              sfrstcr_dupl_over,
              sfrstcr_link_over,
              sfrstcr_corq_over,
              sfrstcr_preq_over,
              sfrstcr_time_over,
              sfrstcr_capc_over,
              sfrstcr_levl_over,
              sfrstcr_coll_over,
              sfrstcr_majr_over,
              sfrstcr_clas_over,
              sfrstcr_appr_over,
              sfrstcr_appr_received_ind,
              sfrstcr_add_date,
              sfrstcr_activity_date,
              sfrstcr_levl_code,
              sfrstcr_camp_code,
              sfrstcr_reserved_key,
              sfrstcr_attend_hr,
              sfrstcr_rept_over,
              sfrstcr_rpth_over,
              sfrstcr_test_over,
              sfrstcr_camp_over,
              sfrstcr_user,
              sfrstcr_degc_over,
              sfrstcr_prog_over,
              sfrstcr_last_attend,
              sfrstcr_gcmt_code,
              sfrstcr_data_origin,
              sfrstcr_assess_activity_date,
              sfrstcr_dept_over,
              sfrstcr_atts_over,
              sfrstcr_chrt_over,
              sfrstcr_rmsg_cde,
              sfrstcr_wl_priority,
              sfrstcr_wl_priority_orig,
              sfrstcr_grde_code_incmp_final,
              sfrstcr_incomplete_ext_date,
              sfrstcr_mexc_over,
              sfrstcr_stsp_key_sequence,
              sfrstcr_surrogate_id,
              sfrstcr_version,
              sfrstcr_user_id,
              sfrstcr_vpdi_code,
              sfrstcr_brdh_seq_num,
              sfrstcr_blck_code,
              sfrstcr_strh_seqno,
              sfrstcr_strd_seqno,
              sfrstcr_sessionid,
              sfrstcr_current_time
         from aud_sfrstcr
        where proceso = p_proc
          and sfrstcr_pidm = p_pidm
          and nvl(restaurado, 'N') <> 'Y');
  end;

  procedure p_restore_process_pidm_nrc(p_proc number,
                                       p_pidm number,
                                       p_nrc  varchar2) is
  begin
    insert into saturn.sfrstcr
      (sfrstcr_term_code,
       sfrstcr_pidm,
       sfrstcr_crn,
       sfrstcr_class_sort_key,
       sfrstcr_reg_seq,
       sfrstcr_ptrm_code,
       sfrstcr_rsts_code,
       sfrstcr_rsts_date,
       sfrstcr_error_flag,
       sfrstcr_message,
       sfrstcr_bill_hr,
       sfrstcr_waiv_hr,
       sfrstcr_credit_hr,
       sfrstcr_bill_hr_hold,
       sfrstcr_credit_hr_hold,
       sfrstcr_gmod_code,
       sfrstcr_grde_code,
       sfrstcr_grde_code_mid,
       sfrstcr_grde_date,
       sfrstcr_dupl_over,
       sfrstcr_link_over,
       sfrstcr_corq_over,
       sfrstcr_preq_over,
       sfrstcr_time_over,
       sfrstcr_capc_over,
       sfrstcr_levl_over,
       sfrstcr_coll_over,
       sfrstcr_majr_over,
       sfrstcr_clas_over,
       sfrstcr_appr_over,
       sfrstcr_appr_received_ind,
       sfrstcr_add_date,
       sfrstcr_activity_date,
       sfrstcr_levl_code,
       sfrstcr_camp_code,
       sfrstcr_reserved_key,
       sfrstcr_attend_hr,
       sfrstcr_rept_over,
       sfrstcr_rpth_over,
       sfrstcr_test_over,
       sfrstcr_camp_over,
       sfrstcr_user,
       sfrstcr_degc_over,
       sfrstcr_prog_over,
       sfrstcr_last_attend,
       sfrstcr_gcmt_code,
       sfrstcr_data_origin,
       sfrstcr_assess_activity_date,
       sfrstcr_dept_over,
       sfrstcr_atts_over,
       sfrstcr_chrt_over,
       sfrstcr_rmsg_cde,
       sfrstcr_wl_priority,
       sfrstcr_wl_priority_orig,
       sfrstcr_grde_code_incmp_final,
       sfrstcr_incomplete_ext_date,
       sfrstcr_mexc_over,
       sfrstcr_stsp_key_sequence,
       sfrstcr_surrogate_id,
       sfrstcr_version,
       sfrstcr_user_id,
       sfrstcr_vpdi_code,
       sfrstcr_brdh_seq_num,
       sfrstcr_blck_code,
       sfrstcr_strh_seqno,
       sfrstcr_strd_seqno,
       sfrstcr_sessionid,
       sfrstcr_current_time)

      (select sfrstcr_term_code,
              sfrstcr_pidm,
              sfrstcr_crn,
              sfrstcr_class_sort_key,
              sfrstcr_reg_seq,
              sfrstcr_ptrm_code,
              sfrstcr_rsts_code,
              sfrstcr_rsts_date,
              sfrstcr_error_flag,
              sfrstcr_message,
              sfrstcr_bill_hr,
              sfrstcr_waiv_hr,
              sfrstcr_credit_hr,
              sfrstcr_bill_hr_hold,
              sfrstcr_credit_hr_hold,
              sfrstcr_gmod_code,
              sfrstcr_grde_code,
              sfrstcr_grde_code_mid,
              sfrstcr_grde_date,
              sfrstcr_dupl_over,
              sfrstcr_link_over,
              sfrstcr_corq_over,
              sfrstcr_preq_over,
              sfrstcr_time_over,
              sfrstcr_capc_over,
              sfrstcr_levl_over,
              sfrstcr_coll_over,
              sfrstcr_majr_over,
              sfrstcr_clas_over,
              sfrstcr_appr_over,
              sfrstcr_appr_received_ind,
              sfrstcr_add_date,
              sfrstcr_activity_date,
              sfrstcr_levl_code,
              sfrstcr_camp_code,
              sfrstcr_reserved_key,
              sfrstcr_attend_hr,
              sfrstcr_rept_over,
              sfrstcr_rpth_over,
              sfrstcr_test_over,
              sfrstcr_camp_over,
              sfrstcr_user,
              sfrstcr_degc_over,
              sfrstcr_prog_over,
              sfrstcr_last_attend,
              sfrstcr_gcmt_code,
              sfrstcr_data_origin,
              sfrstcr_assess_activity_date,
              sfrstcr_dept_over,
              sfrstcr_atts_over,
              sfrstcr_chrt_over,
              sfrstcr_rmsg_cde,
              sfrstcr_wl_priority,
              sfrstcr_wl_priority_orig,
              sfrstcr_grde_code_incmp_final,
              sfrstcr_incomplete_ext_date,
              sfrstcr_mexc_over,
              sfrstcr_stsp_key_sequence,
              sfrstcr_surrogate_id,
              sfrstcr_version,
              sfrstcr_user_id,
              sfrstcr_vpdi_code,
              sfrstcr_brdh_seq_num,
              sfrstcr_blck_code,
              sfrstcr_strh_seqno,
              sfrstcr_strd_seqno,
              sfrstcr_sessionid,
              sfrstcr_current_time
         from aud_sfrstcr
        where proceso = p_proc
          and sfrstcr_crn = p_nrc
          and sfrstcr_pidm = p_pidm
          and nvl(restaurado, 'N') <> 'Y');

    UPDATE aud_sfrstcr
       SET restaurado = 'Y'
     where proceso = p_proc
       and sfrstcr_crn = p_nrc
       and sfrstcr_pidm = p_pidm
       and nvl(restaurado, 'N') <> 'Y';
  end;

  procedure report_process(v_proc number) is
    l_xls               blob;
    sheet_id            pls_integer; -- Worksheet ID
    row_id              pls_integer; -- Row ID
    l_format_encabezado pls_integer; -- Format ID
    l_format_detalle    pls_integer; -- Format ID
    font_encabezados    pls_integer; -- Font ID
    fuente_detalle      pls_integer; -- Font ID

    cursor cur_rep is

      select PROCESO, --SHRTCKN_CRSE_TITLE,
             SSBSECT_CRSE_NUMB || SSBSECT_SUBJ_CODE CURSO,
             sovlcur_pidm SOVLCUR_CAMP_CODE,
             gb_common.f_get_id(sovlcur_pidm) ID,
             sfrstcr_rsts_date,
             SFRSTCR_RSTS_CODE,
             SFRSTCR_CRN NRC,
             SOVLCUR.SOVLCUR_PROGRAM PROGRAMA,
             SMRPRLE_PROGRAM_DESC NOMBRE_PROGRAMA,
             SSBSECT_SUBJ_CODE,
             SSBSECT_CRSE_NUMB,
             (SELECT SPBPERS_SSN
                FROM SPBPERS
               WHERE SPBPERS_PIDM = SPRIDEN_PIDM
                 AND ROWNUM < 2) AS CEDULA,

             (NVL(SPRIDEN_LAST_NAME, '') || ' ' ||
             NVL(SPRIDEN_FIRST_NAME, '') || ' ' || NVL(SPRIDEN_MI, '')) AS NOMBRE

        from SPRIDEN, AUD_SFRSTCR SFRSTCR, sovlcur, SMRPRLE, SSBSECT /*,
                                     (SELECT SHRTCKN_PIDM PIDM,
                                                            SHRTCKN_SUBJ_CODE MATE
                                                            ,SHRTCKN_CRSE_NUMB CRSE
                                                            ,SHRTCKN_CRSE_TITLE
                                                            FROM SHRTCKN,SHRTCKG

                                                            WHERE SHRTCKN_PIDM = SHRTCKG_PIDM
                                                            AND SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE
                                                            AND SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO
                                                            AND SHRTCKG_SEQ_NO =    (SELECT MAX(CKG.SHRTCKG_SEQ_NO)
                                                                                    FROM SATURN.SHRTCKG CKG
                                                                                    WHERE CKG.SHRTCKG_TERM_CODE = SHRTCKN.SHRTCKN_TERM_CODE
                                                                                    AND CKG.SHRTCKG_PIDM = SHRTCKN.SHRTCKN_PIDM
                                                                                    AND CKG.SHRTCKG_TCKN_SEQ_NO = SHRTCKN.SHRTCKN_SEQ_NO
                                                                                    AND CKG.SHRTCKG_PIDM = SHRTCKN.SHRTCKN_PIDM
                                                                                    GROUP BY SHRTCKG_TCKN_SEQ_NO)

                                                           ) HISTORIA
                              WHERE  SFRSTCR_PIDM  (+)= HISTORIA.PIDM
                            AND SSBSECT_SUBJ_CODE(+)= HISTORIA.MATE
                              AND SSBSECT_CRSE_NUMB(+)= HISTORIA.CRSE
                                 AND */
       where SSBSECT_TERM_CODE = SFRSTCR_TERM_CODE
         AND SSBSECT_CRN = SFRSTCR_CRN
         AND SPRIDEN_PIDM = sovlcur_pidm
         AND SPRIDEN_CHANGE_IND IS NULL
         AND SOVLCUR_KEY_SEQNO = sfrstcr_STSP_KEY_SEQUENCE
         AND sovlcur_current_ind = 'Y'
         AND sovlcur_active_ind = 'Y'
         AND SFRSTCR_CRN = SSBSECT_CRN
         AND SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE
         and SOVLCUR_LMOD_CODE = 'LEARNER'
         and smrprle_program = SOVLCUR_PROGRAM
         and SOVLCUR_pidm = sfrstcr_pidm
         AND PROCESO = v_proc
       order by sovlcur_pidm, SOVLCUR_KEY_SEQNO;
  begin
    ploffx_xlsx.init; -- Initializes generator program variables
    sheet_id := ploffx_xlsx.addWorksheet('Reporte'); -- Add new worksheet
    row_id   := ploffx_xlsx.addRow(sheet_id); -- Add row to the worksheet
    --
    font_encabezados := ploffx_xlsx.addFont(p_font_name => 'Calibri', -- Font family
                                            p_font_size => 14, -- Font size
                                            p_italic    => false, -- Italic
                                            p_underline => false, -- Underline
                                            p_bold      => true, -- Bold
                                            p_color     => '#000000' -- Color
                                            );
    fuente_detalle   := ploffx_xlsx.addFont(p_font_name => 'Calibri', -- Font family
                                            p_font_size => 12, -- Font size
                                            p_italic    => false, -- Italic
                                            p_underline => false, -- Underline
                                            p_bold      => false, -- Bold
                                            p_color     => '#000000' -- Color
                                            );
    --
    l_format_encabezado := ploffx_xlsx.addFormat(p_fontid => font_encabezados);
    l_format_detalle    := ploffx_xlsx.addFormat(p_fontid => fuente_detalle);
    --

    /* Add string type data to a cell */

    declare
      type array_t is varray(50) of varchar2(20);
      array array_t := array_t('PROCESO',
                               'ID_BANNER',
                               'NOMBRE',
                               'CEDULA',
                               'NRC',
                               'PROGRAMA',
                               'NOMBRE_PROGRAMA',
                               'CURSO');
    begin
      for i in 1 .. array.count loop

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => i, -- Column name
                                   p_data      => array(i), -- String in the cell
                                   p_format_id => l_format_encabezado);
      end loop;
    end;

    row_id := ploffx_xlsx.addRow(sheet_id); -- Add row to the worksheet

    declare
      v_cont number := 0;
    begin
      /* Add string type data to a cell */
      for rec_rep in cur_rep loop
        v_cont := v_cont + 1;
        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.PROCESO,
                                   p_format_id => l_format_detalle);

        v_cont := v_cont + 1;

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.ID,
                                   p_format_id => l_format_detalle);
        v_cont := v_cont + 1;

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.NOMBRE,
                                   p_format_id => l_format_detalle);
        v_cont := v_cont + 1;

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.CEDULA,
                                   p_format_id => l_format_detalle);
        v_cont := v_cont + 1;

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.NRC,
                                   p_format_id => l_format_detalle);

        v_cont := v_cont + 1;

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.PROGRAMA,
                                   p_format_id => l_format_detalle);

        v_cont := v_cont + 1;

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.NOMBRE_PROGRAMA,
                                   p_format_id => l_format_detalle);

        v_cont := v_cont + 1;

        ploffx_xlsx.addCell_String(p_ws        => sheet_id, -- Worksheet ID
                                   p_row       => row_id, -- Row ID
                                   p_cell      => v_cont, -- Column name
                                   p_data      => rec_rep.CURSO,
                                   p_format_id => l_format_detalle);

        v_cont := v_cont + 1;

        /*
                                 sovlcur_pidm
        SOVLCUR_CAMP_CODE,
        gb_common.f_get_id(sovlcur_pidm),
        sfrstcr_rsts_date,
        SFRSTCR_RSTS_CODE,
        SFRSTCR_CRN,
        SOVLCUR.SOVLCUR_PROGRAM,
        SMRPRLE_PROGRAM_DESC,
        SSBSECT_SUBJ_CODE,
        SSBSECT_CRSE_NUMB*/
        row_id := ploffx_xlsx.addRow(sheet_id); -- Add row to the worksheet
        v_cont := 0;
      end loop;
    end;
    ploffx_xlsx.getDoc(p_blob_file => l_xls);

    HTP.flush;
    HTP.init;
    --
    OWA_UTIL.mime_header('application/vnd.ms-excel', FALSE);
    HTP.p('Content-Length : ' || DBMS_LOB.getlength(l_xls));
    htp.p('Content-Disposition: inline; filename="reporte_' || v_proc ||
          '.xls"');
    OWA_UTIL.http_header_close;
    WPG_DOCLOAD.download_file(l_xls);  
  end;
end TZKLSCL;



















/
