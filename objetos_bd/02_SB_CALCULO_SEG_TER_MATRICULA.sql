CREATE OR REPLACE PACKAGE            "SB_CALCULO_SEG_TER_MATRICULA" is


function f_majr_code(p_pidm number,v_sp number) return
  varchar2;
  /******************************************************************************
     NAME:       p_reverse_charges_student
     PURPOSE:    reverso cargo segunda y tercera matricula

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        13/10/2019   NEORIS         1. cobro a estudiantes por perder materias

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     sb_calculo_seg_ter_Matricula
        Sysdate:         13/10/2019
        Date and Time:    13/10/2019, 02:15:21 a.m., and  13/10/2019 02:15:22 a.m.
        Username:        Neoris (set in TOAD Options, Procedure Editor)
        Table Name:        (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

FUNCTION f_reverse_charges_student(p_student_pidm      IN NUMBER,
                                      p_periodoprefactura IN VARCHAR2,
                                      sqlErrorMsg IN OUT        VARCHAR2) return varchar2;

  /******************************************************************************
     NAME:       p_sb_calculo_seg_ter_Matricula
     PURPOSE:    pagos a estudiantes por perde materias

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. cobro a estudiantes por perder materias

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     p_sb_calculo_seg_ter_Matricula
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 02:15:21 a.m., and 27/08/2019 02:15:22 a.m.
        Username:        Personal (set in TOAD Options, Procedure Editor)
        Table Name:        (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

  PROCEDURE p_assign_charges_student(p_student_pidm      IN NUMBER,
                                     p_periodoprefactura IN VARCHAR2,
                                     sqlErrorMsg         OUT VARCHAR2);
  /******************************************************************************
     NAME:       p_assign_charges_student
     PURPOSE:    materia perdida segunda y tercera vez
                 SHRGRDE.SHRGRDE_PASSED_IND='Y'
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. calificaciones_aprobadas

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     p_assign_charges_student
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 02:15:21 a.m., and 27/08/2019 02:15:22 a.m.
        Username:        Personal (set in TOAD Options, Procedure Editor)
        Table Name:      shrgrde (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

  FUNCTION f_calificaciones_aprobadas(p_shrgrde_levl_code IN shrgrde.shrgrde_levl_code%TYPE,
                                      p_shrgrde_code      IN shrgrde.shrgrde_code%TYPE)
    RETURN VARCHAR2;
  /******************************************************************************
     NAME:       f_calificaciones_aprobadas
     PURPOSE:    La calificación se identifica en la forma SHAGRDE (SHRGRDE),
                 las calificaciones aprobadas tienen el check de contar en aprobadas.
                 SHRGRDE.SHRGRDE_PASSED_IND='Y'

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. calificaciones_aprobadas

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     f_calificaciones_aprobadas
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 02:15:21 a.m., and 27/08/2019 02:15:22 a.m.
        Username:        Personal (set in TOAD Options, Procedure Editor)
        Table Name:      shrgrde (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

  FUNCTION f_perio_ult_inscr_mater_alumn(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE)
    RETURN VARCHAR2;
  /******************************************************************************
     NAME:       f_perio_ult_inscr_mater_alumn
     PURPOSE:    Ultimo periodo por alumno que escribio materias

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. ultima inscripcion de materias

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     f_perio_ult_inscr_mater_alumn
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 02:15:21 a.m., and 27/08/2019 02:15:22 a.m.
        Username:        Personal (set in TOAD Options, Procedure Editor)
        Table Name:      shrgrde (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

  FUNCTION f_curriculum_level_estudiante(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE)
    RETURN VARCHAR2;
  /******************************************************************************
     NAME:       f_curriculums_level_estudiante
     PURPOSE:    nivel del estudiante

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. ultima inscripcion de materias

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     f_curriculums_level_estudiante
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 02:15:21 p.m., and 27/08/2019 02:15:22 p.m.
        Username:        Neoris (set in TOAD Options, Procedure Editor)
        Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

  FUNCTION f_curriculum_camp_estudiante(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE)
    RETURN VARCHAR2;
  /******************************************************************************
     NAME:       f_curriculum_camp_estudiante
     PURPOSE:    nivel del estudiante

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. ultima inscripcion de materias

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     f_curriculum_camp_estudiante
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 02:15:21 p.m., and 27/08/2019 02:15:22 p.m.
        Username:        Neoris (set in TOAD Options, Procedure Editor)
        Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

  FUNCTION f_detalle_cuen_sin_recargo(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                          p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                          p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
    RETURN VARCHAR2;
  /******************************************************************************
     NAME:       f_detalle_cuen_sin_recargo
     PURPOSE:    Prefacturacion de recargo matricaula concepto A0012 segunda y tercera matricula

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. ultima inscripcion de materias

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     f_detalle_cuen_sin_recargo
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 06:15:21 p.m., and 27/08/2019 06:15:22 p.m.
        Username:        Neoris (set in TOAD Options, Procedure Editor)
        Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/
  FUNCTION      f_detalle_con_recargo(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                      p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                      p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
    RETURN VARCHAR2;

FUNCTION      f_detalle_con_recargoanulado(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                           p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                           p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
RETURN VARCHAR2;
/******************************************************************************
NAME:       f_detalle_con_recargoanulado
PURPOSE:    Prefacturacion de recargo anulado matricula concepto A0012 segunda y tercera matricula

REVISIONS:
Ver        Date        Author           Description
---------  ----------  ---------------  ------------------------------------
1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias

NOTES:

Automatically available Auto Replace Keywords:
Object Name:     f_detalle_con_recargoanulado
Sysdate:         13/10/2019
Date and Time:   13/10/2019, 06:15:21 p.m., and 13/10/2019 06:15:22 p.m.
Username:        Neoris (set in TOAD Options, Procedure Editor)
Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)

******************************************************************************/

