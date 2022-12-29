CREATE OR REPLACE PACKAGE BZSKOACC AS
/******************************************************************************
   NAME:       BZSKOACC
   PURPOSE: NEORIS

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        6/4/2019      ljgonzalez       1. Created this package.
   1.1        5/10/2019    emartinez       2. Modify 
******************************************************************************/
-- FILE NAME..: BZSKOACC.sql
-- RELEASE....: 1.0
-- OBJECT NAME: BZSKOACC
-- PRODUCT....: WTAILOR
-- USAGE......: Paquete que muestra el estado de cuenta del Estudiante.
-- COPYRIGHT..: Neoris 2020 
--
-- DESCRIPTION:
--
--    Paquete pricipal de estado de cuenta por categoría, enlazado a los tipos de documento existentes y generación de prefactura.
--
--  Cursors:
--  c_get_crn .- Obtiene el CRN de la tabla TBRACCD de Estado de Cuenta.
--
-- c_get_data_i .- Obtiene los datos de configuracion definidos en GTVSDAX para el desarrollo de Pago en Línea y Prefactura.
--
-- c_get_status_payu .- Obtiene los mensajes de retorno de los proveedores de pago en línea.
-- 
-- c_get_sede .- Obtiene la sede del estudiante definido en SGASTDN.
--
--  Procedures:
--  p_viewacct_alt .- Procedimiento principal de estado de cuenta por categoría.
--
-- p_view_history .- Historial de pagos. Muestra el intento de pagos y pagos realizados por numero de documento.
--
-- DESCRIPTION END
--
  PROCEDURE p_viewacct_alt;
  PROCEDURE p_view_history;

END BZSKOACC;

/


CREATE OR REPLACE PACKAGE BODY          "BZSKOACC"
IS
    /******************************************************************************
       NAME:       BZSKOACC
       PURPOSE:

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        6/4/2019      e-ljgonzalez       1. Created this package body.
       1.1        4/SEP/2019  EMR                    2. Modificación
    ******************************************************************************/
    global_pidm             spriden.spriden_pidm%TYPE;
    curr_release   CONSTANT VARCHAR2 (10) := '8.7.1';
    stvterm_rec             stvterm%ROWTYPE;
    sorrtrm_rec             sorrtrm%ROWTYPE;
    term                    stvterm.stvterm_code%TYPE;
    row_count               NUMBER;
    DEFAULT_TAB    CONSTANT VARCHAR2 (4) := 'ACCD';             

    v_message_payu     TZRPAYU.TZRPAYU_MESSAGE%type;

--  Obtiene el CRN de la tabla TBRACCD de Estado de Cuenta.
cursor c_get_crn (p_pidm number, p_trans varchar2 ) is 
select TBRACCD_CRN
  from tbraccd 
  where tbraccd_pidm = p_pidm  
  and TBRACCD_CRN is not null 
  and TBRACCD_TRAN_NUMBER in 
(    SELECT REGEXP_SUBSTR (
                                             REPLACE ((p_trans), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                    FROM DUAL
                              CONNECT BY REGEXP_SUBSTR (
                                             REPLACE ((p_trans), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                             IS NOT NULL)
        group by TBRACCD_CRN;

v_crn           varchar2(100):= NULL;


-- Obtiene los datos de configuracion definidos en GTVSDAX para el desarrollo de Pago en Línea y Prefactura.
--  valores de GTVSDAX, External Code, Concept y Comments de acuerdo al tipo,  por Código interno y Grupo de Código.
CURSOR c_get_data_i (
        p_group            VARCHAR2,
        p_internal_code    VARCHAR2,
        p_type             VARCHAR2)
    IS
        SELECT DECODE (p_type,
                       'EXT', gtvsdax_external_code,
                       'CON', gtvsdax_concept,
                       'COM', gtvsdax_comments)
          FROM gtvsdax
         WHERE     gtvsdax_internal_code_group = p_group
               AND gtvsdax_internal_code = p_internal_code;

p_sdoc_pref     VARCHAR2 (100);

-- Obtiene el mensaje de retorno de la transaccion de pago en línea por los proveedores.
--
    CURSOR c_get_status_payu ( p_pidm number, p_trans varchar2,  p_term varchar2, p_cod_pref varchar2) is
    select TZRPAYU_MESSAGE 
          from tzrpayu 
        where tzrpayu_pidm = p_pidm
            and TZRPAYU_DOC_NUMBER = tzkpufc.f_get_doc_number_r(p_pidm,p_trans, p_cod_pref )            
            and TZRPAYU_TERM = p_term
            and TZRPAYU_STATUS in ('PENDING','PENDING_VALIDATION','OK');

--Obtiene la sede del estudiante definido en SGASTDN
    CURSOR c_get_sede (
         p_pidm NUMBER)
      IS
         SELECT 
                a.sgbstdn_camp_code sede       
           FROM sgbstdn a
          WHERE a.sgbstdn_pidm = p_pidm    
                AND a.sgbstdn_term_code_eff =
                      (SELECT MAX (z.sgbstdn_term_code_eff)
                         FROM sgbstdn z
                        WHERE sgbstdn_pidm = a.sgbstdn_pidm 
                                                           );

       p_sede          sgbstdn.sgbstdn_camp_code%TYPE;

-- Funcion interna de validacion de periodo.
--
    FUNCTION F_ValidTerm (term          IN     VARCHAR2 DEFAULT NULL,
                          tbbterm_rec      OUT tbbterm%ROWTYPE)
        RETURN BOOLEAN
    IS
        row_count   NUMBER;

        CURSOR tbbterm_cur (
            term    VARCHAR2)                         
        IS
            SELECT *
              FROM TBBTERM
             WHERE     tbbterm_term_code = term
                   AND tbbterm_detail_web_disp_IND = 'Y';
    BEGIN
        IF term IS NULL
        THEN
            RETURN FALSE;
        END IF;

        OPEN tbbterm_cur (term);

        FETCH tbbterm_cur INTO tbbterm_rec;

        IF tbbterm_cur%NOTFOUND
        THEN
            row_count := 0;
        END IF;

        CLOSE tbbterm_cur;

        IF row_count = 0
        THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END F_ValidTerm;

-- Historial de pagos. Muestra el intento de pagos y pagos realizados por numero de documento.
    PROCEDURE p_view_history
    IS
        CURSOR tzrpayu_viewc (
            pidm    spriden.spriden_pidm%TYPE)
        IS
        select h1.TZRPAYh_PIDM_OPRD pidm_oprd,  
                       h1.TZRPAYh_PIDM pidm,
                       gb_common.f_get_id(h1.TZRPAYh_PIDM_OPRD) id_oprd,             
                       gb_common.f_get_id(h1.TZRPAYh_PIDM) ID, 
                       h1.TZRPAYh_CAMPUS campus, 
                       h1.TZRPAYh_REQUEST_ID request_id, 
                       h1.TZRPAYh_SDOC_CODE sdoc_code, 
                       h1.TZRPAYh_DOC_NUMBER doc_number, 
                       h1.TZRPAYh_TERM term,
                       h1.TZRPAYh_STATUS status, 
                       DECODE(UPPER((h1.TZRPAYh_STATUS)),'OK','Solicitud en proceso, favor de validar en unos momentos.',h1.TZRPAYH_MESSAGE) message,
                       h1.TZRPAYH_REFERENCE payment_reference,
                       h1.TZRPAYh_TOTAL total, 
                       h1.TZRPAYh_CURRENCY currency, 
                       h1.TZRPAYH_PAY_DATE pay_date, 
                       h1.TZRPAYh_autorization_code autorization_code,  
                       h1.TZRPAYh_payment_Method_Name PAYMENTMETHODNAME, 
                       h1.TZRPAYh_issuer_Name issuerName,  
                       h1.TZRPAYh_receipt receipt, 
                       h1.TZRPAYh_INSTALLMENTS installments,  
                       h1.TZRPAYh_group groupCode ,
                       f_format_name (TZRPAYh_PIDM_OPRD, 'L30') NombreProveedor
               from tzrpayh h1
            where  h1.TZRPAYh_PIDM = pidm
            and (
            UPPER(nvl(h1.TZRPAYh_STATUS,'NULO'))<>'OK' OR (
            UPPER(nvl(h1.TZRPAYh_STATUS,'NULO'))='OK' AND (
            SELECT COUNT(0) FROM TZRPAYh h
            where h.TZRPAYh_pidm=h1.TZRPAYh_pidm
            )=1
            )
            )
            order by h1.tzrpayh_pay_date desc;



CURSOR tzrpayu_cnt (
            pidm    spriden.spriden_pidm%TYPE)
        IS
                select count(0) cnt
               from tzrpayu 
            where             
                  TZRPAYU_PIDM = pidm
                 order by tzrpayu_pay_date desc;

v_cnt number:= 0;


     BEGIN

     IF NOT twbkwbis.f_validuser (global_pidm)  THEN
            RETURN;
      END IF;

        bwckfrmt.p_open_doc ('bzskoacc.p_view_history');
        twbkfrmt.p_paragraph (1);
        twbkwbis.p_dispinfo ('bzskoacc.p_view_history', 'DEFAULT');

    OPEN tzrpayu_cnt(global_pidm);
    FETCH tzrpayu_cnt into v_cnt;
    CLOSE tzrpayu_cnt;

    IF v_cnt = 0 then
       twbkfrmt.p_printmessage ( ( 'No existen transacciones para mostrar'), 'WARNING');
     ELSE
        twbkfrmt.p_tableopen (
                        'DATADISPLAY',
                        cattributes   =>    'summary="'
                                         || G$_NLS.Get (
                                                'BWSKOAC1-0015',
                                                'SQL',
                                                'Muestra el Historial de Pagos realizados via Pago en Línea.')
                                         || '"',
                        ccaption      =>   G$_NLS.Get ('BWSKOAC1-0016', 'SQL', 'Summary')
                                                                               );

                    twbkfrmt.p_tablerowopen ();
                    twbkfrmt.p_tabledataheader ('Operador');
                    twbkfrmt.p_tabledataheader ('Documento');
                    twbkfrmt.p_tabledataheader ('Periodo');
                    twbkfrmt.p_tabledataheader ('Estatus');
                    twbkfrmt.p_tabledataheader ('Mensaje');
                    twbkfrmt.p_tabledataheader ('Referencia');
                    twbkfrmt.p_tabledataheader ('Total');
                    twbkfrmt.p_tabledataheader ('Moneda');
                        twbkfrmt.p_tabledataheader ( 'Autorización');
                        twbkfrmt.p_tabledataheader ('Método de Pago');
                        twbkfrmt.p_tabledataheader ('Recibo/TicketNumber');
                        twbkfrmt.p_tabledataheader ( 'Fecha de Pago');
                     twbkfrmt.p_tablerowclose;


        FOR pay  IN tzrpayu_viewc (global_pidm)
        LOOP
                twbkfrmt.p_tablerowopen ();
                twbkfrmt.p_tabledata (pay.NombreProveedor);
                twbkfrmt.p_tabledata (pay.DOC_NUMBER);
                twbkfrmt.p_tabledata (pay.TERM);
                twbkfrmt.p_tabledata (pay.STATUS);
                twbkfrmt.p_tabledata (pay.MESSAGE);
                twbkfrmt.p_tabledata (pay.PAYMENT_REFERENCE);
                twbkfrmt.p_tabledata (pay.TOTAL);
                twbkfrmt.p_tabledata (pay.CURRENCY);
                twbkfrmt.p_tabledata (pay.AUTORIZATION_CODE);
                twbkfrmt.p_tabledata (pay.PAYMENTMETHODNAME);
                twbkfrmt.p_tabledata (pay.RECEIPT);
                twbkfrmt.p_tabledata (tO_char(pay.PAY_DATE,'DD-MON-YYYY HH24:MI:SS'));
                twbkfrmt.p_tablerowclose;

        END LOOP;
                twbkfrmt.p_tableclose;
    END IF; 
END p_view_history;

--Procedimiento principal de estado de cuenta por categoría.
-- Se enlaza al TZKPUFC para validaciónes y generación de prefactura y pago en línea.
--
PROCEDURE p_viewacct_alt
    IS

        CURSOR tbraccd_viewc (
            pidm    spriden.spriden_pidm%TYPE)
        IS
        select TZVACCD_PIDM, TZVACCD_TERM_CODE, TZVACCD_DETAIL_CODE, TZVACCD_TYPE_IND, TZVACCD_SDOC_CODE, TZVACCD_DESC, TZVACCD_EFFECTIVE_DATE, TZVACCD_SDOC_DESC, TZVACCD_CAMPUS
        , sum(TZVACCD_AMOUNT) TZVACCD_AMOUNT, sum(TZVACCD_BALANCE) TZVACCD_BALANCE
        from TZVACCD_SSB where tzvaccd_pidm = pidm 
        group by TZVACCD_PIDM, TZVACCD_TERM_CODE, TZVACCD_DETAIL_CODE, TZVACCD_TYPE_IND, TZVACCD_SDOC_CODE, TZVACCD_DESC, TZVACCD_EFFECTIVE_DATE, TZVACCD_SDOC_DESC, TZVACCD_CAMPUS
        order by TZVACCD_TERM_CODE, TZVACCD_TYPE_IND, TZVACCD_DETAIL_CODE ;

        cursor tbraccd_terms (pidm spriden.spriden_pidm%type)
        is
            select distinct tzvaccd_term_code term_code
              from tzvaccd_ssb
             where tzvaccd_pidm = pidm and tzvaccd_balance <> 0;

        CURSOR c_get_trans (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2)
        IS
            SELECT 
                   REGEXP_REPLACE (
                       LISTAGG (TZVACCD_TRAN_NUMBER, ',')
                           WITHIN GROUP (ORDER BY TZVACCD_TRAN_NUMBER),
                       '([^,]+)(,\1)*(,|$)',
                       '\1\3')
                       AS trans_num
              FROM TZVACCD_ssb
             WHERE     TZVACCD_PIDM = pidm
                   AND TZVACCD_SDOC_CODE = p_sdoc_code
                   AND TZVACCD_TERM_CODE = p_term_code
                   AND TZVACCD_BALANCE <> 0;

        cursor c_get_borrado (p_term varchar2, p_camp varchar2) is
            select GTVSDAX_TRANSLATION_CODE, GTVSDAX_DESC
            from gtvsdax 
            where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' 
            and GTVSDAX_EXTERNAL_CODE = p_term
            and GTVSDAX_INTERNAL_CODE = 'TERM_BORRA'
            and GTVSDAX_CONCEPT = p_camp
            and GTVSDAX_TRANSLATION_CODE = 'Y';

        tbraccd_viewc_rec   tbraccd_viewc%ROWTYPE;    

        term_chrg           NUMBER (14, 2) := 0;
        term_pay            NUMBER (14, 2) := 0;
        term_bal            NUMBER (14, 2) := 0;
        total_bal           NUMBER (14, 2) := 0;
        old_term            VARCHAR2 (6) := ' ';
        old_SDOC            VARCHAR (10) := ' ';
        term_chrg_var       NUMBER (14, 2) := 0;
        term_pay_var        NUMBER (14, 2) := 0;
        gtv_ext_code        GTVSDAX.GTVSDAX_EXTERNAL_CODE%TYPE := 'N';
        colspan_var         NUMBER (1);
        tbbterm_rec         tbbterm%ROWTYPE;
        v_trans             VARCHAR2 (1000);
        v_sqlerrormsg       VARCHAR2 (1000);
        v_sqlerrormsg_2       VARCHAR2 (1000);
        lv_out_stat      VARCHAR2 (1000);
        v_get_borrado varchar2(1);
        v_get_desc_borr varchar2(30);

            IN_TIME INT:=3; 
v_now DATE;


    BEGIN

        IF NOT twbkwbis.f_validuser (global_pidm)
        THEN
            RETURN;
        END IF;


        bwckfrmt.p_open_doc ('bzskoacc.P_ViewAcct_Alt');
        twbkfrmt.p_paragraph (1);
        twbkwbis.p_dispinfo ('bzskoacc.P_ViewAcct_Alt', 'DEFAULT');

    htp.p('<span style="font-weight:bold; color:red; font-size:150%">Una vez generada la prefactura,  no es posible realizar cambios en su inscripción de asignaturas <br> </span>');
    htp.p('<span style="font-weight:bold; color:red; font-size:150%">Para poder ver reflejado los valores de becas, se debe dar clic en el botón “GENERAR PREFACTURA”</span>');

    -- TERMINOS Y CONDICIONES
    htp.p('
    <script>
function myFunction( form ) {
  //var txt;
  var r = confirm("Acepta los términos y condiciónes");
  if (r == true) {
    //document.getElementByName("form_pay").submit();
    form.submit();
  } else {
    txt = "You pressed Cancel!";
  }
 // document.getElementById("tercond").innerHTML = txt;
}
</script>

    ');


        OPEN tbraccd_viewc (global_pidm);

        LOOP
            FETCH tbraccd_viewc INTO tbraccd_viewc_rec;

            IF tbraccd_viewc%FOUND
            THEN
                IF old_SDOC <> tbraccd_viewc_rec.TZVACCD_SDOC_CODE
                THEN
                    IF tbraccd_viewc%ROWCOUNT <> 1
                    THEN
                        twbkfrmt.p_tablerowopen ();
                        twbkfrmt.p_tabledatalabel (
                            G$_NLS.Get ('BWSKOAC1-0028',
                                        'SQL',
                                        'Term Charges:'),
                            ccolspan   => 1 + colspan_var);
                        twbkfrmt.p_tabledata (
                            TO_CHAR (term_chrg, 'L999G999G999G990D99'),
                            'right');
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen ();
                        twbkfrmt.p_tabledatalabel (
                            G$_NLS.Get ('BWSKOAC1-0029',
                                        'SQL',
                                        'Term Credits and Payments:'),
                            ccolspan   => 2 + colspan_var);
                        twbkfrmt.p_tabledata (
                            TO_CHAR (term_pay, 'L999G999G999G990D99'),
                            'right');
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen ();
                        twbkfrmt.p_tabledatalabel (
                            G$_NLS.Get ('BWSKOAC1-0030',
                                        'SQL',
                                        'Term Balance:'),
                            ccolspan   => 3 + colspan_var);
                        twbkfrmt.p_tabledata (
                            TO_CHAR (term_bal, 'L999G999G999G990D99'),
                            'right');
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tableclose;
                        HTP.br;
                    END IF;

                    twbkfrmt.p_tableopen (
                        'DATADISPLAY',
                        cattributes   =>    'summary="'
                                         || G$_NLS.Get (
                                                'BWSKOAC1-0015',
                                                'SQL',
                                                'This table displays summarized charge and payment transactions by Category and term on your academic record.')
                                         || '"',
                        ccaption      =>    tbraccd_viewc_rec.TZVACCD_SDOC_CODE
                                         || ' - '
                                         || tbraccd_viewc_rec.TZVACCD_SDOC_DESC 
                                                                               );

                    old_SDOC := tbraccd_viewc_rec.TZVACCD_SDOC_CODE;
                    old_term := ' ';
                    term_chrg := 0;
                    term_pay := 0;
                    term_bal := 0;
                END IF;


                IF old_term <> tbraccd_viewc_rec.TZVACCD_TERM_CODE
                THEN
                    FOR rec_view
                        IN c_get_trans (global_pidm,
                                        tbraccd_viewc_rec.TZVACCD_SDOC_CODE,
                                        tbraccd_viewc_rec.TZVACCD_TERM_CODE)
                    LOOP                
                        v_trans :=  rec_view.trans_num;
                    END LOOP;


                    old_term := tbraccd_viewc_rec.TZVACCD_TERM_CODE;
                    term_chrg := 0;
                    term_pay := 0;
                    term_bal := 0;

                    v_get_borrado := 'N';
                    v_get_desc_borr := '';
                    open c_get_borrado (tbraccd_viewc_rec.TZVACCD_TERM_CODE, tbraccd_viewc_rec.TZVACCD_CAMPUS);
                    fetch c_get_borrado into v_get_borrado, v_get_desc_borr;
                    close c_get_borrado;

                    twbkfrmt.p_tablerowopen ();

                        twbkfrmt.p_tabledatalabel (
                        twbkfrmt.f_printtext (
                               tbraccd_viewc_rec.TZVACCD_TERM_CODE
                            || ' - '
                            || F_STUDENT_GET_DESC (
                                   'STVTERM',
                                   tbraccd_viewc_rec.TZVACCD_TERM_CODE,
                                   30),
                            class_in   => 'fieldOrangetextbold'),
                        ccolspan   => 5);

                        if v_get_borrado = 'Y' then 

                            HTP.p ( '<th> <font color=red> '||v_get_desc_borr||'  </font> </th>');

                        end if;

                    twbkfrmt.p_tablerowclose;

                    twbkfrmt.p_tablerowopen ();


                    twbkfrmt.p_tabledataheader (
                        G$_NLS.Get ('BWSKOAC1-0022', 'SQL', 'Detail Code'));
                    twbkfrmt.p_tabledataheader (
                        G$_NLS.Get ('BWSKOAC1-0023', 'SQL', 'Description'));
                    twbkfrmt.p_tabledataheader (
                        G$_NLS.Get ('BWSKOAC1-0024', 'SQL', 'Charge'));
                    twbkfrmt.p_tabledataheader (
                        G$_NLS.Get ('BWSKOAC1-0025', 'SQL', 'Payment'));
                    twbkfrmt.p_tabledataheader (
                        G$_NLS.Get ('BWSKOAC1-0026', 'SQL', 'Balance'));
                    twbkfrmt.p_tabledataheader (
                        G$_NLS.Get ('BWSKOAC1-0049', 'SQL', 'Due Date'));

                                HTP.formopen (
                                curl =>
                                    'tzkpufc.p_select_provider_alt',
                                cattributes =>
                                       'name= "form_'
                                    || tbraccd_viewc_rec.TZVACCD_SDOC_CODE
                                    || '_'
                                    || tbraccd_viewc_rec.TZVACCD_TERM_CODE
                                    || '"');
                            twbkfrmt.P_FormHidden (
                                cname    => 'p_term_code',
                                cvalue   => tbraccd_viewc_rec.TZVACCD_TERM_CODE);
                            twbkfrmt.P_FormHidden (
                                cname    => 'p_sdoc_code',
                                cvalue   => tbraccd_viewc_rec.TZVACCD_SDOC_CODE);
                            twbkfrmt.P_FormHidden ('p_transactions', v_trans);
				   -- 11MAY20 se incluye CRN como parte de la validación     
				   open c_get_crn(global_pidm, v_trans);
				   fetch c_get_crn into v_crn;
				   close c_get_crn; 



                    if v_get_borrado = 'N' or v_get_borrado is null then 

                        IF TZKPUFC.f_get_valid_document(global_pidm, tbraccd_viewc_rec.TZVACCD_TERM_CODE, tbraccd_viewc_rec.TZVACCD_CAMPUS, tbraccd_viewc_rec.TZVACCD_SDOC_CODE, v_crn) = 'Y' THEN
                                --HTP.p ( '<th> <button type="button" onclick="this.form.submit()">Generar Prefactura</button> </th>');
                                --onclick="this.disabled=true;this.value='Submitting...'; this.form.submit();">
                                HTP.p ( '<th> <button type="button" onclick="this.disabled=true; this.form.submit();">Generar Prefactura</button> </th>');

                        ELSE
                                HTP.p ( '<th> <font color=red> *Fecha de pago fuera de vigencia. </font> </th>');
                        END IF;

                            v_trans := '';

                        end if;                   
                    end if;


                    HTP.formClose;
                    twbkfrmt.p_tablerowclose;


                term_chrg_var := '';
                term_pay_var := '';


                IF tbraccd_viewc_rec.TZVACCD_TYPE_IND = 'C'
                THEN
                    term_chrg_var := tbraccd_viewc_rec.TZVACCD_AMOUNT ;
                ELSE
                    term_pay_var := tbraccd_viewc_rec.TZVACCD_AMOUNT;
                END IF;


                IF tbraccd_viewc_rec.TZVACCD_TYPE_IND = 'C'
                THEN
                    term_chrg := term_chrg + tbraccd_viewc_rec.TZVACCD_AMOUNT;
                ELSE
                    term_pay := term_pay + tbraccd_viewc_rec.TZVACCD_AMOUNT;
                END IF;

                term_bal := term_bal + tbraccd_viewc_rec.TZVACCD_BALANCE;
                total_bal := total_bal + tbraccd_viewc_rec.TZVACCD_BALANCE;

                twbkfrmt.p_tablerowopen ();
                twbkfrmt.p_tabledata (tbraccd_viewc_rec.TZVACCD_DETAIL_CODE);
                twbkfrmt.p_tabledata (tbraccd_viewc_rec.TZVACCD_DESC);
                twbkfrmt.p_tabledata (
                    TO_CHAR (term_chrg_var, 'L999G999G999G990D99'),
                    'right');
                twbkfrmt.p_tabledata (
                    TO_CHAR (term_pay_var, 'L999G999G999G990D99'),
                    'right');
                twbkfrmt.p_tabledata (
                    TO_CHAR (tbraccd_viewc_rec.TZVACCD_BALANCE,
                             'L999G999G999G990D99'),
                    'right');
                twbkfrmt.p_tabledata (
                    tbraccd_viewc_rec.TZVACCD_EFFECTIVE_DATE);
                twbkfrmt.p_tablerowclose;
            ELSE
                IF tbraccd_viewc%ROWCOUNT = 0
                THEN
                    twbkfrmt.p_printmessage (
                        G$_NLS.Get (
                            'BWSKOAC1-0027',
                            'SQL',
                            'No account detail exists on your record.'),
                        'WARNING');
                    EXIT;
                ELSE


                    twbkfrmt.p_tablerowopen ();
                    twbkfrmt.p_tabledatalabel (
                        G$_NLS.Get ('BWSKOAC1-0028', 'SQL', 'Term Charges:'),
                        ccolspan   => 1 + colspan_var);
                    twbkfrmt.p_tabledata (
                        TO_CHAR (term_chrg, 'L999G999G999G990D99'),
                        'right');
                    twbkfrmt.p_tablerowclose;
                    twbkfrmt.p_tablerowopen ();
                    twbkfrmt.p_tabledatalabel (
                        G$_NLS.Get ('BWSKOAC1-0029',
                                    'SQL',
                                    'Term Credits and Payments:'),
                        ccolspan   => 2 + colspan_var);
                    twbkfrmt.p_tabledata (
                        TO_CHAR (term_pay, 'L999G999G999G990D99'),
                        'right');
                    twbkfrmt.p_tablerowclose;
                    twbkfrmt.p_tablerowopen ();
                    twbkfrmt.p_tabledatalabel (
                        G$_NLS.Get ('BWSKOAC1-0030', 'SQL', 'Term Balance:'),
                        ccolspan   => 3 + colspan_var);
                    twbkfrmt.p_tabledata (
                        TO_CHAR (term_bal, 'L999G999G999G990D99'),
                        'right');
                    twbkfrmt.p_tablerowclose;
                    twbkfrmt.p_tablerowopen ();
                    twbkfrmt.p_tabledatalabel (
                        G$_NLS.Get ('BWSKOAC1-0031',
                                    'SQL',
                                    'Account Balance:'),
                        ccolspan   => 3 + colspan_var);
                    twbkfrmt.p_tabledata (
                        TO_CHAR (total_bal, 'L999G999G999G990D99'),
                        'right');
                    twbkfrmt.p_tablerowclose;

                    twbkfrmt.p_tableclose;
                    EXIT;
                END IF;
            END IF;
        END LOOP;

        CLOSE tbraccd_viewc;

        twbkwbis.p_closedoc (curr_release);
        COMMIT;

    END;

END BZSKOACC;






/