FUNCTION   f_saldo_recargoanulado(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                  p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                  p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
 RETURN NUMBER;
    /******************************************************************************
       NAME:       f_detalle_con_recargoanulado
       PURPOSE:    Prefacturacion de recargo anulado matricula concepto A0012 segunda y tercera matricula

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias

       NOTES:

       Automatically available Auto Replace Keywords:
          Object Name:     f_detalle_con_recargoanulado
          Sysdate:         13/10/2019
          Date and Time:   13/10/2019, 06:15:21 p.m., and 13/10/2019 06:15:22 p.m.
          Username:        Neoris (set in TOAD Options, Procedure Editor)
          Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)

    ******************************************************************************/


  FUNCTION f_retencion_estudian_menor_fec(p_sprhold_pidm      IN sprhold.sprhold_pidm%TYPE,
                                          p_sprhold_hldd_code IN sprhold.sprhold_hldd_code%TYPE,
                                          p_sprhold_to_date   IN sprhold.sprhold_to_date%TYPE)
    RETURN VARCHAR2;
  /******************************************************************************
     NAME:       f_codigo_retencion_alumnos
     PURPOSE:    --Con esta información de los estudiantes que tienen los códigos de retención parametrizados en la nueva
           --tabla creada se puede realizar el filtro de búsqueda de los estudiantes cuando inscriban asignaturas.


     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        27/08/2019   NEORIS         1. ultima inscripcion de materias

     NOTES:

     Automatically available Auto Replace Keywords:
        Object Name:     f_codigo_retencion_alumnos
        Sysdate:         27/08/2019
        Date and Time:   27/08/2019, 06:15:21 p.m., and 27/08/2019 06:15:22 p.m.
        Username:        Neoris (set in TOAD Options, Procedure Editor)
        Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)

  ******************************************************************************/

FUNCTION f_calc_program(
  p_student_pidm NUMBER,
  p_subj_code VARCHAR2,
  p_crse_numb VARCHAR2
  ) RETURN VARCHAR2 ;


FUNCTION f_curriculum_level_est_prog(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE,p_programa varchar2)
        RETURN VARCHAR2;

PROCEDURE p_assign_charges_student_upg;

end sb_calculo_seg_ter_Matricula;




/


CREATE OR REPLACE PACKAGE BODY            "SB_CALCULO_SEG_TER_MATRICULA" IS
  v_study_path number;

  function f_majr_code(p_pidm number, v_sp number) return varchar2 is
    v_SORLFOS_MAJR_CODE varchar2(400);
  begin
    select UNIQUE SORLFOS_MAJR_CODE
      INTO v_SORLFOS_MAJR_CODE
      from SORLFOS, SOVLCUR x
     where SORLFOS_pidm = x.SOVLCUR_pidm
       and SORLFOS_CACT_CODE = 'ACTIVE'
       AND x.SOVLCUR_seqno = SORLFOS_LCUR_SEQNO
       AND x.SOVLCUR_LMOD_CODE = 'LEARNER'
       AND x.SOVLCUR_KEY_SEQNO = v_sp
       AND SORLFOS_pidm = p_pidm
       AND SORLFOS_CURRENT_CDE = 'Y'
       AND x.SOVLCUR_current_ind = 'Y'
       AND x.SOVLCUR_active_ind = 'Y'
       AND x.sovlcur_lmod_code = sb_curriculum_str.f_learner
       AND x.SOVLCUR_seqno =
           (select MAX(x1.SOVLCUR_seqno)
              from SOVLCUR x1
             where x1.SOVLCUR_LMOD_CODE = 'LEARNER'
               AND x1.SOVLCUR_KEY_SEQNO = x.SOVLCUR_KEY_SEQNO
               AND x1.SOVLCUR_pidm = x.SOVLCUR_pidm
               AND x1.SOVLCUR_current_ind = 'Y'
               AND x1.SOVLCUR_active_ind = 'Y'
               AND x1.sovlcur_program = x.sovlcur_program
               AND x1.sovlcur_lmod_code = x.sovlcur_lmod_code
               AND x1.sovlcur_lmod_code = sb_curriculum_str.f_learner);

    return v_SORLFOS_MAJR_CODE;
  exception
    when no_data_found then
      return null;
  end f_majr_code;

  FUNCTION f_calc_program(p_student_pidm NUMBER,
                          p_subj_code    VARCHAR2,
                          p_crse_numb    VARCHAR2) RETURN VARCHAR2 IS
    v_cont     number;
    v_programa varchar2(30);
  BEGIN
    v_cont := 0;
    SELECT UNIQUE sorlcur_program
      INTO v_programa
      FROM shrtckn, shrttrm, shrgrde, sorlcur, ssbsect, scbcrse, sfrstcr
     WHERE shrtckn_pidm = shrttrm_pidm
          --  AND        SORLCUR_KEY_SEQNO = SHRTCKN_STSP_KEY_SEQUENCE
       AND shrtckn_term_code = shrttrm_term_code
       and sfrstcr_stsp_key_sequence = SORLCUR_KEY_SEQNO
       AND SHRGRDE_CODE = SUBSTR(shksels.f_shrtckg_value(shrtckn_pidm,
                                                         shrtckn_term_code,
                                                         shrtckn_seq_no,
                                                         1,
                                                         'GC'),
                                 1,
                                 6)
       AND SHRGRDE_LEVL_CODE = SUBSTR(shksels.f_shrtckl_value(shrtckn_pidm,
                                                              shrtckn_term_code,
                                                              shrtckn_seq_no),
                                      1,
                                      2)
       AND SHRGRDE_TERM_CODE_EFFECTIVE =
           (SELECT MAX(X.SHRGRDE_TERM_CODE_EFFECTIVE)
              FROM SHRGRDE X
             WHERE X.SHRGRDE_TERM_CODE_EFFECTIVE <= shrttrm_term_code
               AND X.SHRGRDE_LEVL_CODE = SHRGRDE.SHRGRDE_LEVL_CODE
               AND X.SHRGRDE_GRDE_STATUS_IND = 'A'
               AND X.SHRGRDE_CODE = SHRGRDE.SHRGRDE_CODE)
       AND SORLCUR_PIDM = shrttrm_pidm
       AND SORLCUR_TERM_CODE =
           (SELECT MAX(A.SORLCUR_TERM_CODE)
              FROM SORLCUR A
             WHERE A.SORLCUR_PIDM = SORLCUR.SORLCUR_PIDM
               AND A.SORLCUR_LMOD_CODE = SORLCUR.SORLCUR_LMOD_CODE
               AND A.SORLCUR_CACT_CODE = SORLCUR.SORLCUR_CACT_CODE
               AND A.SORLCUR_KEY_SEQNO = SORLCUR.SORLCUR_KEY_SEQNO
               AND A.SORLCUR_TERM_CODE <= sfrstcr.sfrstcr_term_code)
       AND ssbsect.ssbsect_subj_code = shrtckn_subj_code
       and ssbsect.ssbsect_crse_numb = shrtckn_crse_numb
       AND ssbsect.ssbsect_crn = sfrstcr.sfrstcr_crn
       AND sfrstcr.sfrstcr_term_code = ssbsect.ssbsect_term_code
       AND sfrstcr.sfrstcr_pidm = SORLCUR.SORLCUR_PIDM
       AND scbcrse.scbcrse_subj_code = ssbsect.ssbsect_subj_code
       AND scbcrse.scbcrse_crse_numb = ssbsect.ssbsect_crse_numb
       AND SHRGRDE_PASSED_IND = 'N'
       AND SHRGRDE_GRDE_STATUS_IND = 'A'
       AND SORLCUR_CURRENT_CDE = 'Y'
       AND SORLCUR_LMOD_CODE = 'LEARNER'
       AND SORLCUR_CACT_CODE = 'ACTIVE'
          --   AND     sfrstcr.sfrstcr_term_code = p_periodoprefactura
       AND SHRTTRM_PIDM = p_student_pidm
       AND scbcrse.scbcrse_subj_code = p_subj_code
       AND scbcrse.scbcrse_crse_numb = p_crse_numb;
        log_proceso(SYSDATE,
                                  TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' ||
                                  v_study_path || ',p_student_pidm:' ||
                                  p_student_pidm ||
                                  ', p_periodoprefactura:' ||
                                  '',
                                  'Programa calculado:'||v_programa||', para:p_subj_code:'||p_subj_code||' y p_crse_numb:'||p_crse_numb,
                                  TO_CHAR(v_cont));
    return v_programa;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;


  PROCEDURE p_assign_charges_student_upg is

    /******************************************************************************
    NAME:       p_assign_charges_student_all
    PURPOSE:    materia perdida segunda y tercera vez
    SHRGRDE.SHRGRDE_PASSED_IND='Y'
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        07/26/2021   NEORIS         1. calificaciones_aprobadas
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     p_assign_charges_student_upg
    Sysdate:         07/26/2021
    Date and Time:   07/26/2021, 02:15:21 a.m., and 13/10/2019 02:15:22 a.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      shrgrde (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
		lv_err_msg		  varchar2(400);
		v_pidm                 number;
		v_term_code            varchar2(6);
		v_tbraccd_term_code    tbraccd.tbraccd_term_code%type;
		v_detail_code          varchar2(4);
		v_user                 varchar2(30);
		v_entry_date           date;
		v_amount               number;
		v_effective_date       date;
		v_bill_date            date;
		v_due_date             date;
		v_desc                 varchar2(30);
		v_receipt_number       number;
		v_tran_number_paid     number;
		v_crossref_pidm        number;
		v_crossref_number      number;
		v_crossref_detail_code varchar2(4);
		v_srce_code            varchar2(1);
		v_acct_feed_ind        varchar2(1);
		v_session_number       number;
		v_cshr_end_date        date;
		v_crn                  varchar2(5);
		v_crossref_srce_code   varchar2(1);
		v_loc_mdt              varchar2(1);
		v_loc_mdt_seq          number;
		v_rate                 number;
		v_units                number;
		v_document_number      varchar2(8);
		v_trans_date           date;
		v_payment_id           varchar2(20);
		v_invoice_number       varchar2(8);
		v_statement_date       date;
		v_inv_number_paid      varchar2(8);
		v_curr_code            varchar2(4);
		v_exchange_diff        number;
		v_foreign_amount       number;
		v_late_dcat_code       varchar2(3);
		v_atyp_code            varchar2(2);
		v_atyp_seqno           number;
		v_card_type_vr         varchar2(1);
		v_card_exp_date_vr     date;
		v_card_auth_number_vr  varchar2(12);
		v_crossref_dcat_code   varchar2(3);
		v_orig_chg_ind         varchar2(1);
		v_ccrd_code            varchar2(10);
		v_merchant_id          varchar2(20);
		v_data_origin          varchar2(30);
		v_cpdt_ind             varchar2(1);
		v_override_hold        varchar2(200);
		v_aidy_code            varchar2(4);
		v_stsp_key_sequence    number;
		v_period               varchar2(15);
		v_tran_number_out      number;
		v_rowid_out            varchar2(200);
		v_tax_rept_box_pr      varchar2(2);
		v_tax_rept_box_sg      varchar2(2);
		v_tax_future_ind_pr    varchar2(1);
		v_tax_future_ind_sg    varchar2(1);


		l_holds		varchar2(2);
		l_courses	varchar2(2);
		l_courses_d	varchar2(2);

		l_camp_code sorlcur.sorlcur_camp_code%type;
		l_program	sorlcur.sorlcur_program%type;
		l_key_seqno sorlcur.sorlcur_key_seqno%type;
		l_levl_code sorlcur.sorlcur_levl_code%type;
		l_detail_code szrhdpd.szrhdpd_detail_code%type;
		l_rec_porc	szrhdpd.szrhdpd_rec_porc%type;
		l_detl_calc	szrhdpd.szrhdpd_detl_calc%type;
		l_detl_amt  szrhdpd.szrhdpd_detl_amt%type;
		v_detl_amt  szrhdpd.szrhdpd_detl_amt%type;
		l_per_cred_charge sfrrgfe.sfrrgfe_per_cred_charge%type; 
		l_min_charge 	  sfrrgfe.sfrrgfe_min_charge%type;
		l_rgfe_detl_code 	  sfrrgfe.sfrrgfe_detl_code%type;

		p_student_pidm      NUMBER;
        p_periodoprefactura sorlcur.sorlcur_term_code%type;
		p_programa			sorlcur.sorlcur_program%type;
		p_camp				sorlcur.sorlcur_camp_code%type;
		l_amount_exist		varchar2(1);
		l_balance_rev		tbraccd.tbraccd_balance%type;
		v_fecha_pago           date;
		v_max_pago           date;

		l_date_rec			   date;
		l_insert VARCHAR2(1);
		l_courses_aft_pay date;

		cursor c_campus_programa is
		select unique a2.sovlcur_levl_code,
				 a2.sovlcur_camp_code,
				 a2.sovlcur_program,
				 a2.sovlcur_key_seqno
			from sovlcur a2
		   where sovlcur_term_code =
				 (select max(a.sovlcur_term_code)
					from sovlcur a
				   where a.sovlcur_pidm = a2.sovlcur_pidm
					 and a.sovlcur_lmod_code = a2.sovlcur_lmod_code
					 and a.sovlcur_cact_code = a2.sovlcur_cact_code
					 and a.sovlcur_key_seqno = a2.sovlcur_key_seqno
					 and a.sovlcur_term_code <= p_periodoprefactura)
			 and a2.sovlcur_current_cde = 'Y'
			 and a2.sovlcur_lmod_code = 'LEARNER'
			 and a2.sovlcur_cact_code = 'ACTIVE'
			 and a2.sovlcur_pidm = p_student_pidm;

		cursor c_holds_pidm is
		select 'Y'
		from  sv_sprhold
		where sprhold_pidm = p_student_pidm	    
			and sprhold_hldd_code in
			(
				select szrhdre_hldd_code 
				from szrhdre
			)
			and sprhold_to_date > sysdate;

		cursor c_courses_stcr is
		select unique 'Y'
		from  ssbsect, sfrstcr
		where ssbsect_gradable_ind = 'Y'
			--and sfrstcr_rsts_date <= v_fecha_pago 		
			and sfrstcr_rsts_code   like 'R%' 
			and sfrstcr_pidm        = p_student_pidm
			and ssbsect_term_code   = p_periodoprefactura
			and sfrstcr_term_code   = ssbsect_term_code
			and sfrstcr_crn         = ssbsect_crn
            --
            and ssbsect_subj_code||ssbsect_crse_numb in 
				(select shrtckn_subj_code||shrtckn_crse_numb
                    from shrtckn tckn
                    where tckn.shrtckn_pidm = p_student_pidm 
                    and   (
                          sb_calculo_seg_ter_Matricula.f_calificaciones_aprobadas
                            (
                            substr(shksels.f_shrtckl_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no),1,2),
                            substr(shksels.f_shrtckg_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no,1,'GC'),1,6)
                            ) = 'N'				
                          )
				);
		cursor c_courses_stcr_after_pay is
		select unique 'Y'
		from  ssbsect, sfrstcr
		where ssbsect_gradable_ind = 'Y'
			and sfrstcr_rsts_date > v_fecha_pago 
			and sfrstcr_rsts_code   like 'R%' 
			and sfrstcr_pidm        = p_student_pidm
			and ssbsect_term_code   = p_periodoprefactura
			and sfrstcr_term_code   = ssbsect_term_code
			and sfrstcr_crn         = ssbsect_crn
            --
            and ssbsect_subj_code||ssbsect_crse_numb in 
				(select shrtckn_subj_code||shrtckn_crse_numb
                    from shrtckn tckn
                    where tckn.shrtckn_pidm = p_student_pidm 
                    and   (
                          sb_calculo_seg_ter_Matricula.f_calificaciones_aprobadas
                            (
                            substr(shksels.f_shrtckl_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no),1,2),
                            substr(shksels.f_shrtckg_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no,1,'GC'),1,6)
                            ) = 'N'				
                          )
				);

		cursor c_courses_stcr_sta_d is
		select unique 'Y'
		from  ssbsect, sfrstca--sfrstcr 
		where ssbsect_gradable_ind = 'Y'
			and sfrstca_rsts_code   like 'D%' 
			and sfrstca_pidm        = p_student_pidm
			and sfrstca_term_code   = p_periodoprefactura
			and sfrstca_term_code   = ssbsect_term_code
			and sfrstca_crn         = ssbsect_crn
            and SFRSTCA_SOURCE_CDE = 'BASE'
            and SFRSTCA_SEQ_NUMBER = (select max(SFRSTCA_SEQ_NUMBER) 
                                        from sfrstca 
                                        where sfrstca_pidm      = p_student_pidm
                                        and sfrstca_term_code   = p_periodoprefactura
                                        and sfrstca_term_code   = ssbsect_term_code
                                        and sfrstca_crn         = ssbsect_crn)
            --
            and ssbsect_subj_code||ssbsect_crse_numb in 
				(select shrtckn_subj_code||shrtckn_crse_numb
                    from shrtckn tckn
                    where tckn.shrtckn_pidm = p_student_pidm 
                    and   (
                          sb_calculo_seg_ter_Matricula.f_calificaciones_aprobadas
                            (
                            substr(shksels.f_shrtckl_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no),1,2),
                            substr(shksels.f_shrtckg_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no,1,'GC'),1,6)
                            ) = 'N'				
                          )
				);

			cursor c_hdpd_conf is
			select szrhdpd_detail_code, szrhdpd_rec_porc, szrhdpd_detl_calc, szrhdpd_detl_amt
			from szrhdpd
			where szrhdpd_camp_code = p_camp
			and szrhdpd_term_code = p_periodoprefactura;

			cursor c_rgfe_conf_noprog is 
			select sfrrgfe_detl_code,sfrrgfe_per_cred_charge, sfrrgfe_min_charge
			from sfrrgfe
			where sfrrgfe_term_code = p_periodoprefactura
			and sfrrgfe_detl_code = l_detl_calc--'a006'
			and sfrrgfe_camp_code = p_camp
			and sfrrgfe_type = 'STUDYPATH'
			and sfrrgfe_entry_type = 'R'
			and sfrrgfe_majr_code is null;

			cursor c_rgfe_conf is 
			select sfrrgfe_detl_code,sfrrgfe_per_cred_charge, sfrrgfe_min_charge
			from sfrrgfe
			where sfrrgfe_term_code = p_periodoprefactura
			and sfrrgfe_detl_code = l_detl_calc--'a006'
			and sfrrgfe_camp_code = p_camp
			and sfrrgfe_type = 'STUDYPATH'
			and sfrrgfe_entry_type = 'R'
			and sfrrgfe_majr_code = p_programa;

			cursor c_accd_amount is 
			select tbraccd_amount
			from tbraccd b
			where tbraccd_detail_code = l_detail_code
			and tbraccd_pidm = p_student_pidm
			and tbraccd_term_code = p_periodoprefactura;
			--and tbraccd_stsp_key_sequence = l_key_seqno;    

			cursor c_accd_amount_exist is 
			select unique 'Y'
			from tbraccd b
			where tbraccd_detail_code = l_detail_code
			and tbraccd_pidm = p_student_pidm
			and tbraccd_term_code = p_periodoprefactura
			and tbraccd_amount = v_detl_amt;

			cursor c_accd_date_amount_exist is 
			select max(tbraccd_effective_date)
			from tbraccd b
			where tbraccd_detail_code = l_detail_code
			and tbraccd_pidm = p_student_pidm
			and tbraccd_term_code = p_periodoprefactura
			and tbraccd_amount = v_detl_amt;

			cursor c_accd_exist_rev is 
			select sum (tbraccd_amount)
            --select *
			from tbraccd b
			where tbraccd_detail_code = l_detail_code
			and tbraccd_pidm = p_student_pidm
			and tbraccd_term_code = p_periodoprefactura;
            --having count(*)>1;
			--and tbraccd_amount = :v_detl_amt;


			cursor c_max_pay is
			select max(tzrdprf_pay_date)
			from tzrdprf
				where tzrdprf_pidm      = p_student_pidm
				and   tzrdprf_term_code = p_periodoprefactura
				and   tzrdprf_camp_code = p_camp
				and   tzrdprf_sdoc_code = 'BF';

	   begin
	         gkkpsql.api_retrieverulesetparameter ('004_1_PIDM', p_student_pidm, lv_err_msg);
			 gkkpsql.api_retrieverulesetparameter ('004_2_TERM', p_periodoprefactura, lv_err_msg);
			 gkkpsql.api_retrieverulesetparameter ('004_3_CAMP', p_camp, lv_err_msg);
			 gkkpsql.api_retrieverulesetparameter ('004_4_PROGRAM', p_programa, lv_err_msg);

		   l_holds := null;
		   l_insert := 'N';
		   open c_holds_pidm;
		   fetch c_holds_pidm into l_holds;
		   close c_holds_pidm;

		   l_levl_code := null;
		   l_camp_code := null;
		   l_program := null;
		   l_key_seqno := null;
		   l_detail_code := null; 
		   l_rec_porc := null; 
		   l_detl_calc := null; 
		   l_detl_amt := null;
		   v_detl_amt := null;
		   l_per_cred_charge := null;
		   l_min_charge := null;
		   l_rgfe_detl_code := null;

		   open c_campus_programa;
		   fetch c_campus_programa into l_levl_code,l_camp_code,l_program,l_key_seqno;
		   close c_campus_programa;     	

		   if l_holds = 'Y' then
				--calcular código de detalle a insertar	
				open c_hdpd_conf;
				fetch c_hdpd_conf into l_detail_code, l_rec_porc, l_detl_calc, l_detl_amt;
				close c_hdpd_conf;

				if l_detail_code is not null then
					if l_detl_amt is not null then
						v_detl_amt := l_detl_amt;
					else
					--calcular valores desde reglas de cobro sin programa
						open c_rgfe_conf_noprog;
						fetch c_rgfe_conf_noprog into l_rgfe_detl_code,l_per_cred_charge,l_min_charge;
						close c_rgfe_conf_noprog;  

						if l_rgfe_detl_code is null then-- buscar con programa
							open c_rgfe_conf;
							fetch c_rgfe_conf into l_rgfe_detl_code,l_per_cred_charge,l_min_charge;
							close c_rgfe_conf; 
						end if;
						if l_per_cred_charge = 0 then
							v_detl_amt := l_min_charge * (l_rec_porc / 100);
							else 
							--tomar el valor de tbraccd
								open c_accd_amount;
								fetch c_accd_amount into l_min_charge;
								close c_accd_amount;

								v_detl_amt := l_min_charge * (l_rec_porc / 100);

						end if;
					end if;
				else					
					gkkpsql.writediagnostictodb(40, 'No se encontró código de detalle a insertar');
				end if;

				l_amount_exist := null;
				--validar si ya tiene el recargo para el periodo en tbraccd
				open c_accd_amount_exist;
				fetch c_accd_amount_exist into l_amount_exist;
				close c_accd_amount_exist;
				gkkpsql.writediagnostictodb(40, 'Inicio. validar si ya tiene el recargo para el periodo en tbraccd '|| l_amount_exist);

				--validar si fue reversado, en ese caso debe insertarse
				l_balance_rev := null;
				open c_accd_exist_rev;
				fetch c_accd_exist_rev into l_balance_rev;
				close c_accd_exist_rev;
				gkkpsql.writediagnostictodb(40, 'Inicio. validar si fue reversado '|| l_balance_rev);

				l_insert := 'N';
				v_fecha_pago := tzklscl.f_pay_pidm_term (
								p_student_pidm, 
								p_periodoprefactura,
								l_camp_code
								);	

				l_courses := null;

				open c_courses_stcr;
				fetch c_courses_stcr into l_courses;
				close c_courses_stcr;						

				if l_amount_exist = 'Y' and l_balance_rev = 0 or (l_amount_exist is null) then
					gkkpsql.writediagnostictodb(40, 'hay cargo o se encuentra cargo con reversión ' || p_student_pidm || ' l_amount_exist ' || l_amount_exist ||' l_balance_rev ' || l_balance_rev);		

					if v_detl_amt is not null then	

						l_amount_exist := null;
						--validar si ya tiene el recargo para el periodo en tbraccd
						open c_accd_amount_exist;
						fetch c_accd_amount_exist into l_amount_exist;
						close c_accd_amount_exist;
						gkkpsql.writediagnostictodb(40, 'validar si ya tiene el recargo para el periodo en tbraccd '|| l_amount_exist);

						--validar si fue reversado, en ese caso debe insertarse
						l_balance_rev := null;
						open c_accd_exist_rev;
						fetch c_accd_exist_rev into l_balance_rev;
						close c_accd_exist_rev;
						gkkpsql.writediagnostictodb(40, 'validar si fue reversado '|| l_balance_rev);

						--if l_balance_rev = 0 then
						--	l_amount_exist := null;
						--end if;

						gkkpsql.writediagnostictodb(40, ' pidm ' || p_student_pidm || ' l_holds' || l_holds ||' l_courses' || l_courses || ' p_periodoprefactura '|| p_periodoprefactura);		

						if l_courses = 'Y' then --and l_amount_exist is not null  then
							--insertar transacción
							if l_amount_exist is null then
								l_insert := 'Y';
							else 
								gkkpsql.writediagnostictodb(40, 'Recargo. La transacción de recargo ya existe, se valida reversión');
								if l_balance_rev = 0 then
									gkkpsql.writediagnostictodb(40, 'Recargo. La transacción existe pero fue reversada, se inserta cargo');
									l_insert := 'Y';
								else
									gkkpsql.writediagnostictodb(40, 'Recargo. La transacción existe y no fue reversada, no se inserta cargo');
									l_insert := 'N';
								end if;
							end if;
						else
							l_insert := 'N';
							gkkpsql.writediagnostictodb(40, 'Recargo. No se encontraron cursos perdidos en la historia, con inscripción, no se inserta recargo');
						end if;

					else
						gkkpsql.writediagnostictodb(40, 'Recargo. no fue posible calcular el valor a insertar, no hay configuración');
						l_insert := 'N';	
					end if;
				else
				--if l_insert = 'N' then
					gkkpsql.writediagnostictodb(40, 'No hay cargo o se encuentra cargo sin reversión, no se inserta cargo y se valida posible reversión ' || p_student_pidm || ' l_amount_exist ' || l_amount_exist ||' l_balance_rev ' || l_balance_rev);		

					gkkpsql.writediagnostictodb(40, 'Reversión ');

					l_courses_d := null;
					--validar cursos cancelados, perdidos en la historia
					open c_courses_stcr_sta_d;
					fetch c_courses_stcr_sta_d into l_courses_d; 
					close c_courses_stcr_sta_d;

					l_balance_rev := null;
					open c_accd_exist_rev;
					fetch c_accd_exist_rev into l_balance_rev;
					close c_accd_exist_rev;

					l_courses := null;

					open c_courses_stcr;
					fetch c_courses_stcr into l_courses;
					close c_courses_stcr;	

					gkkpsql.writediagnostictodb(40, 'Reversión. ' || p_student_pidm || ' l_holds ' || l_holds ||' l_courses_d ' || l_courses_d || 'l_courses '|| l_courses || ' v_detl_amt '|| v_detl_amt);	

					if l_balance_rev = 0 then
								gkkpsql.writediagnostictodb(40, 'Reversión. La transacción existe pero fue reversada, no se inserta cargo');
								l_insert := 'N';
					else
						if l_courses_d = 'Y' and l_courses is null and v_detl_amt is not null then
							if v_fecha_pago is null then
								--reversar trnsacción de recargo
								gkkpsql.writediagnostictodb(40, 'Reversión. el estudiante tiene cursos cancelados (perdidos en his. académica), y no tiene pago registrado, se inserta reversión' || p_student_pidm || ' l_holds ' || l_holds ||' l_courses_d ' || l_courses_d || 'l_courses '|| l_courses || ' v_detl_amt '|| v_detl_amt);	
								v_detl_amt := v_detl_amt * -1;
								l_insert := 'Y';
							else
								gkkpsql.writediagnostictodb(40, 'Reversión. el estudiante tiene cursos cancelados (perdidos en his. académica), pero tiene pago registrado, no se inserta reversión' || p_student_pidm || ' l_holds ' || l_holds ||' l_courses_d ' || l_courses_d || 'l_courses '|| l_courses || ' v_detl_amt '|| v_detl_amt);		
								l_insert := 'N';

								--si la fecha maxima de pago de prefacturas es 
								--menor a la fecha de inserción de cargo Reversa

								v_max_pago := null;
								open c_max_pay;
								fetch c_max_pay into v_max_pago;
								close c_max_pay;

								l_date_rec := null;
								open c_accd_date_amount_exist;
								fetch c_accd_date_amount_exist into l_date_rec;
								close c_accd_date_amount_exist;

								gkkpsql.writediagnostictodb(40, 'Reversión. validar si fecha maxima de pago de prefacturas es menor a la fecha de inserción de cargo' || p_student_pidm || ' v_max_pago ' || v_max_pago ||' l_date_rec ' || l_date_rec || 'l_courses '|| l_courses || ' v_detl_amt '|| v_detl_amt);	

								if v_max_pago < l_date_rec then 
									gkkpsql.writediagnostictodb(40, 'Reversión. fecha maxima de pago de prefacturas es menor a la fecha de inserción de cargo se inserta reversión' );	

									v_detl_amt := v_detl_amt * -1;
									l_insert := 'Y';
								else 
									gkkpsql.writediagnostictodb(40, 'Reversión. fecha maxima de pago de prefacturas NO es menor a la fecha de inserción de cargo. NO se inserta reversión' );	

								end if;

							end if;
						else
							gkkpsql.writediagnostictodb(40, 'Reversión. el estudiante no tiene cursos cancelados (o tiene cursos matriculados)(perdidos en his. académica)' || p_student_pidm || ' l_holds ' || l_holds ||' l_courses_d ' || l_courses_d);		
							l_insert := 'N';

						end if;
					end if;
				end if;	

					if l_insert = 'Y' then
						begin
						  v_pidm      := p_student_pidm;
						  v_term_code := p_periodoprefactura;
						  v_detail_code    := l_detail_code;
						  v_user           := 'INTEGRACION';
						  v_entry_date     := sysdate;
						  v_amount         := nvl(v_detl_amt, 0);
						  v_effective_date := sysdate;
						  v_bill_date      := null;
						  v_due_date       := null;
						  v_desc                := '';
						  v_receipt_number       := null;
						  v_tran_number_paid     := null;
						  v_crossref_pidm        := null;
						  v_crossref_number      := null;
						  v_crossref_detail_code := null;
						  v_srce_code            := 'T';
						  v_acct_feed_ind        := 'Y';
						  v_session_number       := 0;
						  v_cshr_end_date        := null;
						  v_crn                  := null;
						  v_crossref_srce_code   := null;
						  v_loc_mdt              := null;
						  v_loc_mdt_seq          := null;
						  v_rate                 := null;
						  v_units                := null;
						  v_document_number      := null;
						  v_trans_date           := sysdate;
						  v_payment_id           := null;
						  v_invoice_number       := null;
						  v_statement_date       := null;
						  v_inv_number_paid      := null;
						  v_curr_code            := null;
						  v_exchange_diff        := null;
						  v_foreign_amount       := null;
						  v_late_dcat_code       := null;
						  v_atyp_code            := null;
						  v_atyp_seqno           := null;
						  v_card_type_vr         := null;
						  v_card_exp_date_vr     := null;
						  v_card_auth_number_vr  := null;
						  v_crossref_dcat_code   := null;
						  v_orig_chg_ind         := null;
						  v_ccrd_code            := null;
						  v_merchant_id          := null;
						  v_data_origin          := 'banner';
						  v_cpdt_ind             := null;
						  v_override_hold        := 'N';
						  v_aidy_code            := null;
						  v_stsp_key_sequence    := v_study_path;
						  v_period               := null;
						  v_tax_rept_box_pr      := null;
						  v_tax_rept_box_sg      := null;
						  v_tax_future_ind_pr    := null;
						  v_tax_future_ind_sg    := null;
						  tb_receivable.p_create(p_pidm                 => v_pidm,
												 p_term_code            => v_term_code,
												 p_detail_code          => v_detail_code,
												 p_user                 => v_user,
												 p_entry_date           => v_entry_date,
												 p_amount               => v_amount,
												 p_effective_date       => v_effective_date,
												 p_bill_date            => v_bill_date,
												 p_due_date             => v_due_date,
												 p_desc                 => v_desc,
												 p_receipt_number       => v_receipt_number,
												 p_tran_number_paid     => v_tran_number_paid,
												 p_crossref_pidm        => v_crossref_pidm,
												 p_crossref_number      => v_crossref_number,
												 p_crossref_detail_code => v_crossref_detail_code,
												 p_srce_code            => v_srce_code,
												 p_acct_feed_ind        => v_acct_feed_ind,
												 p_session_number       => v_session_number,
												 p_cshr_end_date        => v_cshr_end_date,
												 p_crn                  => v_crn,
												 p_crossref_srce_code   => v_crossref_srce_code,
												 p_loc_mdt              => v_loc_mdt,
												 p_loc_mdt_seq          => v_loc_mdt_seq,
												 p_rate                 => v_rate,
												 p_units                => v_units,
												 p_document_number      => v_document_number,
												 p_trans_date           => v_trans_date,
												 p_payment_id           => v_payment_id,
												 p_invoice_number       => v_invoice_number,
												 p_statement_date       => v_statement_date,
												 p_inv_number_paid      => v_inv_number_paid,
												 p_curr_code            => v_curr_code,
												 p_exchange_diff        => v_exchange_diff,
												 p_foreign_amount       => v_foreign_amount,
												 p_late_dcat_code       => v_late_dcat_code,
												 p_atyp_code            => v_atyp_code,
												 p_atyp_seqno           => v_atyp_seqno,
												 p_card_type_vr         => v_card_type_vr,
												 p_card_exp_date_vr     => v_card_exp_date_vr,
												 p_card_auth_number_vr  => v_card_auth_number_vr,
												 p_crossref_dcat_code   => v_crossref_dcat_code,
												 p_orig_chg_ind         => v_orig_chg_ind,
												 p_ccrd_code            => v_ccrd_code,
												 p_merchant_id          => v_merchant_id,
												 p_data_origin          => v_data_origin,
												 p_cpdt_ind             => v_cpdt_ind,
												 p_override_hold        => v_override_hold,
												 p_aidy_code            => v_aidy_code,
												 p_stsp_key_sequence    => v_stsp_key_sequence,
												 p_period               => v_period,
												 p_tran_number_out      => v_tran_number_out,
												 p_rowid_out            => v_rowid_out,
												 p_tax_rept_box_pr      => v_tax_rept_box_pr,
												 p_tax_rept_box_sg      => v_tax_rept_box_sg,
												 p_tax_future_ind_pr    => v_tax_future_ind_pr,
												 p_tax_future_ind_sg    => v_tax_future_ind_sg);
									gkkpsql.writediagnostictodb(40, 'Transacción insertada correctamente = '||v_tran_number_out);					   
						exception when others then
							gkkpsql.writediagnostictodb(40, 'Error al intentar insertar recargo '||sqlerrm);					   
						end;
					else
						gkkpsql.writediagnostictodb(40, 'No se insertó recargo');
					end if;	
		   else
				gkkpsql.writediagnostictodb(40, 'el estudiante no tiene retención por perdida de asignaturas o no tiene inscripción de cursos perdidos pidm ' || p_student_pidm || ' l_holds' || l_holds ||' l_courses' || l_courses);		
		   end if;

	   exception when others then
				gkkpsql.writediagnostictodb(40, 'Error al generar cargos de segunda o tercera matricula '||sqlerrm);		
  END p_assign_charges_student_upg;
  /******************************************************************************
  NAME:       p_reverse_charges_student
  PURPOSE:    reverso cargo segunda y tercera matricula
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        13/10/2019   NEORIS         1. cobro a estudiantes por perder materias
  NOTES:
  Automatically available Auto Replace Keywords:
  Object Name:     sb_calculo_seg_ter_Matricula
  Sysdate:         13/10/2019
  Date and Time:    13/10/2019, 02:15:21 a.m., and  13/10/2019 02:15:22 a.m.
  Username:        Neoris (set in TOAD Options, Procedure Editor)
  Table Name:        (set in the "New PL/SQL Object" dialog)
  ******************************************************************************/
  PROCEDURE p_assign_charges_student(p_student_pidm      IN NUMBER,
                                     p_periodoprefactura IN VARCHAR2,
                                     sqlErrorMsg         OUT VARCHAR2) AS
    v_cont NUMBER;
    v_param_str     VARCHAR2(1000);
    runsequencenum                  INTEGER;

	v_levl             VARCHAR2 (30) := NULL;
	v_program          VARCHAR2 (30) := NULL;

    CURSOR CUR_CAMPUS_PROGRAMA IS
      SELECT UNIQUE               A2.SORLCUR_CAMP_CODE AS CAMPUS,
             A2.SORLCUR_PROGRAM   AS PROGRAMA,
             A2.SORLCUR_KEY_SEQNO AS SP
        FROM sorlcur A2
       WHERE SORLCUR_TERM_CODE =
             (SELECT MAX(A.SORLCUR_TERM_CODE)
                FROM SORLCUR A
               WHERE A.SORLCUR_PIDM = A2.SORLCUR_PIDM
                 AND A.SORLCUR_LMOD_CODE = A2.SORLCUR_LMOD_CODE
                 AND A.SORLCUR_CACT_CODE = A2.SORLCUR_CACT_CODE
                 AND A.SORLCUR_KEY_SEQNO = A2.SORLCUR_KEY_SEQNO
                 AND A.SORLCUR_TERM_CODE <= p_periodoprefactura)
         AND A2.SORLCUR_CURRENT_CDE = 'Y'
         AND A2.SORLCUR_LMOD_CODE = 'LEARNER'
         AND A2.SORLCUR_CACT_CODE = 'ACTIVE'
         AND A2.SORLCUR_PIDM = p_student_pidm
         and A2.SORLCUR_PROGRAM = v_program
         order by 3 desc
         fetch first 1 rows only;
  BEGIN

    v_cont := 0;
    declare
      owner_name  VARCHAR2(100);
      caller_name VARCHAR2(100);
      line_number NUMBER;
      caller_type VARCHAR2(100);
    BEGIN
      OWA_UTIL.WHO_CALLED_ME(owner_name,
                             caller_name,
                             line_number,
                             caller_type);

      log_proceso(SYSDATE,
                  TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                  ',p_student_pidm:' || p_student_pidm ||
                  ', p_periodoprefactura:' || p_periodoprefactura,
                  '!!!!!!!!!!!!->>>>Disparador:' || caller_type || ' ' ||
                  owner_name || '.' || caller_name ||
                  ' called A_PROC from line number ' || line_number,
                  TO_CHAR(v_cont));
      v_cont := v_cont + 1;
    END;

    log_proceso(SYSDATE,
                TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                ',p_student_pidm:' || p_student_pidm ||
                ', p_periodoprefactura:' || p_periodoprefactura,
                '$$$$$$$$$$$$$$--->Inicio verificacion campus',
                TO_CHAR(v_cont));
    v_cont := v_cont + 1;

	v_levl          := TZKPUFC.f_get_sovlcur(p_student_pidm, p_periodoprefactura, 'LEVL' );
	v_program   := TZKPUFC.f_get_sovlcur(p_student_pidm, p_periodoprefactura, 'PROGRAM' );    

	FOR REC_CAMPUS_PROGRAMA IN CUR_CAMPUS_PROGRAMA LOOP

      v_study_path := REC_CAMPUS_PROGRAMA.SP;

      log_proceso(SYSDATE,
                  TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                  ',p_student_pidm:' || p_student_pidm ||
                  ', p_periodoprefactura:' || p_periodoprefactura,
                  '$$$$$$$$$$$$$$--->campus:REC_CAMPUS_PROGRAMA.PROGRAMA:' ||
                  REC_CAMPUS_PROGRAMA.PROGRAMA ||
                  ',REC_CAMPUS_PROGRAMA.CAMPUS' ||
                  REC_CAMPUS_PROGRAMA.CAMPUS || ',sTUDYpATH:' ||
                  v_study_path,
                  TO_CHAR(v_cont));
      v_cont := v_cont + 1;

			v_param_str :='004_4_PROGRAM|'||rec_campus_programa.programa||'|004_3_CAMP|'||rec_campus_programa.campus||'|004_2_TERM|'||p_periodoprefactura||'|004_1_PIDM|'||p_student_pidm||'';

			gkkpsql.api_executeruleset(pprocess => 'SEG_TER_MAT_MDUU',
										  pruleset => 'SEG_TER_MAT_MDUU_RS',
										  prulesetparameters => v_param_str,
										  pdelimiter => '|',
										  pexecutionmode => 'U',
										  pexceptionmode => '1',
										  pdiagnosticseverity => '30',
										  prunsequencenum => runsequencenum,
										  pmessage => sqlErrorMsg);

      IF sqlErrorMsg IS NOT NULL THEN
        CONTINUE;
      END IF;
    END LOOP;
    log_proceso(SYSDATE,
                TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                ',p_student_pidm:' || p_student_pidm ||
                ', p_periodoprefactura:' || p_periodoprefactura,
                '$$$$$$$$$$$$$$--->Fin verificación campus',
                TO_CHAR(v_cont));
    v_cont := v_cont + 1;
  EXCEPTION
    WHEN OTHERS THEN
      log_proceso(SYSDATE,
                  TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                  ',p_student_pidm:' || p_student_pidm ||
                  ', p_periodoprefactura:' || p_periodoprefactura,
                  '$$$$$$$$$$$$$$--->Error campus:' || sqlerrm,
                  TO_CHAR(v_cont));
      v_cont      := v_cont + 1;
      sqlErrorMsg := sqlerrm;
  END p_assign_charges_student;

  FUNCTION f_reverse_charges_student(p_student_pidm      IN NUMBER,
                                     p_periodoprefactura IN VARCHAR2,
                                     sqlErrorMsg         IN OUT VARCHAR2)
    RETURN VARCHAR2 AS
    v_camp                     VARCHAR2(20);
    v_sfrstcr                  sfrstcr%rowtype;
    v_cont_materias            NUMBER := 0;
    v_cont_recargos_eliminadas NUMBER := 0;
    v_TRAN_NUMBER_OUT          NUMBER;
    v_ROWID_OUT                VARCHAR2(200);
    v_cont                     NUMBER;
    v_pass                     NUMBER;
    v_cont_mat                 number;
    CURSOR CUR_RECARGOS(signo NUMBER) IS
      SELECT UNIQUE b.*
        FROM tbraccd b, szrhdpd e
       WHERE b.tbraccd_term_code = e.szrhdpd_term_code --'201961'
         AND b.tbraccd_detail_code = e.szrhdpd_detail_code ---A0012                        
         AND e.szrhdpd_camp_code = NVL(v_camp, e.szrhdpd_camp_code)
         AND b.tbraccd_pidm = p_student_pidm
         AND b.tbraccd_term_code = p_periodoprefactura
         AND signo * b.tbraccd_amount > 0
         AND b.tbraccd_balance != 0
         AND B.tbraccd_stsp_key_sequence = v_study_path;

    CURSOR CUR_RECARGOS_AUX(signo NUMBER) IS
      SELECT UNIQUE b.*
        FROM tbraccd b, szrhdpd e
       WHERE b.tbraccd_term_code = e.szrhdpd_term_code --'201961'
         AND b.tbraccd_detail_code = e.szrhdpd_detail_code ---A0012
         AND e.szrhdpd_camp_code = NVL(v_camp, e.szrhdpd_camp_code)
         AND b.tbraccd_pidm = p_student_pidm
         AND b.tbraccd_term_code = p_periodoprefactura
         AND b.tbraccd_amount < 0
         AND b.tbraccd_balance != 0
         AND B.tbraccd_stsp_key_sequence = v_study_path;

    CURSOR CUR_MATERIAS(ING_DEL VARCHAR2) IS
      SELECT UNIQUE            shrtckn_subj_code, -- MATERIA
             shrtckn_crse_numb, -- CURSO,
             SORLCUR_CAMP_CODE AS CAMPUS,
             shrtckn_pidm      pidm
        FROM shrtckn, shrttrm, shrgrde, sorlcur, ssbsect, scbcrse, sfrstcr
       WHERE shrtckn_pidm = shrttrm_pidm
         AND shrtckn_term_code = shrttrm_term_code
         AND SHRGRDE_CODE = SUBSTR(shksels.f_shrtckg_value(shrtckn_pidm,
                                                           shrtckn_term_code,
                                                           shrtckn_seq_no,
                                                           1,
                                                           'GC'),
                                   1,
                                   6)
         AND SHRGRDE_LEVL_CODE = SUBSTR(shksels.f_shrtckl_value(shrtckn_pidm,
                                                                shrtckn_term_code,
                                                                shrtckn_seq_no),
                                        1,
                                        2)
         AND SHRGRDE_TERM_CODE_EFFECTIVE =
             (SELECT MAX(X.SHRGRDE_TERM_CODE_EFFECTIVE)
                FROM SHRGRDE X
               WHERE X.SHRGRDE_TERM_CODE_EFFECTIVE <= shrttrm_term_code
                 AND X.SHRGRDE_LEVL_CODE = SHRGRDE.SHRGRDE_LEVL_CODE
                 AND X.SHRGRDE_GRDE_STATUS_IND = 'A'
                 AND X.SHRGRDE_CODE = SHRGRDE.SHRGRDE_CODE)
         AND SORLCUR_PIDM = shrttrm_pidm
         AND SORLCUR_TERM_CODE =
             (SELECT MAX(A.SORLCUR_TERM_CODE)
                FROM SORLCUR A
               WHERE A.SORLCUR_PIDM = SORLCUR.SORLCUR_PIDM
                 AND A.SORLCUR_LMOD_CODE = SORLCUR.SORLCUR_LMOD_CODE
                 AND A.SORLCUR_CACT_CODE = SORLCUR.SORLCUR_CACT_CODE
                 AND A.SORLCUR_KEY_SEQNO = SORLCUR.SORLCUR_KEY_SEQNO
                 AND A.SORLCUR_TERM_CODE <= shrtckn_term_code)
         AND ssbsect.ssbsect_subj_code || ssbsect.ssbsect_crse_numb =
             shrtckn_subj_code || shrtckn_crse_numb
         AND ssbsect.ssbsect_crn = sfrstcr.sfrstcr_crn
         AND sfrstcr.sfrstcr_term_code = ssbsect.ssbsect_term_code
         AND sfrstcr.sfrstcr_pidm = SORLCUR.SORLCUR_PIDM
         AND scbcrse.scbcrse_subj_code = ssbsect.ssbsect_subj_code
         AND scbcrse.scbcrse_crse_numb = ssbsect.ssbsect_crse_numb
         AND sfrstcr.sfrstcr_rsts_code LIKE ING_DEL || '%'
         AND SHRGRDE_PASSED_IND = 'N'
         AND SHRGRDE_GRDE_STATUS_IND = 'A'
         AND SORLCUR_CURRENT_CDE = 'Y'
         AND SORLCUR_LMOD_CODE = 'LEARNER'
         AND SORLCUR_CACT_CODE = 'ACTIVE'
         AND SORLCUR_KEY_SEQNO = v_study_path
         AND sfrstcr.sfrstcr_stsp_key_sequence = SORLCUR_KEY_SEQNO
            --  AND SORLCUR_KEY_SEQNO = SHRTCKN_STSP_KEY_SEQUENCE
         AND sfrstcr.sfrstcr_term_code = p_periodoprefactura
         AND SHRTTRM_PIDM = p_student_pidm;

  BEGIN
    v_cont := 0;
    v_pass := 0;
    log_proceso(SYSDATE,
                TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                ',p_student_pidm:' || p_student_pidm ||
                ', p_periodoprefactura:' || p_periodoprefactura,
                'Reversion---->Comienzo procesos reversión',
                TO_CHAR(v_cont));
    v_cont := v_cont + 1;
    --recorre las materias ingresadas (Si al menos hay una no hay reverso)
    FOR REC_MATERIAS IN CUR_MATERIAS('R') LOOP
      log_proceso(SYSDATE,
                  TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                  ',p_student_pidm:' || p_student_pidm ||
                  ', p_periodoprefactura:' || p_periodoprefactura,
                  'Reversion---->No hace reversión por que tiene inscripción',
                  TO_CHAR(v_cont));
      v_cont := v_cont + 1;
      RETURN 'N';
    END LOOP;
    v_cont_mat := 0;
    FOR REC_MATERIAS IN CUR_MATERIAS('D') LOOP
      v_cont_mat := v_cont_mat + 1;

      v_pass := v_pass + 1;
      v_camp := REC_MATERIAS.CAMPUS;
      --recorre recargos
      log_proceso(SYSDATE,
                  TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                  ',p_student_pidm:' || p_student_pidm ||
                  ', p_periodoprefactura:' || p_periodoprefactura,
                  'Reversion---->Encontro retiros de materias',
                  TO_CHAR(v_cont));
      v_cont := v_cont + 1;

    END LOOP;

    if v_cont_mat >= 0 then
      FOR rec_recargos IN CUR_RECARGOS(-1) LOOP
        log_proceso(SYSDATE,
                    TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                    ',p_student_pidm:' || p_student_pidm ||
                    ', p_periodoprefactura:' || p_periodoprefactura,
                    'Reversion---->Encontro recargos negativos de reversión por eso interrumpe el proceso',
                    TO_CHAR(v_cont));
        v_cont := v_cont + 1;
        RETURN 'O';
      END LOOP;
      FOR rec_recargos IN CUR_RECARGOS(1) LOOP
        if rec_recargos.tbraccd_amount < 0 then
          log_proceso(SYSDATE,
                      TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                      ',p_student_pidm:' || p_student_pidm ||
                      ', p_periodoprefactura:' || p_periodoprefactura,
                      'Reversion---->2 posiblilita Encontro recargos negativos de reversión por eso interrumpe el proceso',
                      TO_CHAR(v_cont));
          v_cont := v_cont + 1;
          return 'O';
        end if;
        log_proceso(SYSDATE,
                    TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                    ',p_student_pidm:' || p_student_pidm ||
                    ', p_periodoprefactura:' || p_periodoprefactura,
                    'Reversion---->Inicio TB_RECEIVABLE.P_CREATE',
                    TO_CHAR(v_cont));
        v_cont := v_cont + 1;
        BEGIN
          TB_RECEIVABLE.P_CREATE(P_PIDM                 => rec_recargos.tbraccd_PIDM,
                                 P_TERM_CODE            => rec_recargos.tbraccd_TERM_CODE,
                                 P_DETAIL_CODE          => rec_recargos.tbraccd_DETAIL_CODE,
                                 P_USER                 => rec_recargos.tbraccd_USER,
                                 P_ENTRY_DATE           => sysdate, --rec_recargos.tbraccd_ENTRY_DATE, 
                                 P_AMOUNT               => -1 *
                                                           rec_recargos.tbraccd_AMOUNT,
                                 P_EFFECTIVE_DATE       => sysdate, -- rec_recargos.tbraccd_EFFECTIVE_DATE, 
                                 P_BILL_DATE            => rec_recargos.tbraccd_BILL_DATE,
                                 P_DUE_DATE             => rec_recargos.tbraccd_DUE_DATE,
                                 P_DESC                 => rec_recargos.tbraccd_DESC,
                                 P_RECEIPT_NUMBER       => rec_recargos.tbraccd_RECEIPT_NUMBER,
                                 P_TRAN_NUMBER_PAID     => rec_recargos.tbraccd_TRAN_NUMBER_PAID,
                                 P_CROSSREF_PIDM        => rec_recargos.tbraccd_CROSSREF_PIDM,
                                 P_CROSSREF_NUMBER      => rec_recargos.tbraccd_CROSSREF_NUMBER,
                                 P_CROSSREF_DETAIL_CODE => rec_recargos.tbraccd_CROSSREF_DETAIL_CODE,
                                 P_SRCE_CODE            => rec_recargos.tbraccd_SRCE_CODE,
                                 P_ACCT_FEED_IND        => rec_recargos.tbraccd_ACCT_FEED_IND,
                                 P_SESSION_NUMBER       => rec_recargos.tbraccd_SESSION_NUMBER,
                                 P_CSHR_END_DATE        => rec_recargos.tbraccd_CSHR_END_DATE,
                                 P_CRN                  => rec_recargos.tbraccd_CRN,
                                 P_CROSSREF_SRCE_CODE   => rec_recargos.tbraccd_CROSSREF_SRCE_CODE,
                                 P_LOC_MDT              => rec_recargos.tbraccd_LOC_MDT,
                                 P_LOC_MDT_SEQ          => rec_recargos.tbraccd_LOC_MDT_SEQ,
                                 P_RATE                 => rec_recargos.tbraccd_RATE,
                                 P_UNITS                => rec_recargos.tbraccd_UNITS,
                                 P_DOCUMENT_NUMBER      => rec_recargos.tbraccd_DOCUMENT_NUMBER,
                                 P_TRANS_DATE           => rec_recargos.tbraccd_TRANS_DATE,
                                 P_PAYMENT_ID           => rec_recargos.tbraccd_PAYMENT_ID,
                                 P_INVOICE_NUMBER       => rec_recargos.tbraccd_INVOICE_NUMBER,
                                 P_STATEMENT_DATE       => rec_recargos.tbraccd_STATEMENT_DATE,
                                 P_INV_NUMBER_PAID      => rec_recargos.tbraccd_INV_NUMBER_PAID,
                                 P_CURR_CODE            => rec_recargos.tbraccd_CURR_CODE,
                                 P_EXCHANGE_DIFF        => rec_recargos.tbraccd_EXCHANGE_DIFF,
                                 P_FOREIGN_AMOUNT       => rec_recargos.tbraccd_FOREIGN_AMOUNT,
                                 P_LATE_DCAT_CODE       => rec_recargos.tbraccd_LATE_DCAT_CODE,
                                 P_ATYP_CODE            => rec_recargos.tbraccd_ATYP_CODE,
                                 P_ATYP_SEQNO           => rec_recargos.tbraccd_ATYP_SEQNO,
                                 P_CARD_TYPE_VR         => rec_recargos.tbraccd_CARD_TYPE_VR,
                                 P_CARD_EXP_DATE_VR     => rec_recargos.tbraccd_CARD_EXP_DATE_VR,
                                 P_CARD_AUTH_NUMBER_VR  => rec_recargos.tbraccd_CARD_AUTH_NUMBER_VR,
                                 P_CROSSREF_DCAT_CODE   => rec_recargos.tbraccd_CROSSREF_DCAT_CODE,
                                 P_ORIG_CHG_IND         => rec_recargos.tbraccd_ORIG_CHG_IND,
                                 P_CCRD_CODE            => rec_recargos.tbraccd_CCRD_CODE,
                                 P_MERCHANT_ID          => rec_recargos.tbraccd_MERCHANT_ID,
                                 P_DATA_ORIGIN          => rec_recargos.tbraccd_DATA_ORIGIN,
                                 P_CPDT_IND             => rec_recargos.tbraccd_CPDT_IND,
                                 P_OVERRIDE_HOLD        => 'N',
                                 P_AIDY_CODE            => rec_recargos.tbraccd_AIDY_CODE,
                                 P_STSP_KEY_SEQUENCE    => rec_recargos.tbraccd_STSP_KEY_SEQUENCE,
                                 P_PERIOD               => rec_recargos.tbraccd_PERIOD,
                                 P_TRAN_NUMBER_OUT      => v_TRAN_NUMBER_OUT,
                                 P_ROWID_OUT            => v_ROWID_OUT,
                                 P_TAX_REPT_BOX_PR      => rec_recargos.tbraccd_TAX_REPT_BOX_PR,
                                 P_TAX_REPT_BOX_SG      => rec_recargos.tbraccd_TAX_REPT_BOX_SG,
                                 P_TAX_FUTURE_IND_PR    => rec_recargos.tbraccd_TAX_FUTURE_IND_PR,
                                 P_TAX_FUTURE_IND_SG    => rec_recargos.tbraccd_TAX_FUTURE_IND_SG);
          log_proceso(SYSDATE,
                      TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                      ',p_student_pidm:' || p_student_pidm ||
                      ', p_periodoprefactura:' || p_periodoprefactura,
                      'Reversion---->Fin TB_RECEIVABLE.P_CREATE DEVOLUCIUON =>Y',
                      TO_CHAR(v_cont));
          v_cont := v_cont + 1;
          RETURN 'Y';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            sqlErrorMsg := 'Error en reversión en la consula de materrias inscritas:' ||
                           sqlerrm;
        END;
      END LOOP;
    end if;

    log_proceso(SYSDATE,
                TO_CHAR(SYSDATE, 'MI:SS') || 'SP:' || v_study_path ||
                ',p_student_pidm:' || p_student_pidm ||
                ', p_periodoprefactura:' || p_periodoprefactura,
                'Reversion---->Fin proceso de reversion devolucion=>>N',
                TO_CHAR(v_cont));
    v_cont := v_cont + 1;
    RETURN 'N';
  END;

  FUNCTION f_calificaciones_aprobadas(p_shrgrde_levl_code IN shrgrde.shrgrde_levl_code%TYPE,
                                      p_shrgrde_code      IN shrgrde.shrgrde_code%TYPE)
    RETURN VARCHAR2 IS
    v_aprobada shrgrde.shrgrde_passed_ind%TYPE;
    /******************************************************************************
    NAME:       f_calificaciones_aprobadas
    PURPOSE:    La calificación se identifica en la forma SHAGRDE (SHRGRDE),
    las calificaciones aprobadas tienen el check de contar en aprobadas.
    SHRGRDE.SHRGRDE_PASSED_IND='Y'
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. calificaciones_aprobadas
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_calificaciones_aprobadas
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 02:15:21 a.m., and 13/10/2019 02:15:22 a.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      shrgrde (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_aprobada := 'N';
      --------------------------------------------------------------
      --Start SHRGRDE.SHRGRDE_PASSED_IND=y Materia Aprobada
      --------------------------------------------------------------
      SELECT shrgrde.shrgrde_passed_ind
        INTO v_aprobada
        FROM shrgrde ----Y ESTA MARCADO
       WHERE shrgrde.shrgrde_levl_code = p_shrgrde_levl_code --65
         AND shrgrde.shrgrde_code = p_shrgrde_code; --30
    EXCEPTION
      WHEN OTHERS THEN
        v_aprobada := 'N';
        -- Consider logging the error and then re-raise
    END;
    RETURN v_aprobada;
  END f_calificaciones_aprobadas;

  FUNCTION f_perio_ult_inscr_mater_alumn(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE)
    RETURN VARCHAR2 IS
    v_sfrstca_term_code sfrstca.sfrstca_term_code%TYPE;
    /******************************************************************************
    NAME:       f_perio_ult_inscr_mater_alumn
    PURPOSE:    Ultimo periodo por alumno que escribio materias
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_perio_ult_inscr_mater_alumn
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 02:15:21 a.m., and 13/10/2019 02:15:22 a.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      shrgrde (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_sfrstca_term_code := NULL;
      --------------------------------------------------------------
      ----Start Materias que escribio el alumno
      --------------------------------------------------------------
      SELECT MAX(sfrstca.sfrstca_term_code)
        INTO v_sfrstca_term_code
        FROM sfrstca
       WHERE sfrstca.sfrstca_pidm = p_sfrstca_pidm
         AND sfrstca.sfrstca_term_code =
             (SELECT MAX(s1.sfrstca_term_code)
                FROM sfrstca s1
               WHERE s1.sfrstca_pidm = sfrstca.sfrstca_pidm);

      --------------------------------------------------------------
      ----End Materias que escribio el alumno
      --------------------------------------------------------------
    EXCEPTION
      WHEN OTHERS THEN
        v_sfrstca_term_code := NULL;
        -- Consider logging the error and then re-raise
    END;
    RETURN v_sfrstca_term_code;
  END f_perio_ult_inscr_mater_alumn;

  FUNCTION f_curriculum_level_estudiante(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE)
    RETURN VARCHAR2 IS
    v_sorlcur_levl_code sorlcur.sorlcur_levl_code%TYPE;
    /******************************************************************************
    NAME:       f_curriculums_level_estudiante
    PURPOSE:    nivel del estudiante
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_curriculums_level_estudiante
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 02:15:21 p.m., and 13/10/2019 02:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_sorlcur_levl_code := NULL;
      --------------------------------------------------------------
      ----Start Nivel en que esta escrito el alumno en el curriculum
      --------------------------------------------------------------
      SELECT sorlcur.sorlcur_levl_code
        INTO v_sorlcur_levl_code
        FROM sorlcur
       WHERE sorlcur_cact_code = 'ACTIVE'
         AND sorlcur_roll_ind = 'Y'
         AND sorlcur_pidm = p_sfrstca_pidm
         AND ROWNUM < 2;

    EXCEPTION
      WHEN OTHERS THEN
        v_sorlcur_levl_code := NULL;
        -- Consider logging the error and then re-raise
    END;
    --------------------------------------------------------------
    ----End  Nivel en que esta escrito el alumno en el curriculum
    --------------------------------------------------------------
    RETURN v_sorlcur_levl_code;
  END f_curriculum_level_estudiante;

  FUNCTION f_curriculum_camp_estudiante(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE)
    RETURN VARCHAR2 IS
    v_sorlcur_camp_code sorlcur.sorlcur_camp_code%TYPE;
    /******************************************************************************
    NAME:       f_curriculum_camp_estudiante
    PURPOSE:    nivel del estudiante
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_curriculum_camp_estudiante
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 02:15:21 p.m., and 13/10/2019 02:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_sorlcur_camp_code := NULL;
      --------------------------------------------------------------
      ----Start Nivel en que esta escrito el alumno en el curriculum
      --------------------------------------------------------------
      SELECT sorlcur.sorlcur_camp_code
        INTO v_sorlcur_camp_code
        FROM sorlcur
       WHERE sorlcur_cact_code = 'ACTIVE'
         AND sorlcur_roll_ind = 'Y'
         AND sorlcur_pidm = p_sfrstca_pidm
         AND ROWNUM < 2;

    EXCEPTION
      WHEN OTHERS THEN
        v_sorlcur_camp_code := NULL;
        -- Consider logging the error and then re-raise
    END;
    --------------------------------------------------------------
    ----End  campo que esta escrito el alumno en el curriculum
    --------------------------------------------------------------
    RETURN v_sorlcur_camp_code;
  END f_curriculum_camp_estudiante;

  FUNCTION f_detalle_cuen_sin_recargo(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                      p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                      p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
    RETURN VARCHAR2 IS
    v_facturado        VARCHAR2(2);
    v_valor_recargoa12 tbraccd.tbraccd_amount%TYPE;
    /******************************************************************************
    NAME:       f_detalle_cuen_sin_recargo
    PURPOSE:    Prefacturacion de recargo matricaula concepto A0012 segunda y tercera matricula
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_detalle_cuen_sin_recargo
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 06:15:21 p.m., and 13/10/2019 06:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_facturado := 'NO';
      ------------------------------------------------------------------------------
      ----Start Valor del recargo ya se encuentra prefacturado
      -----------------------------------------------------------------------------
      --SELECT NVL(tbraccd_amount, 0)
      SELECT SUM(tbraccd_amount)      
        INTO v_valor_recargoa12
        FROM tbraccd
       WHERE tbraccd_pidm = p_tbraccd_pidm
         AND tbraccd_detail_code = p_tbraccd_detail_code
         AND tbraccd_term_code = p_tbraccd_term_code
         AND tbraccd_stsp_key_sequence = v_study_path;
         --AND tbraccd_balance > 0
         --AND ROWNUM < 2;

    EXCEPTION
      WHEN OTHERS THEN
        v_valor_recargoa12 := NULL;
        -- Consider logging the error and then re-raise
    END;
    --IF v_valor_recargoa12 IS NOT NULL THEN
    IF v_valor_recargoa12 <> 0 THEN
      v_facturado := 'SI';
    ELSE
      v_facturado := 'NO';
    END IF;
    --------------------------------------------------------------
    ----End  Valor del recargo ya se encuentra prefacturado
    --------------------------------------------------------------
    RETURN v_facturado;
  END f_detalle_cuen_sin_recargo;

  FUNCTION f_detalle_con_recargo(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                 p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                 p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
    RETURN VARCHAR2 IS
    v_facturado        VARCHAR2(2);
    v_valor_prefactura tbraccd.tbraccd_amount%TYPE;
    /******************************************************************************
    NAME:       f_detalle_con_recargo
    PURPOSE:    Prefacturacion de recargo matricula concepto A0012 segunda y tercera matricula
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_detalle_con_recargo
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 06:15:21 p.m., and 13/10/2019 06:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_facturado := 'NO';
      ------------------------------------------------------------------------------
      ----Start Valor del recargo ya se encuentra prefacturado
      -----------------------------------------------------------------------------
      SELECT NVL(tbraccd_amount, 0)
        INTO v_valor_prefactura
        FROM tbraccd
       WHERE tbraccd_pidm = p_tbraccd_pidm
         AND tbraccd_detail_code = p_tbraccd_detail_code
         AND tbraccd_term_code = p_tbraccd_term_code
         AND tbraccd_amount > 0
         AND tbraccd_stsp_key_sequence = v_study_path
         AND ROWNUM < 2;

    EXCEPTION
      WHEN OTHERS THEN
        v_valor_prefactura := NULL;
        -- Consider logging the error and then re-raise
    END;
    IF v_valor_prefactura IS NOT NULL THEN
      v_facturado := 'SI';
    ELSE
      v_facturado := 'NO';
    END IF;
    --------------------------------------------------------------
    ----End  Valor del recargo ya se encuentra prefacturado
    --------------------------------------------------------------
    RETURN v_facturado;
  END f_detalle_con_recargo;

  FUNCTION f_detalle_con_recargoanulado(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                        p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                        p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
    RETURN VARCHAR2 IS
    v_facturado        VARCHAR2(2);
    v_valor_prefactura tbraccd.tbraccd_amount%TYPE;
    /******************************************************************************
    NAME:       f_detalle_con_recargoanulado
    PURPOSE:    Prefacturacion de recargo anulado matricula concepto A0012 segunda y tercera matricula
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_detalle_con_recargoanulado
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 06:15:21 p.m., and 13/10/2019 06:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_facturado := 'NO';
      ------------------------------------------------------------------------------
      ----Start Valor del recargo ya se encuentra prefacturado
      -----------------------------------------------------------------------------
      SELECT NVL(tbraccd_amount, 0)
        INTO v_valor_prefactura
        FROM tbraccd
       WHERE tbraccd_pidm = p_tbraccd_pidm
         AND tbraccd_detail_code = p_tbraccd_detail_code
         AND tbraccd_term_code = p_tbraccd_term_code
         AND tbraccd_amount < 0
         AND tbraccd_stsp_key_sequence = v_study_path
         AND ROWNUM < 2;

    EXCEPTION
      WHEN OTHERS THEN
        v_valor_prefactura := NULL;
        -- Consider logging the error and then re-raise
    END;
    IF v_valor_prefactura IS NOT NULL THEN
      v_facturado := 'SI';
    ELSE
      v_facturado := 'NO';
    END IF;
    --------------------------------------------------------------
    ----End  Valor del recargo ya se encuentra prefacturado
    --------------------------------------------------------------
    RETURN v_facturado;
  END f_detalle_con_recargoanulado;

  FUNCTION f_saldo_recargoanulado(p_tbraccd_pidm        IN tbraccd.tbraccd_pidm%TYPE,
                                  p_tbraccd_detail_code IN tbraccd.tbraccd_detail_code%TYPE,
                                  p_tbraccd_term_code   IN tbraccd.tbraccd_term_code%TYPE)
    RETURN NUMBER IS
    v_facturado        NUMBER;
    v_valor_prefactura tbraccd.tbraccd_amount%TYPE;
    /******************************************************************************
    NAME:       f_detalle_con_recargoanulado
    PURPOSE:    Prefacturacion de recargo anulado matricula concepto A0012 segunda y tercera matricula
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_detalle_con_recargoanulado
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 06:15:21 p.m., and 13/10/2019 06:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_facturado := 'NO';
      ------------------------------------------------------------------------------
      ----Start Valor del recargo ya se encuentra prefacturado
      -----------------------------------------------------------------------------
      SELECT SUM(NVL(tbraccd_amount, 0))
        INTO v_valor_prefactura
        FROM tbraccd
       WHERE tbraccd_pidm = p_tbraccd_pidm
         AND tbraccd_detail_code = p_tbraccd_detail_code
         AND tbraccd_term_code = p_tbraccd_term_code
         AND tbraccd_stsp_key_sequence = v_study_path;

    EXCEPTION
      WHEN OTHERS THEN
        v_valor_prefactura := 0;
        -- Consider logging the error and then re-raise
    END;
    --------------------------------------------------------------
    ----End  Valor del recargo ya se encuentra prefacturado
    --------------------------------------------------------------
    v_facturado := v_valor_prefactura;
    RETURN v_facturado;
  END f_saldo_recargoanulado;

  FUNCTION f_retencion_estudian_menor_fec(p_sprhold_pidm      IN sprhold.sprhold_pidm%TYPE,
                                          p_sprhold_hldd_code IN sprhold.sprhold_hldd_code%TYPE,
                                          p_sprhold_to_date   IN sprhold.sprhold_to_date%TYPE)
    RETURN VARCHAR2 IS
    v_fecharetencionfactura VARCHAR2(2);
    v_sprhold_to_date       sprhold.sprhold_to_date%TYPE;
    /******************************************************************************
    NAME:       f_codigo_retencion_alumnos
    PURPOSE:    --Con esta información de los estudiantes que tienen los códigos de retención parametrizados en la nueva
    --tabla creada se puede realizar el filtro de búsqueda de los estudiantes cuando inscriban asignaturas.
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_codigo_retencion_alumnos
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 06:15:21 p.m., and 13/10/2019 06:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_fecharetencionfactura := 'NO';
      -------------------------------------------------------------------
      ----Start Vigencia Retencion SPRHOLD_HLDD_CODE=1V 1 Vez,2V 2veces. 3V 3Vez Retenciones
      -------------------------------------------------------------------
      SELECT SPRHOLD_TO_DATE
        INTO v_SPRHOLD_TO_DATE
        FROM SPRHOLD
       WHERE SPRHOLD_PIDM = p_sprhold_pidm
         AND SPRHOLD_HLDD_CODE = p_sprhold_hldd_code
         AND SPRHOLD_TO_DATE >= TRUNC(p_SPRHOLD_TO_DATE)
       FETCH FIRST 1 ROWS ONLY;

    EXCEPTION
      WHEN OTHERS THEN
        v_SPRHOLD_TO_DATE := NULL;
        -- Consider logging the error and then re-raise
    END;
    IF v_SPRHOLD_TO_DATE IS NOT NULL THEN
      v_fecharetencionfactura := 'SI';
    ELSE
      v_fecharetencionfactura := 'NO';
    END IF;
    --------------------------------------------------------------
    ----End SPRHOLD_HLDD_CODE=1V 1 Vez,2V 2veces. 3V 3Vez Retenciones
    --------------------------------------------------------------
    RETURN v_fecharetencionfactura;
  END f_retencion_estudian_menor_fec;

  FUNCTION f_curriculum_level_est_prog(p_sfrstca_pidm IN sfrstca.sfrstca_pidm%TYPE,
                                       p_programa     varchar2)
    RETURN VARCHAR2 IS
    v_sorlcur_levl_code sorlcur.sorlcur_levl_code%TYPE;
    /******************************************************************************
    NAME:       f_curriculums_level_estudiante
    PURPOSE:    nivel del estudiante
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        13/10/2019   NEORIS         1. ultima inscripcion de materias
    NOTES:
    Automatically available Auto Replace Keywords:
    Object Name:     f_curriculums_level_estudiante
    Sysdate:         13/10/2019
    Date and Time:   13/10/2019, 02:15:21 p.m., and 13/10/2019 02:15:22 p.m.
    Username:        Neoris (set in TOAD Options, Procedure Editor)
    Table Name:      sorlcur (set in the "New PL/SQL Object" dialog)
    ******************************************************************************/
  BEGIN
    BEGIN
      v_sorlcur_levl_code := NULL;
      --------------------------------------------------------------
      ----Start Nivel en que esta escrito el alumno en el curriculum
      --------------------------------------------------------------
      SELECT sorlcur.sorlcur_levl_code
        INTO v_sorlcur_levl_code
        FROM sorlcur
       WHERE sorlcur_cact_code = 'ACTIVE'
         AND sorlcur_roll_ind = 'Y'
         AND sorlcur_pidm = p_sfrstca_pidm
         AND sorlcur_program = p_programa
         AND ROWNUM < 2;

    EXCEPTION
      WHEN OTHERS THEN
        v_sorlcur_levl_code := NULL;
        -- Consider logging the error and then re-raise
    END;
    --------------------------------------------------------------
    ----End  Nivel en que esta escrito el alumno en el curriculum
    --------------------------------------------------------------
    RETURN v_sorlcur_levl_code;
  END f_curriculum_level_est_prog;

END sb_calculo_seg_ter_Matricula;






/
