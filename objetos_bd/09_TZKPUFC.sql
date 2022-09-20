SET DEFINE OFF;
CREATE OR REPLACE PACKAGE            BANINST1."TZKPUFC" 
AS
--
-- FILE NAME..: tzkpufc.sql
-- RELEASE....: 1.0
-- OBJECT NAME: TZKPUFC
-- PRODUCT....: TAISMGR
-- USAGE......: Paquete principal de Pago en Línea y Generación de Documentos de Venta 
--                     (Prefactura, Factura, Nota de Crédito, Comprobantes, Depósitos) y Representaciónes Gráficas PDF.
-- COPYRIGHT..: Neoris 2020 
--
-- DESCRIPTION:
--
--    El paquete se compone de procedimientos y funciones para la generación, envío de documentos así como la administración de Pago en Línea.
--    Utilizando Api de Banner y consumo de WS de proveedores de Pago en Línea.
--    Contiene las funcionalidades internas para trabajar en conjunto con el paquete BZSKOACC encargado de la parte de Autoservicios de Banner.
--    Llama al paquete de Becas KZKAWRD para su cálculo y sembrado en estado de cuenta y a los paquetes TZKRPAY Mod Carga de Bancos 
--    y al TZKCONE interpretación de cantidades a letras.
--
--  Cursors:
--
--   c_get_moneda.- Obtiene la moneda definida en gubinst.
--
--  c_get_data_i.- Obtiene los valores de GTVSDAX, External Code, Concept y Comments de acuerdo al tipo,  por Código interno y Grupo de Código.
--
--  get_ssn_c.- Obtiene el NSS del Estudiante de la tabla SPBPERS.
--
--  c_camp_code.- Obtiene el código de campus stvcamp consultando el Dicd Code numérico.
-- 
--  c_get_credentials.- Obtiene las credenciales y rutas de los operadores configurados en la tabla TZVOPRD. 
--
--  c_get_sdoc_code_val.- Obtiene el tipo de documento creado en la tabla TZRDPRF de bancos.
--
-- c_get_crn.- Obtiene el CRN del estado de cuenta por el numero de transacción.
--
-- c_get_doc_fecha_valida.- Obtiene la fecha de documento válido (fecha de vigencia en tabla TZRDPRF).
--
--  Functions:
--
-- f_get_due_date
-- Funcion que valida la fecha configurada en TZARVEN para los documentos de venta.
--
-- f_get_docnum_fmt
--Funcion que retorna el formato de la prefactura presentada al usuario/estudiante.
--
-- f_get_balance
-- Funcion que obtiene el balance real del estado de cuenta del estudiante.
--
--f_get_iden
-- Fucion que obtiene la cédula, pasaporte o RUC del estudiante.
--
--f_get_sovlcur
-- Funcion principal que retorna los valores de programa, nivel, campus del estudiante
--
-- f_get_doc_number
-- Obtiene el numero de documento con base al pidm numero de transacciones y tipo de documento.
--
-- f_doc_num_pagado_dprf
-- Funcion que valida si un documento ya fue pagado. 
--
-- f_doc_num_pagado
-- Funcion que valida si el documento esta pagado, con calculo interno del tipo de documento.
--
-- f_get_doc_number_r
-- Obtiene el numero de documento con base a las transacciones existentes en la tabla TVRSDOC.
-- 
-- f_get_sde_val
-- Obtiene el valor de un SDE, Dato suplementario.
--
-- f_get_valid_document
-- Funcion que valida si el documento es válido compara las fechas en las tablas de configuracion TZARVEN
-- 
-- f_get_acum_str
-- Funcion que compara los numeros de transaccion que conforman un documento.
--
-- f_get_url_pay
-- Funcion que retorna la URL encriptada para proceso de pago en línea.
-- 
-- f_encrypt
-- Funcion que encripta los valores de ID y numero de documento a pagar por pago en Línea.
--
-- f_decrypt
 -- Funcion de desencripción, de los valores ID y numero de documento utilizado para Pago en Línea.
--
--  Procedures:
--
-- p_gen_doc.-  Procedimiento principal para generación de prefacturas contiene las validaciónes y configuración para llamar al proceso interno de
-- generación de documentos.
-- 
--	p_gen_document_ssb.- Procedimiento que genera la prefactura desde autoservicios.
--
-- ws_p2p.- Procedimiento principal que gestiona la conectividad con los proveedores de pago en línea, obtiene los datos y 
-- genera la trama que se enviará, almacena la información para rastreo y obtiene la configuración para cada proveedor.
--
-- getRequestInformation.- Utilizado para place to pay para obtener la franquicia e installments, 
-- una vez recibido el estatus mediante el web service provisto por Banner en modo escucha.
--
-- p_update_tzrpayu.- WS de Notificación, WS modo escucha que actualiza el estatus de una transacción de Place to Pay 
--  (Internamente valida que el signature sea correcto de lo contrario el procedimiento podrá regresar lo siguiente:
-- p_error_msg  :=  SGF  (Signature inválido)
-- p_error_msg  := NULL (Datos actualizados correctamente en tabla)
-- p_error_msg  := NDF (No Data Found)
-- p_error_msg  := ERR (Error Others al actualizar)
--
-- p_select_provider_alt.- Procedimiento que visualiza la página de selección de proveedores en Autoservicos de Banner, 
--  quien consume los procedimientos de generación de prefactura y el que realiza la conectividad con el proveedor de servicios de pago en línea.
--
-- p_auto_close.- Procedimiento utilizado por el hall de pagos para auto cerrar las páginas visitadas.
--
-- p_kushki_trx.- Procedimiento principal del proveedor de servicios Kushki. Pago en Línea.
--
-- p_getStatus.- Procedimiento principal del proveedor de servicios Place to Pay para leer y colectar y procesar información de las transacciones. 
-- (Utilizado por el JOB UPDATE_STATUS_IBA009)
--
-- p_pay_hall_ns.- Hall de pagos para estudiantes con opciones de búsqueda por ID, Cédula y Prefactura a pagar. Sin firma en autoservicios de Banner.
--
-- p_show_pdf.- Procedimiento de despliegue de PDF de prefacturas.

---- p_show_pdf_solicitudes - Procedimiento para despliegue de pdf y envio de correo de prefacturas de solicitudes financieras

-- p_awards_courses.- Proceso de calculo de Becas (aumento y disminución) del Estudiante que será sembrado en el estado de cuenta previo a generacion de prefactura.
--
-- p_ins_tzrrlog.- Procedimiento general para almacenar información tipo Log de la ejecución de los procesos de generacion de documentos de venta,
-- pago en línea.
--
-- p_insert_tzrdprf.- Procedimiento que inserta la información de la prefactura generada en la tabla principal de bancos.
--
-- p_gen_sales_doc.- Proceso principal de generacion de documentos de venta.
--
--p_insert_tvbsdoc .- Procedimiento que inserta el encabezado del documento de venta, tabla TVBSDOC.
--
--p_insert_tvrsdoc .- Procedimiento que inserta el detalle del documento de venta, tabla TVRSDOC.
--
-- p_insert_tzrfact_fact.- Procedimiento que inserta la información de la prefactura en la tabla TZRFACT.
-- 
-- p_get_next_folio .- Procedimiento que obtiene el folio siguiente del documento de venta.
--
-- p_update_secuencia.- Procedimiento que actualiza la secuencia del documento de venta en las tablas nativas de Banner.
--
-- p_cancel_sales_doc .- Procedimiento principal para la cancelacion de documentos de venta.
--
-- send_mail.- Procedimiento de envio de prefactura por correo electrónico.
--
-- p_pay_adm_ns.- Pagina de pago en línea para proceso de Admisiones.
-- 
--p_gen_documents.- Genera prefacturas desde Admin Pages individual y Masivo.
--
-- p_create_header_2 .- Crea estructura del Log TZPPFACT
--
-- DESCRIPTION END
--

    TYPE pArray IS VARRAY(1) OF VARCHAR2(30);
    vPrincipal pArray; 

    TYPE arr IS TABLE OF VARCHAR2(32) INDEX BY PLS_INTEGER;
   g_array arr;
--ACASTILLO Refinanciación planes de pago.
PROCEDURE p_main (p_one_up_no IN NUMBER, p_user_id IN VARCHAR2);
------
PROCEDURE p_gen_document_ssb (p_pidm   IN NUMBER, p_term_code    IN VARCHAR2,  p_sdoc_code  IN VARCHAR2, p_out OUT varchar2);
procedure p_gen_factura_cero (p_pidm  IN NUMBER, p_doc_num  IN VARCHAR2, p_user in varchar2, p_return out varchar2);
procedure p_gen_factura_deposito (p_pidm  IN NUMBER, p_doc_num  IN VARCHAR2, p_user in varchar2, p_return out varchar2);

procedure p_regenera_factura (p_pidm  IN NUMBER, p_doc_num  IN VARCHAR2);
PROCEDURE p_reenvia_prefactura (p_one_up_no IN NUMBER);
procedure p_gen_factura_tipo (p_pidm number, p_term_code varchar2, p_contract_number number default null, p_user varchar2 default null, p_return out varchar2);

procedure p_gen_factura_terceros (p_pidm number, p_term_code varchar2, p_doc_number varchar2,  p_return out varchar2);

procedure p_reimpresion_documento (p_pidm  IN NUMBER, p_sdoc_code in varchar2,  p_doc_number  IN VARCHAR2, p_user in varchar2 default null,  p_return out varchar2) ;

procedure  p_genera_factura (p_TVRMLCB_PIDM number, p_TERM_CODE varchar2,  v_doc_number varchar2, p_TVRMLCB_USER varchar2);
procedure p_genera_comprobante_NPP (p_TVRMLCB_PIDM number, p_TERM_CODE varchar2,  v_doc_number varchar2, p_TVRMLCB_USER varchar2);

    PROCEDURE p_gen_sales_doc (p_pidm            IN     NUMBER,
                               p_campus          IN     VARCHAR2,
                               p_term_code       IN     VARCHAR2,
                               p_sdoc_code       IN     VARCHAR2,
                               p_curr_code       IN     VARCHAR2,
                               p_data_origin     IN     VARCHAR2,
                               p_user_id         IN     VARCHAR2,
                               p_trans_numbers   IN     VARCHAR2,
                               p_doc_num            OUT VARCHAR2,
                               p_error_ind          OUT VARCHAR2,
                               p_error_msg          OUT VARCHAR2);

PROCEDURE p_gen_doc (p_pidm        IN     NUMBER,
                         p_trans       IN     VARCHAR2,
                         p_sdoc_code   IN     VARCHAR2,
                         p_site_code   IN     VARCHAR2,
                         p_term_code   IN     VARCHAR2,
                         p_curr_code   IN     VARCHAR2,
                         p_user_id     IN     VARCHAR2,
                         p_program     IN     VARCHAR2,
                         p_levl_code   IN     VARCHAR2,
                         p_doc_num        OUT VARCHAR2,
                         p_error_ind      OUT VARCHAR2,
                         p_error_msg      OUT VARCHAR2);                               

    PROCEDURE p_roll_terms (p_one_up_no IN NUMBER);


    PROCEDURE p_insert_tzrfact (p_pidm          IN     NUMBER,
                                p_sdoc_code     IN     VARCHAR2,
                                p_doc_number    IN     VARCHAR2,
                                p_crn in varchar2 default null,
                                p_out_message      OUT VARCHAR2);

    PROCEDURE p_cancel_sales_doc (p_pidm          IN     NUMBER,
                                  p_sdoc_code     IN     VARCHAR2,
                                  p_doc_num       IN     VARCHAR2,
                                  p_data_origin   IN     VARCHAR2,
                                  p_user_id       IN     VARCHAR2,
                                  p_error_ind        OUT VARCHAR2,
                                  p_error_msg        OUT VARCHAR2);
PROCEDURE p_gen_documents (p_one_up_no IN NUMBER);

PROCEDURE p_awards_courses (p_pidm IN NUMBER, p_term_code IN VARCHAR2, p_error_msg OUT varchar2);

    PROCEDURE p_get_next_folio (
        p_doctype         IN     tvrsdsq.tvrsdsq_sdoc_code%TYPE,
        p_user            IN     VARCHAR2,
        p_camp_code       IN     tvrsdsq.tvrsdsq_camp_code%TYPE,
        p_prefix1         IN  tvrsdsq.tvrsdsq_prefix_1%TYPE,
        p_prefix2         IN  tvrsdsq.tvrsdsq_prefix_2%TYPE,
        p_next_numdoc     IN OUT tvrsdsq.tvrsdsq_max_seq%TYPE,
        p_camp_district   IN OUT stvcamp.stvcamp_dicd_code%TYPE,
        p_seq             IN OUT tvrsdsq.tvrsdsq_seq_num%TYPE,
        p_errormsg        IN OUT VARCHAR2);



    PROCEDURE ws_p2p (p_pidm_oprd     NUMBER,
                      p_pidm          NUMBER,
                      p_sede          VARCHAR2,
                      p_sdoc_code     VARCHAR2,
                      p_doc_number    VARCHAR2,
                      p_term          VARCHAR2,
                      p_servicio varchar2,
                      p_iden_ws varchar2,
                      p_url_return varchar2 default null);

        PROCEDURE getRequestInformation ( p_pidm_oprd number,
                      p_pidm          NUMBER,
                      p_sede varchar, 
                      lc_request_id number,
                      p_servicio varchar2,
                      p_response_out out  clob 
                      );               


PROCEDURE p_select_provider_alt (p_term_code       VARCHAR2 default null,
                                 p_sdoc_code       VARCHAR2 default null,
                                 p_transactions    VARCHAR2 default null);

    procedure p_auto_close;

    procedure p_kushki_trx (p_rowid varchar2,  urlreturn varchar2 default null, cart_id varchar2 default null, kushkiToken varchar2  default null, kushkiPaymentMethod varchar2  default null, kushkiDeferredType varchar2  default null, kushkiDeferred varchar2  default null, kushkiMonthsOfGrace varchar2  default null) ;

    PROCEDURE p_update_secuencia (
        p_doctype     IN     tvrsdsq.tvrsdsq_sdoc_code%TYPE,
        p_user        IN     VARCHAR2,
        p_prefix1     IN     VARCHAR2,
        p_prefix2     IN     VARCHAR2,
        p_camp_code   IN     VARCHAR2,
        p_secuencia   IN     NUMBER,
        p_error          OUT VARCHAR2);



    FUNCTION f_get_doc_number (p_pidm         NUMBER,
                               p_trans_num    VARCHAR2,
                               p_sdoc_code    VARCHAR2)
        RETURN VARCHAR2;

FUNCTION f_get_doc_number_r (p_pidm         NUMBER,
                               p_trans_num    VARCHAR2,
                               p_sdoc_code    VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE p_create_header (in_seq_no              NUMBER,
                               in_user_id             VARCHAR2,
                               p_file_number      OUT NUMBER,
                               app_name        IN     VARCHAR2);

    PROCEDURE p_create_header_2 (in_seq_no              NUMBER,
                               in_user_id             VARCHAR2,
                               p_file_number      OUT NUMBER,
                               app_name        IN     VARCHAR2);


    PROCEDURE p_getStatus;


    PROCEDURE p_insert_tzrdprf (t_pidm               NUMBER,
                                t_sdoc_code          VARCHAR2,
                                t_doc_number         VARCHAR2,
                                t_camp_code          VARCHAR2,
                                t_term_code          VARCHAR2,
                                t_doc_status         VARCHAR2,
                                t_doc_comments       VARCHAR2,
                                t_doc_date           DATE,
                                t_due_doc_date       DATE,
                                t_pref_doc_number    VARCHAR2,
                                t_doc_amount         NUMBER,
                                t_iden_type          VARCHAR2,
                                t_iden_number        VARCHAR2
                                                             ,
                                t_pay_amount         NUMBER
                                                           ,
                                t_user_id            VARCHAR2,
                                t_data_origin        VARCHAR2
                                                             );



    function f_get_sde_val (p_table varchar2, p_att_name varchar2, p_parenttab varchar2, p_type varchar2 default null) return varchar2;

    FUNCTION getData(data IN SYS.ANYDATA)    RETURN VARCHAR2;


    FUNCTION f_get_acum_str (cadena IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION f_get_valid_document (p_pidm        IN NUMBER,
                                   p_term        IN VARCHAR2,
                                   p_campus      IN VARCHAR2,
                                   p_sdoc_code   IN VARCHAR2,
                                   p_crn in varchar2 default null)
        RETURN VARCHAR2;


    FUNCTION f_get_docnum_fmt (p_doc_num IN VARCHAR2)
        RETURN VARCHAR2;


    FUNCTION f_get_due_date (p_pidm        IN NUMBER,
                                   p_term        IN VARCHAR2,
                                   p_campus      IN VARCHAR2,
                                   p_sdoc_code   IN VARCHAR2,
                                   p_crn in varchar2 default null) 
        RETURN DATE;


    FUNCTION f_get_iden (p_pidm    NUMBER,
                         p_type    VARCHAR2 DEFAULT NULL,
                         p_sri     VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION f_get_balance (p_pidm        IN NUMBER,
                            p_term_code   IN VARCHAR2,
                            p_sdoc_code   IN VARCHAR2,
                            p_doc_number IN varchar2)
        RETURN NUMBER;

    PROCEDURE send_mail (p_to          IN VARCHAR2,
                                       p_from        IN VARCHAR2,
                                       p_subject     IN VARCHAR2,
                                       p_text_msg    IN VARCHAR2 DEFAULT NULL,
                                       p_attach_name IN VARCHAR2 DEFAULT NULL,
                                       p_attach_mime IN VARCHAR2 DEFAULT NULL,
                                       p_attach_blob IN BLOB DEFAULT NULL,
                                       p_smtp_host   IN VARCHAR2,
                                       p_smtp_port   IN NUMBER DEFAULT 25);


    PROCEDURE p_show_pdf (p_pidm IN NUMBER, p_doc_number IN NUMBER, p_send_mail in varchar2 default 'N', p_web  in varchar2 default null, p_footer in varchar2 default null); 
--Neoris hermes.navarro
--PROCEDURE p_show_pdf_solicitudes (p_pidm IN NUMBER, p_doc_number IN NUMBER, p_send_mail in varchar2 default 'N', p_web  in varchar2 default null, p_cod_sol IN NUMBER,p_footer in varchar2 default null);
--Neoris hermes.navarro
 procedure  p_credit_note (p_pidm IN NUMBER, p_sri_doc_number IN varchar2, p_user_id IN varchar2 default null, p_reason IN varchar2 default null, p_cuenta_puente_ind IN varchar2 default null,  p_return OUT varchar2);

procedure  p_credit_note_e (p_pidm IN NUMBER, p_sri_doc_number IN varchar2, p_user_id IN varchar2 default null, p_reason IN varchar2 default null, p_cuenta_puente_ind IN varchar2 default null, p_return OUT varchar2);

procedure  p_canc_credit_note (p_sri_nc_doc_number IN varchar2, p_user_id IN varchar2 default null, p_return OUT varchar2);

 procedure  p_credit_note_split (p_pidm IN NUMBER, p_sri_doc_number IN varchar2, p_return OUT varchar2);

    procedure p_update_tzrpayu (p_request_id in varchar2, p_reference in varchar2, p_status in varchar2, p_message in varchar2, p_date in varchar2, p_signature in varchar2,  p_reponse_json in varchar2, p_error_msg out varchar2 ) ;

function f_get_amt_diference_nc (p_pidm in number, p_original_trx in number) return number;
function f_get_amt_diference_ssb (p_pidm in number, p_original_trx in number) return number;

function f_get_ordenamiento (p_TTVPAYT_CODE varchar2) return number;

function f_doc_num_pagado (p_pidm number, p_doc_number number default null, p_trans varchar2 default null) return varchar2;

function f_doc_num_pagado_dprf(p_pidm number, p_sdoc_code varchar2 default null, p_doc_number varchar2) return varchar2; 

procedure p_insert_tvbsdoc (p_sdoc_code varchar2,
                                     p_doc_number varchar2,
                                     p_pidm number,
                                     p_prefix_1 varchar2,
                                     p_prefix_2 varchar2,
                                     p_int_doc_number number,
                                     p_comments varchar2,
                                     p_user_id varchar2,
                                     p_data_origin varchar2,
                                     p_date date,
                                     p_print_pidm number,
                                     p_print_id varchar2,
                                     p_print_id_source varchar2,
                                     p_atyp_code varchar2,
                                     p_msg_out out varchar2);


procedure p_insert_tvrsdoc (p_pidm number ,
                                         p_pay_tran_number number,
                                         p_chg_tran_number number,
                                         p_doc_number varchar2,
                                         p_doc_type varchar2,
                                         p_int_doc_number number,
                                         p_user_id varchar2,
                                         p_data_origin varchar2,
                                         p_comments varchar2,
                                         p_sdoc_code varchar2,
                                         p_msg_out out varchar2);

procedure p_insert_tzrfact_fact (p_PIDM number,p_SDOC_CODE varchar2,p_DOC_NUMBER varchar2,p_CURR_PROGRAM varchar2,p_SALE_DOCNUM varchar2,p_DET_CODE_DOC varchar2,p_AMNT_TRANS number,p_TRAN_NUM number,p_SRI_DOCNUM varchar2,p_RECEIPT_NUM number, p_FACT_DATE date,p_ACTIVITY_DATE date,p_USER varchar2, p_term_code varchar2
,p_TRDPARTY_ID varchar2 default null, p_TRDPARTY_PIDM number default null, p_TRDPARTY_NAME varchar2 default null, p_STPERDOC_QTY varchar2 default null);

procedure p_upd_sri_doc_num (p_PIDM number,p_DOC_NUMBER varchar2, p_sri_doc_num varchar2, p_pay_tran_num number default null );

function f_get_sovlcur (p_pidm number, p_term_code varchar2, p_type varchar2 ) return varchar2 ;

procedure p_upd_TZRDPRF(p_PIDM number,p_DOC_NUMBER varchar2);

procedure p_ins_tvrmlcb_temp(p_SESSION_ID varchar2, p_PIDM number, p_TRAN_ORIGINAL number, p_doc_number varchar2, p_folio_factura varchar2 );

procedure p_del_tvrmlcb_temp(p_SESSION_ID varchar2 );

function f_get_temp_doc_number (p_SESSION_ID varchar2, p_type varchar2) return varchar2;

procedure p_pay_adm_ns (p_val varchar2);

procedure p_pay_hall_ns (p_type varchar2 default null, p_val varchar2 default null, op varchar2 default null);

function f_get_url_pay (p_pidm number, p_doc_num varchar2) return varchar2;

function f_encrypt (p_val varchar2, p_key VARCHAR2) return varchar2;

function f_decrypt (p_val VARCHAR2, p_key VARCHAR2) return VARCHAR2;

  procedure p_ins_nc_split (p_PIDM  varchar2, p_SDOC_CODE  varchar2,p_DOC_NUMBER_REL  varchar2,p_SDOC_CODE_REL  varchar2,p_SRI_DOCNUM_REL  varchar2,  p_TERM_CODE  varchar2,p_TRAN_NUMBER  varchar2
,p_DETAIL_CODE  varchar2,p_AMOUNT  varchar2,p_REASON  varchar2,p_ALL_IND  varchar2, p_CREATE_DATE  date,p_USER_ID  varchar2,p_DATA_ORIGIN  varchar2, p_return out varchar2);

procedure p_ins_tzrrlog ( 
 p_pidm  number default null,
 p_process varchar2  default null,
 p_reference varchar2 default null,
 p_log varchar2 default null,
 p_user_id varchar2 default null
 );

function f_is_comprobante (p_pay_detail_code varchar2) return varchar2;

procedure p_gen_comprobante_pago (p_pidm number, p_sri_doc_number varchar2 default null, p_user varchar2 default null, p_return out varchar2);

procedure p_gen_comprobante_pago_caja (p_pidm number, p_doc_number varchar2 default null, p_return out varchar2);


    PROCEDURE p_show_nota_credito (
                      p_pidm         IN NUMBER,
                      p_tzrfact_crednt_sricode   IN tzrfact.tzrfact_crednt_sricode%TYPE
                      );
function f_valid_pago_total (p_pidm 			tzrfact.tzrfact_pidm%type,		
							 p_receipt			tzrfact.tzrfact_receipt_num%type,
							 p_internal_receipt	tzrfact.tzrfact_internal_receipt_num%type
						) return varchar2;

PROCEDURE p_show_comprobante(p_pidm       IN NUMBER,
                       p_receipt   IN tzrfact.TZRFACT_RECEIPT_NUM%TYPE);


 FUNCTION f_get_type_credit_note( p_detail_code IN TZRFACT.TZRFACT_DET_CODE_DOC%TYPE )
    RETURN VARCHAR2;

FUNCTION f_get_type_comprobante( p_detail_code IN TZRFACT.TZRFACT_DET_CODE_DOC%TYPE, p_is_plan in varchar2 )
    RETURN VARCHAR2;

procedure p_upd_cancel_ind (p_pidm number, p_doc_number varchar2, p_type varchar2, p_result out varchar2);


PROCEDURE p_show_fact (
                      p_pidm         IN NUMBER,
                      p_sri_docnum   IN tzrfact.tzrfact_sri_docnum%TYPE
                      );

PROCEDURE p_factura_masivo_pdf (p_one_up_no IN NUMBER);

procedure p_get_pdf_masivo (p_filename in varchar2);

PROCEDURE p_gen_alter_doc (p_pidm            IN     NUMBER,
                               p_sdoc_code       IN     VARCHAR2,
                               p_trans_numbers   IN     VARCHAR2,
                               p_user IN varchar2,
                               p_error_msg          OUT VARCHAR2);
FUNCTION f_get_amount_trasacc (p_detail_code        varchar2,
                            p_tran_pago     number,
                            p_amount    number,
                            p_pidm	number)
        RETURN number;
END tzkpufc;


/


CREATE OR REPLACE PACKAGE BODY            BANINST1."TZKPUFC" 
IS
--
-- FILE NAME..: tzkpufc.sql
-- RELEASE....: 1.0
-- OBJECT NAME: TZKPUFC
-- PRODUCT....: TAISMGR
-- USAGE......: Paquete principal de Pago en Línea y Generación de Documentos de Venta 
--                     (Prefactura, Factura, Nota de Crédito, Comprobantes, Depósitos) y Representaciónes Gráficas PDF.
-- COPYRIGHT..: Neoris 2020 
--
  const_application_name     CONSTANT VARCHAR2 (32) := 'SZPREFI'; -- nombre del PRO-C
  const_package_name         CONSTANT VARCHAR2 (32) := 'SZKPUFC';
  IN_TIME INT:=3; 
  v_now DATE;
   p_url              varchar2(1000); 
   p_url_close    varchar2(1000);
    global_pidm     spriden.spriden_pidm%TYPE;
        v_return_url      VARCHAR2 (400);
        lc_status         VARCHAR2 (100);
        lc_message        VARCHAR2 (500);
        lc_reason         VARCHAR2 (100);
        lc_date           VARCHAR2 (100);
        lc_requestid      NUMBER;
        lc_franchise  VARCHAR2 (30);
        lc_installments VARCHAR2 (30);
        lc_total number;
        lc_currency VARCHAR2 (30);
    v_moneda        VARCHAR2 (10);
    p_doc_num       tvrsdoc.tvrsdoc_doc_number%TYPE;
    p_error_ind     VARCHAR2 (100);
    p_error_msg     VARCHAR2 (500);
    p_user_create   VARCHAR2 (100);

    lv_inf          SPBPERS.SPBPERS_SSN%TYPE;
    p_id_puce       spriden.spriden_id%TYPE;
    p_sdoc_pref     VARCHAR2 (100);
    p_obs_dflt      VARCHAR2 (100);
    p_camp_x        VARCHAR2 (100);
    p_interna   VARCHAR2(3);
    p_camp_pref VARCHAR2 (100);
    p_term_pref VARCHAR2 (100);
p_fecha_vigencia_valida varchar2(1);
p_sdoc_code_val varchar2(10);

v_valida_pagado varchar2(1);

--Obtiene la fecha de documento válido (fecha de vigencia en tabla TZRDPRF).
--cursor c_get_doc_fecha_valida (p_pidm number, p_doc_number varchar2) is
cursor c_get_doc_fecha_valida (p_doc_number varchar2) is
select  case when trunc(TZRDPRF_DUE_DOC_DATE) >= trunc(sysdate) THEN 
              'Y'
           else 'N'   
        end fecha_valida
from tzrdprf where 
--TZRDPRF_PIDM = p_pidm 
tzrdprf_doc_number = p_doc_number
and TZRDPRF_DOC_STATUS = 'CREADO';
v_get_borrado varchar2(1);
v_get_desc_borr varchar2(30);

cursor c_dat_prefac (p_doc_number varchar2) is
    select TZRFACT_TERM_CODE, TZRFACT_CAMPUS
    from tzrfact
    where TZRFACT_DOC_NUMBER = p_doc_number
    fetch first 1 rows only;

cursor c_get_borrado (p_term varchar2, p_camp varchar2) is
    select GTVSDAX_TRANSLATION_CODE, GTVSDAX_DESC
    from gtvsdax 
    where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' 
    and GTVSDAX_EXTERNAL_CODE = p_term
    and GTVSDAX_INTERNAL_CODE = 'TERM_BORRA'
    and GTVSDAX_CONCEPT = p_camp
    and GTVSDAX_TRANSLATION_CODE = 'Y';
-- Obtiene el CRN del estado de cuenta por el numero de transacción.
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

-- Obtiene el tipo de documento creado en la tabla TZRDPRF de bancos.
cursor c_get_sdoc_code_val (
p_pidm in number,
p_doc_number  IN VARCHAR2,
p_camp_code   IN VARCHAR2,
p_term_code   IN VARCHAR2
) 
IS
select TZRDPRF_SDOC_CODE 
  from TZRDPRF 
where TZRDPRF_PIDM = p_pidm
        and TZRDPRF_DOC_NUMBER = p_doc_number
        and TZRDPRF_CAMP_CODE = p_camp_code
        and TZRDPRF_TERM_CODE = p_term_code;

-- Obtiene las credenciales y rutas de los operadores configurados en la tabla TZVOPRD. 
CURSOR c_get_credentials (
            p_pidm_oprd   IN NUMBER,
            p_camp_code   IN VARCHAR2,
            p_servicio in varchar2)
        IS
            SELECT tzvoprd_endpoint, tzvoprd_trankey, tzvoprd_login
              FROM tzvoprd
             WHERE     tzvoprd_pidm = p_pidm_oprd
                   AND tzvoprd_camp_code = p_camp_code
                   AND TZVOPRD_SERV = p_servicio
                   AND TRUNC (SYSDATE) BETWEEN tzvoprd_start_date
                                           AND tzvoprd_end_date;

--Obtiene el código de campus stvcamp consultando el Dicd Code numérico.
    CURSOR c_camp_code (p_campus NUMBER)
    IS
        SELECT STVCAMP_CODE
          FROM stvcamp
         WHERE STVCAMP_DICD_CODE = p_campus AND ROWNUM = 1;

    p_sede          sovlcur.sovlcur_camp_code%TYPE;
    p_levl          sovlcur.sovlcur_levl_code%TYPE;
    p_program       sovlcur.sovlcur_program%TYPE;

-- Obtiene el NSS del Estudiante de la tabla SPBPERS.
    CURSOR get_ssn_c (p_pidm SPRIDEN.SPRIDEN_PIDM%TYPE)
    IS
        SELECT SPBPERS_SSN
          FROM SPBPERS
         WHERE SPBPERS_PIDM = p_pidm;

-- Obtiene los valores de GTVSDAX, External Code, Concept y Comments de acuerdo al tipo,  por Código interno y Grupo de Código.
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

    p_oracle_wallet_path  gtvsdax.gtvsdax_comments%type;
    p_oracle_wallet_pass  gtvsdax.gtvsdax_external_code%type;

-- Obtiene la moneda definida en gubinst.
    CURSOR c_get_moneda
    IS
        SELECT gubinst_base_curr_code FROM gubinst;


    p_endpoint      VARCHAR2 (1000);
    p_login         VARCHAR2 (500);
    p_trankey       VARCHAR2 (500);

-- Procedimiento de envio de prefactura por correo electrónico.
-- Utiliza la funcionalidad UTL_SMTP.
--
    PROCEDURE send_mail (p_to            IN VARCHAR2,
                         p_from          IN VARCHAR2,
                         p_subject       IN VARCHAR2,
                         p_text_msg      IN VARCHAR2 DEFAULT NULL,
                         p_attach_name   IN VARCHAR2 DEFAULT NULL,
                         p_attach_mime   IN VARCHAR2 DEFAULT NULL,
                         p_attach_blob   IN BLOB DEFAULT NULL,
                         p_smtp_host     IN VARCHAR2,
                         p_smtp_port     IN NUMBER DEFAULT 25)
    AS
        l_mail_conn   UTL_SMTP.connection;
        l_boundary    VARCHAR2 (50) := '----=*#abc1234321cba#*=';
        l_step        PLS_INTEGER := 12000; 
    BEGIN
        l_mail_conn := UTL_SMTP.open_connection (p_smtp_host, p_smtp_port);
        UTL_SMTP.helo (l_mail_conn, p_smtp_host);
        UTL_SMTP.mail (l_mail_conn, p_from);
        UTL_SMTP.rcpt (l_mail_conn, p_to);

        UTL_SMTP.open_data (l_mail_conn);

        UTL_SMTP.write_data (
            l_mail_conn,
               'Date: '          
            || TO_CHAR (SYSTIMESTAMP, 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM')
            || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn,
                             'Subject: ' || p_subject || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn,
                             'Reply-To: ' || p_from || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn,
                             'MIME-Version: 1.0' || UTL_TCP.crlf);
        UTL_SMTP.write_data (
            l_mail_conn,
               'Content-Type: multipart/mixed; boundary="'
            || l_boundary
            || '"'
            || UTL_TCP.crlf
            || UTL_TCP.crlf);

        IF p_text_msg IS NOT NULL
        THEN
            UTL_SMTP.write_data (l_mail_conn,
                                 '--' || l_boundary || UTL_TCP.crlf);
            UTL_SMTP.write_data (
                l_mail_conn,
                   'Content-Type: text/plain; charset="iso-8859-1"'
                || UTL_TCP.crlf
                || UTL_TCP.crlf);

            UTL_SMTP.write_data (l_mail_conn, p_text_msg);
            UTL_SMTP.write_data (l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
        END IF;

        IF p_attach_name IS NOT NULL
        THEN
            UTL_SMTP.write_data (l_mail_conn,
                                 '--' || l_boundary || UTL_TCP.crlf);
            UTL_SMTP.write_data (
                l_mail_conn,
                   'Content-Type: '
                || p_attach_mime
                || '; name="'
                || p_attach_name
                || '"'
                || UTL_TCP.crlf);
            UTL_SMTP.write_data (
                l_mail_conn,
                'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
            UTL_SMTP.write_data (
                l_mail_conn,
                   'Content-Disposition: attachment; filename="'
                || p_attach_name
                || '"'
                || UTL_TCP.crlf
                || UTL_TCP.crlf);

            FOR i IN 0 ..
                     TRUNC (
                         (DBMS_LOB.getlength (p_attach_blob) - 1) / l_step)
            LOOP
                UTL_SMTP.write_data (
                    l_mail_conn,
                    UTL_RAW.cast_to_varchar2 (
                        UTL_ENCODE.base64_encode (
                            DBMS_LOB.SUBSTR (p_attach_blob,
                                             l_step,
                                             i * l_step + 1))));
            END LOOP;

            UTL_SMTP.write_data (l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
        END IF;

        UTL_SMTP.write_data (l_mail_conn,
                             '--' || l_boundary || '--' || UTL_TCP.crlf);
        UTL_SMTP.close_data (l_mail_conn);

        UTL_SMTP.quit (l_mail_conn);
    END;

-- Obtiene el numero de documento con base al pidm numero de transacciones y tipo de documento.
-- Contiene la lógica por numero de transacción y diferencia de montos.
-- si el documento existente ya no corresponde al mismo vs trx y montos o si este ya fue pagado (f_doc_num_pagado_dprf) 
-- , éste lo elimina y genera uno nuevo. Actualiza la tabla TZRDPRF de bancos.
--
    FUNCTION f_get_doc_number (p_pidm         NUMBER,
                               p_trans_num    VARCHAR2,
                               p_sdoc_code    VARCHAR2)
        RETURN VARCHAR2
    IS
        p_doc_number     tvrsdoc.tvrsdoc_doc_number%TYPE;
        p_sdoc_code_e    VARCHAR2 (100);
        p_exist_trans    VARCHAR2 (1000);

        p_valida_exist   NUMBER := 0;
        p_valida_acum    NUMBER := 0;

        cursor c_remanente is 
        SELECT sum(TZVACCD_BALANCE)
                FROM tzvaccd
               WHERE     tzvaccd_pidm = p_pidm 
                     AND TZVACCD_TRAN_NUMBER IN
                             (    SELECT REGEXP_SUBSTR (
                                             REPLACE ((p_trans_num), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                    FROM DUAL
                              CONNECT BY REGEXP_SUBSTR (
                                             REPLACE ((p_trans_num), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                             IS NOT NULL)
            GROUP BY tzvaccd_pidm;

    v_sum_remanente number:= 0;

        CURSOR c_get_doc_num
        IS
              SELECT tvrsdoc_doc_number
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm 
                     AND tvrsdoc_doc_cancel_ind IS NULL
                     AND tvrsdoc_sdoc_code = p_sdoc_code
                     AND tvrsdoc_chg_tran_number IN
                             (    SELECT REGEXP_SUBSTR (
                                             REPLACE ((p_trans_num), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                    FROM DUAL
                              CONNECT BY REGEXP_SUBSTR (
                                             REPLACE ((p_trans_num), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                             IS NOT NULL)
            GROUP BY tvrsdoc_doc_number;



        CURSOR c_get_trans_boleto (
            p_doc_number   IN VARCHAR)
        IS
              SELECT REGEXP_REPLACE (
                         LISTAGG (tvrsdoc_chg_tran_number, ',')
                             WITHIN GROUP (ORDER BY tvrsdoc_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         AS tvrsdoc_chg_tran_number,
                     tvrsdoc_sdoc_code
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm
                     AND tvrsdoc_sdoc_code = p_sdoc_code
                     AND tvrsdoc_doc_number = p_doc_number
            GROUP BY tvrsdoc_pidm, tvrsdoc_sdoc_code;

       CURSOR c_get_trans_pay_boleto (
            p_doc_number   IN VARCHAR)
        IS
              SELECT REGEXP_REPLACE (
                         LISTAGG (tvrsdoc_pay_tran_number, ',')
                             WITHIN GROUP (ORDER BY tvrsdoc_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         AS tvrsdoc_pay_tran_number                    
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm
                     AND tvrsdoc_sdoc_code = p_sdoc_code
                     AND tvrsdoc_doc_number = p_doc_number
                     and tvrsdoc_pay_tran_number <> 0
            GROUP BY tvrsdoc_pidm, tvrsdoc_sdoc_code;

   c_pay_trans varchar2(1000);

    BEGIN
        OPEN c_get_doc_num;
        FETCH c_get_doc_num INTO p_doc_number;
        CLOSE c_get_doc_num;

        OPEN c_get_trans_boleto (p_doc_number);
        FETCH c_get_trans_boleto INTO p_exist_trans, p_sdoc_code_e;
        CLOSE c_get_trans_boleto;

        OPEN c_get_trans_pay_boleto (p_doc_number);
        FETCH c_get_trans_pay_boleto INTO c_pay_trans;
        CLOSE c_get_trans_pay_boleto;

        OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
        FETCH c_get_data_i INTO p_user_create;
        CLOSE c_get_data_i;

       IF c_pay_trans is not null then 
       p_exist_trans := p_exist_trans ||','||c_pay_trans;
       END IF;

        p_valida_acum := f_get_acum_str (p_pidm || p_trans_num);

        p_valida_exist := f_get_acum_str (p_pidm || p_exist_trans);


        IF p_valida_acum = p_valida_exist AND
				f_doc_num_pagado_dprf(p_pidm, p_sdoc_code_e, p_doc_number) = 'Y'
        THEN
            RETURN p_doc_number;
        ELSE

            IF f_doc_num_pagado_dprf(p_pidm, p_sdoc_code_e, p_doc_number) = 'N' then

            BEGIN
                p_cancel_sales_doc (p_pidm,
                                    p_sdoc_code_e,
                                    p_doc_number,
                                    'TZKPUFC',
                                    USER, 
                                    p_error_ind,
                                    p_error_msg);

                BEGIN
                    UPDATE tzrdprf
                       SET tzrdprf_doc_status = 'ANULADA',
                           tzrdprf_user_id = USER,
                           tzrdprf_activity_date = SYSDATE
                     WHERE     tzrdprf_pidm = p_pidm
                           AND tzrdprf_sdoc_code = p_sdoc_code_e
                           AND tzrdprf_doc_number = p_doc_number;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            RETURN NULL;
        ELSE

        RETURN p_doc_number;

        END IF; 

        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;


-- Obtiene el numero de documento con base a las transacciones existentes en la tabla TVRSDOC.
-- 
FUNCTION f_get_doc_number_r (p_pidm         NUMBER,
                               p_trans_num    VARCHAR2,
                               p_sdoc_code    VARCHAR2)
        RETURN VARCHAR2
    IS
        p_doc_number     tvrsdoc.tvrsdoc_doc_number%TYPE;
        p_sdoc_code_e    VARCHAR2 (100);
        p_exist_trans    VARCHAR2 (1000);

        p_valida_exist   NUMBER := 0;
        p_valida_acum    NUMBER := 0;

        CURSOR c_get_doc_num
        IS
              SELECT tvrsdoc_doc_number
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm 
                     AND tvrsdoc_doc_cancel_ind IS NULL
                     AND tvrsdoc_sdoc_code = p_sdoc_code
                     AND tvrsdoc_chg_tran_number IN
                             (    SELECT REGEXP_SUBSTR (
                                             REPLACE ((p_trans_num), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                    FROM DUAL
                              CONNECT BY REGEXP_SUBSTR (
                                             REPLACE ((p_trans_num), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                             IS NOT NULL)
            GROUP BY tvrsdoc_doc_number;



        CURSOR c_get_trans_boleto (
            p_doc_number   IN VARCHAR)
        IS
              SELECT REGEXP_REPLACE (
                         LISTAGG (tvrsdoc_chg_tran_number, ',')
                             WITHIN GROUP (ORDER BY tvrsdoc_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         AS tvrsdoc_chg_tran_number,
                     tvrsdoc_sdoc_code
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm
                     AND tvrsdoc_sdoc_code = p_sdoc_code
                     AND tvrsdoc_doc_number = p_doc_number
            GROUP BY tvrsdoc_pidm, tvrsdoc_sdoc_code;

       CURSOR c_get_trans_pay_boleto (
            p_doc_number   IN VARCHAR)
        IS
              SELECT REGEXP_REPLACE (
                         LISTAGG (tvrsdoc_pay_tran_number, ',')
                             WITHIN GROUP (ORDER BY tvrsdoc_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         AS tvrsdoc_pay_tran_number                    
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm
                     AND tvrsdoc_sdoc_code = p_sdoc_code
                     AND tvrsdoc_doc_number = p_doc_number
                     and tvrsdoc_pay_tran_number <> 0
            GROUP BY tvrsdoc_pidm, tvrsdoc_sdoc_code;

   c_pay_trans varchar2(1000);

    BEGIN
        OPEN c_get_doc_num;
        FETCH c_get_doc_num INTO p_doc_number;
        CLOSE c_get_doc_num;

        OPEN c_get_trans_boleto (p_doc_number);
        FETCH c_get_trans_boleto INTO p_exist_trans, p_sdoc_code_e;
        CLOSE c_get_trans_boleto;

        OPEN c_get_trans_pay_boleto (p_doc_number);
        FETCH c_get_trans_pay_boleto INTO c_pay_trans;
        CLOSE c_get_trans_pay_boleto;

        OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
        FETCH c_get_data_i INTO p_user_create;
        CLOSE c_get_data_i;

       IF c_pay_trans is not null then 
       p_exist_trans := p_exist_trans ||','||c_pay_trans;
       END IF;

        p_valida_acum := f_get_acum_str (p_pidm || p_trans_num);

        p_valida_exist := f_get_acum_str (p_pidm || p_exist_trans);

        IF p_valida_acum = p_valida_exist
        THEN
            RETURN p_doc_number;
         ELSE
            RETURN NULL;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;


-- Obtiene el valor de un SDE, Dato suplementario.
--
        FUNCTION f_get_sde_val (p_table        VARCHAR2,
                            p_att_name     VARCHAR2,
                            p_parenttab    VARCHAR2,
                            p_type varchar2 default null)
        RETURN VARCHAR2
    IS
        p_valor   VARCHAR2 (100);

        CURSOR cGetData
        IS
            SELECT getData (GORSDAV_VALUE) Valor
              FROM GORSDAV
             WHERE     GORSDAV_TABLE_NAME = p_table          
                   AND GORSDAV_ATTR_NAME = p_att_name        
                   AND GORSDAV_PK_PARENTTAB = p_parenttab;

          CURSOR cGetDataP
        IS
            SELECT gorsdav_pk_parenttab
              FROM GORSDAV
             WHERE     GORSDAV_TABLE_NAME = p_table           
                   AND GORSDAV_ATTR_NAME = p_att_name         
                   AND getdata (gorsdav_value) = p_parenttab;

    BEGIN
        IF p_type = 'P' then
            OPEN cGetDataP;
            FETCH cGetDataP INTO p_valor;
            CLOSE cGetDataP;

        ELSE

            OPEN cGetData;
            FETCH cGetData INTO p_valor;
            CLOSE cGetData;
        END IF;

        RETURN p_valor;
    END;

-- Procedimiento que visualiza la página de selección de proveedores en Autoservicos de Banner
-- dentro de su funcionalidad ejecuta el proceso SB_CALCULO_CERRAR_FACTURA
-- 
 PROCEDURE p_select_provider_alt (p_term_code       VARCHAR2 default null,
                                 p_sdoc_code       VARCHAR2 default null,
                                 p_transactions    VARCHAR2 default null)
    IS

        CURSOR c_get_pdf_img (img_name twgbimag.twgbimag_name%TYPE)
        IS
            SELECT twgbimag_image_url, TWGBIMAG_STATUS_BAR, TWGBIMAG_DESC
              FROM twgbimag
             WHERE TWGBIMAG_ALT= img_name;

        lv_pdf_image   twgbimag.twgbimag_image_url%TYPE := '';
        lv_href_img TWGBIMAG.TWGBIMAG_STATUS_BAR%TYPE := '';
        lv_title_img TWGBIMAG.TWGBIMAG_DESC%TYPE := '';
        lv_franc_img    twgbimag.twgbimag_image_url%TYPE := '';
        lv_master_img  twgbimag.twgbimag_image_url%TYPE := '';
        lv_xml_image   twgbimag.twgbimag_image_url%TYPE := '';



        CURSOR c_get_providers (
            p_sede    VARCHAR2)
        IS
            SELECT spriden_last_name proveedor,
                   stvcamp_desc      sede,
                   tzvoprd_endpoint  endpoint,
                   tzvoprd_trankey   trankey,
                   tzvoprd_login     login,
                   tzvoprd_pidm,
                   TZVOPRD_SERV servicio,
                   TZVOPRD_IDENTIFY_WS iden_ws
              FROM spriden, tzvoprd, stvcamp
             WHERE     spriden_pidm = tzvoprd_pidm
                   AND stvcamp_code = tzvoprd_camp_code
                   AND tzvoprd_camp_code = NVL (p_sede, tzvoprd_camp_code)
                   AND spriden_change_ind IS NULL
                   AND spriden_entity_ind = 'C'
                   AND TRUNC (SYSDATE) BETWEEN trunc(tzvoprd_start_date)
                                           AND trunc(tzvoprd_end_date);


        p_status             TZRPAYU.TZRPAYU_STATUS%type;
        p_REQUEST_ID   TZRPAYU.TZRPAYU_REQUEST_ID%type;
        p_reference       TZRPAYU.TZRPAYU_REFERENCE%type;
        p_message         TZRPAYU.TZRPAYU_MESSAGE%type;



      cursor c_valida ( p_pidm number, p_pidm_oprd number, p_sdoc_code varchar2, p_campus varchar2, p_term varchar2, p_doc_number varchar2, p_servicio in varchar2 ) is  
       select TZRPAYU_STATUS, TZRPAYU_REQUEST_ID, TZRPAYU_REFERENCE, TZRPAYU_MESSAGE
            from tzrpayu 
            where  TZRPAYU_PIDM = p_pidm
              and TZRPAYU_PIDM_OPRD = p_pidm_oprd
              and TZRPAYU_SDOC_CODE = p_sdoc_code
              and TZRPAYU_CAMPUS = p_campus
              and TZRPAYU_TERM = p_term
              and TZRPAYU_DOC_NUMBER = p_doc_number
              and TZRPAYU_servicio = p_servicio
              and TZRPAYU_PROCESSED_IND is null;


        p_estatus      sgbstdn.sgbstdn_stst_code%TYPE;
        p_area         sgbstdn.sgbstdn_program_1%TYPE;
        p_doc_number   tvrsdoc.tvrsdoc_doc_number%TYPE;



p_sdoc_code_tzvaccd varchar2(10);

cursor c_get_sdoc_code_tzvaccd (p_pidm number,  p_trans varchar2 ) is 
  SELECT TZVACCD_SDOC_CODE
                FROM TZVACCD
               WHERE     TZVACCD_PIDM = p_pidm
                     AND TZVACCD_TYPE_IND = 'C'
                     AND TZVACCD_TRAN_NUMBER IN
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
                                             IS NOT NULL);


  cursor c_get_doc_number (p_pidm number,  p_trans varchar2 ) is 
SELECT tvrsdoc_doc_number
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm 
                     AND tvrsdoc_doc_cancel_ind IS NULL
                     AND tvrsdoc_chg_tran_number IN
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
            GROUP BY tvrsdoc_doc_number;

p_doc_num_existente varchar2(30);


    BEGIN


        IF NOT twbkwbis.f_validuser (global_pidm)
        THEN
            HTP.p ('you have returnded ');
            RETURN;
        END IF;

        bwckfrmt.p_open_doc ('tzkpufc.p_select_provider_alt');
        twbkfrmt.p_paragraph (1);
        twbkwbis.p_dispinfo ('tzkpufc.p_select_provider_alt', 'DEFAULT');


    IF p_transactions is null then 
        OPEN c_get_data_i ('PUCE_FACT', 'URL_RETURN', 'COM');
        FETCH c_get_data_i INTO p_url;
        CLOSE c_get_data_i;
        HTP.script (   'window.location.href = "' || p_url || '";',  'Javascript');
     END IF;


        htp.p('
                <script>
            function myFunction( p_oprd_pidm,  p_pidm, p_sede, p_sdoc_pref, p_doc_num, p_term, p_servicio, p_iden_ws ) {
              var r = confirm("Acepta los términos y condiciónes");
              if (r == true) {
                //form.submit();
                var url = ''tzkpufc.ws_p2p?p_pidm_oprd='' + p_oprd_pidm
                   + ''&p_pidm=''         + p_pidm
                   + ''&p_sede=''         + p_sede
                   + ''&p_sdoc_code=''         + p_sdoc_pref
                   + ''&p_doc_number=''         + p_doc_num
                   + ''&p_term=''         + p_term
                   + ''&p_servicio=''         + p_servicio
                   + ''&p_iden_ws=''         + p_iden_ws
                   + '' '';

                   //var myWindow = window.open(url, ''MsgWindow'', ''height=768,width=1024,resizable=yes,scrollbars=yes,toolbar=yes,menubar=yes,location=yes'');
                   var myWindow = window.open(url, ''_self'');

              } else {
                txt = "You pressed Cancel!";
              }
            }
            </script>    
                ');


p_sede        := f_get_sovlcur(global_pidm,p_term_code, 'CAMPUS' );
p_levl          := f_get_sovlcur(global_pidm,p_term_code, 'LEVL' );
p_program   := f_get_sovlcur(global_pidm,p_term_code, 'PROGRAM' );



        OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
        FETCH c_get_data_i INTO p_user_create;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;

        OPEN c_get_moneda;
        FETCH c_get_moneda INTO v_moneda;
        CLOSE c_get_moneda;


        BEGIN
        open c_get_doc_number (global_pidm,  p_transactions);
        fetch c_get_doc_number into p_doc_num_existente;
        close c_get_doc_number;

       p_sdoc_code_tzvaccd := '';
       open c_get_sdoc_code_tzvaccd (global_pidm,  p_transactions);
       fetch c_get_sdoc_code_tzvaccd into p_sdoc_code_tzvaccd;
       close c_get_sdoc_code_tzvaccd;


       IF p_doc_num_existente is null then

            BEGIN

             p_gen_document_ssb(global_pidm, p_term_code, nvl(p_sdoc_code_tzvaccd,p_sdoc_pref), p_doc_num);

                   BEGIN
          SB_CALCULO_CERRAR_FACTURA.P_CERRAR_PERIODO_FACTURA(
            P_STUDENT_PIDM => global_pidm,
            P_PERIODOPREFACTURA => p_term_code,
            SQLERRORMSG => p_error_msg
          );

         p_ins_tzrrlog(global_pidm,  'PAGO_ONLINE', 'CERRAR_FACTURA', p_term_code||' ERR: '||p_error_msg, user);

          exception when others then null;

        END;



            EXCEPTION WHEN OTHERS THEN 
            HTP.P(p_error_ind||' '||p_error_msg);

            END;


      ELSE 
      p_doc_num := p_doc_num_existente;

      END IF; 


        EXCEPTION
            WHEN OTHERS
            THEN
                twbkfrmt.p_tableopen ('DATADISPLAY', 
                 ccaption => '');
                twbkfrmt.p_tablerowopen ();
                twbkfrmt.p_printmessage (
                    'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500),
                    'WARNING');
                twbkfrmt.p_tableclose ();
                RETURN;
        END;


        twbkfrmt.p_tableopen ('DATADISPLAY',
                              ccaption   => 'Selección de Proveedor');


        twbkfrmt.p_tabledataheader ('Proveedor');
        twbkfrmt.p_tabledataheader ('Sede');
        twbkfrmt.p_tabledataheader ('Tipo de Servicio');
        twbkfrmt.p_tabledataheader ('Prefactura');
        twbkfrmt.p_tabledataheader ('Ver');
        twbkfrmt.p_tabledataheader ('Ir');


        FOR rec_provider IN c_get_providers (p_sede)
        LOOP
            IF c_get_providers%FOUND
            THEN

                   p_status := ''; 
                   p_REQUEST_ID:= ''; 
                   p_reference:= ''; 
                   p_message:= '';

                    OPEN c_valida ( global_pidm, rec_provider.tzvoprd_pidm ,p_sdoc_pref, p_sede, p_term_code,p_doc_num, rec_provider.servicio );
                    FETCH c_valida INTO p_status, p_REQUEST_ID, p_reference, p_message;
                    CLOSE c_valida;

                    lv_pdf_image:= '';
                    lv_href_img:= ''; 
                    lv_title_img:= '';

                    OPEN c_get_pdf_img (gb_common.f_get_id(rec_provider.tzvoprd_pidm));
                    FETCH c_get_pdf_img into lv_pdf_image, lv_href_img, lv_title_img;
                    CLOSE c_get_pdf_img;


                twbkfrmt.p_tablerowopen ();
                twbkfrmt.p_tabledata ('<a href=" '||lv_href_img||'" ><img src=" '||lv_pdf_image||' " title="'||lv_title_img||'" width="70" height="20" />  </a>');
                twbkfrmt.p_tabledata (rec_provider.sede);
                twbkfrmt.p_tabledata (rec_provider.servicio);
                twbkfrmt.p_tabledata (f_get_docnum_fmt (p_doc_num));


                twbkfrmt.p_tabledata (
                       '<a href="'
                    || 'tzkpufc.p_show_pdf?p_pidm='
                    || global_pidm
                    || '&p_doc_number='
                    || p_doc_num
                    || ' '
                    || '" target="_blank" style="text-decoration: none;"> PDF
                                                           </a>');

                open c_get_sdoc_code_val (global_pidm,p_doc_num,p_sede,p_term_code) ;
                fetch c_get_sdoc_code_val into p_sdoc_code_val;
                close c_get_sdoc_code_val;

                --open c_get_doc_fecha_valida (global_pidm,p_doc_num) ;
                open c_get_doc_fecha_valida (p_doc_num);
                fetch c_get_doc_fecha_valida into p_fecha_vigencia_valida;
                close c_get_doc_fecha_valida;

                --ACASTILLO control temporal para proceso de borrado
                open c_dat_prefac (p_doc_num) ;
                fetch c_dat_prefac into p_term_pref,p_camp_pref;
                close c_dat_prefac;

                v_get_borrado := 'N';
                v_get_desc_borr := '';
                open c_get_borrado (p_term_pref, p_camp_pref);
                fetch c_get_borrado into v_get_borrado, v_get_desc_borr;
                close c_get_borrado;
                IF nvl(p_fecha_vigencia_valida,'N') = 'N' THEN
                    p_status := 'VENCIDO';
                END IF;

                IF v_get_borrado = 'Y' THEN
                    p_status := 'SUSPENDED';
                END IF;
                --
                IF p_status is null or p_status = 'REJECTED' or p_status = 'FAILED' then                
                    HTP.p ( '<th> <button type = "button" onclick="myFunction('''||rec_provider.tzvoprd_pidm||''','''||global_pidm||''','''||p_sede||''','''||p_sdoc_pref||''','''||p_doc_num||''','''||p_term_code||''','''||rec_provider.servicio||''','''||rec_provider.iden_ws||''')">Pagar</button> </th>');
                    ELSIF p_status = 'PENDING' then
                    twbkfrmt.p_tabledata('Referencia:' || p_reference ||'. '||p_message);
                    ELSIF p_status = 'APPROVED' then
                    twbkfrmt.p_tabledata('Referencia:' || p_reference ||'. '||p_message);
                    ELSIF p_status = 'VENCIDO' then
                    twbkfrmt.p_tabledata(' Prefactura Vencida');
                    ELSIF p_status = 'SUSPENDED' then
                    twbkfrmt.p_tabledata(v_get_desc_borr);
                    ELSIF p_status = 'KUSHKI' then
                    twbkfrmt.p_tabledata('Opción disponible en 10 minutos');
                    ELSE 
                    twbkfrmt.p_tabledata('Referencia:' || p_reference ||' Estatus:'||p_status||'. '||p_message);
                   END IF;

                twbkfrmt.p_tablerowclose;
            ELSE
                IF c_get_providers%ROWCOUNT = 0
                THEN
                    twbkfrmt.p_printmessage (
                        'No se han encontrado proveedores configurados',
                        'WARNING');
                END IF;

                EXIT;
            END IF;
        END LOOP;

        HTP.p (p_error_msg);

        twbkfrmt.p_tableclose ();
        HTP.br;
        HTP.br;


        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/detalles-ptp-discover.php"  target="_blank"> Información Place to Pay Discover </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/detalles-ptp.php"  target="_blank"> Información Place to Pay </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/detalles-kushki.php"  target="_blank"> Información Kushki </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/preguntas-frecuentes-ptp.php"  target="_blank"> Preguntas Frecuentes </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/terminos-y-condiciones.php"  target="_blank"> Términos y Condiciones </a>'); 

        HTP.br;
        HTP.br;


        OPEN c_get_pdf_img ('franc');
                    FETCH c_get_pdf_img into lv_franc_img, lv_href_img, lv_title_img;
                    CLOSE c_get_pdf_img;

         OPEN c_get_pdf_img ('master');
                    FETCH c_get_pdf_img into lv_master_img, lv_href_img, lv_title_img;
                    CLOSE c_get_pdf_img;           

        htp.p('<a ><img src=" '||lv_franc_img||' " title="Franquicias" width="420" height="40" />  </a>');
        htp.p('<a ><img src=" '||lv_master_img||' " title="Franquicias" width="65" height="35" />  </a>');

        twbkwbis.p_closedoc ();
    END;


-- Proceso principal de generacion de documentos de venta.
-- Consume los procedimientos de obtencion de numero de documento existente, consulta el folio siguiente disponible, actualización de folios,
-- inserta el encabezado del documento de venta p_insert_tvbsdoc y el detalle p_insert_tvrsdoc así como la inserción en la tabla principal de
-- facturación TZRFACT p_insert_tzrfact 
--
    PROCEDURE p_gen_sales_doc (p_pidm            IN     NUMBER,
                               p_campus          IN     VARCHAR2,
                               p_term_code       IN     VARCHAR2,
                               p_sdoc_code       IN     VARCHAR2,
                               p_curr_code       IN     VARCHAR2,
                               p_data_origin     IN     VARCHAR2,
                               p_user_id         IN     VARCHAR2,
                               p_trans_numbers   IN     VARCHAR2,
                               p_doc_num            OUT VARCHAR2,
                               p_error_ind          OUT VARCHAR2,
                               p_error_msg          OUT VARCHAR2)
    IS
        p_doc_number      tvrsdoc.tvrsdoc_doc_number%TYPE;
        v_prefix_1        tvrsdsq.tvrsdsq_prefix_1%TYPE;
        v_prefix_2        tvrsdsq.tvrsdsq_prefix_2%TYPE;
        v_campus          tvrsdsq.tvrsdsq_camp_code%TYPE;
        v_district        stvcamp.stvcamp_dicd_code%TYPE;
        v_doc_num         tvrsdsq.tvrsdsq_max_seq%TYPE;
        v_seq             tvrsdsq.tvrsdsq_seq_num%TYPE;
        v_error           VARCHAR2 (1000);
        lv_print_pidm     tvbsdoc.tvbsdoc_print_pidm%TYPE;
        lv_print_id       tvbsdoc.tvbsdoc_print_id%TYPE;
        lv_print_source   tvbsdoc.tvbsdoc_print_id_source%TYPE;
        lv_id             spriden.spriden_id%TYPE;
        v_atyp_code       tvvsdoc.tvvsdoc_atyp_code%TYPE;
        v_rowid           gb_common.internal_record_id_type;
        p_cedula          VARCHAR2 (100);
        p_emal_code       VARCHAR2 (100);
        p_correo          VARCHAR2 (200);

        v_status          VARCHAR2 (10);
        v_comments        VARCHAR2 (20000);
        p_sdoc_pref       VARCHAR2 (100);
        lv_out_error      VARCHAR2 (1000);


        CURSOR c_get_trans_appl
        IS
        SELECT 0 tran_pay_num, tbraccd_tran_number tran_chg_num
              FROM tbraccd, tbbdetc
             WHERE     tbraccd_pidm = p_pidm
                   AND tbbdetc_detail_code = tbraccd_detail_code
                   and tbbdetc_type_ind = 'C'
                   AND tbraccd_tran_number IN
                           (    SELECT REGEXP_SUBSTR (
                                           REPLACE ((p_trans_numbers), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (
                                           REPLACE ((p_trans_numbers), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                           IS NOT NULL)
               and tbraccd_balance > 0 
        UNION
        SELECT TBRAPPL_PAY_TRAN_NUMBER tran_pay_num, TBRAPPL_CHG_TRAN_NUMBER tran_chg_num
                      FROM tbraccd, tbbdetc, tbrappl
                     WHERE     tbraccd_pidm = p_pidm
                           AND tbbdetc_detail_code = tbraccd_detail_code               
                           and tbrappl_pidm = tbraccd_pidm
                           and TBRAPPL_PAY_TRAN_NUMBER = tbraccd_tran_number
                           and TBRAPPL_REAPPL_IND is null
                           AND tbraccd_tran_number IN
                                   (    SELECT REGEXP_SUBSTR (
                                                   REPLACE ((p_trans_numbers), ' '),
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                          FROM DUAL
                                    CONNECT BY REGEXP_SUBSTR (
                                                   REPLACE ((p_trans_numbers), ' '),
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                                   IS NOT NULL);

p_sdoc_code_tzvaccd varchar2(10);
p_tzvaccd_crn number;

cursor c_get_sdoc_code_tzvaccd (p_pidm number,  p_trans varchar2 ) is 
  SELECT TZVACCD_SDOC_CODE, TZVACCD_CRN
                FROM TZVACCD
               WHERE     TZVACCD_PIDM = p_pidm
                     AND TZVACCD_TYPE_IND = 'C'
                     AND TZVACCD_TRAN_NUMBER IN
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
                                             IS NOT NULL);


    BEGIN

        p_doc_number :=
            f_get_doc_number (p_pidm, p_trans_numbers, p_sdoc_code);

        IF p_doc_number IS NULL
        THEN

            v_prefix_1 := SUBSTR (p_term_code, 1, 4);
            v_prefix_2 := SUBSTR (p_term_code, 5, 4);

            tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_code, 
                                      p_user            => p_user_id, 
                                      p_camp_code       => p_campus,
                                      p_prefix1         => v_prefix_1, 
                                      p_prefix2         => v_prefix_2, 
                                      p_next_numdoc     => v_doc_num, 
                                      p_seq             => v_seq,    
                                      p_errormsg        => v_error,
                                      p_camp_district   => v_district); 


            IF v_error IS NOT NULL
            THEN
                p_error_msg := g$_nls.get ('X', 'SQL', v_error);                
                GOTO end_process;
            ELSE 

                p_update_secuencia (p_sdoc_code,
                                    p_user_id,
                                    v_prefix_1,
                                    v_prefix_2,
                                    p_campus,
                                    v_doc_num,
                                    p_error_msg);


                IF p_error_msg IS NOT NULL
                THEN
                    p_error_msg :=
                        g$_nls.get (
                            'X',
                            'SQL',
                            'Ha ocurrido un error. Favor de contactar a su unidad académica');

                    GOTO end_process;
                END IF;

            END IF;

            p_doc_num := v_prefix_1 || v_prefix_2 || v_district || v_doc_num;

            OPEN get_ssn_c (p_pidm);

            FETCH get_ssn_c INTO lv_inf;

            CLOSE get_ssn_c;


            lv_id := gb_common.f_get_id (p_pidm);

            tvkrlib.p_get_printed_id (p_sdoc_code,
                                      lv_id,
                                      lv_print_pidm,
                                      lv_print_id,
                                      lv_print_source);

            IF     lv_inf IS NOT NULL
               AND v_prefix_1 IS NOT NULL
               AND v_prefix_2 IS NOT NULL
               AND v_district IS NOT NULL
               AND v_doc_num IS NOT NULL
            THEN

                p_insert_tvbsdoc (p_sdoc_code =>p_sdoc_code,
                                     p_doc_number =>p_doc_num,
                                     p_pidm =>p_pidm,
                                     p_prefix_1 =>v_prefix_1,
                                     p_prefix_2 =>v_prefix_2,
                                     p_int_doc_number =>v_doc_num,
                                     p_comments =>NULL,
                                     p_user_id =>p_user_id,
                                     p_data_origin =>p_data_origin,
                                     p_date =>SYSDATE,
                                     p_print_pidm =>p_pidm,
                                     p_print_id =>lv_inf,
                                     p_print_id_source =>'SPBPERS_SSN',
                                     p_atyp_code => v_atyp_code,
                                     p_msg_out =>p_error_msg);


                IF p_error_msg is not null then
                    p_error_msg := p_error_msg || p_error_msg;
                    GOTO end_process;
                ELSE
                    p_error_msg := NULL;
                END IF;

                FOR rect IN c_get_trans_appl
                LOOP
                    p_insert_tvrsdoc (p_pidm => p_pidm,
                                         p_pay_tran_number =>rect.tran_pay_num,
                                         p_chg_tran_number => rect.tran_chg_num,
                                         p_doc_number => p_doc_num,
                                         p_doc_type => SUBSTR (p_sdoc_code, 1, 2),
                                         p_int_doc_number => v_doc_num,
                                         p_user_id => p_user_id,
                                         p_data_origin => p_data_origin,
                                         p_comments =>NULL,
                                         p_sdoc_code => p_sdoc_code,
                                         p_msg_out =>p_error_msg);

                END LOOP;

                IF p_error_msg is not null then
                    p_error_msg := p_error_msg || p_error_msg;
                    GOTO end_process;
                ELSE
                    p_error_msg := NULL;
                END IF;


       p_sdoc_code_tzvaccd := '';
       open c_get_sdoc_code_tzvaccd (p_pidm,  p_trans_numbers);
       fetch c_get_sdoc_code_tzvaccd into p_sdoc_code_tzvaccd, p_tzvaccd_crn;
       close c_get_sdoc_code_tzvaccd;

                BEGIN
                    p_insert_tzrfact (p_pidm          => p_pidm,
                                      p_sdoc_code     => nvl(p_sdoc_code_tzvaccd,p_sdoc_code),
                                      p_doc_number    => p_doc_num,
                                      p_crn => p_tzvaccd_crn,
                                      p_out_message   => lv_out_error);

                    p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA', 'INS_TZRFACT', nvl(p_sdoc_code_tzvaccd,p_sdoc_code) || ' p_doc_num: '||p_doc_num || ' p_tzvaccd_crn: '||p_tzvaccd_crn ||' lv_out_error: '||lv_out_error, user);

                EXCEPTION
                    WHEN OTHERS
                    THEN


                        lv_out_error :=
                            SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

                     p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA', 'INS_ERR', lv_out_error, user);

                        p_error_ind := 'Y';
                        p_error_msg :=
                               'Error: '
                            || SQLCODE
                            || '--'
                            || SUBSTR (SQLERRM, 1, 500);
                        GOTO end_process;
                END;
            ELSE
                p_error_msg :=
                    g$_nls.get (
                        'X',
                        'SQL',
                           'Warning NSS is null. Please go to SPAIDEN form'
                        || 'p_pidm:'
                        || p_pidm
                        || ' lv_inf:'
                        || lv_inf
                        || ' v_prefix_1:'
                        || v_prefix_1
                        || ' v_prefix_2:'
                        || v_prefix_2
                        || ' v_district:'
                        || v_district
                        || ' v_doc_num:'
                        || v_doc_num);

            END IF;
        ELSE
            p_error_ind := '5';
            p_error_msg :=
                   'Transacciones de Cargo ya existen dentro del documento: '
                || p_doc_number;
        END IF;

       <<end_process>>
        p_error_msg := p_error_msg;

        p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA', 'P_GEN_SALES_DOC', p_campus||' - '||p_term_code||' - '||p_sdoc_code||' - '||p_trans_numbers||' - '||p_error_msg, user);

    EXCEPTION
        WHEN OTHERS
        THEN
            p_error_ind := 'Y';
            p_error_msg :=
                'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

                p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA', 'P_GEN_SALES_DOC_ERR', p_error_ind||' - '||p_error_msg, user);

    END;

    PROCEDURE p_roll_terms (p_one_up_no IN NUMBER)
    IS
        TYPE gjbprun_rec IS RECORD
        (
            r_gjbprun_number    gjbprun.gjbprun_number%TYPE,
            r_gjbprun_value     gjbprun.gjbprun_value%TYPE,
            r_gjbprun_desc      gjbpdef.gjbpdef_desc%TYPE
        );


        TYPE gjbprun_ref IS REF CURSOR RETURN gjbprun_rec;

        ln_count              NUMBER;
        v_job_num             NUMBER := p_one_up_no;
        v_user_id             VARCHAR2 (50) := USER;
        v_user_id_log         VARCHAR2 (50) := USER;
        v_job_ref             gjbprun_ref;
        v_job_rec             gjbprun_rec;
        v_env_nm_before       NUMBER;
        v_env_nm_after        NUMBER;
        v_line_cntr           NUMBER := 0;
        v_page_cntr           NUMBER := 0;
        v_file_number         guboutp.guboutp_file_number%TYPE;
        v_page_width          NUMBER;
        v_page_break          NUMBER;
        v_row_print           VARCHAR2 (1000);
        v_status              VARCHAR2 (10);
        v_comments            VARCHAR2 (20000);

        lv_out_error          VARCHAR2 (1000);

        v_term_code_origin    stvterm.stvterm_code%TYPE;
        v_term_code_destiny   stvterm.stvterm_code%TYPE;

        CURSOR c_tvrsdsq (
            p_term_code_origin   IN VARCHAR2,
            p_term_code_target   IN VARCHAR2)
        IS
              SELECT tvrsdsq_sdoc_code,
                     tvrsdsq_fbpr_code,
                     tvrsdsq_seq_num,
                     tvrsdsq_camp_code,
                     SUBSTR (p_term_code_target, 1, 4) tvrsdsq_prefix_1,
                     SUBSTR (p_term_code_target, 5, 2) tvrsdsq_prefix_2,
                     tvrsdsq_max_seq,
                     1                               tvrsdsq_init_seq,
                     tvrsdsq_final_seq,
                     '31/12/2099'                    tvrsdsq_valid_until,
                     tvrsdsq_reference,
                     SYSDATE                         tvrsdsq_activity_date,
                     USER                            tvrsdsq_user_id,
                     'TZPRTRM'                       tvrsdsq_data_origin
                FROM tvrsdsq
               WHERE     tvrsdsq_prefix_1 = SUBSTR (p_term_code_origin, 1, 4)
                     AND tvrsdsq_prefix_2 = SUBSTR (p_term_code_origin, 5, 2)
            ORDER BY tvrsdsq_sdoc_code, tvrsdsq_prefix_1, tvrsdsq_prefix_2;
    BEGIN
        p_create_header (p_one_up_no,
                         USER,
                         v_file_number,
                         'TZPRTRM');

        v_page_width :=
            gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');


        v_page_break :=
            gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');


        OPEN v_job_ref FOR
              SELECT gjbprun_number, gjbprun_value, gjbpdef_desc
                FROM gjbprun, gjbpdef
               WHERE     gjbprun_one_up_no = p_one_up_no
                     AND gjbprun_job = 'TZPRTRM'
                     AND gjbpdef_job = gjbprun_job
                     AND gjbpdef_number = gjbprun_number
            ORDER BY gjbprun_number ASC;


        LOOP
            FETCH v_job_ref INTO v_job_rec;

            EXIT WHEN v_job_ref%NOTFOUND; 



            gz_report.p_put_line (
                p_one_up_no =>
                    p_one_up_no,
                p_user =>
                    v_user_id_log,
                p_job_name =>
                    'TZPRTRM',
                p_file_number =>
                    NVL (v_file_number, 1),
                p_content_line =>
                       v_job_rec.r_gjbprun_number
                    || ' - '
                    || v_job_rec.r_gjbprun_desc
                    || ' - '
                    || v_job_rec.r_gjbprun_value
                    || '.',
                p_content_width =>
                    v_page_width,
                p_content_align =>
                    'LEFT',                           
                p_status =>
                    v_status,
                p_comments =>
                    v_comments);


            CASE v_job_rec.r_gjbprun_number
                WHEN '01'
                THEN
                    v_term_code_origin := v_job_rec.r_gjbprun_value;
                WHEN '02'
                THEN
                    v_term_code_destiny := v_job_rec.r_gjbprun_value;
                ELSE
                    NULL;
            END CASE;
        END LOOP;


        ln_count := 0;

        SELECT COUNT (1)
          INTO ln_count
          FROM tvrsdsq
         WHERE     tvrsdsq_prefix_1 = SUBSTR (v_term_code_destiny, 1, 4)
               AND tvrsdsq_prefix_2 = SUBSTR (v_term_code_destiny, 5, 2);

        IF (ln_count > 0)
        THEN
            gz_report.p_put_line (
                p_one_up_no =>
                    p_one_up_no,
                p_user =>
                    v_user_id_log,
                p_job_name =>
                    'TZPRTRM',
                p_file_number =>
                    NVL (v_file_number, 1),
                p_content_line =>
                    'TZPRTRM - Ya existen registros en el periodo destino.',
                p_content_width =>
                    v_page_width,
                p_content_align =>
                    'LEFT',                    
                p_status =>
                    v_status,
                p_comments =>
                    v_comments);
            RETURN;
        END IF;


        v_row_print :=
               gz_report.f_colum_format ('Periodo ',
                                         8,
                                         'CENTER',
                                         ' | ')
            || gz_report.f_colum_format ('Tipo de Documento',
                                         17,
                                         'CENTER',
                                         ' | ')
            || gz_report.f_colum_format ('Campus',
                                         6,
                                         'CENTER',
                                         ' | ')
            || gz_report.f_colum_format ('Secuencia',
                                         9,
                                         'CENTER',
                                         ' | ');

        gz_report.p_put_line (
            p_one_up_no       => p_one_up_no,
            p_user            => v_user_id_log,
            p_job_name        => 'TZPRTRM',
            p_file_number     => NVL (v_file_number, 1),
            p_content_line    => LPAD (' ', v_page_width, '-'),
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',
            p_status          => v_status,
            p_comments        => v_comments);

        gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                              p_user            => v_user_id_log,
                              p_job_name        => 'TZPRTRM',
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => v_row_print,
                              p_content_width   => v_page_width,
                              p_content_align   => 'LEFT',
                              p_status          => v_status,
                              p_comments        => v_comments);


        ln_count := 0;

        FOR x IN c_tvrsdsq (v_term_code_origin, v_term_code_destiny)
        LOOP
            BEGIN
                INSERT INTO tvrsdsq (tvrsdsq_sdoc_code,
                                     tvrsdsq_fbpr_code,
                                     tvrsdsq_seq_num,
                                     tvrsdsq_camp_code,
                                     tvrsdsq_prefix_1,
                                     tvrsdsq_prefix_2,
                                     tvrsdsq_max_seq,
                                     tvrsdsq_init_seq,
                                     tvrsdsq_final_seq,
                                     tvrsdsq_valid_until,
                                     tvrsdsq_reference,
                                     tvrsdsq_activity_date,
                                     tvrsdsq_user_id,
                                     tvrsdsq_data_origin)
                     VALUES (x.tvrsdsq_sdoc_code,
                             x.tvrsdsq_fbpr_code,
                             x.tvrsdsq_seq_num,
                             x.tvrsdsq_camp_code,
                             x.tvrsdsq_prefix_1,
                             x.tvrsdsq_prefix_2,
                             x.tvrsdsq_max_seq,
                             x.tvrsdsq_init_seq,
                             x.tvrsdsq_final_seq,
                             TO_DATE ('12/31/2099', 'MM/DD/yyyy'),
                             x.tvrsdsq_reference,
                             x.tvrsdsq_activity_date,
                             x.tvrsdsq_user_id,
                             x.tvrsdsq_data_origin);

                v_row_print :=
                       gz_report.f_colum_format (
                           LPAD (v_term_code_origin, 8, ' '),
                           8,
                           'RIGHT',
                           '   ')
                    || gz_report.f_colum_format (
                           LPAD (x.tvrsdsq_sdoc_code, 17, ' '),
                           17,
                           'RIGHT',
                           '   ')
                    || gz_report.f_colum_format (x.tvrsdsq_camp_code,
                                                 6,
                                                 'CENTER',
                                                 '   ')
                    || gz_report.f_colum_format (x.tvrsdsq_init_seq,
                                                 9,
                                                 'CENTER',
                                                 '   ');

                gz_report.p_put_line (
                    p_one_up_no       => p_one_up_no,
                    p_user            => v_user_id,
                    p_job_name        => 'TZPRTRM',
                    p_file_number     => NVL (v_file_number, 1),
                    p_content_line    => v_row_print,
                    p_content_width   => v_page_width,
                    p_content_align   => 'LEFT',    
                    p_status          => v_status,
                    p_comments        => v_comments);


                ln_count := ln_count + 1;
            EXCEPTION
                WHEN OTHERS
                THEN
                    lv_out_error :=
                        SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);


            END;

            COMMIT;
        END LOOP;

        gz_report.p_put_line (
            p_one_up_no =>
                p_one_up_no,
            p_user =>
                v_user_id_log,
            p_job_name =>
                'TZPRTRM',
            p_file_number =>
                NVL (v_file_number, 1),
            p_content_line =>
                   'TZPRTRM - Se procesaron '
                || ln_count
                || ' registros. Proceso terminado',
            p_content_width =>
                v_page_width,
            p_content_align =>
                'LEFT',          
            p_status =>
                v_status,
            p_comments =>
                v_comments);
    EXCEPTION
        WHEN OTHERS
        THEN

            lv_out_error := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);



    END;

-- Procedimiento principal para generación de prefacturas.
-- Contiene procesos de validación y configuración y el llamado a procedimiento de insercion en documentos de bancos p_insert_tzrdprf 
-- (vista que se envía al banco)  y generación de documentos p_gen_sales_doc.
-- fecha de vencimiento de prefactura configurada en TZARVEN
--
    PROCEDURE p_gen_doc (p_pidm        IN     NUMBER,
                         p_trans       IN     VARCHAR2,
                         p_sdoc_code   IN     VARCHAR2,
                         p_site_code   IN     VARCHAR2,
                         p_term_code   IN     VARCHAR2,
                         p_curr_code   IN     VARCHAR2,
                         p_user_id     IN     VARCHAR2,
                         p_program     IN     VARCHAR2,
                         p_levl_code   IN     VARCHAR2,
                         p_doc_num        OUT VARCHAR2,
                         p_error_ind      OUT VARCHAR2,
                         p_error_msg      OUT VARCHAR2)
    IS
        p_doc_number   VARCHAR2 (30) := NULL;
        p_sdoc_pref    VARCHAR2 (100);
        v_crn           varchar2(100):= NULL;


     cursor c_get_doc_code ( p_doc_code varchar2, p_alt_doc_code varchar2 ) is
     select case when p_doc_code in (select distinct TVRSDSQ_SDOC_CODE from TVRSDSQ) then p_doc_code
                 else p_alt_doc_code
          end
    from dual;

	cursor c_get_disminucion_beca is
    SELECT
        'Y'
    FROM
        tbraccd, tbbdetc
    WHERE
        tbraccd_pidm = p_pidm
        and TBRACCD_TERM_CODE = p_term_code
        and tbraccd_detail_code = tbbdetc_detail_code
        and tbbdetc_type_ind = 'P'
        and tbbdetc_dcat_code in ('BEC','DES')
        and TBRACCD_AMOUNT < 0
        and TBRACCD_BALANCE > 0;

	v_disminucion_beca varchar2(1):='N';
    BEGIN

        OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;


        OPEN c_get_doc_code (p_sdoc_code, p_sdoc_pref);
        FETCH c_get_doc_code INTO p_sdoc_pref;
        CLOSE c_get_doc_code;

        p_doc_number := f_get_doc_number (p_pidm, p_trans, p_sdoc_pref 
                                                                      );
        IF p_doc_number IS NULL
        THEN


        open c_get_crn(p_pidm, p_trans);
       fetch c_get_crn into v_crn;
       close c_get_crn;


         p_fecha_vigencia_valida :=  TZKPUFC.f_get_valid_document(p_pidm, p_term_code, p_site_code, nvl(p_sdoc_code,p_sdoc_pref), v_crn);

        IF p_fecha_vigencia_valida = 'Y' then

            tzkpufc.p_gen_sales_doc (p_pidm            => p_pidm,
                                     p_campus          => p_site_code,
                                     p_term_code       => p_term_code,
                                     p_sdoc_code       => p_sdoc_pref, 
                                     p_curr_code       => p_curr_code, 
                                     p_data_origin     => 'TZKPUFC',
                                     p_user_id         => p_user_id, 
                                     p_trans_numbers   => p_trans,
                                     p_doc_num         => p_doc_num,
                                     p_error_ind       => p_error_ind,
                                     p_error_msg       => p_error_msg);

           p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_P', 'GEN_SALES_DOC', p_error_ind||p_error_msg, user);


            IF p_doc_num IS NOT NULL and p_error_msg is null
            THEN

                BEGIN
                p_insert_tzrdprf (
                    p_pidm,
                    p_sdoc_code, 
                    p_doc_num,
                    p_site_code,
                    p_term_code,
                    'CREADO',
                    NULL,
                    SYSDATE,                    
                    f_get_due_date (p_pidm,p_term_code, p_site_code, p_sdoc_code,v_crn  )  
                                         ,
                    f_get_docnum_fmt (p_doc_num),
                    f_get_balance (p_pidm, p_term_code, p_sdoc_code,p_doc_num),
                    f_get_iden (p_pidm, 'CEDULA', 'Y'),
                    f_get_iden (p_pidm),
                    f_get_balance (p_pidm, p_term_code, p_sdoc_code,p_doc_num),
                    USER,
                    'TZKPUFC');


                EXCEPTION WHEN OTHERS THEN
                   p_error_ind := 'Y';
                    p_error_msg := 'El ID '||gb_common.f_get_id(p_pidm)||' no cuenta con número de identificación';
                END;
            END IF;
            ---
            ELSE
            p_error_ind := 'Y';
            p_error_msg := 'Fecha vencida.';
          END IF; 

        ELSE
            p_doc_num := p_doc_number;
			----------------

		   open c_get_disminucion_beca;
		   fetch c_get_disminucion_beca into v_disminucion_beca;
		   close c_get_disminucion_beca;

           p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_P', 'p_gen_doc', 'v_disminucion_beca '||v_disminucion_beca, user);

			IF v_disminucion_beca = 'N' and f_doc_num_pagado_dprf(p_pidm, p_sdoc_pref, p_doc_number) = 'N' then
				BEGIN
                p_cancel_sales_doc (p_pidm,
                                    p_sdoc_pref,
                                    p_doc_number,
                                    'TZKPUFC',
                                    USER, 
                                    p_error_ind,
                                    p_error_msg);

                BEGIN
                    UPDATE tzrdprf
                       SET tzrdprf_doc_status = 'ANULADA',
                           tzrdprf_user_id = USER,
                           tzrdprf_activity_date = SYSDATE
                     WHERE     tzrdprf_pidm = p_pidm
                           AND tzrdprf_sdoc_code = p_sdoc_pref
                           AND tzrdprf_doc_number = p_doc_number;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
			p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_P', 'p_gen_doc beca', p_error_ind||p_error_msg, user);
			p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_P', 'p_gen_doc return no genera', p_error_ind||p_error_msg, user);

				return;
			end if;
			----------------        
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_error_ind := 'Y';
            p_error_msg := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
            p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_P', 'GEN_SALES_DOC_ERR', p_error_ind||p_error_msg, user);

    END;

-- Proceso de calculo de Becas (aumento y disminución) del Estudiante que será sembrado en el estado de cuenta previo a generacion de prefactura.
--
    PROCEDURE p_awards_courses (p_pidm IN NUMBER, p_term_code IN VARCHAR2, p_error_msg OUT varchar2)
    IS
        v_sqlerrormsg   VARCHAR2 (1000);
        v_sqlerrormsg_2   VARCHAR2 (1000);
        lv_out_stat   VARCHAR2 (500);


    cursor c_pago_x_aplicar  is
    select 'Y' from tbraccd, tbbdetc 
                                       where tbraccd_detail_code = tbbdetc_detail_code
                                           and TBRACCD_BALANCE <> 0
                                       and tbraccd_pidm = p_pidm;

    v_pago_x_aplicar varchar2(1);

cursor c_get_disminucion_beca is
    SELECT
        'Y'
    FROM
        tbraccd, tbbdetc
    WHERE
        tbraccd_pidm = p_pidm
        and TBRACCD_TERM_CODE = p_term_code
        and tbraccd_detail_code = tbbdetc_detail_code
        and tbbdetc_type_ind = 'P'
        and tbbdetc_dcat_code in ('BEC','DES')
        and TBRACCD_AMOUNT < 0
        and TBRACCD_BALANCE > 0;

v_disminucion_beca varchar2(1):='N';


cursor c_get_bec_dis (p_sdoc_code varchar2) is
select TBRAPPL_PIDM,  TBRAPPL_PAY_TRAN_NUMBER, TBRAPPL_CHG_TRAN_NUMBER, TBRAPPL_AMOUNT, rowid TBRAPPL_rowid
from tbrappl where tbrappl_pidm = p_pidm and TBRAPPL_REAPPL_IND is null
and  TBRAPPL_PAY_TRAN_NUMBER in (
select TBRACCD_TRAN_NUMBER 
from tbraccd, tbbdetc where tbraccd_pidm = p_pidm 
and TBRACCD_TERM_CODE = p_term_code
and tbraccd_detail_code =  tbbdetc_detail_code
and tbbdetc_type_ind = 'P'
and tbbdetc_dcat_code in ('BEC', 'DES')
and TBRACCD_TRAN_NUMBER in 
(select TVRSDOC_PAY_TRAN_NUMBER from tvrsdoc where tvrsdoc_pidm = tbraccd_pidm
    and substr(TVRSDOC_DOC_NUMBER,1,6)  = TBRACCD_TERM_CODE --
    and TVRSDOC_DOC_CANCEL_IND is null 
    and TVRSDOC_PAY_TRAN_NUMBER <> 0
    and tzkpufc.f_doc_num_pagado_dprf(tvrsdoc_pidm, p_sdoc_code, TVRSDOC_DOC_NUMBER) = 'N')
);

    BEGIN

        BEGIN

        kzkawrd.p_exec_population (p_pidm => p_pidm, p_term=>p_term_code,  ls_error_msg => v_sqlerrormsg_2);
        p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA', 'BECAS', p_term_code||' , '||v_sqlerrormsg_2, user);

        IF p_error_msg is null then
        p_error_msg := v_sqlerrormsg;
        ELSE
        p_error_msg := v_sqlerrormsg||v_sqlerrormsg_2;
        END IF;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;


   open c_get_disminucion_beca;
   fetch c_get_disminucion_beca into v_disminucion_beca;
   close c_get_disminucion_beca;

p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA', 'BECAS', 'v_disminucion_beca: '||v_disminucion_beca, user);

   IF v_disminucion_beca = 'Y' then
        OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;

        gb_common.p_set_context ('TB_RECEIVABLE',
                                  'PROCESS',
                                  'APPLPMNT',
                                  'N');

        FOR rec in c_get_bec_dis(p_sdoc_pref) LOOP
           tv_application.p_process_unapplication (
                p_pidm              => rec.tbrappl_pidm,
                p_pay_tran_number   => rec.tbrappl_pay_tran_number,
                p_chg_tran_number   => rec.tbrappl_chg_tran_number,
                p_amount            => rec.tbrappl_amount,
                p_appl_rowid        => rec.tbrappl_rowid);
        END LOOP;

  end if;

            OPEN c_pago_x_aplicar;
            FETCH c_pago_x_aplicar into v_pago_x_aplicar;
            CLOSE c_pago_x_aplicar;

            IF v_pago_x_aplicar = 'Y' then

            BEGIN 

            p_aplicatvrappl (p_id            => gb_common.f_get_id (p_pidm),
                             p_update_mode   => 'U',
                             output          => lv_out_stat);

                    SELECT SYSDATE 
                      INTO v_now
                      FROM DUAL;

                    LOOP
                      EXIT WHEN v_now + (IN_TIME * (1/86400)) <= SYSDATE;
                    END LOOP;

            EXCEPTION WHEN OTHERS THEN NULL;
            END;
            END IF; 

    END;

-- Genera prefacturas desde Admin Pages individual y Masivo.
-- Utiliza un proC y ejecuta con base a la información entregada por la vista TZVACCD.
    PROCEDURE p_gen_documents (p_one_up_no IN NUMBER)
    IS
        TYPE gjbprun_rec IS RECORD
        (
            r_gjbprun_number    gjbprun.gjbprun_number%TYPE,
            r_gjbprun_value     gjbprun.gjbprun_value%TYPE,
            r_gjbprun_desc      gjbpdef.gjbpdef_desc%TYPE
        );


        TYPE gjbprun_ref IS REF CURSOR RETURN gjbprun_rec;

        ln_count           NUMBER;
        v_job_num          NUMBER := p_one_up_no;
        v_user_id_log      VARCHAR2 (50) := USER;
        v_job_ref          gjbprun_ref;
        v_job_rec          gjbprun_rec;
        v_env_nm_before    NUMBER;
        v_env_nm_after     NUMBER;
        v_line_cntr        NUMBER := 0;
        v_page_cntr        NUMBER := 0;
        v_file_number      guboutp.guboutp_file_number%TYPE;
        v_page_width       NUMBER;
        v_page_break       NUMBER;
        v_row_print        VARCHAR2 (1000);
        v_status           VARCHAR2 (10);
        v_comments         VARCHAR2 (20000);
        p_error_msg_2    VARCHAR2 (1000);

        lv_out_error       VARCHAR2 (1000);

        v_term_code        stvterm.stvterm_code%TYPE;
        v_id               spriden.spriden_id%TYPE;
        v_pidm             spriden.spriden_pidm%TYPE;
        v_sdoc_code        tvvsdoc.tvvsdoc_code%TYPE;
        v_camp_code        stvcamp.stvcamp_code%TYPE;
        v_selection_id     VARCHAR2 (30) := NULL;
        v_application_id   VARCHAR2 (30) := NULL;
        v_creator_id       VARCHAR2 (30) := NULL;
        v_user_id          VARCHAR2 (30) := NULL;
        v_send_ind         VARCHAR2 (1) := 'N';

        v_site_code        VARCHAR2 (30) := NULL;
        v_levl             VARCHAR2 (30) := NULL;
        v_program          VARCHAR2 (30) := NULL;
        v_user_create      VARCHAR2 (30) := NULL;
        v_moneda           VARCHAR2 (30) := NULL;
        v_create_doc       VARCHAR2 (30) := NULL;
        v_doc_num          VARCHAR2 (30) := NULL;
        v_error_ind        VARCHAR2 (30) := NULL;
        v_err_msg          VARCHAR2 (300) := NULL;
        p_sdoc_pref        VARCHAR2 (100);

        lv_doc_amount      NUMBER (18, 2) := 0;
        v_sqlerrormsg   varchar2(500);


cursor c_has_bec  (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2) is
select distinct tvrsdoc_doc_number
          from TZVACCD , tvrsdoc
          where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code and TZVACCD_DCAT_CODE in ('BEC','DES') and TZVACCD_TYPE_IND = 'P'
            and tzvaccd_pidm = tvrsdoc_pidm
                             AND tzvaccd_tran_number = tvrsdoc_chg_tran_number
                             AND tvrsdoc_sdoc_code = TZVACCD_SDOC_CODE
                             AND tvrsdoc_doc_cancel_ind IS NULL;



cursor c_boleto_activo (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2,
            p_doc_number varchar2) is
   select sum(TZVACCD.TZVACCD_BALANCE) balance
          from TZVACCD , tvrsdoc
          where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code
           and tzvaccd_tran_number in (select tvrsdoc_chg_tran_number from tvrsdoc
                                                        where  tzvaccd_pidm = tvrsdoc_pidm
                                                         AND tvrsdoc_sdoc_code = TZVACCD_SDOC_CODE
                                                          and tvrsdoc_doc_number = p_doc_number
                                                         AND tvrsdoc_doc_cancel_ind IS NULL);

cursor c_get_bec  (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2) is
select TZVACCD.*
          from TZVACCD 
          where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code and TZVACCD_DCAT_CODE in ('BEC','DES') and TZVACCD_TYPE_IND = 'P'
          and  not exists ( select 'Y' from tvrsdoc where tvrsdoc_pidm = tzvaccd_pidm and tvrsdoc_chg_tran_number =   tzvaccd_tran_number and tvrsdoc_sdoc_code = TZVACCD_SDOC_CODE AND tvrsdoc_doc_cancel_ind = 'Y');

v_print_becas varchar2(1) := 'N'; 
v_doc_number varchar2(20) := 0;
v_print_becas_i varchar2(1) := 'N'; 
v_doc_number_i varchar2(20) := 0;
v_trans             VARCHAR2 (1000);
v_trx_dis           VARCHAR2 (1000);
v_all_trans       VARCHAR2 (1500);

cursor c_beca_aplicada (pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2)
        is
        select TZVACCD_AMOUNT amt, TZVACCD_BALANCE bal
          from TZVACCD where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code and TZVACCD_DCAT_CODE in ('BEC','DES') and TZVACCD_TYPE_IND = 'P' ;

        v_beca_no_aplicada varchar2(1):= 'N';


       CURSOR c_bec_trans (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2,
            p_trxs_chg varchar2)
        IS
                 SELECT 
                   REGEXP_REPLACE (
                       LISTAGG (TZVACCD_TRAN_NUMBER, ',')
                           WITHIN GROUP (ORDER BY TZVACCD_TRAN_NUMBER),
                       '([^,]+)(,\1)*(,|$)',
                       '\1\3')
                       AS trans_num
              FROM TZVACCD
             WHERE     TZVACCD_PIDM = pidm
                   AND TZVACCD_SDOC_CODE = p_sdoc_code
                   AND TZVACCD_TERM_CODE = p_term_code
                   AND TZVACCD_DCAT_CODE in ('BEC','DES')
                   and TZVACCD_TYPE_IND = 'P'
                   AND TZVACCD_BALANCE = 0                  
                    and tzvaccd_tran_number  
                        not in (select TZRFACT_TRAN_NUM from tzrfact where tzrfact_pidm = tzvaccd_pidm and tzrfact_term_code = TZVACCD_TERM_CODE and TZRFACT_SRI_DOCNUM is not null)
                    and tzvaccd_tran_number
                             in (select TBRAPPL_PAY_TRAN_NUMBER from tbrappl where tbrappl_pidm = tzvaccd_pidm  and TBRAPPL_REAPPL_IND is null 
                             and TBRAPPL_CHG_TRAN_NUMBER IN                              
                           (    SELECT REGEXP_SUBSTR (
                                           REPLACE ((p_trxs_chg), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (
                                           REPLACE ((p_trxs_chg), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                           IS NOT NULL)
                             ) ;   



        CURSOR c_get_transactions (
            p_term_code    IN VARCHAR2,
            p_camp_code    IN VARCHAR2,
            p_sdoc_code    IN VARCHAR2,
            p_pidm         IN NUMBER,
            p_appl_id      IN VARCHAR2,
            p_sel_id       IN VARCHAR2,
            p_creator_id   IN VARCHAR2,
            p_user_id      IN VARCHAR2)
        IS
        SELECT tzvaccd_pidm,
                     tzvaccd_sdoc_code,
                     tzvaccd_term_code,
                     SUM (tzvaccd_balance)
                         doc_amount,
                     REGEXP_REPLACE (
                         LISTAGG (tzvaccd_tran_number, ',')
                             WITHIN GROUP (ORDER BY tzvaccd_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         trans,
                         TZVACCD_CAMPUS
                         , null  as TZVACCD_CRN
                FROM tzvaccd
               WHERE     tzvaccd_term_code = p_term_code
                    AND 10 <> substr(p_term_code,5,2)
                    AND TZVACCD_CAMPUS =  p_camp_code
                    AND tzvaccd_pidm = nvl(p_pidm,tzvaccd_pidm)
                    AND tzvaccd_sdoc_code = nvl(p_sdoc_code,tzvaccd_sdoc_code)
                    AND tzvaccd_balance > 0
                    --
                    and  (CASE WHEN p_appl_id IS NOT NULL  AND p_pidm IS NULL AND EXISTS
                                      (SELECT 1
                                         FROM glbextr
                                        WHERE     glbextr_application =
                                                  p_appl_id
                                              AND glbextr_selection = p_sel_id
                                              AND glbextr_creator_id = p_creator_id
                                              AND glbextr_user_id = p_user_id
                                              AND tzvaccd_pidm = glbextr_key)
                                  THEN 1
                                    WHEN p_pidm IS NOT NULL AND tzvaccd_pidm = p_pidm
                                  THEN 1
                                    WHEN  p_appl_id IS NULL  AND p_pidm IS NULL AND tzvaccd_sdoc_code =  NVL (p_sdoc_code, tzvaccd_sdoc_code) and tzvaccd_sdoc_code <> '000'
                                  THEN 1
                                ELSE 0
                            END) = 1                       
GROUP BY tzvaccd_pidm, tzvaccd_sdoc_code, tzvaccd_term_code, TZVACCD_CAMPUS, null
UNION
SELECT tzvaccd_pidm,
                     tzvaccd_sdoc_code,
                     tzvaccd_term_code,
                     SUM (tzvaccd_balance)
                         doc_amount,
                     REGEXP_REPLACE (
                         LISTAGG (tzvaccd_tran_number, ',')
                             WITHIN GROUP (ORDER BY tzvaccd_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         trans,
                         TZVACCD_CAMPUS
                         , TZVACCD_CRN
                FROM tzvaccd
               WHERE     tzvaccd_term_code = p_term_code
                    AND 10 = substr(p_term_code,5,2)
                    AND TZVACCD_CAMPUS =  p_camp_code
                    AND tzvaccd_pidm = nvl(p_pidm,tzvaccd_pidm)
                    AND tzvaccd_sdoc_code = nvl(p_sdoc_code,tzvaccd_sdoc_code)
                    AND tzvaccd_balance > 0
                    --
                    and  (CASE WHEN p_appl_id IS NOT NULL  AND p_pidm IS NULL AND EXISTS
                                      (SELECT 1
                                         FROM glbextr
                                        WHERE     glbextr_application =
                                                  p_appl_id
                                              AND glbextr_selection = p_sel_id
                                              AND glbextr_creator_id = p_creator_id
                                              AND glbextr_user_id = p_user_id
                                              AND tzvaccd_pidm = glbextr_key)
                                  THEN 1
                                    WHEN p_pidm IS NOT NULL AND tzvaccd_pidm = p_pidm
                                  THEN 1
                                    WHEN  p_appl_id IS NULL  AND p_pidm IS NULL AND tzvaccd_sdoc_code =  NVL (p_sdoc_code, tzvaccd_sdoc_code) and tzvaccd_sdoc_code <> '000'
                                  THEN 1
                                ELSE 0
                            END) = 1                       
GROUP BY tzvaccd_pidm, tzvaccd_sdoc_code, tzvaccd_term_code, TZVACCD_CAMPUS, TZVACCD_CRN;


    cursor c_get_tx_dis_becas ( p_pidm in number, p_term_code in varchar2, p_sdoc_code varchar2, p_trans varchar2) is
    select a1.tbraccd_tran_number trx_dis
      from tbraccd a1 
    where a1.tbraccd_pidm = p_pidm 
        and a1.TBRACCD_TERM_CODE = p_term_code 
        and a1.TBRACCD_AMOUNT < 0  
        and  a1.TBRACCD_BALANCE = 0 
            AND a1.tbraccd_tran_number NOT IN
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
                                           IS NOT NULL);


    BEGIN


        p_create_header_2 (p_one_up_no,
                           v_user_id_log,
                           v_file_number,
                           'TZPPFAC');
        v_page_width :=
            gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

        v_page_break :=
            gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');


        OPEN v_job_ref FOR
              SELECT gjbprun_number, gjbprun_value, gjbpdef_desc
                FROM gjbprun, gjbpdef
               WHERE     gjbprun_one_up_no = p_one_up_no
                     AND gjbprun_job = 'TZPPFAC'
                     AND gjbpdef_job = gjbprun_job
                     AND gjbpdef_number = gjbprun_number
            ORDER BY gjbprun_number ASC;


        LOOP
            FETCH v_job_ref INTO v_job_rec;

            EXIT WHEN v_job_ref%NOTFOUND; 


            gz_report.p_put_line (
                p_one_up_no =>
                    p_one_up_no,
                p_user =>
                    v_user_id_log,
                p_job_name =>
                    'TZPPFAC',
                p_file_number =>
                    NVL (v_file_number, 1),
                p_content_line =>
                       v_job_rec.r_gjbprun_number
                    || ' - '
                    || v_job_rec.r_gjbprun_desc
                    || ' - '
                    || v_job_rec.r_gjbprun_value
                    || '.',
                p_content_width =>
                    v_page_width,
                p_content_align =>
                    'LEFT',        
                p_status =>
                    v_status,
                p_comments =>
                    v_comments);


            CASE v_job_rec.r_gjbprun_number
                WHEN '01'
                THEN
                    v_term_code := v_job_rec.r_gjbprun_value;
                WHEN '09'
                THEN
                    v_camp_code := v_job_rec.r_gjbprun_value;    
                WHEN '02'
                THEN
                    v_id := v_job_rec.r_gjbprun_value;

                    IF v_id IS NOT NULL
                    THEN
                        BEGIN
                            SELECT spriden_pidm
                              INTO v_pidm
                              FROM spriden
                             WHERE     spriden_id = v_id
                                   AND spriden_change_ind IS NULL;
                        END;
                    END IF;
                WHEN '03'
                THEN
                    v_sdoc_code := v_job_rec.r_gjbprun_value;
                WHEN '04'
                THEN
                    v_selection_id := v_job_rec.r_gjbprun_value;
                WHEN '05'
                THEN
                    v_application_id := v_job_rec.r_gjbprun_value;
                WHEN '06'
                THEN
                    v_creator_id := v_job_rec.r_gjbprun_value;
                WHEN '07'
                THEN
                    v_user_id := v_job_rec.r_gjbprun_value;
                WHEN '08'
                THEN
                    v_send_ind := v_job_rec.r_gjbprun_value;
                ELSE
                    NULL;
            END CASE;
        END LOOP;


        CLOSE v_job_ref;


        FOR ter IN c_get_transactions (v_term_code,
                                     v_camp_code,
                                     v_sdoc_code,
                                     v_pidm,
                                     v_application_id,
                                     v_selection_id,
                                     v_creator_id,
                                     v_user_id)
        LOOP
        BEGIN


            sb_calculo_seg_ter_matricula.p_assign_charges_student (
                p_student_pidm        => ter.tzvaccd_pidm,
                p_periodoprefactura   => ter.tzvaccd_term_code,
                sqlerrormsg           => v_sqlerrormsg);

           p_ins_tzrrlog(v_pidm,  'GENERA_PREFACTURA_MASIVO', 'SEG_Y_TER_MAT', v_sqlerrormsg, user);

            p_error_msg := v_sqlerrormsg;
        exception when others then 
           p_ins_tzrrlog(v_pidm,  'GENERA_PREFACTURA_MASIVO', 'SEG_Y_TER_MAT_ERR', v_sqlerrormsg, user);
        END;

        END LOOP;

        v_row_print :=
               gz_report.f_colum_format ('Id alumno',
                                         9,
                                         'CENTER',
                                         ' | ')
            || gz_report.f_colum_format ('Nombre',
                                         30,
                                         'CENTER',
                                         ' | ')
            || gz_report.f_colum_format ('Tipo de Documento',
                                         17,
                                         'CENTER',
                                         ' | ')
            || gz_report.f_colum_format ('Monto',
                                         16,
                                         'CENTER',
                                         ' | ')
            || gz_report.f_colum_format ('Num. Documento Venta',
                                         20,
                                         'CENTER',
                                         ' | ');

        gz_report.p_put_line (
            p_one_up_no       => p_one_up_no,
            p_user            => v_user_id_log,
            p_job_name        => 'TZPPFAC',
            p_file_number     => NVL (v_file_number, 1),
            p_content_line    => LPAD (' ', v_page_width, '-'),
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',
            p_status          => v_status,
            p_comments        => v_comments);

        gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                              p_user            => v_user_id_log,
                              p_job_name        => 'TZPPFAC',
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => v_row_print,
                              p_content_width   => v_page_width,
                              p_content_align   => 'LEFT',
                              p_status          => v_status,
                              p_comments        => v_comments);

        ln_count := 0;

p_ins_tzrrlog(v_pidm,  'GENERA_PREFACTURA_MASIVO', 'P_GEN_DOCUMENTS', 'v_term_code: ' || v_term_code|| ' v_camp_code: ' ||v_camp_code || ' v_sdoc_code: ' || v_sdoc_code || '  v_application_id: ' ||  v_application_id  || '  v_selection_id: ' ||  v_selection_id || '  v_creator_id: ' ||  v_creator_id || '  v_user_id: ' ||v_user_id, user);

        FOR x IN c_get_transactions (v_term_code,
                                     v_camp_code,
                                     v_sdoc_code,
                                     v_pidm,
                                     v_application_id,
                                     v_selection_id,
                                     v_creator_id,
                                     v_user_id)
        LOOP
            IF c_get_transactions%NOTFOUND
            THEN

                gz_report.p_put_line (
                    p_one_up_no       => p_one_up_no,
                    p_user            => v_user_id_log,
                    p_job_name        => 'TZPPFAC',
                    p_file_number     => NVL (v_file_number, 1),
                    p_content_line    => LPAD (' ', v_page_width, ' '),
                    p_content_width   => v_page_width,
                    p_content_align   => 'LEFT',
                    p_status          => v_status,
                    p_comments        => v_comments);
                gz_report.p_put_line (
                    p_one_up_no =>
                        p_one_up_no,
                    p_user =>
                        v_user_id_log,
                    p_job_name =>
                        'TZPPFAC',
                    p_file_number =>
                        NVL (v_file_number, 1),
                    p_content_line =>
                        'TZPPFAC - No existen documentos de Prefactura a generar.',
                    p_content_width =>
                        v_page_width,
                    p_content_align =>
                        'LEFT',   
                    p_status =>
                        v_status,
                    p_comments =>
                        v_comments);

                EXIT;
                ln_count := 0;
                GOTO end_process;
            END IF;



            BEGIN

                v_levl          := f_get_sovlcur(x.tzvaccd_pidm, x.tzvaccd_term_code, 'LEVL' );
                v_program   := f_get_sovlcur(x.tzvaccd_pidm, x.tzvaccd_term_code, 'PROGRAM' );


                OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
                FETCH c_get_data_i INTO v_user_create;
                CLOSE c_get_data_i;

                OPEN c_get_moneda;
                FETCH c_get_moneda INTO v_moneda;
                CLOSE c_get_moneda;


                v_create_doc :=
                    f_get_valid_document (x.tzvaccd_pidm,
                                          x.tzvaccd_term_code,
                                          x.TZVACCD_CAMPUS,
                                          x.tzvaccd_sdoc_code,
                                          x.tzvaccd_crn);


                IF v_create_doc = 'Y'
                THEN
                    BEGIN
                        p_awards_courses (
                            p_pidm        => x.tzvaccd_pidm,
                            p_term_code   => x.tzvaccd_term_code,
                            p_error_msg => p_error_msg_2 
                            );

                            p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS', p_error_msg_2, user);

                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            gz_report.p_put_line (
                                p_one_up_no =>
                                    p_one_up_no,
                                p_user =>
                                    v_user_id_log,
                                p_job_name =>
                                    'TZPPFAC',
                                p_file_number =>
                                    NVL (v_file_number, 1),
                                p_content_line =>
                                       'Error en calculo de becas o 2da y 3era reprobación: '
                                    || SQLCODE
                                    || '--'
                                    || SUBSTR (SQLERRM||p_error_msg_2, 1, 500),
                                p_content_width =>
                                    v_page_width,
                                p_content_align =>
                                    'LEFT',    
                                p_status =>
                                    v_status,
                                p_comments =>
                                    v_comments);
                            CONTINUE;
                    END;

                    BEGIN


                    BEGIN

                    FOR bec
                        IN c_beca_aplicada (x.tzvaccd_pidm,x.tzvaccd_sdoc_code, x.tzvaccd_term_code)
                    LOOP
                                     IF abs(bec.amt) = abs(bec.bal) then
                                        v_beca_no_aplicada := 'Y';
                                     end if;

                    END LOOP;
                    p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS', v_beca_no_aplicada, user);

                      FOR hb  IN c_has_bec (x.tzvaccd_pidm,x.tzvaccd_sdoc_code, x.tzvaccd_term_code)
                                        LOOP
                                            v_doc_number_i :=  hb.tvrsdoc_doc_number;
                                                        FOR ba  IN c_boleto_activo (x.tzvaccd_pidm,x.tzvaccd_sdoc_code, x.tzvaccd_term_code, hb.tvrsdoc_doc_number)
                                                        LOOP  
                                                        p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS ', ba.balance, user);

                                                              IF ba.balance > 0 then
                                                                v_print_becas_i := 'Y';
                                                              END IF;
                                                        END LOOP;
                                                    p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS ', v_print_becas_i, user);
                                        END LOOP;

                              p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS', v_print_becas_i ||' - ' ||v_doc_number_i, user);

                                       IF v_print_becas_i = 'Y' or v_doc_number_i = 0 then
                                          FOR b_tran  IN c_bec_trans (x.tzvaccd_pidm,x.tzvaccd_sdoc_code, x.tzvaccd_term_code, x.trans)
                                               LOOP
                                                   IF b_tran.trans_num is not null then
                                                    v_trans := v_trans ||',' ||b_tran.trans_num;
                                                    END IF;
                                               END LOOP;     
                                               p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS', v_trans, user);
                                        END IF;       
                     EXCEPTION WHEN OTHERS THEN 
                     lv_out_error :=                                    SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);  
                                               p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS_ERR', lv_out_error, user);
                    END;

                    IF TZKPUFC.f_get_valid_document(x.tzvaccd_pidm, x.tzvaccd_term_code, x.TZVACCD_CAMPUS, x.tzvaccd_sdoc_code, x.TZVACCD_CRN) = 'Y' THEN
                        IF v_beca_no_aplicada = 'Y' then
                               lv_out_error := 'Estudiante: ' ||gb_common.f_get_id(x.tzvaccd_pidm) ||' tiene Becas por aplicar.';
                               v_beca_no_aplicada := 'N';
                                p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS_ERR_2', lv_out_error, user);

                               EXIT;
                        END IF;
                      ELSE
                               lv_out_error := 'Estudiante: ' ||gb_common.f_get_id(x.tzvaccd_pidm) ||' f_get_valid_document.';
                               p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'BECAS_ERR_3', lv_out_error, user);

                               EXIT;
                     END IF;          

                       IF v_trans is not null then
                       v_all_trans := x.trans||','||v_trans;
                       ELSE
                       v_all_trans := x.trans;
                       END IF;

                            p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'ALL_TRANS', v_all_trans, user);

                        tzkpufc.p_gen_doc (
                            p_pidm        => x.tzvaccd_pidm,
                            p_trans       => v_all_trans, 
                            p_sdoc_code   => x.tzvaccd_sdoc_code,
                            p_site_code   => x.TZVACCD_CAMPUS,
                            p_term_code   => x.tzvaccd_term_code,
                            p_curr_code   => v_moneda,
                            p_user_id     => v_user_create,
                            p_program     => v_program,
                            p_levl_code   => v_levl,
                            p_doc_num     => v_doc_num,
                            p_error_ind   => v_error_ind,
                            p_error_msg   => v_err_msg);

p_ins_tzrrlog(x.tzvaccd_pidm,  'GENERA_PREFACTURA_MASIVO', 'P_GEN_DOC', 'ALL_TRANS: ' || v_all_trans||' x.tzvaccd_sdoc_code: ' ||x.tzvaccd_sdoc_code||' x.TZVACCD_CAMPUS: ' ||x.TZVACCD_CAMPUS
||' x.tzvaccd_term_code: ' ||x.tzvaccd_term_code||' v_moneda: ' ||v_moneda||' v_user_create: ' ||v_user_create||' v_program: ' ||v_program
||' v_levl: ' ||v_levl||' v_doc_num: ' ||v_doc_num||' v_error_ind: ' ||v_error_ind||' v_err_msg: ' ||v_err_msg, user);


                            v_all_trans := '';

                        gb_common.p_commit;

                        v_trans := '';

                        IF v_err_msg IS NOT NULL
                        THEN
                            gz_report.p_put_line (
                                p_one_up_no       => p_one_up_no,
                                p_user            => v_user_id_log,
                                p_job_name        => 'TZPPFAC',
                                p_file_number     => NVL (v_file_number, 1),
                                p_content_line    => 'Error con ID:'||gb_common.f_get_id(x.tzvaccd_pidm)||'-'|| v_err_msg,
                                p_content_width   => v_page_width,
                                p_content_align   => 'LEFT', 
                                p_status          => v_status,
                                p_comments        => v_comments);
                        END IF;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            gz_report.p_put_line (
                                p_one_up_no =>
                                    p_one_up_no,
                                p_user =>
                                    v_user_id_log,
                                p_job_name =>
                                    'TZPPFAC',
                                p_file_number =>
                                    NVL (v_file_number, 1),
                                p_content_line =>
                                       'Error con ID:'||gb_common.f_get_id(x.tzvaccd_pidm)||'-'
                                    || SQLCODE
                                    || '--'
                                    || SUBSTR (SQLERRM, 1, 500),
                                p_content_width =>
                                    v_page_width,
                                p_content_align =>
                                    'LEFT', 
                                p_status =>
                                    v_status,
                                p_comments =>
                                    v_comments);

                    END;

                    IF v_doc_num IS NULL
                    THEN

                        gz_report.p_put_line (
                            p_one_up_no =>
                                p_one_up_no,
                            p_user =>
                                v_user_id_log,
                            p_job_name =>
                                'TZPPFAC',
                            p_file_number =>
                                NVL (v_file_number, 1),
                            p_content_line =>
                                   'Error al generar la prefactura del id '
                                || gb_common.f_get_id (x.tzvaccd_pidm)
                                || ' ´'
                                || v_err_msg,
                            p_content_width =>
                                v_page_width,
                            p_content_align =>
                                'LEFT',
                            p_status =>
                                v_status,
                            p_comments =>
                                v_comments);

                    ELSIF v_doc_num IS NOT NULL
                    THEN

                        p_show_pdf (p_pidm         => x.tzvaccd_pidm,
                                    p_doc_number   => TO_NUMBER (v_doc_num),
                                    p_send_mail    => v_send_ind,
                                    p_web          => 'N',
                                    p_footer => '');

                        BEGIN
                            SELECT SUM (tzvaccd_balance)
                              INTO lv_doc_amount
                              FROM tzvaccd
                             WHERE     tzvaccd_term_code =
                                       x.tzvaccd_term_code
                                   AND tzvaccd_pidm = x.tzvaccd_pidm
                                   AND tzvaccd_sdoc_code =
                                       x.tzvaccd_sdoc_code;
                        END;

                        v_row_print :=
                               gz_report.f_colum_format (
                                   gb_common.f_get_id (x.tzvaccd_pidm),
                                   9,
                                   'LEFT',
                                   '  | ')
                            || gz_report.f_colum_format (
                                   f_format_name (x.tzvaccd_pidm, 'FMIL'),
                                   30,
                                   'LEFT',
                                   '  | ')
                            || gz_report.f_colum_format (x.tzvaccd_sdoc_code,
                                                         17,
                                                         'CENTER',
                                                         '  | ')
                            || gz_report.f_colum_format (lv_doc_amount, 
                                                         16,
                                                         'CENTER',
                                                         '  | ')
                            || gz_report.f_colum_format (v_doc_num,
                                                         20,
                                                         'CENTER',
                                                         '  | ');




                        gz_report.p_put_line (
                            p_one_up_no       => p_one_up_no,
                            p_user            => v_user_id_log,
                            p_job_name        => 'TZPPFAC',
                            p_file_number     => NVL (v_file_number, 1),
                            p_content_line    => v_row_print,
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', 
                            p_status          => v_status,
                            p_comments        => v_comments);
                    END IF;
                ELSE
                    gz_report.p_put_line (
                        p_one_up_no =>
                            p_one_up_no,
                        p_user =>
                            v_user_id_log,
                        p_job_name =>
                            'TZPPFAC',
                        p_file_number =>
                            NVL (v_file_number, 1),
                        p_content_line =>
                            'No se puede generar el documento de Prefactura para el ID:'||gb_common.f_get_id(x.tzvaccd_pidm)||', ya que está fuera de vigencia.',
                        p_content_width =>
                            v_page_width,
                        p_content_align =>
                            'LEFT',  
                        p_status =>
                            v_status,
                        p_comments =>
                            v_comments);
                END IF;

                ln_count := ln_count + 1;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                lv_out_error :=
                                    SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);


            END;
        END LOOP;

        gb_common.p_commit;

       <<end_process>>

        gz_report.p_put_line (
            p_one_up_no =>
                p_one_up_no,
            p_user =>
                v_user_id_log,
            p_job_name =>
                'TZPPFAC',
            p_file_number =>
                NVL (v_file_number, 1),
            p_content_line =>
                   'TZPPFAC - Se procesaron '
                || ln_count
                || ' registros. Proceso terminado',
            p_content_width =>
                v_page_width,
            p_content_align =>
                'LEFT',  
            p_status =>
                v_status,
            p_comments =>
                v_comments);
        EXCEPTION
            WHEN OTHERS
            THEN

                lv_out_error := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);



    END;

-- Procedimiento que inserta la información de la prefactura en la tabla TZRFACT.
--
    PROCEDURE p_insert_tzrfact (p_pidm          IN     NUMBER,
                                p_sdoc_code     IN     VARCHAR2,
                                p_doc_number    IN     VARCHAR2,
                                p_crn in varchar2 default null,
                                p_out_message      OUT VARCHAR2)
    IS
        lv_out_error   VARCHAR2 (1000);


       cursor c_get_educacion_continua (p_pidm  IN     NUMBER, p_doc_number in varchar2) is
       select TBRACCD_CROSSREF_NUMBER, TBRACCD_TERM_CODE 
          from tbraccd 
        where tbraccd_pidm = p_pidm
            and TBRACCD_TRAN_NUMBER in 
          (select TVRSDOC_CHG_TRAN_NUMBER from tvrsdoc where tvrsdoc_pidm = tbraccd_pidm and tvrsdoc_doc_number = p_doc_number and TVRSDOC_DOC_CANCEL_IND is null) 
          and TBRACCD_CROSSREF_NUMBER is not null;

        cursor c_get_cnt_contrato (p_pidm  IN     NUMBER, p_term_code in varchar2, p_contratct_number in number) is
        select count(0) cnt from TBBCSTU
        where
        TBBCSTU_CONTRACT_PIDM = p_pidm
        and TBBCSTU_TERM_CODE = p_term_code
        and TBBCSTU_CONTRACT_NUMBER = p_contratct_number;

          cursor c_get_val_cnt (p_pidm  IN     NUMBER, p_term_code in varchar2, p_contratct_number in number) is 
            SELECT 'Y'
              FROM gorsdav
             WHERE     gorsdav_table_name = 'TBBCONT'
                   AND gorsdav_attr_name = 'FACTURACION_INDIVUDUAL'
                   AND getdata (gorsdav_value) = 'Y'
                   AND GORSDAV_PK_PARENTTAB = p_pidm||chr(1)||p_contratct_number||chr(1)||p_term_code;

    v_cnt_val varchar2(1):='N';
    v_cnt_contrato number := 1;
    v_CROSSREF_NUMBER  TBRACCD.TBRACCD_CROSSREF_NUMBER%type;
    v_TERM_CODE           TBRACCD.TBRACCD_TERM_CODE%type;


CURSOR c_get_trans  (p_pidm  IN     NUMBER, p_term_code in varchar2)
        IS
        select TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE, sum(TBRACCD_AMOUNT) TBRACCD_AMOUNT, sum(TBRACCD_BALANCE) TBRACCD_BALANCE, TBRACCD_STSP_KEY_SEQUENCE, TBRACCD_CRN
from (
select TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE, TBRACCD_AMOUNT, TBRACCD_BALANCE, tbraccd_stsp_key_sequence, decode(substr(tbraccd_term_code,5,2), '10', tbraccd_crn, null) tbraccd_crn
from tbraccd, tbbdetc where tbraccd_pidm = p_pidm  and TBRACCD_TERM_CODE = p_term_code
and TBRACCD_BALANCE <> 0 
and  tbraccd_detail_code = tbbdetc_detail_code
and tbbdetc_type_ind = 'C'
and  TBRACCD_TRAN_NUMBER not in (select TZRFACT_TRAN_NUM from tzrfact , tvbsdoc where tzrfact_pidm = tvbsdoc_pidm and tzrfact_doc_number = tvbsdoc_doc_number 
            and tvbsdoc_doc_cancel_ind is null and tzrfact_pidm =TBRACCD_PIDM and TZRFACT_SRI_DOCNUM is not null 
           and (select count(0) from tbrappl vl where vl.tbrappl_pidm = TBRACCD_PIDM and vl.TBRAPPL_CHG_TRAN_NUMBER = TBRACCD_TRAN_NUMBER and vl.TBRAPPL_REAPPL_IND is null)<2)  
UNION ALL
select TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE, 0, TBRAPPL_AMOUNT, tbraccd_stsp_key_sequence, decode(substr(tbraccd_term_code,5,2), '10', tbraccd_crn, null) tbraccd_crn
from tbraccd , tbbdetc, tbrappl
where tbraccd_detail_code = tbbdetc_detail_code
and tbbdetc_dcat_code in ('BEC','DES')
and tbbdetc_type_ind = 'P'
and tbraccd_pidm = p_pidm 
and TBRACCD_TERM_CODE = p_term_code
and TBRACCD_BALANCE = 0 
and TBRACCD_TRAN_NUMBER = TBRAPPL_PAY_TRAN_NUMBER
and tbraccd_pidm = tbrappl_pidm
and TBRAPPL_REAPPL_IND is null
and  TBRACCD_TRAN_NUMBER not in (select TZRFACT_TRAN_NUM from tzrfact , tvbsdoc where tzrfact_pidm = tvbsdoc_pidm and tzrfact_doc_number = tvbsdoc_doc_number 
            and tvbsdoc_doc_cancel_ind is null and tzrfact_pidm =TBRACCD_PIDM and TZRFACT_SRI_DOCNUM is not null 
           and (select count(0) from tbrappl vl where vl.tbrappl_pidm = TBRACCD_PIDM and vl.TBRAPPL_CHG_TRAN_NUMBER = TBRACCD_TRAN_NUMBER and vl.TBRAPPL_REAPPL_IND is null)<2) 
UNION ALL
SELECT TBRAPPL_PIDM PIDM, Y.TBRACCD_TRAN_NUMBER, Y.TBRACCD_TERM_CODE, Y.TBRACCD_DETAIL_CODE DETAIL_CODE, 0,
case 
when DETL_CHG.TBBDETC_DCAT_CODE in ('BEC', 'DES') then
TBRAPPL_AMOUNT *-1
else
TBRAPPL_AMOUNT
end  AMOUNT
, y.tbraccd_stsp_key_sequence, decode(substr(y.tbraccd_term_code,5,2), '10', y.tbraccd_crn, null) tbraccd_crn
FROM    TBRACCD X, TBRACCD Y, TBRAPPL, TBBDETC DETL_CHG, TBBDETC DETL_PAY 
WHERE   TBRAPPL_PIDM = p_pidm  
     and X.TBRACCD_TERM_CODE = p_term_code
     and X.TBRACCD_TERM_CODE = Y.TBRACCD_TERM_CODE 
     AND X.tbraccd_pidm = tbrappl_pidm  
     AND Y.tbraccd_pidm = tbrappl_pidm 
     AND Y.TBRACCD_DETAIL_CODE= DETL_CHG.TBBDETC_DETAIL_CODE 
     AND X.TBRACCD_DETAIL_CODE= DETL_PAY.TBBDETC_DETAIL_CODE 
      AND DETL_PAY.TBBDETC_TYPE_IND='P'
      AND DETL_PAY.TBBDETC_DCAT_CODE in ('BEC', 'DES')
     AND TBRAPPL_PAY_TRAN_NUMBER = X.TBRACCD_TRAN_NUMBER 
     AND TBRAPPL_CHG_TRAN_NUMBER = Y.TBRACCD_TRAN_NUMBER 
     AND TBRAPPL_REAPPL_IND is null
     and  x.TBRACCD_TRAN_NUMBER not in (select TZRFACT_TRAN_NUM from tzrfact, tvbsdoc where tzrfact_pidm = tvbsdoc_pidm and tzrfact_doc_number = tvbsdoc_doc_number 
            and tvbsdoc_doc_cancel_ind is null and tzrfact_pidm =x.TBRACCD_PIDM and TZRFACT_SRI_DOCNUM is not null 
           and (select count(0) from tbrappl where tbrappl_pidm = x.TBRACCD_PIDM and TBRAPPL_CHG_TRAN_NUMBER = x.TBRACCD_TRAN_NUMBER and TBRAPPL_REAPPL_IND is null)<2)  
     ) where TBRACCD_DETAIL_CODE in ( select TZVACCD_DETAIL_CODE from TZVACCD where  tzvaccd_pidm = TBRACCD_PIDM  
                                                                 and TZVACCD_TERM_CODE = TBRACCD_TERM_CODE 
                                                                  and TZVACCD_SDOC_CODE = p_sdoc_code)
     group by TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE,  TBRACCD_STSP_KEY_SEQUENCE, TBRACCD_CRN
     order by TBRACCD_TRAN_NUMBER;


CURSOR c_get_trx_ed_cont  (p_pidm  IN     NUMBER, p_term_code in varchar2, v_crn in varchar2)
        IS
select TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE, sum(TBRACCD_AMOUNT) TBRACCD_AMOUNT, sum(TBRACCD_BALANCE) TBRACCD_BALANCE, TBRACCD_STSP_KEY_SEQUENCE, TBRACCD_CRN
from (
select TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE, TBRACCD_AMOUNT, TBRACCD_BALANCE, tbraccd_stsp_key_sequence, decode(substr(tbraccd_term_code,5,2), '10', tbraccd_crn, null) tbraccd_crn
from tbraccd, tbbdetc where tbraccd_pidm = p_pidm  and TBRACCD_TERM_CODE = p_term_code
and TBRACCD_BALANCE <> 0 
and  tbraccd_detail_code = tbbdetc_detail_code
and tbbdetc_type_ind = 'C'
and  TBRACCD_TRAN_NUMBER not in (select TZRFACT_TRAN_NUM from tzrfact , tvbsdoc where tzrfact_pidm = tvbsdoc_pidm and tzrfact_doc_number = tvbsdoc_doc_number 
            and tvbsdoc_doc_cancel_ind is null and tzrfact_pidm =TBRACCD_PIDM and TZRFACT_SRI_DOCNUM is not null             
           and (select count(0) from tbrappl vl where vl.tbrappl_pidm = TBRACCD_PIDM and vl.TBRAPPL_CHG_TRAN_NUMBER = TBRACCD_TRAN_NUMBER and vl.TBRAPPL_REAPPL_IND is null)<2)  
UNION ALL
select ccd.TBRACCD_PIDM, ccd.TBRACCD_TRAN_NUMBER, ccd.TBRACCD_TERM_CODE, ccd.TBRACCD_DETAIL_CODE, 0, TBRAPPL_AMOUNT, ccd.tbraccd_stsp_key_sequence, 
(select crn.TBRACCD_CRN from tbraccd crn where crn.tbraccd_pidm = ccd.TBRACCD_PIDM and crn.tbraccd_tran_number in (
  select TBRAPPL_CHG_TRAN_NUMBER from tbrappl where tbrappl_pidm = crn.TBRACCD_PIDM and TBRAPPL_PAY_TRAN_NUMBER = ccd.TBRACCD_TRAN_NUMBER) and rownum = 1)
tbraccd_crn
from tbraccd ccd, tbbdetc, tbrappl
where ccd.tbraccd_detail_code = tbbdetc_detail_code
and tbbdetc_dcat_code in ('BEC','DES')
and tbbdetc_type_ind = 'P'
and ccd.tbraccd_pidm = p_pidm 
and ccd.TBRACCD_TERM_CODE = p_term_code
and ccd.TBRACCD_BALANCE = 0 
and ccd.TBRACCD_TRAN_NUMBER = TBRAPPL_PAY_TRAN_NUMBER
and ccd.tbraccd_pidm = tbrappl_pidm
and TBRAPPL_REAPPL_IND is null
and  ccd.TBRACCD_TRAN_NUMBER not in (select TZRFACT_TRAN_NUM from tzrfact , tvbsdoc where tzrfact_pidm = tvbsdoc_pidm and tzrfact_doc_number = tvbsdoc_doc_number 
            and tvbsdoc_doc_cancel_ind is null and tzrfact_pidm =ccd.TBRACCD_PIDM and TZRFACT_SRI_DOCNUM is not null             
           and (select count(0) from tbrappl vl where vl.tbrappl_pidm = ccd.TBRACCD_PIDM and vl.TBRAPPL_CHG_TRAN_NUMBER = ccd.TBRACCD_TRAN_NUMBER and vl.TBRAPPL_REAPPL_IND is null)<2) 
UNION ALL
SELECT TBRAPPL_PIDM PIDM, Y.TBRACCD_TRAN_NUMBER, Y.TBRACCD_TERM_CODE, Y.TBRACCD_DETAIL_CODE DETAIL_CODE, 0,
case 
when DETL_CHG.TBBDETC_DCAT_CODE in ('BEC', 'DES') then
TBRAPPL_AMOUNT *-1
else
TBRAPPL_AMOUNT
end  AMOUNT
, y.tbraccd_stsp_key_sequence, decode(substr(y.tbraccd_term_code,5,2), '10', y.tbraccd_crn, null) tbraccd_crn
FROM    TBRACCD X, TBRACCD Y, TBRAPPL, TBBDETC DETL_CHG, TBBDETC DETL_PAY 
WHERE   TBRAPPL_PIDM = p_pidm  
     and X.TBRACCD_TERM_CODE = p_term_code
     and X.TBRACCD_TERM_CODE = Y.TBRACCD_TERM_CODE 
     AND X.tbraccd_pidm = tbrappl_pidm  
     AND Y.tbraccd_pidm = tbrappl_pidm 
     AND Y.TBRACCD_DETAIL_CODE= DETL_CHG.TBBDETC_DETAIL_CODE 
     AND X.TBRACCD_DETAIL_CODE= DETL_PAY.TBBDETC_DETAIL_CODE 
      AND DETL_PAY.TBBDETC_TYPE_IND='P'
      AND DETL_PAY.TBBDETC_DCAT_CODE in ('BEC', 'DES')
     AND TBRAPPL_PAY_TRAN_NUMBER = X.TBRACCD_TRAN_NUMBER 
     AND TBRAPPL_CHG_TRAN_NUMBER = Y.TBRACCD_TRAN_NUMBER 
     AND TBRAPPL_REAPPL_IND is null
     and  x.TBRACCD_TRAN_NUMBER not in (select TZRFACT_TRAN_NUM from tzrfact, tvbsdoc where tzrfact_pidm = tvbsdoc_pidm and tzrfact_doc_number = tvbsdoc_doc_number 
            and tvbsdoc_doc_cancel_ind is null and tzrfact_pidm =x.TBRACCD_PIDM and TZRFACT_SRI_DOCNUM is not null             
           and (select count(0) from tbrappl where tbrappl_pidm = x.TBRACCD_PIDM and TBRAPPL_CHG_TRAN_NUMBER = x.TBRACCD_TRAN_NUMBER and TBRAPPL_REAPPL_IND is null)<2)  
     ) where TBRACCD_DETAIL_CODE in ( select TZVACCD_DETAIL_CODE from TZVACCD where  tzvaccd_pidm = TBRACCD_PIDM  
                                                                 and TZVACCD_TERM_CODE = TBRACCD_TERM_CODE 
                                                                  and TZVACCD_SDOC_CODE = p_sdoc_code)              
         and nvl(TBRACCD_CRN,1) = nvl2(v_crn,TBRACCD_CRN,1)
     group by TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE,  TBRACCD_STSP_KEY_SEQUENCE, TBRACCD_CRN
     order by TBRACCD_TRAN_NUMBER;


p_id             varchar2(10);
p_program    varchar2(100);   
p_fmt_pref    varchar2(100);   

p_ed_continua varchar2(10);

cursor c_get_campus is 
select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(p_doc_number,7,1);

p_campus varchar2(30);


    BEGIN

open c_get_campus;
fetch c_get_campus into p_campus;
close c_get_campus;

open  c_get_educacion_continua (p_pidm, p_doc_number);
fetch c_get_educacion_continua into v_CROSSREF_NUMBER, v_TERM_CODE;
close c_get_educacion_continua;

open  c_get_cnt_contrato (p_pidm, v_TERM_CODE, v_CROSSREF_NUMBER);
fetch c_get_cnt_contrato into v_cnt_contrato;
close c_get_cnt_contrato;

open c_get_val_cnt  (p_pidm, v_TERM_CODE, v_CROSSREF_NUMBER);
fetch c_get_val_cnt into v_cnt_val;
close c_get_val_cnt;

IF v_cnt_val = 'Y' THEN
v_cnt_contrato := 1;
END IF;

p_id:=  gb_common.f_get_id (p_pidm);
p_program :=  f_get_sovlcur(p_pidm , substr(p_doc_number,1,6), 'PROGRAM');
p_fmt_pref :=  f_get_docnum_fmt(p_doc_number);

OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;

p_ed_continua := substr(p_doc_number,5,2);

IF p_ed_continua = '10' then

FOR rect IN c_get_trx_ed_cont(p_pidm, substr(p_doc_number,1,6), p_crn)
        LOOP

         IF   nvl(rect.tbraccd_crn,1) = nvl(p_crn,1) then     
            INSERT INTO taismgr.tzrfact (tzrfact_pidm,
                                         tzrfact_sdoc_code,
                                         tzrfact_doc_number,
                                         tzrfact_id,
                                         tzrfact_curr_program,
                                         tzrfact_sale_docnum,
                                         tzrfact_det_code_doc,
                                         tzrfact_amnt_trans,
                                         tzrfact_tran_num,
                                         tzrfact_prefact_date,
                                         tzrfact_activity_date,
                                         tzrfact_user,
                                         TZRFACT_TERM_CODE,
                                         TZRFACT_CRN_CONTND,
                                         TZRFACT_STPERDOC_QTY,
                                         TZRFACT_CAMPUS)
                 VALUES (rect.TBRACCD_PIDM,
                         p_sdoc_pref,
                         p_doc_number,
                         p_id,
                         p_program,
                         f_get_docnum_fmt(p_doc_number),
                         rect.tbraccd_detail_code,
                         rect.TBRACCD_BALANCE,
                         rect.tbraccd_tran_number,
                         SYSDATE,
                         SYSDATE,
                         USER,
                         rect.tbraccd_term_code,
                         rect.tbraccd_crn, 
                         v_cnt_contrato,
                         p_campus); 

                         p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_MASIVO', 'REC_ED_CONT: ', rect.TBRACCD_PIDM||'-'||rect.tbraccd_detail_code||'-'|| rect.TBRACCD_BALANCE||'-'||rect.tbraccd_crn, user);
          END IF;         
        END LOOP;
ELSE
        FOR rect IN c_get_trans(p_pidm, substr(p_doc_number,1,6))
        LOOP


            INSERT INTO taismgr.tzrfact (tzrfact_pidm,
                                         tzrfact_sdoc_code,
                                         tzrfact_doc_number,
                                         tzrfact_id,
                                         tzrfact_curr_program,
                                         tzrfact_sale_docnum,
                                         tzrfact_det_code_doc,
                                         tzrfact_amnt_trans,
                                         tzrfact_tran_num,
                                         tzrfact_prefact_date,
                                         tzrfact_activity_date,
                                         tzrfact_user,
                                         TZRFACT_TERM_CODE,
                                         TZRFACT_CRN_CONTND,
                                         TZRFACT_STPERDOC_QTY,
                                         TZRFACT_CAMPUS)
                 VALUES (rect.TBRACCD_PIDM,
                         p_sdoc_pref,
                         p_doc_number,
                         p_id,
                         p_program,
                         f_get_docnum_fmt(p_doc_number),
                         rect.tbraccd_detail_code,
                         rect.TBRACCD_BALANCE,
                         rect.tbraccd_tran_number,
                         SYSDATE,
                         SYSDATE,
                         USER,
                         rect.tbraccd_term_code,
                         rect.tbraccd_crn, 
                         v_cnt_contrato,
                         p_campus); 

                         p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_MASIVO', 'REC', rect.TBRACCD_PIDM||'-'||rect.tbraccd_detail_code||'-'|| rect.TBRACCD_BALANCE||'-'||rect.tbraccd_crn, user);

        END LOOP;

end if; 


        lv_out_error := 'Registros creados en TZRFACT con exito.';
        p_out_message := lv_out_error;
    EXCEPTION
        WHEN OTHERS
        THEN
            lv_out_error := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

             p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA_MASIVO', 'INS_TZRFACT', SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500), user);

            p_out_message := lv_out_error;
    END;


-- Procedimiento principal para la cancelacion de documentos de venta.
-- Actualiza en tablas principales de Banner TVBSDOC, TVRSDOC, TZRFACT y TZRDPRF.
--
    PROCEDURE p_cancel_sales_doc (p_pidm          IN     NUMBER,
                                  p_sdoc_code     IN     VARCHAR2,
                                  p_doc_num       IN     VARCHAR2,
                                  p_data_origin   IN     VARCHAR2,
                                  p_user_id       IN     VARCHAR2,
                                  p_error_ind        OUT VARCHAR2,
                                  p_error_msg        OUT VARCHAR2)
    IS
        --
        CURSOR getcanceldocc
        IS
            SELECT tvrsdoc_pay_tran_number,
                   tvrsdoc_chg_tran_number,
                   tvrsdoc_pidm
              FROM tvrsdoc
             WHERE     tvrsdoc_pidm = p_pidm
                   AND tvrsdoc_doc_number = p_doc_num
                   AND tvrsdoc_sdoc_code = p_sdoc_code
                   AND NVL (tvrsdoc_doc_cancel_ind, 'N') <> 'Y';
    --
    cursor c_get_status is
    select TZRDPRF_DOC_STATUS from tzrdprf
              WHERE     tzrdprf_pidm = p_pidm
                           AND tzrdprf_doc_number = p_doc_num;

   cursor c_second is 
    select 'Y'
    from tzrfact where tzrfact_pidm = p_pidm and TZRFACT_DOC_NUMBER = p_doc_num and TZRFACT_SRI_DOCNUM is not null 
    and (TZRFACT_FACT_CANCEL_IND is not null or TZRFACT_CREDNT_SRICODE is not null) ;

   p_sec_cond varchar2(1):= 'N' ;

    v_status        TZRDPRF.TZRDPRF_DOC_STATUS%type;

    BEGIN
        --
        p_error_ind := ''; 
        p_error_msg := '';

        open c_get_status;
        fetch c_get_status into v_status;
        close c_get_status;

         open c_second;
         fetch c_second into p_sec_cond;
         close c_second;

p_ins_tzrrlog(p_pidm,  'CANCELA_PREFACTURA', 'PARAM: ', ' p_sdoc_code:'||p_sdoc_code||' p_doc_num:'||p_doc_num || ' p_data_origin:'||p_data_origin||' p_user_id:'||p_user_id ||' v_status:'||v_status, user);


  IF v_status = 'ACEPTADO'  and nvl(p_sec_cond,'N') = 'N' then

            p_error_ind := -20000;
            p_error_msg := 'Documento Pagado, no puede ser cancelado.';

ELSE

begin
        UPDATE tvrsdoc
           SET tvrsdoc_doc_cancel_ind = 'Y',
               tvrsdoc_activity_date = SYSDATE,
               TVRSDOC_USER_ID = USER
         WHERE     tvrsdoc_pidm = p_pidm
               AND tvrsdoc_doc_number = p_doc_num
               AND tvrsdoc_sdoc_code = p_sdoc_code
               AND NVL (tvrsdoc_doc_cancel_ind, 'N') <> 'Y';
EXCEPTION
        WHEN OTHERS
        THEN
            p_error_ind := SQLCODE;
            p_error_msg := SUBSTR (SQLERRM, 1, 500);
        end;    

        begin
        UPDATE tvbsdoc
           SET tvbsdoc_doc_cancel_ind = 'Y',
               tvbsdoc_activity_date = SYSDATE,
               TVBSDOC_USER_ID = USER
         WHERE     tvbsdoc_pidm = p_pidm
               AND tvbsdoc_doc_number = p_doc_num
               AND tvbsdoc_sdoc_code = p_sdoc_code
               AND NVL (tvbsdoc_doc_cancel_ind, 'N') <> 'Y';
               EXCEPTION
        WHEN OTHERS
        THEN
            p_error_ind := SQLCODE;
            p_error_msg := SUBSTR (SQLERRM, 1, 500);
        end;    

       begin
        update tzrfact set tzrfact_pref_cancel_ind = 'Y' where TZRFACT_PIDM = p_pidm and TZRFACT_DOC_NUMBER = p_doc_num;
        EXCEPTION
        WHEN OTHERS
        THEN
            p_error_ind := SQLCODE;
            p_error_msg := SUBSTR (SQLERRM, 1, 500);
        end;    


BEGIN
                    UPDATE tzrdprf
                       SET tzrdprf_doc_status = 'ANULADA',
                           tzrdprf_user_id = USER,
                           tzrdprf_activity_date = SYSDATE
                     WHERE     tzrdprf_pidm = p_pidm
                           AND tzrdprf_doc_number = p_doc_num;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

    END IF;

    EXCEPTION
        WHEN OTHERS
        THEN
            p_error_ind := SQLCODE;
            p_error_msg := SUBSTR (SQLERRM, 1, 500);
    END;


    PROCEDURE p_create_header (in_seq_no              NUMBER,
                               in_user_id             VARCHAR2,
                               p_file_number      OUT NUMBER,
                               app_name        IN     VARCHAR2)
    IS
        const_package_name         CONSTANT VARCHAR2 (32) := 'TZKPUFC';
        inst_name                           VARCHAR2 (100);

        v_status                            VARCHAR2 (10);
        v_comments                          VARCHAR2 (20000);
        v_file_name                         guboutp.guboutp_file_name%TYPE;
        v_file_number                       guboutp.guboutp_file_number%TYPE;
        v_environment                       VARCHAR2 (25) := NULL;
        v_environment_nm                    VARCHAR2 (25);
        v_page_width                        NUMBER;
        v_page_break                        NUMBER;

        const_application_name     CONSTANT VARCHAR2 (32) := app_name;
        const_out_line_headerj     CONSTANT VARCHAR2 (230)
            :=    RPAD ('DATE RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'mm/dd/yyyy'), 43, ' ')
               || RPAD (inst_name, 58, ' ')
               || 'REPORT PAGE' ;

        const_out_line_header2     VARCHAR2 (230);


        const_out_line_header2_2   CONSTANT VARCHAR2 (230)
            :=    RPAD ('TIME RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'hh12:mi:ss AM'), 31, ' ')
               || RPAD ('Proceso Masivo de Generacion de Prefacturas',
                        70,
                        ' ')
               || RPAD ('PROGRAM ID TZPPFAC', 18, ' ') ;
    BEGIN

    IF APP_NAME = 'TZPPREN' THEN
     const_out_line_header2 :=    RPAD ('TIME RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'hh12:mi:ss AM'), 31, ' ')
               || RPAD ('--- Proceso de reenvío de prefacturas ---', 70, ' ')
               || RPAD ('PROGRAM ID TZPPREN', 18, ' ') ;
     ELSIF APP_NAME = 'TZPFMAS' THEN
     const_out_line_header2 :=    RPAD ('TIME RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'hh12:mi:ss AM'), 31, ' ')
               || RPAD ('--- Proceso de Impresión de Facturas ---', 70, ' ')
               || RPAD ('PROGRAM ID TZPFMAS', 18, ' ') ;     
     ELSE

     const_out_line_header2 :=    RPAD ('TIME RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'hh12:mi:ss AM'), 31, ' ')
               || RPAD ('--- Proceso de Rolado de Secuencias ---', 70, ' ')
               || RPAD ('PROGRAM ID TZPFACT', 18, ' ') ;
      END IF;         

        DBMS_OUTPUT.enable (1000000);

        SELECT gubinst_name INTO inst_name FROM gubinst;


        SELECT SYS_CONTEXT ('USERENV', 'DB_NAME')
          INTO v_environment
          FROM DUAL;

        IF SUBSTR (v_environment, 1, 4) = 'PROD'
        THEN
            v_environment_nm := 'PRODUCTION INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'DEVL'
        THEN
            v_environment_nm := 'DEVELOPMENT INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'TEST'
        THEN
            v_environment_nm := 'TEST INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'QA'
        THEN
            v_environment_nm := 'QUALITY INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'TEMP'
        THEN
            v_environment_nm := 'TEMP INSTANCE';
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

        p_file_number := v_file_number;


        v_page_width :=
            gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

        v_page_break :=
            gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');


        gz_report.p_put_line (p_one_up_no       => in_seq_no,
                              p_user            => in_user_id,
                              p_job_name        => const_application_name,
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => CHR (12),
                              p_content_width   => v_page_width,
                              p_content_align   => 'CENTER', 
                              p_status          => v_status,
                              p_comments        => v_comments);

        gz_report.p_put_line (p_one_up_no       => in_seq_no,
                              p_user            => in_user_id,
                              p_job_name        => const_application_name,
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => const_out_line_headerj,
                              p_content_width   => v_page_width,
                              p_content_align   => 'CENTER', 
                              p_status          => v_status,
                              p_comments        => v_comments);

        IF app_name = 'TZPPFAC'
        THEN
            gz_report.p_put_line (
                p_one_up_no       => in_seq_no,
                p_user            => in_user_id,
                p_job_name        => const_application_name,
                p_file_number     => NVL (v_file_number, 1),
                p_content_line    => const_out_line_header2_2,
                p_content_width   => v_page_width,
                p_content_align   => 'CENTER',   
                p_status          => v_status,
                p_comments        => v_comments);
        ELSE
            gz_report.p_put_line (p_one_up_no       => in_seq_no,
                                  p_user            => in_user_id,
                                  p_job_name        => const_application_name,
                                  p_file_number     => NVL (v_file_number, 1),
                                  p_content_line    => const_out_line_header2,
                                  p_content_width   => v_page_width,
                                  p_content_align   => 'CENTER', 
                                  p_status          => v_status,
                                  p_comments        => v_comments);
        END IF;


        gz_report.p_put_line (p_one_up_no       => in_seq_no,
                              p_user            => in_user_id,
                              p_job_name        => const_application_name,
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => v_environment_nm,
                              p_content_width   => v_page_width,
                              p_content_align   => 'CENTER', 
                              p_status          => v_status,
                              p_comments        => v_comments);



        gz_report.p_put_line (
            p_one_up_no =>
                in_seq_no,
            p_user =>
                in_user_id,
            p_job_name =>
                const_application_name,
            p_file_number =>
                NVL (v_file_number, 1),
            p_content_line =>
                '----------------------------------------------------------------------------------------------------------------------------------',
            p_content_width =>
                v_page_width,
            p_content_align =>
                'CENTER', 
            p_status =>
                v_status,
            p_comments =>
                v_comments);

    END p_create_header;

--     Crea estructura del Log TZPPFACT
    PROCEDURE p_create_header_2 (in_seq_no              NUMBER,
                                 in_user_id             VARCHAR2,
                                 p_file_number      OUT NUMBER,
                                 app_name        IN     VARCHAR2)
    IS
        const_package_name         CONSTANT VARCHAR2 (32) := 'TZKPUFC';
        inst_name                           VARCHAR2 (100);

        v_status                            VARCHAR2 (10);
        v_comments                          VARCHAR2 (20000);
        v_file_name                         guboutp.guboutp_file_name%TYPE;
        v_file_number                       guboutp.guboutp_file_number%TYPE;
        v_environment                       VARCHAR2 (25) := NULL;
        v_environment_nm                    VARCHAR2 (25);
        v_page_width                        NUMBER;
        v_page_break                        NUMBER;


        const_application_name     CONSTANT VARCHAR2 (32) := 'TZPPFAC';


        const_out_line_headerj     CONSTANT VARCHAR2 (230)
            :=    RPAD ('DATE RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'mm/dd/yyyy'), 43, ' ')
               || RPAD (inst_name, 58, ' ')
               || 'REPORT PAGE' ;

        const_out_line_header2_2   CONSTANT VARCHAR2 (230)
            :=    RPAD ('TIME RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'hh12:mi:ss AM'), 31, ' ')
               || RPAD ('Proceso Masivo de Generacion de Prefacturas',
                        70,
                        ' ')
               || RPAD ('PROGRAM ID TZPPFAC', 18, ' ') ;
    BEGIN
        DBMS_OUTPUT.enable (1000000);

        SELECT gubinst_name INTO inst_name FROM gubinst;


        SELECT SYS_CONTEXT ('USERENV', 'DB_NAME')
          INTO v_environment
          FROM DUAL;


        IF SUBSTR (v_environment, 1, 4) = 'PROD'
        THEN
            v_environment_nm := 'PRODUCTION INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'DEVL'
        THEN
            v_environment_nm := 'DEVELOPMENT INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'TEST'
        THEN
            v_environment_nm := 'TEST INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'QA'
        THEN
            v_environment_nm := 'QUALITY INSTANCE';
        ELSIF SUBSTR (v_environment, 1, 4) = 'TEMP'
        THEN
            v_environment_nm := 'TEMP INSTANCE';
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

        p_file_number := v_file_number;


        v_page_width :=
            gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

        v_page_break :=
            gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');


        gz_report.p_put_line (p_one_up_no       => in_seq_no,
                              p_user            => in_user_id,
                              p_job_name        => const_application_name,
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => CHR (12),
                              p_content_width   => v_page_width,
                              p_content_align   => 'CENTER', 
                              p_status          => v_status,
                              p_comments        => v_comments);

        gz_report.p_put_line (p_one_up_no       => in_seq_no,
                              p_user            => in_user_id,
                              p_job_name        => const_application_name,
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => const_out_line_headerj,
                              p_content_width   => v_page_width,
                              p_content_align   => 'CENTER', 
                              p_status          => v_status,
                              p_comments        => v_comments);


        gz_report.p_put_line (p_one_up_no       => in_seq_no,
                              p_user            => in_user_id,
                              p_job_name        => const_application_name,
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => const_out_line_header2_2,
                              p_content_width   => v_page_width,
                              p_content_align   => 'CENTER', 
                              p_status          => v_status,
                              p_comments        => v_comments);


        gz_report.p_put_line (p_one_up_no       => in_seq_no,
                              p_user            => in_user_id,
                              p_job_name        => const_application_name,
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => v_environment_nm,
                              p_content_width   => v_page_width,
                              p_content_align   => 'CENTER', 
                              p_status          => v_status,
                              p_comments        => v_comments);


        gz_report.p_put_line (
            p_one_up_no =>
                in_seq_no,
            p_user =>
                in_user_id,
            p_job_name =>
                const_application_name,
            p_file_number =>
                NVL (v_file_number, 1),
            p_content_line =>
                '----------------------------------------------------------------------------------------------------------------------------------',
            p_content_width =>
                v_page_width,
            p_content_align =>
                'CENTER',                    
            p_status =>
                v_status,
            p_comments =>
                v_comments);

    END p_create_header_2;

-- Procedimiento principal que gestiona la conectividad con los proveedores de pago en línea, obtiene los datos y 
-- genera la trama que se enviará, almacena la información para rastreo y obtiene la configuración para cada proveedor.
-- Utiliza UTL_HTTP de Oracle, Oracle Wallet, funcionalidad de JSON y consumo a los WS de P2P y Kushki.
--
PROCEDURE ws_p2p (p_pidm_oprd     NUMBER,
                      p_pidm          NUMBER,
                      p_sede          VARCHAR2,
                      p_sdoc_code     VARCHAR2,
                      p_doc_number    VARCHAR2,
                      p_term          VARCHAR2,
                       p_servicio varchar2,
                      p_iden_ws varchar2,
                      p_url_return varchar2 default null)
    IS
        p_locale          gtvsdax.gtvsdax_comments%TYPE;
        req               UTL_HTTP.req;
        res               UTL_HTTP.resp;

        name              VARCHAR2 (4000);
        buffer            clob;
        p_request         VARCHAR2 (4000);

        xseed             VARCHAR2 (200);
        nonce             VARCHAR2 (200);
        varnonce          VARCHAR2 (500);
        xsha1             RAW (20);
        p_trankeybase64   VARCHAR2 (500);

        v_name            VARCHAR2 (200);
        v_surname         VARCHAR2 (100);
        v_ssn             VARCHAR2 (100);
        v_email           VARCHAR2 (200);
        v_document_type   VARCHAR2 (4);
        v_mobile          VARCHAR2 (100);
        v_phone           VARCHAR2 (100);
        v_street_1        VARCHAR2 (500);
        v_city            spraddr.spraddr_city%TYPE;
        v_state           stvstat.stvstat_desc%TYPE;
        v_zip             spraddr.spraddr_zip%TYPE;
        v_natn            stvnatn.stvnatn_nation%TYPE;

        v_expiration      VARCHAR2 (200);
        v_reference       VARCHAR2 (200);
        v_description     VARCHAR2 (500);
        v_amount          NUMBER;
        --

        lc_reference      VARCHAR2 (100);
        lc_signature      VARCHAR2 (200);

        l_clob           CLOB;
        l_text           VARCHAR2(32767);

        lv_record_exists varchar2(1);
        lv_status varchar2(10);

        v_user_agent  VARCHAR2 (500);
          v_user_ip    VARCHAR2 (100);

       v_environment                     VARCHAR2 (25) := NULL;
       v_instance_ksk       varchar2(10):= 'false';


      cursor c_existe_request ( p_pidm number, p_pidm_oprd number, p_doc_number varchar2 ) is  
           select 'Y'
            from tzrpayu 
            where  TZRPAYU_PIDM = p_pidm                
              and TZRPAYU_DOC_NUMBER = p_doc_number
              and nvl(TZRPAYU_STATUS,'N') not in ('REJECTED','FAILED', 'DECLINED');

          v_exist_request varchar2(1):='N';    


        CURSOR c_get_name (p_pidm NUMBER)
        IS
            SELECT spriden_first_name || ' ' || spriden_mi
                       p_name,
                   replace(spriden_last_name, '/',' ') 
                       p_surname,
                   (SELECT spbpers_ssn
                      FROM spbpers
                     WHERE spbpers_pidm = spriden_pidm)
                       ci_doc_number,
                       (SELECT case SPBPERS_LGCY_CODE
                              when   '1' then
                              'CI'
                              when   '2' then
                              'PPN'
                              when   '4' then
                              'RUC'
                           else
                              'CI'
                           end  tipo_documento  
                      FROM spbpers, STVLGCY
                     WHERE spbpers_pidm = spriden_pidm
                         and SPBPERS_LGCY_CODE = STVLGCY_CODE) tipo_documento   
              FROM spriden
             WHERE spriden_change_ind IS NULL AND spriden_pidm = p_pidm;

                m_email_address       goremal.goremal_email_address%TYPE;


       CURSOR c_email_address
        IS
            SELECT goremal_email_address
              FROM goremal
             WHERE     goremal_pidm = p_pidm
                   AND goremal_emal_code = (  SELECT gtvsdax_external_code   FROM gtvsdax  WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code = 'EMAL_CODE')
                   AND goremal_status_ind = 'A';

      CURSOR c_email_address_sec
        IS
            SELECT goremal_email_address
              FROM goremal
             WHERE     goremal_pidm = p_pidm
                   AND goremal_emal_code = (  SELECT gtvsdax_external_code   FROM gtvsdax  WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code = 'EMAL_INST')
                   AND goremal_status_ind = 'A';


        CURSOR c_get_mobile (
            p_pidm    NUMBER)
        IS
            SELECT sprtele_phone_number
              FROM sprtele
             WHERE     sprtele_pidm = p_pidm
                   AND sprtele_tele_code =
                       (SELECT gtvsdax_external_code
                          FROM gtvsdax
                         WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
                               AND GTVSDAX_INTERNAL_CODE = 'CEL_CODE');

        CURSOR c_get_phone (
            p_pidm    NUMBER)
        IS
            SELECT    sprtele_phone_area
                   || sprtele_phone_number
                   || sprtele_phone_ext
              FROM sprtele
             WHERE     sprtele_pidm = p_pidm
                   AND sprtele_tele_code =
                       (SELECT gtvsdax_external_code
                          FROM gtvsdax
                         WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
                               AND GTVSDAX_INTERNAL_CODE = 'TEL_CODE');

        CURSOR c_get_addr (
            p_pidm    NUMBER)
        IS
            SELECT spraddr_street_line1 street,
                   spraddr_city         city,
                   stvstat_desc         state,
                   spraddr_zip          postalcode,
                   stvnatn_nation
              FROM spraddr, stvstat, stvnatn
             WHERE     spraddr_stat_code = stvstat_code(+)
                   AND spraddr_natn_code = stvnatn_code(+)
                   AND spraddr_pidm = p_pidm
                   AND spraddr_atyp_code =
                       (SELECT gtvsdax_external_code
                          FROM gtvsdax
                         WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
                               AND GTVSDAX_INTERNAL_CODE = 'ATYP_CODE')
                   AND spraddr_to_date IS NULL;

        CURSOR c_get_desc_pago (p_sdoc_code VARCHAR2)
        IS
            SELECT TVVSDOC_DESC
              FROM TVVSDOC
             WHERE TVVSDOC_CODE = p_sdoc_code;

        CURSOR c_amount   IS
        select TZRDPRF_DOC_AMOUNT from TZRDPRF where TZRDPRF_pidm = p_pidm and TZRDPRF_DOC_NUMBER = p_doc_number;

     cursor c_get_sdoc_type is
        select TZRDPRF_SDOC_CODE from TZRDPRF where TZRDPRF_pidm = p_pidm and TZRDPRF_DOC_NUMBER = p_doc_number;

   v_sdoc_type_redirect varchar2(10);
   v_rowid  varchar2(500);
    p_url_ret varchar2(1000);

    BEGIN

        OPEN c_get_credentials (p_pidm_oprd, p_sede, p_servicio);
        FETCH c_get_credentials INTO p_endpoint, p_trankey, p_login;
        CLOSE c_get_credentials;

        OPEN c_get_data_i ('PUCE_FACT', 'URL_RETURN', 'COM');
        FETCH c_get_data_i INTO p_url_ret;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'URL_RETALT', 'COM');
            FETCH c_get_data_i INTO p_url_close;
            CLOSE c_get_data_i;


        OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;


        OPEN c_get_sdoc_type;
        FETCH c_get_sdoc_type into v_sdoc_type_redirect;
        CLOSE c_get_sdoc_type;


        IF v_sdoc_type_redirect =  p_sdoc_pref and p_url_return is null  then 
               v_return_url := p_url_ret;
        ELSIF v_sdoc_type_redirect <>  p_sdoc_pref then 
               v_return_url := tzkpufc.f_get_url_pay(p_pidm,p_doc_number);               
        ELSIF v_sdoc_type_redirect =  p_sdoc_pref and p_url_return = 'R' then
              v_return_url := tzkpufc.f_get_url_pay(p_pidm,p_doc_number);
        ELSIF p_url_return = 'R' then             
             v_return_url := p_url_close;            
        END IF;

open  c_existe_request (p_pidm, p_pidm_oprd, p_doc_number);
      fetch c_existe_request into  v_exist_request;
      close c_existe_request;

       p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'REDIRECT v_exist_request:', v_exist_request ||' p_url_ret: ' ||p_url_ret ||' v_return_url: '||v_return_url, user);

      IF nvl(v_exist_request,'N') = 'Y' then     

        HTP.script ( 'window.location.href ="' || v_return_url || '";',  'Javascript');  

      ELSE 

   IF p_iden_ws = 'P2P' then

        BEGIN
            nonce := DBMS_RANDOM.string ('x', DBMS_RANDOM.VALUE (1, 32));

            xseed := TO_CHAR (SYSTIMESTAMP, 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM');

            varnonce :=
                UTL_RAW.cast_to_varchar2 (
                    UTL_ENCODE.base64_encode (UTL_RAW.cast_to_raw (nonce)));

            SELECT sys.DBMS_CRYPTO.hash (
                       UTL_RAW.cast_to_raw (nonce || xseed || p_trankey),
                       sys.DBMS_CRYPTO.hash_sh1)
              INTO xsha1
              FROM DUAL;

            p_trankeybase64 :=
                UTL_RAW.cast_to_varchar2 (UTL_ENCODE.base64_encode (xsha1));

        END;


        OPEN c_get_data_i ('PUCE_FACT', 'LOCALE', 'EXT');
        FETCH c_get_data_i INTO p_locale;
        CLOSE c_get_data_i;


        OPEN c_get_name (p_pidm);
        FETCH c_get_name INTO v_name, v_surname, v_ssn, v_document_type;
        CLOSE c_get_name;

                    OPEN c_email_address_sec;
                    FETCH c_email_address_sec INTO m_email_address;
                    CLOSE c_email_address_sec;

                IF m_email_address IS NULL   THEN
                    OPEN c_email_address;
                    FETCH c_email_address INTO m_email_address;
                    CLOSE c_email_address;                    
                END IF;


        OPEN c_get_mobile (p_pidm);
        FETCH c_get_mobile INTO v_mobile;
        CLOSE c_get_mobile;

        OPEN c_get_addr (p_pidm);
        FETCH c_get_addr
            INTO v_street_1,
                 v_city,
                 v_state,
                 v_zip,
                 v_natn;
        CLOSE c_get_addr;

        OPEN c_get_phone (p_pidm);
        FETCH c_get_phone INTO v_phone;
        CLOSE c_get_phone;

        OPEN c_get_moneda;
        FETCH c_get_moneda INTO v_moneda;
        CLOSE c_get_moneda;

        OPEN c_get_desc_pago (p_sdoc_code);
        FETCH c_get_desc_pago INTO v_description;
        CLOSE c_get_desc_pago;


        v_expiration :=
            TO_CHAR (SYSTIMESTAMP + INTERVAL '15' MINUTE,
                     'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM');        
        v_reference :=
               gb_common.f_get_id (p_pidm)
            || '_'
            || p_sede
            || '_'
            || p_sdoc_code
            || '_'
            || p_doc_number;


        OPEN c_amount;
        FETCH c_amount INTO v_amount;
        CLOSE c_amount;

        v_user_agent := owa_util.get_cgi_env('HTTP_USER_AGENT');
        v_user_ip := owa_util.get_cgi_env ('REMOTE_ADDR');

    begin
        p_request :=
               '
                {
                    "buyer": {
                        "name": "'
                            || CONVERT(v_name, 'US7ASCII')
                            || '",
                        "surname": "'
                            || CONVERT(v_surname, 'US7ASCII')
                            || '",
                        "email": "'
                            || m_email_address
                            || '",
                        "documentType": "'
                            || v_document_type
                            || '",
                        "document": "'
                            || v_ssn
                            || '",
                        "mobile": "'
                            || v_mobile
                            || '"
                    },
                "payment": {
                "reference": "'
                            || v_reference
                            || '",
                "description": "'
                            || v_reference
                            || '",
                "amount": {
                "currency": "'
                            || v_moneda
                            || '",
                "total": "'
                            || REPLACE (TO_CHAR (v_amount), ',', '.')
                            || '"
                 }
                },
                "expiration": "'
                            || v_expiration
                            || '",
                "returnUrl": "'
                            || v_return_url 
                            || '",
                "userAgent": "'
                            || v_user_agent 
                            || '",
                "ipAddress": "'
                            || v_user_ip
                            || '",
                   "paymentMethod":null,
                "auth": {
                    "login": "'
                            || p_login
                            || '",
                    "seed": "'
                            || xseed
                            || '",
                    "nonce": "'
                            || varnonce
                            || '",
                    "tranKey": "'
                            || p_trankeybase64
                            || '"
                    }
                }';
        exception when others then

            p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'P2P', 'EXCEPTION request: ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);
        end;

BEGIN
        BEGIN
            SELECT DISTINCT 'Y' into lv_record_exists 
                 FROM  tzrpayu             
                 where tzrpayu_pidm = p_pidm  
                     and  tzrpayu_sdoc_code = p_sdoc_code 
                     and  tzrpayu_doc_number = p_doc_number 
                     and  tzrpayu_campus = p_sede 
                     and  tzrpayu_term = p_term
                     and tzrpayu_servicio = p_servicio;

                     p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'P2P lv_record_exists:', lv_record_exists, user);

            EXCEPTION WHEN NO_DATA_FOUND THEN
                lv_record_exists := 'N'; 
        END;

        IF lv_record_exists <> 'Y' then
            insert into tzrpayu (tzrpayu_pidm_oprd, tzrpayu_pidm, tzrpayu_sdoc_code, tzrpayu_doc_number, tzrpayu_campus, tzrpayu_term,TZRPAYU_REFERENCE, tzrpayu_send_json, tzrpayu_activity_date, tzrpayu_user_id, tzrpayu_data_origin, tzrpayu_pay_date, tzrpayu_servicio)
            values (p_pidm_oprd, p_pidm, p_sdoc_code,p_doc_number, p_sede, p_term,v_reference, p_request, sysdate, user, 'TZKPUFC', sysdate, p_servicio);

            p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'P2P lv_record_exists:', lv_record_exists ||' p_doc_number: ' ||p_doc_number ||' v_reference: '||v_reference ||' p_servicio:'||p_servicio, user);

            standard.commit;
        END IF;    

        END;


        OPEN c_get_data_i ('PUCE_FACT', 'WALLET_DIR', 'COM');
        FETCH c_get_data_i INTO p_oracle_wallet_path;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'WALLET_PWD', 'EXT');
        FETCH c_get_data_i INTO p_oracle_wallet_pass;
        CLOSE c_get_data_i;
        --
       begin 
        UTL_HTTP.set_wallet ( p_oracle_wallet_path, p_oracle_wallet_pass);


        req := UTL_HTTP.begin_request (p_endpoint, 'POST', ' HTTP/1.1');      
        UTL_HTTP.set_header (req, 'content-type', 'application/json');
        UTL_HTTP.set_header (req, 'Content-Length', LENGTH (p_request));

        UTL_HTTP.write_text (req, p_request);
        res := UTL_HTTP.get_response (req);
        UTL_HTTP.read_text (res, buffer);

        exception when others then
            p_error_msg := 'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700);

            p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'P2P', 'EXCEPTION : ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);
        end;
        SELECT json_value (buffer, '$.status.status')
         INTO lv_status
         FROM DUAL;


        IF lv_status = 'OK' THEN  

              SELECT json_value (buffer, '$.processUrl'),
                          json_value (buffer, '$.status.status'),
                          json_value (buffer, '$.status.reason'),
                          json_value (buffer, '$.status.message'),
                          json_value (buffer, '$.status.date'),
                          json_value (buffer, '$.requestId')      
             INTO v_return_url, lc_status, lc_reason, lc_message, lc_date, lc_requestid
             FROM DUAL;

            update  tzrpayu
                   set 
                        tzrpayu_response_json = buffer,
                        tzrpayu_activity_date = sysdate, 
                        TZRPAYU_STATUS = lc_status, 
                        TZRPAYU_REASON = lc_reason, 
                        TZRPAYU_MESSAGE = 'La petición se encuenta en proceso, valide en unos minutos su estado.'                         
                        ,TZRPAYU_REQUEST_ID = lc_requestid 
            where tzrpayu_pidm = p_pidm 
                and  tzrpayu_sdoc_code = p_sdoc_code 
                and  tzrpayu_doc_number = p_doc_number 
                and  tzrpayu_campus = p_sede 
                and  tzrpayu_term = p_term
                and  tzrpayu_servicio = p_servicio                
            and not exists (select 'Y' from tzvoprd where TZVOPRD_PIDM = TZRPAYU_PIDM_OPRD and TZVOPRD_IDENTIFY_WS = 'KSK');

            p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'P2P Guarda Respuesta lv_status:', lv_status ||' lc_status: ' ||lc_status ||' lc_reason: '||lc_reason ||' sysdate:'||sysdate, user);

            standard.commit;           

          begin
           insert into taismgr.tzrpayh
            (
              TZRPAYH_PIDM, 
              TZRPAYH_SDOC_CODE, 
              TZRPAYH_DOC_NUMBER, 
              TZRPAYH_CAMPUS, 
              TZRPAYH_TERM, 
              TZRPAYH_STATUS,  
              TZRPAYH_MESSAGE, 
              TZRPAYH_REQUEST_ID, 
              TZRPAYH_REFERENCE, 
              TZRPAYH_activity_date
              , TZRPAYh_PIDM_OPRD
              , TZRPAYh_SERVICE
              ,TZRPAYh_TOTAL
              ,TZRPAYh_CURRENCY)
            values
            (p_pidm, p_sdoc_code , p_doc_number , p_sede , p_term, lc_status,  lc_message, lc_requestid , v_reference,  sysdate,  p_pidm_oprd, p_servicio, v_amount, v_moneda);
            standard.commit;           
            exception when others then null;
            end;

            HTP.script (
            'window.location.href ="' || v_return_url || '";',
            'Javascript');
		ELSE
            p_ins_tzrrlog(p_pidm,  'PagoOnLine', 'P2P Guarda Respuesta lv_status<>ok:', lv_status ||' lc_status: ' ||lc_status ||' lc_reason: '||lc_reason ||' sysdate:'||sysdate, user);
            p_ins_tzrrlog(p_pidm,  'PagoOnLine', 'P2P Guarda Respuesta lv_status<>ok:', lc_reason ||' lc_reason: ' ||lc_reason ||' sysdate:'||sysdate, user);

         END IF;

         ELSIF p_iden_ws = 'KSK' THEN

        OPEN c_get_moneda;
        FETCH c_get_moneda INTO v_moneda;
        CLOSE c_get_moneda;


       OPEN c_amount;
        FETCH c_amount INTO v_amount;
        CLOSE c_amount;

        bwckfrmt.p_open_doc ('tzkpufc.p_kushki_cajita');
        twbkfrmt.p_paragraph (1);
        twbkwbis.p_dispinfo ('tzkpufc.p_kushki_cajita', 'DEFAULT');

        htp.p('<script src="https://cdn.kushkipagos.com/kushki-checkout.js"></script>');

        htp.p('<div style=''width:50%; float:left ''> ');

        htp.p('<span style=''font-weight:bold; color:black; font-size:100%''>Total a Pagar <br></span>' ||v_moneda ||' $'||v_amount|| '<br><br>'||
                  '<span style=''font-weight:bold; color:black; font-size:100% ''>Referencia <br></span>' ||gb_common.f_get_id(p_pidm) ||'_'||p_sede||'_'|| p_sdoc_code||'_'||p_doc_number|| '<br><br>'||
                  '<span style=''font-weight:bold; color:black; font-size:100%''>Fecha <br></span>' ||to_char(sysdate,'YYYY-MM-DD HH24:MI:SS')
                  );

       htp.br; htp.br; htp.br;

         htp.p('<a href=" '||v_return_url||'">  Presione aquí para salir de esta ventana </a>');                    

        htp.p('</div>');


        p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'KUSHKI', 'Inicia Cajita ' , user);

        htp.p('<div style=''width:50%; float:right ''> ');

        p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'KUSHKI', 'INSERT TZRPAYU: ' ||lv_record_exists ||p_pidm ||' - '|| p_sdoc_code||' - '|| p_doc_number||' - '|| p_sede||' - '|| p_term||' - '|| p_pidm_oprd||' - '|| p_servicio, user);

        BEGIN
        BEGIN
            SELECT DISTINCT 'Y' into lv_record_exists FROM  tzrpayu             
                    where tzrpayu_pidm = p_pidm  and  tzrpayu_sdoc_code = p_sdoc_code and  tzrpayu_doc_number = p_doc_number and  tzrpayu_campus = p_sede and  tzrpayu_term = p_term                    
                     and  TZRPAYU_PIDM_OPRD = p_pidm_oprd and  TZRPAYU_SERVICIO= p_servicio;

            EXCEPTION WHEN NO_DATA_FOUND THEN
                                lv_record_exists := 'N'; 
                                WHEN OTHERS THEN
                                lv_record_exists := 'N'; 
        END;

        p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'KUSHKI', 'INSERT TZRPAYU' ||lv_record_exists, user);

        IF lv_record_exists <> 'Y' then

        v_reference :=
               gb_common.f_get_id (p_pidm)
            || '_'
            || p_sede
            || '_'
            || p_sdoc_code
            || '_'
            || p_doc_number;

            begin
            insert into tzrpayu (tzrpayu_pidm_oprd, tzrpayu_pidm, tzrpayu_sdoc_code, tzrpayu_doc_number, tzrpayu_campus, tzrpayu_term,TZRPAYU_REFERENCE, tzrpayu_send_json, tzrpayu_activity_date, tzrpayu_user_id, tzrpayu_data_origin, tzrpayu_pay_date, tzrpayu_servicio, tzrpayu_status)
            values (p_pidm_oprd, p_pidm, p_sdoc_code,p_doc_number, p_sede, p_term,v_reference, p_request, sysdate, user, 'TZKPUFC', sysdate, p_servicio, 'KUSHKI');
            gb_common.p_commit;
             exception when others then
         p_error_msg := 'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700);

        p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'P2P', 'EXCEPTION : ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);
            end;
        END IF;    

        END;

begin 
 SELECT rowid into v_rowid FROM  tzrpayu             
                    where tzrpayu_pidm = p_pidm  and  tzrpayu_sdoc_code = p_sdoc_code and  tzrpayu_doc_number = p_doc_number and  tzrpayu_campus = p_sede and  tzrpayu_term = p_term
                     and  TZRPAYU_PIDM_OPRD = p_pidm_oprd and  TZRPAYU_SERVICIO= p_servicio;

        p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'KUSHKI', 'rowid: ' ||v_rowid ||' - '|| p_sdoc_code ||' - '|| p_doc_number||' - '|| p_sede||' - '|| p_term||' - '|| p_servicio||' - '|| p_pidm_oprd, user);

exception when others then 
p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'KUSHKI', 'Error: ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);


end;

begin
SELECT SYS_CONTEXT ('USERENV', 'DB_NAME')
          INTO v_environment
          FROM DUAL;

IF upper(SUBSTR (v_environment, 1, 4)) = 'PROD' then
   v_instance_ksk := 'false'; -- ambiente productivo
ELSE
   v_instance_ksk := 'true'; -- ambiente TEST/QA/PPRD/otro
END IF;

exception when others then null;

end;


htp.p('                  
        <form id="kushki-pay-form" action="tzkpufc.p_kushki_trx" method="post">
            <input type="hidden" name="p_rowid" value="'||v_rowid||'">
            <input type="hidden" name="urlreturn" value="'||v_return_url||'">
            <input type="hidden" name="cart_id" value="124">
        </form>
        ');

p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'KUSHKI', 'Merchant_ID: ' ||p_login ||' - '|| v_amount ||' v_instance_ksk: ' ||v_instance_ksk, user);


htp.p('</div>');
        htp.p('
        <script type="text/javascript">
            var kushki = new KushkiCheckout({
                form: "kushki-pay-form",
                merchant_id: "'||p_login||'",
                amount: "'||REPLACE (TO_CHAR (v_amount), ',', '.') ||'",
                currency: "'||v_moneda||'",
                payment_methods:["credit-card"], // Payments Methods enabled
                is_subscription: false, // Optional
                inTestEnvironment: '||v_instance_ksk||', 
                regional:false // Optional
            });
        </script>
        ');

        twbkwbis.p_closedoc ();



    ELSE
          htp.p('<a href=" '||v_return_url||'"> Identificador de Proveedor no establecido en Identificación Adicional (SPAIDEN). Presione aquí para salir. </a>');                    

    END IF; --p_iden_ws   
    END IF; 
    END ws_p2p;

-- Procedimiento principal del proveedor de servicios Kushki. Pago en Línea.
-- Utiliza HTTP, JSON y WS Kushki.
-- Registra directamente el pago utilizando el proceso tzkrpay.p_register_payment, registra el pago en el estado de cuenta del estudiante.
--
procedure p_kushki_trx (p_rowid varchar2,  urlreturn varchar2 default null, cart_id varchar2 default null, kushkiToken varchar2  default null, kushkiPaymentMethod varchar2  default null, kushkiDeferredType varchar2  default null, kushkiDeferred varchar2  default null, kushkiMonthsOfGrace varchar2  default null)       
is
        req               UTL_HTTP.req;
        res               UTL_HTTP.resp;
        name              VARCHAR2 (4000);
        buffer            VARCHAR2 (4000);
        p_request         VARCHAR2 (4000);
        p_deferred     VARCHAR2 (1000);
        p_endpoint varchar(2000):='';
        p_ticketNumber VARCHAR2 (1000);
        p_transactionStatus VARCHAR2 (1000);
        p_responseText VARCHAR2 (1000);
        p_transactionId VARCHAR2 (1000); 
        p_paymentBrand VARCHAR2 (1000); 
        p_numberOfMonths VARCHAR2 (1000);

        cursor c_get_info_rowid (v_rowid varchar2) is
        select TZRPAYU_PIDM, TZRPAYU_SDOC_CODE, TZRPAYU_TERM, TZRPAYU_REFERENCE, TZRPAYU_DOC_NUMBER, TZRPAYU_PIDM_OPRD,TZRPAYU_CAMPUS, TZRPAYU_SERVICIO
        from tzrpayu where rowid = v_rowid;

        v_PIDM number(8); 
        v_SDOC_CODE varchar2(10);
        v_TERM varchar2(10); 
        v_REFERENCE varchar2(100); 
        v_amount number;
        v_moneda varchar2(10); 
        v_DOC_NUMBER varchar2(30); 
        v_operador varchar2(30); 
        v_campus varchar2(10); 
        v_servicio varchar2(100); 


CURSOR c_amount   (
            p_pidm         NUMBER,            
            p_doc_number  varchar2)
IS
        select TZRDPRF_DOC_AMOUNT from TZRDPRF where TZRDPRF_pidm = p_pidm and TZRDPRF_DOC_NUMBER = p_doc_number;


      cursor c_get_bank (p_pidm_oprd in number, p_camp_code in varchar2, p_servicio in varchar2 ) is
SELECT TZVOPRD_PAY_TYPE 
              FROM tzvoprd
             WHERE     tzvoprd_pidm = p_pidm_oprd
                   AND tzvoprd_camp_code = p_camp_code
                   AND TZVOPRD_SERV = p_servicio
                   AND TRUNC (SYSDATE) BETWEEN tzvoprd_start_date
                                           AND tzvoprd_end_date;

  v_pay_type  tzvoprd.tzvoprd_pay_type%type;

    p_result   varchar2(100);
    p_error    varchar2(1000);

    p_url       varchar2(1000);


  p_code   varchar2(100);
   p_message  varchar2(1000);


  p_autorization_code varchar2(100);
  p_paymentMethodName varchar2(100);
  p_issuerName varchar2(100); 
  p_receipt varchar2(100);

begin                   

p_ins_tzrrlog(0,  'PAGO_ONLINE', 'KUSHKI', 'lanza p_kushki_trx: ' ||p_rowid , user);

   IF p_rowid is not null then
         open c_get_info_rowid (p_rowid);
         fetch c_get_info_rowid into v_PIDM, v_SDOC_CODE, v_TERM, v_REFERENCE, v_DOC_NUMBER, v_operador, v_campus, v_servicio ;
         close c_get_info_rowid;

         p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'rowid_vals: ' ||v_PIDM ||' , '||v_SDOC_CODE ||' , '|| v_TERM ||' , '|| v_REFERENCE ||' , '|| v_DOC_NUMBER ||' , '|| v_operador ||' , '|| v_campus ||' , '|| v_servicio , user);

         open c_get_bank (v_operador, v_campus,v_servicio ) ;
         fetch c_get_bank into v_pay_type;
         close c_get_bank;

        OPEN c_get_credentials (v_operador, v_campus, v_servicio);
        FETCH c_get_credentials INTO p_endpoint, p_trankey, p_login;
        CLOSE c_get_credentials;

        OPEN c_get_moneda;
        FETCH c_get_moneda INTO v_moneda;
        CLOSE c_get_moneda;

        OPEN c_amount (v_PIDM,  v_DOC_NUMBER);
        FETCH c_amount INTO v_amount;
        CLOSE c_amount;

p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'p_endpoint: ' ||p_endpoint ||' -p_trankey:  '|| p_trankey||' -p_login:  '|| p_login||' -v_amount:  '|| v_amount || ' , '|| v_pay_type, user);
p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'p_kushki_trx, cart_id: ' ||cart_id ||' -kushkiToken:  '|| kushkiToken||' -kushkiPaymentMethod:  '|| kushkiPaymentMethod||' -kushkiDeferredType:  '|| kushkiDeferredType||' -kushkiDeferred:  '|| kushkiDeferred||' -kushkiMonthsOfGrace:  '|| kushkiMonthsOfGrace|| ' -p_rowid: ' ||p_rowid, user);

IF kushkiDeferredType is not null then
    p_deferred:= '
    "deferred": {
        "graceMonths": "'||nvl(kushkiMonthsOfGrace,'00')||'",
        "creditType": "'||kushkiDeferredType||'",
        "months": '||kushkiDeferred|| '
      },';
  END IF;


      p_request := '
      {
  "token": "'|| kushkiToken ||'",
  "amount": {
    "subtotalIva": 0,
    "subtotalIva0": '||REPLACE (TO_CHAR (v_amount), ',', '.')||',
    "ice": 0,
    "iva": 0,
    "currency": "'||v_moneda||'"
  },' ||p_deferred||'
  "metadata": {
    "contractID": "'||v_REFERENCE||'"
  },
  "fullResponse": true
}
      ';

p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'p_kushki_trx, p_request: ' ||p_request, user);


       req := UTL_HTTP.begin_request (p_endpoint, 'POST', ' HTTP/1.1');
        UTL_HTTP.set_header (req, 'Private-Merchant-Id', p_trankey);
        UTL_HTTP.set_header (req, 'content-type', 'application/json');
        UTL_HTTP.set_header (req, 'Content-Length', LENGTH (p_request));

        UTL_HTTP.write_text (req, p_request);
        res := UTL_HTTP.get_response (req);
        UTL_HTTP.read_text (res, buffer);

htp.p(buffer)  ;

p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'buffer: ' ||substr(buffer,1,2000), user);


              SELECT json_value (buffer, '$.ticketNumber'),
                          json_value (buffer, '$.details.transactionStatus'),
                          json_value (buffer, '$.details.responseText'),
                          json_value (buffer, '$.details.transactionId'),
                          json_value (buffer, '$.details.paymentBrand'),
                          json_value (buffer, '$.details.numberOfMonths')                        
                          , json_value (buffer, '$.code') 
                          , json_value (buffer, '$.message')
                          ,json_value (buffer, '$.details.approvalCode') 
                           ,json_value (buffer, '$.details.binInfo.type')  
                           ,json_value (buffer, '$.details.binInfo.bank')   
                           ,json_value (buffer, '$.ticketNumber') 
             INTO p_ticketNumber,  p_transactionStatus,  p_responseText, p_transactionId, p_paymentBrand, p_numberOfMonths, p_code, p_message, p_autorization_code, p_paymentMethodName, p_issuerName,  p_receipt
             FROM DUAL;


             p_paymentBrand := REPLACE(UPPER(p_paymentBrand),' ','');
             p_numberOfMonths := nvl(p_numberOfMonths,1);


        begin
            update  tzrpayu
                   set 
                        tzrpayu_response_json = buffer,
                        tzrpayu_activity_date = sysdate, 
                        TZRPAYU_STATUS = p_transactionStatus, 
                        TZRPAYU_MESSAGE = nvl(p_responseText,p_code||'-'|| p_message), 
                        TZRPAYU_DATE = sysdate,
                        TZRPAYU_REQUEST_ID = p_ticketNumber,                        
                        TZRPAYU_FRANCHISE = p_paymentBrand, 
                        TZRPAYU_INSTALLMENTS = p_numberOfMonths,
                        TZRPAYU_REASON = p_transactionId,
                        tzrpayu_send_json = p_request
               where rowid =  p_rowid;        
        exception when others then 
        p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'EXCEPTION: ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);
        end;

p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'p_kushki_trx, Buffer de regreso: ' ||buffer, user);


IF p_ticketNumber is not null then

 OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
        FETCH c_get_data_i INTO p_user_create;
        CLOSE c_get_data_i;


BEGIN
                         tzkrpay.p_register_payment (
                            p_bank_code        => v_pay_type,
                            p_doc_number     => f_get_docnum_fmt(v_DOC_NUMBER),
                            p_total_amount    => v_amount,
                            p_payment_date   => sysdate, 
                            p_payment_hour   => null,
                            p_pay_type           => p_numberOfMonths, 
                            p_cash_amount          => NULL,
                            p_chk_amount           => NULL,
                            p_card_amount          => v_amount,
                            p_invoice_number     => NULL,
                            p_status                    => 'ACEPTADO',
                            p_agency_code          => NULL,
                            p_card_number          => p_paymentBrand, 
                            p_pay_method           => NULL,
                            p_card_type               => NULL,
                            p_pay_deferred          => NULL,
                            p_internal_reference   => NULL, 
                            p_receipt_number     => NULL,
                            p_auth_number         => NULL,
                            p_pay_comments       => NULL,
                            p_user_id                  => p_user_create,
                            p_result                  => p_result,
                            p_error                   => p_error);


          begin
          update tzrpayu set TZRPAYU_PROCESSED_IND = 'Y', TZRPAYU_PAYMENT_ERROR_MSG = substr(p_error||p_result,1,1000)
           where rowid =  p_rowid;        

           exception when others then
           p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'EXCEPTION UPD TZRPAYU: ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);
        end;

   exception when others then
         p_error_msg := 'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700);

        p_ins_tzrrlog(v_PIDM,  'PAGO_ONLINE', 'KUSHKI', 'EXCEPTION Register Payment: ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);


   END;                            

end if; 


begin

           insert into taismgr.tzrpayh
            (
              TZRPAYH_PIDM, 
              TZRPAYH_SDOC_CODE, 
              TZRPAYH_DOC_NUMBER, 
              TZRPAYH_CAMPUS, 
              TZRPAYH_TERM, 
              TZRPAYH_STATUS,  
              TZRPAYH_MESSAGE, 
              TZRPAYH_REQUEST_ID, 
              TZRPAYH_REFERENCE, 
              TZRPAYH_activity_date,
              tzrpayh_PIDM_OPRD,
              TZRPAYh_SERVICE,
              TZRPAYh_PAY_DATE,
              TZRPAYh_TOTAL,
              TZRPAYh_CURRENCY,              
              TZRPAYh_autorization_code,
                TZRPAYh_payment_Method_Name,
                TZRPAYh_issuer_Name,
                TZRPAYh_receipt,
                TZRPAYh_group)
              select TZRPAYU_PIDM, 
              TZRPAYU_SDOC_CODE, 
              TZRPAYU_DOC_NUMBER, 
              TZRPAYU_CAMPUS, 
              TZRPAYU_TERM, 
              TZRPAYU_STATUS,  
              TZRPAYU_MESSAGE, 
              TZRPAYU_REQUEST_ID, 
              TZRPAYU_REFERENCE, 
              sysdate ,
              tzrpayu_PIDM_OPRD,
              TZRPAYU_SERVICIO,
              TZRPAYu_PAY_DATE,
              v_amount,
              v_moneda,
              p_autorization_code, p_paymentMethodName, p_issuerName,  p_receipt, null
              from tzrpayu
              where rowid = p_rowid;

            standard.commit;           
            exception when others then null;
            end;

end if; 

            HTP.script (
            'window.location.href = "' || urlreturn || '";',
            'Javascript');

end;

-- Procedimiento utilizado para place to pay para obtener la franquicia e installments
-- consume WS de P2P
   PROCEDURE getRequestInformation ( p_pidm_oprd number,
                      p_pidm          NUMBER,
                      p_sede varchar, 
                      lc_request_id number,
                      p_servicio varchar2,
                      p_response_out out  clob 
                      )
    IS
        req               UTL_HTTP.req;
        res               UTL_HTTP.resp;
        name              VARCHAR2 (4000);
        buffer            clob;
        p_request         VARCHAR2 (4000);

        xseed             VARCHAR2 (200);
        nonce             VARCHAR2 (200);
        varnonce          VARCHAR2 (500);
        xsha1             RAW (20);
        p_trankeybase64   VARCHAR2 (500);

        lc_message        VARCHAR2 (500);

        lv_record_exists varchar2(1);
        lv_status varchar2(10);

    BEGIN
        OPEN c_get_credentials (p_pidm_oprd, p_sede, p_servicio);
        FETCH c_get_credentials INTO p_endpoint, p_trankey, p_login;
        CLOSE c_get_credentials;

        BEGIN
            nonce := DBMS_RANDOM.string ('x', DBMS_RANDOM.VALUE (1, 32));
            xseed := TO_CHAR (SYSTIMESTAMP, 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM');
            varnonce :=
                UTL_RAW.cast_to_varchar2 (
                    UTL_ENCODE.base64_encode (UTL_RAW.cast_to_raw (nonce)));

            SELECT sys.DBMS_CRYPTO.hash (
                       UTL_RAW.cast_to_raw (nonce || xseed || p_trankey),
                       sys.DBMS_CRYPTO.hash_sh1)
              INTO xsha1
              FROM DUAL;
            p_trankeybase64 :=
                UTL_RAW.cast_to_varchar2 (UTL_ENCODE.base64_encode (xsha1));
        END;

        p_request :=
               '
                {
                "auth": {
                    "login": "'
                            || p_login
                            || '",
                    "tranKey": "'
                            || p_trankeybase64
                            || '",
                    "nonce": "'
                            || varnonce
                            || '",                            
                    "seed": "'
                            || xseed
                            || '"
                    }
                }';


        OPEN c_get_data_i ('PUCE_FACT', 'WALLET_DIR', 'COM');
        FETCH c_get_data_i INTO p_oracle_wallet_path;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'WALLET_PWD', 'EXT');
        FETCH c_get_data_i INTO p_oracle_wallet_pass;
        CLOSE c_get_data_i;

        UTL_HTTP.set_wallet ( p_oracle_wallet_path, p_oracle_wallet_pass);


        req := UTL_HTTP.begin_request (p_endpoint||'/'||lc_request_id, 'POST', ' HTTP/1.1');
        UTL_HTTP.set_header (req, 'content-type', 'application/json');
        UTL_HTTP.set_header (req, 'Content-Length', LENGTH (p_request));

        UTL_HTTP.write_text (req, p_request);
        res := UTL_HTTP.get_response (req);
        UTL_HTTP.read_text (res, buffer);

        p_response_out := buffer;
        utl_http.end_response(res);

   exception when others then
         p_error_msg := 'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700);

        p_ins_tzrrlog(0,  'PAGO_ONLINE', 'p29', 'EXCEPTION Register Payment: ' ||SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700), user);


    END;

-- Procedimiento que obtiene el folio siguiente del documento de venta.
--
    PROCEDURE p_get_next_folio (
        p_doctype         IN     tvrsdsq.tvrsdsq_sdoc_code%TYPE,
        p_user            IN     VARCHAR2,
        p_camp_code       IN     tvrsdsq.tvrsdsq_camp_code%TYPE,
        p_prefix1         IN     tvrsdsq.tvrsdsq_prefix_1%TYPE,
        p_prefix2         IN     tvrsdsq.tvrsdsq_prefix_2%TYPE,
        p_next_numdoc     IN OUT tvrsdsq.tvrsdsq_max_seq%TYPE,
        p_camp_district   IN OUT stvcamp.stvcamp_dicd_code%TYPE,
        p_seq             IN OUT tvrsdsq.tvrsdsq_seq_num%TYPE,
        p_errormsg        IN OUT VARCHAR2)
    IS
        lv_seq          tvrsdsq.tvrsdsq_seq_num%TYPE;
        lv_prefix1      tvrsdsq.tvrsdsq_prefix_1%TYPE;
        lv_prefix2      tvrsdsq.tvrsdsq_prefix_2%TYPE;
        lv_docnum       tvrsdsq.tvrsdsq_max_seq%TYPE; 
        lv_ini          tvrsdsq.tvrsdsq_init_seq%TYPE;
        lv_end          tvrsdsq.tvrsdsq_final_seq%TYPE;
        lv_date_until   tvrsdsq.tvrsdsq_valid_until%TYPE;
        lv_exist        VARCHAR2 (1) := 'Y';

        CURSOR get_record_tvrsdsq_c
        IS
            SELECT tvrsdsq_seq_num,
                   (SELECT stvcamp_dicd_code
                      FROM stvcamp
                     WHERE stvcamp_code = tvrsdsq_camp_code)
                       p_district,
                   tvrsdsq_prefix_1,
                   tvrsdsq_prefix_2,
                   tvrsdsq_max_seq,
                   tvrsdsq_init_seq,
                   tvrsdsq_final_seq,
                   tvrsdsq_valid_until
              FROM tvrsdsq, gorfbpr
             WHERE     tvrsdsq_sdoc_code = p_doctype
                   AND tvrsdsq_fbpr_code = gorfbpr_fbpr_code 
                   AND gorfbpr_fgac_user_id = p_user
                   AND tvrsdsq_valid_until >= SYSDATE
                   AND tvrsdsq_prefix_1 = NVL (p_prefix1, tvrsdsq_prefix_1)
                   AND tvrsdsq_prefix_2 = NVL (p_prefix2, tvrsdsq_prefix_2)
                   AND tvrsdsq_camp_code =
                       NVL (p_camp_code, tvrsdsq_camp_code);
    BEGIN

          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago netx folio: ', ' p_doctype ' ||p_doctype,user);
	      p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago netx folio: ', ' p_user ' ||p_user,user);
          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago netx folio: ', ' p_prefix1 ' ||p_prefix1,user);
          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago netx folio: ', ' p_prefix2 ' ||p_prefix2,user);
          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago netx folio: ', ' p_camp_code ' ||p_camp_code,user);
          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago: ', ' p_camp_district ' ||p_camp_district,user);


	DBMS_LOCK.Sleep(2);
          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_get_next_folio: ', ' Sleep(2) Espera para obtener siguiente folio ' ||sysdate,user);

        OPEN get_record_tvrsdsq_c;

        FETCH get_record_tvrsdsq_c
            INTO lv_seq,
                 p_camp_district,
                 lv_prefix1,
                 lv_prefix2,
                 lv_docnum,
                 lv_ini,
                 lv_end,
                 lv_date_until;					   
          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago netx folio: ', ' lv_prefix1 ' ||lv_prefix1,user);
          p_ins_tzrrlog(0,  'COMPROBANTE', 'p_gen_comprobante_pago netx folio: ', ' lv_prefix2 ' ||lv_prefix2,user);

        IF get_record_tvrsdsq_c%NOTFOUND
        THEN
            p_errormsg :=
                g$_nls.get (
                    'TVKRLI1-0015',
                    'SQL',
                    'There is not folio numbers configured. Please go to TVASDSQ form');
            p_next_numdoc := NULL;
            RETURN;
        END IF;

        IF p_camp_district IS NULL
        THEN
            p_errormsg :=
                g$_nls.get (
                    'TZKPUFC-0001',
                    'SQL',
                    'There is not campus related with ID District. Please go to STVCAMP form');
            p_next_numdoc := NULL;
            RETURN;
        END IF;

        IF lv_prefix1 IS NULL
        THEN
            p_errormsg :=
                g$_nls.get (
                    'TZKPUFC-0001',
                    'SQL',
                    'There is not prefix related with Prefix1. Please go to TVASDSQ form');
            p_next_numdoc := NULL;
            RETURN;
        END IF;

        IF lv_prefix2 IS NULL
        THEN
            p_errormsg :=
                g$_nls.get (
                    'TZKPUFC-0001',
                    'SQL',
                    'There is not prefix related with Prefix2. Please go to TVASDSQ form');
            p_next_numdoc := NULL;
            RETURN;
        END IF;

        CLOSE get_record_tvrsdsq_c;


       IF lv_ini > 1 and lv_docnum = 0 then
         p_next_numdoc := lv_ini + 1;
         p_seq := lv_seq;
       ELSE
        p_next_numdoc := lv_docnum + 1;
        p_seq := lv_seq;
       END IF; 
        p_errormsg := NULL;
    END p_get_next_folio;

-- Procedimiento que actualiza la secuencia del documento de venta en las tablas nativas de Banner.
--
    PROCEDURE p_update_secuencia (
        p_doctype     IN     tvrsdsq.tvrsdsq_sdoc_code%TYPE,
        p_user        IN     VARCHAR2,
        p_prefix1     IN     VARCHAR2,
        p_prefix2     IN     VARCHAR2,
        p_camp_code   IN     VARCHAR2,
        p_secuencia   IN     NUMBER,
        p_error          OUT VARCHAR2)
    IS PRAGMA autonomous_transaction;
    BEGIN
	--DBMS_LOCK.Sleep(1);    
        UPDATE tvrsdsq
           SET tvrsdsq_max_seq = p_secuencia,
               TVRSDSQ_ACTIVITY_DATE = SYSDATE,
               TVRSDSQ_DATA_ORIGIN = 'TZKPUFC',
               TVRSDSQ_USER_ID = USER
         WHERE     tvrsdsq_sdoc_code = p_doctype
               AND tvrsdsq_fbpr_code IN
                       (SELECT gorfbpr_fbpr_code
                          FROM gorfbpr
                         WHERE gorfbpr_fgac_user_id = p_user)
               AND tvrsdsq_valid_until >= SYSDATE
               AND tvrsdsq_prefix_1 = p_prefix1
               AND tvrsdsq_prefix_2 = p_prefix2
               AND tvrsdsq_camp_code = p_camp_code;
    --commit;
    gb_common.p_commit;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_error := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
        WHEN OTHERS
        THEN
            p_error := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
    END;

-- Funcion que valida si el documento es válido compara las fechas en las tablas de configuracion TZARVEN
function f_get_valid_document (p_pidm        IN NUMBER,
                                   p_term        IN VARCHAR2,
                                   p_campus      IN VARCHAR2,
                                   p_sdoc_code   IN VARCHAR2,
                                   p_crn in varchar2 default null) return varchar2
is                                   

v_valid varchar2(100);
fecha_fin varchar2(100);


v_program   varchar2(100);
v_levl          varchar2(100);
v_chrt          varchar2(100):= '';


cursor c_regs is
SELECT  TZRFVEN_PROGRAM_CODE , TZRFVEN_LEVL_CODE , TZRFVEN_CHRT_CODE , TZRFVEN_CRN 
            , tzrfven_start_date , tzrfven_end_date 
              FROM tzrfven
                  WHERE  tzrfven_term_code = p_term
                   AND tzrfven_sdoc_code = p_sdoc_code
                   AND tzrfven_camp_code = p_campus
                   AND (   (    tzrfven_program_code IS NOT NULL
                                      AND tzrfven_program_code = v_program
                                      )
                                  OR tzrfven_program_code IS NULL)
                   AND (   (    tzrfven_levl_code IS NOT NULL
                                      AND tzrfven_levl_code = v_levl 
                                      )
                                  OR tzrfven_levl_code IS NULL)
                   AND (   (    tzrfven_chrt_code IS NOT NULL
                                      AND tzrfven_chrt_code = v_chrt
                                      )
                                  OR tzrfven_chrt_code IS NULL)
                   AND (   (    TZRFVEN_CRN IS NOT NULL
                                      AND TZRFVEN_CRN = p_crn
                                      )
                                  OR TZRFVEN_CRN IS NULL);




j number:=0;
k number:=0;
v_last number:=0;
v_ant number:=0;


cursor c_get_chrt is 
select   max(pr.SGRCHRT_CHRT_CODE)
from  sgrchrt pr
where pr.SGRCHRT_PIDM = p_pidm
and pr.SGRCHRT_STSP_KEY_SEQUENCE = (select max(SFRSTCR_STSP_KEY_SEQUENCE) from SFRSTCR where SFRSTCR_PIDM = p_pidm  and SFRSTCR_TERM_CODE =  p_term)
and pr.sgrchrt_term_code_eff = (select max (sc.sgrchrt_term_code_eff) from sgrchrt sc where sc.SGRCHRT_PIDM = p_pidm and sc.sgrchrt_term_code_eff <= p_term)
and pr.SGRCHRT_CHRT_CODE is not null;


p_valid_1 varchar2(1);

begin


v_program := tzkpufc.f_get_sovlcur(p_pidm, p_term, 'PROGRAM' );
v_levl := tzkpufc.f_get_sovlcur(p_pidm, p_term, 'LEVL' );

open c_get_chrt;
fetch c_get_chrt into v_chrt;
close c_get_chrt;


for i in c_regs loop


if i.TZRFVEN_PROGRAM_CODE is null and i.TZRFVEN_LEVL_CODE is null and i.TZRFVEN_CHRT_CODE is null and i.TZRFVEN_CRN is null  then
  j := 1;
  fecha_fin := to_char(i.tzrfven_end_date, 'DD/MON/YYYY');

  if trunc(sysdate) between trunc(i.tzrfven_start_date) and  trunc(i.tzrfven_end_date) then
        p_valid_1 :=  'Y';
   else
        p_valid_1 := 'N';     
   end if;


elsif  i.TZRFVEN_PROGRAM_CODE = v_program then 
 k := k +1;

elsif i.TZRFVEN_LEVL_CODE = v_levl then
 k := k +1;

 elsif i.TZRFVEN_CHRT_CODE = v_chrt then
 k := k +1;

 elsif i.TZRFVEN_CRN = p_crn then
 k := k +1;

 else
 k := 0;

 end if;

v_ant := v_ant +  k;


if v_ant > v_last then
   v_last := v_ant;
   if trunc(sysdate) between trunc(i.tzrfven_start_date) and  trunc(i.tzrfven_end_date) then
        v_valid := 'Y' ;     
   else
        v_valid := 'N';     
   end if;
end if;


v_ant := 0;
k := 0;
end loop;

IF v_last = 0 and j = 0 then
     v_valid := 'N';     

elsif v_last = 0 and j > 0 then
     v_valid := p_valid_1;     

end if;


return v_valid;

end;

-- -- Funcion que compara los numeros de transaccion que conforman un documento.
--
    FUNCTION f_get_acum_str (cadena IN VARCHAR2)
        RETURN NUMBER
    IS
        vare     VARCHAR2 (10);
        p_cnt    NUMBER;
        p_acum   NUMBER := 0;
    BEGIN
        IF cadena IS NOT NULL
        THEN
            FOR x IN 1 .. LENGTH (cadena)
            LOOP
                vare := SUBSTR (cadena, x, 1);
                p_cnt := ASCII (vare);

                p_acum := p_acum + p_cnt;
            END LOOP;

            RETURN (p_acum);
        ELSE
            RETURN (-8);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN (-99);
        WHEN OTHERS
        THEN
            RETURN (-99);
    END;


--Funcion que retorna el formato de la prefactura presentada al usuario/estudiante.
-- Almacenada en la tabla TZRFACT como TZRFACT_SALE_DOCNUM
-- 
    FUNCTION f_get_docnum_fmt (p_doc_num IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_docnum   VARCHAR2 (100);
    BEGIN
        v_docnum :=
               SUBSTR (p_doc_num, 1, 7)
            || LPAD (SUBSTR (p_doc_num, 8, LENGTH (p_doc_num)), 6, '0');

        RETURN v_docnum;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

-- Funcion que valida la fecha configurada en TZARVEN para los documentos de venta.
-- De acuerdo al periodo, campus, tipo de documento, programa, nivel, cohorte del estudiante.
--  
function f_get_due_date (p_pidm        IN NUMBER,
                                   p_term        IN VARCHAR2,
                                   p_campus      IN VARCHAR2,
                                   p_sdoc_code   IN VARCHAR2,
                                   p_crn in varchar2 default null) return date
is                                   

v_valid date;
fecha_fin date;


v_program   varchar2(100);
v_levl          varchar2(100);
v_crn           varchar2(100);
v_chrt          varchar2(100):= '';


cursor c_regs is
SELECT  TZRFVEN_PROGRAM_CODE , TZRFVEN_LEVL_CODE , TZRFVEN_CHRT_CODE , TZRFVEN_CRN 
            , tzrfven_start_date , tzrfven_end_date 
              FROM tzrfven
                  WHERE  tzrfven_term_code = p_term
                   AND tzrfven_sdoc_code = p_sdoc_code
                   AND tzrfven_camp_code = p_campus
                   AND (   (    tzrfven_program_code IS NOT NULL
                                      AND tzrfven_program_code = v_program
                                      )
                                  OR tzrfven_program_code IS NULL)
                   AND (   (    tzrfven_levl_code IS NOT NULL
                                      AND tzrfven_levl_code = v_levl 
                                      )
                                  OR tzrfven_levl_code IS NULL)
                   AND (   (    tzrfven_chrt_code IS NOT NULL
                                      AND tzrfven_chrt_code = v_chrt
                                      )
                                  OR tzrfven_chrt_code IS NULL)
                   AND (   (    TZRFVEN_CRN IS NOT NULL
                                      AND TZRFVEN_CRN = p_crn
                                      )
                                  OR TZRFVEN_CRN IS NULL);

j number:=0;
k number:=0;
v_last number:=0;
v_ant number:=0;


cursor c_get_chrt is 
select   max(pr.SGRCHRT_CHRT_CODE)
from  sgrchrt pr
where pr.SGRCHRT_PIDM = p_pidm
and pr.SGRCHRT_STSP_KEY_SEQUENCE = (select max(SFRSTCR_STSP_KEY_SEQUENCE) from SFRSTCR where SFRSTCR_PIDM = p_pidm  and SFRSTCR_TERM_CODE =  p_term)
and pr.sgrchrt_term_code_eff = (select max (sc.sgrchrt_term_code_eff) from sgrchrt sc where sc.SGRCHRT_PIDM = p_pidm and sc.sgrchrt_term_code_eff <= p_term)
and pr.SGRCHRT_CHRT_CODE is not null;

p_valid_1 varchar2(1);

begin


v_program := tzkpufc.f_get_sovlcur(p_pidm, p_term, 'PROGRAM' );
v_levl := tzkpufc.f_get_sovlcur(p_pidm, p_term, 'LEVL' );

open c_get_chrt;
fetch c_get_chrt into v_chrt;
close c_get_chrt;


for i in c_regs loop

if i.TZRFVEN_PROGRAM_CODE is null and i.TZRFVEN_LEVL_CODE is null and i.TZRFVEN_CHRT_CODE is null and i.TZRFVEN_CRN is null  then
  j := 1;

  if trunc(sysdate) between trunc(i.tzrfven_start_date) and  trunc(i.tzrfven_end_date) then
        p_valid_1 :=  'Y';
        fecha_fin := i.tzrfven_end_date;
   else
        p_valid_1 := 'N';     
   end if;


elsif  i.TZRFVEN_PROGRAM_CODE = v_program then 
 k := k +1;

elsif i.TZRFVEN_LEVL_CODE = v_levl then
 k := k +1;

 elsif i.TZRFVEN_CHRT_CODE = v_chrt then
 k := k +1;

 elsif i.TZRFVEN_CRN = p_crn then
 k := k +1;

 else
 k := 0;

 end if;

v_ant := v_ant +  k;


if v_ant > v_last then
   v_last := v_ant;

   if trunc(sysdate) between trunc(i.tzrfven_start_date) and  trunc(i.tzrfven_end_date) then
        v_valid := i.tzrfven_end_date ;     

   else
        v_valid := '';     

   end if;
end if;

v_ant := 0;
k := 0;
end loop;

IF v_last = 0 and j = 0 then
     v_valid := '';     
elsif v_last = 0 and j > 0 then
     v_valid := fecha_fin;     
end if;


return v_valid;

end;


-- Procedimiento que inserta la información de la prefactura generada en la tabla principal de bancos.
-- 
    PROCEDURE p_insert_tzrdprf (t_pidm               NUMBER,
                                t_sdoc_code          VARCHAR2,
                                t_doc_number         VARCHAR2,
                                t_camp_code          VARCHAR2,
                                t_term_code          VARCHAR2,
                                t_doc_status         VARCHAR2,
                                t_doc_comments       VARCHAR2,
                                t_doc_date           DATE,
                                t_due_doc_date       DATE,
                                t_pref_doc_number    VARCHAR2,
                                t_doc_amount         NUMBER,
                                t_iden_type          VARCHAR2,
                                t_iden_number        VARCHAR2 
                                                             ,
                                t_pay_amount         NUMBER 
                                                           ,
                                t_user_id            VARCHAR2,
                                t_data_origin        VARCHAR2)
    IS
    BEGIN
        INSERT INTO taismgr.tzrdprf (tzrdprf_pidm,
                                     tzrdprf_sdoc_code,
                                     tzrdprf_doc_number,
                                     tzrdprf_camp_code,
                                     tzrdprf_term_code,
                                     tzrdprf_doc_status,
                                     tzrdprf_doc_comments,
                                     tzrdprf_doc_date,
                                     tzrdprf_due_doc_date,
                                     tzrdprf_pref_doc_number,
                                     tzrdprf_doc_amount,
                                     tzrdprf_iden_type,
                                     tzrdprf_iden_number,
                                     tzrdprf_user_id,
                                     tzrdprf_data_origin,
                                     tzrdprf_activity_date)
             VALUES (t_pidm,
                     t_sdoc_code,
                     t_doc_number,
                     t_camp_code,
                     t_term_code,
                     t_doc_status,
                     t_doc_comments,
                     t_doc_date,
                     t_due_doc_date,
                     t_pref_doc_number,
                     t_doc_amount,
                     t_iden_type,
                     t_iden_number 
                     ,
                     t_user_id,
                     t_data_origin,
                     SYSDATE);

    EXCEPTION
        WHEN OTHERS
        THEN
            p_ins_tzrrlog(t_pidm,  'GENERA_PREFACTURA', 'INS_TZRDPRF', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);
    END;

-- Fucion que obtiene la cédula, pasaporte o RUC del estudiante.
    FUNCTION f_get_iden (p_pidm    NUMBER,
                         p_type    VARCHAR2 DEFAULT NULL,
                         p_sri     VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        p_cedula      VARCHAR2 (100);
        p_pasaporte   VARCHAR2 (100);
        p_ruc         VARCHAR2 (100);
        p_adid_code   VARCHAR2 (10);

        CURSOR c_get_cedula (p_pidm NUMBER)
        IS
            SELECT spbpers_ssn cedula
              FROM spbpers
             WHERE spbpers_pidm = p_pidm;

        CURSOR c_get_pasaporte (p_pidm NUMBER)
        IS
            SELECT gobintl_passport_id pasaporte
              FROM gobintl
             WHERE gobintl_pidm = p_pidm;

        CURSOR c_get_goradid (
            p_pidm         NUMBER,
            p_adid_code    VARCHAR2)
        IS
            SELECT x.goradid_additional_id
              FROM goradid x
             WHERE     x.goradid_pidm = p_pidm
                   AND x.goradid_adid_code = p_adid_code
                   AND x.goradid_activity_date =
                       (SELECT MAX (y.goradid_activity_date)
                          FROM goradid y
                         WHERE     y.goradid_pidm = x.goradid_pidm
                               AND y.goradid_adid_code = x.goradid_adid_code);
    BEGIN
        OPEN c_get_cedula (p_pidm);
        FETCH c_get_cedula INTO p_cedula;
        CLOSE c_get_cedula;

        OPEN c_get_pasaporte (p_pidm);
        FETCH c_get_pasaporte INTO p_pasaporte;
        CLOSE c_get_pasaporte;

        OPEN c_get_data_i ('PUCE_FACT', 'RUC_CODE', 'EXT');
        FETCH c_get_data_i INTO p_adid_code;
        CLOSE c_get_data_i;

        OPEN c_get_goradid (p_pidm, p_adid_code);
        FETCH c_get_goradid INTO p_ruc;
        CLOSE c_get_goradid;

        IF p_type = 'CEDULA' AND p_sri IS NULL
        THEN
            RETURN p_cedula;
        ELSIF p_type = 'CEDULA' AND p_sri IS NOT NULL
        THEN
            RETURN 'C';
        ELSIF p_type = 'PASAPORTE' AND p_sri IS NULL
        THEN
            RETURN p_pasaporte;
        ELSIF p_type = 'PASAPORTE' AND p_sri IS NOT NULL
        THEN
            RETURN 'P';
        ELSIF p_type = 'RUC' AND p_sri IS NULL
        THEN
            RETURN p_ruc;
        ELSIF p_type = 'RUC' AND p_sri IS NOT NULL
        THEN
            RETURN 'R';
        ELSIF p_type IS NULL AND p_sri IS NULL
        THEN
            IF p_cedula IS NOT NULL
            THEN
                RETURN p_cedula;
            ELSIF p_pasaporte IS NOT NULL
            THEN
                RETURN p_pasaporte;
            ELSIF p_ruc IS NOT NULL
            THEN
                RETURN p_ruc;
            END IF;
        ELSIF p_type IS NULL AND p_sri IS NOT NULL
        THEN
            IF p_cedula IS NOT NULL
            THEN
                RETURN 'C';
            ELSIF p_pasaporte IS NOT NULL
            THEN
                RETURN 'P';
            ELSIF p_ruc IS NOT NULL
            THEN
                RETURN 'R';
            END IF;
        ELSE
            RETURN NULL;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

-- Funcion que obtiene el balance real del estado de cuenta del estudiante.
-- Utilizando la vista principal de documentos de venta tzvaccd.
--
    FUNCTION f_get_balance (p_pidm        IN NUMBER,
                            p_term_code   IN VARCHAR2,
                            p_sdoc_code   IN VARCHAR2,
                            p_doc_number  IN VARCHAR2)
        RETURN NUMBER
    IS
        p_balance   NUMBER := 0;

        CURSOR c_get_balance
        IS
            SELECT SUM (TZVACCD_BALANCE)
                        FROM  tzvaccd
                       WHERE 
                                    tzvaccd_pidm = p_pidm
                             AND TZVACCD_SDOC_CODE = p_sdoc_code
                             AND tzvaccd_term_code = p_term_code
                               and TZVACCD_TYPE_IND = 'C'
                               AND tzvaccd_tran_number in (select tvrsdoc_chg_tran_number from tvrsdoc where 
                                    tzvaccd_pidm = tvrsdoc_pidm
                             AND tvrsdoc_doc_number = p_doc_number
                             AND tvrsdoc_doc_cancel_ind IS NULL);

    BEGIN
        OPEN c_get_balance;
        FETCH c_get_balance INTO p_balance;
        CLOSE c_get_balance;


        RETURN nvl(p_balance,0);

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN 0;
        WHEN OTHERS
        THEN
            RETURN 0;
    END;


-- Procedimiento de despliegue de PDF de prefacturas.
-- Utiliza la funcionalidad de PLPDF para la creacion de documentos en formato PDF.
-- 
    PROCEDURE p_show_pdf (p_pidm         IN NUMBER,
                          p_doc_number   IN NUMBER,
                          p_send_mail    IN VARCHAR2 DEFAULT 'N',
                          p_web          IN VARCHAR2 DEFAULT NULL,
                          p_footer in varchar2 default null)
    IS
        l_pdf                 BLOB;
        p_nombre_estudiante   VARCHAR2 (1000);
        p_att1 varchar2(1000);

cursor c_get_due_date is
select TZRDPRF_DUE_DOC_DATE
  from TZRDPRF
where TZRDPRF_PIDM = p_pidm    
    and TZRDPRF_DOC_NUMBER = p_doc_number;

cursor c_get_tzrven_code_obs  is
        SELECT
            TZRFVEN_LETR_CODE
        FROM
            tzrdprf, tzrfven
        WHERE
            tzrdprf_pidm = p_pidm
            AND   tzrdprf_doc_number = p_doc_number
            and TZRDPRF_TERM_CODE = TZRFVEN_TERM_CODE
            and TZRDPRF_SDOC_CODE = TZRFVEN_SDOC_CODE
            and TZRDPRF_CAMP_CODE = TZRFVEN_CAMP_CODE;


        CURSOR c_nombre_completo
        IS
            SELECT    REPLACE (spriden_last_name, '/', ' ')
                   || ' '
                   || spriden_first_name
                   || ' '
                   || spriden_mi
                       complete_name
              FROM spriden
             WHERE spriden_change_ind IS NULL AND spriden_pidm = p_pidm;

        CURSOR c_cargos
        IS
SELECT c_order, CATEGORIA,
                   CONCEPTO,
                   TOTAL,
                   TOTAL_AMT,
                   TYPE_IND,
                   (SUM (DECODE (TYPE_IND, 'P', TOTAL_AMT * -1, TOTAL_AMT))
                        OVER (PARTITION BY CATEGORIA))
                       gpo_amt,
                       (SUM (DECODE (TYPE_IND, 'P', TOTAL * -1, TOTAL))
                        OVER (PARTITION BY CATEGORIA))
                       gpo_tot,
                   (COUNT (0) OVER (PARTITION BY CATEGORIA))
                       cnt_cat,
                   ROW_NUMBER ()
                       OVER (PARTITION BY CATEGORIA ORDER BY type_ind)
                       row_cnt
              FROM (  
select tzkpufc.f_get_ordenamiento(TBBDETC_PAYT_CODE) c_order
          , TTVPAYT_DESC categoria
          , TBBDETC_DESC concepto
          , sum(TZRFACT_AMNT_TRANS) total
          , sum(TZRFACT_AMNT_TRANS) total_amt
          , TBBDETC_TYPE_IND type_ind
from tzrfact, tbbdetc, ttvpayt, gtvsdax
where tzrfact_pidm = p_pidm
  and TZRFACT_DOC_NUMBER = p_doc_number
  and tbbdetc_detail_code = TZRFACT_DET_CODE_DOC
  and TBBDETC_PAYT_CODE = TTVPAYT_CODE(+)
  and TZRFACT_SDOC_CODE = GTVSDAX_EXTERNAL_CODE 
  and GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_PREF'
  and tbbdetc_detail_code not in 
                                       (select distinct TBBISTC_PRIN_DETAIL_CODE from TBBISTC where TBBISTC_PRIN_DETAIL_CODE is not null
                                        UNION
                                        select distinct TBBISTC_INT_DETAIL_CODE from TBBISTC  where TBBISTC_INT_DETAIL_CODE is not null)                                
  group by TTVPAYT_DESC, TBBDETC_DESC, TBBDETC_TYPE_IND, TBBDETC_PAYT_CODE
  having sum(TZRFACT_AMNT_TRANS) <> 0
  ) ORDER BY c_order, categoria, type_ind, row_cnt ;

        CURSOR c_leyenda (
            p_letr_code    VARCHAR2)
        IS
              SELECT gubletr_para_seqno
                         sec,          GUBPARA_SEQ_NO para_seq_no,             
                         gtvpara_desc leyenda,
                         gubpara_text_var texto                     
                FROM gubletr,
                     gtvletr,
                     gtvpara,
                     gubpara
               WHERE     gtvletr_code = gubletr_letr_code
                     AND gubletr_para_code = gtvpara_code
                     AND gubletr_para_code = gubpara_para_code
                     AND gubletr_letr_code = p_letr_code                     
                     order by 1,2;

        v_cod_obs             VARCHAR2 (15);
        v_sum_teoria    number:=0; 
         v_sum_practica number:=0;

        CURSOR c_block_asignaturas
        IS
            SELECT UNIQUE sfrstcr_blck_code,
            (select stvblck_desc from stvblck where stvblck_code = sfrstcr.sfrstcr_blck_code) des
              FROM sfrstcr, ssbsect, scbcrse
              WHERE sfrstcr_blck_code is not null    
				   AND sfrstcr_term_code = SUBSTR (p_doc_number, 1, 6)
                   AND sfrstcr_pidm = p_pidm
                   AND ssbsect_term_code = sfrstcr_term_code
                   AND ssbsect_crn = sfrstcr_crn
                   AND EXISTS
                           (SELECT 1
                              FROM stvrsts
                             WHERE     stvrsts_code = sfrstcr_rsts_code
                                   AND stvrsts_incl_sect_enrl = 'Y')
                   AND ssbsect_subj_code = scbcrse_subj_code
                   AND ssbsect_crse_numb = scbcrse_crse_numb
                   AND scbcrse_eff_term =
                       (SELECT MAX (crse.scbcrse_eff_term)
                          FROM scbcrse crse
                         WHERE     scbcrse.scbcrse_subj_code =
                                   crse.scbcrse_subj_code
                               AND scbcrse.scbcrse_crse_numb =
                                   crse.scbcrse_crse_numb
                               AND crse.scbcrse_eff_term <= ssbsect_term_code);


        CURSOR c_asignaturas
        IS
            SELECT SSBSECT_SUBJ_CODE                        curso,
                   SSBSECT_CRSE_NUMB                        materia,
                   scbcrse_title                            asignatura,
                   NVL (SSBSECT_LEC_HR, SCBCRSE_LEC_HR_LOW) teoria,
                   NVL (SSBSECT_LAB_HR, SCBCRSE_LAB_HR_LOW) practica,
                   SSBSECT_CRN                              NRC
              FROM sfrstcr, ssbsect, scbcrse
             WHERE     sfrstcr_term_code = SUBSTR (p_doc_number, 1, 6)
                   AND sfrstcr_pidm = p_pidm
                   AND ssbsect_term_code = sfrstcr_term_code
                   AND ssbsect_crn = sfrstcr_crn
                   AND EXISTS
                           (SELECT 1
                              FROM stvrsts
                             WHERE     stvrsts_code = sfrstcr_rsts_code
                                   AND stvrsts_incl_sect_enrl = 'Y')
                   AND ssbsect_subj_code = scbcrse_subj_code
                   AND ssbsect_crse_numb = scbcrse_crse_numb
                   AND scbcrse_eff_term =
                       (SELECT MAX (crse.scbcrse_eff_term)
                          FROM scbcrse crse
                         WHERE     scbcrse.scbcrse_subj_code =
                                   crse.scbcrse_subj_code
                               AND scbcrse.scbcrse_crse_numb =
                                   crse.scbcrse_crse_numb
                               AND crse.scbcrse_eff_term <= ssbsect_term_code);

        CURSOR c_cnt_asignaturas
        IS
            SELECT COUNT (0) cnt
              FROM sfrstcr, ssbsect, scbcrse
             WHERE     sfrstcr_term_code = SUBSTR (p_doc_number, 1, 6)
                   AND sfrstcr_pidm = p_pidm
                   AND ssbsect_term_code = sfrstcr_term_code
                   AND ssbsect_crn = sfrstcr_crn
                   AND EXISTS
                           (SELECT 1
                              FROM stvrsts
                             WHERE     stvrsts_code = sfrstcr_rsts_code
                                   AND stvrsts_incl_sect_enrl = 'Y')
                   AND ssbsect_subj_code = scbcrse_subj_code
                   AND ssbsect_crse_numb = scbcrse_crse_numb
                   AND scbcrse_eff_term =
                       (SELECT MAX (crse.scbcrse_eff_term)
                          FROM scbcrse crse
                         WHERE     scbcrse.scbcrse_subj_code =
                                   crse.scbcrse_subj_code
                               AND scbcrse.scbcrse_crse_numb =
                                   crse.scbcrse_crse_numb
                               AND crse.scbcrse_eff_term <= ssbsect_term_code);

                        cursor c_is_adm is
                        SELECT 'Y'
                        FROM  tzvaccd
                       WHERE  tzvaccd_pidm = p_pidm
                            and TZVACCD_DCAT_CODE= 'APF'   
                            AND tzvaccd_tran_number in (select tvrsdoc_chg_tran_number from tvrsdoc
                                            where tvrsdoc_pidm = tzvaccd_pidm                             
                                             AND tvrsdoc_sdoc_code = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_PREF')
                                             AND tvrsdoc_doc_number = p_doc_number
                                             AND tvrsdoc_doc_cancel_ind IS NULL)  ;

                       v_is_adm varchar2(1);

        CURSOR c_identificacion
        IS
            SELECT (SELECT stvlgcy_desc
                      FROM stvlgcy
                     WHERE stvlgcy_code = spbpers_lgcy_code)
                       tipo_identificacion,
                   spbpers_ssn
                       identificacion
              FROM spbpers
             WHERE spbpers_pidm = p_pidm;

        v_tipo_iden           stvlgcy.stvlgcy_desc%TYPE;
        v_iden                spbpers.spbpers_ssn%TYPE;

        CURSOR c_cohort (
            p_pidm         NUMBER,
            p_term_code    VARCHAR2)
        IS
       select   max(pr.SGRCHRT_CHRT_CODE)
from  sgrchrt pr
where pr.SGRCHRT_PIDM = p_pidm
and pr.SGRCHRT_STSP_KEY_SEQUENCE = (select max(SFRSTCR_STSP_KEY_SEQUENCE) from SFRSTCR where SFRSTCR_PIDM = p_pidm  and SFRSTCR_TERM_CODE =  p_term_code)
and pr.sgrchrt_term_code_eff = (select max (sc.sgrchrt_term_code_eff) from sgrchrt sc where sc.SGRCHRT_PIDM = p_pidm and sc.sgrchrt_term_code_eff <= p_term_code)
and pr.SGRCHRT_CHRT_CODE is not null;

        v_cohort              SGRCHRT.SGRCHRT_CHRT_CODE%TYPE;
        l_num_mask            VARCHAR2 (20) := 'L999G999G999D00';
        v_total_cargos        NUMBER;
        v_enca_ara            VARCHAR2 (1) := 'N';
        v_enca_mat            VARCHAR2 (1) := 'N';
        v_enca_ter            VARCHAR2 (1) := 'N';
        v_enca_otr            VARCHAR2 (1) := 'N';
        v_encabezado          TTVPAYT.TTVPAYT_DESC%TYPE := 'X';
        v_grupo               TTVPAYT.TTVPAYT_DESC%TYPE;



        CURSOR c_fecha_emision
        IS
            SELECT TZRFACT_PREFACT_DATE, 
            TZRFACT_CURR_PROGRAM programa, decode(TZRFACT_CAMPUS, null, (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum =1), TZRFACT_CAMPUS) campus
              FROM tzrfact
             WHERE     TZRFACT_PIDM = p_pidm
                   AND TZRFACT_DOC_NUMBER = p_doc_number;

        v_fecha_emision       DATE := SYSDATE;

        CURSOR c_smtp
        IS
            SELECT gtvsdax_external_code, gtvsdax_desc, gtvsdax_comments
              FROM gtvsdax
             WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
                   AND gtvsdax_internal_code = 'SMTP';

        m_port                gtvsdax.gtvsdax_external_code%TYPE;
        m_host                gtvsdax.gtvsdax_desc%TYPE;
        m_mail_test           gtvsdax.gtvsdax_comments%TYPE;

        CURSOR c_emal_code
        IS
            SELECT gtvsdax_external_code,
                   gtvsdax_desc,
                   gtvsdax_concept,
                   gtvsdax_comments
              FROM gtvsdax
             WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
                   AND gtvsdax_internal_code = 'EMAL_CODE';

        m_emal_code           gtvsdax.gtvsdax_external_code%TYPE;
        m_from                gtvsdax.gtvsdax_desc%TYPE;
        m_subject             gtvsdax.gtvsdax_concept%TYPE;
        m_body                gtvsdax.gtvsdax_comments%TYPE;

        CURSOR c_email_address
        IS
        SELECT GOREMAL_EMAIL_ADDRESS FROM VIEW_TZRFACT_OPERACION 
        WHERE TZRFACT_PIDM= p_pidm 
        AND TZRFACT_DOC_NUMBER= p_doc_number
        AND TZRFACT_SDOC_CODE=
        (select GTVSDAX_EXTERNAL_CODE from gtvsdax 
        where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' 
        and GTVSDAX_INTERNAL_CODE = 'COD_PREF');

        CURSOR c_email_adm
        IS
        SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL 
        WHERE GOREMAL_PIDM= p_pidm          
            AND goremal_emal_code = (SELECT GTVSDAX_EXTERNAL_CODE
        FROM GTVSDAX
        WHERE GTVSDAX_INTERNAL_CODE_GROUP ='SARAPPD_GBA021'
        AND GTVSDAX_INTERNAL_CODE ='EMAL_CODE')
            AND goremal_status_ind = 'A';


        m_email_address       goremal.goremal_email_address%TYPE;

        CURSOR c_due_date (
            p_term         VARCHAR2,
            p_sdoc_code    VARCHAR2,
            p_program      VARCHAR2,
            p_campus       VARCHAR2,
            p_levl_code    VARCHAR2,
            p_chrt_code    VARCHAR2)
        IS
            SELECT TZRFVEN_END_DATE
              FROM TZRFVEN
             WHERE     tzrfven_term_code = p_term
                   AND tzrfven_sdoc_code = p_sdoc_code
                   AND NVL (tzrfven_program_code, p_program) = p_program
                   AND tzrfven_camp_code = p_campus
                   AND NVL (tzrfven_levl_code, p_levl_code) = p_levl_code
                   AND NVL (tzrfven_chrt_code, p_chrt_code) = p_chrt_code;

        v_due_date            DATE;
        varx plpdf_type.t_color;
        l_widths              plpdf_type.t_row_widths;      
        l_aligns              plpdf_type.t_row_aligns;      
        l_datas               plpdf_type.t_row_datas;       
        l_borders             plpdf_type.t_row_borders;   
        l_styles              plpdf_type.t_row_styles;      
        l_maxlines            plpdf_type.t_row_maxlines; 

        l_border_custom       VARCHAR2 (2) := '';
        l_aligns_center       VARCHAR2 (2) := 'C';
        l_aligns_left         VARCHAR2 (2) := 'L';
        l_aligns_rigth        VARCHAR2 (2) := 'R';
        l_font_arial          NUMBER := 10;
        l_cell_arial          NUMBER := l_font_arial - 4;
        l_font_courier        NUMBER := 8;
        l_cell_courier        NUMBER := l_font_courier - 3.5;
        l_font_times          NUMBER := 14;
        l_cell_times          NUMBER := l_font_times - 8;
        l_widths_infotab      plpdf_type.t_row_widths;      
        l_widths_totaltab     plpdf_type.t_row_widths;     
        l_logo_posy           NUMBER;
        v_fill_spaces_20      VARCHAR2 (35) := '                    ';
        v_fill_spaces_30      VARCHAR2 (35)
                                  := '                              ';
        v_fill_spaces_40      VARCHAR2 (48)
            := '                                             ';

        v_amt                 VARCHAR2 (200);
        v_subtotal                 VARCHAR2 (200);
        v_tot_gpo             NUMBER := 0;
        p_gpo                 NUMBER := 0;
        p_gpo_printed         VARCHAR2 (1) := 'N';



        p_cnt_asign           NUMBER := 0;
		l_block_asignaturas	  varchar2(100);	
		l_desc_block_asignaturas	  varchar2(100);	

        cursor c_get_sede_name (p_doc_number varchar2) is
          select f_format_name (gb_common.f_get_pidm (gtvsdax_external_code), 'L60') 
          FROM gtvsdax
         WHERE  gtvsdax_internal_code_group = 'PUCE_FACT'
                     AND gtvsdax_internal_code = 'ID_PUCE'
                     AND GTVSDAX_TRANSLATION_CODE =   substr(p_doc_number,7,1)  ;

      p_sede_name varchar2(300);

    BEGIN


        OPEN c_get_sede_name (p_doc_number);
        FETCH c_get_sede_name INTO p_sede_name;
        CLOSE c_get_sede_name;


        OPEN c_nombre_completo;
        FETCH c_nombre_completo INTO p_nombre_estudiante;
        CLOSE c_nombre_completo;


        OPEN c_identificacion;
        FETCH c_identificacion INTO v_tipo_iden, v_iden;
        CLOSE c_identificacion;


                p_levl          := f_get_sovlcur(p_pidm, SUBSTR (p_doc_number, 1, 6), 'LEVL' );


        OPEN c_cohort (p_pidm, SUBSTR (p_doc_number, 1, 6));
        FETCH c_cohort INTO v_cohort;
        CLOSE c_cohort;

        OPEN c_fecha_emision;
        FETCH c_fecha_emision INTO v_fecha_emision, p_program, p_sede;
        CLOSE c_fecha_emision;

        OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;

        OPEN c_due_date (SUBSTR (p_doc_number, 1, 6),
                         p_sdoc_pref,
                         p_program,
                         p_sede,
                         p_levl,
                         v_cohort);

        FETCH c_due_date INTO v_due_date;

        CLOSE c_due_date;

        plpdf.init (p_orientation   => plpdf_const.portrait,
                    p_unit          => plpdf_const.mm,
                    p_format        => 'letter');


        plpdf.newpage;

        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 10);
        plpdf_cell.printcell (
            p_width =>
                195,
            p_align =>
                plpdf3.c_center,
            p_text => p_sede_name || v_fill_spaces_40 || v_fill_spaces_20);

        plpdf_cell.newline;  plpdf_cell.newline;plpdf_cell.newline;

        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 10);
        plpdf_cell.printcell (
            p_width =>
                195,
            p_align =>
                plpdf3.c_right,
            p_text =>
                   'Fecha de Emisión: '
                || NVL (v_fecha_emision, SYSDATE)
                || v_fill_spaces_30);

          plpdf_cell.newline; plpdf_cell.newline;

          plpdf.printcell ( p_w   => 32, p_txt    =>RPAD('Periodo:', 13, ' '), p_ln       => plpdf_const.beside);
          plpdf.setprintfont (p_family => 'Arial', p_style => '', p_size => 10);
          plpdf.printcell ( p_w   => 163, p_txt    =>SUBSTR (p_doc_number, 1, 6) || ' ' || GB_STVTERM.f_get_description (SUBSTR (p_doc_number, 1, 6)), p_ln       => plpdf_const.newline);

          plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 10);
          plpdf.printcell ( p_w   => 32, p_txt    =>RPAD('Estudiante:', 13, ' '), p_ln       => plpdf_const.beside);
          plpdf.setprintfont (p_family => 'Arial', p_style => '', p_size => 10);
          plpdf.printcell ( p_w =>163, p_txt => p_nombre_estudiante|| ' ('|| gb_common.f_get_id (p_pidm)|| ')', p_ln       => plpdf_const.newline);

          plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 10);
          plpdf.printcell ( p_w   => 32, p_txt    =>RPAD(v_tipo_iden ||':', 13, ' '), p_ln       => plpdf_const.beside);
          plpdf.setprintfont (p_family => 'Arial', p_style => '', p_size => 10);
          plpdf.printcell ( p_w =>163, p_txt => v_iden, p_ln       => plpdf_const.newline);

          plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 10);
          plpdf.printcell ( p_w   => 32, p_txt    =>RPAD('Carrera:', 13, ' '), p_ln       => plpdf_const.beside);
          plpdf.setprintfont (p_family => 'Arial', p_style => '', p_size => 10);
          plpdf.printcell ( p_w =>163, p_txt => BWCKCAPP.get_program_desc (p_program), p_ln       => plpdf_const.newline);

         IF v_cohort is not null then
          plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 10);
          plpdf.printcell ( p_w   => 32, p_txt    =>RPAD('Cohort:', 13, ' '), p_ln       => plpdf_const.beside);

          plpdf.setprintfont (p_family => 'Arial', p_style => '', p_size => 10);
          plpdf.printcell ( p_w =>163, p_txt => v_cohort, p_ln       => plpdf_const.newline);

         END IF; 

        plpdf_cell.newline;

       plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 10);
        plpdf_cell.printcell (
            p_width =>
                190,
            p_text =>
                'Comprobante no. ' || f_get_docnum_fmt (p_doc_number));
        plpdf_cell.newline;plpdf_cell.newline;


        plpdf.Line(
        p_x1 => 10,
        p_y1 => plpdf.getCurrentY(), 
        p_x2 => 205,
        p_y2 => plpdf.getCurrentY());


        plpdf_cell.newline;        plpdf_cell.newline;

        v_total_cargos := 0;

        FOR chrg IN c_cargos
        LOOP
            IF chrg.categoria <> v_encabezado
            THEN
                plpdf.setprintfont (p_family   => 'Arial',
                                    p_style    => 'B',
                                    p_size     => 9);

                plpdf_cell.printcell (p_width => 190, p_text => chrg.categoria);
                plpdf_cell.newline;

                v_encabezado := chrg.categoria;
            END IF;

            plpdf_cell.init;
            plpdf.setprintfont (p_family => 'Arial', p_size => 9);

            plpdf.printcell (p_w        => 150,             
                             p_txt      => chrg.concepto, 
                             p_border   => '0',                  
                             p_ln       => plpdf_const.beside, 
                             p_align    => 'L',      
                             p_fill     => FALSE 
                                                );

            IF chrg.type_ind = 'P'
            THEN
                v_amt := '(-)' || TRIM (TO_CHAR (chrg.total_amt, l_num_mask));
            ELSE
                IF chrg.total_amt > chrg.total then
                v_amt := TRIM (TO_CHAR (chrg.total, l_num_mask));
                ELSE
                v_amt := TRIM (TO_CHAR (chrg.total_amt, l_num_mask));
                END IF;

            END IF;

            plpdf.printcell (p_w        => 45,              
                             p_txt      => v_amt || v_fill_spaces_20, 
                             p_border   => '0',                  
                             p_ln       => plpdf_const.newline, 
                             p_align    => 'R',      
                             p_fill     => FALSE 
                                                );

            IF chrg.cnt_cat = chrg.row_cnt
            THEN

                IF chrg.GPO_AMT <> chrg.GPO_TOT then
                 v_subtotal := to_char(chrg.GPO_TOT);
                ELSE
                 v_subtotal := to_char(chrg.GPO_AMT);
                END IF; 
             v_total_cargos := v_total_cargos + v_subtotal;

                plpdf.setprintfont (p_family   => 'Arial',
                                    p_style    => 'B',
                                    p_size     => 9);

                plpdf.printcell (
                    p_w =>
                        195,
                    p_txt =>
                           TRIM (TO_CHAR (v_subtotal, l_num_mask))
                        || v_fill_spaces_20,
                    p_border =>
                        '0',
                    p_ln =>
                        plpdf_const.newline,
                    p_align =>
                        'R',
                    p_fill =>
                        FALSE);

            END IF;
        END LOOP;

        plpdf_cell.newline;

        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 9);
        plpdf_cell.printcell (p_width   => 190,
                              p_text    => 'SERVICIOS FACTURADOS +  IVA');
        plpdf_cell.newline;

        plpdf_cell.init;
        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 9);

        plpdf.printcell (p_w        => 150,
                         p_txt      => 'Total +  IVA',
                         p_border   => '0',
                         p_ln       => plpdf_const.beside,
                         p_align    => 'L',
                         p_fill     => FALSE);

        plpdf.printcell (
            p_w =>
                45,
            p_txt =>
                   TRIM (TO_CHAR (v_total_cargos, l_num_mask))
                || v_fill_spaces_20,
            p_border =>
                '0',
            p_ln =>
                plpdf_const.newline,
            p_align =>
                'R',
            p_fill =>
                FALSE);

        ------------------------------------------------------------------------------------------------------------
        OPEN c_get_due_date;
        FETCH c_get_due_date into v_due_date;
        CLOSE  c_get_due_date;   

        plpdf_cell.newline;plpdf_cell.newline;

            plpdf_cell.init;
        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 9);

        plpdf.printcell (p_w        => 57,
                         p_txt      => 'Fecha máxima de pago: ',
                         p_border   => '0',
                         p_ln       => plpdf_const.beside,
                         p_align    => 'L',
                         p_fill     => FALSE);

        plpdf.printcell (
            p_w =>
                60,
            p_txt =>
                   (v_due_date)
                ,
            p_border =>
                '0',
            p_ln =>
                plpdf_const.newline,
            p_align =>
                'L',
            p_fill =>
                FALSE);

        plpdf_cell.newline;
        plpdf_cell.newline;

        OPEN c_cnt_asignaturas;
        FETCH c_cnt_asignaturas INTO p_cnt_asign;
        CLOSE c_cnt_asignaturas;

        open  c_is_adm;
        fetch c_is_adm into v_is_adm;
        close c_is_adm;

        IF p_cnt_asign > 0
        THEN
           IF v_is_adm is null then
		    l_block_asignaturas := null;
            l_desc_block_asignaturas := null;
		    open  c_block_asignaturas;
			fetch c_block_asignaturas into l_block_asignaturas, l_desc_block_asignaturas;
			close c_block_asignaturas;

			if l_block_asignaturas is not null then
				plpdf_cell.newline;

				plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 9);
				plpdf_cell.printcell (p_width   => 190,
									  p_text    => ' Bloque: '||l_block_asignaturas||' '||l_desc_block_asignaturas);
				plpdf.setprintfont (p_family   => 'Arial',
									p_style    => 'B',
									p_size     => 9);
				plpdf_cell.newline;

			end if;

            plpdf.printcell (p_w        => 20,              
                             p_txt      => g$_nls.get ('X', 'SQL', 'Curso'), 
                             p_border   => '0',                  
                             p_ln       => plpdf_const.beside, 
                             p_align    => 'L',      
                             p_fill     => FALSE 
                                                );

            plpdf.printcell (p_w        => 20,              
                             p_txt      => g$_nls.get ('X', 'SQL', 'Materia'), 
                             p_border   => '0',                  
                             p_ln       => plpdf_const.beside, 
                             p_align    => 'L',      
                             p_fill     => FALSE 
                                                );

            plpdf.printcell (p_w        => 80,              
                             p_txt      => g$_nls.get ('X', 'SQL', 'Asignatura'), 
                             p_border   => '0',                  
                             p_ln       => plpdf_const.beside, 
                             p_align    => 'L',      
                             p_fill     => FALSE 
                                                );

            plpdf.printcell (p_w        => 20,              
                             p_txt      => g$_nls.get ('X', 'SQL', 'Teoría'), 
                             p_border   => '0',                 
                             p_ln       => plpdf_const.beside, 
                             p_align    => 'L',      
                             p_fill     => FALSE 
                                                );

            plpdf.printcell (p_w        => 30,             
                             p_txt      => g$_nls.get ('X', 'SQL', 'Práctica'), 
                             p_border   => '0',                 
                             p_ln       => plpdf_const.beside, 
                             p_align    => 'L',      
                             p_fill     => FALSE 
                                                );

            plpdf.printcell (p_w        => 20,              
                             p_txt      => g$_nls.get ('X', 'SQL', 'NRC'), 
                             p_border   => '0',                 
                             p_ln       => plpdf_const.newline, 
                             p_align    => 'L',      
                             p_fill     => FALSE 
                                                );

            plpdf_cell.init;
            plpdf.setprintfont (p_family => 'Arial', p_size => 9);

v_sum_teoria    :=0; 
         v_sum_practica :=0;

            FOR asig IN c_asignaturas
            LOOP
                plpdf.printcell (p_w        => 20,
                                 p_txt      => asig.curso,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 20,
                                 p_txt      => asig.materia,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 80,
                                 p_txt      => asig.asignatura,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 20,
                                 p_txt      => asig.teoria,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 25,
                                 p_txt      => asig.practica,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 20,
                                 p_txt      => asig.nrc,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.newline,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                v_sum_teoria    :=v_sum_teoria + asig.teoria; 
                v_sum_practica := v_sum_practica + asig.practica;

            END LOOP;
            plpdf.printcell (p_w        => 120,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 20,
                                 p_txt      => v_sum_teoria,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 25,
                                 p_txt      => v_sum_practica,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.newline,
                                 p_align    => 'C',
                                 p_fill     => FALSE);
                     END IF; 
        END IF;                                            


        plpdf.Line(
        p_x1 => 10,
        p_y1 => plpdf.getCurrentY(), 
        p_x2 => 205,
        p_y2 => plpdf.getCurrentY());


        plpdf_cell.newline;
        plpdf_cell.newline;


        open c_get_tzrven_code_obs;
        fetch c_get_tzrven_code_obs into v_cod_obs;
        close c_get_tzrven_code_obs;


        OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'OBS_DFLT', 'EXT');
        FETCH c_get_data_i INTO p_obs_dflt;
        CLOSE c_get_data_i;


        if v_cod_obs is null then
         v_cod_obs := p_obs_dflt;
        end if; 

        FOR text IN c_leyenda (v_cod_obs)
        LOOP

         IF text.para_seq_no = 1 then
         plpdf_cell.init;
         plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 9);

         plpdf.printcell (p_w        => 48,
                                 p_txt      => text.leyenda, --'Observaciones: ',--
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside, --newline
                                 p_align    => 'L',
                                 p_fill     => FALSE);
         ELSE
         plpdf.printcell (p_w        => 48,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside, --newline
                                 p_align    => 'L',
                                 p_fill     => FALSE);
         END IF;

         plpdf_cell.init;
         plpdf.setprintfont (p_family => 'Arial', p_size => 8);

         plpdf.printcell (p_w        => 165,
                                 p_txt      => text.texto,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.newline,
                                 p_align    => 'L',
                                 p_fill     => FALSE);


        END LOOP;


        plpdf.senddoc (p_blob => l_pdf);

        IF p_web IS NULL
        THEN
            HTP.flush;
            HTP.init;
            --
            OWA_UTIL.mime_header ('application/pdf', FALSE);
            HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_pdf));
            OWA_UTIL.http_header_close;
            WPG_DOCLOAD.download_file (l_pdf);
        END IF;

        IF p_send_mail = 'Y'
        THEN

         m_mail_test := '';

            BEGIN
                OPEN c_smtp;
                FETCH c_smtp INTO m_port, m_host, m_mail_test;
                CLOSE c_smtp;

                OPEN c_emal_code;
                FETCH c_emal_code INTO m_emal_code, m_from, m_subject, m_body;
                CLOSE c_emal_code;

                OPEN c_email_address;
                FETCH c_email_address INTO m_email_address;
                CLOSE c_email_address;

                IF m_mail_test IS NULL or nvl(instr(m_mail_test,'@'),0)< 1
                THEN
                    m_mail_test := m_email_address;
                END IF;

                IF p_footer is not null then
                   p_att1 := 'Pago en Línea: ' ||tzkpufc.f_get_url_pay(p_pidm, p_doc_number);
                OPEN c_email_adm;
                FETCH c_email_adm INTO m_email_address;
                CLOSE c_email_adm;

                END IF;

                send_mail (
                    p_to =>  m_email_address,
                    p_from =>
                        m_from,
                    p_subject =>
                        m_subject || ' ' || f_get_docnum_fmt (p_doc_number),
                    p_text_msg =>
                        m_body || chr(10)||chr(10) || p_att1,
                    p_attach_name =>
                        f_get_docnum_fmt (p_doc_number) || '.pdf',
                    p_attach_mime =>
                        'application/pdf',
                    p_attach_blob =>
                        l_pdf,
                    p_smtp_host =>
                        m_host,
                    p_smtp_port =>
                        m_port);
            END;
        END IF;

    END;

-- Funcion interna de transformación de tipo de dato que utilizan los datos suplementarios.
    FUNCTION getData (data IN SYS.ANYDATA)
        RETURN VARCHAR2
    AS
        l_varchar2   VARCHAR2 (4000);
        l_rc         NUMBER;
    BEGIN
        CASE data.getTypeName
            WHEN 'SYS.NUMBER'
            THEN
                l_rc := data.getNumber (l_varchar2);
            WHEN 'SYS.DATE'
            THEN
                l_rc := data.getDate (l_varchar2);
            WHEN 'SYS.VARCHAR2'
            THEN
                l_rc := data.getVarchar2 (l_varchar2);
            ELSE
                l_varchar2 := '** unknown **';
        END CASE;

        RETURN l_varchar2;
    END;

--Procedimiento principal del proveedor de servicios Place to Pay para leer y colectar y procesar información de las transacciones.
-- Utiliza UTL_HTTP, JSON y simbra el pago en el estado de cuenta utilizando el procedimiento tzkrpay.p_register_payment.
-- 
PROCEDURE p_getStatus is
cursor c_get_trans is
select TZRPAYU_PIDM_OPRD oprd, TZRPAYU_PIDM pidm, TZRPAYU_CAMPUS campus, TZRPAYU_REQUEST_ID request_id, TZRPAYU_SDOC_CODE sdoc_code, TZRPAYU_DOC_NUMBER doc_number, TZRPAYU_TERM term, TZRPAYU_REFERENCE, tzrpayu_servicio, tzrpayu_PAY_DATE
from tzrpayu where TZRPAYU_REQUEST_ID is not null
and (TZRPAYU_STATUS not in ('REJECTED','FAILED', 'KUSHKI', 'APPROVAL') or TZRPAYU_STATUS is null ) and tzrpayu_processed_ind is null
and not exists (select 'Y' from tzvoprd where TZVOPRD_PIDM = TZRPAYU_PIDM_OPRD and TZVOPRD_IDENTIFY_WS = 'KSK');

cursor c_trans_not_proccessed is
select TZRPAYU_PIDM_OPRD oprd, TZRPAYU_PIDM pidm, TZRPAYU_CAMPUS campus, TZRPAYU_REQUEST_ID request_id, TZRPAYU_SDOC_CODE sdoc_code, TZRPAYU_DOC_NUMBER doc_number, TZRPAYU_TERM term,
           json_value (TZRPAYU_SEND_JSON, '$.payment.amount.total') total_amount, 
           json_value (TZRPAYU_SEND_JSON, '$.payment.reference') payment_reference, 
           tzrpayu_pay_date pay_date,
           tzrpayu_franchise,
           tzrpayu_installments
           ,TZRPAYU_SERVICIO servicio
from tzrpayu where TZRPAYU_REQUEST_ID is not null  and TZRPAYU_STATUS in ('APPROVED')
 and tzrpayu_processed_ind is null
 and not exists (select 'Y' from tzvoprd where TZVOPRD_PIDM = TZRPAYU_PIDM_OPRD and TZVOPRD_IDENTIFY_WS = 'KSK');

cursor c_exist_history (p_request_id number, p_status varchar2) is
select count(0) from taismgr.tzrpayh where tzrpayh_request_id = p_request_id and TZRPAYH_STATUS = p_status;

p_existe number :=0;


cursor c_get_bank (p_pidm_oprd in number, p_camp_code in varchar2, p_servicio in varchar2 ) is
SELECT TZVOPRD_PAY_TYPE 
              FROM tzvoprd
             WHERE     tzvoprd_pidm = p_pidm_oprd
                   AND tzvoprd_camp_code = p_camp_code
                   AND TZVOPRD_SERV = p_servicio
                   AND TRUNC (SYSDATE) BETWEEN tzvoprd_start_date
                                           AND tzvoprd_end_date;


v_pay_type  tzvoprd.tzvoprd_pay_type%type;

p_response_out clob;
p_result   varchar2(100);
p_error    varchar2(1000);
p_error_msg varchar2(1000);

p_bank_p2p           gtvsdax.gtvsdax_external_code%TYPE;

p_pay_sde varchar2(10);
lc_autorization_code varchar2(100); 
lc_paymentMethodName varchar2(100); 
lc_issuerName varchar2(100); 
lc_receipt varchar2(10);
lc_groupCode varchar2(100);

lc_pay_date date;

BEGIN

FOR i IN c_get_trans
    LOOP
      p_response_out := '';

      getRequestInformation ( i.oprd, i.pidm, i.campus, i.request_id, i.tzrpayu_servicio, p_response_out );
      p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P getRequestInformation:', i.oprd ||' pidm: '|| i.pidm ||' campus: '|| i.campus ||' request_id: '|| i.request_id ||' servicio: '|| i.tzrpayu_servicio, user);

begin
SELECT json_value (p_response_out, '$.request.returnUrl') return_url,
            json_value (p_response_out, '$.status.status') status,
            json_value (p_response_out, '$.status.reason') reason,
            json_value (p_response_out, '$.status.message') mess,
            json_value (p_response_out, '$.status.date') fecha,
            json_value (p_response_out, '$.requestId') requestid,
            jt.franchise,
            jt.installments,
             json_value (p_response_out, '$.request.payment.amount.currency') currency,
            json_value (p_response_out, '$.request.payment.amount.total') total
 INTO v_return_url, lc_status, lc_reason, lc_message, lc_date, lc_requestid, lc_franchise, lc_installments
 , lc_currency,lc_total
FROM dual,
JSON_TABLE(p_response_out, '$.payment[*]'
COLUMNS (
         franchise VARCHAR2(10) PATH '$.franchise',
         installments NUMBER PATH '$.processorFields[*].value.installments',
         payment_status VARCHAR2(20) PATH '$.status.status'
         ))         
AS jt
where payment_status = 'APPROVED';

p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P APPROVED lc_status:', lc_status ||' lc_reason: '||lc_reason ||' lc_message: '|| lc_message ||' lc_date: '|| lc_date ||' lc_requestid: '|| lc_requestid||' lc_franchise: '|| lc_franchise||' lc_installments: '|| lc_installments||' lc_total: '|| lc_total, user);


exception when no_data_found then
     SELECT json_value (p_response_out, '$.request.returnUrl'),
                          json_value (p_response_out, '$.status.status'),
                          json_value (p_response_out, '$.status.reason'),
                          json_value (p_response_out, '$.status.message'),
                          json_value (p_response_out, '$.status.date'),
                          json_value (p_response_out, '$.requestId'),
                          json_value (p_response_out, '$.payment.franchise'),
                          json_value (p_response_out, '$.payment.processorFields.value.installments')
                          ,json_value (p_response_out, '$.payment.authorization') , 
                       json_value (p_response_out, '$.payment.paymentMethodName') , 
                       json_value (p_response_out, '$.payment.issuerName') ,  
                       json_value (p_response_out, '$.payment.receipt') , 
                       json_value (p_response_out, '$.payment.processorFields.value.groupCode'),
                       json_value (p_response_out, '$.payment.amount.total') ,    
                       json_value (p_response_out, '$.payment.amount.currency') 
             INTO v_return_url, lc_status, lc_reason, lc_message, lc_date, lc_requestid, lc_franchise, lc_installments, lc_autorization_code, lc_paymentMethodName, lc_issuerName, lc_receipt, lc_groupCode, lc_total, lc_currency
             FROM DUAL;

             p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P no_data_found lc_status:', lc_status ||' lc_reason: '||lc_reason ||' lc_message: '|| lc_message ||' lc_date: '|| lc_date ||' lc_requestid: '|| lc_requestid||' lc_franchise: '|| lc_franchise||' lc_installments: '|| lc_installments||' lc_total: '|| lc_total ||' lc_autorization_code: '|| lc_autorization_code||' lc_paymentMethodName: '|| lc_paymentMethodName ||' lc_issuerName: '||lc_issuerName, user);
               when others then 

               begin
               p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P others', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);

			SELECT json_value (p_response_out, '$.request.returnUrl'),
                          json_value (p_response_out, '$.status.status'),
                          json_value (p_response_out, '$.status.reason'),
                          json_value (p_response_out, '$.status.message'),
                          json_value (p_response_out, '$.status.date'),
                          json_value (p_response_out, '$.requestId'),
                          json_value (p_response_out, '$.payment.franchise'),
                          json_value (p_response_out, '$.payment.processorFields.value.installments')
                          ,json_value (p_response_out, '$.payment.authorization') , 
                       json_value (p_response_out, '$.payment.paymentMethodName') , 
                       json_value (p_response_out, '$.payment.issuerName') ,  
                       json_value (p_response_out, '$.payment.receipt') , 
                       json_value (p_response_out, '$.payment.processorFields.value.groupCode'),
                       json_value (p_response_out, '$.payment.amount.total') ,    
                       json_value (p_response_out, '$.payment.amount.currency') 
             INTO v_return_url, lc_status, lc_reason, lc_message, lc_date, lc_requestid, lc_franchise, lc_installments, lc_autorization_code, lc_paymentMethodName, lc_issuerName, lc_receipt, lc_groupCode, lc_total, lc_currency
             FROM DUAL;

             p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P others after lc_status:', lc_status ||' lc_reason: '||lc_reason ||' lc_message: '|| lc_message ||' lc_date: '|| lc_date ||' lc_requestid: '|| lc_requestid||' lc_franchise: '|| lc_franchise||' lc_installments: '|| lc_installments||' lc_total: '|| lc_total ||' lc_autorization_code: '|| lc_autorization_code||' lc_paymentMethodName: '|| lc_paymentMethodName ||' lc_issuerName: '||lc_issuerName, user);
            exception when others then
             p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P others after lc_status:', lc_status, user);

            end;
end;

begin
 lc_pay_date :=  TO_DATE(substr(replace(lc_date, 'T',' '),1,19), 'YYYY-MM-DD HH24:MI:SS');
 exception when others then
 lc_pay_date := sysdate;
end;


          begin
            update  tzrpayu
                   set tzrpayu_response_json = p_response_out,
                        tzrpayu_activity_date = sysdate, 
                        TZRPAYU_STATUS = lc_status, 
                        TZRPAYU_REASON = lc_reason, 
                        TZRPAYU_MESSAGE = lc_message, 
                        tzrpayu_franchise = lc_franchise,
                        tzrpayu_installments = lc_installments
                        , tzrpayu_pay_date =  lc_pay_date
            where tzrpayu_pidm = i.pidm
                and  tzrpayu_sdoc_code = i.sdoc_code 
                and  tzrpayu_doc_number = i.DOC_NUMBER 
                and  tzrpayu_campus = i.campus 
                and  tzrpayu_term = i.TERM
                and  tzrpayu_servicio = i.tzrpayu_servicio
                and not exists (select 'Y' from tzvoprd where TZVOPRD_PIDM = TZRPAYU_PIDM_OPRD and TZVOPRD_IDENTIFY_WS = 'KSK');

              p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P Actualiza', sysdate ||' lc_status: '||lc_status ||' lc_reason: '|| lc_reason ||' lc_message: '|| lc_message ||' lc_franchise: '|| lc_franchise||' lc_installments: '|| lc_installments||' i.DOC_NUMBER: '|| i.DOC_NUMBER, user);

            exception  when others then p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P update others', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);
             end;

  begin
  open c_exist_history(lc_requestid, lc_status);
  fetch c_exist_history into p_existe;
  close c_exist_history;

  IF p_existe = 0 then

          insert into taismgr.tzrpayh
            (
              TZRPAYH_PIDM, 
              TZRPAYH_SDOC_CODE, 
              TZRPAYH_DOC_NUMBER, 
              TZRPAYH_CAMPUS, 
              TZRPAYH_TERM, 
              TZRPAYH_STATUS,  
              TZRPAYH_MESSAGE, 
              TZRPAYH_REQUEST_ID, 
              TZRPAYH_REFERENCE, 
              TZRPAYH_FRANCHISE, 
              TZRPAYH_INSTALLMENTS,
              TZRPAYH_activity_date,
              tzrpayh_PIDM_OPRD,
              TZRPAYh_SERVICE, 
              TZRPAYh_PAY_DATE,
              TZRPAYh_autorization_code,
            TZRPAYh_payment_Method_Name,
            TZRPAYh_issuer_Name,
            TZRPAYh_receipt,
            TZRPAYh_group,
            TZRPAYH_TOTAL, TZRPAYH_CURRENCY
              )
            values
            ( i.pidm, i.sdoc_code , i.DOC_NUMBER , i.campus , i.TERM, lc_status, lc_message, lc_requestid , i.TZRPAYU_REFERENCE, lc_franchise,lc_installments, sysdate, i.oprd, i.tzrpayu_servicio, sysdate, lc_autorization_code, lc_paymentMethodName, lc_issuerName, lc_receipt, lc_groupCode, lc_total, lc_currency);
   END IF;            

            exception  when others then p_ins_tzrrlog(i.pidm,  'PAGO_ONLINE', 'P2P update history table', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);
             end;

    END LOOP;

FOR j IN c_trans_not_proccessed
    LOOP

open c_get_bank (j.oprd, j.campus, j.servicio);
fetch c_get_bank into p_bank_p2p;
close c_get_bank;


IF p_bank_p2p is null then
OPEN c_get_data_i ('PUCE_FACT', 'BANK_P2P', 'EXT');
 FETCH c_get_data_i INTO p_bank_p2p;
 CLOSE c_get_data_i;
end if;

 OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
        FETCH c_get_data_i INTO p_user_create;
        CLOSE c_get_data_i;


BEGIN
                         tzkrpay.p_register_payment (
                            p_bank_code        => p_bank_p2p,
                            p_doc_number     => f_get_docnum_fmt(j.DOC_NUMBER),
                            p_total_amount    => j.total_amount,
                            p_payment_date   => j.pay_date, 
                            p_payment_hour   => null,
                            p_pay_type           => j.tzrpayu_installments, 
                            p_cash_amount          => NULL,
                            p_chk_amount           => NULL,
                            p_card_amount          => j.total_amount,
                            p_invoice_number     => NULL,
                            p_status                    => 'ACEPTADO',
                            p_agency_code          => NULL,
                            p_card_number          => j.tzrpayu_franchise, 
                            p_pay_method           => NULL,
                            p_card_type               => NULL,
                            p_pay_deferred          => NULL,
                            p_internal_reference   => NULL, 
                            p_receipt_number     => NULL,
                            p_auth_number         => NULL,
                            p_pay_comments       => NULL,
                            p_user_id                  => p_user_create,
                            p_result                  => p_result,
                            p_error                   => p_error);

   exception when others then
         p_error_msg := 'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 700);
         p_ins_tzrrlog(j.pidm,  'PAGO_ONLINE', 'P2P others p_register_payment', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);

   END;                            
      begin
          update tzrpayu set TZRPAYU_PROCESSED_IND = 'Y', TZRPAYU_PAYMENT_ERROR_MSG = substr(p_error||p_result,1,1000)
          where tzrpayu_pidm = j.pidm
                    and  tzrpayu_sdoc_code = j.sdoc_code 
                    and  tzrpayu_doc_number = j.DOC_NUMBER 
                    and  tzrpayu_campus = j.campus 
                    and  tzrpayu_term = j.TERM
                    and TZRPAYU_STATUS = 'APPROVED'
                    and tzrpayu_servicio = j.servicio
                    and not exists (select 'Y' from tzvoprd where TZVOPRD_PIDM = TZRPAYU_PIDM_OPRD and TZVOPRD_IDENTIFY_WS = 'KSK');

         p_ins_tzrrlog(j.pidm,  'PAGO_ONLINE', 'P2P TZRPAYU payment', j.DOC_NUMBER ||' - ' ||substr(p_error||p_result,1,1000), user);

       exception  when others then p_ins_tzrrlog(j.pidm,  'PAGO_ONLINE', 'P2P others TZRPAYU', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);
       end;

    END LOOP;

    delete from tzrpayu
    where upper(tzrpayu_servicio) like upper('%kushki%')
    and NVL(tzrpayu_status,'NULO')<>'APPROVAL'
    and   tzrpayu_activity_date<(sysdate - 7 / 1440);

    delete from tzrpayu
    where upper(tzrpayu_servicio) like upper('%Tarjeta%')
    and (NVL(tzrpayu_status,'NULO') = 'PENDING' or NVL(tzrpayu_status,'NULO') = 'FAILED')
    and   tzrpayu_activity_date<(sysdate - 7 / 1440);

    gb_common.p_commit;

END p_getStatus;

-- Procedimiento de WS de Notificación, WS modo escucha que actualiza el estatus de una transacción de Place to Pay.
-- codigo desplegado bajo el nombre de PlacetoPay.war
--
procedure p_update_tzrpayu (p_request_id in varchar2, p_reference in varchar2, p_status in varchar2, p_message in varchar2, p_date in varchar2, p_signature in varchar2,  p_reponse_json in varchar2,  p_error_msg out varchar2 ) 
is
xsha1                       RAW (20);
v_pidm_oprd             TZRPAYU.TZRPAYU_PIDM_OPRD%type;
v_campus                 TZRPAYU.TZRPAYU_CAMPUS%type;
v_servicio                  TZRPAYU.tzrpayu_servicio%type;

cursor c_get_operador is
select TZRPAYU_PIDM_OPRD, TZRPAYU_CAMPUS, TZRPAYU_SERVICIO 
  from tzrpayu 
where TZRPAYU_REQUEST_ID = p_request_id
    and TZRPAYU_REFERENCE = p_reference;

cursor c_get_all_info is
select         TZRPAYU_PIDM, 
              TZRPAYU_SDOC_CODE, 
              TZRPAYU_DOC_NUMBER, 
              TZRPAYU_CAMPUS, 
              TZRPAYU_TERM,
              tzrpayu_PIDM_OPRD,
              TZRPAYu_SERVICIO, 
              TZRPAYu_PAY_DATE
  from tzrpayu 
where TZRPAYU_REQUEST_ID = p_request_id
    and TZRPAYU_REFERENCE = p_reference;



begin
        open c_get_operador;
        fetch c_get_operador into v_pidm_oprd,v_campus, v_servicio ;
        close c_get_operador;


        OPEN c_get_credentials (v_pidm_oprd, v_campus, v_servicio);
        FETCH c_get_credentials INTO p_endpoint, p_trankey, p_login;
        CLOSE c_get_credentials;


    SELECT sys.DBMS_CRYPTO.hash (
                       UTL_RAW.cast_to_raw (p_request_id ||p_status || p_date || p_trankey),
                       sys.DBMS_CRYPTO.hash_sh1)
    INTO xsha1
    FROM DUAL;


     IF upper(xsha1) = upper(p_signature) then
                 begin
                   update tzrpayu set TZRPAYU_STATUS = p_status , TZRPAYU_MESSAGE = p_message , TZRPAYU_RESPONSE_JSON = p_reponse_json,                   
                                                TZRPAYU_ACTIVITY_DATE = sysdate, TZRPAYU_USER_ID = user, TZRPAYU_DATA_ORIGIN = 'WS_NOTIFICATION'
                    where TZRPAYU_REQUEST_ID = p_request_id
                        and TZRPAYU_REFERENCE = p_reference
                        and TZRPAYU_PROCESSED_IND is null
                        and tzrpayu_servicio =  v_servicio
                        and TZRPAYU_RESPONSE_JSON is null
                        and not exists (select 'Y' from tzvoprd where TZVOPRD_PIDM = TZRPAYU_PIDM_OPRD and TZVOPRD_IDENTIFY_WS = 'KSK');

        p_ins_tzrrlog(v_pidm_oprd,  'PAGO_ONLINE', 'P2P Notification', 'p_status: '||p_status||' p_message: '||p_message||' sysdate: '||sysdate||' p_request_id: '||p_request_id||' p_reference: '||p_reference, user);

                        gb_common.p_commit;


                        p_error_msg := ''; 
                   exception when NO_DATA_FOUND then p_error_msg := 'NDF';
                                   when others then p_error_msg := 'ERR';
                   end;

        begin
        FOR reg IN c_get_all_info
        LOOP

          insert into taismgr.tzrpayh
            (
              TZRPAYH_PIDM, 
              TZRPAYH_SDOC_CODE, 
              TZRPAYH_DOC_NUMBER, 
              TZRPAYH_CAMPUS, 
              TZRPAYH_TERM, 
             TZRPAYH_STATUS,  
              TZRPAYH_MESSAGE, 
              TZRPAYH_REQUEST_ID, 
              TZRPAYH_REFERENCE, 
              TZRPAYH_activity_date ,
              tzrpayh_PIDM_OPRD,
              TZRPAYh_SERVICE, 
              TZRPAYh_PAY_DATE)
            values
            ( reg.TZRPAYU_PIDM, reg.TZRPAYU_SDOC_CODE , reg.TZRPAYU_DOC_NUMBER , reg.TZRPAYU_CAMPUS , reg.TZRPAYU_TERM,p_status,  p_message, p_request_id , p_reference,  sysdate, reg.tzrpayu_PIDM_OPRD, reg.tzrpayu_servicio, reg.tzrpayu_PAY_DATE);

           end loop;

            exception  when others then null;
             end;


     ELSE
           p_error_msg := 'SGF';
     END IF;

end;


function f_get_ordenamiento (p_TTVPAYT_CODE varchar2) return number is
v_value number (2);

cursor c_get_val is 
select getData(GORSDAV_VALUE)
from GORSDAV
where GORSDAV_TABLE_NAME = 'TTVPAYT' and GORSDAV_PK_PARENTTAB = p_TTVPAYT_CODE;

begin
open c_get_val;
fetch c_get_val into v_value;
close c_get_val;

return nvl(v_value,99);

end;

-- Funcion que valida si el documento esta pagado, con calculo interno del tipo de documento.
function f_doc_num_pagado (p_pidm number, p_doc_number number default null, p_trans varchar2 default null) return varchar2
is
val_ret varchar2(1):='';
v_doc_number  TVRSDOC.TVRSDOC_DOC_NUMBER%type;


cursor c_get_status (p_pidm number, p_doc_number number) is
select 'Y' from tzrdprf
              WHERE     tzrdprf_pidm = p_pidm
                           AND tzrdprf_doc_number = p_doc_number
                           and TZRDPRF_DOC_STATUS = 'ACEPTADO';

begin

IF p_doc_number is not null then
        v_doc_number := p_doc_number;
ELSIF p_doc_number is  null and p_trans is not null then
        OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
        FETCH c_get_data_i INTO p_sdoc_pref;
        CLOSE c_get_data_i;
        v_doc_number :=  tzkpufc.f_get_doc_number_r(p_pidm, p_trans,p_sdoc_pref);
ELSE
        v_doc_number := null;
END IF;

IF v_doc_number is not null then
    OPEN c_get_status(p_pidm, v_doc_number);
    fetch c_get_status into val_ret;
    CLOSE c_get_status;
END IF;

    return nvl(val_ret,'N');

end;

-- Funcion que valida si un documento ya fue pagado. 
-- Revisa el estatus del documento en la tabla TZRDPRF de bancos.
--
function f_doc_num_pagado_dprf(p_pidm number, p_sdoc_code varchar2 default null, p_doc_number varchar2) return varchar2
is
v_status TZRDPRF.TZRDPRF_DOC_STATUS%type;

cursor c_get_status is
select TZRDPRF_DOC_STATUS from tzrdprf
              WHERE     tzrdprf_pidm = p_pidm
                           AND tzrdprf_doc_number = p_doc_number;

begin
open c_get_status;
fetch c_get_status into v_status;
close c_get_status;

IF v_status = 'ACEPTADO' then
v_status := 'Y';
ELSE
v_status := 'N';
END IF;

return v_status;

end;

-- Procedimiento que inserta el encabezado del documento de venta, tabla TVBSDOC.
--
procedure p_insert_tvbsdoc (p_sdoc_code varchar2,
                                     p_doc_number varchar2,
                                     p_pidm number,
                                     p_prefix_1 varchar2,
                                     p_prefix_2 varchar2,
                                     p_int_doc_number number,
                                     p_comments varchar2,
                                     p_user_id varchar2,
                                     p_data_origin varchar2,
                                     p_date date,
                                     p_print_pidm number,
                                     p_print_id varchar2,
                                     p_print_id_source varchar2,
                                     p_atyp_code varchar2,
                                     p_msg_out out varchar2) is

begin
INSERT INTO tvbsdoc (tvbsdoc_sdoc_code,
                                     tvbsdoc_doc_number,
                                     tvbsdoc_pidm,
                                     tvbsdoc_prefix_1,
                                     tvbsdoc_prefix_2,
                                     tvbsdoc_int_doc_number,
                                     tvbsdoc_comments,
                                     tvbsdoc_user_id,
                                     tvbsdoc_data_origin,
                                     tvbsdoc_date,
                                     tvbsdoc_print_pidm,
                                     tvbsdoc_print_id,
                                     tvbsdoc_print_id_source,
                                     tvbsdoc_atyp_code,
                                     tvbsdoc_activity_date)
                     VALUES (p_sdoc_code,
                             p_doc_number,
                             p_pidm,
                             p_prefix_1,
                             p_prefix_2,
                             p_int_doc_number,
                             p_comments,
                             p_user_id,
                             p_data_origin,
                             p_date,
                             p_print_pidm,
                             p_print_id,
                             p_print_id_source,
                             p_atyp_code,
                             SYSDATE);
 p_msg_out := null;
EXCEPTION WHEN OTHERS THEN
p_msg_out := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
END;

-- Procedimiento que inserta el detalle del documento de venta, tabla TVRSDOC.
--
procedure p_insert_tvrsdoc (p_pidm number ,
                                         p_pay_tran_number number,
                                         p_chg_tran_number number,
                                         p_doc_number varchar2,
                                         p_doc_type varchar2,
                                         p_int_doc_number number,
                                         p_user_id varchar2,
                                         p_data_origin varchar2,
                                         p_comments varchar2,
                                         p_sdoc_code varchar2,
                                         p_msg_out out varchar2)
IS
BEGIN
INSERT INTO tvrsdoc (tvrsdoc_pidm,
                                         tvrsdoc_pay_tran_number,
                                         tvrsdoc_chg_tran_number,
                                         tvrsdoc_doc_number,
                                         tvrsdoc_doc_type,
                                         tvrsdoc_int_doc_number,
                                         tvrsdoc_user_id,
                                         tvrsdoc_data_origin,
                                         tvrsdoc_comments,
                                         tvrsdoc_sdoc_code,
                                         tvrsdoc_activity_date)
                         VALUES (p_pidm,
                                         p_pay_tran_number,
                                         p_chg_tran_number,
                                         p_doc_number,
                                         p_doc_type,
                                         p_int_doc_number,
                                         p_user_id,
                                         p_data_origin,
                                         p_comments,
                                         p_sdoc_code,
                                         sysdate);
p_msg_out := null;                                         
EXCEPTION WHEN OTHERS THEN
p_msg_out := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
END;                                 

-- Procedimiento que inserta la información de la prefactura en la tabla TZRFACT.
--
procedure p_insert_tzrfact_fact (p_PIDM number,p_SDOC_CODE varchar2,p_DOC_NUMBER varchar2,p_CURR_PROGRAM varchar2,p_SALE_DOCNUM varchar2,p_DET_CODE_DOC varchar2,p_AMNT_TRANS number,p_TRAN_NUM number,p_SRI_DOCNUM varchar2,p_RECEIPT_NUM number, p_FACT_DATE date,p_ACTIVITY_DATE date,p_USER varchar2,  p_term_code varchar2
,p_TRDPARTY_ID varchar2 default null, p_TRDPARTY_PIDM number default null, p_TRDPARTY_NAME varchar2 default null, p_STPERDOC_QTY varchar2 default null)
IS
cursor c_get_campus is 
select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(p_DOC_NUMBER,7,1);

p_campus varchar2(30);

BEGIN
open c_get_campus;
fetch c_get_campus into p_campus;
close c_get_campus;


Insert into TZRFACT (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_DOC_NUMBER,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_SALE_DOCNUM,TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM,TZRFACT_SRI_DOCNUM,TZRFACT_RECEIPT_NUM, TZRFACT_FACT_DATE,TZRFACT_ACTIVITY_DATE,TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY, TZRFACT_CAMPUS) 
--values ( p_PIDM,p_SDOC_CODE,p_DOC_NUMBER,gb_common.f_get_id(p_PIDM),p_CURR_PROGRAM,p_SALE_DOCNUM,p_DET_CODE_DOC,p_AMNT_TRANS,p_TRAN_NUM,p_SRI_DOCNUM,p_RECEIPT_NUM, p_FACT_DATE,p_ACTIVITY_DATE,p_USER, p_term_code, p_TRDPARTY_ID, p_TRDPARTY_PIDM, p_TRDPARTY_NAME, p_STPERDOC_QTY, p_campus);
--acastillo actualiza act_date
values ( p_PIDM,p_SDOC_CODE,p_DOC_NUMBER,gb_common.f_get_id(p_PIDM),p_CURR_PROGRAM,p_SALE_DOCNUM,p_DET_CODE_DOC,p_AMNT_TRANS,p_TRAN_NUM,p_SRI_DOCNUM,p_RECEIPT_NUM, p_FACT_DATE,sysdate,p_USER, p_term_code, p_TRDPARTY_ID, p_TRDPARTY_PIDM, p_TRDPARTY_NAME, p_STPERDOC_QTY, p_campus);

exception when others then 
p_ins_tzrrlog(p_pidm,  'GENERA_PREFACTURA', 'INS_TZRFACT', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);

END;


procedure p_ins_tvrmlcb_temp(p_SESSION_ID varchar2, p_PIDM number, p_TRAN_ORIGINAL number, p_doc_number varchar2, p_folio_factura varchar2 ) IS
cursor c_get_temp is
select 'Y' from tvrmlcb_temp where TVRMLCB_SESSION_ID = p_SESSION_ID;

v_existe varchar2(1);

BEGIN
OPEN c_get_temp;
FETCH c_get_temp into v_existe;
CLOSE c_get_temp;

insert into tvrmlcb_temp (TVRMLCB_SESSION_ID, TVRMLCB_PIDM, TVRMLCB_TRAN_ORIGINAL, TVRMLCB_DOC_NUMBER, TVRMLCB_SRI_DOC_NUMBER, tvrmlcb_activity_date) 
                           values (p_SESSION_ID, p_PIDM, p_TRAN_ORIGINAL, p_doc_number, p_folio_factura, sysdate);

exception when others then null;
END;


procedure p_del_tvrmlcb_temp(p_SESSION_ID varchar2 ) is
begin
 delete tvrmlcb_temp where TVRMLCB_SESSION_ID = p_SESSION_ID;
 exception when others then null;
end;


function f_get_temp_doc_number (p_SESSION_ID varchar2, p_type varchar2) return varchar2 is
cursor c_get_doc is
select TVRMLCB_DOC_NUMBER, TVRMLCB_SRI_DOC_NUMBER from tvrmlcb_temp where TVRMLCB_SESSION_ID = p_SESSION_ID  and TVRMLCB_DOC_NUMBER is not null
and tvrmlcb_activity_date = (select max(tvrmlcb_activity_date) from tvrmlcb_temp where TVRMLCB_SESSION_ID = p_SESSION_ID  and TVRMLCB_DOC_NUMBER is not null);

v_doc varchar2(19):='';
v_sri_doc varchar2(20):='';

begin
   open c_get_doc;
   fetch c_get_doc into v_doc, v_sri_doc;
   close c_get_doc;

   IF p_type = 'DOC_NUM' then
   return v_doc;
   ELSE
   return v_sri_doc;
   END IF;

end;


procedure p_upd_TZRDPRF(p_PIDM number,p_DOC_NUMBER varchar2)
IS
BEGIN

update TZRDPRF 
      set TZRDPRF_DOC_STATUS = 'ACEPTADO'
          , TZRDPRF_DATA_ORIGIN = 'TVACAJA'
          , TZRDPRF_PAY_DATE = sysdate
 where TZRDPRF_PIDM = p_PIDM 
     and TZRDPRF_DOC_NUMBER = p_DOC_NUMBER
     and TZRDPRF_DOC_STATUS = 'CREADO';

EXCEPTION WHEN OTHERS THEN
p_ins_tzrrlog(p_pidm,  'GENERA_FACTURA', 'UPD_TZRDPRF', 'P_DOC_NUMBER: '|| p_DOC_NUMBER ||SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);

END;


procedure p_upd_sri_doc_num (p_PIDM number,p_DOC_NUMBER varchar2, p_sri_doc_num varchar2, p_pay_tran_num number default null )
IS

BEGIN

IF p_pay_tran_num is not null then
    update tzrfact set TZRFACT_SRI_DOCNUM = p_sri_doc_num
                                             where tzrfact_pidm = p_PIDM and TZRFACT_DOC_NUMBER = p_DOC_NUMBER  and TZRFACT_SRI_DOCNUM is null
                                            and exists (select 'Y' from tbbdetc where tbbdetc_detail_code = TZRFACT_DET_CODE_DOC  and TBBDETC_TYPE_IND = 'C' )
                                            and TZRFACT_TRAN_NUM IN (select TBRAPPL_CHG_TRAN_NUMBER from tbrappl where tbrappl_pidm = p_PIDM and TBRAPPL_PAY_TRAN_NUMBER = p_pay_tran_num and TBRAPPL_REAPPL_IND is null);
ELSE
    update TZRFACT
    set TZRFACT_SRI_DOCNUM = p_sri_doc_num
    where 
    TZRFACT_PIDM = p_PIDM
    and TZRFACT_DOC_NUMBER = p_DOC_NUMBER
    and TZRFACT_SRI_DOCNUM is  null;
END IF;


EXCEPTION WHEN OTHERS THEN
kzkawrd.p_log (in_seq_no =>0,
                       in_user_id=>user,
                       in_comments=> SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500)||' p_upd_sri_doc_num- p_PIDM:'||p_PIDM||' p_sri_doc_num:'|| p_sri_doc_num||' p_doc_num:'||p_DOC_NUMBER||' p_pay_tran_num:'||p_pay_tran_num,
                       p_tipo=> 'E',
                       p_pidm=>p_PIDM,
                       p_term_code =>substr(p_DOC_NUMBER,1,6));

END;

-- Funcion principal que retorna los valores de programa, nivel, campus del estudiante
-- utiliza la vista sovlcur de base con tres formas de calculo de los atributos de retorno.
-- 
function f_get_sovlcur (p_pidm number, p_term_code varchar2, p_type varchar2 ) return varchar2 
IS
p_campus   SOVLCUR.SOVLCUR_CAMP_CODE%type;
p_level       SOVLCUR.SOVLCUR_LEVL_CODE%type;
p_program  SOVLCUR.SOVLCUR_PROGRAM%type;
p_term       SOVLCUR.SOVLCUR_TERM_CODE%type;
p_lmod       SOVLCUR.SOVLCUR_LMOD_CODE%type;


--Neoris hermes.navarro 
/*Cursor para obtener el programa con el plan de estudios registrado en el estado de cuenta
Para el estudiante y periodo indicado */
cursor c_plan_est is
SELECT SOVLCUR_TERM_CODE, SOVLCUR_LMOD_CODE, sovlcur_camp_code, sovlcur_levl_code, sovlcur_program
FROM sovlcur
WHERE SOVLCUR_PIDM = p_pidm
AND SOVLCUR_KEY_SEQNO = (   SELECT DISTINCT(TBRACCD_STSP_KEY_SEQUENCE )
                            FROM TBRACCD
                            WHERE TBRACCD_PIDM = p_pidm 
                            AND TBRACCD_TERM_CODE = p_term_code
                            AND TBRACCD_STSP_KEY_SEQUENCE IS NOT NULL
                            AND ROWNUM = 1)
and ROWNUM = 1 ;
/*SELECT DISTINCT(TVRACCD_STSP_KEY_SEQUENCE ) KEY_SEQUENCE
FROM TVRACCD
WHERE TVRACCD_PIDM = p_pidm 
AND TVRACCD_TERM_CODE = p_term_code
AND TVRACCD_STSP_KEY_SEQUENCE IS NOT NULL
AND ROWNUM = 1;*/
--Neoris hermes.navarro

cursor c_primaria is
select SOVLCUR_TERM_CODE term_code, SOVLCUR_LMOD_CODE lmod_code, sovlcur_camp_code camp_code, sovlcur_levl_code levl_code, sovlcur_program pprogram 
from sovlcur where sovlcur_PIDM = p_pidm
and SOVLCUR_LMOD_CODE in ('LEARNER','ADMISSIONS') 
and SOVLCUR_CURRENT_IND = 'Y' and SOVLCUR_ACTIVE_IND = 'Y'
and SOVLCUR_KEY_SEQNO = (select max( SFRSTCR_STSP_KEY_SEQUENCE)  keep (dense_rank first order by SFRSTCR_STSP_KEY_SEQUENCE desc) 
from SFRSTCR where SFRSTCR_PIDM =p_pidm  and SFRSTCR_TERM_CODE =  p_term_code);


cursor c_directa is
SELECT SOVLCUR_TERM_CODE term_code, SOVLCUR_LMOD_CODE lmod_code, sovlcur_camp_code camp_code, sovlcur_levl_code levl_code, sovlcur_program pprogram
          FROM sovlcur
         WHERE    
                      sovlcur_pidm = p_pidm
               AND sovlcur_term_code = p_term_code
               and SOVLCUR_LMOD_CODE in ('LEARNER','ADMISSIONS') 
               AND sovlcur_current_ind = 'Y'
               AND sovlcur_active_ind = 'Y';

cursor c_maxima is
SELECT SOVLCUR_TERM_CODE term_code, SOVLCUR_LMOD_CODE lmod_code, sovlcur_camp_code camp_code, sovlcur_levl_code levl_code, sovlcur_program pprogram
          FROM sovlcur
         WHERE 
                      sovlcur_pidm = p_pidm
               AND sovlcur_term_code =
                   (SELECT MAX (lcur.sovlcur_term_code)
                      FROM sovlcur lcur
                     WHERE     sovlcur.sovlcur_pidm = lcur.sovlcur_pidm
                           AND sovlcur.sovlcur_camp_code =
                               lcur.sovlcur_camp_code
                           AND sovlcur.sovlcur_program = lcur.sovlcur_program
                           AND sovlcur.sovlcur_lmod_code =
                               lcur.sovlcur_lmod_code
                          AND lcur.sovlcur_current_ind = 'Y'
                          AND lcur.sovlcur_active_ind = 'Y'
                           AND lcur.sovlcur_term_code <= p_term_code)
               AND (   
                      (    sovlcur_lmod_code =
                            sb_curriculum_str.f_admissions
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM sorlcur
                                  WHERE     sorlcur_pidm = sovlcur_pidm
                                        AND sorlcur_program = sovlcur_program
                                        AND sorlcur_lmod_code =
                                            sb_curriculum_str.f_learner))
                    OR sovlcur_lmod_code = sb_curriculum_str.f_learner)
               AND sovlcur_current_ind = 'Y'
               AND sovlcur_active_ind = 'Y';

v_max_term varchar2(10):='1';


cursor c_prog_by_key_seqno is
select  sovlcur_program 
from sovlcur where sovlcur_PIDM = p_pidm
--and SOVLCUR_LMOD_CODE in ('LEARNER','ADMISSIONS') 
--and SOVLCUR_CURRENT_IND = 'Y' and SOVLCUR_ACTIVE_IND = 'Y'
and SOVLCUR_KEY_SEQNO = p_term_code; -- utilizando el p_term como key_seqno


begin

IF p_type = 'PROGRAM_DIRECT'  THEN
    open c_prog_by_key_seqno;
    fetch c_prog_by_key_seqno into p_program;
    close c_prog_by_key_seqno;

    return p_program;

ELSE

    FOR pr IN c_primaria
    LOOP
        p_term := pr.TERM_CODE;
        p_lmod := pr.LMOD_CODE;
        p_campus := pr.CAMP_CODE;
        p_level := pr.LEVL_CODE;
        p_program := pr.PPROGRAM;
        IF pr.LMOD_CODE = 'LEARNER'  then          
            EXIT;         
        END IF;
    END LOOP;

    IF p_campus is null then
        open c_directa;
            fetch c_directa into p_term, p_lmod, p_campus, p_level, p_program;
        close c_directa;
    end if;

    IF p_campus is not null then 
        IF p_type = 'CAMPUS' then
            return p_campus;
        ELSIF p_type = 'LEVL' then
            return p_level;
        ELSIF p_type = 'PROGRAM' then
            return p_program;
        ELSIF p_type = 'TERM' then
            return p_term;
        ELSIF p_type = 'LMOD' then
            return p_lmod;
        ELSE
            return null;
        END IF;
    ELSE

        --Neoris hermes.navarro 
        /*Si llega a este punto y no se ha encontrado la información, se verifica
        en el cursor que obtiene el programa desde el plan de estudios registrado en el estado de cuenta
        para el estudiante en el periodo enviado como parametro*/
        open c_plan_est;
            fetch c_plan_est into p_term, p_lmod, p_campus, p_level, p_program;
        close c_plan_est;
            if p_program is not null then--and  p_type = 'PROGRAM' then
                --return p_program;
                IF p_type = 'CAMPUS' then
                    return p_campus;
                ELSIF p_type = 'LEVL' then
                    return p_level;
                ELSIF p_type = 'PROGRAM' then
                    return p_program;
                ELSIF p_type = 'TERM' then
                    return p_term;
                ELSIF p_type = 'LMOD' then
                    return p_lmod;
                ELSE
                    return null;
                END IF;
            end if;
        --Neoris hermes.navarro 

        FOR cmx IN c_maxima
        LOOP
            IF cmx.term_code = p_term_code then
                p_campus :=  cmx.camp_code;
                p_level :=  cmx.levl_code;
                p_program :=  cmx.pprogram;
                p_term :=  cmx.term_code;
                p_lmod := cmx.lmod_code;
            END IF;
        END LOOP;
        IF p_campus is not null then 
            IF p_type = 'CAMPUS' then
                return p_campus;
            ELSIF p_type = 'LEVL' then
                return p_level;
            ELSIF p_type = 'PROGRAM' then
                return p_program;
            ELSIF p_type = 'TERM' then
                return p_term;
            ELSIF p_type = 'LMOD' then
                return p_lmod;
            ELSE
                return null;
            END IF;    
        ELSE

        FOR cmx IN c_maxima
        LOOP
            IF  v_max_term < cmx.term_code then
                p_campus :=  cmx.camp_code;
                p_level :=  cmx.levl_code;
                p_program :=  cmx.pprogram;
                p_term :=  cmx.term_code;
                p_lmod := cmx.lmod_code;
            END IF;
        END LOOP;

        IF p_type = 'CAMPUS' then
            return p_campus; 
        ELSIF p_type = 'LEVL' then
            return p_level;
        ELSIF p_type = 'PROGRAM' then
            return p_program;
        ELSIF p_type = 'TERM' then
            return p_term;
        ELSIF p_type = 'LMOD' then
            return p_lmod;
        ELSE
            return null;
        END IF;  
    END IF; 

    END IF;

END IF;

exception when no_data_found then return null;
                when others then return null;
end f_get_sovlcur;

function f_get_sovlcur_xp (p_pidm number, p_stsp number ) return varchar2 
IS

p_program  SOVLCUR.SOVLCUR_PROGRAM%type;


cursor c_directa is
SELECT sovlcur_program pprogram
          FROM sovlcur
			WHERE    
                      sovlcur_pidm = p_pidm
               AND SOVLCUR_KEY_SEQNO = p_stsp
               and SOVLCUR_LMOD_CODE in ('LEARNER','ADMISSIONS') 
               AND sovlcur_current_ind = 'Y'
               AND sovlcur_active_ind = 'Y'
               order by SOVLCUR_LMOD_CODE desc
			   fetch first 1 rows only;

v_max_term varchar2(10):='1';



begin

        open c_directa;
        fetch c_directa into p_program;
        close c_directa;

		return p_program;

exception when no_data_found then return null;
                when others then return null;
end f_get_sovlcur_xp;

--Hall de pagos para estudiantes con opciones de búsqueda por ID, Cédula y Prefactura a pagar. Sin firma en autoservicios de Banner.
-- 
procedure p_pay_hall_ns (p_type varchar2 default null, p_val varchar2 default null, op varchar2 default null) IS
p_pidm number;
p_doc_number varchar2(50);
p_habilitado varchar2(1);
p_get_enc_url varchar2(1000);
p_cnt_doc number:= 0;
p_doc_amount number;


p_nombre_estudiante varchar2(400);

pstyle varchar2(3000):= 
'<style>
body, td, p, h2, input {
	font-family: Arial, Helvetica, sans-serif;
}

input {
	font-size:15px;
	margin:5px; 
	padding:5px 10px;
}

table {
	border:0 !important;
	font-size:12px;
}

td, th {
	border:0;
	padding:7px;
	margin:3px;
	background-color:#DDD;
}

th {
	font-size:15px;
}
</style>'; 

cursor c_cnt_doc is
select count(0)                   
                   from SPBPERS, tzrdprf, spriden
                where SPBPERS_PIDM =  tzrdprf_pidm
                    and SPBPERS_PIDM = spriden_pidm
                    and SPRIDEN_CHANGE_IND is null
                    and TZRDPRF_DOC_STATUS = 'CREADO'
                    and exists (select 'Y' from tvbsdoc where tvbsdoc_pidm = tzrdprf_pidm and TVBSDOC_DOC_NUMBER = TZRDPRF_DOC_NUMBER and TVBSDOC_DOC_CANCEL_IND is null )
                    and  (CASE WHEN p_TYPE = 'C' AND SPBPERS_SSN = p_val
                                  THEN 1
                                    WHEN p_TYPE = 'I' AND  spriden_id = p_val 
                                  THEN 1
                                    WHEN p_TYPE = 'P' AND  TZRDPRF_PREF_DOC_NUMBER = p_val 
                                  THEN 1
                                ELSE 0
                            END) = 1
                            ;

cursor c_get_data is
select SPBPERS_PIDM, TZRDPRF_DOC_NUMBER, TZRDPRF_DOC_AMOUNT                  
                   from SPBPERS, tzrdprf, spriden
                where SPBPERS_PIDM =  tzrdprf_pidm
                    and SPBPERS_PIDM = spriden_pidm
                    and SPRIDEN_CHANGE_IND is null
                    and TZRDPRF_DOC_STATUS = 'CREADO'
                    and exists (select 'Y' from tvbsdoc where tvbsdoc_pidm = tzrdprf_pidm and TVBSDOC_DOC_NUMBER = TZRDPRF_DOC_NUMBER and TVBSDOC_DOC_CANCEL_IND is null )
                    and  (CASE WHEN p_TYPE = 'C' AND SPBPERS_SSN = p_val
                                  THEN 1
                                    WHEN p_TYPE = 'I' AND  spriden_id = p_val 
                                  THEN 1
                                    WHEN p_TYPE = 'P' AND  TZRDPRF_PREF_DOC_NUMBER = p_val 
                                  THEN 1
                                ELSE 0
                            END) = 1
                            ;

BEGIN



if op IS NULL THEN
     htp.formOpen('tzkpufc.p_pay_hall_ns',cattributes=>'name="tzkpufc" style= "text-align:center;font-size:15px;font-family:Arial, Helvetica, sans-serif;"'); 
     htp.formHidden('op','');
     htp.p('<form action="tzkpufc.p_pay_hall_ns" method="post">');
     htp.center('<h2> Seleccione el método de búsqueda </h2>');
     htp.center('<input type="radio" name="p_type" value="C" id="p_type_c"> Cédula/Pasaporte <input type="radio" name="p_type" value="I" id="p_vt_type_i"> ID Banner <input type="radio" name="p_type" value="P" id="p_vt_type_p"> Prefactura');
     htp.center('<input type="text" value="" size="20" maxlength="20" name= "p_val" width="85">');     
     htp.center( '<input type=button value="Buscar" onclick=f_recorre(this.form); >' );       
     htp.br;
     htp.formClose;


    htp.p('
   <script languaje="JAVASCRIPT">      
       function f_recorre(forma)
        {            

    myOption=-1;
      for(i=forma.p_type.length-1; i > -1; i--)
      {
        if(forma.p_type[i].checked)
        {
          //alert(forma.p_type[i].value); return;
          myOption = i;
          i = -1;
        }
      }

		   if(myOption == -1)
		     {
			  alert("Favor seleccionar un Tipo de Búsqueda.");
			  return;
			 }

    if(forma.p_val.value=="")
           { alert("Favor digitar en el recuadro el valor a buscar.");
             forma.p_val.focus();
             return;
           }    

    forma.op.value="grabar";
    forma.submit();
  }        
 </script>
 ');

 ELSif op = 'grabar' THEN


            OPEN c_get_data_i ('PUCE_FACT', 'HALL_IND', 'EXT');
            FETCH c_get_data_i INTO p_habilitado;
            CLOSE c_get_data_i;

        IF p_habilitado = 'Y' then
           htp.formOpen('tzkpufc.p_pay_hall_ns',cattributes=>'name="PagoEnLinea" style= "text-align:center;font-size:15px;font-family:Arial, Helvetica, sans-serif;"'); 
htp.p (pstyle);  


           open c_cnt_doc;
           fetch c_cnt_doc into  p_cnt_doc;
           close c_cnt_doc;

                p_ins_tzrrlog(p_pidm,  'PAGO_ONLINE', 'HALL_PAGOS', 'Valores de búsqueda. Tipo:' ||p_TYPE || ', Valor:'|| p_val, user);

             if p_cnt_doc = 0 then
                    HTP.p ( '<th> <font color=red> Datos ingresados no retornan ningún valor. </font> </th>');
                    htp.br;
                    htp.p('Presione <a href="" onClick="history.back()">aquí</a> para regresar a la ventana anterior. '); 
             ELSE


                    htp.tableOpen(' border=1',cattributes=> 'align="Center" ');   
                    htp.center('<h2> Seleccione la prefactura que desee pagar </h2>');
                    htp.tablerowopen;		  
                    htp.tabledata('<b>Prefactura</b>');
                    htp.tabledata('<b>Nombre</b>');
                    htp.tabledata('<b>Monto</b>');
                    htp.tabledata('<b>Ver</b>');
                    htp.tabledata('<b>Seleccionar</b>');
                    htp.tablerowclose;

                    FOR k in c_get_data LOOP
                        HTP.TABLEROWOPEN;
                        HTP.TABLEDATA(f_get_docnum_fmt (k.TZRDPRF_DOC_NUMBER));
                        HTP.TABLEDATA(f_format_name (k.SPBPERS_PIDM, 'FMIL'));
                        HTP.TABLEDATA(k.TZRDPRF_DOC_AMOUNT);
                        htp.p('<td> <a href="'|| 'tzkpufc.p_show_pdf?p_pidm='
                                || k.SPBPERS_PIDM
                                || '&p_doc_number='
                                || k.TZRDPRF_DOC_NUMBER
                                || ' '
                                || '" target="_blank" style="text-decoration: none;"> PDF
                                                           </a></td>');                    

                        p_get_enc_url := tzkpufc.f_get_url_pay(k.SPBPERS_PIDM,k.TZRDPRF_DOC_NUMBER);
                        htp.p('<td> <a href="'||p_get_enc_url||'"  target="_blank"> Ir </a></td>');                    
                        HTP.TABLEROWCLOSE;
                    END LOOP;
                    HTP.TABLECLOSE;

                  htp.p('</p>');
                  htp.br;
                  htp.p('Presione <a href="" onClick="history.back()">aquí</a> para regresar a la ventana anterior. ');                   
          END IF;
          htp.formClose;
         ELSE
                HTP.p ( '<th> <font color=red> Método de búsqueda deshabilitado. </font> </th>');
        END IF; 


END IF;


END;

-- Pagina de pago en línea para proceso de Admisiones.

procedure p_pay_adm_ns (p_val varchar2) IS


        CURSOR c_get_pdf_img (img_name twgbimag.twgbimag_name%TYPE)
        IS
            SELECT twgbimag_image_url, TWGBIMAG_STATUS_BAR, TWGBIMAG_DESC
              FROM twgbimag
             WHERE TWGBIMAG_ALT= img_name;

        lv_pdf_image   twgbimag.twgbimag_image_url%TYPE := '';
        lv_href_img TWGBIMAG.TWGBIMAG_STATUS_BAR%TYPE := '';
        lv_title_img TWGBIMAG.TWGBIMAG_DESC%TYPE := '';
        lv_franc_img    twgbimag.twgbimag_image_url%TYPE := '';
        lv_master_img  twgbimag.twgbimag_image_url%TYPE := '';
        lv_xml_image   twgbimag.twgbimag_image_url%TYPE := '';

        p_pidm number;
        p_doc_num varchar2(30);

        CURSOR c_get_providers (
            p_sede    VARCHAR2)
        IS
            SELECT spriden_last_name proveedor,
                   stvcamp_desc      sede,
                   tzvoprd_endpoint  endpoint,
                   tzvoprd_trankey   trankey,
                   tzvoprd_login     login,
                   tzvoprd_pidm,
                   TZVOPRD_SERV servicio,
                   TZVOPRD_IDENTIFY_WS iden_ws
              FROM spriden, tzvoprd, stvcamp
             WHERE     spriden_pidm = tzvoprd_pidm
                   AND stvcamp_code = tzvoprd_camp_code
                   AND tzvoprd_camp_code = NVL (p_sede, tzvoprd_camp_code)
                   AND spriden_change_ind IS NULL
                   AND spriden_entity_ind = 'C'
                   AND TRUNC (SYSDATE) BETWEEN tzvoprd_start_date
                                           AND tzvoprd_end_date;

        p_status             TZRPAYU.TZRPAYU_STATUS%type;
        p_REQUEST_ID   TZRPAYU.TZRPAYU_REQUEST_ID%type;
        p_reference       TZRPAYU.TZRPAYU_REFERENCE%type;
        p_message         TZRPAYU.TZRPAYU_MESSAGE%type;


      cursor c_valida ( p_pidm number, p_pidm_oprd number,  p_campus varchar2,  p_doc_number varchar2, p_servicio varchar2 ) is  
       select TZRPAYU_STATUS, TZRPAYU_REQUEST_ID, TZRPAYU_REFERENCE, TZRPAYU_MESSAGE
            from tzrpayu 
            where  TZRPAYU_PIDM = p_pidm
              and TZRPAYU_PIDM_OPRD = p_pidm_oprd
              and TZRPAYU_CAMPUS = p_campus
              and TZRPAYU_DOC_NUMBER = p_doc_number
              and TZRPAYU_servicio = p_servicio;


        cursor c_get_mensajes (p_doc_number varchar2 ) is  
        select TZRPAYH_DOC_NUMBER,TZRPAYH_TERM , TZRPAYH_STATUS, decode(TZRPAYH_STATUS, 'OK','Solicitud en proceso, favor de validar en unos momentos.',TZRPAYH_MESSAGE) TZRPAYH_MESSAGE, TZRPAYH_REQUEST_ID, TZRPAYH_REFERENCE, to_char(TZRPAYH_ACTIVITY_DATE,'DD-MON-YYYY HH24:MI:SS') TZRPAYH_ACTIVITY_DATE
         from TZRPAYH
         where TZRPAYH_DOC_NUMBER = p_doc_number            
           order by   TZRPAYH_ACTIVITY_DATE  desc ;


         cursor c_get_status ( p_pidm number,  p_doc_number varchar2 ) is  
          select a1.TZRPAYU_REFERENCE
             from tzrpayu  a1
            where  a1.TZRPAYU_PIDM = p_pidm
                and  a1.TZRPAYU_DOC_NUMBER = p_doc_num
                and a1.TZRPAYU_pay_date = (select max(b1.tzrpayu_pay_date) 
                                                            from tzrpayu b1
                                                            where  b1.TZRPAYU_PIDM = a1.TZRPAYU_PIDM
                                                              and b1.TZRPAYU_DOC_NUMBER = a1.TZRPAYU_DOC_NUMBER
                                                              ) ; 

           p_reference_1 TZRPAYU.TZRPAYU_REFERENCE%type;

        p_estatus      sgbstdn.sgbstdn_stst_code%TYPE;
        p_area         sgbstdn.sgbstdn_program_1%TYPE;
        p_doc_number   tvrsdoc.tvrsdoc_doc_number%TYPE;

        p_port           varchar2(30);
        p_instance     varchar2(30);

        p_enc_key      varchar2(15);

    BEGIN

        BEGIN 
        OPEN c_get_data_i ('PUCE_FACT', 'ENC_KEY', 'EXT');
                FETCH c_get_data_i INTO p_enc_key;
                CLOSE c_get_data_i;

        p_pidm := to_number(tzkpufc.f_decrypt (substr(p_val,1,instr(p_val, '-')-1), p_enc_key));
        p_doc_num := to_number(tzkpufc.f_decrypt (substr(p_val,instr(p_val, '-')+1, length(p_val)), p_enc_key));

        IF tzkpufc.f_doc_num_pagado(p_pidm, p_doc_num) = 'Y' then
               OPEN c_get_status (p_pidm, p_doc_num);
                FETCH c_get_status INTO p_reference_1;
                CLOSE c_get_status;

        htp.p('El documento con referencia: '||p_reference_1|| ' ya ha sido pagado.');        
        RETURN;
        END IF;

        EXCEPTION WHEN OTHERS THEN
        htp.p('INVALID KEY');        
        RETURN;
        END;


        bwckfrmt.p_open_doc ('tzkpufc.p_pay_adm_ns');
        twbkfrmt.p_paragraph (1);
        twbkwbis.p_dispinfo ('tzkpufc.p_pay_adm_ns', 'DEFAULT');



        htp.p('
                <script>
            function myFunction( p_oprd_pidm,  p_pidm, p_sede, p_sdoc_pref, p_doc_num, p_term,p_servicio, p_iden_ws ) {
              var r = confirm("Acepta los términos y condiciónes");
              if (r == true) {
                //form.submit();
                   var url = ''tzkpufc.ws_p2p?p_pidm_oprd='' + p_oprd_pidm
                   + ''&p_pidm=''         + p_pidm
                   + ''&p_sede=''         + p_sede
                   + ''&p_sdoc_code=''         + p_sdoc_pref
                   + ''&p_doc_number=''         + p_doc_num
                   + ''&p_term=''         + p_term
                   + ''&p_servicio=''         + p_servicio
                   + ''&p_iden_ws=''         + p_iden_ws
                   + ''&p_url_return=''         + "R"
                   + '' '';

                   //var myWindow = window.open(url, ''MsgWindow'', ''height=768,width=1024,resizable=yes,scrollbars=yes,toolbar=yes,menubar=yes,location=yes'');
                   var myWindow = window.open(url, ''_self'');

              } else {
                txt = "You pressed Cancel!";
              }
            }
            </script>    
                ');


        p_sede        := f_get_sovlcur(p_pidm,substr(p_doc_num,1,6) , 'CAMPUS' );

       OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
                FETCH c_get_data_i INTO p_sdoc_pref;
                CLOSE c_get_data_i;



        twbkfrmt.p_tableopen ('DATADISPLAY',
                              ccaption   => 'Selección de Proveedor');


        twbkfrmt.p_tabledataheader ('Proveedor');
        twbkfrmt.p_tabledataheader ('Sede');
        twbkfrmt.p_tabledataheader ('Prefactura');
        twbkfrmt.p_tabledataheader ('Tipo de Servicio');
        twbkfrmt.p_tabledataheader ('Ir');


        FOR rec_provider IN c_get_providers (p_sede)
        LOOP
            IF c_get_providers%FOUND
            THEN

                   p_status := ''; 
                   p_REQUEST_ID:= ''; 
                   p_reference:= ''; 
                   p_message:= '';

                    OPEN c_valida ( p_pidm, rec_provider.tzvoprd_pidm , p_sede, p_doc_num, rec_provider.servicio );
                    FETCH c_valida INTO p_status, p_REQUEST_ID, p_reference, p_message;
                    CLOSE c_valida;

                    lv_pdf_image:= '';
                    lv_href_img:= ''; 
                    lv_title_img:= '';
                    OPEN c_get_pdf_img (gb_common.f_get_id(rec_provider.tzvoprd_pidm));
                    FETCH c_get_pdf_img into lv_pdf_image, lv_href_img, lv_title_img;
                    CLOSE c_get_pdf_img;



                twbkfrmt.p_tablerowopen ();
                twbkfrmt.p_tabledata ('<a href=" '||lv_href_img||'" ><img src=" '||lv_pdf_image||' " title="'||lv_title_img||'" width="70" height="20" />  </a>');
                twbkfrmt.p_tabledata (rec_provider.sede);
                twbkfrmt.p_tabledata (f_get_docnum_fmt (p_doc_num));
                twbkfrmt.p_tabledata (rec_provider.servicio);


open c_get_sdoc_code_val (p_pidm,p_doc_num,p_sede,substr(p_doc_num,1,6)) ;
fetch c_get_sdoc_code_val into p_sdoc_code_val;
close c_get_sdoc_code_val;


--open c_get_doc_fecha_valida (p_pidm,p_doc_num) ;
open c_get_doc_fecha_valida (p_doc_num) ;
fetch c_get_doc_fecha_valida into p_fecha_vigencia_valida;
close c_get_doc_fecha_valida;

                --ACASTILLO control temporal para proceso de borrado
                open c_dat_prefac (p_doc_num) ;
                fetch c_dat_prefac into p_term_pref,p_camp_pref;
                close c_dat_prefac;

                v_get_borrado := 'N';
                v_get_desc_borr := '';
                open c_get_borrado (p_term_pref, p_camp_pref);
                fetch c_get_borrado into v_get_borrado, v_get_desc_borr;
                close c_get_borrado;

                IF nvl(p_fecha_vigencia_valida,'N') = 'N' THEN
                    p_status := 'VENCIDO';
                END IF;

                IF v_get_borrado = 'Y' THEN
                    p_status := 'SUSPENDED';
                END IF;
                --

                IF p_status is null or p_status = 'REJECTED' or p_status = 'FAILED' then

                   HTP.p ( '<th> <button type = "button" onclick="myFunction('''||rec_provider.tzvoprd_pidm||''','''||p_pidm||''','''||p_sede||''','''||p_sdoc_pref||''','''||p_doc_num||''','''||substr(p_doc_num,1,6)||''','''||rec_provider.servicio||''','''||rec_provider.iden_ws||''')">Pagar</button> </th>');

                    ELSIF p_status = 'PENDING' then
                    twbkfrmt.p_tabledata('Referencia:' || p_reference ||'. '||p_message);
                    ELSIF p_status = 'APPROVED' then
                    twbkfrmt.p_tabledata('Referencia:' || p_reference ||'. '||p_message);
                    ELSIF p_status = 'VENCIDO' then
                    twbkfrmt.p_tabledata(' Prefactura Vencida');
                    ELSIF p_status = 'SUSPENDED' then
                    twbkfrmt.p_tabledata(v_get_desc_borr);    
                    ELSIF p_status = 'KUSHKI' then
                    twbkfrmt.p_tabledata('Referencia:' || p_reference ||'. '||'La petición se encuenta en proceso, valide en unos minutos su estado.');
                    ELSE 
                    twbkfrmt.p_tabledata(' Referencia:' || p_reference ||' Estatus:'||p_status||'. '||p_message);
                   END IF;

                twbkfrmt.p_tablerowclose;
            ELSE
                IF c_get_providers%ROWCOUNT = 0
                THEN
                    twbkfrmt.p_printmessage (
                        'No se han encontrado proveedores configurados',
                        'WARNING');
                END IF;

                EXIT;
            END IF;
        END LOOP;


        twbkfrmt.p_tableclose ();
        HTP.p (p_error_msg);
        HTP.br;
        HTP.br;

        twbkfrmt.p_tableopen ('DATADISPLAY',
                              ccaption   => 'Historial de Pagos');

        twbkfrmt.p_tabledataheader ('Numero Documento');
        twbkfrmt.p_tabledataheader ('Periodo');
        twbkfrmt.p_tabledataheader ('Estatus');
        twbkfrmt.p_tabledataheader ('Mensaje');
        twbkfrmt.p_tabledataheader ('Request ID');
        twbkfrmt.p_tabledataheader ('Referencia');
        twbkfrmt.p_tabledataheader ('Fecha');


        FOR rec_msg IN c_get_mensajes (p_doc_num)
        LOOP
                twbkfrmt.p_tablerowopen ();
                twbkfrmt.p_tabledata (rec_msg.TZRPAYH_DOC_NUMBER);
                twbkfrmt.p_tabledata ( rec_msg.TZRPAYH_TERM);
                twbkfrmt.p_tabledata (rec_msg.TZRPAYH_STATUS);
                twbkfrmt.p_tabledata ( rec_msg.TZRPAYH_MESSAGE);
                twbkfrmt.p_tabledata (rec_msg.TZRPAYH_REQUEST_ID);
                twbkfrmt.p_tabledata (rec_msg.TZRPAYH_REFERENCE);
                twbkfrmt.p_tabledata (rec_msg.TZRPAYH_ACTIVITY_DATE);
        END LOOP;

        twbkfrmt.p_tableclose ();
        HTP.br;
        HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/detalles-ptp-discover.php"  target="_blank"> Información Place to Pay Discover </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/detalles-ptp.php"  target="_blank"> Información Place to Pay </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/detalles-kushki.php"  target="_blank"> Información Kushki </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/preguntas-frecuentes-ptp.php"  target="_blank"> Preguntas Frecuentes </a>'); HTP.br;
        htp.p('<a href="https://www.puce.edu.ec/assets/pages/banner/pagos/terminos-y-condiciones.php"  target="_blank"> Términos y Condiciones </a>'); 

        HTP.br;
        HTP.br;
        OPEN c_get_pdf_img ('franc');
                    FETCH c_get_pdf_img into lv_franc_img, lv_href_img, lv_title_img;
                    CLOSE c_get_pdf_img;

         OPEN c_get_pdf_img ('master');
                    FETCH c_get_pdf_img into lv_master_img, lv_href_img, lv_title_img;
                    CLOSE c_get_pdf_img;           

        htp.p('<a ><img src=" '||lv_franc_img||' " title="Franquicias" width="420" height="40" />  </a>');
        htp.p('<a ><img src=" '||lv_master_img||' " title="Franquicias" width="65" height="35" />  </a>');
        htp.br;
        htp.p('Presione <a href="" onClick="window.close()">aquí</a> para cerrar esta ventana. ');                   
        twbkwbis.p_closedoc ();

END;


-- Funcion que retorna la URL encriptada para proceso de pago en línea.
--
function f_get_url_pay (p_pidm number, p_doc_num varchar2) return varchar2 IS
p_enc_key  varchar2(15);

BEGIN
        OPEN c_get_data_i ('PUCE_FACT', 'URL_PAY', 'COM');
        FETCH c_get_data_i INTO p_url;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'ENC_KEY', 'EXT');
                FETCH c_get_data_i INTO p_enc_key;
                CLOSE c_get_data_i;

return(p_url||'tzkpufc.p_pay_adm_ns?p_val='||tzkpufc.f_encrypt (p_pidm, p_enc_key)||'-'||tzkpufc.f_encrypt (p_doc_num, p_enc_key));

END;

-- Funcion que encripta los valores de ID y numero de documento a pagar por pago en Línea.
--
function f_encrypt (p_val varchar2, p_key varchar2) return varchar2
IS 

V_ENCRYPT varchar2(500) default NULL ;
V_INPUT varchar2(500) default NULL ;
v_val_encrypt varchar2(1000);

BEGIN
V_INPUT := p_val; 
V_INPUT := rpad( V_INPUT, (trunc(length(V_INPUT)/8)+1)*8, chr(0));

dbms_obfuscation_toolkit.DESEncrypt
( input_string => V_INPUT,
key_string => p_key,
encrypted_string=> V_ENCRYPT );

v_val_encrypt := utl_raw.cast_to_raw(V_ENCRYPT);

return v_val_encrypt;

END;


-- Funcion de desencripción, de los valores ID y numero de documento utilizado para Pago en Línea.
function f_decrypt (p_val varchar2, p_key varchar2) return VARCHAR2 is
V_ENCRYPT varchar2(500) default NULL ;
V_DECRYPT varchar2(500) default NULL ;
V_INPUT varchar2(500) default NULL ;
BEGIN
  V_ENCRYPT := utl_raw.cast_to_varchar2( hextoraw(p_val) );

dbms_obfuscation_toolkit.DESDecrypt
( input_string => V_ENCRYPT,
key_string => p_key,
decrypted_string=> V_DECRYPT );

return replace(V_DECRYPT,chr(0),'') ;

END;



procedure p_regenera_factura (p_pidm  IN NUMBER, p_doc_num  IN VARCHAR2) is
    v_plan_pago        varchar2(1):= NULL;

BEGIN

p_ins_tzrrlog(p_pidm,  'REGENERA_FACTURA', 'VAL: ', p_doc_num ||' Es Plan de Pago:'||v_plan_pago, user);


begin
delete tvrmlcb_temp 
where TVRMLCB_PIDM= p_pidm;

exception when no_data_found then null;
                when others then null;
end;

        begin
        update TZRDPRF 
              set TZRDPRF_DOC_STATUS = 'CREADO'
                  , TZRDPRF_DATA_ORIGIN = 'TVACAJA_RG'
                  , TZRDPRF_PAY_DATE = sysdate
         where TZRDPRF_PIDM = p_pidm
             and TZRDPRF_DOC_NUMBER = p_doc_num
             and TZRDPRF_DOC_STATUS = 'ACEPTADO';

        exception when no_data_found then null;
                        when others then null;
        end;


        begin
        delete tzrfact 
        where 
        TZRFACT_PIDM = p_pidm
        and TZRFACT_SDOC_CODE in (select GTVSDAX_EXTERNAL_CODE from gtvsdax where gtvsdax_internal_code_group = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE in ( 'COD_FACT','COD_CP'))
        and TZRFACT_DOC_NUMBER = p_doc_num
        and not exists (select 'Y' from tbrappl where TBRAPPL_PIDM = TZRFACT_PIDM and TBRAPPL_PAY_TRAN_NUMBER = TZRFACT_TRAN_NUM and TBRAPPL_REAPPL_IND is null);

        exception when no_data_found then null;
                        when others then null;
        end;


standard.commit;

END p_regenera_factura ; 



PROCEDURE p_reenvia_prefactura (p_one_up_no IN NUMBER)
    IS
        TYPE gjbprun_rec IS RECORD
        (
            r_gjbprun_number    gjbprun.gjbprun_number%TYPE,
            r_gjbprun_value     gjbprun.gjbprun_value%TYPE,
            r_gjbprun_desc      gjbpdef.gjbpdef_desc%TYPE
        );

        TYPE gjbprun_ref IS REF CURSOR RETURN gjbprun_rec;

        ln_count              NUMBER:= 0;
        v_job_num             NUMBER := p_one_up_no;
        v_user_id             VARCHAR2 (50) := USER;
        v_user_id_log         VARCHAR2 (50) := USER;
        v_job_ref             gjbprun_ref;
        v_job_rec             gjbprun_rec;
        v_env_nm_before       NUMBER;
        v_env_nm_after        NUMBER;
        v_line_cntr           NUMBER := 0;
        v_page_cntr           NUMBER := 0;
        v_file_number         guboutp.guboutp_file_number%TYPE;
        v_page_width          NUMBER;
        v_page_break          NUMBER;
        v_row_print           VARCHAR2 (1000);
        v_status              VARCHAR2 (10);
        v_comments            VARCHAR2 (20000);

        lv_out_error          VARCHAR2 (1000);

        v_id                        gjbprun.gjbprun_value%TYPE;
        v_pidm                    number(8);
        v_doc_number         gjbprun.gjbprun_value%TYPE;   
        v_sdoc_code            gjbprun.gjbprun_value%TYPE; 
        v_periodo               gjbprun.gjbprun_value%TYPE;
        v_campus                gjbprun.gjbprun_value%TYPE;
        v_application           gjbprun.gjbprun_value%TYPE;
        v_selection             gjbprun.gjbprun_value%TYPE;
        v_userid                gjbprun.gjbprun_value%TYPE;
        v_user_create           gjbprun.gjbprun_value%TYPE;
        v_link_pago             gjbprun.gjbprun_value%TYPE;
        v_moda                   gjbprun.gjbprun_value%TYPE;   



        CURSOR c_get_email (p_pidm number)
        IS
            SELECT goremal_email_address
              FROM goremal
             WHERE     goremal_pidm = p_pidm
                   AND goremal_emal_code = (SELECT gtvsdax_external_code                  
                                                          FROM gtvsdax
                                                         WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
                                                               AND gtvsdax_internal_code = 'EMAL_CODE')
                   AND goremal_status_ind = 'A';

        v_email  goremal.goremal_email_address%type;

    BEGIN
        p_create_header (p_one_up_no,
                         USER,
                         v_file_number,
                         'TZPPREN');
        v_page_width :=
            gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

        v_page_break :=
            gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');

        OPEN v_job_ref FOR
              SELECT gjbprun_number, gjbprun_value, gjbpdef_desc
                FROM gjbprun, gjbpdef
               WHERE     gjbprun_one_up_no = p_one_up_no
                     AND gjbprun_job = 'TZPPREN'
                     AND gjbpdef_job = gjbprun_job
                     AND gjbpdef_number = gjbprun_number
            ORDER BY gjbprun_number ASC;

        LOOP
            FETCH v_job_ref INTO v_job_rec;
            EXIT WHEN v_job_ref%NOTFOUND; 

            gz_report.p_put_line (
                p_one_up_no =>
                    p_one_up_no,
                p_user =>
                    v_user_id_log,
                p_job_name =>
                    'TZPPREN',
                p_file_number =>
                    NVL (v_file_number, 1),
                p_content_line =>
                       v_job_rec.r_gjbprun_number
                    || ' - '
                    || v_job_rec.r_gjbprun_desc
                    || ' - '
                    || v_job_rec.r_gjbprun_value
                    || '.',
                p_content_width =>
                    v_page_width,
                p_content_align =>
                    'LEFT',     
                p_status =>
                    v_status,
                p_comments =>
                    v_comments);


            CASE v_job_rec.r_gjbprun_number
                WHEN '01'   THEN
                    v_id := v_job_rec.r_gjbprun_value;
                    IF v_id IS NOT NULL  THEN
                      v_pidm := gb_common.f_get_pidm(v_id);
                    END IF;
                WHEN '02'   THEN
                    v_doc_number := v_job_rec.r_gjbprun_value;    
                WHEN '03'   THEN
                    v_sdoc_code := v_job_rec.r_gjbprun_value;
                WHEN '04'   THEN
                    v_periodo := v_job_rec.r_gjbprun_value;
                WHEN '05'   THEN
                    v_campus := v_job_rec.r_gjbprun_value;
                WHEN '06'   THEN
                    v_application := v_job_rec.r_gjbprun_value;
                WHEN '07'   THEN
                    v_selection := v_job_rec.r_gjbprun_value;
                WHEN '08'   THEN
                    v_userid := v_job_rec.r_gjbprun_value;
                WHEN '09'   THEN
                  v_user_create := v_job_rec.r_gjbprun_value;
                WHEN '10'   THEN
                    v_link_pago := v_job_rec.r_gjbprun_value;
                WHEN '11'   THEN
                    v_moda := v_job_rec.r_gjbprun_value;    
                ELSE
                    NULL;
            END CASE;
        END LOOP;


        v_row_print :=
               gz_report.f_colum_format ('ID ',
                                         9,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format ('Nombre',
                                         30,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format ('# Documento',
                                         19,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format ('Email',
                                         40,
                                         'LEFT',
                                         ' | ');

        gz_report.p_put_line (
            p_one_up_no       => p_one_up_no,
            p_user            => v_user_id_log,
            p_job_name        => 'TZPPREN',
            p_file_number     => NVL (v_file_number, 1),
            p_content_line    => LPAD (' ', v_page_width, '-'),
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',
            p_status          => v_status,
            p_comments        => v_comments);

        gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                              p_user            => v_user_id_log,
                              p_job_name        => 'TZPPREN',
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => v_row_print,
                              p_content_width   => v_page_width,
                              p_content_align   => 'LEFT',
                              p_status          => v_status,
                              p_comments        => v_comments);


        FOR ren IN (
            select TVBSDOC_PIDM t_pidm, TVBSDOC_DOC_NUMBER t_doc_number, gb_common.f_get_id(TVBSDOC_PIDM) t_id
                from tvbsdoc 
                where (( 
                              tvbsdoc_pidm = v_pidm  
                             and TVBSDOC_DOC_NUMBER = v_doc_number)                           
                            OR v_pidm   is null and exists
                            (SELECT 1
                                           FROM glbextr
                                          WHERE     glbextr_application = v_application
                                                AND glbextr_selection = v_selection
                                                AND glbextr_creator_id = v_user_create 
                                                AND glbextr_user_id = v_userid
                                                AND glbextr_key = tvbsdoc_pidm )                            
                            OR  (v_pidm   is null and  v_application is null )                               
                                  AND TVBSDOC_SDOC_CODE =  v_sdoc_code
                                  AND TVBSDOC_PREFIX_1 = substr(v_periodo ,1,4)
                                  AND TVBSDOC_PREFIX_2 = substr(v_periodo ,5,2)
                                  AND substr(TVBSDOC_DOC_NUMBER,7,1) = (select STVCAMP_DICD_CODE from stvcamp where STVCAMP_CODE = v_campus)
                           )
                and TVBSDOC_DOC_CANCEL_IND is null                
                and tzkpufc.f_doc_num_pagado_dprf(tvbsdoc_pidm, TVBSDOC_SDOC_CODE, TVBSDOC_DOC_NUMBER) = 'N'
        )
        LOOP

       open c_get_email (ren.t_pidm);
       fetch c_get_email into v_email;
       close c_get_email;


                v_row_print :=
                       gz_report.f_colum_format (
                           LPAD (ren.t_id, 9, ' '),
                           9,
                           'RIGHT',
                           '   ')
                     || gz_report.f_colum_format (
                                   f_format_name (ren.t_pidm, 'FMIL'),
                                   30,
                                   'LEFT',
                                   '   ')      
                    || gz_report.f_colum_format (ren.t_doc_number,
                                                 19,
                                                 'LEFT',
                                                 '   ')
                    || gz_report.f_colum_format (v_email,
                                                 40,
                                                 'LEFT',
                                                 '   ');

                IF v_moda = 'U' THEN
                    tzkpufc.p_show_pdf (p_pidm => ren.t_pidm,
                                                    p_doc_number   => ren.t_doc_number,
                                                    p_send_mail    => 'Y',
                                                    p_web          => 'N',
                                                    p_footer    =>  'Y');
                END IF;


                gz_report.p_put_line (
                    p_one_up_no       => p_one_up_no,
                    p_user            => v_user_id,
                    p_job_name        => 'TZPPREN',
                    p_file_number     => NVL (v_file_number, 1),
                    p_content_line    => v_row_print,
                    p_content_width   => v_page_width,
                    p_content_align   => 'LEFT',  
                    p_status          => v_status,
                    p_comments        => v_comments);



                ln_count := ln_count + 1;

        END LOOP;

        gz_report.p_put_line (
            p_one_up_no =>
                p_one_up_no,
            p_user =>
                v_user_id_log,
            p_job_name =>
                'TZPPREN',
            p_file_number =>
                NVL (v_file_number, 1),
            p_content_line =>
                   'TZPRTRM - Se procesaron '
                || ln_count
                || ' registros. Proceso terminado',
            p_content_width =>
                v_page_width,
            p_content_align =>
                'LEFT', 
            p_status =>
                v_status,
            p_comments =>
                v_comments);
    EXCEPTION
        WHEN OTHERS
        THEN            
            lv_out_error := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

    END p_reenvia_prefactura;

FUNCTION f_get_type_credit_note( p_detail_code IN TZRFACT.TZRFACT_DET_CODE_DOC%TYPE )
    RETURN VARCHAR2 IS
v_credit_note_type VARCHAR2(10);

BEGIN
    v_credit_note_type:='-';
    BEGIN
       SELECT
		CASE
		WHEN TYP_DETC.C_D = 'BEC' THEN GTVSDAX_TRANSLATION_CODE
		WHEN TYP_DETC.C_D = 'DES' THEN GTVSDAX_TRANSLATION_CODE
		WHEN TYP_DETC.T_D = 'C' THEN GTVSDAX_TRANSLATION_CODE
		ELSE GTVSDAX_EXTERNAL_CODE
		END COD
		INTO v_credit_note_type
		FROM GTVSDAX,
		(SELECT TBBDETC_TYPE_IND T_D, TBBDETC_DCAT_CODE C_D FROM TBBDETC WHERE TBBDETC_DETAIL_CODE = p_detail_code) TYP_DETC
		WHERE GTVSDAX_INTERNAL_CODE = 'COD_NC'
		AND GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT';
    EXCEPTION
      WHEN OTHERS THEN
			v_credit_note_type:='-';
    END;
    RETURN v_credit_note_type;
END;	


FUNCTION f_get_type_comprobante( p_detail_code IN TZRFACT.TZRFACT_DET_CODE_DOC%TYPE, p_is_plan in varchar2 )
    RETURN VARCHAR2 IS
v_comprobante_type VARCHAR2(10);


BEGIN
    v_comprobante_type:='-';
    BEGIN
       SELECT
		CASE		
		WHEN TYP_DETC.T_D = 'C'  and p_is_plan = 'Y' THEN 
                GTVSDAX_TRANSLATION_CODE
        WHEN TYP_DETC.T_D = 'C'  and p_is_plan = 'N' THEN 
                GTVSDAX_CONCEPT        
        WHEN TYP_DETC.T_D = 'P' THEN GTVSDAX_EXTERNAL_CODE
		ELSE NULL
		END COD
		INTO v_comprobante_type
		FROM GTVSDAX,
		(SELECT DECODE (TBBDETC_DCAT_CODE, 'INT','P',TBBDETC_TYPE_IND) T_D FROM TBBDETC WHERE TBBDETC_DETAIL_CODE = p_detail_code) TYP_DETC
		WHERE GTVSDAX_INTERNAL_CODE = 'COD_CP'
		AND GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT';
    EXCEPTION
      WHEN OTHERS THEN
			v_comprobante_type:='-';
    END;
    RETURN v_comprobante_type;
END;	



procedure  p_credit_note (p_pidm IN NUMBER, p_sri_doc_number IN varchar2, p_user_id IN varchar2 default null, p_reason IN varchar2 default null, p_cuenta_puente_ind IN varchar2 default null, p_return OUT varchar2)
is

cursor c_get_credntb_sricodenc (p_sri_doc_number varchar2) is
select unique TZRFACT_CREDNT_BNNR, TZRFACT_CREDNT_SRICODE 
  from tzrfact  
where TZRFACT_SRI_DOCNUM = p_sri_doc_number
and   TZRFACT_NC_CANCEL_IND is null 									
and   TZRFACT_SDOC_CODE = 'BN';

cursor c_get_doc_number is
select TZRFACT_DOC_NUMBER 
  from tzrfact  
where TZRFACT_SRI_DOCNUM = p_sri_doc_number
and   tzrfact_pidm = p_pidm;

p_doc_number varchar2(19);

cursor c_get_sri_doc (p_doc_number varchar2, p_user varchar2)  is
SELECT
     TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2
FROM
    tvrsdsq
WHERE
    tvrsdsq_sdoc_code = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_NC')
    AND   tvrsdsq_camp_code =  (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(p_doc_number,7,1)) 
    AND tvrsdsq_fbpr_code IN
                       (SELECT gorfbpr_fbpr_code
                          FROM gorfbpr
                         WHERE gorfbpr_fgac_user_id = p_user)
               AND tvrsdsq_valid_until >= SYSDATE;



cursor c_nc_int is
SELECT
    TVRSDSQ_SDOC_CODE, TVRSDSQ_FBPR_CODE, TVRSDSQ_CAMP_CODE, TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2
FROM
    tvrsdsq
WHERE
    tvrsdsq_sdoc_code = (select GTVSDAX_CONCEPT from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_NC')
    AND   tvrsdsq_camp_code =  (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(p_doc_number,7,1)) 
    AND   tvrsdsq_prefix_1 = substr(p_doc_number,1,4)
    AND   tvrsdsq_prefix_2 = substr(p_doc_number,5,2);

	 p_int_SDOC_CODE   TVRSDSQ.TVRSDSQ_SDOC_CODE%type; 
	 p_int_FBPR_CODE    TVRSDSQ.TVRSDSQ_FBPR_CODE%type;  
	 p_int_CAMP_CODE   TVRSDSQ.TVRSDSQ_CAMP_CODE%type;
	 p_int_PREFIX_1        TVRSDSQ.TVRSDSQ_PREFIX_1%type;
	 p_int_PREFIX_2        TVRSDSQ.TVRSDSQ_PREFIX_2%type;

	 v_int_district        stvcamp.stvcamp_dicd_code%TYPE;
	 v_int_NC         tvrsdsq.tvrsdsq_max_seq%TYPE;
	 v_int_seq             tvrsdsq.tvrsdsq_seq_num%TYPE;
	 v_int_error           VARCHAR2 (1000);
	 p_int_error_msg    VARCHAR2 (1000); 

	 v_sri_district        stvcamp.stvcamp_dicd_code%TYPE;
	 v_sri_NC         tvrsdsq.tvrsdsq_max_seq%TYPE;
	 v_sri_seq             tvrsdsq.tvrsdsq_seq_num%TYPE;
	 v_sri_error           VARCHAR2 (1000);
	 p_sri_error_msg    VARCHAR2 (1000); 
	 p_sri_PREFIX_1        TVRSDSQ.TVRSDSQ_PREFIX_1%type;
	 p_sri_PREFIX_2        TVRSDSQ.TVRSDSQ_PREFIX_2%type;

	 p_folio_int_nc varchar2(20) ;
	 p_sdoc_sri_nc varchar2(10);
	 p_folio_sri_NC			tzrfact.tzrfact_crednt_sricode%type;
	 l_crednt_bnnr 			tzrfact.tzrfact_crednt_bnnr%type;
	 l_crednt_sricode  		tzrfact.tzrfact_crednt_sricode%type;

cursor c_existe_nc  is
SELECT
    'Y'
FROM
    tzrfact j
WHERE
    j.tzrfact_pidm = p_pidm
    AND   j.tzrfact_doc_number = p_doc_number
    AND  j.TZRFACT_SRI_DOCNUM = p_sri_doc_number
    AND j.TZRFACT_FACT_CANCEL_IND is null
	and   j.TZRFACT_NC_CANCEL_IND is null 									  
    AND   j.tzrfact_sdoc_code = (
        SELECT
            gtvsdax_external_code
        FROM
            gtvsdax
        WHERE
            gtvsdax_internal_code_group = 'PUCE_FACT'
            AND   gtvsdax_internal_code = 'COD_NC'
    );

v_existe varchar2(1):='N';


cursor c_valida_doc_activo is
select nvl(tvbsdoc_doc_cancel_ind,'N') cancelado  from tvbsdoc where tvbsdoc_pidm = p_pidm and tvbsdoc_doc_number = p_doc_number;

v_doc_cancelado varchar2(1):= 'N';

cursor c_get_nc_trans is
select  
REGEXP_REPLACE (
                         LISTAGG (TZRFANC_TRAN_NUMBER, ',')
                             WITHIN GROUP (ORDER BY tzrfanc_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         AS TZRFANC_TRAN_NUMBER
FROM
    tzrfanc
WHERE
    tzrfanc_pidm = p_pidm
    AND   tzrfanc_doc_number_rel = p_doc_number
    AND   tzrfanc_doc_number IS NOT NULL
    AND   tzrfanc_sri_docnum IS NOT NULL
    AND   tzrfanc_doc_cancel_ind IS NULL;

  v_trans_nc varchar2(1000) ;
  p_err_msg  varchar2(2000) ;

  cursor  c_get_tvrsdoc_nc (p_trans_numbers in varchar2) is 
  SELECT 0 tran_pay_num, tbraccd_tran_number tran_chg_num
              FROM tbraccd, tbbdetc
             WHERE     tbraccd_pidm = p_pidm
                   AND tbbdetc_detail_code = tbraccd_detail_code
                   and tbbdetc_type_ind = 'C'
                   AND tbraccd_tran_number IN
                           (    SELECT REGEXP_SUBSTR (
                                           REPLACE ((p_trans_numbers), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (
                                           REPLACE ((p_trans_numbers), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                           IS NOT NULL)
               and tbraccd_balance > 0 
        UNION
        SELECT TBRAPPL_PAY_TRAN_NUMBER tran_pay_num, TBRAPPL_CHG_TRAN_NUMBER tran_chg_num
                      FROM tbraccd, tbbdetc, tbrappl
                     WHERE     tbraccd_pidm =  p_pidm
                           AND tbbdetc_detail_code = tbraccd_detail_code
                           and tbbdetc_type_ind = 'P'
                           and tbbdetc_dcat_code in ('BEC','CNT','DES')
                           and tbrappl_pidm = tbraccd_pidm
                           and TBRAPPL_chg_TRAN_NUMBER = tbraccd_tran_number
                           and TBRAPPL_REAPPL_IND is null
                           AND tbraccd_tran_number IN
                                   (    SELECT REGEXP_SUBSTR (
                                                   REPLACE ((p_trans_numbers), ' '),
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                          FROM DUAL
                                    CONNECT BY REGEXP_SUBSTR (
                                                   REPLACE ((p_trans_numbers), ' '),
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                                   IS NOT NULL);



	begin

		open c_get_doc_number;
		fetch c_get_doc_number into p_doc_number;
		close c_get_doc_number;                     

		p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_credit_note: ', p_sri_doc_number||'  p_user_id: '||p_user_id||' p_reason: '||p_reason ||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm, user);


		open c_valida_doc_activo;
		fetch c_valida_doc_activo into v_doc_cancelado;
		close c_valida_doc_activo;

	IF v_doc_cancelado = 'N' THEN

			open c_existe_nc;
			fetch c_existe_nc into v_existe;
			close c_existe_nc;

		IF v_existe = 'N' THEN

				open c_nc_int;
				fetch c_nc_int into p_int_SDOC_CODE, p_int_FBPR_CODE, p_int_CAMP_CODE, p_int_PREFIX_1, p_int_PREFIX_2;
				close c_nc_int;


				tzkpufc.p_get_next_folio (p_doctype         => p_int_SDOC_CODE, 
													  p_user            => NVL(p_user_id,user), 
													  p_camp_code       => p_int_CAMP_CODE,
													  p_prefix1         => p_int_PREFIX_1, 
													  p_prefix2         => p_int_PREFIX_2, 
													  p_next_numdoc     => v_int_NC, 
													  p_seq             => v_int_seq,    
													  p_errormsg        => v_int_error,
													  p_camp_district   => v_int_district); 

				IF v_int_error IS NOT NULL  THEN
					p_return := g$_nls.get ('X', 'SQL', v_int_error);
                    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_get_next_folio: ', p_sri_doc_number||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||p_return||sqlerrm, user);
					GOTO end_credit_note;
				END IF;


				open c_get_sri_doc (  p_doc_number, NVL(p_user_id,user)) ;
				fetch c_get_sri_doc into p_sri_PREFIX_1, p_sri_PREFIX_2;
				close c_get_sri_doc;

				OPEN c_get_data_i ('PUCE_FACT', 'COD_NC', 'EXT');
				 FETCH c_get_data_i INTO p_sdoc_sri_nc;
				CLOSE c_get_data_i;

				tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_sri_nc, 
													  p_user            => NVL(p_user_id,user), 
													  p_camp_code       => p_int_CAMP_CODE,
													  p_prefix1         => p_sri_PREFIX_1, 
													  p_prefix2         => p_sri_PREFIX_2, 
													  p_next_numdoc     => v_sri_NC, 
													  p_seq             => v_sri_seq,    
													  p_errormsg        => v_sri_error,
													  p_camp_district   => v_sri_district); 


				IF v_sri_error IS NOT NULL  THEN
					p_return := g$_nls.get ('X', 'SQL', v_sri_error);
                    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_credit_note: ', p_sri_doc_number||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||p_return||sqlerrm, user);
					GOTO end_credit_note;
				END IF;


					IF v_int_NC is not null and v_int_error is null and v_sri_NC is not null and  v_sri_error is null then 
                        p_update_secuencia (p_int_SDOC_CODE,
                                                    NVL(p_user_id,user),
                                                    p_int_PREFIX_1,
                                                    p_int_PREFIX_2,
                                                    p_int_CAMP_CODE,
                                                    v_int_NC,
                                                    p_int_error_msg);

                        p_update_secuencia (p_sdoc_sri_nc,
                                                    NVL(p_user_id,user),
                                                    p_sri_PREFIX_1,
                                                    p_sri_PREFIX_2,
                                                    p_int_CAMP_CODE,
                                                    v_sri_NC,
                                                    p_sri_error_msg);
						l_crednt_bnnr := null;
						l_crednt_sricode := null;

						open c_get_credntb_sricodenc(p_sri_doc_number);
						fetch c_get_credntb_sricodenc into l_crednt_bnnr,l_crednt_sricode;
						close c_get_credntb_sricodenc;

						if l_crednt_bnnr is null then

							p_folio_int_nc := p_int_PREFIX_1 || p_int_PREFIX_2 || v_int_NC;
							p_folio_sri_NC := p_sri_PREFIX_1 || '-'||p_sri_PREFIX_2 ||'-'|| lpad(v_sri_NC,9,'0');
						else
							p_folio_int_nc := l_crednt_bnnr;
							p_folio_sri_NC := l_crednt_sricode;
						end if;

						IF p_int_error_msg IS NOT NULL OR p_sri_error_msg is not null  THEN
							p_return := g$_nls.get ('X', 'SQL', p_int_error_msg||'-'||p_sri_error_msg);
                            p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_credit_note: ', p_sri_doc_number||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||p_return||sqlerrm, user);

							GOTO end_credit_note;
						END IF;

						IF p_int_error_msg is null and p_sri_error_msg is null then

							BEGIN
								INSERT INTO TZRFACT
								(TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, 
								TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND, TZRFACT_SRI_DOCNUM, TZRFACT_RECEIPT_NUM, 
								TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY, TZRFACT_CREDNT_BNNR, 
								TZRFACT_CREDNT_SRICODE, TZRFACT_NCRED_REASON, TZRFACT_SRI_AUTH_NUM, TZRFACT_SRIDOC_STCODE, TZRFACT_SRIDOC_STDESC, 
								TZRFACT_SAP_DOCNUM, TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE, TZRFACT_CREDNT_DATE, TZRFACT_ACTIVITY_DATE, 
								TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS, TZRFACT_CUENTA_PUENTE)
								select TZRFACT_PIDM, f_get_type_credit_note(TZRFACT_DET_CODE_DOC) , TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, 
								TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS*-1, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND, TZRFACT_SRI_DOCNUM, TZRFACT_RECEIPT_NUM, 
								TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY, p_folio_int_nc, 
								p_folio_sri_NC, p_reason, TZRFACT_SRI_AUTH_NUM, TZRFACT_SRIDOC_STCODE, TZRFACT_SRIDOC_STDESC, 
								null TZRFACT_SAP_DOCNUM, TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE, sysdate TZRFACT_CREDNT_DATE, sysdate, 
								user, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, p_int_CAMP_CODE, p_cuenta_puente_ind
								from TZRFACT
								where TZRFACT_pidm = p_pidm
									 and TZRFACT_DOC_NUMBER = p_doc_number
									 and TZRFACT_RECEIPT_NUM is null
									 and TZRFACT_SRI_DOCNUM = p_sri_doc_number
									 and TZRFACT_FACT_CANCEL_IND is null
									 and TZRFACT_NC_CANCEL_IND is null
									 and  TZRFACT_SDOC_CODE not in  (select GTVSDAX_TRANSLATION_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_CP'
																							union 
																							select  GTVSDAX_CONCEPT from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_CP')
									 --
									 and not exists (select 'Y' from tzrfact j 
									 where j.TZRFACT_pidm = p_pidm and  j.TZRFACT_DOC_NUMBER = p_doc_number 
									 and j.TZRFACT_SRI_DOCNUM = p_sri_doc_number
									 and j.TZRFACT_FACT_CANCEL_IND is null
									 and TZRFACT_NC_CANCEL_IND is null		  
									 and j.TZRFACT_SDOC_CODE = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_NC'));

								  standard.commit;

								 p_return:= 'OK';
                              p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_folio_sri_NC: ', p_folio_sri_NC||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm, user);							 

							exception when others then 
                              p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_folio_sri_NC: ', p_folio_sri_NC||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||sqlerrm, user);							 

							END; 

							BEGIN
								insert into TZRFANC 
								(TZRFANC_PIDM,TZRFANC_DOC_NUMBER,TZRFANC_SDOC_CODE,TZRFANC_SRI_DOCNUM,TZRFANC_DOC_NUMBER_REL,TZRFANC_SDOC_CODE_REL,TZRFANC_SRI_DOCNUM_REL,
								TZRFANC_TERM_CODE,TZRFANC_TRAN_NUMBER,TZRFANC_DETAIL_CODE,TZRFANC_AMOUNT,TZRFANC_REASON,TZRFANC_ALL_IND,
								TZRFANC_CREATE_DATE,TZRFANC_ACTIVITY_DATE,TZRFANC_USER_ID,TZRFANC_DATA_ORIGIN
								)
								select TZRFACT_PIDM, TZRFACT_CREDNT_BNNR, TZRFACT_SDOC_CODE, TZRFACT_CREDNT_SRICODE,
										TZRFACT_DOC_NUMBER,
										(select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_FACT') DOC_PREF,
										TZRFACT_SRI_DOCNUM, TZRFACT_TERM_CODE, TZRFACT_TRAN_NUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, 
										TZRFACT_NCRED_REASON, 'Y' ALL_IND, sysdate create_date, sysdate activity_date, user user_id, 'TZKPUFC' data_origin
								from TZRFACT
								where TZRFACT_pidm = p_pidm
									 and TZRFACT_DOC_NUMBER = p_doc_number
									 and TZRFACT_RECEIPT_NUM is null
									 and TZRFACT_NC_CANCEL_IND is null		  
									 and TZRFACT_SDOC_CODE = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_NC')
									 and not exists (select 'Y' from TZRFANC  where TZRFANC_PIDM = TZRFACT_pidm and  TZRFANC_DOC_NUMBER_REL = TZRFACT_DOC_NUMBER and TZRFANC_SDOC_CODE = TZRFACT_SDOC_CODE
										and TZRFANC_SRI_DOCNUM_REL =  TZRFACT_SRI_DOCNUM  and TZRFANC_SRI_DOCNUM =  TZRFACT_CREDNT_SRICODE and  TZRFANC_TRAN_NUMBER = TZRFACT_TRAN_NUM and TZRFANC_DOC_CANCEL_IND is null);


								standard.commit;

							exception when others then 
                              p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_folio_sri_NC: ', p_folio_sri_NC||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||sqlerrm, user);							 

							END; 

							  OPEN get_ssn_c (p_pidm);
							  FETCH get_ssn_c INTO lv_inf;
							  CLOSE get_ssn_c;

								  p_insert_tvbsdoc (p_sdoc_code =>p_int_SDOC_CODE,
															 p_doc_number =>p_folio_int_nc,
															 p_pidm =>p_pidm,
															 p_prefix_1 =>p_int_PREFIX_1,
															 p_prefix_2 =>p_int_PREFIX_2,
															 p_int_doc_number =>v_int_NC,
															 p_comments =>NULL,
															 p_user_id =>NVL(p_user_id,user),
															 p_data_origin =>'TZKPUFC_NC',
															 p_date =>SYSDATE,
															 p_print_pidm =>p_pidm,
															 p_print_id =>lv_inf,
															 p_print_id_source =>'SPBPERS_SSN',
															 p_atyp_code => NULL, --address type
															 p_msg_out =>p_err_msg);

							  OPEN c_get_nc_trans;
							  FETCH c_get_nc_trans into v_trans_nc;
							  CLOSE c_get_nc_trans;

							  FOR trx_nc in c_get_tvrsdoc_nc (v_trans_nc)
							  loop

									  p_insert_tvrsdoc (p_pidm => p_pidm,
																 p_pay_tran_number =>trx_nc.tran_pay_num,
																 p_chg_tran_number => trx_nc.tran_chg_num,
																 p_doc_number => p_folio_int_nc,
																 p_doc_type => SUBSTR (p_int_SDOC_CODE, 1, 2),
																 p_int_doc_number => v_int_NC,
																 p_user_id => NVL(p_user_id,user),
																 p_data_origin => 'TZKPUFC_NC',
																 p_comments =>NULL,
																 p_sdoc_code => p_int_SDOC_CODE,
																 p_msg_out =>p_err_msg);
							  end loop;                                    

						else
						  p_return := p_int_error_msg||' - '||p_sri_error_msg;
                          p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_folio_sri_NC: ', p_folio_sri_NC||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||p_return||sqlerrm, user);							 

						end if; 

					else
					  p_return := v_int_error||' - '||v_sri_error;
                      p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_folio_sri_NC: ', p_folio_sri_NC||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||p_return||sqlerrm, user);							 

					end if;

				ELSE
				p_return := 'Nota de crédito existente.';
                p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_folio_sri_NC: ', p_folio_sri_NC||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||p_return||sqlerrm, user);							 

				END IF; 

		ELSE
		p_return := 'No se puede generar nota de crédito a un documento cancelado.';
        p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_folio_sri_NC: ', p_folio_sri_NC||' p_doc_number:'||p_doc_number||' p_pidm:'||p_pidm ||' Error '||p_return||sqlerrm, user);							 

	END IF; 

<<end_credit_note>>
  null;

exception when others then rollback;
end p_credit_note;

procedure  p_credit_note_e (p_pidm IN NUMBER, p_sri_doc_number IN varchar2, p_user_id IN varchar2 default null, p_reason IN varchar2 default null, p_cuenta_puente_ind IN varchar2 default null, p_return OUT varchar2)
is
	cursor c_dat_e is
	select unique tzrfact_pidm, tzrfact_sri_docnum
	from tzrfact
	where tzrfact_sri_docnum = p_sri_doc_number
	and   tzrfact_trdparty_pidm = p_pidm
	and   tzrfact_sdoc_code in ('BF','BT');

	begin
		for tx_dat_e in c_dat_e
		loop
			p_credit_note (p_pidm => tx_dat_e.tzrfact_pidm, 
							p_sri_doc_number => tx_dat_e.tzrfact_sri_docnum, 
							p_user_id => NVL(p_user_id,user), 
							p_reason => p_reason, 
							p_cuenta_puente_ind => p_cuenta_puente_ind, 
							p_return => p_return);
			p_return:= p_return;
		end loop;
	exception when others then 
		p_return:= 'Error al generar notas crédito';
	rollback;

    <<end_credit_note_e>>
  null;

--exception when others then rollback;
end p_credit_note_e;


procedure  p_canc_credit_note (p_sri_nc_doc_number IN varchar2, p_user_id IN varchar2 default null, p_return OUT varchar2)
is

	cursor c_get_is_bill  is
	select unique 'Y'
	from tzrfact
	where tzrfact_sap_docnum is not null
	and tzrfact_crednt_sricode = p_sri_nc_doc_number;

	v_is_bill varchar2(1) := null;

	begin

		open c_get_is_bill;
		fetch c_get_is_bill into v_is_bill;
		close c_get_is_bill;                     

		p_ins_tzrrlog(0,  'NOTA_CREDITO', 'p_canc_credit_note', 'p_sri_nc_doc_number '||p_sri_nc_doc_number||'  v_is_bill: '||v_is_bill, user);

	IF v_is_bill = 'Y' THEN

			p_return := 'Nota crédito contabilizada. No permitir la anulación';
			p_ins_tzrrlog(0,  'NOTA_CREDITO', 'p_canc_credit_note: ', 'p_sri_nc_doc_number: '||p_sri_nc_doc_number||'p_return '||p_return, user);
            --standard.commit;
			--GOTO end_canc_credit_note;
            return;
	else

	begin
		update tzrfact
		set tzrfact_nc_cancel_ind = 'Y'
		where tzrfact_crednt_sricode = p_sri_nc_doc_number;

		update tzrfanc
		set TZRFANC_DOC_CANCEL_IND = 'Y'
		where TZRFANC_SRI_DOCNUM = p_sri_nc_doc_number;

		p_return := 'Nota crédito anulada correctamente';

		p_ins_tzrrlog(0,  'NOTA_CREDITO', 'p_canc_credit_note', 'p_sri_nc_doc_number '||p_sri_nc_doc_number||'  p_return: '||p_return, user);

		standard.commit;

	exception when others then		
		p_return := 'Error al intentar anular Nota crédito'||sqlerrm;
		p_ins_tzrrlog(0,  'NOTA_CREDITO', 'p_canc_credit_note', 'p_sri_nc_doc_number '||p_sri_nc_doc_number|| p_return , user);
		GOTO end_canc_credit_note;

	end;
	end if;		

<<end_canc_credit_note>>
  null;

exception when others then 
	p_return := 'Error al intentar anular Nota crédito'||sqlerrm;
	p_ins_tzrrlog(0,  'NOTA_CREDITO', 'p_canc_credit_note', 'p_sri_nc_doc_number '||p_sri_nc_doc_number|| p_return , user);
	rollback;
end p_canc_credit_note;


function f_get_amt_diference_nc (p_pidm in number, p_original_trx in number) return number
is
v_amount number;

begin

select nvl((
select nvl(sum(inu.TBRAPPL_AMOUNT),0)
                        from tbraccd, tbbdetc, tbrappl inu 
                      where tbraccd_pidm = p_pidm  
                          and tbraccd_detail_code = tbbdetc_detail_code 
                          and tbbdetc_type_ind <> 'P'
                          and tbbdetc_dcat_code not in ('BEC','DES')
                          and tbraccd_pidm = tbrappl_pidm
                          and inu.TBRAPPL_CHG_TRAN_NUMBER = TBRACCD_TRAN_NUMBER
                          and inu.TBRAPPL_PAY_TRAN_NUMBER = p_original_trx
                          and inu.TBRAPPL_REAPPL_IND is null
                          and  TBRACCD_TRAN_NUMBER in (
                                            select ina.TBRAPPL_CHG_TRAN_NUMBER 
                                                    from tbrappl ina  where                         
                                                     ina.tbrappl_pidm = tbraccd_pidm
                                               and ina.TBRAPPL_PAY_TRAN_NUMBER = p_original_trx
                                               and ina.TBRAPPL_REAPPL_IND is null)
),0)+ nvl((
select case when abs(TBRACCD_AMOUNT) =  abs(TBRACCD_BALANCE) then 0
                   when abs(TBRACCD_AMOUNT) >  abs(TBRACCD_BALANCE) and abs(TBRACCD_BALANCE) <> 0 then
                          abs(TBRACCD_AMOUNT) -  abs(TBRACCD_BALANCE)
                    else 0
                    end resultado
from tbraccd , tbbdetc                        
where tbraccd_pidm = p_pidm and TBRACCD_TRAN_NUMBER = p_original_trx
and tbraccd_detail_code = tbbdetc_detail_code 
                          and tbbdetc_type_ind = 'P'
                          and tbbdetc_dcat_code  in ('BEC','DES')
                          ),0) into v_amount from dual;

  return nvl(v_amount,0);                                             
  exception when no_data_found then return 0;
                 when others then return 0;
end;


function f_get_amt_diference_ssb (p_pidm in number, p_original_trx in number) return number
is
v_amount number;

begin

select sum(inu.TBRAPPL_AMOUNT)
into v_amount
                        from tbraccd, tbbdetc, tbrappl inu 
                      where tbraccd_pidm = p_pidm  
                          and tbraccd_detail_code = tbbdetc_detail_code 
                          and tbbdetc_type_ind <> 'P'
                          and tbbdetc_dcat_code not in ('BEC','DES')
                          and tbraccd_pidm = tbrappl_pidm                          
                          and inu.TBRAPPL_PAY_TRAN_NUMBER = TBRACCD_TRAN_NUMBER
                          and inu.TBRAPPL_CHG_TRAN_NUMBER = p_original_trx
                          and inu.TBRAPPL_REAPPL_IND is null
                          and  TBRACCD_TRAN_NUMBER in (
                                            select ina.TBRAPPL_PAY_TRAN_NUMBER 
                                                    from tbrappl ina  where                         
                                                     ina.tbrappl_pidm = tbraccd_pidm
                                                     and ina.TBRAPPL_CHG_TRAN_NUMBER  = p_original_trx                                               
                                               and ina.TBRAPPL_REAPPL_IND is null);

  return nvl(v_amount,0);                                             
  exception when no_data_found then return 0;
                 when others then return 0;
end;


procedure  p_credit_note_split (p_pidm IN NUMBER, p_sri_doc_number IN varchar2, p_return OUT varchar2) is

v_amt_diference number;                                               

cursor c_get_doc_number is
select TZRFACT_DOC_NUMBER 
  from tzrfact  
where TZRFACT_SRI_DOCNUM = p_sri_doc_number;

p_doc_number varchar2(19);            

cursor c_additional_data is
select  distinct  TZRFACT_CURR_PROGRAM, TZRFACT_CRN_CONTND, TZRFACT_STPERDOC_QTY, TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE, TZRFACT_PAY_DATE
, TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME
from tzrfact where tzrfact_pidm = p_pidm and tzrfact_doc_number = p_doc_number and TZRFACT_SDOC_CODE= (SELECT gtvsdax_external_code
FROM   gtvsdax  WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code = 'COD_FACT')
and TZRFACT_SRI_DOCNUM = p_sri_doc_number;

cursor c_has_ter is
select 'Y'
   from 
tzrfanc, tbbdetc
WHERE TZRFANC_DETAIL_CODE = TBBDETC_DETAIL_CODE
    AND tzrfanc_pidm =  p_pidm
    AND tzrfanc_doc_number_rel = p_doc_number
    AND tbbdetc_dcat_code = 'TER';

 v_dcat_ter varchar2(1):='N';   

p_curr_program      TZRFACT.TZRFACT_CURR_PROGRAM%type;
p_crn_contnd          TZRFACT.TZRFACT_CRN_CONTND%type;
p_stperdoc_qty       TZRFACT.TZRFACT_STPERDOC_QTY%type; 
p_prefact_date       TZRFACT.TZRFACT_PREFACT_DATE%type; 
p_fact_date            TZRFACT.TZRFACT_FACT_DATE%type; 
p_pay_date             TZRFACT.TZRFACT_PAY_DATE%type;
p_TRDPARTY_ID                    TZRFACT.TZRFACT_TRDPARTY_ID%type;
p_TRDPARTY_PIDM                TZRFACT.TZRFACT_TRDPARTY_PIDM%type;
p_TRDPARTY_NAME               TZRFACT.TZRFACT_TRDPARTY_NAME%type;



cursor c_get_info_folios is
SELECT distinct 
     TZRFANC_USER_ID, 
    REGEXP_SUBSTR (TZRFANC_SRI_DOCNUM_REL,
                      '([^-]+)\-',
                      1,
                      1,
                      NULL,
                      1) sri_prefix1, 
            REGEXP_SUBSTR (TZRFANC_SRI_DOCNUM_REL,
                      '([^-]+)\-',
                      1,
                      2,
                      NULL,
                      1) sri_prefix2
                      , (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(TZRFANC_DOC_NUMBER_REL,7,1) and rownum = 1) campus
                      , substr(TZRFANC_DOC_NUMBER_REL,1,4) int_prefix1
                      , substr(TZRFANC_DOC_NUMBER_REL,5,2) int_prefix2
from tzrfanc
WHERE
    tzrfanc_pidm = p_pidm
    AND   tzrfanc_doc_number_rel = p_doc_number
    AND   tzrfanc_doc_number IS NULL
    AND   tzrfanc_sri_docnum IS NULL
    AND   tzrfanc_doc_cancel_ind IS NULL;

cursor c_get_sri_doc (p_doc_number varchar2, p_user varchar2)  is
SELECT
     TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2
FROM
    tvrsdsq
WHERE
    tvrsdsq_sdoc_code = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_NC')
    AND   tvrsdsq_camp_code =  (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(p_doc_number,7,1)) 
    AND tvrsdsq_fbpr_code IN
                       (SELECT gorfbpr_fbpr_code
                          FROM gorfbpr
                         WHERE gorfbpr_fgac_user_id = p_user)
               AND tvrsdsq_valid_until >= SYSDATE;



cursor c_get_nc_trans is
select  
REGEXP_REPLACE (
                         LISTAGG (TZRFANC_TRAN_NUMBER, ',')
                             WITHIN GROUP (ORDER BY tzrfanc_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         AS TZRFANC_TRAN_NUMBER
FROM
    tzrfanc
WHERE
    tzrfanc_pidm = p_pidm
    AND   tzrfanc_doc_number_rel = p_doc_number
    AND   tzrfanc_doc_number IS NOT NULL   
    AND   tzrfanc_doc_cancel_ind IS NULL;


  v_trans_nc varchar2(1000) ;

  cursor  c_get_tvrsdoc_nc (p_trans_numbers in varchar2) is 
  SELECT 0 tran_pay_num, tbraccd_tran_number tran_chg_num
              FROM tbraccd, tbbdetc
             WHERE     tbraccd_pidm = p_pidm
                   AND tbbdetc_detail_code = tbraccd_detail_code
                   and tbbdetc_type_ind = 'C'
                   AND tbraccd_tran_number IN
                           (    SELECT REGEXP_SUBSTR (
                                           REPLACE ((p_trans_numbers), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (
                                           REPLACE ((p_trans_numbers), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                           IS NOT NULL)
               and tbraccd_balance > 0 
        UNION
        SELECT TBRAPPL_PAY_TRAN_NUMBER tran_pay_num, TBRAPPL_CHG_TRAN_NUMBER tran_chg_num
                      FROM tbraccd, tbbdetc, tbrappl
                     WHERE     tbraccd_pidm =  p_pidm
                           AND tbbdetc_detail_code = tbraccd_detail_code
                           and tbbdetc_type_ind = 'P'
                           and tbbdetc_dcat_code in ('BEC','CNT','DES')
                           and tbrappl_pidm = tbraccd_pidm
                           and TBRAPPL_chg_TRAN_NUMBER = tbraccd_tran_number
                           and TBRAPPL_REAPPL_IND is null
                           AND tbraccd_tran_number IN
                                   (    SELECT REGEXP_SUBSTR (
                                                   REPLACE ((p_trans_numbers), ' '),
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                          FROM DUAL
                                    CONNECT BY REGEXP_SUBSTR (
                                                   REPLACE ((p_trans_numbers), ' '),
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                                   IS NOT NULL);



cursor c_valida_doc_activo is
select nvl(tvbsdoc_doc_cancel_ind,'N') cancelado  from tvbsdoc where tvbsdoc_pidm = p_pidm and tvbsdoc_doc_number = p_doc_number;

v_doc_cancelado varchar2(1):= 'N';


 v_int_district        stvcamp.stvcamp_dicd_code%TYPE;
 v_int_NC         tvrsdsq.tvrsdsq_max_seq%TYPE;
 v_int_seq             tvrsdsq.tvrsdsq_seq_num%TYPE;
 v_int_error           VARCHAR2 (1000);
 p_int_error_msg    VARCHAR2 (1000); 
 p_sdoc_sri_nc varchar2(10);
 p_sdoc_nc varchar2(10);

 v_sri_district        stvcamp.stvcamp_dicd_code%TYPE;
 v_sri_NC         tvrsdsq.tvrsdsq_max_seq%TYPE;
 v_sri_seq             tvrsdsq.tvrsdsq_seq_num%TYPE;
 v_sri_error           VARCHAR2 (1000);
 p_sri_error_msg    VARCHAR2 (1000); 

 p_folio_sri_nc   varchar2(20);
 p_folio_int_nc   varchar2(20);

 v_user_nc         varchar2(30);
 v_sri_prefix1 varchar2(20);
 v_sri_prefix2 varchar2(20);
 v_campus varchar2(20);
 v_int_prefix1 varchar2(20);
 v_int_prefix2    varchar2(20);

 p_err_msg  VARCHAR2 (2000); 

begin

open c_get_doc_number;
fetch c_get_doc_number into p_doc_number;
close c_get_doc_number;                                             

p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_credit_note_split: ', p_sri_doc_number ||' p_doc_number:'||p_doc_number, user);


open c_valida_doc_activo;
fetch c_valida_doc_activo into v_doc_cancelado;
close c_valida_doc_activo;


IF v_doc_cancelado = 'N' THEN


OPEN c_get_data_i ('PUCE_FACT', 'COD_NC', 'CON');
 FETCH c_get_data_i INTO p_sdoc_nc;
CLOSE c_get_data_i;


OPEN c_get_data_i ('PUCE_FACT', 'COD_NC', 'EXT');
 FETCH c_get_data_i INTO p_sdoc_sri_nc;
CLOSE c_get_data_i;


open  c_get_info_folios;
fetch c_get_info_folios into v_user_nc, v_sri_prefix1, v_sri_prefix2, v_campus, v_int_prefix1,v_int_prefix2;
close c_get_info_folios;


OPEN c_get_sri_doc(p_doc_number, v_user_nc );
FETCH c_get_sri_doc into  v_sri_prefix1, v_sri_prefix2;
CLOSE c_get_sri_doc;



IF v_user_nc is not null and  v_sri_prefix1 is not null and  v_sri_prefix2 is not null and  v_campus is not null and  v_int_prefix1 is not null and v_int_prefix2  is not null then


  tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_nc, 
                                      p_user            => v_user_nc, 
                                      p_camp_code       => v_campus,
                                      p_prefix1         => v_int_prefix1, 
                                      p_prefix2         => v_int_prefix2, 
                                      p_next_numdoc     => v_int_NC, 
                                      p_seq             => v_int_seq,    
                                      p_errormsg        => v_int_error,
                                      p_camp_district   => v_int_district); 


IF v_int_error IS NOT NULL  THEN
    p_return := g$_nls.get ('X', 'SQL', v_int_error);
    GOTO end_credit_note_split;
END IF;


tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_sri_nc, 
                                      p_user            => v_user_nc, 
                                      p_camp_code       => v_campus,
                                      p_prefix1         => v_sri_prefix1, 
                                      p_prefix2         => v_sri_prefix2, 
                                      p_next_numdoc     => v_sri_NC, 
                                      p_seq             => v_sri_seq,    
                                      p_errormsg        => v_sri_error,
                                      p_camp_district   => v_sri_district); 


IF v_sri_error IS NOT NULL  THEN
    p_return := g$_nls.get ('X', 'SQL', v_sri_error);
    GOTO end_credit_note_split;
END IF;

  IF v_int_NC is not null and v_int_error is null  then 
  p_update_secuencia (p_sdoc_nc,
                                    v_user_nc,
                                    v_int_prefix1,
                                    v_int_prefix2,
                                    v_campus,
                                    v_int_NC,
                                    p_int_error_msg);

 p_update_secuencia (p_sdoc_sri_nc,
                                    v_user_nc,
                                    v_sri_prefix1,
                                    v_sri_prefix2,
                                    v_campus,
                                    v_sri_NC,
                                    p_sri_error_msg);

   p_folio_sri_nc := v_sri_prefix1 || '-'||v_sri_prefix2 ||'-'|| lpad(v_sri_NC,9,'0') ;

   p_folio_int_nc := v_int_prefix1 || v_int_prefix2 || v_int_NC ;

begin

update
    tzrfanc
 set  TZRFANC_DOC_NUMBER = p_folio_int_nc
      ,TZRFANC_SRI_DOCNUM = p_folio_sri_nc
      , TZRFANC_ALL_IND = ''
WHERE
    tzrfanc_pidm = p_pidm
    AND   tzrfanc_doc_number_rel = p_doc_number
    AND   tzrfanc_doc_number IS NULL
    AND   tzrfanc_sri_docnum IS NULL
    AND   tzrfanc_doc_cancel_ind IS NULL;

standard.commit;

exception when others then 
    p_return := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_credit_note_split Error: p_folio_sri_nc', p_folio_sri_nc ||' p_doc_number:'||p_doc_number||p_return||sqlerrm, user);

    GOTO end_credit_note_split;
end;

IF p_int_error_msg IS NOT NULL OR p_sri_error_msg is not null  THEN
    p_return := g$_nls.get ('X', 'SQL', p_int_error_msg||'-'||p_sri_error_msg);
    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_int_error_msg Error: p_folio_sri_nc', p_folio_sri_nc ||' p_doc_number:'||p_doc_number||p_return||sqlerrm, user);
    GOTO end_credit_note_split;
END IF;


open c_additional_data;
fetch c_additional_data into p_curr_program, p_crn_contnd, p_stperdoc_qty, p_prefact_date, p_fact_date, p_pay_date, p_TRDPARTY_ID, p_TRDPARTY_PIDM , p_TRDPARTY_NAME;
close c_additional_data;


begin

INSERT INTO TZRFACT
    (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID
    , TZRFACT_SALE_DOCNUM,TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM
    , TZRFACT_SRI_DOCNUM , TZRFACT_CREDNT_BNNR,   TZRFACT_CREDNT_SRICODE, TZRFACT_NCRED_REASON
    , TZRFACT_CREDNT_DATE, TZRFACT_ACTIVITY_DATE,TZRFACT_USER, TZRFACT_TERM_CODE, 
    TZRFACT_CURR_PROGRAM, TZRFACT_CRN_CONTND, TZRFACT_STPERDOC_QTY, TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS
    , TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME
    )
 select TZRFANC_PIDM, f_get_type_credit_note(TZRFANC_DETAIL_CODE), TZRFANC_DOC_NUMBER_REL, gb_common.f_get_id(TZRFANC_PIDM) TZRFANC_ID, --PROGRAM
          tzkpufc.f_get_docnum_fmt(TZRFANC_DOC_NUMBER_REL) TZRFANC_sale_docnum, TZRFANC_DETAIL_CODE
          , TZRFANC_AMOUNT + f_get_amt_diference_nc(tzrfanc_pidm, TZRFANC_TRAN_NUMBER) 
          , TZRFANC_TRAN_NUMBER
          , TZRFANC_SRI_DOCNUM_REL, TZRFANC_DOC_NUMBER, TZRFANC_SRI_DOCNUM, TZRFANC_REASON
          , TZRFANC_CREATE_DATE, sysdate, user, TZRFANC_TERM_CODE,
          p_curr_program, p_crn_contnd, p_stperdoc_qty, p_prefact_date, p_fact_date, p_pay_date, v_campus
          , p_TRDPARTY_ID, p_TRDPARTY_PIDM , p_TRDPARTY_NAME
   from 
tzrfanc
WHERE
    tzrfanc_pidm = p_pidm
    AND   tzrfanc_doc_number_rel = p_doc_number
    AND   tzrfanc_doc_number IS NOT NULL
    AND   tzrfanc_doc_cancel_ind IS NULL
   and not exists (select 'Y' from tzrfact j where j.TZRFACT_pidm = tzrfanc_pidm and  j.TZRFACT_CREDNT_SRICODE = TZRFANC_SRI_DOCNUM  AND j.TZRFACT_FACT_CANCEL_IND is null and j.TZRFACT_SDOC_CODE = (select GTVSDAX_TRANSLATION_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_NC'));
  standard.commit;
    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_int_error_msg', 'p_folio_sri_nc '|| p_folio_sri_nc ||' p_doc_number:'||p_doc_number, user);

  p_return := 'OK';

exception when others then 
    p_return := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'credit_note_split ok', 'p_folio_sri_nc'|| p_folio_sri_nc ||' p_doc_number:'||p_doc_number, user);

    GOTO end_credit_note_split;
end;


  OPEN get_ssn_c (p_pidm);
  FETCH get_ssn_c INTO lv_inf;
  CLOSE get_ssn_c;

          p_insert_tvbsdoc (p_sdoc_code =>p_sdoc_nc,
                                     p_doc_number =>p_folio_int_nc,
                                     p_pidm =>p_pidm,
                                     p_prefix_1 =>v_int_prefix1,
                                     p_prefix_2 =>v_int_prefix2,
                                     p_int_doc_number =>v_int_NC,
                                     p_comments =>NULL,
                                     p_user_id =>v_user_nc,
                                     p_data_origin =>'TZKPUFC_NC_SPLIT',
                                     p_date =>SYSDATE,
                                     p_print_pidm =>p_pidm,
                                     p_print_id =>lv_inf,
                                     p_print_id_source =>'SPBPERS_SSN',
                                     p_atyp_code => NULL, --address type
                                     p_msg_out =>p_err_msg);

      OPEN c_get_nc_trans;
      FETCH c_get_nc_trans into v_trans_nc;
      CLOSE c_get_nc_trans;

      FOR trx_nc in c_get_tvrsdoc_nc (v_trans_nc)
      loop

              p_insert_tvrsdoc (p_pidm => p_pidm,
                                         p_pay_tran_number =>trx_nc.tran_pay_num,
                                         p_chg_tran_number => trx_nc.tran_chg_num,
                                         p_doc_number => p_folio_int_nc,
                                         p_doc_type => SUBSTR (p_sdoc_nc, 1, 2),
                                         p_int_doc_number => v_int_NC,
                                         p_user_id => v_user_nc,
                                         p_data_origin => 'TZKPUFC_NC_SPLIT',
                                         p_comments =>NULL,
                                         p_sdoc_code => p_sdoc_nc,
                                         p_msg_out =>p_err_msg);
      end loop;                                    

else
    p_return := v_int_error||' - '||v_sri_error;
    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'Error: p_folio_sri_nc', p_folio_sri_nc ||' p_doc_number:'||p_doc_number||p_return||sqlerrm, user);

end if; 

ELSE
    p_return := 'No se puede generar nota de crédito error en la obtención de folios.';
    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'Error: ', 'p_folio_sri_nc '||p_folio_sri_nc ||' p_doc_number:'||p_doc_number||p_return||sqlerrm, user);

END IF; 


ELSE
p_return := 'No se puede generar nota de crédito a un documento cancelado.';
END IF; 

<<end_credit_note_split>>
  null;
exception when others then 
    p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'end_credit_note_split Error: ', 'p_folio_sri_nc '||p_folio_sri_nc ||' p_doc_number:'||p_doc_number||p_return||sqlerrm, user);
    rollback;
end;


procedure p_ins_nc_split (p_PIDM  varchar2, p_SDOC_CODE  varchar2,p_DOC_NUMBER_REL  varchar2,p_SDOC_CODE_REL  varchar2,p_SRI_DOCNUM_REL  varchar2,  p_TERM_CODE  varchar2,p_TRAN_NUMBER  varchar2
,p_DETAIL_CODE  varchar2,p_AMOUNT  varchar2,p_REASON  varchar2,p_ALL_IND  varchar2, p_CREATE_DATE  date, p_USER_ID  varchar2,p_DATA_ORIGIN  varchar2, p_return out varchar2)
is
begin

insert into TZRFANC 
    (TZRFANC_PIDM,TZRFANC_SDOC_CODE,TZRFANC_DOC_NUMBER_REL,TZRFANC_SDOC_CODE_REL,TZRFANC_SRI_DOCNUM_REL,
    TZRFANC_TERM_CODE,TZRFANC_TRAN_NUMBER,TZRFANC_DETAIL_CODE,TZRFANC_AMOUNT,TZRFANC_REASON,TZRFANC_ALL_IND,
    TZRFANC_CREATE_DATE,TZRFANC_USER_ID,TZRFANC_DATA_ORIGIN, TZRFANC_ACTIVITY_DATE
    )
values(
p_PIDM , p_SDOC_CODE, p_DOC_NUMBER_REL,p_SDOC_CODE_REL , p_SRI_DOCNUM_REL  ,  p_TERM_CODE  ,p_TRAN_NUMBER  
,p_DETAIL_CODE ,p_AMOUNT ,p_REASON  ,p_ALL_IND  , p_CREATE_DATE  ,p_USER_ID  ,p_DATA_ORIGIN, sysdate  
);

p_return := 'OK';                     

exception when others then 
 p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
 p_ins_tzrrlog(p_pidm,  'NOTA_CREDITO', 'p_ins_nc_split Error: ', 'p_SRI_DOCNUM_REL '||p_SRI_DOCNUM_REL||p_return, user);

end;

-- Procedimiento general para almacenar información tipo Log de la ejecución de los procesos de generacion de documentos de venta,
-- pago en línea y procesos internos.
--
procedure p_ins_tzrrlog ( 
 p_pidm  number default null,
 p_process varchar2  default null,
 p_reference varchar2 default null,
 p_log varchar2 default null,
 p_user_id varchar2 default null
 )
is
begin
insert into tzrrlog 
(
 tzrrlog_pidm,
 tzrrlog_process,
 tzrrlog_reference,
 tzrrlog_log,
 tzrrlog_user_id,
 tzrrlog_activity_date
)
values
(
  p_pidm,
 p_process,
 p_reference,
 p_log,
 p_user_id,
 sysdate
);

end;


function f_is_comprobante (p_pay_detail_code varchar2) return varchar2
is
cursor c_get_prebill_ind is
select 'Y'
from tbbdetc 
where 
         TBBDETC_DETAIL_CODE = p_pay_detail_code
  and TBBDETC_TYPE_IND = 'P'       
  and TBBDETC_PREBILL_PRINT_IND = 'N'; 

val_ret varchar2(1):= 'N';

begin

open c_get_prebill_ind;
fetch c_get_prebill_ind into val_ret;
close c_get_prebill_ind;

return val_ret;

end;

procedure p_gen_comprobante_pago (p_pidm number, p_sri_doc_number varchar2 default null, p_user varchar2 default null, p_return out varchar2) is

p_campus varchar2(12);
v_sdoc_code    GTVSDAX.GTVSDAX_EXTERNAL_CODE%type;

cursor c_get_sdoc_code (p_code varchar2) is
        select  GTVSDAX_EXTERNAL_CODE , GTVSDAX_CONCEPT 
        from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = p_code;

   v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
   v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
   v_error  varchar2(1000);
   v_district  VARCHAR2(3);

v_doc_num_int   tvrsdsq.tvrsdsq_max_seq%TYPE;
   v_seq_2   tvrsdsq.tvrsdsq_seq_num%TYPE;
   v_error_2  varchar2(1000);
   v_district_2  VARCHAR2(3);

   p_folio_comprobante varchar2(20);
   v_err_update  varchar2(1000);


cursor c_get_term  is
select TZRFACT_TERM_CODE, TZRFACT_CAMPUS,
	(select STVCAMP_DICD_CODE from stvcamp where stvcamp_code = TZRFACT_CAMPUS) DICD_CODE
    from TZRFACT
    where TZRFACT_pidm = p_pidm
         and TZRFACT_SRI_DOCNUM = p_sri_doc_number
         and TZRFACT_TERM_CODE is not null;

   v_term varchar2(6);

p_prefix1_cuotas TVRSDSQ.TVRSDSQ_PREFIX_1%type;
p_prefix2_cuotas TVRSDSQ.TVRSDSQ_PREFIX_2%type;
p_interno_cuotas varchar2(20);
p_sdoc_cuotas varchar2(20);

cursor c_get_prefix2_internal (p_sdoc_cuotas varchar2) is
select TVRSDSQ_PREFIX_2 from tvrsdsq where TVRSDSQ_SDOC_CODE = p_sdoc_cuotas and trunc(sysdate)<= trunc(TVRSDSQ_VALID_UNTIL);

begin


    OPEN c_get_sdoc_code ('COD_CP');
    FETCH c_get_sdoc_code into v_sdoc_code, p_sdoc_cuotas;
    CLOSE c_get_sdoc_code;


     open c_get_term;
     fetch c_get_term into v_term, p_campus,p_prefix1_cuotas;
     close c_get_term;


                    tzkpufc.p_get_next_folio (p_doctype         => v_sdoc_code,
                                                              p_user            => p_user, 
                                                              p_camp_code       => p_campus,
                                                              p_prefix1         => p_prefix1_cuotas,
                                                              p_prefix2         => null,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 

                          p_return :=v_error;

      p_folio_comprobante := v_district ||1|| lpad(v_doc_num,11,'0');

     p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago folio: ', p_sri_doc_number ||' v_sdoc_code:'||v_sdoc_code
     ||' v_term:'||v_term||' p_campus:'||p_campus||' v_doc_num:'||v_doc_num||' v_error:'||v_error||' p_folio_comprobante:'||p_folio_comprobante, user);

                   IF v_doc_num is not null then           

                           UPDATE tvrsdsq
                           SET tvrsdsq_max_seq = v_doc_num,
                               TVRSDSQ_ACTIVITY_DATE = SYSDATE,
                               TVRSDSQ_DATA_ORIGIN = 'TZKPUFC',
                               TVRSDSQ_USER_ID = USER
                         WHERE     tvrsdsq_sdoc_code = v_sdoc_code
                               AND tvrsdsq_fbpr_code IN
                                       (SELECT gorfbpr_fbpr_code
                                          FROM gorfbpr
                                         WHERE gorfbpr_fgac_user_id = p_user)
                               AND tvrsdsq_valid_until >= SYSDATE
                               --AND tvrsdsq_prefix_1 = 1
							   AND tvrsdsq_prefix_1 = p_prefix1_cuotas
                               AND tvrsdsq_camp_code = p_campus;

                        END IF;


BEGIN
                         OPEN c_get_prefix2_internal (p_sdoc_cuotas);
                         fetch c_get_prefix2_internal into p_prefix2_cuotas;
                         close c_get_prefix2_internal;

                         tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_cuotas,
                                                                              p_user            => p_user, 
                                                                              p_camp_code       => p_campus,
                                                                              p_prefix1         => v_district, 
                                                                              p_prefix2         => p_prefix2_cuotas,
                                                                              p_next_numdoc     => v_doc_num_int, 
                                                                              p_seq             => v_seq_2,    
                                                                              p_errormsg        => v_error_2,
                                                                              p_camp_district   => v_district_2); 

                                      p_interno_cuotas := v_district ||p_prefix2_cuotas|| lpad(v_doc_num_int,11,'0');

                                                         IF v_doc_num_int is not null then           

                                                               UPDATE tvrsdsq
                                                               SET tvrsdsq_max_seq = v_doc_num_int,
                                                                   TVRSDSQ_ACTIVITY_DATE = SYSDATE,
                                                                   TVRSDSQ_DATA_ORIGIN = 'TZKPUFC',
                                                                   TVRSDSQ_USER_ID = p_user
                                                             WHERE     tvrsdsq_sdoc_code = p_sdoc_cuotas
                                                                   AND tvrsdsq_fbpr_code IN
                                                                           (SELECT gorfbpr_fbpr_code
                                                                              FROM gorfbpr
                                                                             WHERE gorfbpr_fgac_user_id = p_user)
                                                                   AND tvrsdsq_valid_until >= SYSDATE
                                                                   AND tvrsdsq_prefix_1 = v_district
                                                                   AND tvrsdsq_prefix_2 = p_prefix2_cuotas
                                                                   AND tvrsdsq_camp_code = p_campus;
                                                        END IF;

      p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago: ', ' p_interno_cuotas' ||p_interno_cuotas, user);

END;
----------------------------------------

BEGIN
    INSERT INTO TZRFACT
    (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, 
    TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND,  TZRFACT_RECEIPT_NUM, 
    TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY, 
     TZRFACT_SRI_AUTH_NUM, TZRFACT_SRIDOC_STCODE, TZRFACT_SRIDOC_STDESC, 
     TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE,  TZRFACT_ACTIVITY_DATE, 
    TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS, TZRFACT_INTERNAL_RECEIPT_NUM)
    select TZRFACT_PIDM, f_get_type_comprobante(TZRFACT_DET_CODE_DOC, 'N') SDOC_CODE
    , TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, 
    TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND, p_folio_comprobante, 
    TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY,  TZRFACT_SRI_AUTH_NUM, TZRFACT_SRIDOC_STCODE, TZRFACT_SRIDOC_STDESC, 
     TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE, sysdate, 
    TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, p_campus, p_interno_cuotas
    from TZRFACT
    where TZRFACT_pidm = p_pidm
         and TZRFACT_SRI_DOCNUM = p_sri_doc_number
         and not exists (select 'Y' from tzrfact j where j.TZRFACT_pidm = p_pidm and  j.TZRFACT_RECEIPT_NUM = p_folio_comprobante and j.TZRFACT_SDOC_CODE = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_CP'));

     p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago: ', ' insert', user);

      standard.commit;     
      p_return:= 'OK';

     exception when others then 

     p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
     p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago: ', ' Exception 1' ||p_return, user);

     END; 

    IF p_return is null then 
    p_return:= 'OK';
    END IF;

   exception when others then 
   p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
   p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago: ', ' Exception 2' ||p_return, user);
end;


FUNCTION f_get_amount_trasacc (p_detail_code        varchar2,
                            p_tran_pago     number,
                            p_amount    number,
                            p_pidm	number)
        RETURN number
    IS
        v_valor   tzrfact.TZRFACT_AMNT_TRANS%type := null;
		v_detc		varchar2(2);
        v_valor_ret   tzrfact.TZRFACT_AMNT_TRANS%type := null;
		cursor c_detc is
		select 'Y'
		from tbbdetc
		where tbbdetc_detail_code = p_detail_code
		and   tbbdetc_dcat_code = 'INT';

        CURSOR cGetData
        IS
		select sum(tbrappl_amount) 
		from tbrappl 
		where tbrappl_pidm = p_pidm 
		and tbrappl_pay_tran_number = p_tran_pago;

		--select tbraccd_amount 
		--	from tbraccd 
		--	where tbraccd_pidm = p_pidm 
		--	and tbraccd_tran_number_paid = p_tran_pago 
		--	and tbraccd_amount= p_amount;
		cursor c_appl_amount is
		select tbrappl_amount
		from tbrappl 
		where tbrappl_pidm = p_pidm 
		and tbrappl_chg_tran_number = p_tran_pago 
		and tbrappl_pay_tran_number = (select max(tbrappl_pay_tran_number) 
										from tbrappl 
										where tbrappl_pidm = p_pidm 
										and tbrappl_chg_tran_number = p_tran_pago);


    BEGIN
	v_valor := null;
	v_valor_ret := null;

           OPEN c_detc;
            FETCH c_detc INTO v_detc;
            CLOSE c_detc;

           OPEN cGetData;
            FETCH cGetData INTO v_valor;
            CLOSE cGetData;

			if v_detc = 'Y' then
			    dbms_output.put_line('v_valor1' ||v_valor);

				IF v_valor is null then
   		            OPEN c_appl_amount;
					FETCH c_appl_amount INTO v_valor;
					CLOSE c_appl_amount;
					dbms_output.put_line('v_valor2' ||v_valor);
					v_valor_ret := v_valor; 
				END IF;
			else
				v_valor_ret := p_amount;
			end if;
			dbms_output.put_line('RETORNA v_valor_ret' ||v_valor);
        if v_valor_ret is null then
            v_valor_ret := p_amount;
        end if;
        RETURN v_valor_ret;
    END;

procedure p_gen_comprobante_pago_caja (p_pidm number, p_doc_number varchar2 default null, p_return out varchar2)
is 

cursor c_get_sdoc_code (p_code varchar2) is
        select  GTVSDAX_EXTERNAL_CODE, GTVSDAX_TRANSLATION_CODE 
        from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = p_code;



v_sdoc_code    GTVSDAX.GTVSDAX_EXTERNAL_CODE%type;
v_sdoc_cuota   GTVSDAX.GTVSDAX_TRANSLATION_CODE%type; 

p_program varchar2(12):= '';
p_campus varchar2(12);

cursor c_get_temp  is
select  TVRMLCB_TERM_CODE, TVRMLCB_DETAIL_CODE, TVRMLCB_TRAN_PAGO, TVRMLCB_USER
from tvrmlcb_temp  
where TVRMLCB_PIDM=p_pidm  
and TVRMLCB_DOC_NUMBER = p_doc_number
and TVRMLCB_CHECK_PAGO = 'A';

v_term_code          TVRMLCB.TVRMLCB_TERM_CODE%type;
v_pay_detail_code TVRMLCB.TVRMLCB_DETAIL_CODE%type; 
v_tran_pago           TVRMLCB.TVRMLCB_TRAN_PAGO%type; 
v_user                    TVRMLCB.TVRMLCB_USER%type;

   v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
   v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
   v_error  varchar2(1000);
   v_district  VARCHAR2(3);


   p_folio_comprobante number(13);
   v_err_update  varchar2(1000);
   v_pto_emision varchar2(9);
   v_sri varchar2(20):='';
   v_return_error varchar2(1000);

cursor c_pagos ( p_pidm number, p_doc_number varchar2) is
select DETAIL_CODE
, case when DETAIL_CODE not in (select TBBDETC_DETAIL_CODE from tbbdetc where TBBDETC_DCAT_CODE = 'INT') then 
         TVRMLCB_AMOUNT
         else
		    --f_get_amount_trasacc (detail_code,tran_pago,tvrmlcb_amount,tvrmlcb_pidm)
--NVL((select TBRACCD_AMOUNT from tbraccd where tbraccd_pidm = TVRMLCB_PIDM and TBRACCD_TRAN_NUMBER_PAID = TRAN_PAGO and TBRACCD_AMOUNT=TVRMLCB_AMOUNT), TVRMLCB_AMOUNT)
NVL((select sum(TBRACCD_AMOUNT) from tbraccd where tbraccd_pidm = TVRMLCB_PIDM and TBRACCD_TRAN_NUMBER_PAID = TRAN_PAGO
and tbraccd_tran_number not in (select tzrfact_tran_num from tzrfact where tzrfact_pidm = TVRMLCB_PIDM)), TVRMLCB_AMOUNT)

        --NVL((select sum(TBRAPPL_AMOUNT) from TBRAPPL where TBRAPPL_PIDM = TVRMLCB_PIDM and TBRAPPL_PAY_TRAN_NUMBER = TRAN_PAGO), 
        --(select TBRAPPL_AMOUNT from TBRAPPL where TBRAPPL_PIDM = TVRMLCB_PIDM and TBRAPPL_CHG_TRAN_NUMBER = TRAN_PAGO AND TBRAPPL_PAY_TRAN_NUMBER =
        --(SELECT MAX(TBRAPPL_PAY_TRAN_NUMBER) FROM TBRAPPL WHERE TBRAPPL_PIDM = TVRMLCB_PIDM AND TBRAPPL_CHG_TRAN_NUMBER = TRAN_PAGO)
        --)) 
        end 
        TVRMLCB_AMOUNT
        , TRAN_PAGO
--select *
from (
        select 
        TVRMLCB_PIDM, 
        case 
        when TVRMLCB_DETAIL_CODE_ORG is null then
        TVRMLCB_DETAIL_CODE
        else TVRMLCB_DETAIL_CODE_ORG
        end detail_code
        ,
        TVRMLCB_AMOUNT
        ,
        case 
        when TVRMLCB_TRAN_PAGO is null then
             NVL(TVRMLCB_TRAN_NUMBER_PRIN, TVRMLCB_TRAN_NUMBER_INIT)
         else  TVRMLCB_TRAN_PAGO  
         end tran_pago    
        from tvrmlcb_temp
        where TVRMLCB_PIDM= p_pidm
        and TVRMLCB_DOC_NUMBER = p_doc_number
        and TVRMLCB_TRAN_ORIGINAL is null  
        --
        and nvl(TVRMLCB_DETAIL_CODE_ORG,'NA') not in (select TBBDETC_DETAIL_CODE from tbbdetc where  TBBDETC_DCAT_CODE = 'FNA')
);


--select 
--case 
--when TVRMLCB_DETAIL_CODE_ORG is null then
--TVRMLCB_DETAIL_CODE
--else TVRMLCB_DETAIL_CODE_ORG
--end detail_code
--, TVRMLCB_AMOUNT,
--case 
--when TVRMLCB_TRAN_PAGO is null then
--     NVL(TVRMLCB_TRAN_NUMBER_PRIN, TVRMLCB_TRAN_NUMBER_INIT)
-- else  TVRMLCB_TRAN_PAGO  
-- end tran_pago    
--from tvrmlcb_temp  where TVRMLCB_PIDM= p_pidm
--and TVRMLCB_DOC_NUMBER = p_doc_number
--and TVRMLCB_TRAN_ORIGINAL is null
----
--and nvl(TVRMLCB_DETAIL_CODE_ORG,'NA') not in (select TBBDETC_DETAIL_CODE from tbbdetc where  TBBDETC_DCAT_CODE = 'FNA');


cursor c_get_internal_receipt ( p_pidm number, p_doc_number varchar2,  p_receipt_number varchar2, p_sdoc_cuota varchar2) is
select  TZRFACT_INTERNAL_RECEIPT_NUM 
from 
TVRMLCB_temp, tzrfact 
where 
 TVRMLCB_PIDM = tzrfact_pidm 
and TVRMLCB_DOC_NUMBER = tzrfact_doc_number
--and TVRMLCB_SRI_DOC_NUMBER = TZRFACT_RECEIPT_NUM
and TZRFACT_SDOC_CODE = p_sdoc_cuota
and TVRMLCB_PIDM = p_pidm
and TVRMLCB_DOC_NUMBER = p_doc_number 
and TVRMLCB_SRI_DOC_NUMBER = p_receipt_number
and TVRMLCB_CHECK_PAGO = 'Y' 
and TVRMLCB_TRAN_NUMBER_PRIN = TZRFACT_TRAN_NUM
and TVRMLCB_DETAIL_CODE_ORG in (select TBBDETC_DETAIL_CODE from tbbdetc where  TBBDETC_DCAT_CODE = 'FNA')
and TZRFACT_COMP_CANCEL_IND is null;


 p_internal_receipt varchar2(20);



cursor c_get_prefact_date (p_pidm  NUMBER, p_doc_number number)is
select TZRFACT_PREFACT_DATE, TZRFACT_CURR_PROGRAM programa,
decode (TZRFACT_CAMPUS, null,  
        (select STVCAMP_CODE from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum = 1) ,TZRFACT_CAMPUS) campus
from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_DOC_NUMBER = p_doc_number;

v_dicd_code stvcamp.stvcamp_dicd_code%type;
--acastillo
cursor c_get_dicd_code (p_campus varchar2)is
select stvcamp_dicd_code 
from stvcamp 
where stvcamp_code = p_campus;


v_prefact_date date;

cursor c_existe_comprobante_sin is
select distinct x.TZRFACT_RECEIPT_NUM  RECEIPT_NUM
from TZRFACT x where x.TZRFACT_PIDM = p_pidm
and x.TZRFACT_DOC_NUMBER = p_doc_number
and x.TZRFACT_SRI_DOCNUM is not null
and x.TZRFACT_RECEIPT_NUM is not null
and x.TZRFACT_PREF_CANCEL_IND is null
and x.TZRFACT_COMP_CANCEL_IND is null
--
and not exists (select 'Y' from tzrfact y where y.tzrfact_pidm = x.TZRFACT_PIDM and y.TZRFACT_DOC_NUMBER = x.TZRFACT_DOC_NUMBER and y.TZRFACT_RECEIPT_NUM = x.TZRFACT_RECEIPT_NUM
and y.TZRFACT_SDOC_CODE  in (select GTVSDAX_EXTERNAL_CODE from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_CP'))
;

v_existe_comprobante TZRFACT.TZRFACT_RECEIPT_NUM%type;


cursor c_get_sri_c (p_pidm in number, p_doc_number in varchar2) is
select distinct  TZRFACT_SRI_DOCNUM 
                            from tzrfact 
                            where TZRFACT_PIDM = p_pidm
                              and TZRFACT_DOC_NUMBER = p_doc_number
                              and TZRFACT_SRI_DOCNUM is not null
                              and TZRFACT_FACT_CANCEL_IND is null;

v_sri_doc varchar2(30);
v_amount   tzrfact.TZRFACT_AMNT_TRANS%type := null;

--
CURSOR c_get_terceros (p_pidm in number, p_doc_number in varchar2, p_sri_docnum in varchar2) is
         SELECT UNIQUE  tzrfact_trdparty_id, tzrfact_trdparty_pidm, tzrfact_trdparty_name
        FROM  tzrfact 
        WHERE  tzrfact_pidm          =  p_pidm 
        and TZRFACT_DOC_NUMBER = p_doc_number
        AND   tzrfact_sri_docnum = p_sri_docnum
        AND   tzrfact_trdparty_id   IS NOT NULL
        and TZRFACT_FACT_CANCEL_IND is null;

v_trdparty_id               tzrfact.tzrfact_trdparty_id%type;
v_trdparty_pidm          tzrfact.tzrfact_trdparty_pidm%type;
v_trdparty_name         tzrfact.tzrfact_trdparty_name%type;


begin

     OPEN c_get_sdoc_code ('COD_CP');
     FETCH c_get_sdoc_code into v_sdoc_code, v_sdoc_cuota;
     CLOSE c_get_sdoc_code;



    for c_existe in c_existe_comprobante_sin loop

         FOR i_val IN c_pagos (p_pidm, p_doc_number)   LOOP
         begin
         select TZRFACT_RECEIPT_NUM into v_existe_comprobante
                from tzrfact, tbbdetc where 
                 TZRFACT_DET_CODE_DOC = tbbdetc_detail_code
                and tbbdetc_type_ind = 'C'
                and TZRFACT_PIDM = p_pidm
                and TZRFACT_DOC_NUMBER = p_doc_number
                and TZRFACT_RECEIPT_NUM = c_existe.RECEIPT_NUM                
                and TZRFACT_TRAN_NUM = i_val.TRAN_PAGO;
         exception when no_data_found then null;
                        when others then null;
         end;
        END LOOP;

    end loop;


     OPEN c_get_temp;
     FETCH c_get_temp into v_term_code, v_pay_detail_code, v_tran_pago, v_user;
     CLOSE c_get_temp;


     open c_get_prefact_date (p_pidm, p_doc_number);
                                fetch c_get_prefact_date into v_prefact_date, p_program, p_campus;
                                close c_get_prefact_date;

	 open c_get_dicd_code(p_campus);
	 fetch c_get_dicd_code into v_dicd_code;
	 close c_get_dicd_code;

   IF v_existe_comprobante is null then 

                    tzkpufc.p_get_next_folio (p_doctype         => v_sdoc_code,
                                                              p_user            => v_user, 
                                                              p_camp_code       => p_campus,
                                                              --p_prefix1         => 1,
															  p_prefix1         => v_dicd_code,
                                                              p_prefix2         => null,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district);

          p_folio_comprobante := v_district ||1|| lpad(v_doc_num,11,'0');

p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', p_doc_number ||' v_sdoc_code:'||v_sdoc_code
     ||' v_term_code:'||v_term_code||' v_pay_detail_code:'||v_pay_detail_code||' v_tran_pago:'||v_tran_pago||' v_user:'||v_user||' p_campus:'||p_campus
     ||' p_program:'||p_program||' v_doc_num:'||v_doc_num||' p_folio_comprobante:'||p_folio_comprobante||' v_error:'||v_error, user);


                   IF v_doc_num is not null then           

                           UPDATE tvrsdsq
                           SET tvrsdsq_max_seq = v_doc_num,
                               TVRSDSQ_ACTIVITY_DATE = SYSDATE,
                               TVRSDSQ_DATA_ORIGIN = 'TVRMLCB',
                               TVRSDSQ_USER_ID = USER
                         WHERE     tvrsdsq_sdoc_code = v_sdoc_code
                               AND tvrsdsq_fbpr_code IN
                                       (SELECT gorfbpr_fbpr_code
                                          FROM gorfbpr
                                         WHERE gorfbpr_fgac_user_id = v_user)
                               AND tvrsdsq_valid_until >= SYSDATE
                               --AND tvrsdsq_prefix_1 = 1
							   --AND tvrsdsq_prefix_1 = 4
							   AND tvrsdsq_prefix_1 = v_dicd_code							   
                               AND tvrsdsq_camp_code = p_campus;
                     END IF;
         ELSE
            p_folio_comprobante := v_existe_comprobante;
         END IF;

    IF length(p_folio_comprobante) >= 13 then
                               update tvrmlcb_temp
                            set TVRMLCB_DOC_NUMBER = p_doc_number
                            where TVRMLCB_PIDM=p_pidm 
                              and TVRMLCB_TERM_CODE = v_term_code
                              and TVRMLCB_DETAIL_CODE_ORG in (select TBBDETC_DETAIL_CODE from tbbdetc where  TBBDETC_DCAT_CODE in ('FNA','INT'))
                              and TVRMLCB_DOC_NUMBER is null;

                            update tvrmlcb_temp set 
                                        TVRMLCB_SRI_DOC_NUMBER = p_folio_comprobante 
                             where TVRMLCB_PIDM = p_pidm
                                 and TVRMLCB_DOC_NUMBER = p_doc_number;                    


        --DBMS_LOCK.Sleep(15);
        FOR r_pago IN c_pagos (p_pidm, p_doc_number)
        LOOP
            v_amount := r_pago.TVRMLCB_AMOUNT;--f_get_amount_trasacc (r_pago.detail_code,r_pago.tran_pago,r_pago.tvrmlcb_amount,p_pidm);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' inserta pagos', user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: f_get_type_comprobante(r_pago.detail_code y)', f_get_type_comprobante(r_pago.detail_code, 'Y'), user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: tzkpufc.f_get_docnum_fmt(p_doc_number)', tzkpufc.f_get_docnum_fmt(p_doc_number), user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: r_pago.detail_code', r_pago.detail_code, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'r_pago.TVRMLCB_AMOUNT', r_pago.TVRMLCB_AMOUNT, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'v_amount1', v_amount, user);

                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_folio_comprobante', p_folio_comprobante, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'r_pago.TRAN_PAGO', r_pago.TRAN_PAGO, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_doc_number', p_doc_number, user);


                IF v_existe_comprobante is null then
                begin
				Insert into TZRFACT (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_DOC_NUMBER,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_SALE_DOCNUM,
                                             TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM,TZRFACT_RECEIPT_NUM, 
                                             TZRFACT_FACT_DATE,TZRFACT_ACTIVITY_DATE,TZRFACT_USER, TZRFACT_TERM_CODE,  TZRFACT_STPERDOC_QTY, TZRFACT_PREFACT_DATE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS
                                             ) 
                                 values ( p_pidm,f_get_type_comprobante(r_pago.detail_code, 'Y'),p_doc_number,gb_common.f_get_id(p_pidm),p_program,tzkpufc.f_get_docnum_fmt(p_doc_number),
                                            r_pago.detail_code,v_amount,r_pago.TRAN_PAGO,p_folio_comprobante,
                                            sysdate,sysdate,v_user, v_term_code, 1,  v_prefact_date, sysdate, p_campus);
				exception when others then 
				p_return :=  ' Validar perfiles VBS ';
				end;
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' inserta pagos', user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: f_get_type_comprobante(r_pago.detail_code y)', f_get_type_comprobante(r_pago.detail_code, 'Y'), user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: tzkpufc.f_get_docnum_fmt(p_doc_number)', tzkpufc.f_get_docnum_fmt(p_doc_number), user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: r_pago.detail_code', r_pago.detail_code, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'r_pago.TVRMLCB_AMOUNT', r_pago.TVRMLCB_AMOUNT, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_folio_comprobante', p_folio_comprobante, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'r_pago.TRAN_PAGO', r_pago.TRAN_PAGO, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'v_amount2', v_amount, user);

                ELSE

                    IF  f_get_type_comprobante(r_pago.detail_code, 'Y') = v_sdoc_code then
                       begin
					   Insert into TZRFACT (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_DOC_NUMBER,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_SALE_DOCNUM,
                                             TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM,TZRFACT_RECEIPT_NUM, 
                                             TZRFACT_FACT_DATE,TZRFACT_ACTIVITY_DATE,TZRFACT_USER, TZRFACT_TERM_CODE,  TZRFACT_STPERDOC_QTY, TZRFACT_PREFACT_DATE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS
                                             ) 
                                 values ( p_pidm,f_get_type_comprobante(r_pago.detail_code, 'Y'),p_doc_number,gb_common.f_get_id(p_pidm),p_program,tzkpufc.f_get_docnum_fmt(p_doc_number),
                                            r_pago.detail_code,v_amount,r_pago.TRAN_PAGO,p_folio_comprobante,
                                            sysdate,sysdate,v_user, v_term_code, 1,  v_prefact_date, sysdate, p_campus);
						exception when others then 
							p_return :=  ' Validar perfiles VBS. ';
						end;
                        p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' inserta pagos', user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' inserta pagos', user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: f_get_type_comprobante(r_pago.detail_code y)', f_get_type_comprobante(r_pago.detail_code, 'Y'), user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: tzkpufc.f_get_docnum_fmt(p_doc_number)', tzkpufc.f_get_docnum_fmt(p_doc_number), user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: r_pago.detail_code', r_pago.detail_code, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'r_pago.TVRMLCB_AMOUNT', r_pago.TVRMLCB_AMOUNT, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_folio_comprobante', p_folio_comprobante, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'r_pago.TRAN_PAGO', r_pago.TRAN_PAGO, user);
                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'v_amount3', v_amount, user);

                    END IF;

                END IF;

        END LOOP;


         open c_get_internal_receipt (p_pidm, p_doc_number, p_folio_comprobante, v_sdoc_cuota);
         fetch c_get_internal_receipt into p_internal_receipt;
         close c_get_internal_receipt;

        p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja, referencia: ', p_pidm ||' - '||p_doc_number||' - '||p_folio_comprobante||' - '||p_internal_receipt, user);

                begin

                open  c_get_sri_c(p_pidm, p_doc_number);
                fetch c_get_sri_c into v_sri_doc;
                close c_get_sri_c;

                update tzrfact 
                            set 
                            TZRFACT_SRI_DOCNUM = v_sri_doc, 
							TZRFACT_INTERNAL_RECEIPT_NUM = p_internal_receipt,
							TZRFACT_FACT_DATE = sysdate
                            where TZRFACT_PIDM = p_pidm
                            and TZRFACT_DOC_NUMBER = p_doc_number
                            and TZRFACT_RECEIPT_NUM = p_folio_comprobante ;

                            p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', 'Actualiza # SRI con Comprobante de Plan de Pago: '||p_folio_comprobante ||' SRI'|| v_sri_doc, user);

                exception when no_data_found then 
                       p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' Excepcion Actualiza SRI NDF:'|| SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500), user);
                         when others then 
                       p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' Excepcion Actualiza SRI: '|| SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500), user);
                end;


                                TZKPUFC.p_upd_TZRDPRF  (p_pidm, p_doc_number);

                                delete from tvrmlcb_temp  where TVRMLCB_PIDM = p_pidm
                                and TVRMLCB_DOC_NUMBER = p_doc_number;

                                p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' elimina de temporal y cambia estatus a pago', user);


             begin
             v_trdparty_id := '';
             v_trdparty_pidm := ''; 
             v_trdparty_name := '';

                open c_get_terceros(p_pidm, p_doc_number, v_sri_doc);
                fetch c_get_terceros into v_trdparty_id, v_trdparty_pidm, v_trdparty_name;
                close c_get_terceros;

                  update tzrfact 
                            set 
                            tzrfact_trdparty_id = v_trdparty_id, tzrfact_trdparty_pidm = v_trdparty_pidm , tzrfact_trdparty_name = v_trdparty_name
                            where TZRFACT_PIDM = p_pidm
                            and TZRFACT_DOC_NUMBER = p_doc_number
                            AND tzrfact_sri_docnum = v_sri_doc
                            and TZRFACT_RECEIPT_NUM = p_folio_comprobante
                            and v_trdparty_id is not null ;

                exception when no_data_found then 
                       p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' Excepcion Actualiza Terceros NDF:'|| SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500), user);
                         when others then 
                       p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' Excepcion Actualiza Terceros: '|| SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500), user);

             end;           

   end if;
   p_return:= 'OK';

   if p_program is null then
		p_return:= ' Validar perfiles VBS. ';
   end if;   

   exception when others then 
   p_return :=  p_return || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
   p_ins_tzrrlog(p_pidm,  'COMPROBANTE', 'p_gen_comprobante_pago_caja: ', ' Excepcion: '|| p_return, user);
end;


procedure p_gen_factura_tipo (p_pidm number, p_term_code varchar2, p_contract_number number default null, p_user varchar2 default null, p_return out varchar2)
is

cursor c_data is 
with edo_cta as(
                                        select 
                                        TBRACCD_PIDM,
                                        REGEXP_REPLACE (
                                         LISTAGG (TBRACCD_TRAN_NUMBER, ',')
                                             WITHIN GROUP (ORDER BY TBRACCD_PIDM),
                                         '([^,]+)(,\1)*(,|$)',
                                         '\1\3')
                                         AS TBRACCD_TRAN_NUMBER
                                        from TBBCSTU, tbraccd
                                        where
                                        TBBCSTU_CONTRACT_PIDM = p_pidm
                                        and TBBCSTU_TERM_CODE = p_term_code
                                        and TBBCSTU_CONTRACT_NUMBER = p_contract_number
                                        and TBBCSTU_DEL_IND is null
                                        and TBRACCD_PIDM = TBBCSTU_STU_PIDM
                                        and TBRACCD_CROSSREF_PIDM = TBBCSTU_CONTRACT_PIDM 
                                        and TBRACCD_TERM_CODE = TBBCSTU_TERM_CODE 
                                        and TBRACCD_CROSSREF_NUMBER = TBBCSTU_CONTRACT_NUMBER 
                                        and TBRACCD_SRCE_CODE = 'C' 
                                        and TBRACCD_BALANCE <= 0
                                        group by TBRACCD_PIDM
                                     )   
select tbrappl_pidm,
                REGEXP_REPLACE (
                         LISTAGG (TBRAPPL_CHG_TRAN_NUMBER, ',')
                             WITHIN GROUP (ORDER BY tbrappl_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         AS TBRAPPL_CHG_TRAN_NUMBER
from tbrappl, edo_cta   
where tbrappl_pidm = edo_cta.TBRACCD_PIDM
   AND TBRAPPL_PAY_TRAN_NUMBER IN
                             (    SELECT REGEXP_SUBSTR (
                                             REPLACE ((edo_cta.TBRACCD_TRAN_NUMBER), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                    FROM DUAL
                              CONNECT BY REGEXP_SUBSTR (
                                             REPLACE ((edo_cta.TBRACCD_TRAN_NUMBER), ' '),
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                             IS NOT NULL)
group by tbrappl_pidm;

cursor c_get_doc_number (p_pidm number, p_sdoc_code varchar2, p_trans varchar2 ) is 
SELECT tvrsdoc_doc_number
                FROM tvrsdoc
               WHERE     tvrsdoc_pidm = p_pidm 
                     AND tvrsdoc_doc_cancel_ind IS NULL
                     AND tvrsdoc_sdoc_code = p_sdoc_code
                     AND tvrsdoc_chg_tran_number IN
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
            GROUP BY tvrsdoc_doc_number;

v_doc_number varchar2(19);
p_sdoc_fact  varchar2(4);
v_count_reg number(9):=0;

cursor c_get_pto_emision (p_usuario varchar2, p_sdoc_code varchar2) IS
   select TVRSDSQ_CAMP_CODE, TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2 
   from TVRSDSQ 
   where TVRSDSQ_SDOC_CODE = p_sdoc_code
   and TVRSDSQ_FBPR_CODE in (select GORFBPR_FBPR_CODE from GENERAL.GORFBPR where GORFBPR_FGAC_USER_ID = p_usuario);

    v_pto_emision varchar2(9);
    v_prefix_1 TVRSDSQ.TVRSDSQ_PREFIX_1%type;
    v_prefix_2 TVRSDSQ.TVRSDSQ_PREFIX_1%type;

    p_campus varchar2(12);
    p_program varchar2(12):= '';

    v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
    v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
    v_error  varchar2(1000);
    v_district  VARCHAR2(3);

    p_folio_factura varchar2(20);
    v_err_update  varchar2(1000);
    v_prefact_date date;

cursor c_detail_pagos (pidm_stu number) is
select 
                                        TBRACCD_TRAN_NUMBER
                                        ,TBRACCD_DETAIL_CODE
                                        ,TBRACCD_AMOUNT
                                        from TBBCSTU, tbraccd
                                        where
                                        TBBCSTU_CONTRACT_PIDM = p_pidm
                                        and TBBCSTU_TERM_CODE = p_term_code
                                        and TBBCSTU_CONTRACT_NUMBER = p_contract_number
                                        and TBBCSTU_DEL_IND is null
                                        and TBRACCD_PIDM = TBBCSTU_STU_PIDM
                                        and TBRACCD_CROSSREF_PIDM = TBBCSTU_CONTRACT_PIDM 
                                        and TBRACCD_TERM_CODE = TBBCSTU_TERM_CODE 
                                        and TBRACCD_CROSSREF_NUMBER = TBBCSTU_CONTRACT_NUMBER 
                                        and TBRACCD_SRCE_CODE = 'C' 
                                        and TBRACCD_BALANCE = 0
                                        and TBRACCD_PIDM = pidm_stu;


cursor c_datos_empresa is
select SPRIDEN_PIDM, SPRIDEN_ID, SPRIDEN_LAST_NAME 
   from spriden 
where spriden_pidm = p_pidm
    and SPRIDEN_ENTITY_IND = 'C' 
    and SPRIDEN_CHANGE_IND is null;

v_empr_pidm  SPRIDEN.SPRIDEN_PIDM%type;
v_empr_id       SPRIDEN.SPRIDEN_ID%type;
v_empr_name  SPRIDEN.SPRIDEN_LAST_NAME%type;   

cursor c_get_cnt_cstu is
select count(0) cnt from TBBCSTU
where
TBBCSTU_CONTRACT_PIDM = p_pidm
and TBBCSTU_TERM_CODE = p_term_code
and TBBCSTU_CONTRACT_NUMBER = p_contract_number
and TBBCSTU_DEL_IND is null;

v_cnt_cstu number;

cursor c_get_prefact_date (p_pidm  NUMBER, p_doc_number number)is
select TZRFACT_PREFACT_DATE from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_DOC_NUMBER = p_doc_number;

cursor c_fact_individual_ind is 
SELECT 'Y'
              FROM gorsdav
             WHERE     gorsdav_table_name = 'TBBCONT'
                   AND gorsdav_attr_name = 'FACTURACION_INDIVUDUAL'
                   AND getdata (gorsdav_value) = 'Y'
                   AND GORSDAV_PK_PARENTTAB = p_pidm||chr(1)||p_contract_number||chr(1)||p_term_code;

v_fact_individual varchar2(1):='N';
v_crn TBRACCD.TBRACCD_CRN%type;

cursor c_existe_factura (p_pidm  NUMBER, p_doc_number number) is
select count(0) from tzrfact where tzrfact_pidm = p_pidm and TZRFACT_DOC_NUMBER = p_doc_number and TZRFACT_SRI_DOCNUM is null;

p_existe_factura number;

cursor c_get_montos_validados is 
select (
SELECT sum(TBRACCD_AMOUNT)  
FROM TBRACCD, TBBDETC
where TBRACCD_PIDM= p_pidm 
    and TBRACCD_CROSSREF_NUMBER= p_contract_number
    and TBRACCD_TERM_CODE = p_term_code
    and TBRACCD_DETAIL_CODE = TBBDETC_DETAIL_CODE 
    and TBBDETC_TYPE_IND = 'C' 
    and TBBDETC_DCAT_CODE = 'CNT' 
    and TBRACCD_SRCE_CODE = 'C') total_contrato,
(SELECT sum(TBRACCD_AMOUNT)  
FROM TBRACCD, TBBDETC
where TBRACCD_CROSSREF_PIDM= p_pidm
    and TBRACCD_CROSSREF_NUMBER= p_contract_number
    and TBRACCD_TERM_CODE = p_term_code
    and TBRACCD_DETAIL_CODE = TBBDETC_DETAIL_CODE 
    and TBBDETC_TYPE_IND = 'P' 
    and TBBDETC_DCAT_CODE = 'CNT' 
    and TBRACCD_SRCE_CODE = 'C'
    --and TBRACCD_BALANCE = 0
    )  total_contrato_aplicado from dual;

  v_amt_contrato                     number:= 0;
  v_amt_contrato_aplicado    number:= 0;
  p_genera varchar2(1):= 'Y';

begin

open c_get_montos_validados;
fetch c_get_montos_validados into v_amt_contrato,  v_amt_contrato_aplicado;
close c_get_montos_validados;

if v_amt_contrato = v_amt_contrato_aplicado then 
p_genera := 'Y';
else
p_genera := 'N';
end if;


IF p_genera = 'Y' then


OPEN c_get_data_i ('PUCE_FACT', 'COD_PREF', 'EXT');
FETCH c_get_data_i INTO p_sdoc_pref;
CLOSE c_get_data_i;



OPEN c_get_data_i ('PUCE_FACT', 'COD_FACT', 'EXT');
FETCH c_get_data_i INTO p_sdoc_fact;
CLOSE c_get_data_i;


OPEN c_get_pto_emision (p_user, p_sdoc_fact);
FETCH c_get_pto_emision into v_pto_emision, v_prefix_1, v_prefix_2;
CLOSE c_get_pto_emision;


open c_datos_empresa;
fetch c_datos_empresa into v_empr_pidm, v_empr_id, v_empr_name;
close c_datos_empresa;


open c_fact_individual_ind;
fetch c_fact_individual_ind into v_fact_individual;
close c_fact_individual_ind;


open c_get_cnt_cstu;
fetch c_get_cnt_cstu into  v_cnt_cstu;
close c_get_cnt_cstu;


for  c_reg in c_data 
loop
   open c_get_doc_number (c_reg.tbrappl_pidm, p_sdoc_pref, c_reg.TBRAPPL_CHG_TRAN_NUMBER );
   fetch c_get_doc_number into v_doc_number;
   close c_get_doc_number;

   open c_existe_factura  (c_reg.tbrappl_pidm,v_doc_number);
   fetch c_existe_factura into p_existe_factura;
   close c_existe_factura;


   IF p_existe_factura > 0 then


   open c_get_prefact_date (c_reg.tbrappl_pidm,v_doc_number);
   fetch c_get_prefact_date into v_prefact_date;
   close c_get_prefact_date;


   open c_get_crn(c_reg.tbrappl_pidm, c_reg.TBRAPPL_CHG_TRAN_NUMBER);
   fetch c_get_crn into v_crn;
   close c_get_crn;

                   IF v_prefix_1 is not null and v_prefix_2 is not null then  

                        p_program := tzkpufc.f_get_sovlcur(c_reg.tbrappl_pidm,p_term_code, 'PROGRAM' );
                        p_campus  := tzkpufc.f_get_sovlcur(c_reg.tbrappl_pidm,p_term_code, 'CAMPUS' );

                        IF v_fact_individual = 'N' and p_folio_factura is null then
                        tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_fact,
                                                              p_user            => p_user, 
                                                              p_camp_code       => p_campus,
                                                              p_prefix1         => v_prefix_1,
                                                              p_prefix2         => v_prefix_2,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 

                        p_folio_factura := v_prefix_1 || '-'||v_prefix_2 ||'-'|| lpad(v_doc_num,9,'0');

                        IF v_doc_num is not null then           

                                TZKPUFC.P_UPDATE_SECUENCIA(
                                    P_DOCTYPE => p_sdoc_fact,
                                    P_USER => p_user,
                                    P_PREFIX1 => v_prefix_1,
                                    P_PREFIX2 => v_prefix_2,
                                    P_CAMP_CODE => p_campus,
                                    P_SECUENCIA => v_doc_num,
                                    P_ERROR => v_err_update
                                  );


                        END IF; 


                      ELSIF v_fact_individual = 'Y' THEN
                      v_cnt_cstu := 1;

                        tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_fact,
                                                              p_user            => p_user, 
                                                              p_camp_code       => p_campus,
                                                              p_prefix1         => v_prefix_1,
                                                              p_prefix2         => v_prefix_2,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 

                        p_folio_factura := v_prefix_1 || '-'||v_prefix_2 ||'-'|| lpad(v_doc_num,9,'0');


                        IF v_doc_num is not null then           

                                TZKPUFC.P_UPDATE_SECUENCIA(
                                    P_DOCTYPE => p_sdoc_fact,
                                    P_USER => p_user,
                                    P_PREFIX1 => v_prefix_1,
                                    P_PREFIX2 => v_prefix_2,
                                    P_CAMP_CODE => p_campus,
                                    P_SECUENCIA => v_doc_num,
                                    P_ERROR => v_err_update
                                  );


                        END IF; 

                      END IF; 

        for r_pago in c_detail_pagos (c_reg.tbrappl_pidm) loop

           begin 
           Insert into TZRFACT (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_DOC_NUMBER,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_SALE_DOCNUM,
                                             TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM,TZRFACT_SRI_DOCNUM, 
                                             TZRFACT_FACT_DATE,TZRFACT_ACTIVITY_DATE,TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, 
                                             TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY, TZRFACT_CRN_CONTND, TZRFACT_PREFACT_DATE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS) 
                                 values ( c_reg.tbrappl_pidm,p_sdoc_fact,v_doc_number,gb_common.f_get_id(c_reg.tbrappl_pidm),p_program,tzkpufc.f_get_docnum_fmt(v_doc_number),
                                            r_pago.TBRACCD_DETAIL_CODE,r_pago.TBRACCD_AMOUNT,r_pago.TBRACCD_TRAN_NUMBER,p_folio_factura,
                                            sysdate,sysdate,p_user, p_term_code, v_empr_id, v_empr_pidm, v_empr_name, v_cnt_cstu, v_crn, v_prefact_date, sysdate, p_campus);

           v_count_reg := sql%rowcount;

           exception when others then 
            p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
           end;

         end loop;                

         begin
                                  update TZRFACT
                                        set TZRFACT_SRI_DOCNUM = p_folio_factura,
                                              TZRFACT_FACT_DATE = sysdate,
                                              TZRFACT_TRDPARTY_ID = v_empr_id
                                              , TZRFACT_TRDPARTY_PIDM = v_empr_pidm
                                              , TZRFACT_TRDPARTY_NAME = v_empr_name
                                              , TZRFACT_STPERDOC_QTY = v_cnt_cstu
                                              , TZRFACT_PAY_DATE = sysdate
                                        where 
                                        TZRFACT_PIDM = c_reg.tbrappl_pidm
                                        and TZRFACT_DOC_NUMBER = v_doc_number
                                        and TZRFACT_SRI_DOCNUM is  null;

         exception when others then null;
         end;



       TZKPUFC.p_upd_TZRDPRF (c_reg.tbrappl_pidm,v_doc_number);

    END IF; 

  end if; 

end loop;
if v_count_reg > 0 then
p_return := 'OK';
standard.commit;
else
    p_return := 'Documento no generado';    
end if;
else
p_return := 'Montos de contrato vs monto aplicado a estudiantes no coincide. '|| ' Monto de Contrato: '||v_amt_contrato || ' Monto en Estudiantes: '||v_amt_contrato_aplicado;
end if; 

exception when others then  p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
end;


procedure p_gen_factura_terceros (p_pidm number, p_term_code varchar2, p_doc_number varchar2,  p_return out varchar2) is

cursor c_terceros is
select TZRFACR_TRDPARTY_PIDM , TZRFACR_USER, TZRFACR_CAMP
from tzrfacr
where TZRFACR_PIDM = p_pidm
     and TZRFACR_TERM_CODE = p_term_code
     and TZRFACR_DOC_NUMBER = p_doc_number
     and TZRFACR_FACT_ALL = 'N'
group by TZRFACR_TRDPARTY_PIDM, TZRFACR_USER, TZRFACR_CAMP;

cursor c_pagos is
select TVRMLCB_DETAIL_CODE, TVRMLCB_AMOUNT, TVRMLCB_TRAN_PAGO, TVRMLCB_ACTIVITY_DATE
from tvrmlcb_temp  
where TVRMLCB_PIDM= p_pidm
and TVRMLCB_TERM_CODE = p_term_code
and TVRMLCB_DOC_NUMBER = p_doc_number
and TVRMLCB_TRAN_ORIGINAL is null;

cursor c_hay_pagos is
select count(0)
from tvrmlcb_temp  
where TVRMLCB_PIDM= p_pidm
and TVRMLCB_TERM_CODE = p_term_code
and TVRMLCB_DOC_NUMBER = p_doc_number
and TVRMLCB_TRAN_ORIGINAL is null;

v_hay_pagos number;

v_detail_code_pay  TVRMLCB.TVRMLCB_DETAIL_CODE%type;
v_amount_pay        TVRMLCB.TVRMLCB_AMOUNT%type;
v_tran_pay              TVRMLCB.TVRMLCB_TRAN_PAGO%type;
v_date_pay             TVRMLCB.TVRMLCB_ACTIVITY_DATE%type;

cursor c_adicionales  is
            SELECT TZRFACT_PREFACT_DATE, TZRFACT_CURR_PROGRAM
              FROM tzrfact
             WHERE TZRFACT_PIDM = p_pidm
                   AND TZRFACT_DOC_NUMBER = p_doc_number
                   and TZRFACT_TERM_CODE = p_term_code;

v_PREFACT_DATE       TZRFACT.TZRFACT_PREFACT_DATE%type;
v_CURR_PROGRAM      TZRFACT.TZRFACT_CURR_PROGRAM%type;

cursor c_crn is
                            SELECT TZRFACT_CRN_CONTND 
                                              FROM tzrfact
                                             WHERE TZRFACT_PIDM = p_pidm
                                                   AND TZRFACT_DOC_NUMBER = p_doc_number                                                   
                                                   and TZRFACT_CRN_CONTND is not null
                                                   and rownum = 1;     

p_sdoc_fact  varchar2(4);

cursor c_get_pto_emision (p_usuario varchar2, p_sdoc_code varchar2) IS
   select TVRSDSQ_CAMP_CODE, TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2 
   from TVRSDSQ 
   where TVRSDSQ_SDOC_CODE = p_sdoc_code
   and TVRSDSQ_FBPR_CODE in (select GORFBPR_FBPR_CODE from GENERAL.GORFBPR where GORFBPR_FGAC_USER_ID = p_usuario);

    v_pto_emision varchar2(9);
    v_prefix_1 TVRSDSQ.TVRSDSQ_PREFIX_1%type;
    v_prefix_2 TVRSDSQ.TVRSDSQ_PREFIX_1%type;

    v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
    v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
    v_error  varchar2(1000);
    v_district  VARCHAR2(3);

    p_folio_factura varchar2(20);
    v_err_update  varchar2(1000);
    v_crn_c  varchar2(10);

begin


open c_hay_pagos;
fetch c_hay_pagos into v_hay_pagos;
close c_hay_pagos;

open c_adicionales;
fetch c_adicionales into v_PREFACT_DATE, v_CURR_PROGRAM;
close c_adicionales;

open c_crn;
fetch c_crn into v_crn_c;
close c_crn;

OPEN c_get_data_i ('PUCE_FACT', 'COD_FACT', 'EXT');
FETCH c_get_data_i INTO p_sdoc_fact;
CLOSE c_get_data_i;

IF v_hay_pagos > 0 then

         for c_pay in c_pagos loop
        begin      
       update  tzrfacr
             set TZRFACR_TRAN_NUM = c_pay.TVRMLCB_TRAN_PAGO
                  , TZRFACR_ACTIVITY_DATE = c_pay.TVRMLCB_ACTIVITY_DATE
        where TZRFACR_PIDM = p_pidm
             and TZRFACR_DOC_NUMBER = p_doc_number
             and TZRFACR_TERM_CODE = p_term_code
             and TZRFACR_FACT_ALL = 'N'
             and TZRFACR_DET_CODE = c_pay.TVRMLCB_DETAIL_CODE
             and TZRFACR_MONTO_TRNS = c_pay.TVRMLCB_AMOUNT
             and TZRFACR_VPDI_CODE is null;

        exception when others then null; 
        end; 
    end loop;

--08MZO21 CRN
        begin
        insert into tzrfact (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_DOC_NUMBER,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_SALE_DOCNUM,
                                             TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM, 
                                             TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM,TZRFACT_TRDPARTY_NAME,TZRFACT_STPERDOC_QTY,
                                             TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE ,TZRFACT_ACTIVITY_DATE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS, TZRFACT_CRN_CONTND) 
        select TZRFACR_PIDM, DECODE(TZRFACR_REGISTRO_PAGO, 'P', p_sdoc_fact, TZRFACR_SDOC_CODE), TZRFACR_DOC_NUMBER, TZRFACR_ID, v_CURR_PROGRAM,TZRFACR_SALE_DOCNUM,
                    TZRFACR_DET_CODE, TZRFACR_MONTO_TRNS, TZRFACR_TRAN_NUM, 
                    TZRFACR_TRDPARTY_ID, TZRFACR_TRDPARTY_PIDM,  TZRFACR_TRDPARTY_NAME,  1 TZRFACT_STPERDOC_QTY,
                     TZRFACR_USER,  TZRFACR_TERM_CODE, v_PREFACT_DATE, sysdate, sysdate, sysdate, TZRFACR_CAMP
                     , v_crn_c
--                     , case     TZRFACR_REGISTRO_PAGO    
--                              when   'P' then        
--                                       (
--                                         SELECT TZRFACT_CRN_CONTND
--                                              FROM tzrfact
--                                             WHERE TZRFACT_PIDM = TZRFACR_PIDM
--                                                   AND TZRFACT_DOC_NUMBER = TZRFACR_DOC_NUMBER
--                                                   AND TZRFACT_TRAN_NUM = 
--                                                                                        (select TVRAPPL_CHG_TRAN_NUMBER 
--                                                                                        from tvrappl where tvrappl_pidm =   TZRFACR_PIDM 
--                                                                                        and TVRAPPL_REAPPL_IND is null 
--                                                                                        and TVRAPPL_PAY_TRAN_NUMBER = TZRFACR_TRAN_NUM)
--                                                   and TZRFACT_CRN_CONTND is not null
--                                                   and rownum = 1                 
--                                       )
--                              else
--                                     (SELECT TZRFACT_CRN_CONTND
--                                              FROM tzrfact
--                                             WHERE TZRFACT_PIDM = TZRFACR_PIDM
--                                                   AND TZRFACT_DOC_NUMBER = TZRFACR_DOC_NUMBER
--                                                   AND TZRFACT_TRAN_NUM = TZRFACR_TRAN_NUM 
--                                                   and TZRFACT_CRN_CONTND is not null
--                                                   and rownum = 1)                   
--                                  end      crn
        from tzrfacr
        where TZRFACR_PIDM = p_pidm
             and TZRFACR_DOC_NUMBER = p_doc_number
             and TZRFACR_TERM_CODE = p_term_code
             and TZRFACR_FACT_ALL = 'N'
             and TZRFACR_VPDI_CODE is null;

        exception when others then p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
        end;




for  c_reg in c_terceros
loop
OPEN c_get_pto_emision (c_reg.TZRFACR_USER, p_sdoc_fact);
FETCH c_get_pto_emision into v_pto_emision, v_prefix_1, v_prefix_2;
CLOSE c_get_pto_emision;

IF v_prefix_1 is not null  then 

                    tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_fact,
                                                              p_user            => c_reg.TZRFACR_USER, 
                                                              p_camp_code       => c_reg.TZRFACR_CAMP,
                                                              p_prefix1         => v_prefix_1,
                                                              p_prefix2         => v_prefix_2,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 

                        p_folio_factura := v_prefix_1 || '-'||v_prefix_2 ||'-'|| lpad(v_doc_num,9,'0');


                        IF v_doc_num is not null then           
                                TZKPUFC.P_UPDATE_SECUENCIA(
                                    P_DOCTYPE => p_sdoc_fact,
                                    P_USER => c_reg.TZRFACR_USER,
                                    P_PREFIX1 => v_prefix_1,
                                    P_PREFIX2 => v_prefix_2,
                                    P_CAMP_CODE => c_reg.TZRFACR_CAMP,
                                    P_SECUENCIA => v_doc_num,
                                    P_ERROR => v_err_update
                                  );

                        END IF; 

         begin
                                  update TZRFACT
                                        set TZRFACT_SRI_DOCNUM = p_folio_factura
                                        where 
                                        TZRFACT_TRDPARTY_PIDM = c_reg.TZRFACR_TRDPARTY_PIDM
                                        and TZRFACT_PIDM = p_pidm
                                        and TZRFACT_DOC_NUMBER = p_doc_number
                                        and TZRFACT_SRI_DOCNUM is  null;

         p_return := 'OK';                         
         exception when others then null;
         end;


       TZKPUFC.p_upd_TZRDPRF (c_reg.TZRFACR_TRDPARTY_PIDM,p_doc_number);
else
         p_return := 'No existen folios configurados.';                         
end if; 

end loop;


begin   
   delete from tvrmlcb_temp  
            where TVRMLCB_PIDM = p_pidm
                and TVRMLCB_DOC_NUMBER = p_doc_number;

exception when others then p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);                
end;

else
         p_return := 'No existen pagos pendientes por generar factura.';                         
end if; 

exception when others then p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
end;

procedure p_reimpresion_documento (p_pidm  IN NUMBER, p_sdoc_code in varchar2,  p_doc_number  IN VARCHAR2, p_user in varchar2 default null,  p_return out varchar2)
is

cursor c_get_init_data is
SELECT distinct     
    REGEXP_SUBSTR (TZRFACT_SRI_DOCNUM,
                      '([^-]+)\-',
                      1,
                      1,
                      NULL,
                      1) sri_prefix1, 
            REGEXP_SUBSTR (TZRFACT_SRI_DOCNUM,
                      '([^-]+)\-',
                      1,
                      2,
                      NULL,
                      1) sri_prefix2
                      , (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum = 1) campus
                      , TZRFACT_USER
                      , TZRFACT_DOC_NUMBER
from tzrfact
where TZRFACT_PIDM = p_pidm
    and TZRFACT_SDOC_CODE = p_sdoc_code
    and TZRFACT_SRI_DOCNUM = p_doc_number    
    and TZRFACT_CREDNT_BNNR is null
    and TZRFACT_RECEIPT_NUM is null;


cursor c_get_init_data_nc is
SELECT distinct     
    REGEXP_SUBSTR (TZRFACT_CREDNT_SRICODE,
                      '([^-]+)\-',
                      1,
                      1,
                      NULL,
                      1) sri_prefix1, 
            REGEXP_SUBSTR (TZRFACT_CREDNT_SRICODE,
                      '([^-]+)\-',
                      1,
                      2,
                      NULL,
                      1) sri_prefix2
                      , (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum = 1) campus
                      , TZRFACT_USER
                      , TZRFACT_CREDNT_BNNR 
from tzrfact
where TZRFACT_PIDM = p_pidm
    and TZRFACT_SDOC_CODE = p_sdoc_code
    and TZRFACT_CREDNT_SRICODE = p_doc_number;



cursor c_get_init_data_cp is
SELECT distinct     
                       (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum = 1) campus
                      , TZRFACT_USER
                      , TZRFACT_DOC_NUMBER
from tzrfact
where TZRFACT_PIDM = p_pidm
    and TZRFACT_SDOC_CODE = p_sdoc_code
    and TZRFACT_RECEIPT_NUM = p_doc_number;


    v_sri_prefix1 varchar2(10);
    v_sri_prefix2 varchar2(10);
    v_campus      varchar2(10);
    v_user           varchar2(30);
    v_doc_num_interno TZRFACT.TZRFACT_DOC_NUMBER%type;
    p_folio_factura varchar2(20);
    v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
   v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
   v_error  varchar2(1000);
   v_district  VARCHAR2(3);
   v_err_update  varchar2(1000);

  cursor c_get_terceros (p_pidm number, p_doc_number varchar2) is
  select TZRFACR_TRDPARTY_ID, TZRFACR_TRDPARTY_PIDM, TZRFACR_TRDPARTY_NAME 
   from tzrfacr 
 where
          tzrfacr_pidm = p_pidm
    and TZRFACR_DOC_NUMBER =  p_doc_number
    and TZRFACR_FACT_ALL = 'Y';

   v_id_ter         TZRFACR.TZRFACR_TRDPARTY_ID%type;
   v_pidm_ter     TZRFACR.TZRFACR_TRDPARTY_PIDM%type;
   v_name_ter     TZRFACR.TZRFACR_TRDPARTY_NAME%type;

   v_sdoc_fact      varchar2(10);
   v_sdoc_nc        varchar2(10);
   v_sdoc_cp        varchar2(10);

p_result varchar2(550);


cursor c_is_plan_pago is
select 'Y' 
from tbraccd, tbristl  where 
tbraccd_pidm = tbristl_pidm 
and TBRACCD_CROSSREF_NUMBER = TBRISTL_REF_NUMBER
and tbraccd_pidm = p_pidm 
and TBRACCD_SRCE_CODE = 'I'
and exists
            (select 'Y' 
            from tzrfact 
            where tzrfact_pidm = tbraccd_pidm 
            and tzrfact_sdoc_code = (select  GTVSDAX_EXTERNAL_CODE  from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_FACT')
            and  TZRFACT_DOC_NUMBER = p_doc_number 
            and TZRFACT_TRAN_NUM = TBRACCD_TRAN_NUMBER)
and TBRACCD_CROSSREF_NUMBER is not null;

v_is_plan varchar2(1):= NULL;

--acastillo
v_dicd_code stvcamp.stvcamp_dicd_code%type;

cursor c_get_dicd_code (p_campus varchar2)is
select stvcamp_dicd_code 
from stvcamp 
where stvcamp_code = p_campus;

cursor c_get_usr_reimp (p_doctype varchar2,p_prefix1 varchar2, p_prefix2 varchar2,p_camp_code varchar2 ) is
select  gorfbpr.GORFBPR_FGAC_USER_ID
              FROM tvrsdsq, gorfbpr
             WHERE   TVRSDSQ_FBPR_CODE =   gorfbpr_fbpr_code
                   AND tvrsdsq_sdoc_code = p_doctype
                   AND tvrsdsq_prefix_1 = NVL (p_prefix1, tvrsdsq_prefix_1)
                   AND tvrsdsq_prefix_2 = NVL (p_prefix2, tvrsdsq_prefix_2)
                   AND tvrsdsq_camp_code = NVL (p_camp_code, tvrsdsq_camp_code)
                   AND tvrsdsq_valid_until >= SYSDATE;

p_usr_reimp varchar2(60);
begin

 OPEN c_get_data_i ('PUCE_FACT', 'COD_FACT', 'EXT');
 FETCH c_get_data_i INTO v_sdoc_fact;
 CLOSE c_get_data_i;

OPEN c_get_data_i ('PUCE_FACT', 'COD_NC', 'EXT');
 FETCH c_get_data_i INTO v_sdoc_nc;
 CLOSE c_get_data_i;

 OPEN c_get_data_i ('PUCE_FACT', 'COD_CP', 'EXT');
 FETCH c_get_data_i INTO v_sdoc_cp;
 CLOSE c_get_data_i;

p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'p_reimpresion_documento', p_sdoc_code||' p_doc_number: '||p_doc_number||' p_user: '||p_user, user);

 IF v_sdoc_fact = p_sdoc_code then

open c_is_plan_pago;
fetch c_is_plan_pago into v_is_plan;
close c_is_plan_pago;


IF v_is_plan is null then
 OPEN c_get_init_data;
 FETCH c_get_init_data INTO v_sri_prefix1, v_sri_prefix2, v_campus, v_user, v_doc_num_interno;
 CLOSE c_get_init_data;


open c_get_usr_reimp (p_sdoc_code ,v_sri_prefix1, v_sri_prefix2,v_campus) ;
fetch c_get_usr_reimp into p_usr_reimp;
close c_get_usr_reimp;

p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'FACTURA', v_sri_prefix1||' v_sri_prefix2: '||v_sri_prefix2||' v_campus: '||v_campus||' v_doc_num_interno: '||v_doc_num_interno ||' v_user_original:'||p_usr_reimp, user);

 IF v_sri_prefix1 is not null then

  tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_code,
                                           p_user            => p_usr_reimp, 
                                     p_camp_code       => v_campus,
                                          p_prefix1         => v_sri_prefix1,
                                          p_prefix2         => v_sri_prefix2,
                                     p_next_numdoc     => v_doc_num, 
                                           p_seq             => v_seq,    
                                        p_errormsg        => v_error,
                                      p_camp_district   => v_district); 

    p_folio_factura := v_sri_prefix1 || '-'||v_sri_prefix2 ||'-'|| lpad(v_doc_num,9,'0');
    p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'Factura', p_folio_factura, p_usr_reimp);

    IF v_doc_num is not null then           
                                TZKPUFC.P_UPDATE_SECUENCIA(
                                    P_DOCTYPE => p_sdoc_code,
                                    P_USER => p_usr_reimp,
                                    P_PREFIX1 => v_sri_prefix1,
                                    P_PREFIX2 => v_sri_prefix2,
                                    P_CAMP_CODE => v_campus,
                                    P_SECUENCIA => v_doc_num,
                                    P_ERROR => v_err_update
                                  );

      open c_get_terceros (p_pidm, v_doc_num_interno);
      fetch c_get_terceros into v_id_ter, v_pidm_ter, v_name_ter;
      close c_get_terceros;

    begin 
        insert into tzrfact (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND
                 , TZRFACT_SRI_DOCNUM
                 , TZRFACT_STPERDOC_QTY, TZRFACT_CREDNT_BNNR
                 , TZRFACT_CREDNT_SRICODE, TZRFACT_NCRED_REASON
                 , TZRFACT_PREFACT_DATE
                 , TZRFACT_FACT_DATE
                 , TZRFACT_CREDNT_DATE
                 , TZRFACT_ACTIVITY_DATE, TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE 
                 ,TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_CAMPUS) 
        select TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND
                 , p_folio_factura 
                 , TZRFACT_STPERDOC_QTY, TZRFACT_CREDNT_BNNR
                 , TZRFACT_CREDNT_SRICODE, TZRFACT_NCRED_REASON
                 , TZRFACT_PREFACT_DATE
                 , sysdate TZRFACT_FACT_DATE
                 , TZRFACT_CREDNT_DATE
                 , sysdate TZRFACT_ACTIVITY_DATE, 
                 p_user 
                 , TZRFACT_TERM_CODE, TZRFACT_PAY_DATE 
                 , v_id_ter, v_pidm_ter, v_name_ter, v_campus
        from tzrfact 
        where TZRFACT_PIDM = p_pidm    
            and TZRFACT_SRI_DOCNUM = p_doc_number
            and TZRFACT_CREDNT_BNNR is null
            and TZRFACT_RECEIPT_NUM is null;


         tzkpufc.p_upd_cancel_ind(p_pidm, p_doc_number, 'FACT', p_result);

      p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'FACTURA', 'insert. Cancel:' ||p_doc_number||' '||p_result, user);

      exception when others then p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);     
      p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'FACTURA', p_return, user);
      end;      

     END IF; 

     p_return:= p_folio_factura;
   else
     p_return:= 'No existe factura por reimprimir';

   END IF; 

ELSE
     p_return:= 'Factura pertenece a plan de pago.';
END IF; 

 ELSIF v_sdoc_nc = p_sdoc_code then

 OPEN c_get_init_data_nc;
 FETCH c_get_init_data_nc INTO v_sri_prefix1, v_sri_prefix2, v_campus, v_user, v_doc_num_interno;
 CLOSE c_get_init_data_nc;


open c_get_usr_reimp (p_sdoc_code ,v_sri_prefix1, v_sri_prefix2,v_campus) ;
fetch c_get_usr_reimp into p_usr_reimp;
close c_get_usr_reimp;

p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'NC', v_sri_prefix1||' v_sri_prefix2: '||v_sri_prefix2||' v_campus: '||v_campus||' v_doc_num_interno: '||v_doc_num_interno ||' v_user_original: '||p_usr_reimp, user);

 IF v_sri_prefix1 is not null then

  tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_code,
                                           p_user            => p_usr_reimp, 
                                     p_camp_code       => v_campus,
                                          p_prefix1         => v_sri_prefix1,
                                          p_prefix2         => v_sri_prefix2,
                                     p_next_numdoc     => v_doc_num, 
                                           p_seq             => v_seq,    
                                        p_errormsg        => v_error,
                                      p_camp_district   => v_district); 

    p_folio_factura := v_sri_prefix1 || '-'||v_sri_prefix2 ||'-'|| lpad(v_doc_num,9,'0');

    p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'NC', p_folio_factura, p_usr_reimp);

    IF v_doc_num is not null then           
                                TZKPUFC.P_UPDATE_SECUENCIA(
                                    P_DOCTYPE => p_sdoc_code,
                                    P_USER => p_usr_reimp,
                                    P_PREFIX1 => v_sri_prefix1,
                                    P_PREFIX2 => v_sri_prefix2,
                                    P_CAMP_CODE => v_campus,
                                    P_SECUENCIA => v_doc_num,
                                    P_ERROR => v_err_update
                                  );

      open c_get_terceros (p_pidm, v_doc_num_interno);
      fetch c_get_terceros into v_id_ter, v_pidm_ter, v_name_ter;
      close c_get_terceros;

    begin 
        insert into tzrfact (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND
                 , TZRFACT_STPERDOC_QTY, TZRFACT_CREDNT_BNNR
                 , TZRFACT_CREDNT_SRICODE, TZRFACT_NCRED_REASON
                 , TZRFACT_PREFACT_DATE
                 , TZRFACT_FACT_DATE
                 , TZRFACT_CREDNT_DATE
                 , TZRFACT_ACTIVITY_DATE, TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE 
                 ,TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_SRI_DOCNUM, TZRFACT_CAMPUS) 
        select TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND
                 , TZRFACT_STPERDOC_QTY, TZRFACT_CREDNT_BNNR
                 , p_folio_factura , TZRFACT_NCRED_REASON
                 , TZRFACT_PREFACT_DATE
                 ,  TZRFACT_FACT_DATE
                 , sysdate TZRFACT_CREDNT_DATE
                 , sysdate TZRFACT_ACTIVITY_DATE, 
                 p_user 
                 , TZRFACT_TERM_CODE, TZRFACT_PAY_DATE 
                 , v_id_ter, v_pidm_ter, v_name_ter, TZRFACT_SRI_DOCNUM, v_campus
        from tzrfact 
        where TZRFACT_PIDM = p_pidm    
            and TZRFACT_CREDNT_SRICODE = p_doc_number;


          tzkpufc.p_upd_cancel_ind(p_pidm, p_doc_number, 'NC', p_result);

   p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'NC', 'insert. Cancel:' || p_doc_number||' '||p_result, user);

      exception when others then p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);     
      p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'NC', p_return, user);
      end;      

     END IF; 

     p_return:= p_folio_factura;
   else
     p_return:= 'No existe nota de crédito por reimprimir';
   p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'NC', 'p_return: ' ||p_return, user);

   END IF; 
 ELSIF v_sdoc_cp = p_sdoc_code then


 OPEN c_get_init_data_cp;
 FETCH c_get_init_data_cp INTO  v_campus, v_user, v_doc_num_interno;
 CLOSE c_get_init_data_cp;



p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'Comprobante', v_campus||' v_user: '||v_user||' v_doc_num_interno: '||v_doc_num_interno ||' v_user_original: '||v_user, user);


 IF v_campus is not null then
	--acastillo
	 open c_get_dicd_code(v_campus);
	 fetch c_get_dicd_code into v_dicd_code;
	 close c_get_dicd_code;

        tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_code,
                                                              p_user            => v_user, 
                                                              p_camp_code       => v_campus,
                                                              --p_prefix1         => 1,
															  p_prefix1         => v_dicd_code,
                                                              p_prefix2         => null,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 

        p_folio_factura := v_district ||1|| lpad(v_doc_num,11,'0');

        p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'Comprobante', p_folio_factura, user);

                   IF v_doc_num is not null then           

                           UPDATE tvrsdsq
                           SET tvrsdsq_max_seq = v_doc_num,
                               TVRSDSQ_ACTIVITY_DATE = SYSDATE,
                               TVRSDSQ_DATA_ORIGIN = 'TZKPUFC Reimpr',
                               TVRSDSQ_USER_ID = USER
                         WHERE     tvrsdsq_sdoc_code = p_sdoc_code
                               AND tvrsdsq_fbpr_code IN
                                       (SELECT gorfbpr_fbpr_code
                                          FROM gorfbpr
                                         WHERE gorfbpr_fgac_user_id = v_user)
                               AND tvrsdsq_valid_until >= SYSDATE
                               --AND tvrsdsq_prefix_1 = 1   
								AND tvrsdsq_prefix_1 = v_dicd_code							   
                               AND tvrsdsq_camp_code = v_campus;


BEGIN
    INSERT INTO TZRFACT
    (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, 
    TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND,  TZRFACT_RECEIPT_NUM, 
    TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY,      
     TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE,  TZRFACT_ACTIVITY_DATE, 
    TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_SRI_DOCNUM, TZRFACT_CAMPUS)
    select TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, 
    TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND, p_folio_factura, 
    TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY,
     TZRFACT_PREFACT_DATE, sysdate, sysdate, 
    p_user 
    , TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_SRI_DOCNUM, v_campus
    from TZRFACT
    where TZRFACT_pidm = p_pidm
         and TZRFACT_RECEIPT_NUM = p_doc_number;

    tzkpufc.p_upd_cancel_ind(p_pidm, p_doc_number, 'COMP', p_result);

   p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'Comprobante', 'insert. Cancel:' ||p_doc_number||' '||p_result, user);

     exception when others then 
     p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);
     p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'Comprobante', 'p_return: ' ||p_return, user);
     END; 


      END IF; 

   p_return:= p_folio_factura;      

   else
     p_return:= 'No existe Comprobante por reimprimir';
   p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'Comprobante', 'p_return: ' ||p_return, user);
   END IF; 
 ELSE
    p_return := 'Tipo de documento inválido.';
     p_ins_tzrrlog(p_pidm,  'REIMPRESION', 'General', 'p_return: ' ||p_return, user);

 END IF; 


exception when others then p_return :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);     
end;


procedure  p_genera_factura (p_TVRMLCB_PIDM number, p_TERM_CODE varchar2,  v_doc_number varchar2, p_TVRMLCB_USER varchar2) is
--PRAGMA AUTONOMOUS_TRANSACTION;

v_has_sri varchar2(17):= '';
v_sdoc_code    GTVSDAX.GTVSDAX_EXTERNAL_CODE%type;
v_pto_emision varchar2(9);
v_prefix_1 TVRSDSQ.TVRSDSQ_PREFIX_1%type;
v_prefix_2 TVRSDSQ.TVRSDSQ_PREFIX_1%type;   
p_campus varchar2(12);
p_program varchar2(12):= '';
v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
v_error  varchar2(1000);
v_district  VARCHAR2(3);
p_folio_factura varchar2(20);
v_err_update  varchar2(1000);
v_TRDPARTY_ID varchar2(10);
v_TRDPARTY_PIDM number(8); 
v_TRDPARTY_NAME varchar2(300);	
v_STPERDOC_QTY varchar2(10);
v_trx_plan TBRACCD.TBRACCD_TRAN_NUMBER%type;
v_plan_amount       TBRISTL.TBRISTL_PLAN_AMOUNT%type;
v_plan_detail_code TBRISTL.TBRISTL_PLAN_DETAIL_CODE%type;
v_prefact_date date;
v_crn TZRFACT.TZRFACT_CRN_CONTND%type;
--hermes.navarro
v_cant_seq_cuotas number := 0;
TYPE tabla_seq_cuotas IS TABLE OF VARCHAR2 (20);
t_seq_cuotas tabla_seq_cuotas := tabla_seq_cuotas();
--hermes.navarro

cursor c_has_sri (p_pidm  NUMBER, p_doc_number number) is 
select TZRFACT_SRI_DOCNUM from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_DOC_NUMBER = p_doc_number
and TZRFACT_SRI_DOCNUM is not null;

cursor c_get_sdoc_code (p_code varchar2) is
        select  GTVSDAX_EXTERNAL_CODE, GTVSDAX_TRANSLATION_CODE 
        from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = p_code;

cursor c_get_pto_emision (p_usuario varchar2) IS
   select TVRSDSQ_CAMP_CODE, TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2 from TVRSDSQ where TVRSDSQ_SDOC_CODE = (SELECT  gtvsdax_external_code
                        FROM   gtvsdax
                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT'
                        AND     gtvsdax_internal_code IN( 'COD_FACT')) and TVRSDSQ_FBPR_CODE in (select GORFBPR_FBPR_CODE from GENERAL.GORFBPR where GORFBPR_FGAC_USER_ID = p_usuario);

cursor c_terceros (p_pidm  NUMBER, p_doc_number number) is
select TZRFACR_TRDPARTY_ID, TZRFACR_TRDPARTY_PIDM, TZRFACR_TRDPARTY_NAME,	1 TZRFACR_STPERDOC_QTY
from tzrfacr
where TZRFACR_PIDM = p_pidm
     and TZRFACR_DOC_NUMBER = p_doc_number
     and nvl(TZRFACR_FACT_ALL,'N') = 'Y';

cursor c_pagos ( p_pidm number, p_doc_number varchar2) is
select TVRMLCB_DETAIL_CODE, TVRMLCB_AMOUNT, TVRMLCB_TRAN_PAGO
from tvrmlcb_temp  where TVRMLCB_PIDM= p_pidm
and TVRMLCB_DOC_NUMBER = p_doc_number
and TVRMLCB_TRAN_ORIGINAL is null;


v_crossreference  TBRACCD.TBRACCD_CROSSREF_NUMBER%type;
p_sdoc_cuotas  varchar2(10);
v_doc_num_int   tvrsdsq.tvrsdsq_max_seq%TYPE;
   v_seq_2   tvrsdsq.tvrsdsq_seq_num%TYPE;
   v_error_2  varchar2(1000);
   v_district_2  VARCHAR2(3);

cursor c_get_tran_plan_pago (p_pidm number, p_doc_number varchar2) is
select TBRACCD_TRAN_NUMBER, TBRACCD_DETAIL_CODE, TBRACCD_AMOUNT
         , TBRACCD_CROSSREF_NUMBER
from tbraccd, tbristl 
where tbraccd_pidm = p_pidm 
and TBRACCD_SRCE_CODE = 'I'
and TBRACCD_TRAN_NUMBER in (
select TBRAPPL_PAY_TRAN_NUMBER 
from tbrappl where tbrappl_pidm = tbraccd_pidm and TBRAPPL_CHG_TRAN_NUMBER in 
(select TVRSDOC_CHG_TRAN_NUMBER 
   from tvrsdoc where TVRSDOC_PIDM = tbraccd_pidm and tvrsdoc_doc_number = p_doc_number and TVRSDOC_DOC_CANCEL_IND is null)
and TBRAPPL_REAPPL_IND is null
)
and TBRACCD_PIDM = TBRISTL_PIDM
and TBRACCD_CROSSREF_NUMBER = TBRISTL_REF_NUMBER
and TBRACCD_TERM_CODE = TBRISTL_TERM_CODE
and TBRACCD_DETAIL_CODE = TBRISTL_PLAN_DETAIL_CODE
and not exists (select 'Y' from tzrfact where tzrfact_pidm = tbraccd_pidm and TZRFACT_TRAN_NUM = TBRACCD_TRAN_NUMBER and TZRFACT_FACT_CANCEL_IND is null)
;


cursor c_get_cuotas (p_pidm in number, p_crossref in number, p_doc_number varchar2) is
select TBRACCD_PIDM, TBRACCD_TRAN_NUMBER, TBRACCD_TERM_CODE, TBRACCD_DETAIL_CODE, TBRACCD_AMOUNT, TBRACCD_EFFECTIVE_DATE, TBRACCD_DESC, TBRACCD_CROSSREF_NUMBER
from tbraccd , tbristl
where 
tbraccd_pidm = tbristl_pidm
and TBRISTL_REF_NUMBER = TBRACCD_CROSSREF_NUMBER
and TBRISTL_PRIN_DETAIL_CODE = TBRACCD_DETAIL_CODE
and tbraccd_pidm =  p_pidm 
and TBRACCD_CROSSREF_NUMBER = p_crossref
and TBRACCD_SRCE_CODE = 'I'
and not exists (select 'Y' from tzrfact where tzrfact_pidm = p_doc_number and TZRFACT_TRAN_NUM = TBRACCD_TRAN_NUMBER and TZRFACT_COMP_CANCEL_IND is null)
order by TBRACCD_TRAN_NUMBER;

cursor c_get_prefix2_internal (p_sdoc_cuotas varchar2) is
select TVRSDSQ_PREFIX_2 from tvrsdsq where TVRSDSQ_SDOC_CODE = p_sdoc_cuotas and trunc(sysdate)<= trunc(TVRSDSQ_VALID_UNTIL);

p_prefix2_cuotas TVRSDSQ.TVRSDSQ_PREFIX_2%type;
p_interno_cuotas varchar2(20);

cursor c_adicional (p_pidm  NUMBER, p_doc_number number)is
select TZRFACT_PREFACT_DATE
,TZRFACT_CRN_CONTND
,TZRFACT_CURR_PROGRAM programa
, decode(TZRFACT_CAMPUS, null, (select STVCAMP_CODE  from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum =1), TZRFACT_CAMPUS) campus 
from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_DOC_NUMBER = p_doc_number and TZRFACT_PREFACT_DATE is not null ;

v_exists_internal varchar2(1);
v_flag number(2);
cursor c_exists_internal (p_pidm in number, p_interno_cuotas in varchar2) is
    select unique 'Y'
    from tzrfact
    where TZRFACT_INTERNAL_RECEIPT_NUM = p_interno_cuotas
    and   TZRFACT_SDOC_CODE = 'XC'
    and   tzrfact_pidm <> p_pidm;

    e_invalid_internal EXCEPTION;

begin

   v_exists_internal :=  'Y';
   v_flag := 0;
   open c_adicional (p_TVRMLCB_PIDM,v_doc_number);
   fetch c_adicional into v_prefact_date, v_crn, p_program, p_campus;
   close c_adicional;


    OPEN c_has_sri(p_TVRMLCB_PIDM, v_doc_number);
    FETCH c_has_sri into v_has_sri;
    CLOSE c_has_sri;

    tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '1- v_has_sri: ' ||v_has_sri, user);

     OPEN c_get_sdoc_code ('COD_FACT');
     FETCH c_get_sdoc_code into v_sdoc_code, p_sdoc_cuotas;
     CLOSE c_get_sdoc_code;


IF  v_has_sri is null then

                   OPEN c_get_pto_emision (p_TVRMLCB_USER);
                   FETCH c_get_pto_emision into v_pto_emision, v_prefix_1, v_prefix_2;
                   CLOSE c_get_pto_emision;

tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '2- emision: ' ||v_pto_emision ||' - '|| v_prefix_1||' - '|| v_prefix_2, user);

        IF v_prefix_1 is not null and v_prefix_2 is not null and p_program is not null and p_campus is not null then  

                        tzkpufc.p_get_next_folio (p_doctype         => v_sdoc_code,
                                                              p_user            => p_TVRMLCB_USER, 
                                                              p_camp_code       => p_campus,
                                                              p_prefix1         => v_prefix_1,
                                                              p_prefix2         => v_prefix_2,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 


     tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '3- Genera Folio: ' ||v_sdoc_code ||' - '|| p_campus||' - '|| v_prefix_1||' - '|| v_prefix_2||' - '|| v_doc_num||' - '|| v_error, user);

                        IF v_doc_num is not null then           

  p_folio_factura := v_prefix_1 || '-'||v_prefix_2 ||'-'|| lpad(v_doc_num,9,'0');

                                TZKPUFC.P_UPDATE_SECUENCIA(
                                    P_DOCTYPE => v_sdoc_code,
                                    P_USER => p_TVRMLCB_USER,
                                    P_PREFIX1 => v_prefix_1,
                                    P_PREFIX2 => v_prefix_2,
                                    P_CAMP_CODE => p_campus,
                                    P_SECUENCIA => v_doc_num,
                                    P_ERROR => v_err_update
                                  );

                        tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '4- TZKPUFC.P_UPDATE_SECUENCIA: ' ||p_folio_factura || ' Err Update:' ||v_err_update, user);
                        --commit;
                        END IF; 

            ELSE
           delete from tvrmlcb_temp  where TVRMLCB_PIDM = p_TVRMLCB_PIDM
                                 and TVRMLCB_DOC_NUMBER = v_doc_number;
    END IF; 

ELSE
p_folio_factura := v_has_sri;

END IF; 

tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '5- Actualiza folio en tabla temporal ' , user);


     IF p_folio_factura is not null then
                            update tvrmlcb_temp set 
                            TVRMLCB_SRI_DOC_NUMBER = p_folio_factura
                             where TVRMLCB_PIDM = p_TVRMLCB_PIDM
                                 and TVRMLCB_DOC_NUMBER = v_doc_number;


                               OPEN c_terceros(p_TVRMLCB_PIDM,v_doc_number);
                                fetch c_terceros into v_TRDPARTY_ID,v_TRDPARTY_PIDM,v_TRDPARTY_NAME,v_STPERDOC_QTY;
                                CLOSE c_terceros;

        tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '6- Siembra pagos y valida terceros: ' ||v_TRDPARTY_ID || ' - '||v_TRDPARTY_PIDM|| ' - '||v_TRDPARTY_NAME, user);


    begin
        FOR r_pay IN c_pagos (p_TVRMLCB_PIDM, v_doc_number)
                LOOP
                            tzkpufc.p_insert_tzrfact_fact (
                                    p_pidm            => p_TVRMLCB_PIDM,
                                    p_sdoc_code       => v_sdoc_code,
                                    p_doc_number      => v_doc_number,
                                    p_curr_program    => p_program,
                                    p_sale_docnum     => tzkpufc.f_get_docnum_fmt(v_doc_number),
                                    p_det_code_doc    => r_pay.TVRMLCB_DETAIL_CODE,
                                    p_amnt_trans      => r_pay.TVRMLCB_AMOUNT,
                                    p_tran_num        =>  r_pay.TVRMLCB_TRAN_PAGO, 
                                    p_sri_docnum      => null,
                                    p_receipt_num     => null,
                                    p_fact_date       => sysdate,
                                    p_activity_date   => sysdate,
                                    p_user            => p_TVRMLCB_USER,
                                    p_term_code => p_TERM_CODE,
                                    p_TRDPARTY_ID => v_TRDPARTY_ID, 
                                    p_TRDPARTY_PIDM => v_TRDPARTY_PIDM, 
                                    p_TRDPARTY_NAME =>v_TRDPARTY_NAME, 
                                    p_STPERDOC_QTY =>1
                                    ); 

        END LOOP;        
        Exception when others then
            tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'Error Insert TZRFACT, valida plan de pago:  ' ||sqlerrm, user);
    End;

        open c_get_tran_plan_pago (p_TVRMLCB_PIDM, v_doc_number);
        fetch c_get_tran_plan_pago into v_trx_plan, v_plan_detail_code, v_plan_amount, v_crossreference;
        close c_get_tran_plan_pago;

        tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '7- Insert TZRFACT, valida plan de pago:  ' ||v_trx_plan ||' - '|| v_plan_detail_code||' - '|| v_plan_amount ||' - '|| v_crossreference, user);

        IF v_trx_plan is not null THEN
        tzkpufc.p_insert_tzrfact_fact (
                                    p_pidm            => p_TVRMLCB_PIDM,
                                    p_sdoc_code       => v_sdoc_code,
                                    p_doc_number      => v_doc_number,
                                    p_curr_program    => p_program,
                                    p_sale_docnum     => tzkpufc.f_get_docnum_fmt(v_doc_number),
                                    p_det_code_doc    => v_plan_detail_code,
                                    p_amnt_trans      => v_plan_amount,
                                    p_tran_num        =>  v_trx_plan, 
                                    p_sri_docnum      => null,
                                    p_receipt_num     => null,
                                    p_fact_date       => sysdate,
                                    p_activity_date   => sysdate,
                                    p_user            => p_TVRMLCB_USER,
                                    p_term_code => p_TERM_CODE,
                                    p_TRDPARTY_ID => v_TRDPARTY_ID, 
                                    p_TRDPARTY_PIDM => v_TRDPARTY_PIDM, 
                                    p_TRDPARTY_NAME =>v_TRDPARTY_NAME, 
                                    p_STPERDOC_QTY =>1
                                    ); 


                         OPEN c_get_sdoc_code ('COD_CP');
                         FETCH c_get_sdoc_code into v_sdoc_code, p_sdoc_cuotas;
                         CLOSE c_get_sdoc_code;

                          OPEN c_get_prefix2_internal (p_sdoc_cuotas);
                         fetch c_get_prefix2_internal into p_prefix2_cuotas;
                         close c_get_prefix2_internal;

                         --HERMES.NAVARRO
                         --SE OBTIENEN LAS SECUENCIAS Y SE ALMACENAN EN LA TABLA CREADA PARA ESTO
                         begin
                         <<INICIAR_CUOTAS>>
                         t_seq_cuotas := tabla_seq_cuotas();
                         FOR r_cuota IN c_get_cuotas (p_TVRMLCB_PIDM, v_crossreference, v_doc_number)
                              LOOP
                                    tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_cuotas,
                                                                          p_user            => p_TVRMLCB_USER, 
                                                                          p_camp_code       => p_campus,
                                                                          p_prefix1         => v_district, 
                                                                          p_prefix2         => p_prefix2_cuotas,
                                                                          p_next_numdoc     => v_doc_num_int, 
                                                                          p_seq             => v_seq_2,    
                                                                          p_errormsg        => v_error_2,
                                                                          p_camp_district   => v_district_2); 

                                   p_interno_cuotas := v_district ||p_prefix2_cuotas|| lpad(v_doc_num_int,11,'0');
                                   t_seq_cuotas.EXTEND;
                                   t_seq_cuotas(t_seq_cuotas.LAST) := p_interno_cuotas;
                                   p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB: ', ' Seq Generada1: '|| p_interno_cuotas, user);                        
                                   --hacer el update
                                   IF v_doc_num_int is not null then           
										   UPDATE tvrsdsq
										   SET tvrsdsq_max_seq = v_doc_num_int,
											   TVRSDSQ_ACTIVITY_DATE = SYSDATE,
											   TVRSDSQ_DATA_ORIGIN = 'TZKPUFC',
											   TVRSDSQ_USER_ID = p_TVRMLCB_USER
										 WHERE     tvrsdsq_sdoc_code = p_sdoc_cuotas
											   AND tvrsdsq_fbpr_code IN
													   (SELECT gorfbpr_fbpr_code
														  FROM gorfbpr
														 WHERE gorfbpr_fgac_user_id = p_TVRMLCB_USER)
											   AND tvrsdsq_valid_until >= SYSDATE
											   AND tvrsdsq_prefix_1 = v_district
											   AND tvrsdsq_prefix_2 = p_prefix2_cuotas
											   AND tvrsdsq_camp_code = p_campus;
                                     end if;
                                   --fin update
                                   p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB: ', ' Despues Update Seq Generada1: '|| p_interno_cuotas, user);
                                END LOOP;


                         --imprimir las secuencias generadas para verificar
                        FOR j in 1 .. t_seq_cuotas.COUNT LOOP 
                            p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB: ', ' Seq Generada: '||j||' - '|| t_seq_cuotas(j), user);
                        END LOOP;
                         --fin imprimir las secuencias

                         --SE VERIFICA SI EXISTE ALGUNA SECUENCIA PARA OTRO ESTUDIANTE
                         FOR i in 1 .. t_seq_cuotas.COUNT LOOP 
                            v_exists_internal := 'N';
                               open c_exists_internal (p_TVRMLCB_PIDM,t_seq_cuotas(i));
                               fetch c_exists_internal into v_exists_internal;
                               close c_exists_internal;
                                if v_exists_internal = 'Y' then                                            
                                    v_flag := v_flag + 1;
                                    p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB: ', ' sleep 2 v_flag: '||v_flag||'- v_exists_internal: '|| v_exists_internal ||' p_interno_cuotas: '||t_seq_cuotas(i), user);
                                    DBMS_LOCK.Sleep(2);
                                    if v_flag <= 4 then
                                        goto INICIAR_CUOTAS;
                                    else
                                        p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB: ', ' Exit - v_flag: '||v_flag||'- v_exists_internal: '|| v_exists_internal ||' p_interno_cuotas: '||t_seq_cuotas(i), user);
                                        raise e_invalid_internal;
                                        exit;     
                                    end if;
                               end if;
                       END LOOP;
                       v_cant_seq_cuotas := 1;
                       --se recorren las cuotas para hacer el insert en 
                        FOR r_cuota IN c_get_cuotas (p_TVRMLCB_PIDM, v_crossreference, v_doc_number)
                        loop
                            tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '13- CUOTAS:  ' ||v_doc_num_int  ||' - '|| r_cuota.TBRACCD_TRAN_NUMBER ||' - '|| p_interno_cuotas ||' - '|| v_crossreference, user);
                            Insert into TZRFACT (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_DOC_NUMBER,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_SALE_DOCNUM,
                                                 TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM,TZRFACT_INTERNAL_RECEIPT_NUM, 
                                                 TZRFACT_FACT_DATE,TZRFACT_ACTIVITY_DATE,TZRFACT_USER, TZRFACT_TERM_CODE,    TZRFACT_PAY_DATE, TZRFACT_CAMPUS
                                                  ) 
                                     values ( p_TVRMLCB_PIDM,f_get_type_comprobante(r_cuota.TBRACCD_DETAIL_CODE, 'Y'),v_doc_number,gb_common.f_get_id(p_TVRMLCB_PIDM),p_program,tzkpufc.f_get_docnum_fmt(v_doc_number),
                                                r_cuota.TBRACCD_DETAIL_CODE,r_cuota.TBRACCD_AMOUNT,r_cuota.TBRACCD_TRAN_NUMBER,t_seq_cuotas(v_cant_seq_cuotas),
                                                sysdate,sysdate,p_TVRMLCB_USER, p_TERM_CODE,  sysdate, p_campus);

                        v_cant_seq_cuotas := v_cant_seq_cuotas + 1;
                        end loop;
                         Exception when e_invalid_internal then --raise aplication error
                                               p_ins_tzrrlog(p_TVRMLCB_PIDM,  'COMPROBANTE', 'TT_TVRMLCB ERROR AFT: ', ' Excepcion: '|| SUBSTR (SQLERRM, 1, 500), user);
                                               raise_application_error(-20555,'Error, consecutivo ya existe');
                                               return;					   
								when others then
                                tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB ERROR', '13- CUOTAS: Error ' ||sqlerrm, user);
                            end;
                         --HERMES.NAVARRO
            -----------------------------------------

        END IF;

                                  update TZRFACT
                                        set TZRFACT_SRI_DOCNUM = p_folio_factura,
                                              TZRFACT_FACT_DATE = sysdate,
                                              TZRFACT_TRDPARTY_ID = v_TRDPARTY_ID
                                              , TZRFACT_TRDPARTY_PIDM = v_TRDPARTY_PIDM
                                              , TZRFACT_TRDPARTY_NAME = v_TRDPARTY_NAME
                                              , TZRFACT_STPERDOC_QTY = 1
                                              , TZRFACT_USER = p_TVRMLCB_USER
                                              , TZRFACT_PREFACT_DATE = v_prefact_date
                                              , TZRFACT_PAY_DATE = sysdate
                                              , TZRFACT_CRN_CONTND = v_crn
                                        where 
                                        TZRFACT_PIDM = p_TVRMLCB_PIDM
                                        and TZRFACT_DOC_NUMBER = v_doc_number
                                        and TZRFACT_SRI_DOCNUM is  null;

                                  TZKPUFC.p_upd_TZRDPRF (p_TVRMLCB_PIDM,v_doc_number);

                                  delete from tvrmlcb_temp  where TVRMLCB_PIDM = p_TVRMLCB_PIDM
                                 and TVRMLCB_DOC_NUMBER = v_doc_number;

                                  tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'GENERA_FACTURA', 'TT_TVRMLCB', '8- Actualiza TZRFACT, tzrdprf y elimina data de temporal:  ' ||v_doc_number ||' - '||p_folio_factura, user);

end if; 

Exception when e_invalid_internal then 
       p_ins_tzrrlog(p_TVRMLCB_PIDM,  'COMPROBANTE', 'TT_TVRMLCB ERROR end: ', ' Excepcion: '|| SUBSTR (SQLERRM, 1, 500), user);
       --p_return:= p_return ||' Consecutivo ya existe, por favor intente nuevamente.';
       return;
END;

procedure p_genera_comprobante_NPP (p_TVRMLCB_PIDM number, p_TERM_CODE varchar2,  v_doc_number varchar2, p_TVRMLCB_USER varchar2) is 
p_folio_comprobante number(13);
v_has_comprobante number(13);
v_sdoc_code    GTVSDAX.GTVSDAX_EXTERNAL_CODE%type;
v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
v_error  varchar2(1000);
v_district  VARCHAR2(3);

v_TRDPARTY_ID varchar2(10);
v_TRDPARTY_PIDM number(8); 
v_TRDPARTY_NAME varchar2(300);	
v_STPERDOC_QTY varchar2(10);
p_campus varchar2(12);
p_program varchar2(12):= '';
v_prefact_date date;
v_crn TZRFACT.TZRFACT_CRN_CONTND%type;

cursor c_terceros (p_pidm  NUMBER, p_doc_number number) is
select TZRFACR_TRDPARTY_ID, TZRFACR_TRDPARTY_PIDM, TZRFACR_TRDPARTY_NAME,	1 TZRFACR_STPERDOC_QTY
from tzrfacr
where TZRFACR_PIDM = p_pidm
     and TZRFACR_DOC_NUMBER = p_doc_number
     and nvl(TZRFACR_FACT_ALL,'N') = 'Y';

cursor c_has_comprobante (p_pidm  NUMBER, p_doc_number varchar2) is 
select TZRFACT_RECEIPT_NUM from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_INTERNAL_RECEIPT_NUM = p_doc_number
and TZRFACT_RECEIPT_NUM is not null;

cursor c_adicional (p_pidm  NUMBER, p_doc_number varchar2)is
select TZRFACT_PREFACT_DATE
,TZRFACT_CRN_CONTND
,TZRFACT_CURR_PROGRAM programa
, TZRFACT_CAMPUS campus 
from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_INTERNAL_RECEIPT_NUM = p_doc_number ;

cursor c_pagos ( p_pidm number, p_doc_number varchar2) is
select TVRMLCB_DETAIL_CODE, TVRMLCB_AMOUNT, TVRMLCB_TRAN_PAGO,  TVRMLCB_TERM_CODE
from tvrmlcb_temp  where TVRMLCB_PIDM= p_pidm
and TVRMLCB_DOC_NUMBER = p_doc_number
and TVRMLCB_TRAN_ORIGINAL is null;

cursor c_get_sdoc_code (p_code varchar2) is
        select  GTVSDAX_EXTERNAL_CODE 
        from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = p_code;

v_prefix1 TVRSDSQ.TVRSDSQ_PREFIX_1%type;

cursor c_get_add_data is
select 
 TZRFACT_CURR_PROGRAM programa
 , TZRFACT_CAMPUS campus,
 	(select stvcamp_dicd_code from stvcamp where stvcamp_code = tzrfact_campus) dicd_code
from tzrfact where TZRFACT_PIDM = p_TVRMLCB_PIDM and TZRFACT_INTERNAL_RECEIPT_NUM = v_doc_number and rownum = 1;


BEGIN

    OPEN c_has_comprobante(p_TVRMLCB_PIDM, v_doc_number);
    FETCH c_has_comprobante into v_has_comprobante;
    CLOSE c_has_comprobante;

     OPEN c_get_sdoc_code ('COD_CP');
     FETCH c_get_sdoc_code into v_sdoc_code;
     CLOSE c_get_sdoc_code;

    open c_get_add_data;
    fetch c_get_add_data into p_program, p_campus, v_prefix1;
    close c_get_add_data;

IF  v_has_comprobante is null then    
tzkpufc.p_get_next_folio (p_doctype         => v_sdoc_code,
                                                              p_user            => p_TVRMLCB_USER, 
                                                              p_camp_code       => p_campus,
                                                              --p_prefix1         => 1,
                                                              p_prefix1         => v_prefix1,
                                                              p_prefix2         => null,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 

 tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'COMPROBANTE', 'COMP_NPP_XP', '1- v_sdoc_code: '||v_sdoc_code || ' p_campus: '||p_campus|| ' v_doc_num: '||v_doc_num|| ' v_error: '||v_error||' TVRMLCB_USER: '||p_TVRMLCB_USER, user);

    IF v_doc_num is not null then           
                 p_folio_comprobante := v_district ||1|| lpad(v_doc_num,11,'0');

                           UPDATE tvrsdsq
                           SET tvrsdsq_max_seq = v_doc_num,
                               TVRSDSQ_ACTIVITY_DATE = SYSDATE,
                               TVRSDSQ_DATA_ORIGIN = 'TVRMLCB',
                               TVRSDSQ_USER_ID = USER
                         WHERE     tvrsdsq_sdoc_code = v_sdoc_code
                               AND tvrsdsq_fbpr_code IN
                                       (SELECT gorfbpr_fbpr_code
                                          FROM gorfbpr
                                         WHERE gorfbpr_fgac_user_id = p_TVRMLCB_USER)
                               AND tvrsdsq_valid_until >= SYSDATE
                               --AND tvrsdsq_prefix_1 = 1
                               AND tvrsdsq_prefix_1 = v_prefix1							   
                               AND tvrsdsq_camp_code = p_campus;

     END IF; 

ELSE
p_folio_comprobante := v_has_comprobante;

END IF; 


   update tvrmlcb_temp set 
     TVRMLCB_SRI_DOC_NUMBER = p_folio_comprobante 
    where TVRMLCB_PIDM = p_TVRMLCB_PIDM
        and TVRMLCB_DOC_NUMBER = v_doc_number;

tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'COMPROBANTE', 'UPD_TVRMLCB_TEMP', 'p_folio_comprobante: ' || p_folio_comprobante||' v_doc_number: '|| v_doc_number, user);

    OPEN c_terceros(p_TVRMLCB_PIDM,v_doc_number);
    fetch c_terceros into v_TRDPARTY_ID,v_TRDPARTY_PIDM,v_TRDPARTY_NAME,v_STPERDOC_QTY;
    CLOSE c_terceros;

   open c_adicional (p_TVRMLCB_PIDM,v_doc_number);
   fetch c_adicional into v_prefact_date, v_crn, p_program, p_campus;
   close c_adicional;


        FOR r_pay IN c_pagos (p_TVRMLCB_PIDM, v_doc_number)
        LOOP

                    Insert into TZRFACT (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM,TZRFACT_TRDPARTY_ID,TZRFACT_TRDPARTY_PIDM,TZRFACT_TRDPARTY_NAME,TZRFACT_STPERDOC_QTY,TZRFACT_ACTIVITY_DATE,TZRFACT_USER,TZRFACT_TERM_CODE,TZRFACT_CAMPUS,TZRFACT_INTERNAL_RECEIPT_NUM
                                            ,TZRFACT_RECEIPT_NUM, TZRFACT_FACT_DATE , TZRFACT_PREFACT_DATE, TZRFACT_PAY_DATE) 
                                          values (p_TVRMLCB_PIDM, v_sdoc_code, gb_common.f_get_id(p_TVRMLCB_PIDM), p_program, r_pay.TVRMLCB_DETAIL_CODE, r_pay.TVRMLCB_AMOUNT, r_pay.TVRMLCB_TRAN_PAGO,  v_TRDPARTY_ID, v_TRDPARTY_PIDM, v_TRDPARTY_NAME,1,sysdate,p_TVRMLCB_USER,r_pay.TVRMLCB_TERM_CODE,p_campus,v_doc_number
                                          , p_folio_comprobante, sysdate, v_prefact_date, sysdate);


        END LOOP;

                     begin
                        update tzrfact
                        set TZRFACT_RECEIPT_NUM = p_folio_comprobante,
						TZRFACT_FACT_DATE = sysdate
                        where TZRFACT_PIDM = p_TVRMLCB_PIDM
                        and TZRFACT_SDOC_CODE = (select  GTVSDAX_CONCEPT from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_CP')
                        and TZRFACT_INTERNAL_RECEIPT_NUM = v_doc_number
                        and TZRFACT_RECEIPT_NUM is null;

                        tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'COMPROBANTE', 'UPD_TZRFACT_XP ', 'p_folio_comprobante: ' || p_folio_comprobante||' v_doc_number: '|| v_doc_number, user);

                        exception when others then null;                        
                       end; 

                                  TZKPUFC.p_upd_TZRDPRF (p_TVRMLCB_PIDM,v_doc_number);

                                  delete from tvrmlcb_temp  where TVRMLCB_PIDM = p_TVRMLCB_PIDM  and TVRMLCB_DOC_NUMBER = v_doc_number;

                                  tzkpufc.p_ins_tzrrlog(p_TVRMLCB_PIDM,  'COMPROBANTE', 'DEL_TVRMLCB_TEMP', 'FIN update TZRFACT, TZRDPRF y elimina temporal ' ||v_doc_number, user);

END;


PROCEDURE p_show_nota_credito (
                      p_pidm         IN NUMBER,
                      p_tzrfact_crednt_sricode   IN tzrfact.tzrfact_crednt_sricode%TYPE
                      )
    IS

v_texto varchar2(1000);

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

p_id_puce       spriden.spriden_id%TYPE;


       v_pidm number:=0;

        l_pdf                 BLOB;
        p_nombre_estudiante   VARCHAR2 (1000);
        p_web                 VARCHAR2 (1000);  
        p_doc_number          NUMBER;
        v_fecha_emision       DATE;
        v_email               goremal.goremal_email_address%TYPE; 
        v_total_venta_neta    NUMBER;   
        p_campus_number number (1);
         l_num_mask            VARCHAR2 (20) := 'L999G999G999D00';
        v_total_cargos        NUMBER;

v_tipo_iden           stvlgcy.stvlgcy_desc%TYPE;
v_iden                spbpers.spbpers_ssn%TYPE;
v_tipo_iden_sede           stvlgcy.stvlgcy_desc%TYPE;
v_iden_sede                spbpers.spbpers_ssn%TYPE;
v_id_estudiante       varchar2(20);
v_direccion           spraddr.spraddr_street_line1%TYPE;
v_dir_sede               spraddr.spraddr_street_line1%TYPE;
v_dir_city_sede      varchar2(50);
v_city varchar2(50);

p_emal_code varchar2(20);
p_emal_code_sede varchar2(20);
         p_sede          sovlcur.sovlcur_camp_code%TYPE;

        l_widths              plpdf_type.t_row_widths;      

        l_aligns_center       VARCHAR2 (2) := 'C';
        l_aligns_left         VARCHAR2 (2) := 'L';
        l_aligns_rigth        VARCHAR2 (2) := 'R';
        l_font_arial          NUMBER := 10;        
        l_font_courier        NUMBER := 8;        
        l_cell_courier        NUMBER := l_font_courier - 3.5;
        l_font_times          NUMBER := 14;
        l_cell_times          NUMBER := l_font_times - 8;


        v_periodo_prefactura  VARCHAR2 (6);
        v_tran_num            VARCHAR2 (20):='CANT';
        v_describe_detalle    VARCHAR2 (20):='DETALLE';
        v_valor_unitario      VARCHAR2 (20):='VALOR UNITARIO';
        v_valor_total         VARCHAR2 (20):='VALOR TOTAL';
        v_total_descuentos    NUMBER := 0;  

        v_total_pagos         NUMBER;

        v_descuento           NUMBER := 0; 
        v_descuento2          NUMBER := 0;  

        v_detalleivamayorcero VARCHAR2(40);
        v_valorivaestudiante  tzrfact.tzrfact_amnt_trans%TYPE;
        v_total               NUMBER := 0;  
        v_valor_retencion       NUMBER := 0;
        v_descripcion_retencion VARCHAR2 (200);
        v_total_factura         NUMBER := 0;    
        p_pidm_sede        spriden.spriden_pidm%TYPE;
        v_resolucionimpuestos   VARCHAR2 (300);
        v_rucsede               VARCHAR2 (300);
        v_direccionsede         VARCHAR2 (200);
        v_telefenosede          VARCHAR2 (200);
        v_emailsede             VARCHAR2 (200);
        v_cajero                tzrfact.tzrfact_user%TYPE;

        v_carreraestudiante     tzrfact.tzrfact_curr_program%TYPE;
       v_telefono sprtele.sprtele_phone_number%type;

       v_party_id  TZRFACT.TZRFACT_TRDPARTY_ID%type;
       v_party_pidm TZRFACT.TZRFACT_TRDPARTY_PIDM%type;
       v_party_name TZRFACT.TZRFACT_TRDPARTY_NAME%type;

       p_interna varchar2(1);
       v_fecha_nota_credito date;      
       ncred_reason varchar2(4000);
       v_total_sin_iva         NUMBER := 0;     
       v_totaldetalleivas   NUMBER := 0;     
       v_tzrfact_sri_docnum    tzrfact.tzrfact_sri_docnum%TYPE;
       v_ini_x number;
        v_ini_y number;  
        v_ancho number;
        v_alto number; 

 cursor c_get_data is 
        select  TZRFACT_TERM_CODE , tzrfact_doc_number,tzrfact_fact_date,  TZRFACT_CAMPUS, SUBSTR(tzrfact_sale_docnum,7,1) campus_number, tzrfact_curr_program, tzrfact_user  
                  ,TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_CREDNT_DATE, 
                  (
                SELECT gtvsdax_concept
                FROM  gtvsdax 
                WHERE gtvsdax_external_code =tzrfact_ncred_reason
                 AND   gtvsdax_internal_code='MOTIVO_NC'
                ) motivo
                , tzrfact_sri_docnum
        from tzrfact where tzrfact_pidm = p_pidm 
        and TZRFACT_SDOC_CODE = (select GTVSDAX_CONCEPT from gtvsdax where gtvsdax_internal_code_group = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_NC')
        and tzrfact_crednt_sricode =  p_tzrfact_crednt_sricode;

 cursor c_get_data_sede (p_campus_number number) is 
SELECT gb_common.f_get_pidm ( gtvsdax_external_code) pidm_sede, gtvsdax_comments 
                FROM  gtvsdax 
                WHERE gtvsdax_internal_code ='ID_PUCE' 
                AND   gtvsdax_internal_code_group='PUCE_FACT'
                AND   gtvsdax_translation_code= p_campus_number;

CURSOR c_nombre_completo (p_pidm number)
IS
    SELECT    REPLACE (spriden_last_name, '/', ' ')
    || ' '|| spriden_first_name|| ' '|| spriden_mi complete_name
    FROM spriden
    WHERE spriden_change_ind IS NULL 
    AND spriden_pidm = p_pidm;

CURSOR c_identificacion (p_pidm number)
IS
    SELECT (
    SELECT stvlgcy_desc
    FROM stvlgcy
    WHERE stvlgcy_code = spbpers_lgcy_code
    ) tipo_identificacion, spbpers_ssn  identificacion
    FROM spbpers
    WHERE spbpers_pidm =  p_pidm
    AND ROWNUM=1;

CURSOR c_cargos
IS 
select TZRFACT_STPERDOC_QTY, TZRFACT_DET_CODE_DOC, DESCRIPCION, TZRFACT_AMNT_TRANS, TZRFACT_CRN_CONTND, TZRFACT_TERM_CODE, tbbdetc_dcat_code from (
SELECT  tzrfact_stperdoc_qty 
           , tzrfact_det_code_doc
           , f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion
          , sum(tzrfact_amnt_trans) as tzrfact_amnt_trans
          ,tzrfact_crn_contnd
          ,tzrfact_term_code 
          ,tbbdetc_dcat_code
FROM  tzrfact, tbbdetc 
WHERE tzrfact_det_code_doc = tbbdetc_detail_code
and (case when p_interna = 'Y' and tbbdetc_dcat_code not in ('TAX','TER','FNA') then 1
        when p_interna = 'N' and tbbdetc_dcat_code not in ('TAX','FNA') then 1
        else  0
        end) = 1
and (case when tbbdetc_type_ind='C'  then 1
        when tbbdetc_type_ind='P' and tbbdetc_dcat_code in ('BEC') then 1
        else  0
        end) = 1
and tzrfact_sdoc_code  IN (SELECT GTVSDAX_CONCEPT   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_NC') )
AND   tzrfact_pidm     =  p_pidm 
AND   tzrfact_crednt_sricode =  p_tzrfact_crednt_sricode
GROUP BY tzrfact_stperdoc_qty ,
          tzrfact_det_code_doc,
          tzrfact_crn_contnd,tzrfact_term_code, tbbdetc_dcat_code)
where  (case when TBBDETC_DCAT_CODE='BEC' and TZRFACT_AMNT_TRANS < 0  then 0                     
            else  1
            end) = 1;

cursor c_get_descuento1 is
select sum(descuento1) from (
                        SELECT  TZRFACT_DET_CODE_DOC, SUM(tzrfact_amnt_trans)     descuento1                   
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT GTVSDAX_CONCEPT
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_NC')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_crednt_sricode    =  p_tzrfact_crednt_sricode                        
                        AND   tzrfact_det_code_doc  IN  (
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code LIKE '1%'
                                                        )group by TZRFACT_DET_CODE_DOC
) where descuento1 < 0;


cursor c_get_descuento2 is
/*select descuento2 from (
                        SELECT  --TZRFACT_DET_CODE_DOC, 
							SUM(tzrfact_amnt_trans) descuento2
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT GTVSDAX_CONCEPT
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_NC')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_amnt_trans < 0
                        AND   tzrfact_crednt_sricode    =   p_tzrfact_crednt_sricode
                        AND   tzrfact_det_code_doc  IN  ((
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code NOT LIKE '1%'
                                                        )
                                                        UNION
                                                        (
                                                         select TBBDETC_DETAIL_CODE from TBBDETC 
                                                         WHERE TBBDETC_DCAT_CODE IN ('BEC','DES')
                                                         AND    tbbdetc_type_ind = 'P'
                                                         AND TBBDETC_DETAIL_CODE NOT IN (
                                                         SELECT kvrfbse_dflt_detail_code 
                                                         FROM   kvrfbse 
                                                         WHERE kvrfbse_fndc_code  LIKE '1%')
                                                        )
                                                        ) --group by TZRFACT_DET_CODE_DOC
                                                        ) where descuento2 < 0;*/
select descuento2 from (
                        SELECT  --TZRFACT_DET_CODE_DOC, 
							SUM(tzrfact_amnt_trans) descuento2
                        --select * 
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT GTVSDAX_CONCEPT
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_NC')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_amnt_trans < 0
                        AND   tzrfact_crednt_sricode    =   p_tzrfact_crednt_sricode
                        AND   tzrfact_det_code_doc||tzrfact_amnt_trans  IN 
                                        (
										select tzrfact_det_code_doc||tzrfact_amnt_trans from (
										SELECT  tzrfact_stperdoc_qty 
												   , tzrfact_det_code_doc
												   , f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion
												  , sum(tzrfact_amnt_trans) as tzrfact_amnt_trans
												  ,tzrfact_crn_contnd
												  ,tzrfact_term_code 
												  ,tbbdetc_dcat_code
										FROM  tzrfact, tbbdetc 
										WHERE tzrfact_det_code_doc = tbbdetc_detail_code
										and (case when p_interna = 'Y' and tbbdetc_dcat_code not in ('TAX','TER','FNA') then 1
												when p_interna = 'N' and tbbdetc_dcat_code not in ('TAX','FNA') then 1
												else  0
												end) = 1
										and (case when tbbdetc_type_ind='C'  then 1
												when tbbdetc_type_ind='P' and tbbdetc_dcat_code in ('BEC') then 1
												else  0
												end) = 1
										and tzrfact_sdoc_code  IN (SELECT GTVSDAX_CONCEPT   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_NC') )
										AND   tzrfact_pidm     =  p_pidm 
										AND   tzrfact_crednt_sricode =  p_tzrfact_crednt_sricode   
										GROUP BY tzrfact_stperdoc_qty ,
												tzrfact_det_code_doc,
											  tzrfact_crn_contnd,tzrfact_term_code, tbbdetc_dcat_code
											)
										where  (case when TBBDETC_DCAT_CODE='BEC' and TZRFACT_AMNT_TRANS > 0  then 0                     
													else  1
													end) = 1

                                        )
                        AND   tzrfact_det_code_doc  IN  ((
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code NOT LIKE '1%'
                                                        )
                                                        UNION
                                                        (
                                                         select TBBDETC_DETAIL_CODE from TBBDETC 
                                                         WHERE TBBDETC_DCAT_CODE IN ('BEC','DES')
                                                         AND    tbbdetc_type_ind = 'P'
                                                         AND TBBDETC_DETAIL_CODE NOT IN (
                                                         SELECT kvrfbse_dflt_detail_code 
                                                         FROM   kvrfbse 
                                                         WHERE kvrfbse_fndc_code  LIKE '1%')
                                                        )
                                                        ) --group by TZRFACT_DET_CODE_DOC
                                                        ) where descuento2 < 0;														



CURSOR c_totalivas is
SELECT tbbdetc_detail_code, 
               'TOTAL GRAVADO CON ' ||tbbdetc_desc detalle, 
               tbbdetc_type_ind, 
               tbbdetc_dcat_code,
               SUBSTR(tbbdetc_desc,INSTR(tbbdetc_desc,' ')+1,( INSTR(tbbdetc_desc,'%')-INSTR(tbbdetc_desc,' ') )-1 ) iva
            ,(
            nvl((
                SELECT         
                             sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and (case when p_interna = 'Y' and tbbdetc_dcat_code not in ('TAX','TER','FNA') then 1
                        when p_interna = 'N' and tbbdetc_dcat_code not in ('TAX','FNA') then 1
                        else  0
                        end) = 1
                AND tbbdetc_type_ind='C'
                and tzrfact_sdoc_code  IN (SELECT GTVSDAX_CONCEPT   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_NC') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                --acastillo 2306 calcular solo por sri para corregir NT empresa
				--AND   tzrfact_pidm     =  p_pidm 
                AND   tzrfact_crednt_sricode =  p_tzrfact_crednt_sricode
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE),0)
                -
                nvl((SELECT         
                             sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and tbbdetc_dcat_code  in ('BEC','DES')
                AND tbbdetc_type_ind='P'
                and tzrfact_sdoc_code  IN (SELECT GTVSDAX_CONCEPT   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_NC') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                --acastillo 2306 calcular solo por sri para corregir NT empresa
				--AND   tzrfact_pidm     =  p_pidm 
                AND   tzrfact_crednt_sricode =  p_tzrfact_crednt_sricode
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE) ,0)
                ) valor
        FROM tbbdetc iva
        WHERE iva.tbbdetc_dcat_code='TAX'
        AND iva.tbbdetc_type_ind='C'
        AND iva.TBBDETC_DETAIL_CODE
        IN (
            SELECT TVRDCTX_TXPR_CODE
            FROM tvrdctx 
            WHERE tvrdctx_txpr_code IS NOT NULL
            ) ;


      CURSOR c_direccion (p_pidm number) IS
        SELECT spraddr_street_line1, spraddr_city
        FROM spraddr
        WHERE spraddr_pidm = p_pidm
        AND ROWNUM < 2;

      CURSOR c_email (p_pidm number, p_emal_code varchar2) IS
        SELECT goremal_email_address 
        FROM   goremal
        WHERE  goremal_pidm=p_pidm
        AND    goremal_emal_code = p_emal_code;


             CURSOR c_smtp
        IS
            SELECT gtvsdax_external_code, gtvsdax_desc, gtvsdax_comments
            FROM gtvsdax
            WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
            AND gtvsdax_internal_code = 'SMTP';

            cursor c_telefono (p_pidm number) is
            SELECT sprtele_phone_number             
            FROM   sprtele 
            WHERE  sprtele_pidm = p_pidm_sede;

cursor c_get_ivamayorcero is
                SELECT  
                'VALOR DEL ' ||      f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion,
                tzrfact.tzrfact_amnt_trans                
                FROM    tzrfact 
                WHERE   tzrfact.tzrfact_sdoc_code     IN (SELECT GTVSDAX_CONCEPT
                                                          FROM   gtvsdax 
                                                          WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                          AND gtvsdax_internal_code IN( 'COD_NC')
                                                          )
                AND     tzrfact.tzrfact_pidm          = p_pidm
                AND     tzrfact.tzrfact_crednt_sricode    =  p_tzrfact_crednt_sricode
                AND     tzrfact.tzrfact_det_code_doc  IN   (
                                                            SELECT iva.tvrdctx_txpr_code 
                                                            FROM tvrdctx iva
                                                            WHERE  iva.tvrdctx_txpr_code IS NOT NULL
                                                            )
                and rownum = 1
                ORDER BY tzrfact.tzrfact_det_code_doc;


    BEGIN

        OPEN c_get_data;
        FETCH c_get_data INTO v_periodo_prefactura,p_doc_number, v_fecha_emision, p_sede, p_campus_number, v_carreraestudiante, v_cajero, v_party_id,v_party_pidm,v_party_name, v_fecha_nota_credito, ncred_reason, v_tzrfact_sri_docnum;
        CLOSE c_get_data;

       open c_get_data_sede (p_campus_number) ;
       fetch c_get_data_sede into p_pidm_sede, v_resolucionimpuestos;
       close c_get_data_sede;

       OPEN  c_identificacion(p_pidm_sede);
        FETCH c_identificacion INTO v_tipo_iden_sede, v_iden_sede;
        CLOSE c_identificacion;

       v_rucsede := v_tipo_iden_sede||': '|| v_iden_sede;

        OPEN c_get_data_i ('PUCE_FACT', 'ID_PUCE', 'EXT');
        FETCH c_get_data_i INTO p_id_puce;
        CLOSE c_get_data_i;

       OPEN c_direccion(p_pidm_sede);
        FETCH c_direccion  INTO v_dir_sede, v_dir_city_sede ;
        CLOSE c_direccion;  

        v_direccionsede := 'Dirección: '||v_dir_sede||' '||v_dir_city_sede ;        

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_CODE', 'EXT');
        FETCH c_get_data_i INTO p_emal_code;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_INST', 'EXT');
        FETCH c_get_data_i INTO p_emal_code_sede;
        CLOSE c_get_data_i;

        OPEN   c_email (p_pidm_sede, p_emal_code_sede);
        FETCH  c_email INTO   v_emailsede;
        CLOSE  c_email;


        OPEN c_telefono(p_pidm_sede);
        FETCH c_telefono
        INTO v_telefono ;
        CLOSE c_telefono;  

         v_telefenosede := 'Teléfonos: '||v_telefono;


       IF v_party_pidm is null then
           v_pidm := p_pidm;
        ELSE
           v_pidm := v_party_pidm;
       END IF;

        OPEN c_nombre_completo (v_pidm );
        FETCH c_nombre_completo INTO p_nombre_estudiante;
        CLOSE c_nombre_completo;

        OPEN  c_identificacion(v_pidm);
        FETCH c_identificacion INTO v_tipo_iden, v_iden;
        CLOSE c_identificacion;

        OPEN c_direccion(v_pidm);
        FETCH c_direccion    INTO v_direccion, v_city;
        CLOSE c_direccion;  

        OPEN   c_email (v_pidm, p_emal_code);
        FETCH  c_email INTO   v_email;
        CLOSE  c_email;

        IF v_email is null then
            OPEN   c_email (v_pidm, p_emal_code_sede);
            FETCH  c_email INTO   v_email;
            CLOSE  c_email;
        END IF;



        plpdf.init (p_orientation   => plpdf_const.portrait,
                    p_unit          => plpdf_const.mm,
                    p_format        => 'letter');

        p_interna := 'Y';

FOR Lcntr IN 1..2 LOOP

        plpdf.newpage;

        plpdf.setprintfont (p_family => 'Arial',  p_size => 6);
        plpdf_cell.newline;

                    plpdf.printcell(p_w      => 200,
                    p_txt    => f_format_name (p_pidm_sede, 'L60'),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);



        plpdf.printcell( p_w      => 40,
                    p_txt    => v_rucsede,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);

        plpdf.printcell(p_w      => 80,
                        p_txt    => ' ' ,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 80,
                        p_txt    => 'Nro Nota Crédito. ' ||p_tzrfact_crednt_sricode,
                        p_border => '1',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_center,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => v_direccionsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);



        plpdf.printcell(p_w        => 200,
                        p_txt    => v_telefenosede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => 'Email: ' ||v_emailsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 200,
                        p_txt    =>tzkcone.f_get_dinamic_text(p_sede,'Encabezado factura', '1,2'),
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.setprintfont (p_family => 'Arial', p_size => 6);



        plpdf_cell.newline;

     plpdf.printcell(p_w     => 100,
                    p_txt    => 'Cliente: ' || p_nombre_estudiante,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => plpdf3.c_right,
                    p_fill   => FALSE);

        plpdf.printcell(p_w     => 100,
                    p_txt    => 'Ciudad: ' || v_city,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => plpdf3.c_right,
                    p_fill   => FALSE);

     plpdf.printcell(p_w     => 100,
                    p_txt    => 'Código: ' || gb_common.f_get_id(v_pidm),
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);


      plpdf.printcell(p_w   => 100,
                    p_txt   => 'Fecha Nota Crédito: ' ||
                                    NVL(TO_CHAR(v_fecha_nota_credito,'DD/MM/YYYY'), 
                                    TO_CHAR(SYSDATE,'DD/MM/YYYY')),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w     => 100,
                    p_txt    =>  'RUC/CI: '  ||v_iden,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);


      plpdf.printcell(p_w   => 100,
                    p_txt   => 'Tipo de documento: ' || 'Factura',
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w        => 100,
                    p_txt    => 'Dirección: ' || v_direccion,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);


    plpdf.printcell(p_w        => 100,
                    p_txt    => 'No Documento: ' || v_tzrfact_sri_docnum,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);

     plpdf.printcell(p_w        => 100,
                    p_txt    => ' ',
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);

    plpdf.printcell(p_w   => 100,
                    p_txt   => 'Fecha Factura: ' ||
                                    NVL(TO_CHAR(v_fecha_emision,'DD/MM/YYYY'), 
                                    TO_CHAR(SYSDATE,'DD/MM/YYYY')),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);



        plpdf.printcell(p_w        => 100,
                        p_txt    => 'Correo: ' ||v_email,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => 'L',
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 100,
                    p_txt    => 'Motivo Modificación: ' || ncred_reason,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


        plpdf_cell.printcell (p_width => 200,
                             p_text => '' 
                             );

        plpdf_cell.newline;
        plpdf_cell.init;

            v_total_venta_neta:=0;
            v_total_cargos := 0;
            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 8);


            plpdf.printcell (p_w        => 20,
                             p_txt      => v_tran_num,
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);

              plpdf.printcell   (p_w        => 80,
                                 p_txt      => v_describe_detalle,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_unitario,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_total,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'C',
                                 p_fill  =>FALSE
                                 );

        plpdf_cell.newline;
        plpdf.setprintfont (p_family   => 'Arial',p_size     => 6);


        FOR chrg IN c_cargos     LOOP
            plpdf.printcell (p_w        => 20,
                             p_txt      => nvl(chrg.tzrfact_stperdoc_qty,1),
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);


                plpdf.printcell (p_w        => 80,
                                 p_txt      =>chrg.descripcion,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);
                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (abs(chrg.tzrfact_amnt_trans), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (abs(chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1)), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

               v_total_cargos := v_total_cargos + abs(chrg.tzrfact_amnt_trans)*nvl(chrg.tzrfact_stperdoc_qty,1);

            END LOOP;

            plpdf_cell.newline;
            v_ini_x:=plpdf.getCurrentX();
            v_ini_Y:=plpdf.getCurrentY();

            plpdf.printcell     (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            v_ancho:=  plpdf.getCurrentX()-  v_ini_x;

            plpdf.printcell     (p_w        => 70,
                                 p_txt      => 'SUBTOTAL',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w     =>50,
                                 p_txt   =>TO_CHAR (abs(v_total_cargos), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


                open c_get_descuento1;
                fetch c_get_descuento1 into v_descuento;
                close c_get_descuento1;

                open c_get_descuento2;
                fetch c_get_descuento2 into v_descuento2;
                close c_get_descuento2;


             v_total_descuentos := NVL(v_descuento,0) + NVL(v_descuento2,0);

            v_total_descuentos := v_total_descuentos * -1;

                plpdf.printcell (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'DESCUENTO',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(abs(v_total_descuentos),0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


        v_total_sin_iva := NVL(v_total_cargos,0) - NVL(v_total_descuentos,0);

           plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'TOTAL SIN IVA',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(abs(v_total_sin_iva),0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );



           v_totaldetalleivas:=0;

            FOR fivas IN c_totalivas     LOOP

                plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => fivas.detalle,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (ABS(fivas.valor), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );
            v_totaldetalleivas:=NVL(v_totaldetalleivas,0)+NVL(fivas.valor,0) ;                                        

          END LOOP;


v_valorivaestudiante := 0;

open c_get_ivamayorcero;
fetch c_get_ivamayorcero into v_detalleivamayorcero  ,v_valorivaestudiante;
close c_get_ivamayorcero;


                plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => nvl(v_detalleivamayorcero,'VALOR DEL IVA 12%'),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(abs(v_valorivaestudiante),0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


           v_total:=NVL(v_valorivaestudiante,0)+v_totaldetalleivas;

           plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'TOTAL',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (abs(v_total), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


           plpdf.setprintfont (p_family => 'Arial',  p_size => 6);
        v_alto:=plpdf.getCurrentY()-v_ini_y;

       plpdf_cell.newline;

plpdf.Rect(
   p_x => v_ini_x,             
   p_y => v_ini_y,             
   p_w => v_ancho-5,       
   p_h => v_alto             
   );

     plpdf.setcurrentXY(v_ini_x+1,v_ini_y+2.5);
   plpdf.PrintMultiLineCell(p_txt=>'SON:'||tzkcone.numero_nota_letra(to_char(v_total,'999999999.99'))||'/100 *',
   p_w=>50,
   p_align=>'L',
   p_clipping=>false
   );

         plpdf_cell.newline;    

        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 6);

         plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;
         plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;plpdf_cell.newline;


          plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

              plpdf.printcell (p_w        => 25,
                                 p_txt      => 'Elaborado por:',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.newline,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 25,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell  (p_w        => 75,
                                   p_h        => .3,
                                   p_txt      => '-',
                                   p_border   => '1',
                                   p_ln       => plpdf_const.newline,
                                   p_align    => 'L',
                                   p_fill     => FALSE);

                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.printcell (p_w        => 25,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell  (p_w        => 75,
                                   p_h        => .3,
                                   p_txt      => '-',
                                   p_border   => '1',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'L',
                                   p_fill     => FALSE);

                  plpdf.printcell (p_w        => 25,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>75,
                                  p_h => .3,
                                  p_txt   =>'-',
                                  p_border =>'1',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>l_aligns_rigth,
                                  p_fill  =>FALSE
                                  );

                 plpdf.printcell  (p_w        => 75,
                                   p_h        => 6,
                                   p_txt      => 'Firma y Sello',
                                   p_border   => '0',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'C',
                                   p_fill     => FALSE);


                  plpdf.printcell (p_w        => 40,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>80,
                                  p_h => 6,
                                  p_txt   =>'Recibi Conforme',
                                  p_border =>'0',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>'C',
                                  p_fill  =>FALSE
                                  );

                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

                plpdf.printcell (p_w        => 0,            
                                 p_h =>     6,     
                                 p_txt      => tzkcone.f_get_dinamic_text(p_sede,'Pie de pagina factura', '1'), 
                                 p_border   => '0',                 
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',     
                                 p_fill     => FALSE 
                                );

                plpdf.printcell (p_w        => 0,            
                                 p_h =>     5,     
                                 p_txt      => tzkcone.f_get_dinamic_text(p_sede,'Pie de pagina factura', '2,3,4'),  
                                 p_border   => '0',                  
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',      
                                 p_fill     => FALSE 
                                );
        plpdf_cell.newline;
        plpdf_cell.newline;
        plpdf_cell.newline;
        plpdf_cell.newline;

p_interna := 'N';
END LOOP;

        plpdf.senddoc (p_blob => l_pdf);

        IF p_web IS NULL THEN
            HTP.flush;
            HTP.init;
            --
            OWA_UTIL.mime_header ('application/pdf', FALSE);
            HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_pdf));
            OWA_UTIL.http_header_close;
            WPG_DOCLOAD.download_file (l_pdf);
        END IF;
    END p_show_nota_credito;

function f_valid_pago_total (p_pidm 			tzrfact.tzrfact_pidm%type,		
							 p_receipt			tzrfact.tzrfact_receipt_num%type,
							 p_internal_receipt	tzrfact.tzrfact_internal_receipt_num%type
						) return varchar2 is

	v_total_pagos	number;
	v_total_cargos	number;
	v_total			number;
	v_pago_total varchar2(1);

	cursor c_cargos is
	select nvl(sum(tzrfact_amnt_trans),0) total_cargos --cargo cuota+interes x internal 
	from  tzrfact t
	where 
	   tzrfact_pidm     =  p_pidm 
	and tzrfact_internal_receipt_num = p_internal_receipt
	--and tzrfact_receipt_num = :p_receipt
	and   tzrfact_det_code_doc in  (
									select tbbdetc_detail_code
									from tbbdetc 
									where tbbdetc_dcat_code not in ('TAX')
									and tbbdetc_type_ind='C'
								   );

	cursor c_pagos is
	select nvl(sum(tzrfact_amnt_trans),0) total_pagos --pago cuota+interes por recibo
	from  tzrfact t
	where 
	   tzrfact_pidm     =  p_pidm 
	and tzrfact_internal_receipt_num = p_internal_receipt
	and tzrfact_receipt_num <= p_receipt
	and   tzrfact_det_code_doc in  (
									select tbbdetc_detail_code
									from tbbdetc 
									where tbbdetc_dcat_code not in ('TAX')
									and tbbdetc_type_ind='P'
								   );

		begin
        v_pago_total := null;
			open c_cargos;
			fetch c_cargos into v_total_cargos;
			close c_cargos;
			          dbms_output.put_line('v_total_cargos ' ||v_total_cargos);

			open c_pagos;
			fetch c_pagos into v_total_pagos;
			close c_pagos;
			          dbms_output.put_line('v_total_pagos ' ||v_total_pagos);

			v_total := v_total_cargos - v_total_pagos;
			          dbms_output.put_line('v_total ' ||v_total);

			if v_total = 0 then
				v_pago_total := 'Y';
				else
				v_pago_total := 'N';
			end if;
			          dbms_output.put_line('v_pago_total ' ||v_pago_total);
			return v_pago_total;

			exception when others then
				return 'N';			
		--end;
end;						

PROCEDURE p_show_comprobante (
                      p_pidm         IN NUMBER,
                      p_receipt   IN tzrfact.TZRFACT_RECEIPT_NUM%TYPE
                      )
      IS

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

        p_pidm_sede        spriden.spriden_pidm%TYPE;
        v_pidm number:=0;
       p_campus_number number (1);
       p_id_puce       spriden.spriden_id%TYPE;

        p_doc_number          NUMBER;
        l_pdf                 BLOB;
        p_nombre_estudiante   VARCHAR2 (1000);
        p_web                 VARCHAR2 (1000);  
        v_fecha_emision       DATE;
        v_email               goremal.goremal_email_address%TYPE; 
        v_total_venta_neta    NUMBER;
        v_ini_x number;
        v_ini_y number;  
        v_ancho number;
        v_alto number;
        v_2_ini_x number;
        v_2_ini_y number;  
        v_2_ancho number;
        v_2_alto number; 
        v_space number; 

CURSOR c_formapago
IS
SELECT 
       tzrfact_det_code_doc,f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion,
       sum(tzrfact_amnt_trans ) tzrfact_amnt_trans
FROM   tzrfact 
WHERE  tzrfact_sdoc_code    IN (SELECT gtvsdax_external_code
                                FROM   gtvsdax 
                                WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                AND gtvsdax_internal_code IN ('COD_CP') 
                                )
AND   tzrfact_pidm     =  p_pidm 
AND   tzrfact_receipt_num =  p_receipt
AND    tzrfact_det_code_doc IN (
                                SELECT tbbdetc_detail_code
                                FROM tbbdetc 
                                WHERE tbbdetc_type_ind='P'                                
                                AND tbbdetc_prebill_print_ind='N'
                               )
group by        TZRFACT_DET_CODE_DOC;


p_INTERNAL_RECEIPT_NUM TZRFACT.TZRFACT_INTERNAL_RECEIPT_NUM%type;
v_pago_total varchar2(1);
CURSOR c_get_data is
    SELECT   TZRFACT_TERM_CODE , tzrfact_doc_number,tzrfact_fact_date,  TZRFACT_CAMPUS, 
	(select STVCAMP_DICD_CODE from stvcamp where stvcamp_code = TZRFACT_CAMPUS) campus_number,--SUBSTR(tzrfact_sale_docnum,7,1) campus_number, 
					tzrfact_curr_program, tzrfact_user  
                  ,TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_SRI_DOCNUM, TZRFACT_INTERNAL_RECEIPT_NUM
    FROM tzrfact 
    WHERE tzrfact_sdoc_code          IN (SELECT gtvsdax_external_code
                FROM  gtvsdax 
                WHERE gtvsdax_internal_code IN ('COD_CP')  
                AND   gtvsdax_internal_code_group='PUCE_FACT')
    AND   tzrfact_pidm               =  p_pidm 
    AND   tzrfact_receipt_num     = p_receipt ;

 cursor c_get_data_sede (p_campus_number number) is 
SELECT gb_common.f_get_pidm ( gtvsdax_external_code) pidm_sede, gtvsdax_comments 
                FROM  gtvsdax 
                WHERE gtvsdax_internal_code ='ID_PUCE' 
                AND   gtvsdax_internal_code_group='PUCE_FACT'
                AND   gtvsdax_translation_code= p_campus_number;

CURSOR c_nombre_completo (p_pidm number)
IS
    SELECT    REPLACE (spriden_last_name, '/', ' ')
    || ' '|| spriden_first_name|| ' '|| spriden_mi complete_name
    FROM spriden
    WHERE spriden_change_ind IS NULL 
    AND spriden_pidm = p_pidm;


CURSOR c_identificacion (p_pidm number)
IS
    SELECT (
    SELECT stvlgcy_desc
    FROM stvlgcy
    WHERE stvlgcy_code = spbpers_lgcy_code
    ) tipo_identificacion, spbpers_ssn  identificacion
    FROM spbpers
    WHERE spbpers_pidm = p_pidm
    AND ROWNUM=1;

v_tipo_iden           stvlgcy.stvlgcy_desc%TYPE;
v_iden                spbpers.spbpers_ssn%TYPE;
v_id_estudiante       varchar2(20);
v_direccion           spraddr.spraddr_street_line1%TYPE;



CURSOR c_cargoscompro (p_INTERNAL_RECEIPT varchar2)
IS 
/*SELECT  tzrfact_stperdoc_qty ,
          tzrfact_det_code_doc,
		  --f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion,
		  f_get_ar_desc ('TBBDETC', ( select TBRACCD_DETAIL_CODE
						from tbrappl appl, tbraccd accd
						where tbrappl_pidm =tzrfact_pidm
						and tbrappl_pidm = tbraccd_pidm
						and TBRAPPL_PAY_TRAN_NUMBER = TZRFACT_TRAN_NUM
						and TBRACCD_TRAN_NUMBER = TBRAPPL_CHG_TRAN_NUMBER), 60) descripcion,
          tzrfact_amnt_trans 
FROM  tzrfact 
WHERE 
   tzrfact_pidm     =  p_pidm 
and TZRFACT_INTERNAL_RECEIPT_NUM = p_INTERNAL_RECEIPT
--
AND TZRFACT_RECEIPT_NUM = p_receipt
AND   tzrfact_det_code_doc IN  (
                                SELECT tbbdetc_detail_code
                                FROM tbbdetc 
                                WHERE tbbdetc_dcat_code not in ('TAX')
                                --AND tbbdetc_type_ind='C'
								AND tbbdetc_type_ind='P'
                               )
ORDER BY tzrfact_tran_num;*/
select tzrfact_stperdoc_qty,
tzrfact_det_code_doc,
f_get_ar_desc ('TBBDETC', (select TBRACCD_DETAIL_CODE from tbraccd where tbraccd_pidm=tbrappl_pidm and tbraccd_tran_number = TBRAPPL_CHG_TRAN_NUMBER), 60) descripcion,
TBRAPPL_AMOUNT tzrfact_amnt_trans
--select *
FROM  tzrfact t, tbrappl l
WHERE 
   tzrfact_pidm     =  p_pidm 
AND tzrfact_pidm     = TBRAPPL_PIDM   
and TZRFACT_TRAN_NUM = TBRAPPL_PAY_TRAN_NUMBER   
--and TZRFACT_INTERNAL_RECEIPT_NUM = p_INTERNAL_RECEIPT
and nvl2(p_INTERNAL_RECEIPT,TZRFACT_INTERNAL_RECEIPT_NUM,0) = nvl2(p_INTERNAL_RECEIPT,p_INTERNAL_RECEIPT,0)
AND TZRFACT_RECEIPT_NUM = p_receipt
AND TBRAPPL_REAPPL_IND is null
AND   tzrfact_det_code_doc IN  (
                                SELECT tbbdetc_detail_code
                                FROM tbbdetc 
                                WHERE tbbdetc_dcat_code not in ('TAX')
                                AND tbbdetc_type_ind='P'
                               )   
ORDER BY tzrfact_tran_num;

CURSOR c_cargoscompro_total (p_INTERNAL_RECEIPT varchar2)
IS 
/*
select  
tzrfact_stperdoc_qty,
tzrfact_det_code_doc,
f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion,
SUM(tzrfact_amnt_trans) tzrfact_amnt_trans
FROM  tzrfact t
WHERE 
   tzrfact_pidm     =  p_pidm 
and TZRFACT_INTERNAL_RECEIPT_NUM = p_INTERNAL_RECEIPT
--AND TZRFACT_RECEIPT_NUM = p_receipt
AND   tzrfact_det_code_doc IN  (
                                SELECT tbbdetc_detail_code
                                FROM tbbdetc 
                                WHERE tbbdetc_dcat_code not in ('TAX')
                                AND tbbdetc_type_ind='C'
                               ) 
group by tzrfact_stperdoc_qty,
tzrfact_det_code_doc,
f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60);
--ORDER BY tzrfact_tran_num;*/

select tzrfact_stperdoc_qty,
TBRACCD_DETAIL_CODE tzrfact_det_code_doc,
--f_get_ar_desc ('TBBDETC', (select TBRACCD_DETAIL_CODE from tbraccd where tbraccd_pidm=tbrappl_pidm and tbraccd_tran_number = TBRAPPL_CHG_TRAN_NUMBER), 60) descripcion,
f_get_ar_desc ('TBBDETC', TBRACCD_DETAIL_CODE, 60) descripcion,
sum(TBRAPPL_AMOUNT) tzrfact_amnt_trans
--select *
FROM  tzrfact t, tbrappl l, tbraccd d
WHERE tbraccd_pidm=tbrappl_pidm
AND tbraccd_tran_number = TBRAPPL_CHG_TRAN_NUMBER
AND tzrfact_pidm     =  p_pidm 
AND tzrfact_pidm     = TBRAPPL_PIDM   
and TZRFACT_TRAN_NUM = TBRAPPL_PAY_TRAN_NUMBER   
--and TZRFACT_INTERNAL_RECEIPT_NUM =p_INTERNAL_RECEIPT
and nvl2(p_INTERNAL_RECEIPT,TZRFACT_INTERNAL_RECEIPT_NUM,0) = nvl2(p_INTERNAL_RECEIPT,p_INTERNAL_RECEIPT,0)
AND TZRFACT_RECEIPT_NUM = p_receipt
AND TBRAPPL_REAPPL_IND is null
AND   tzrfact_det_code_doc IN  (
                                SELECT tbbdetc_detail_code
                                FROM tbbdetc 
                                WHERE tbbdetc_dcat_code not in ('TAX')
                                AND tbbdetc_type_ind='P'
                               )   
group by tzrfact_stperdoc_qty,
TBRACCD_DETAIL_CODE,
f_get_ar_desc ('TBBDETC', TBRACCD_DETAIL_CODE, 60);


cursor c_get_descuento1 is
                        SELECT  SUM(tzrfact_amnt_trans)                        
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_CP')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_receipt_num =  p_receipt
                        AND   tzrfact_det_code_doc  IN  (
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code LIKE '1%'
                                                        );

cursor c_get_descuento2 is
                        SELECT  SUM(tzrfact_amnt_trans)
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_CP')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_receipt_num =  p_receipt
                        AND   tzrfact_det_code_doc  IN  ((
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code NOT LIKE '1%'
                                                        )
                                                        UNION
                                                        (
                                                         select TBBDETC_DETAIL_CODE from TBBDETC 
                                                         WHERE TBBDETC_DCAT_CODE IN ('BEC','DES')
                                                         AND    tbbdetc_type_ind = 'P'
                                                         AND TBBDETC_DETAIL_CODE NOT IN (
                                                         SELECT kvrfbse_dflt_detail_code 
                                                         FROM   kvrfbse 
                                                         WHERE kvrfbse_fndc_code  LIKE '1%')
                                                        )
                                                        );



CURSOR c_totalivas (p_INTERNAL_RECEIPT varchar2) is
SELECT tbbdetc_detail_code, 
               'TOTAL GRAVADO CON ' ||tbbdetc_desc detalle, 
               tbbdetc_type_ind, 
               tbbdetc_dcat_code,
               SUBSTR(tbbdetc_desc,INSTR(tbbdetc_desc,' ')+1,( INSTR(tbbdetc_desc,'%')-INSTR(tbbdetc_desc,' ') )-1 ) iva
            ,(
            nvl((
                SELECT         
                             sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and tbbdetc_dcat_code not in ('TAX')
                AND tbbdetc_type_ind='C'
                --and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_CP') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                AND   tzrfact_pidm     =  p_pidm 
                --AND   tzrfact_receipt_num =  p_receipt
                and TZRFACT_INTERNAL_RECEIPT_NUM = p_INTERNAL_RECEIPT
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE),0)
                -
                nvl((SELECT         
                             sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and tbbdetc_dcat_code  in ('BEC','DES')
                AND tbbdetc_type_ind='P'
                and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_CP') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                AND   tzrfact_pidm     =  p_pidm 
                AND   tzrfact_receipt_num =  p_receipt
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE) ,0)
                ) valor
        FROM tbbdetc iva
        WHERE iva.tbbdetc_dcat_code='TAX'
        AND iva.tbbdetc_type_ind='C'
        AND iva.TBBDETC_DETAIL_CODE
        IN (
            SELECT TVRDCTX_TXPR_CODE
            FROM tvrdctx 
            WHERE tvrdctx_txpr_code IS NOT NULL
            ) ;



        v_cod_obs             VARCHAR2 (15);
        v_sum_teoria    number:=0; 
         v_sum_practica number:=0;

        ----
        l_num_mask            VARCHAR2 (20) := 'L999G999G999D00';
        v_total_cargos        NUMBER;
        v_enca_ara            VARCHAR2 (1) := 'N';
        v_enca_mat            VARCHAR2 (1) := 'N';
        v_enca_ter            VARCHAR2 (1) := 'N';
        v_enca_otr            VARCHAR2 (1) := 'N';
        v_encabezado          TTVPAYT.TTVPAYT_DESC%TYPE := 'X';
        v_grupo               TTVPAYT.TTVPAYT_DESC%TYPE;
        v_ciudad_cliente      spraddr.spraddr_city%TYPE;
        v_mensajeescrito     VARCHAR2(400);
        v_espacio_ultimo number;
        v_linea1         VARCHAR2(400);
        v_linea2         VARCHAR2(400);


      CURSOR c_direccion (p_pidm number) IS
        SELECT spraddr_street_line1, spraddr_city
        FROM spraddr
        WHERE spraddr_pidm = p_pidm
        AND ROWNUM < 2;

      CURSOR c_email (p_pidm number, p_emal_code varchar2) IS
        SELECT goremal_email_address 
        FROM   goremal
        WHERE  goremal_pidm=p_pidm
        AND    goremal_emal_code = p_emal_code;

            cursor c_telefono (p_pidm number) is
            SELECT sprtele_phone_number             
            FROM   sprtele 
            WHERE  sprtele_pidm = p_pidm_sede;


    p_oracle_wallet_path  gtvsdax.gtvsdax_comments%type;
    p_oracle_wallet_pass  gtvsdax.gtvsdax_external_code%type;


        p_emal_code varchar2(20);
p_emal_code_sede varchar2(20);
         p_sede          sovlcur.sovlcur_camp_code%TYPE;

    p_levl          sovlcur.sovlcur_levl_code%TYPE;
    p_program       sovlcur.sovlcur_program%TYPE;

        v_due_date            DATE;

        l_widths              plpdf_type.t_row_widths;      
        l_aligns              plpdf_type.t_row_aligns;      
        l_datas               plpdf_type.t_row_datas;       
        l_borders             plpdf_type.t_row_borders;  
        l_styles              plpdf_type.t_row_styles;      
        l_maxlines            plpdf_type.t_row_maxlines; 

        l_border_custom       VARCHAR2 (2) := '';
        l_aligns_center       VARCHAR2 (2) := 'C';
        l_aligns_left         VARCHAR2 (2) := 'L';
        l_aligns_rigth        VARCHAR2 (2) := 'R';
        l_font_arial          NUMBER := 10;
        l_cell_arial          NUMBER := l_font_arial - 4;
        l_font_courier        NUMBER := 8;
        l_cell_courier        NUMBER := l_font_courier - 3.5;
        l_font_times          NUMBER := 14;
        l_cell_times          NUMBER := l_font_times - 8;
        l_widths_infotab      plpdf_type.t_row_widths;      
        l_widths_totaltab     plpdf_type.t_row_widths;     
        l_logo_posy           NUMBER;
        v_fill_spaces_20      VARCHAR2 (35) := '                    ';
        v_fill_spaces_30      VARCHAR2 (35) := '                              ';
        v_fill_spaces_45      VARCHAR2 (48) := '                                             ';
        v_fill_encabezado     VARCHAR2 (78) :='                DETALLE              VALOR UNITARIO          VALOR TOTAL';
        v_amt                 VARCHAR2 (200);
        v_tot_gpo             NUMBER := 0;
        p_gpo                 NUMBER := 0;
        p_gpo_printed         VARCHAR2 (1) := 'N';
        v_periodo_prefactura  VARCHAR2 (6);
        v_tran_num            VARCHAR2 (20):='CANT';
        v_describe_detalle    VARCHAR2 (20):='DETALLE';
        v_valor_unitario      VARCHAR2 (20):='VALOR UNITARIO';
        v_valor_total         VARCHAR2 (20):='VALOR TOTAL';
        v_total_descuentos    NUMBER := 0;  
        p_cnt_asign           NUMBER := 0;
        v_total_pagos         NUMBER;
        v_total_cargosiva     NUMBER := 0;
        v_descuento           NUMBER := 0; 
        v_descuento2          NUMBER := 0;  
        v_valorivamayorcero   NUMBER := 0;
        v_codigoivamayorcero  VARCHAR2(20);  
        v_detalleivamayorcero VARCHAR2(40);
        v_valorivaestudiante  tzrfact.tzrfact_amnt_trans%TYPE;
        v_total               NUMBER := 0;  
        v_total_factura         NUMBER := 0;    
        v_spriden_idsede        spriden.spriden_id%TYPE;
        v_resolucionimpuestos   VARCHAR2 (300);
        v_rucsede               VARCHAR2 (300);
        v_direccionsede         VARCHAR2 (200);
        v_telefenosede          VARCHAR2 (200);
        v_emailsede             VARCHAR2 (200);
        v_cajero                tzrfact.tzrfact_user%TYPE;
        v_tzrfact_sri_docnum    tzrfact.tzrfact_sri_docnum%TYPE;
        ncred_reason  varchar2(4000);
        v_total_sin_iva         NUMBER := 0;     
        v_totaldetalleivas      NUMBER := 0;
        v_result                CLOB;


cursor c_get_ivamayorcero is
                SELECT  
                'VALOR DEL ' ||      f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion,
                tzrfact.tzrfact_amnt_trans                
                FROM    tzrfact 
                WHERE   tzrfact.tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                          FROM   gtvsdax 
                                                          WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                          AND gtvsdax_internal_code IN( 'COD_CP')
                                                          )
                AND     tzrfact.tzrfact_pidm          = p_pidm
                AND   tzrfact_receipt_num =  p_receipt
                AND     tzrfact.tzrfact_det_code_doc  IN   (
                                                            SELECT iva.tvrdctx_txpr_code 
                                                            FROM tvrdctx iva
                                                            WHERE  iva.tvrdctx_txpr_code IS NOT NULL
                                                            )
                AND tzrfact.tzrfact_amnt_trans>0                
                and rownum = 1
                ORDER BY tzrfact.tzrfact_det_code_doc;


v_carreraestudiante     tzrfact.tzrfact_curr_program%TYPE;
v_tipo_iden_sede           stvlgcy.stvlgcy_desc%TYPE;
v_iden_sede                spbpers.spbpers_ssn%TYPE;
v_party_id  TZRFACT.TZRFACT_TRDPARTY_ID%type;
       v_party_pidm TZRFACT.TZRFACT_TRDPARTY_PIDM%type;
       v_party_name TZRFACT.TZRFACT_TRDPARTY_NAME%type;

       v_dir_sede               spraddr.spraddr_street_line1%TYPE;
v_dir_city_sede      varchar2(50);
v_city varchar2(50);
v_telefono sprtele.sprtele_phone_number%type;

    BEGIN

       OPEN c_get_data;
        FETCH c_get_data INTO v_periodo_prefactura,p_doc_number, v_fecha_emision, p_sede, p_campus_number, v_carreraestudiante, v_cajero, v_party_id,v_party_pidm,v_party_name, v_tzrfact_sri_docnum, p_INTERNAL_RECEIPT_NUM;
        CLOSE c_get_data;

       open c_get_data_sede (p_campus_number) ;
       fetch c_get_data_sede into p_pidm_sede, v_resolucionimpuestos;
       close c_get_data_sede;

       OPEN  c_identificacion(p_pidm_sede);
        FETCH c_identificacion INTO v_tipo_iden_sede, v_iden_sede;
        CLOSE c_identificacion;

       v_rucsede := v_tipo_iden_sede||': '|| v_iden_sede;

        OPEN c_get_data_i ('PUCE_FACT', 'ID_PUCE', 'EXT');
        FETCH c_get_data_i INTO p_id_puce;
        CLOSE c_get_data_i;

       OPEN c_direccion(p_pidm_sede);
        FETCH c_direccion  INTO v_dir_sede, v_dir_city_sede ;
        CLOSE c_direccion;  

        v_direccionsede := 'Dirección: '||v_dir_sede||' '||v_dir_city_sede ;        

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_CODE', 'EXT');
        FETCH c_get_data_i INTO p_emal_code;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_INST', 'EXT');
        FETCH c_get_data_i INTO p_emal_code_sede;
        CLOSE c_get_data_i;

        OPEN   c_email (p_pidm_sede, p_emal_code_sede);
        FETCH  c_email INTO   v_emailsede;
        CLOSE  c_email;


        OPEN c_telefono(p_pidm_sede);
        FETCH c_telefono
        INTO v_telefono ;
        CLOSE c_telefono;  

         v_telefenosede := 'Teléfonos: '||v_telefono;


       IF v_party_pidm is null then
           v_pidm := p_pidm;
        ELSE
           v_pidm := v_party_pidm;
       END IF;

        OPEN c_nombre_completo (v_pidm );
        FETCH c_nombre_completo INTO p_nombre_estudiante;
        CLOSE c_nombre_completo;

        OPEN  c_identificacion(v_pidm);
        FETCH c_identificacion INTO v_tipo_iden, v_iden;
        CLOSE c_identificacion;

        OPEN c_direccion(v_pidm);
        FETCH c_direccion    INTO v_direccion, v_city;
        CLOSE c_direccion;  

        OPEN   c_email (v_pidm, p_emal_code);
        FETCH  c_email INTO   v_email;
        CLOSE  c_email;

        IF v_email is null then
            OPEN   c_email (v_pidm, p_emal_code_sede);
            FETCH  c_email INTO   v_email;
            CLOSE  c_email;
        END IF;
---------------------------------------------------------------


        plpdf.init (p_orientation   => plpdf_const.portrait,
                    p_unit          => plpdf_const.mm,
                    p_format        => 'letter');


        plpdf.newpage;


        plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

        plpdf_cell.newline;


        plpdf.printcell(p_w      => 200,
                    p_txt    => f_format_name (p_pidm_sede, 'L60'),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);


        plpdf.printcell( p_w      => 40,
                    p_txt    => v_rucsede,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);

        plpdf.printcell(p_w      => 60,
                        p_txt    => ' ' ,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 100,
                        p_txt    => 'Nro Comprobante de cobro. ' ||p_receipt,
                        p_border => '1',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_center,
                        p_fill   => FALSE);


              plpdf.printcell(p_w        => 200,
                        p_txt    => v_direccionsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);



           plpdf.printcell(p_w        => 200,
                        p_txt    => v_telefenosede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);



        plpdf.printcell(p_w        => 200,
                        p_txt    => 'Email: ' ||v_emailsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);



        plpdf.printcell(p_w        => 200,
                         p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);



        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.setprintfont (p_family => 'Arial', p_size => 6);


        plpdf_cell.newline;

     plpdf.printcell(p_w     => 100,
                    p_txt    => 'Cliente: ' || p_nombre_estudiante,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => plpdf3.c_right,
                    p_fill   => FALSE);

     plpdf.printcell(p_w     => 100,
                    p_txt    => '',
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => plpdf3.c_right,
                    p_fill   => FALSE);


     plpdf.printcell(p_w     => 100,
                    p_txt    => 'Código: ' || gb_common.f_get_id(v_pidm),
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);


      plpdf.printcell(p_w   => 100,
                    p_txt   => 'Fecha: ' ||
                                    NVL(TO_CHAR(v_fecha_emision,'DD/MM/YYYY'), 
                                    ''),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w     => 100,
                    p_txt    =>  'RUC/CI: '  ||v_iden,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);



      plpdf.printcell(p_w   => 100,
                    p_txt   => '',
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w        => 100,
                    p_txt    => 'Dirección: ' || v_direccion,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);



     plpdf.printcell(p_w        => 100,
                    p_txt    => 'Factura Asociada:'||v_tzrfact_sri_docnum,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);



                plpdf.printcell(p_w        => 100,
                        p_txt    => 'Correo: ' ||v_email,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => 'L',
                        p_fill   => FALSE);



     plpdf.printcell(p_w        => 100,
                    p_txt    => 'Cajero: ' ||v_cajero,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);



        plpdf_cell.printcell (p_width => 200,
                             p_text => '' 
                             );

        plpdf_cell.newline;
        plpdf_cell.init;

            v_total_venta_neta:=0;
            v_total_cargos := 0;
            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 8);


            plpdf.printcell (p_w        => 20,
                             p_txt      => v_tran_num,
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);

              plpdf.printcell   (p_w        => 80,
                                 p_txt      => v_describe_detalle,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_unitario,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_total,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'C',
                                 p_fill  =>FALSE
                                 );


        plpdf_cell.newline;

        plpdf.setprintfont (p_family   => 'Arial',p_size     => 6);

		dbms_output.put_line('f_valid_pago_total ' ||f_valid_pago_total (p_pidm,p_receipt,p_INTERNAL_RECEIPT_NUM));
		v_pago_total := f_valid_pago_total (p_pidm,p_receipt,p_INTERNAL_RECEIPT_NUM);

		if v_pago_total = 'N' then --IMPRIME COMPROBANTE PARCIAL
			FOR chrg IN c_cargoscompro (p_INTERNAL_RECEIPT_NUM)      LOOP
				plpdf.printcell (p_w        => 20,
                             p_txt      => nvl(chrg.tzrfact_stperdoc_qty,1) ,
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);

                plpdf.printcell (p_w        => 80,
                                 p_txt      => chrg.descripcion,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);
                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

               v_total_cargos := v_total_cargos + chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1);

            END LOOP;
		else
			FOR chrg IN c_cargoscompro_total (p_INTERNAL_RECEIPT_NUM)      LOOP
				plpdf.printcell (p_w        => 20,
                             p_txt      => nvl(chrg.tzrfact_stperdoc_qty,1) ,
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);

                plpdf.printcell (p_w        => 80,
                                 p_txt      => chrg.descripcion,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);
                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

               v_total_cargos := v_total_cargos + chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1);

            END LOOP;
		end if;
            plpdf_cell.newline;
            v_ini_x:=plpdf.getCurrentX();
            v_ini_Y:=plpdf.getCurrentY();
               plpdf.setprintfont (p_family => 'Arial', p_size => 6);
            plpdf.printcell     (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);
      v_ancho:=  plpdf.getCurrentX()-  v_ini_x;       


            plpdf.printcell     (p_w        => 70,
                                 p_txt      => 'SUBTOTAL',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);



             v_2_ini_x:=plpdf.getCurrentX();       	 
            v_2_ini_y:=plpdf.getCurrentY();

            v_space:=50;
            plpdf.printcell     (p_w     =>v_space,
                                 p_txt   =>TO_CHAR (v_total_cargos, l_num_mask),
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

             v_2_ancho:=  v_space;


                v_descuento := 0;  

                 open c_get_descuento1;
                fetch c_get_descuento1 into v_descuento;
                close c_get_descuento1;

                plpdf.printcell (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);


                plpdf.printcell (p_w     =>50,
                                 p_txt   =>'',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


                        v_total_sin_iva := NVL(v_total_cargos,0) - NVL(v_descuento,0);

        plpdf_cell.newline;
                         plpdf_cell.newline;
                        plpdf.printcell (p_w        => 80,
                                         p_txt      => 'Forma de Pago:',
                                         p_border   => '0',
                                         p_ln       => plpdf_const.beside,
                                         p_align    => 'L',
                                         p_fill     => FALSE);

                        plpdf.printcell (p_w        => 70,
                                         p_txt      => '',
                                         p_border   => '0',
                                         p_ln       => plpdf_const.beside,
                                         p_align    => 'L',
                                         p_fill     => FALSE);


                        plpdf.printcell (p_w     =>50,
                                         p_txt   =>'',
                                         p_border =>'0',
                                         p_ln    =>plpdf_const.newline,
                                         p_align =>'L',
                                         p_fill  =>FALSE
                                         );

                 plpdf_cell.newline;

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

         v_totaldetalleivas:=0;
            FOR fivas IN c_totalivas (p_INTERNAL_RECEIPT_NUM)    LOOP

                plpdf.printcell  (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>'',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

          v_totaldetalleivas:=NVL(v_totaldetalleivas,0)+NVL(fivas.valor,0) ;                      
          END LOOP;


        open c_get_ivamayorcero;
        fetch c_get_ivamayorcero into v_detalleivamayorcero  ,v_valorivaestudiante;
        close c_get_ivamayorcero;



          BEGIN
          v_total_pagos:=0;
         FOR fpago IN c_formapago     LOOP
              v_total_pagos := v_total_pagos + NVL(fpago.tzrfact_amnt_trans,0);

             plpdf.printcell  (p_w        => 30,
                                 p_txt      =>nvl(fpago.descripcion,''),
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);
              plpdf.printcell (p_w     =>40,
                                 p_txt   =>TO_CHAR (NVL(fpago.tzrfact_amnt_trans,0), l_num_mask),
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );                     
                plpdf_cell.newline;                      
       END LOOP;  
            END;		


                plpdf.printcell (p_w        => 70,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>'',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

           plpdf_cell.newline;
            plpdf.printcell  (p_w        => 80,
                                 p_txt      => '                                        '||v_total_pagos,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);


           plpdf_cell.newline;
            plpdf.printcell  (p_w        => 80,
                                 p_txt      => '                                     -------------',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);


           plpdf_cell.newline;
            plpdf.printcell  (p_w        => 80,
                                 p_txt      => '                                        '||v_total_pagos,
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);


           plpdf_cell.newline;


           v_total:=NVL(v_total_cargos,0); --+NVL(v_valorivaestudiante,0)+NVL(v_totaldetalleivas,0);

               plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'TOTAL',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (v_total, l_num_mask),
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

               plpdf.setprintfont (p_family => 'Arial',  p_size => 6);
               v_alto:=plpdf.getCurrentY()-v_ini_y;
               v_2_alto:=plpdf.getCurrentY()-v_2_ini_y;

       plpdf_cell.newline;

  plpdf.strokingcolor(0,0,0);

  plpdf.Rect(
   p_x => v_ini_x,             
   p_y => v_ini_y,             
   p_w => v_ancho-5,       
   p_h => v_alto             
   );
  plpdf.Rect(
   p_x => v_2_ini_x,             
   p_y => v_2_ini_y,             
   p_w => v_2_ancho,          
   p_h => v_2_alto             
   );

     plpdf.setcurrentXY(v_ini_x+1,v_ini_y+2.5);
   --plpdf.PrintMultiLineCell(p_txt=>'SON:'||tzkcone.numero_nota_letra(ABS(v_total))||'/100 *',
   plpdf.PrintMultiLineCell(p_txt=>'SON:'||tzkcone.numero_nota_letra(to_char(v_total,'999999999.99'))||'/100 *',
   p_w=>50,
   p_align=>'L',
   p_clipping=>false
   );

                plpdf_cell.newline;
            plpdf_cell.newline;
        plpdf_cell.init;
        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 6);


                plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;							

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

              plpdf.printcell (p_w        => 25,
                                 p_txt      => 'Elaborado por:',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.newline,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 25,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell  (p_w        => 75,
                                   p_h        => .3,
                                   p_txt      => '-',
                                   p_border   => '1',
                                   p_ln       => plpdf_const.newline,
                                   p_align    => 'L',
                                   p_fill     => FALSE);

                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.printcell (p_w        => 25,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell  (p_w        => 75,
                                   p_h        => .3,
                                   p_txt      => '-',
                                   p_border   => '1',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'L',
                                   p_fill     => FALSE);

                  plpdf.printcell (p_w        => 25,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>75,
                                  p_h => .3,
                                  p_txt   =>'-',
                                  p_border =>'1',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>l_aligns_rigth,
                                  p_fill  =>FALSE
                                  );

                 plpdf.printcell  (p_w        => 75,
                                   p_h        => 6,
                                   p_txt      => 'Firma y Sello',
                                   p_border   => '0',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'C',
                                   p_fill     => FALSE);

                  plpdf.printcell (p_w        => 40,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>80,
                                  p_h => 6,
                                  p_txt   =>'Recibi Conforme',
                                  p_border =>'0',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>'C',
                                  p_fill  =>FALSE
                                  );

                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);



                plpdf.printcell (p_w        => 0,             
                                 p_h =>     6,     
                                 p_txt      => '',
                                 p_border   => '0',  
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',     
                                 p_fill     => FALSE 
                                );

                plpdf.printcell (p_w        => 0,          
                                 p_h =>     5,     
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',     
                                 p_fill     => FALSE 
                                );
               plpdf_cell.newline;



        plpdf_cell.newline;
        plpdf_cell.newline;
        plpdf_cell.newline;

        plpdf.senddoc (p_blob => l_pdf);


        IF p_web IS NULL THEN
            HTP.flush;
            HTP.init;
            --
            OWA_UTIL.mime_header ('application/pdf', FALSE);
            HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_pdf));
            OWA_UTIL.http_header_close;
            WPG_DOCLOAD.download_file (l_pdf);
        END IF;


    END p_show_comprobante;


procedure p_upd_cancel_ind (p_pidm number, p_doc_number varchar2, p_type varchar2, p_result out varchar2) 
is
begin

IF p_type = 'PREF' then
  begin
     update tzrfact set tzrfact_pref_cancel_ind = 'Y' where TZRFACT_PIDM = p_pidm and TZRFACT_DOC_NUMBER = p_doc_number;
     p_result :=  'OK';
   exception when no_data_found then p_result := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
                when others then p_result :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
  end;
ELSIF p_type = 'FACT' then
begin    
     update tzrfact set tzrfact_fact_cancel_ind = 'Y' where TZRFACT_PIDM =  p_pidm and TZRFACT_SRI_DOCNUM = p_doc_number;
     p_result :=  'OK';
   exception when no_data_found then p_result := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
                when others then p_result :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
  end;
ELSIF p_type = 'COMP' then
begin
     update tzrfact set tzrfact_comp_cancel_ind = 'Y' where TZRFACT_PIDM = p_pidm  and TZRFACT_RECEIPT_NUM = p_doc_number;
     p_result :=  'OK';
   exception when no_data_found then p_result := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
                when others then p_result :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
  end;
ELSIF p_type = 'NC' then
begin
     update tzrfact set tzrfact_nc_cancel_ind = 'Y' where TZRFACT_PIDM = p_pidm and TZRFACT_CREDNT_SRICODE = p_doc_number;
     p_result :=  'OK';
   exception when no_data_found then p_result := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
                when others then p_result :=  SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500) ;
  end;
ELSE p_result :=  'Invalid Type';

END IF;
commit;

end p_upd_cancel_ind;


procedure p_gen_factura_cero (p_pidm  IN NUMBER, p_doc_num  IN VARCHAR2,  p_user in varchar2, p_return out varchar2)
is
cursor c_has_sri  is 
select TZRFACT_SRI_DOCNUM from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_DOC_NUMBER = p_doc_num
and TZRFACT_SRI_DOCNUM is not null;

v_has_sri  TZRFACT.TZRFACT_SRI_DOCNUM%type;
v_sdoc_code varchar2(10);

cursor c_get_sdoc_code (p_code varchar2) is
        select  GTVSDAX_EXTERNAL_CODE 
        from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = p_code;

cursor c_get_pto_emision  IS
   select TVRSDSQ_CAMP_CODE, TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2 
   from TVRSDSQ where TVRSDSQ_SDOC_CODE = v_sdoc_code
   and TVRSDSQ_FBPR_CODE in (select GORFBPR_FBPR_CODE from GENERAL.GORFBPR where GORFBPR_FGAC_USER_ID = p_user);

p_resultpay   varchar2(100);
p_errorpay    varchar2(1000);
p_error_msg_pay varchar2(1000);
p_program varchar2(12):= '';
p_campus varchar2(12);
p_term varchar2(8);

cursor c_get_data is
select TZRFACT_CURR_PROGRAM, TZRFACT_TERM_CODE, 
decode (TZRFACT_CAMPUS, null,  
        (select STVCAMP_CODE from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum = 1) ,TZRFACT_CAMPUS) campus
from tzrfact where tzrfact_pidm =  p_pidm and tzrfact_doc_number = p_doc_num;

   v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
   v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
   v_error  varchar2(1000);
   v_district  VARCHAR2(3);

   p_folio_factura varchar2(20);
   v_prefix_1 TVRSDSQ.TVRSDSQ_PREFIX_1%type;
   v_prefix_2 TVRSDSQ.TVRSDSQ_PREFIX_1%type;
   v_err_update  varchar2(1000);
   v_pto_emision varchar2(9);
   v_sri varchar2(20):='';
   v_return_error varchar2(1000);
   p_pay_detail_code varchar2(4);

   ln_recepit_number            tbraccd.tbraccd_receipt_number%TYPE;
   ln_tbraccd_tran_number_out   NUMBER;
   lv_tbraccd_response_out      VARCHAR2 (300);

   v_user_create      VARCHAR2 (30) := NULL;
   v_pref_code  VARCHAR2 (30) := NULL;

cursor c_terceros is
select TZRFACR_PIDM, TZRFACR_ID, TZRFACR_TRDPARTY_NAME
from tzrfacr
where TZRFACR_PIDM = p_pidm
     and TZRFACR_TERM_CODE = p_term
     and TZRFACR_DOC_NUMBER = p_doc_num
     and TZRFACR_FACT_ALL = 'Y'
group by TZRFACR_PIDM, TZRFACR_ID, TZRFACR_TRDPARTY_NAME;

v_TRDPARTY_ID       varchar2(10);
v_TRDPARTY_PIDM number;
v_TRDPARTY_NAME varchar2(120);

begin


    OPEN c_has_sri;
    FETCH c_has_sri into v_has_sri;
    CLOSE c_has_sri;

     OPEN c_get_sdoc_code ('COD_FACT');
     FETCH c_get_sdoc_code into v_sdoc_code;
     CLOSE c_get_sdoc_code;

p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'Inicio','01- '|| p_pidm||' p_doc_num: '||p_doc_num || ' v_has_sri: '||v_has_sri, p_user);

IF  v_has_sri is null then

                   OPEN c_get_pto_emision;
                   FETCH c_get_pto_emision into v_pto_emision, v_prefix_1, v_prefix_2;
                   CLOSE c_get_pto_emision;

      p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'Emision', '02- '||'v_pto_emision: '||v_pto_emision||' v_prefix_1: '||v_prefix_1 || ' v_prefix_2: '||v_prefix_2, p_user);

                   IF v_prefix_1 is not null and v_prefix_2 is not null then  

                        open c_get_data;
                        fetch c_get_data into p_program, p_term, p_campus;
                        close c_get_data;

                        tzkpufc.p_get_next_folio (p_doctype         => v_sdoc_code,
                                                              p_user            => p_user, 
                                                              p_camp_code       => p_campus,
                                                              p_prefix1         => v_prefix_1,
                                                              p_prefix2         => v_prefix_2,
                                                              p_next_numdoc     => v_doc_num, 
                                                              p_seq             => v_seq,    
                                                              p_errormsg        => v_error,
                                                              p_camp_district   => v_district); 

    p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'p_get_next_folio', '03- '||'v_sdoc_code: '||v_sdoc_code||' p_campus: '||p_campus || ' v_doc_num: '||v_doc_num|| ' v_error: '||v_error, p_user);

                   IF v_doc_num is not null then           
                      p_folio_factura := v_prefix_1 || '-'||v_prefix_2 ||'-'|| lpad(v_doc_num,9,'0');
                      p_return := v_has_sri;

                                TZKPUFC.P_UPDATE_SECUENCIA(
                                    P_DOCTYPE => v_sdoc_code,
                                    P_USER => p_user,
                                    P_PREFIX1 => v_prefix_1,
                                    P_PREFIX2 => v_prefix_2,
                                    P_CAMP_CODE => p_campus,
                                    P_SECUENCIA => v_doc_num,
                                    P_ERROR => v_err_update
                                  );

p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'P_UPDATE_SECUENCIA', '04- '||'p_folio_factura: '||p_folio_factura||' v_err_update: '||v_err_update , p_user);

      IF v_err_update is null then

      OPEN c_terceros;
      fetch c_terceros into v_TRDPARTY_PIDM, v_TRDPARTY_ID,v_TRDPARTY_NAME;
      CLOSE c_terceros;

        OPEN c_get_data_i ('PUCE_FACT', 'FA_CERO', 'EXT');
        FETCH c_get_data_i INTO p_pay_detail_code;
        CLOSE c_get_data_i;

        p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'P_UPDATE_SECUENCIA', '05- '||'p_pay_detail_code: '||p_pay_detail_code||' v_TRDPARTY_NAME: '||v_TRDPARTY_NAME , p_user);

        IF p_pay_detail_code is not null then

        gb_common.p_set_context ('TB_RECEIVABLE',
                                 'SYSTEM_TRAN',
                                 'TRUE',
                                 'N');

            BEGIN
                SELECT tb_common.f_update_sobseqn_receipt
                  INTO ln_recepit_number
                  FROM DUAL;
            END;

                OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
                FETCH c_get_data_i INTO v_user_create;
                CLOSE c_get_data_i;

				begin
					tb_receivable.p_create (
					p_pidm => p_pidm,
					p_term_code => p_term,
					p_detail_code =>  p_pay_detail_code,
					p_user => v_user_create,
					p_amount => 0,
					p_effective_date => sysdate,
					p_trans_date => sysdate,
					p_desc =>  f_get_ar_desc ('TBBDETC', p_pay_detail_code, 60),
					p_data_origin =>  'TZKPUFC',
					p_receipt_number =>  ln_recepit_number,
					p_tran_number_out => ln_tbraccd_tran_number_out,
					p_rowid_out => lv_tbraccd_response_out);

					p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'tb_receivable.p_create', '06- '||'ln_recepit_number: '||ln_recepit_number||' ln_tbraccd_tran_number_out: '||ln_tbraccd_tran_number_out ||' lv_tbraccd_response_out: '||lv_tbraccd_response_out, p_user);

				EXCEPTION
                    WHEN OTHERS
                    THEN
                        --ROLLBACK;
                        p_error_msg :=
                               'Error generado el pago - '
                            || SQLCODE
                            || SUBSTR (SQLERRM, 1, 300);

						p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'tb_receivable.p_create error', '06- '||'ln_recepit_number: '||ln_recepit_number||' ln_tbraccd_tran_number_out: '||ln_tbraccd_tran_number_out ||' lv_tbraccd_response_out: '||lv_tbraccd_response_out||'p_error_msg '||p_error_msg, p_user);
                        RETURN;
                END;
				BEGIN
                    UPDATE tzrdprf
                       SET tzrdprf_total_pay_amount = 0,                         
                           tzrdprf_card_pay_amount = null,                         
                           tzrdprf_receipt_number = ln_recepit_number, -- 23SEP19 EMR
                           tzrdprf_pay_date = sysdate,
                           tzrdprf_pay_hour = null,
                           tzrdprf_pay_user_id = nvl(v_user_create,USER),
                           tzrdprf_doc_status = 'ACEPTADO',
                           tzrdprf_pay_comments = 'Factura en cero',
                           tzrdprf_auth_number = null,
                           tzrdprf_activity_date = SYSDATE
                     WHERE tzrdprf_doc_number = to_number(p_doc_num);
				COMMIT;
                    p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'update ttzrdprf', '(p_doc_num) '||to_number(p_doc_num), p_user);

                EXCEPTION
                    WHEN OTHERS
                    THEN
                        --ROLLBACK;
                        p_error_msg :=
                               'Error generado el pago - '
                            || SQLCODE
                            || SUBSTR (SQLERRM, 1, 300);

						p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'tb_receivable.p_create error', '06- '||'ln_recepit_number: '||ln_recepit_number||' ln_tbraccd_tran_number_out: '||ln_tbraccd_tran_number_out ||' lv_tbraccd_response_out: '||lv_tbraccd_response_out, p_user);
                        RETURN;
                END;

            IF (ln_tbraccd_tran_number_out = '0')
            THEN      
                GOTO end_process_cero;

            ELSE

                OPEN c_get_sdoc_code ('COD_PREF');
                FETCH c_get_sdoc_code into v_pref_code;
                CLOSE c_get_sdoc_code;

                    begin 
                    INSERT INTO TZRFACT (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM, TZRFACT_CRN_CONTND, TZRFACT_SRI_DOCNUM, TZRFACT_RECEIPT_NUM, TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY, TZRFACT_CREDNT_BNNR, TZRFACT_CREDNT_SRICODE, TZRFACT_NCRED_REASON, TZRFACT_SRI_AUTH_NUM, TZRFACT_SRIDOC_STCODE, TZRFACT_SRIDOC_STDESC, TZRFACT_SAP_DOCNUM, TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE, TZRFACT_CREDNT_DATE, TZRFACT_ACTIVITY_DATE, TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS)
                                select TZRFACT_PIDM, v_sdoc_code, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, p_pay_detail_code, 0, ln_tbraccd_tran_number_out, TZRFACT_CRN_CONTND, TZRFACT_SRI_DOCNUM, TZRFACT_RECEIPT_NUM, TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY, TZRFACT_CREDNT_BNNR, TZRFACT_CREDNT_SRICODE, TZRFACT_NCRED_REASON, TZRFACT_SRI_AUTH_NUM, TZRFACT_SRIDOC_STCODE, TZRFACT_SRIDOC_STDESC, TZRFACT_SAP_DOCNUM, TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE, TZRFACT_CREDNT_DATE, sysdate, TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS
                                from tzrfact where tzrfact_pidm = p_pidm and TZRFACT_DOC_NUMBER = p_doc_num and TZRFACT_SDOC_CODE = v_pref_code and rownum = 1;

                                p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'Insert TZRFACT', '07- '||'v_pref_code: '||v_pref_code, p_user);           
                    exception when others then null;
                    end;

                    begin
                                  update TZRFACT
                                        set TZRFACT_SRI_DOCNUM = p_folio_factura,
                                              TZRFACT_FACT_DATE = sysdate,
                                              TZRFACT_TRDPARTY_ID = v_TRDPARTY_ID
                                              , TZRFACT_TRDPARTY_PIDM = v_TRDPARTY_PIDM
                                              , TZRFACT_TRDPARTY_NAME = v_TRDPARTY_NAME
                                              , TZRFACT_STPERDOC_QTY = 1
                                              , TZRFACT_USER = p_user
                                              , TZRFACT_PAY_DATE = sysdate
                                        where 
                                        TZRFACT_PIDM = p_pidm
                                        and TZRFACT_DOC_NUMBER = p_doc_num
                                        and TZRFACT_SRI_DOCNUM is  null;

                                   p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'Insert TZRFACT', '08- '||'update tzrfact OK Finaliza ', p_user);           
                        exception when others then null;
                        end;
                        p_return := p_folio_factura;
            END IF;

        ELSE
            GOTO end_process_cero;
        END IF;

                        END IF; 

                        END IF;  
    ELSE
    GOTO end_process_cero;
    END IF; 

ELSE

p_return := v_has_sri;

END IF; 


<<end_process_cero>> 

p_ins_tzrrlog(p_pidm,  'FACTURA_CERO', 'end_process_cero', '08- '||'Excepcion '||SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), p_user);           

end p_gen_factura_cero;



--  Procedimiento utilizado por el hall de pagos para auto cerrar las páginas visitadas.
procedure p_auto_close
is
begin
htp.p('<script type="text/javascript">
     self.close();
</script>');
end;

-- Procedimiento que genera la prefactura desde autoservicios.
-- Como primer actividad se encarga de ejecutar el procedimirnto  de segunda y tercera matrícula.
-- Valida si no tiene documento generado (f_get_valid_document) y ejecuta el proceso de becas inmerso en el procedimiento (p_awards_courses)
-- Posteriormente llama al procedimiento de generaciónde prefactura (p_gen_doc) y al procedimiento que genera y muestra el PDF (p_show_pdf)
--
PROCEDURE p_gen_document_ssb (p_pidm   IN NUMBER, p_term_code    IN VARCHAR2,  p_sdoc_code  IN VARCHAR2, p_out OUT varchar2)
    IS
        p_error_msg_2    VARCHAR2 (1000);
        p_error_msg     VARCHAR2 (1000);
        lv_out_error       VARCHAR2 (1000);
        v_id               spriden.spriden_id%TYPE;
        v_camp_code        stvcamp.stvcamp_code%TYPE;
        v_user_id          VARCHAR2 (30) := NULL;
        v_send_ind         VARCHAR2 (1) := 'N';
        v_site_code        VARCHAR2 (30) := NULL;
        v_levl             VARCHAR2 (30) := NULL;
        v_program          VARCHAR2 (30) := NULL;
        v_user_create      VARCHAR2 (30) := NULL;
        v_moneda           VARCHAR2 (30) := NULL;
        v_create_doc       VARCHAR2 (30) := NULL;
        v_doc_num          VARCHAR2 (30) := NULL;
        v_error_ind        VARCHAR2 (30) := NULL;
        v_err_msg          VARCHAR2 (300) := NULL;
        p_sdoc_pref        VARCHAR2 (100);
        lv_doc_amount      NUMBER (18, 2) := 0;
        v_sqlerrormsg   varchar2(500);

cursor c_has_bec  (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2) is
select distinct tvrsdoc_doc_number
          from TZVACCD , tvrsdoc
          where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code and TZVACCD_DCAT_CODE in ('BEC','DES') and TZVACCD_TYPE_IND = 'P'
            and tzvaccd_pidm = tvrsdoc_pidm
                             AND tzvaccd_tran_number = tvrsdoc_chg_tran_number
                             AND tvrsdoc_sdoc_code = TZVACCD_SDOC_CODE
                             AND tvrsdoc_doc_cancel_ind IS NULL;


cursor c_boleto_activo (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2,
            p_doc_number varchar2) is
   select sum(TZVACCD.TZVACCD_BALANCE) balance
          from TZVACCD , tvrsdoc
          where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code
           and tzvaccd_tran_number in (select tvrsdoc_chg_tran_number from tvrsdoc
                                                        where  tzvaccd_pidm = tvrsdoc_pidm
                                                         AND tvrsdoc_sdoc_code = TZVACCD_SDOC_CODE
                                                          and tvrsdoc_doc_number = p_doc_number
                                                         AND tvrsdoc_doc_cancel_ind IS NULL);

cursor c_get_bec  (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2) is
select TZVACCD.*
          from TZVACCD 
          where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code and TZVACCD_DCAT_CODE in ('BEC','DES') and TZVACCD_TYPE_IND = 'P'
          and  not exists ( select 'Y' from tvrsdoc where tvrsdoc_pidm = tzvaccd_pidm and tvrsdoc_chg_tran_number =   tzvaccd_tran_number and tvrsdoc_sdoc_code = TZVACCD_SDOC_CODE AND tvrsdoc_doc_cancel_ind = 'Y');

v_print_becas varchar2(1) := 'N'; 
v_doc_number varchar2(20) := 0;
v_print_becas_i varchar2(1) := 'N'; 
v_doc_number_i varchar2(20) := 0;
v_trans             VARCHAR2 (1000);
v_trx_dis           VARCHAR2 (1000);
v_all_trans       VARCHAR2 (1500);

cursor c_beca_aplicada (pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2)
        is
        select TZVACCD_AMOUNT amt, TZVACCD_BALANCE bal
          from TZVACCD where TZVACCD_PIDM =pidm and TZVACCD_SDOC_CODE = p_sdoc_code and TZVACCD_TERM_CODE = p_term_code and TZVACCD_DCAT_CODE in ('BEC','DES') and TZVACCD_TYPE_IND = 'P' ;

        v_beca_no_aplicada varchar2(1):= 'N';


       CURSOR c_bec_trans (
            pidm           spriden.spriden_pidm%TYPE,
            p_sdoc_code    VARCHAR2,
            p_term_code    VARCHAR2,
            p_trxs_chg varchar2)
        IS
                 SELECT 
                   REGEXP_REPLACE (
                       LISTAGG (TZVACCD_TRAN_NUMBER, ',')
                           WITHIN GROUP (ORDER BY TZVACCD_TRAN_NUMBER),
                       '([^,]+)(,\1)*(,|$)',
                       '\1\3')
                       AS trans_num
              FROM TZVACCD
             WHERE     TZVACCD_PIDM = pidm
                   AND TZVACCD_SDOC_CODE = p_sdoc_code
                   AND TZVACCD_TERM_CODE = p_term_code
                   AND TZVACCD_DCAT_CODE in ('BEC','DES')
                   and TZVACCD_TYPE_IND = 'P'
                   AND TZVACCD_BALANCE = 0
                    and tzvaccd_tran_number  
                        not in (select TZRFACT_TRAN_NUM from tzrfact where tzrfact_pidm = tzvaccd_pidm and tzrfact_term_code = TZVACCD_TERM_CODE and TZRFACT_SRI_DOCNUM is not null)
                    and tzvaccd_tran_number
                             in (select TBRAPPL_PAY_TRAN_NUMBER from tbrappl where tbrappl_pidm = tzvaccd_pidm  and TBRAPPL_REAPPL_IND is null 
                             and TBRAPPL_CHG_TRAN_NUMBER IN                              
                           (    SELECT REGEXP_SUBSTR (
                                           REPLACE ((p_trxs_chg), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (
                                           REPLACE ((p_trxs_chg), ' '),
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                           IS NOT NULL)
                             ) ;   

        CURSOR c_get_transactions (
            p_pidm         IN NUMBER,
            p_term_code    IN VARCHAR2,
            p_sdoc_code    IN VARCHAR2
            )
        IS
                SELECT tzvaccd_pidm,
                     tzvaccd_sdoc_code,
                     tzvaccd_term_code,
                     SUM (tzvaccd_balance)
                         doc_amount,
                     REGEXP_REPLACE (
                         LISTAGG (tzvaccd_tran_number, ',')
                             WITHIN GROUP (ORDER BY tzvaccd_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         trans,
                         TZVACCD_CAMPUS
                         , null  as TZVACCD_CRN
                FROM tzvaccd
               WHERE  tzvaccd_term_code = p_term_code
                    AND 10 <> substr(p_term_code,5,2)
                    AND tzvaccd_pidm = p_pidm
                    AND tzvaccd_sdoc_code = p_sdoc_code
                     AND tzvaccd_balance > 0
            GROUP BY tzvaccd_pidm, tzvaccd_sdoc_code, tzvaccd_term_code, TZVACCD_CAMPUS, null
            UNION
                    SELECT tzvaccd_pidm,
                     tzvaccd_sdoc_code,
                     tzvaccd_term_code,
                     SUM (tzvaccd_balance)
                         doc_amount,
                     REGEXP_REPLACE (
                         LISTAGG (tzvaccd_tran_number, ',')
                             WITHIN GROUP (ORDER BY tzvaccd_pidm),
                         '([^,]+)(,\1)*(,|$)',
                         '\1\3')
                         trans,
                         TZVACCD_CAMPUS
                         , tzvaccd_crn
                FROM tzvaccd
               WHERE  tzvaccd_term_code = p_term_code
                    AND 10 = substr(p_term_code,5,2)
                    AND tzvaccd_pidm = p_pidm
                    AND tzvaccd_sdoc_code = p_sdoc_code
                     AND tzvaccd_balance > 0
            GROUP BY tzvaccd_pidm, tzvaccd_sdoc_code, tzvaccd_term_code, TZVACCD_CAMPUS, tzvaccd_crn;  

    cursor c_get_tx_dis_becas ( p_pidm in number, p_term_code in varchar2, p_sdoc_code varchar2, p_trans varchar2) is
    select a1.tbraccd_tran_number trx_dis
      from tbraccd a1 
    where a1.tbraccd_pidm = p_pidm 
        and a1.TBRACCD_TERM_CODE = p_term_code 
        and a1.TBRACCD_AMOUNT < 0  
        and  a1.TBRACCD_BALANCE = 0 
            AND a1.tbraccd_tran_number NOT IN
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
                                           IS NOT NULL);

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

CURSOR c_get_moneda
    IS
        SELECT gubinst_base_curr_code FROM gubinst;


    BEGIN

        BEGIN
            sb_calculo_seg_ter_matricula.p_assign_charges_student (
                p_student_pidm        => p_pidm,
                p_periodoprefactura   => p_term_code,
                sqlerrormsg           => v_sqlerrormsg);

            tzkpufc.p_ins_tzrrlog(p_pidm,  'PREFACTURA_WEB', 'sb_calculo_seg_ter_matricula', v_sqlerrormsg, user);
           p_error_msg := v_sqlerrormsg;
        exception when others then 
           tzkpufc.p_ins_tzrrlog(p_pidm,  'PREFACTURA_WEB', 'sb_calculo_seg_ter_matricula', v_sqlerrormsg, user);
        END;


tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA', 'PREFACTURA_WEB', 'p_term_code: ' || p_term_code||  ' p_sdoc_code: ' || p_sdoc_code , user);

        v_levl          := tzkpufc.f_get_sovlcur(p_pidm, p_term_code, 'LEVL' );
        v_program   := tzkpufc.f_get_sovlcur(p_pidm, p_term_code, 'PROGRAM' );

                OPEN c_get_data_i ('PUCE_FACT', 'USR_GEN', 'EXT');
                FETCH c_get_data_i INTO v_user_create;
                CLOSE c_get_data_i;

                OPEN c_get_moneda;
                FETCH c_get_moneda INTO v_moneda;
                CLOSE c_get_moneda;


        FOR gtrx IN c_get_transactions ( p_pidm,
                                     p_term_code,                                     
                                     p_sdoc_code)
        LOOP
            IF c_get_transactions%NOTFOUND  THEN
                GOTO end_process;
            END IF;

                v_create_doc :=
                    tzkpufc.f_get_valid_document (gtrx.tzvaccd_pidm,
                                          gtrx.tzvaccd_term_code,
                                          gtrx.TZVACCD_CAMPUS,
                                          gtrx.tzvaccd_sdoc_code,
                                          gtrx.tzvaccd_crn);

                tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'f_get_valid_document', 'v_create_doc: ' || v_create_doc, user);

                IF v_create_doc = 'Y'
                THEN                    
                    BEGIN
                        tzkpufc.p_awards_courses (
                            p_pidm        => gtrx.tzvaccd_pidm,
                            p_term_code   => gtrx.tzvaccd_term_code,
                            p_error_msg => p_error_msg_2 
                            );

                            tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'BECAS p_awards_courses', p_error_msg_2, user);

                    EXCEPTION
                        WHEN OTHERS
                        THEN
                        NULL;
                    END;

                    FOR bec
                        IN c_beca_aplicada (gtrx.tzvaccd_pidm,gtrx.tzvaccd_sdoc_code, gtrx.tzvaccd_term_code)
                    LOOP
                                     IF abs(bec.amt) = abs(bec.bal) then
                                        v_beca_no_aplicada := 'Y';
                                     end if;

                    END LOOP;
                    tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'v_beca_no_aplicada', v_beca_no_aplicada ||' '|| gtrx.tzvaccd_sdoc_code ||' '|| gtrx.tzvaccd_term_code, user);

                      FOR hb  IN c_has_bec (gtrx.tzvaccd_pidm,gtrx.tzvaccd_sdoc_code, gtrx.tzvaccd_term_code)
                                        LOOP
                                            v_doc_number_i :=  hb.tvrsdoc_doc_number;
                                            tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'v_doc_number_i ', v_doc_number_i, user);

                                                 FOR ba  IN c_boleto_activo (gtrx.tzvaccd_pidm,gtrx.tzvaccd_sdoc_code, gtrx.tzvaccd_term_code, hb.tvrsdoc_doc_number)
                                                        LOOP  
                                                        tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'Validacion de Becas For c_boleto_activo ', ba.balance, user);

                                                              IF ba.balance > 0 then
                                                                v_print_becas_i := 'Y';
                                                              END IF;
                                                        END LOOP;
                                                    tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'v_print_becas_i ', v_print_becas_i, user);
                                        END LOOP;

                              tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'Validacion de Becas For c_boleto_activo ', v_print_becas_i ||' - ' ||v_doc_number_i, user);

                                       IF v_print_becas_i = 'Y' or v_doc_number_i = 0 then
                                          FOR b_tran  IN c_bec_trans (gtrx.tzvaccd_pidm,gtrx.tzvaccd_sdoc_code, gtrx.tzvaccd_term_code, gtrx.trans)
                                               LOOP
                                                  tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'Validacion de Becas For c_bec_trans No Pagado', b_tran.trans_num, user);
                                                   IF b_tran.trans_num is not null then
                                                    v_trans := v_trans ||',' ||b_tran.trans_num;
                                                    END IF;
                                               END LOOP;     
                                               tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'Validacion de Becas For c_bec_trans ', v_trans, user);
                                        END IF;       

                    IF TZKPUFC.f_get_valid_document(gtrx.tzvaccd_pidm, gtrx.tzvaccd_term_code, gtrx.TZVACCD_CAMPUS, gtrx.tzvaccd_sdoc_code, gtrx.TZVACCD_CRN) = 'Y' THEN
                        IF v_beca_no_aplicada = 'Y' then
                               v_beca_no_aplicada := 'N';
                                tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'Error Becas 2: ', lv_out_error, user);

                               EXIT;
                        END IF;
                      ELSE
                               tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'Error Becas 3: ', lv_out_error, user);

                               EXIT;
                     END IF;          

                       IF v_trans is not null then
                       v_all_trans := gtrx.trans||','||v_trans;
                       ELSE
                       v_all_trans := gtrx.trans;
                       END IF;

                        tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'v_all_trans Previo', v_all_trans, user);

                        tzkpufc.p_gen_doc (
                            p_pidm        => gtrx.tzvaccd_pidm,
                            p_trans       => v_all_trans, 
                            p_sdoc_code   => gtrx.tzvaccd_sdoc_code,
                            p_site_code   => gtrx.TZVACCD_CAMPUS,
                            p_term_code   => gtrx.tzvaccd_term_code,
                            p_curr_code   => v_moneda,
                            p_user_id     => v_user_create,
                            p_program     => v_program,
                            p_levl_code   => v_levl,
                            p_doc_num     => v_doc_num,
                            p_error_ind   => v_error_ind,
                            p_error_msg   => v_err_msg);

            tzkpufc.p_ins_tzrrlog(gtrx.tzvaccd_pidm,  'PREFACTURA_WEB', 'p_gen_doc', 'v_all_trans: ' || v_all_trans||' gtrx.tzvaccd_sdoc_code: ' ||gtrx.tzvaccd_sdoc_code||' gtrx.TZVACCD_CAMPUS: ' ||gtrx.TZVACCD_CAMPUS
            ||' gtrx.tzvaccd_term_code: ' ||gtrx.tzvaccd_term_code||' v_moneda: ' ||v_moneda||' v_user_create: ' ||v_user_create||' v_program: ' ||v_program
            ||' v_levl: ' ||v_levl||' v_doc_num: ' ||v_doc_num||' v_error_ind: ' ||v_error_ind||' v_err_msg: ' ||v_err_msg, user);

                            v_all_trans := '';
                        gb_common.p_commit;
                        v_trans := '';

                    IF v_doc_num IS NOT NULL       THEN
                        p_out := v_doc_num;

                        tzkpufc.p_show_pdf (p_pidm         => gtrx.tzvaccd_pidm,
                                    p_doc_number   => TO_NUMBER (v_doc_num),
                                    p_send_mail    => v_send_ind,
                                    p_web          => 'Y',
                                    p_footer => '');
                    END IF;

        END IF;
        END LOOP;

        gb_common.p_commit;

       <<end_process>>

                tzkpufc.p_ins_tzrrlog(p_pidm,  'PREFACTURA_WEB', 'ERROR F', SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500), user);
    END p_gen_document_ssb ;


    PROCEDURE p_show_fact (
                      p_pidm         IN NUMBER,
                      p_sri_docnum   IN tzrfact.tzrfact_sri_docnum%TYPE
                      )
    IS


       v_pidm number:=0;

        l_pdf                 BLOB;
        p_nombre_estudiante   VARCHAR2 (1000);
        p_web                 VARCHAR2 (1000);  
        p_doc_number          NUMBER;
        v_fecha_emision       DATE;
        v_email               goremal.goremal_email_address%TYPE; 
        v_total_venta_neta    NUMBER;   
        p_campus_number number (1);
         l_num_mask            VARCHAR2 (20) := 'L999G999G999D00';
        v_total_cargos        NUMBER;

v_tipo_iden           stvlgcy.stvlgcy_desc%TYPE;
v_iden                spbpers.spbpers_ssn%TYPE;
v_tipo_iden_sede           stvlgcy.stvlgcy_desc%TYPE;
v_iden_sede                spbpers.spbpers_ssn%TYPE;
v_id_estudiante       varchar2(20);
v_direccion           spraddr.spraddr_street_line1%TYPE;
v_dir_sede               spraddr.spraddr_street_line1%TYPE;
v_dir_city_sede      varchar2(50);
v_city varchar2(50);

p_emal_code varchar2(20);
p_emal_code_sede varchar2(20);
         p_sede          sovlcur.sovlcur_camp_code%TYPE;

        l_widths              plpdf_type.t_row_widths;   

        l_aligns_center       VARCHAR2 (2) := 'C';
        l_aligns_left         VARCHAR2 (2) := 'L';
        l_aligns_rigth        VARCHAR2 (2) := 'R';
        l_font_arial          NUMBER := 10;        
        l_font_courier        NUMBER := 8;        
        l_cell_courier        NUMBER := l_font_courier - 3.5;
        l_font_times          NUMBER := 14;
        l_cell_times          NUMBER := l_font_times - 8;


        v_periodo_prefactura  VARCHAR2 (6);
        v_tran_num            VARCHAR2 (20):='CANT';
        v_describe_detalle    VARCHAR2 (20):='DETALLE';
        v_valor_unitario      VARCHAR2 (20):='VALOR UNITARIO';
        v_valor_total         VARCHAR2 (20):='VALOR TOTAL';
        v_total_descuentos    NUMBER := 0;  

        v_total_pagos         NUMBER;

        v_descuento           NUMBER := 0; 
        v_descuento2          NUMBER := 0;  

        v_detalleivamayorcero VARCHAR2(40);
        v_valorivaestudiante  tzrfact.tzrfact_amnt_trans%TYPE;
        v_total               NUMBER := 0;  
        v_valor_retencion       NUMBER := 0;
        v_descripcion_retencion VARCHAR2 (200);
        v_total_factura         NUMBER := 0;    
        p_pidm_sede        spriden.spriden_pidm%TYPE;
        v_resolucionimpuestos   VARCHAR2 (300);
        v_rucsede               VARCHAR2 (300);
        v_direccionsede         VARCHAR2 (200);
        v_telefenosede          VARCHAR2 (200);
        v_emailsede             VARCHAR2 (200);
        v_cajero                tzrfact.tzrfact_user%TYPE;

        v_carreraestudiante     tzrfact.tzrfact_curr_program%TYPE;
       v_telefono sprtele.sprtele_phone_number%type;

       v_party_id  TZRFACT.TZRFACT_TRDPARTY_ID%type;
       v_party_pidm TZRFACT.TZRFACT_TRDPARTY_PIDM%type;
       v_party_name TZRFACT.TZRFACT_TRDPARTY_NAME%type;


 cursor c_get_data is 
        select  TZRFACT_TERM_CODE , tzrfact_doc_number,tzrfact_fact_date,  TZRFACT_CAMPUS, SUBSTR(tzrfact_sale_docnum,7,1) campus_number, tzrfact_curr_program, tzrfact_user  
                  ,TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME
        from tzrfact where tzrfact_pidm = p_pidm 
        and TZRFACT_SDOC_CODE = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where gtvsdax_internal_code_group = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_FACT')
        and tzrfact_sri_docnum =  p_sri_docnum;

 cursor c_get_data_sede (p_campus_number number) is 
SELECT gb_common.f_get_pidm ( gtvsdax_external_code) pidm_sede, gtvsdax_comments 
                FROM  gtvsdax 
                WHERE gtvsdax_internal_code ='ID_PUCE' 
                AND   gtvsdax_internal_code_group='PUCE_FACT'
                AND   gtvsdax_translation_code= p_campus_number;

CURSOR c_nombre_completo (p_pidm number)
IS
    SELECT    REPLACE (spriden_last_name, '/', ' ')
    || ' '|| spriden_first_name|| ' '|| spriden_mi complete_name
    FROM spriden
    WHERE spriden_change_ind IS NULL 
    AND spriden_pidm = p_pidm;

CURSOR c_identificacion (p_pidm number)
IS
    SELECT (
    SELECT stvlgcy_desc
    FROM stvlgcy
    WHERE stvlgcy_code = spbpers_lgcy_code
    ) tipo_identificacion, spbpers_ssn  identificacion
    FROM spbpers
    WHERE spbpers_pidm =  p_pidm
    AND ROWNUM=1;

CURSOR c_cargos
IS 
SELECT  tzrfact_stperdoc_qty 
           , tzrfact_det_code_doc
           , f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion
          , sum(tzrfact_amnt_trans) as tzrfact_amnt_trans
          ,tzrfact_crn_contnd
          ,tzrfact_term_code 
FROM  tzrfact, tbbdetc 
WHERE tzrfact_det_code_doc = tbbdetc_detail_code
and tbbdetc_dcat_code not in ('TAX','TER','FNA')
AND tbbdetc_type_ind='C'
and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_FACT','COD_PREF') )
AND   tzrfact_pidm     =  p_pidm 
AND   tzrfact_sri_docnum =  p_sri_docnum
GROUP BY tzrfact_stperdoc_qty ,
          tzrfact_det_code_doc,
          tzrfact_crn_contnd,tzrfact_term_code;                               


cursor c_get_descuento1 is
                        SELECT  SUM(tzrfact_amnt_trans)                        
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_FACT','COD_PREF')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_sri_docnum    =  p_sri_docnum
                        AND   tzrfact_det_code_doc  IN  (
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code LIKE '1%'
                                                        );

cursor c_get_descuento2 is
                        SELECT  SUM(tzrfact_amnt_trans)
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_FACT','COD_PREF')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_sri_docnum    =  p_sri_docnum
                        AND   tzrfact_det_code_doc  IN  ((
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code NOT LIKE '1%'
                                                        )
                                                        UNION
                                                        (
                                                         select TBBDETC_DETAIL_CODE from TBBDETC 
                                                         WHERE TBBDETC_DCAT_CODE IN ('BEC','DES')
                                                         AND    tbbdetc_type_ind = 'P'
                                                         AND TBBDETC_DETAIL_CODE NOT IN (
                                                         SELECT kvrfbse_dflt_detail_code 
                                                         FROM   kvrfbse 
                                                         WHERE kvrfbse_fndc_code  LIKE '1%')
                                                        )
                                                        );



CURSOR c_formapago
IS
SELECT 
       f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion, 
       sum(tzrfact_amnt_trans ) tzrfact_amnt_trans 
FROM   tzrfact
where

   tzrfact_sdoc_code    IN (SELECT gtvsdax_external_code
                                FROM   gtvsdax 
                                WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                AND gtvsdax_internal_code =  'COD_FACT'
                                )
--AND    tzrfact_pidm         =  p_pidm 
AND    tzrfact_sri_docnum   =  p_sri_docnum
group by        TZRFACT_DET_CODE_DOC;



CURSOR c_totalivas is
SELECT tbbdetc_detail_code, 
               'TOTAL GRAVADO CON ' ||tbbdetc_desc detalle, 
               tbbdetc_type_ind, 
               tbbdetc_dcat_code,
               SUBSTR(tbbdetc_desc,INSTR(tbbdetc_desc,' ')+1,( INSTR(tbbdetc_desc,'%')-INSTR(tbbdetc_desc,' ') )-1 ) iva
            ,(
            nvl((
                SELECT         
                             tzrfact_stperdoc_qty *
							 sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and tbbdetc_dcat_code not in ('TAX','TER','FNA')
                AND tbbdetc_type_ind='C'
                and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_FACT','COD_PREF') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                AND   tzrfact_pidm     =  p_pidm 
                AND   tzrfact_sri_docnum =  p_sri_docnum
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE
				GROUP BY tzrfact_stperdoc_qty ,
				--tzrfact_det_code_doc,
				tzrfact_crn_contnd,tzrfact_term_code
				),0)
                -
                nvl((SELECT         
                             sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and tbbdetc_dcat_code  in ('BEC','DES')
                AND tbbdetc_type_ind='P'
                and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_FACT','COD_PREF') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                AND   tzrfact_pidm     =  p_pidm 
                AND   tzrfact_sri_docnum =  p_sri_docnum
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE) ,0)
                ) valor
        FROM tbbdetc iva
        WHERE iva.tbbdetc_dcat_code='TAX'
        AND iva.tbbdetc_type_ind='C'
        AND iva.TBBDETC_DETAIL_CODE
        IN (
            SELECT TVRDCTX_TXPR_CODE
            FROM tvrdctx 
            WHERE tvrdctx_txpr_code IS NOT NULL
            ) ;


      CURSOR c_direccion (p_pidm number) IS
        SELECT spraddr_street_line1, spraddr_city
        FROM spraddr
        WHERE spraddr_pidm = p_pidm
        AND ROWNUM < 2;

      CURSOR c_email (p_pidm number, p_emal_code varchar2) IS
        SELECT goremal_email_address 
        FROM   goremal
        WHERE  goremal_pidm=p_pidm
        AND    goremal_emal_code = p_emal_code;


             CURSOR c_smtp
        IS
            SELECT gtvsdax_external_code, gtvsdax_desc, gtvsdax_comments
            FROM gtvsdax
            WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
            AND gtvsdax_internal_code = 'SMTP';

            cursor c_telefono (p_pidm number) is
            SELECT sprtele_phone_number             
            FROM   sprtele 
            WHERE  sprtele_pidm = p_pidm_sede;

    cursor c_get_retencion is          
                SELECT   SUM(tzrfact_amnt_trans)  valorretencion
                FROM    tzrfact, tbbdetc
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                     and  tbbdetc_dcat_code = 'TER'
                    AND tbbdetc_type_ind = 'C'
                     and tzrfact_sdoc_code IN (SELECT gtvsdax_external_code
                                              FROM   gtvsdax 
                                              WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                              AND gtvsdax_internal_code IN ( 'COD_FACT','COD_PREF')
                                              )
                    AND tzrfact_pidm        =p_pidm
                    AND tzrfact_sri_docnum  =p_sri_docnum ;



cursor c_get_ivamayorcero is
                SELECT  
                'VALOR DEL ' ||      f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion,
                tzrfact.tzrfact_amnt_trans                
                FROM    tzrfact 
                WHERE   tzrfact.tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                          FROM   gtvsdax 
                                                          WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                          AND gtvsdax_internal_code IN( 'COD_FACT','COD_PREF')
                                                          )
                AND     tzrfact.tzrfact_pidm          = p_pidm
                AND     tzrfact.tzrfact_sri_docnum    =  p_sri_docnum
                AND     tzrfact.tzrfact_det_code_doc  IN   (
                                                            SELECT iva.tvrdctx_txpr_code 
                                                            FROM tvrdctx iva
                                                            WHERE  iva.tvrdctx_txpr_code IS NOT NULL
                                                            )
                AND tzrfact.tzrfact_amnt_trans>0                
                and rownum = 1
                ORDER BY tzrfact.tzrfact_det_code_doc;


    BEGIN


        OPEN c_get_data;
        FETCH c_get_data INTO v_periodo_prefactura,p_doc_number, v_fecha_emision, p_sede, p_campus_number, v_carreraestudiante, v_cajero, v_party_id,v_party_pidm,v_party_name;
        CLOSE c_get_data;

       open c_get_data_sede (p_campus_number) ;
       fetch c_get_data_sede into p_pidm_sede, v_resolucionimpuestos;
       close c_get_data_sede;

       OPEN  c_identificacion(p_pidm_sede);
        FETCH c_identificacion INTO v_tipo_iden_sede, v_iden_sede;
        CLOSE c_identificacion;

       v_rucsede := v_tipo_iden_sede||': '|| v_iden_sede;

        OPEN c_get_data_i ('PUCE_FACT', 'ID_PUCE', 'EXT');
        FETCH c_get_data_i INTO p_id_puce;
        CLOSE c_get_data_i;

       OPEN c_direccion(p_pidm_sede);
        FETCH c_direccion  INTO v_dir_sede, v_dir_city_sede ;
        CLOSE c_direccion;  

        v_direccionsede := 'Dirección: '||v_dir_sede||' '||v_dir_city_sede ;        

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_CODE', 'EXT');
        FETCH c_get_data_i INTO p_emal_code;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_INST', 'EXT');
        FETCH c_get_data_i INTO p_emal_code_sede;
        CLOSE c_get_data_i;

        OPEN   c_email (p_pidm_sede, p_emal_code_sede);
        FETCH  c_email INTO   v_emailsede;
        CLOSE  c_email;


        OPEN c_telefono(p_pidm_sede);
        FETCH c_telefono
        INTO v_telefono ;
        CLOSE c_telefono;  

         v_telefenosede := 'Teléfonos: '||v_telefono;


       IF v_party_pidm is null then
           v_pidm := p_pidm;
        ELSE
           v_pidm := v_party_pidm;
       END IF;

        OPEN c_nombre_completo (v_pidm );
        FETCH c_nombre_completo INTO p_nombre_estudiante;
        CLOSE c_nombre_completo;

        OPEN  c_identificacion(v_pidm);
        FETCH c_identificacion INTO v_tipo_iden, v_iden;
        CLOSE c_identificacion;

        OPEN c_direccion(v_pidm);
        FETCH c_direccion    INTO v_direccion, v_city;
        CLOSE c_direccion;  

        OPEN   c_email (v_pidm, p_emal_code);
        FETCH  c_email INTO   v_email;
        CLOSE  c_email;

        IF v_email is null then
            OPEN   c_email (v_pidm, p_emal_code_sede);
            FETCH  c_email INTO   v_email;
            CLOSE  c_email;
        END IF;



        plpdf.init (p_orientation   => plpdf_const.portrait,
                    p_unit          => plpdf_const.mm,
                    p_format        => 'letter');

        plpdf.newpage;

        plpdf.setprintfont (p_family => 'Arial',  p_size => 6);
        plpdf_cell.newline;

                    plpdf.printcell(p_w      => 200,
                    p_txt    => f_format_name (p_pidm_sede, 'L60'),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);



        plpdf.printcell( p_w      => 40,
                    p_txt    => v_rucsede,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);

        plpdf.printcell(p_w      => 80,
                        p_txt    => ' ' ,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 80,
                        p_txt    => 'Nro Factura. ' ||p_sri_docnum,
                        p_border => '1',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_center,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => v_direccionsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);



        plpdf.printcell(p_w        => 200,
                        p_txt    => v_telefenosede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => 'Email: ' ||v_emailsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 200,
                        p_txt    =>tzkcone.f_get_dinamic_text(p_sede,'Encabezado factura', '1,2'),
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.setprintfont (p_family => 'Arial', p_size => 6);


        plpdf_cell.newline;

     plpdf.printcell(p_w     => 200,
                    p_txt    => 'Cliente: ' || p_nombre_estudiante,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => plpdf3.c_right,
                    p_fill   => FALSE);

     plpdf.printcell(p_w     => 200,
                    p_txt    => 'Código: ' || gb_common.f_get_id(v_pidm),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w     => 200,
                    p_txt    =>  'RUC/CI: '  ||v_iden,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w        => 200,
                    p_txt    => 'Dirección: ' || v_direccion,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);



     plpdf.printcell(p_w        => 200,
                    p_txt    => 'Facultad y Carrera: ' || BWCKCAPP.get_program_desc(v_carreraestudiante),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


      plpdf.printcell(p_w   => 40,
                    p_txt   => 'Fecha: ' ||
                                    NVL(TO_CHAR(v_fecha_emision,'DD/MM/YYYY'), 
                                    TO_CHAR(SYSDATE,'DD/MM/YYYY')),
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);


        plpdf.printcell(p_w        => 140,
                        p_txt    => 'Email: ' ||v_email,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 40,
                        p_txt    => ' ' ,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


           plpdf.printcell(p_w   => 40,
                           p_txt   => ' ' ,
                           p_border => '0',
                           p_ln     => plpdf_const.beside,
                           p_align  => 'L',
                           p_fill   => FALSE);

          plpdf.printcell(p_w        => 90,
                        p_txt    => ' ',
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => 'L',
                        p_fill   => FALSE);

           plpdf.printcell(p_w        => 70,
                        p_txt    => 'Cajero: ' ||v_cajero,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.printcell(p_w      => 40,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 90,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 70,
                        p_txt    => 'Comprobante Nro:' ||tzkpufc.f_get_docnum_fmt(p_doc_number),
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);

        plpdf_cell.printcell (p_width => 200,
                             p_text => '' 
                             );

        plpdf_cell.newline;
        plpdf_cell.init;

            v_total_venta_neta:=0;
            v_total_cargos := 0;
            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 8);


            plpdf.printcell (p_w        => 20,
                             p_txt      => v_tran_num,
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);

              plpdf.printcell   (p_w        => 80,
                                 p_txt      => v_describe_detalle,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_unitario,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_total,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'C',
                                 p_fill  =>FALSE
                                 );

        plpdf_cell.newline;
        plpdf.setprintfont (p_family   => 'Arial',p_size     => 6);


        FOR chrg IN c_cargos     LOOP
            plpdf.printcell (p_w        => 20,
                             p_txt      => nvl(chrg.tzrfact_stperdoc_qty,1),
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);


                plpdf.printcell (p_w        => 80,
                                 p_txt      => tzkcone.f_get_title_ed_con(chrg.tzrfact_term_code,chrg.tzrfact_crn_contnd,chrg.descripcion),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);
                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

               v_total_cargos := v_total_cargos + chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1);

            END LOOP;

            plpdf_cell.newline;
            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 6);
            plpdf.printcell     (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w        => 70,
                                 p_txt      => 'SUBTOTAL',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w     =>50,
                                 p_txt   =>TO_CHAR (v_total_cargos, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf_cell.newline;

                plpdf.setprintfont (p_family   => 'Arial',p_size     => 6);

                open c_get_descuento1;
                fetch c_get_descuento1 into v_descuento;
                close c_get_descuento1;

                plpdf.printcell (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'DESCUENTO 1',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_descuento,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                open c_get_descuento2;
                fetch c_get_descuento2 into v_descuento2;
                close c_get_descuento2;

                plpdf.printcell (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'DESCUENTO 2',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);


                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_descuento2,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

           v_total_descuentos := NVL(v_descuento,0) + NVL(v_descuento2,0);
           v_total_venta_neta:=v_total_cargos-v_total_descuentos;


           plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'TOTAL VENTA NETA',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (v_total_venta_neta, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );




            FOR fivas IN c_totalivas     LOOP

                plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => fivas.detalle,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (ABS(fivas.valor), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );
          END LOOP;


v_valorivaestudiante := 0;

open c_get_ivamayorcero;
fetch c_get_ivamayorcero into v_detalleivamayorcero  ,v_valorivaestudiante;
close c_get_ivamayorcero;


                plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => nvl(v_detalleivamayorcero,'VALOR DEL IVA 12%'),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_valorivaestudiante,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );



           v_total:=NVL(v_total_cargos,0)-NVL(v_total_descuentos,0)+NVL(v_valorivaestudiante,0);

           plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'TOTAL',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (v_total, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


           plpdf.setprintfont (p_family => 'Arial',  p_size => 6);
       plpdf_cell.newline;

        open c_get_retencion;
        fetch c_get_retencion into v_valor_retencion;
        close c_get_retencion;

            v_descripcion_retencion :='COMPROBANTE DE PAGO RETENCIONES ASOCIACIONES Y OTROS (NO DEDUCIBLE IMP.RENTA)';

              plpdf.printcell   (p_w        => 150,
                                 p_txt      => v_descripcion_retencion,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_valor_retencion,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


        v_total_factura:=NVL(v_total,0)+NVL(v_valor_retencion,0);
        plpdf_cell.newline;


            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 6);
            plpdf.printcell     (p_w        => 80,
                                 p_txt      => 'Forma Pago:',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w        => 70,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w     =>50,
                                 p_txt   =>'',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf_cell.newline;

          plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

            v_total_pagos:=0;
            FOR fpago IN c_formapago     LOOP

                plpdf.printcell (p_w        => 60,
                                 p_txt      => fpago.descripcion,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 40,
                                 p_txt      => TO_CHAR (fpago.tzrfact_amnt_trans, l_num_mask),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>100,
                                 p_txt   =>' ',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

           v_total_pagos := v_total_pagos + NVL(fpago.tzrfact_amnt_trans,0);

            END LOOP;


             plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 6);

               plpdf.printcell  (p_w        => 60,
                                 p_txt      => 'TOTAL:',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 40,
                                 p_txt      => TO_CHAR (v_total_pagos, l_num_mask),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>100,
                                 p_txt   =>' ',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

        plpdf_cell.newline;

        plpdf_cell.init;
        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 6);

                 plpdf.printcell   (p_w        => 150,
                                 p_txt      => 'TOTAL A PAGAR',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_total_factura,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

                 plpdf.printcell  (p_w        => 75,
                                   p_h        => .3,
                                   p_txt      => '-',
                                   p_border   => '1',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'L',
                                   p_fill     => FALSE);

                  plpdf.printcell (p_w        => 40,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>75,
                                  p_h => .3,
                                  p_txt   =>'-',
                                  p_border =>'1',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>l_aligns_rigth,
                                  p_fill  =>FALSE
                                  );

                 plpdf.printcell  (p_w        => 75,
                                   p_h        => 6,
                                   p_txt      => 'Firma y Sello',
                                   p_border   => '0',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'C',
                                   p_fill     => FALSE);

                  plpdf.printcell (p_w        => 40,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>80,
                                  p_h => 6,
                                  p_txt   =>'Recibi Conforme',
                                  p_border =>'0',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>'C',
                                  p_fill  =>FALSE
                                  );

                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

                plpdf.printcell (p_w        => 0,            
                                 p_h =>     6,    
                                 p_txt      => tzkcone.f_get_dinamic_text(p_sede,'Pie de pagina factura', '1'), 
                                 p_border   => '0',                 
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',      
                                 p_fill     => FALSE 
                                );

                plpdf.printcell (p_w        => 0,             
                                 p_h =>     5,     
                                 p_txt      => tzkcone.f_get_dinamic_text(p_sede,'Pie de pagina factura', '2,3,4'), 
                                 p_border   => '0',                  
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',     
                                 p_fill     => FALSE 
                                );
        plpdf_cell.newline;
        plpdf_cell.newline;
        plpdf_cell.newline;
        plpdf_cell.newline;

        plpdf.senddoc (p_blob => l_pdf);

        IF p_web IS NULL THEN
            HTP.flush;
            HTP.init;
            --
            OWA_UTIL.mime_header ('application/pdf', FALSE);
            HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_pdf));
            OWA_UTIL.http_header_close;
            WPG_DOCLOAD.download_file (l_pdf);
        END IF;
    END p_show_fact;

PROCEDURE p_factura_masivo_pdf (p_one_up_no IN NUMBER)
    IS


TYPE gjbprun_rec IS RECORD
        (
            r_gjbprun_number    gjbprun.gjbprun_number%TYPE,
            r_gjbprun_value     gjbprun.gjbprun_value%TYPE,
            r_gjbprun_desc      gjbpdef.gjbpdef_desc%TYPE
        );


        TYPE gjbprun_ref IS REF CURSOR RETURN gjbprun_rec;

        ln_count           NUMBER;
        v_job_num          NUMBER := p_one_up_no;
        v_user_id_log      VARCHAR2 (50) := USER;
        v_job_ref          gjbprun_ref;
        v_job_rec          gjbprun_rec;
        v_env_nm_before    NUMBER;
        v_env_nm_after     NUMBER;
        v_line_cntr        NUMBER := 0;
        v_page_cntr        NUMBER := 0;
        v_file_number      guboutp.guboutp_file_number%TYPE;
        v_page_width       NUMBER;
        v_page_break       NUMBER;
        v_row_print        VARCHAR2 (1000);
        v_status           VARCHAR2 (10);
        v_comments         VARCHAR2 (20000);
        lv_out_error       VARCHAR2 (1000);


        p_filename varchar2(100);
        v_modo varchar2(1);
         v_campus varchar2(10);
         v_date_from date; 
         v_date_to date; 
         v_punto_emision number(4);
         v_correo VARCHAR2 (90) := NULL;
         v_params VARCHAR2 (500) := NULL;
         v_appl_id VARCHAR2 (30) := NULL;
         v_sel_id VARCHAR2 (30) := NULL; 
         v_creator_id VARCHAR2 (30) := NULL;
         v_user_id VARCHAR2 (30) := NULL;

        p_pidm          NUMBER;
        p_sri_docnum tzrfact.tzrfact_sri_docnum%TYPE;

       v_pidm number:=0;

        l_pdf                 BLOB;
        p_nombre_estudiante   VARCHAR2 (1000);
        p_web                 VARCHAR2 (1000);  
        p_doc_number          NUMBER;
        v_fecha_emision       DATE;
        v_email               goremal.goremal_email_address%TYPE; 
        v_total_venta_neta    NUMBER;   
        p_campus_number number (1);
         l_num_mask            VARCHAR2 (20) := 'L999G999G999D00';
        v_total_cargos        NUMBER;

v_tipo_iden           stvlgcy.stvlgcy_desc%TYPE;
v_iden                spbpers.spbpers_ssn%TYPE;
v_tipo_iden_sede           stvlgcy.stvlgcy_desc%TYPE;
v_iden_sede                spbpers.spbpers_ssn%TYPE;
v_id_estudiante       varchar2(20);
v_direccion           spraddr.spraddr_street_line1%TYPE;
v_dir_sede               spraddr.spraddr_street_line1%TYPE;
v_dir_city_sede      varchar2(50);
v_city varchar2(50);

p_emal_code varchar2(20);
p_emal_code_sede varchar2(20);
         p_sede          sovlcur.sovlcur_camp_code%TYPE;

        l_widths              plpdf_type.t_row_widths;      

        l_aligns_center       VARCHAR2 (2) := 'C';
        l_aligns_left         VARCHAR2 (2) := 'L';
        l_aligns_rigth        VARCHAR2 (2) := 'R';
        l_font_arial          NUMBER := 10;        
        l_font_courier        NUMBER := 8;        
        l_cell_courier        NUMBER := l_font_courier - 3.5;
        l_font_times          NUMBER := 14;
        l_cell_times          NUMBER := l_font_times - 8;


        v_periodo_prefactura  VARCHAR2 (6);
        v_tran_num            VARCHAR2 (20):='CANT';
        v_describe_detalle    VARCHAR2 (20):='DETALLE';
        v_valor_unitario      VARCHAR2 (20):='VALOR UNITARIO';
        v_valor_total         VARCHAR2 (20):='VALOR TOTAL';
        v_total_descuentos    NUMBER := 0;  

        v_total_pagos         NUMBER;

        v_descuento           NUMBER := 0; 
        v_descuento2          NUMBER := 0;  

        v_detalleivamayorcero VARCHAR2(40);
        v_valorivaestudiante  tzrfact.tzrfact_amnt_trans%TYPE;
        v_total               NUMBER := 0;  
        v_valor_retencion       NUMBER := 0;
        v_descripcion_retencion VARCHAR2 (200);
        v_total_factura         NUMBER := 0;    
        p_pidm_sede        spriden.spriden_pidm%TYPE;
        v_resolucionimpuestos   VARCHAR2 (300);
        v_rucsede               VARCHAR2 (300);
        v_direccionsede         VARCHAR2 (200);
        v_telefenosede          VARCHAR2 (200);
        v_emailsede             VARCHAR2 (200);
        v_cajero                tzrfact.tzrfact_user%TYPE;

        v_carreraestudiante     tzrfact.tzrfact_curr_program%TYPE;
       v_telefono sprtele.sprtele_phone_number%type;

       v_party_id  TZRFACT.TZRFACT_TRDPARTY_ID%type;
       v_party_pidm TZRFACT.TZRFACT_TRDPARTY_PIDM%type;
       v_party_name TZRFACT.TZRFACT_TRDPARTY_NAME%type;



cursor c_masivo (p_campus varchar2, p_date_from date, p_date_to date, p_punto_emision number, p_appl_id varchar2, p_sel_id varchar2, p_creator_id varchar2, p_user_id varchar2) is
select distinct TZRFACT_PIDM, TZRFACT_ID, TZRFACT_DOC_NUMBER, TZRFACT_SRI_DOCNUM 
from tzrfact  
where TZRFACT_CAMPUS   = p_campus
    and TZRFACT_SDOC_CODE = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where gtvsdax_internal_code_group = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_FACT')
    and trunc(TZRFACT_FACT_DATE) between trunc(TO_DATE(p_date_from,G$_DATE.GET_NLS_DATE_FORMAT)) and trunc(trunc(TO_DATE(p_date_to,G$_DATE.GET_NLS_DATE_FORMAT)))
    and TZRFACT_SRI_DOCNUM is not null
    and substr(TZRFACT_SRI_DOCNUM,5,3) = p_punto_emision    
    and TZRFACT_FACT_CANCEL_IND  is null
    and  (CASE WHEN p_appl_id IS NOT NULL  AND EXISTS
                                      (SELECT 1
                                         FROM glbextr
                                        WHERE     glbextr_application =  p_appl_id
                                              AND glbextr_selection = p_sel_id
                                              AND glbextr_creator_id = p_creator_id
                                              AND glbextr_user_id = p_user_id
                                              AND glbextr_key =  tzrfact_pidm)
                                  THEN 1
                                           WHEN p_appl_id IS NULL  then 1
                                  else 0
             end       
           ) = 1
order by TZRFACT_SRI_DOCNUM           
;




 cursor c_get_data (p_pidm number, p_sri_docnum varchar2) is 
        select  TZRFACT_TERM_CODE , tzrfact_doc_number,tzrfact_fact_date,  TZRFACT_CAMPUS, SUBSTR(tzrfact_sale_docnum,7,1) campus_number, tzrfact_curr_program, tzrfact_user  
                  ,TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME
                  , tzrfact_pidm, tzrfact_sri_docnum
        from tzrfact where tzrfact_pidm = p_pidm 
        and TZRFACT_SDOC_CODE = (select GTVSDAX_EXTERNAL_CODE from gtvsdax where gtvsdax_internal_code_group = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_FACT')
        and tzrfact_sri_docnum =  p_sri_docnum;

 cursor c_get_data_sede (p_campus_number number) is 
SELECT gb_common.f_get_pidm ( gtvsdax_external_code) pidm_sede, gtvsdax_comments 
                FROM  gtvsdax 
                WHERE gtvsdax_internal_code ='ID_PUCE' 
                AND   gtvsdax_internal_code_group='PUCE_FACT'
                AND   gtvsdax_translation_code= p_campus_number;

CURSOR c_nombre_completo (p_pidm number)
IS
    SELECT    REPLACE (spriden_last_name, '/', ' ')
    || ' '|| spriden_first_name|| ' '|| spriden_mi complete_name
    FROM spriden
    WHERE spriden_change_ind IS NULL 
    AND spriden_pidm = p_pidm;

CURSOR c_identificacion (p_pidm number)
IS
    SELECT (
    SELECT stvlgcy_desc
    FROM stvlgcy
    WHERE stvlgcy_code = spbpers_lgcy_code
    ) tipo_identificacion, spbpers_ssn  identificacion
    FROM spbpers
    WHERE spbpers_pidm =  p_pidm
    AND ROWNUM=1;

CURSOR c_cargos (p_pidm number, p_sri_docnum varchar2)
IS 
SELECT  tzrfact_stperdoc_qty 
           , tzrfact_det_code_doc
           , f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion
          , sum(tzrfact_amnt_trans) as tzrfact_amnt_trans
          ,tzrfact_crn_contnd
          ,tzrfact_term_code 
FROM  tzrfact, tbbdetc 
WHERE tzrfact_det_code_doc = tbbdetc_detail_code
and tbbdetc_dcat_code not in ('TAX','TER','FNA')
AND tbbdetc_type_ind='C'
and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_FACT','COD_PREF') )
AND   tzrfact_pidm     =  p_pidm 
AND   tzrfact_sri_docnum =  p_sri_docnum
GROUP BY tzrfact_stperdoc_qty ,
          tzrfact_det_code_doc,
          tzrfact_crn_contnd,tzrfact_term_code;                               


cursor c_get_descuento1  (p_pidm number, p_sri_docnum varchar2) is
                        SELECT  SUM(tzrfact_amnt_trans)                        
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_FACT','COD_PREF')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_sri_docnum    =  p_sri_docnum
                        AND   tzrfact_det_code_doc  IN  (
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code LIKE '1%'
                                                        );

cursor c_get_descuento2 (p_pidm number, p_sri_docnum varchar2) is
                        SELECT  SUM(tzrfact_amnt_trans)
                        FROM  tzrfact 
                        WHERE tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                        FROM   gtvsdax 
                                                        WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                        AND gtvsdax_internal_code IN( 'COD_FACT','COD_PREF')
                                                         )
                        AND   tzrfact_pidm          =  p_pidm 
                        AND   tzrfact_sri_docnum    =  p_sri_docnum
                        AND   tzrfact_det_code_doc  IN  ((
                                                        SELECT kvrfbse_dflt_detail_code 
                                                        FROM   kvrfbse 
                                                        WHERE kvrfbse_fndc_code NOT LIKE '1%'
                                                        )
                                                        UNION
                                                        (
                                                         select TBBDETC_DETAIL_CODE from TBBDETC 
                                                         WHERE TBBDETC_DCAT_CODE IN ('BEC','DES')
                                                         AND    tbbdetc_type_ind = 'P'
                                                         AND TBBDETC_DETAIL_CODE NOT IN (
                                                         SELECT kvrfbse_dflt_detail_code 
                                                         FROM   kvrfbse 
                                                         WHERE kvrfbse_fndc_code  LIKE '1%')
                                                        )
                                                        );


CURSOR c_formapago (p_pidm number, p_sri_docnum varchar2)
IS
SELECT 
       f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion, 
       sum(tzrfact_amnt_trans ) tzrfact_amnt_trans 
FROM   tzrfact
where
   tzrfact_sdoc_code    IN (SELECT gtvsdax_external_code
                                FROM   gtvsdax 
                                WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                AND gtvsdax_internal_code =  'COD_FACT'
                                )
AND    tzrfact_pidm         =  p_pidm 
AND    tzrfact_sri_docnum   =  p_sri_docnum
group by        TZRFACT_DET_CODE_DOC;



CURSOR c_totalivas (p_pidm number, p_sri_docnum varchar2)   is
SELECT tbbdetc_detail_code, 
               'TOTAL GRAVADO CON ' ||tbbdetc_desc detalle, 
               tbbdetc_type_ind, 
               tbbdetc_dcat_code,
               SUBSTR(tbbdetc_desc,INSTR(tbbdetc_desc,' ')+1,( INSTR(tbbdetc_desc,'%')-INSTR(tbbdetc_desc,' ') )-1 ) iva
            ,(
            nvl((
                SELECT 
                             tzrfact_stperdoc_qty *				
                             sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and tbbdetc_dcat_code not in ('TAX','TER','FNA')
                AND tbbdetc_type_ind='C'
                and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_FACT','COD_PREF') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                AND   tzrfact_pidm     =  p_pidm 
                AND   tzrfact_sri_docnum =  p_sri_docnum
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE
				GROUP BY tzrfact_stperdoc_qty ,
				--tzrfact_det_code_doc,
				tzrfact_crn_contnd,tzrfact_term_code				
				),0)

				-
                nvl((SELECT         
                             sum(tzrfact_amnt_trans) as tzrfact_amnt_trans          
                FROM  tzrfact, tbbdetc, tvrdctx 
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                and tbbdetc_dcat_code  in ('BEC','DES')
                AND tbbdetc_type_ind='P'
                and tzrfact_sdoc_code  IN (SELECT gtvsdax_external_code   FROM   gtvsdax WHERE gtvsdax_internal_code_group = 'PUCE_FACT'  AND gtvsdax_internal_code in ('COD_FACT','COD_PREF') )
                and tzrfact_det_code_doc = TVRDCTX_DETC_CODE
                and tvrdctx_txpr_code IS NOT NULL
                AND   tzrfact_pidm     =  p_pidm 
                AND   tzrfact_sri_docnum =  p_sri_docnum
                and TVRDCTX_TXPR_CODE = iva.TBBDETC_DETAIL_CODE) ,0)
                ) valor
        FROM tbbdetc iva
        WHERE iva.tbbdetc_dcat_code='TAX'
        AND iva.tbbdetc_type_ind='C'
        AND iva.TBBDETC_DETAIL_CODE
        IN (
            SELECT TVRDCTX_TXPR_CODE
            FROM tvrdctx 
            WHERE tvrdctx_txpr_code IS NOT NULL
            ) ;


      CURSOR c_direccion (p_pidm number) IS
        SELECT spraddr_street_line1, spraddr_city
        FROM spraddr
        WHERE spraddr_pidm = p_pidm
        AND ROWNUM < 2;

      CURSOR c_email (p_pidm number, p_emal_code varchar2) IS
        SELECT goremal_email_address 
        FROM   goremal
        WHERE  goremal_pidm=p_pidm
        AND    goremal_emal_code = p_emal_code;


             CURSOR c_smtp
        IS
            SELECT gtvsdax_external_code, gtvsdax_desc
            FROM gtvsdax
            WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
            AND gtvsdax_internal_code = 'SMTP';

            cursor c_telefono (p_pidm number) is
            SELECT sprtele_phone_number             
            FROM   sprtele 
            WHERE  sprtele_pidm = p_pidm_sede;

    cursor c_get_retencion (p_pidm number, p_sri_docnum varchar2) is          
                SELECT   SUM(tzrfact_amnt_trans)  valorretencion
                FROM    tzrfact, tbbdetc
                WHERE tzrfact_det_code_doc = tbbdetc_detail_code
                     and  tbbdetc_dcat_code = 'TER'
                    AND tbbdetc_type_ind = 'C'
                     and tzrfact_sdoc_code IN (SELECT gtvsdax_external_code
                                              FROM   gtvsdax 
                                              WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                              AND gtvsdax_internal_code IN ( 'COD_FACT','COD_PREF')
                                              )
                    AND tzrfact_pidm        =p_pidm
                    AND tzrfact_sri_docnum  =p_sri_docnum ;



cursor c_get_ivamayorcero (p_pidm number, p_sri_docnum varchar2) is
                SELECT  
                'VALOR DEL ' ||      f_get_ar_desc ('TBBDETC', tzrfact_det_code_doc, 60) descripcion,
                tzrfact.tzrfact_amnt_trans                
                FROM    tzrfact 
                WHERE   tzrfact.tzrfact_sdoc_code     IN (SELECT gtvsdax_external_code
                                                          FROM   gtvsdax 
                                                          WHERE gtvsdax_internal_code_group = 'PUCE_FACT' 
                                                          AND gtvsdax_internal_code IN( 'COD_FACT','COD_PREF')
                                                          )
                AND     tzrfact.tzrfact_pidm          = p_pidm
                AND     tzrfact.tzrfact_sri_docnum    =  p_sri_docnum
                AND     tzrfact.tzrfact_det_code_doc  IN   (
                                                            SELECT iva.tvrdctx_txpr_code 
                                                            FROM tvrdctx iva
                                                            WHERE  iva.tvrdctx_txpr_code IS NOT NULL
                                                            )
                AND tzrfact.tzrfact_amnt_trans>0                
                and rownum = 1
                ORDER BY tzrfact.tzrfact_det_code_doc;



cursor c_get_mail_send is
            SELECT GTVSDAX_DESC
              FROM gtvsdax
             WHERE     gtvsdax_internal_code_group = 'PUCE_FACT'
                   AND gtvsdax_internal_code = 'EMAL_CODE';

m_port varchar2(10); 
m_host varchar2(50) ;
m_from varchar2(90) ;

    BEGIN

    tzkpufc.p_create_header (p_one_up_no,
                           v_user_id_log,
                           v_file_number,
                           'TZPFMAS');

        v_page_width :=  gokeacc.f_getgtvsdaxextcode ('R_WIDTH', 'REPORTS_LIS');

        v_page_break :=  gokeacc.f_getgtvsdaxextcode ('R_PAGE_BRK', 'REPORTS_LIS');

        OPEN v_job_ref FOR
              SELECT gjbprun_number, gjbprun_value, gjbpdef_desc
                FROM gjbprun, gjbpdef
               WHERE     gjbprun_one_up_no = p_one_up_no
                     AND gjbprun_job = 'TZPFMAS'
                     AND gjbpdef_job = gjbprun_job
                     AND gjbpdef_number = gjbprun_number
            ORDER BY gjbprun_number ASC;

        LOOP
            FETCH v_job_ref INTO v_job_rec;
            EXIT WHEN v_job_ref%NOTFOUND; 

            gz_report.p_put_line (
                p_one_up_no =>    p_one_up_no,
                p_user =>    v_user_id_log,
                p_job_name =>   'TZPFMAS',
                p_file_number =>     NVL (v_file_number, 1),
                p_content_line =>  v_job_rec.r_gjbprun_number
                    || ' - '
                    || v_job_rec.r_gjbprun_desc
                    || ' - '
                    || v_job_rec.r_gjbprun_value
                    || '.',
                p_content_width =>    v_page_width,
                p_content_align =>      'LEFT', 
                p_status =>       v_status,
                p_comments =>    v_comments);


            CASE v_job_rec.r_gjbprun_number
                WHEN '01'     THEN
                    v_campus := v_job_rec.r_gjbprun_value;
                WHEN '02'     THEN
                    v_date_from := v_job_rec.r_gjbprun_value;    
                WHEN '03'       THEN
                    v_date_to := v_job_rec.r_gjbprun_value;
                WHEN '04'       THEN
                    v_punto_emision := v_job_rec.r_gjbprun_value;
                WHEN '05'       THEN
                    v_correo := v_job_rec.r_gjbprun_value;
                WHEN '06'       THEN
                    v_modo := v_job_rec.r_gjbprun_value;    
                WHEN '07'        THEN
                    v_sel_id := v_job_rec.r_gjbprun_value;
                WHEN '08'        THEN
                    v_appl_id := v_job_rec.r_gjbprun_value;
                WHEN '09'        THEN
                    v_creator_id := v_job_rec.r_gjbprun_value;
                WHEN '10'        THEN
                    v_user_id := v_job_rec.r_gjbprun_value;                
                ELSE
                    NULL;
            END CASE;
        END LOOP;
        CLOSE v_job_ref;



     IF v_modo = 'U' then
        p_filename := 'tzpfmas_'||to_char(sysdate,'DDMMYY_HH24MISS');

        OPEN c_get_data_i ('PUCE_FACT', 'URL_PAY', 'COM');
        FETCH c_get_data_i INTO p_url;
        CLOSE c_get_data_i;

        p_url := p_url ||'tzkpufc.p_get_pdf_masivo?p_filename=' || p_filename;


       gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                              p_user            => v_user_id_log,
                              p_job_name        => 'TZPFMAS',
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => 'Liga de descarga: '||p_url,
                              p_content_width   => v_page_width,
                              p_content_align   => 'LEFT',
                              p_status          => v_status,
                              p_comments        => v_comments);

       END IF;                       

        gz_report.p_put_line (
            p_one_up_no       => p_one_up_no,
            p_user            => v_user_id_log,
            p_job_name        => 'TZPFMAS',
            p_file_number     => NVL (v_file_number, 1),
            p_content_line    => LPAD (' ', v_page_width, '-'),
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',
            p_status          => v_status,
            p_comments        => v_comments);

           v_row_print :=
                gz_report.f_colum_format ('ID Alumno', 10, 'CENTER',  ' | ')
            || gz_report.f_colum_format ('Nombre',  30, 'CENTER', ' | ')            
            || gz_report.f_colum_format ('Prefactura', 20,'LEFT', ' | ')
            || gz_report.f_colum_format ('Factura', 20, 'LEFT',  ' | ')        
            || gz_report.f_colum_format ('Fecha', 20, 'LEFT',  ' | ')        
           ;


        gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                              p_user            => v_user_id_log,
                              p_job_name        => 'TZPFMAS',
                              p_file_number     => NVL (v_file_number, 1),
                              p_content_line    => v_row_print,
                              p_content_width   => v_page_width,
                              p_content_align   => 'LEFT',
                              p_status          => v_status,
                              p_comments        => v_comments);

                ln_count := 0;


plpdf.init (p_orientation   => plpdf_const.portrait,
                    p_unit          => plpdf_const.mm,
                    p_format        => 'letter');


for rec in c_masivo (v_campus , v_date_from , v_date_to , v_punto_emision ,  v_appl_id , v_sel_id , v_creator_id , v_user_id ) loop

            IF c_masivo%NOTFOUND
            THEN

                gz_report.p_put_line (
                    p_one_up_no       => p_one_up_no,
                    p_user            => v_user_id_log,
                    p_job_name        => 'TZPFMAS',
                    p_file_number     => NVL (v_file_number, 1),
                    p_content_line    => LPAD (' ', v_page_width, ' '),
                    p_content_width   => v_page_width,
                    p_content_align   => 'LEFT',
                    p_status          => v_status,
                    p_comments        => v_comments);

                gz_report.p_put_line (
                    p_one_up_no =>                        p_one_up_no,
                    p_user =>                        v_user_id_log,
                    p_job_name =>                        'TZPFMAS',
                    p_file_number =>                        NVL (v_file_number, 1),
                    p_content_line =>                        'TZPFMAS - No registros con los parametros ingresados.',
                    p_content_width =>                        v_page_width,
                    p_content_align =>                        'LEFT',   
                    p_status =>                        v_status,
                    p_comments =>                        v_comments);

                EXIT;
                ln_count := 0;
                GOTO end_process;
            END IF;

    BEGIN

       IF   v_modo = 'U' then                      
        BEGIN    

        v_email := '';
        v_direccion := ''; 
        v_city := '';
        v_tipo_iden := ''; 
        v_iden := '';
        p_nombre_estudiante := '';
        v_telefono := '';
        v_party_pidm := '';
        v_emailsede := '';
        p_pidm := '';
        v_periodo_prefactura:= '';
        p_doc_number := ''; 
        v_fecha_emision := ''; 
        p_sede := '';
        p_campus_number := ''; 
        v_carreraestudiante := '';
        v_cajero:= ''; 
        v_party_id := '';
        v_party_name:= '';
        p_sri_docnum:= '';

        OPEN c_get_data(rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM);
        FETCH c_get_data INTO v_periodo_prefactura,p_doc_number, v_fecha_emision, p_sede, p_campus_number, v_carreraestudiante, v_cajero, v_party_id,v_party_pidm,v_party_name
        , p_pidm, p_sri_docnum;
        CLOSE c_get_data;

       open c_get_data_sede (p_campus_number) ;
       fetch c_get_data_sede into p_pidm_sede, v_resolucionimpuestos;
       close c_get_data_sede;

       OPEN  c_identificacion(p_pidm_sede);
        FETCH c_identificacion INTO v_tipo_iden_sede, v_iden_sede;
        CLOSE c_identificacion;

       v_rucsede := v_tipo_iden_sede||': '|| v_iden_sede;

        OPEN c_get_data_i ('PUCE_FACT', 'ID_PUCE', 'EXT');
        FETCH c_get_data_i INTO p_id_puce;
        CLOSE c_get_data_i;

       OPEN c_direccion(p_pidm_sede);
        FETCH c_direccion  INTO v_dir_sede, v_dir_city_sede ;
        CLOSE c_direccion;  

        v_direccionsede := 'Dirección: '||v_dir_sede||' '||v_dir_city_sede ;        

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_CODE', 'EXT');
        FETCH c_get_data_i INTO p_emal_code;
        CLOSE c_get_data_i;

        OPEN c_get_data_i ('PUCE_FACT', 'EMAL_INST', 'EXT');
        FETCH c_get_data_i INTO p_emal_code_sede;
        CLOSE c_get_data_i;

        OPEN   c_email (p_pidm_sede, p_emal_code_sede);
        FETCH  c_email INTO   v_emailsede;
        CLOSE  c_email;


        OPEN c_telefono(p_pidm_sede);
        FETCH c_telefono
        INTO v_telefono ;
        CLOSE c_telefono;  

         v_telefenosede := 'Teléfonos: '||v_telefono;


       IF v_party_pidm is null then
           v_pidm := p_pidm;
        ELSE
           v_pidm := v_party_pidm;
       END IF;

        OPEN c_nombre_completo (v_pidm );
        FETCH c_nombre_completo INTO p_nombre_estudiante;
        CLOSE c_nombre_completo;

        OPEN  c_identificacion(v_pidm);
        FETCH c_identificacion INTO v_tipo_iden, v_iden;
        CLOSE c_identificacion;

        OPEN c_direccion(v_pidm);
        FETCH c_direccion    INTO v_direccion, v_city;
        CLOSE c_direccion;  

        OPEN   c_email (v_pidm, p_emal_code);
        FETCH  c_email INTO   v_email;
        CLOSE  c_email;

        IF v_email is null then
            OPEN   c_email (v_pidm, p_emal_code_sede);
            FETCH  c_email INTO   v_email;
            CLOSE  c_email;
        END IF;




        plpdf.newpage;

        plpdf.setprintfont (p_family => 'Arial',  p_size => 6);
        plpdf_cell.newline;

                    plpdf.printcell(p_w      => 200,
                    p_txt    => f_format_name (p_pidm_sede, 'L60'),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);



        plpdf.printcell( p_w      => 40,
                    p_txt    => v_rucsede,
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => l_aligns_left,
                    p_fill   => FALSE);

        plpdf.printcell(p_w      => 80,
                        p_txt    => ' ' ,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 80,
                        p_txt    => 'Nro Factura. ' ||p_sri_docnum,
                        p_border => '1',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_center,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => v_direccionsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);



        plpdf.printcell(p_w        => 200,
                        p_txt    => v_telefenosede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => 'Email: ' ||v_emailsede,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w        => 200,
                        p_txt    =>tzkcone.f_get_dinamic_text(p_sede,'Encabezado factura', '1,2'),
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 200,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.setprintfont (p_family => 'Arial', p_size => 6);



        plpdf_cell.newline;

     plpdf.printcell(p_w     => 200,
                    p_txt    => 'Cliente: ' || p_nombre_estudiante,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => plpdf3.c_right,
                    p_fill   => FALSE);

     plpdf.printcell(p_w     => 200,
                    p_txt    => 'Código: ' || gb_common.f_get_id(v_pidm),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w     => 200,
                    p_txt    =>  'RUC/CI: '  ||v_iden,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


     plpdf.printcell(p_w        => 200,
                    p_txt    => 'Dirección: ' || v_direccion,
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);



     plpdf.printcell(p_w        => 200,
                    p_txt    => 'Facultad y Carrera: ' || BWCKCAPP.get_program_desc(v_carreraestudiante),
                    p_border => '0',
                    p_ln     => plpdf_const.newline,
                    p_align  => 'L',
                    p_fill   => FALSE);


      plpdf.printcell(p_w   => 40,
                    p_txt   => 'Fecha: ' ||
                                    NVL(TO_CHAR(v_fecha_emision,'DD/MM/YYYY'), 
                                    TO_CHAR(SYSDATE,'DD/MM/YYYY')),
                    p_border => '0',
                    p_ln     => plpdf_const.beside,
                    p_align  => 'L',
                    p_fill   => FALSE);


        plpdf.printcell(p_w        => 140,
                        p_txt    => 'Email: ' ||v_email,
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.printcell(p_w        => 40,
                        p_txt    => ' ' ,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


           plpdf.printcell(p_w   => 40,
                           p_txt   => ' ' ,
                           p_border => '0',
                           p_ln     => plpdf_const.beside,
                           p_align  => 'L',
                           p_fill   => FALSE);

          plpdf.printcell(p_w        => 90,
                        p_txt    => ' ',
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => 'L',
                        p_fill   => FALSE);

           plpdf.printcell(p_w        => 70,
                        p_txt    => 'Cajero: ' ||v_cajero,
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);


        plpdf.printcell(p_w      => 40,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 90,
                        p_txt    => '',
                        p_border => '0',
                        p_ln     => plpdf_const.beside,
                        p_align  => l_aligns_left,
                        p_fill   => FALSE);

        plpdf.printcell(p_w      => 70,
                        p_txt    => 'Comprobante Nro:' ||tzkpufc.f_get_docnum_fmt(p_doc_number),
                        p_border => '0',
                        p_ln     => plpdf_const.newline,
                        p_align  => 'L',
                        p_fill   => FALSE);

        plpdf_cell.printcell (p_width => 200,
                             p_text => '' 
                             );

        plpdf_cell.newline;
        plpdf_cell.init;

            v_total_venta_neta:=0;
            v_total_cargos := 0;
            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 8);


            plpdf.printcell (p_w        => 20,
                             p_txt      => v_tran_num,
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);

              plpdf.printcell   (p_w        => 80,
                                 p_txt      => v_describe_detalle,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_unitario,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>v_valor_total,
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'C',
                                 p_fill  =>FALSE
                                 );

        plpdf_cell.newline;
        plpdf.setprintfont (p_family   => 'Arial',p_size     => 6);


        FOR chrg IN c_cargos (rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM)    LOOP
            plpdf.printcell (p_w        => 20,
                             p_txt      => nvl(chrg.tzrfact_stperdoc_qty,1),
                             p_border   => '1',
                             p_ln       => plpdf_const.beside,
                             p_align    => 'C',
                             p_fill     => FALSE);


                plpdf.printcell (p_w        => 80,
                                 p_txt      => tzkcone.f_get_title_ed_con(chrg.tzrfact_term_code,chrg.tzrfact_crn_contnd,chrg.descripcion),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);
                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.beside,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

               v_total_cargos := v_total_cargos + chrg.tzrfact_amnt_trans*nvl(chrg.tzrfact_stperdoc_qty,1);

            END LOOP;

            plpdf_cell.newline;
            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 6);
            plpdf.printcell     (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w        => 70,
                                 p_txt      => 'SUBTOTAL',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w     =>50,
                                 p_txt   =>TO_CHAR (v_total_cargos, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf_cell.newline;

                plpdf.setprintfont (p_family   => 'Arial',p_size     => 6);

                open c_get_descuento1 (rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM);
                fetch c_get_descuento1 into v_descuento;
                close c_get_descuento1;

                plpdf.printcell (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'DESCUENTO 1',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_descuento,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                open c_get_descuento2 (rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM);
                fetch c_get_descuento2 into v_descuento2;
                close c_get_descuento2;

                plpdf.printcell (p_w        => 80,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'DESCUENTO 2',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);


                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_descuento2,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

           v_total_descuentos := NVL(v_descuento,0) + NVL(v_descuento2,0);
           v_total_venta_neta:=v_total_cargos-v_total_descuentos;


           plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'TOTAL VENTA NETA',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (v_total_venta_neta, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );




            FOR fivas IN c_totalivas  (rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM)   LOOP

                plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => fivas.detalle,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (ABS(fivas.valor), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );
          END LOOP;

v_valorivaestudiante := 0;

open c_get_ivamayorcero (rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM);
fetch c_get_ivamayorcero into v_detalleivamayorcero  ,v_valorivaestudiante;
close c_get_ivamayorcero;


                plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => nvl(v_detalleivamayorcero,'VALOR DEL IVA 12%'),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_valorivaestudiante,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );



           v_total:=NVL(v_total_cargos,0)-NVL(v_total_descuentos,0)+NVL(v_valorivaestudiante,0);

           plpdf.printcell  (p_w        => 80,
                                 p_txt      => ' ',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 70,
                                 p_txt      => 'TOTAL',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (v_total, l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


           plpdf.setprintfont (p_family => 'Arial',  p_size => 6);
       plpdf_cell.newline;

        open c_get_retencion(rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM);
        fetch c_get_retencion into v_valor_retencion;
        close c_get_retencion;

            v_descripcion_retencion :='COMPROBANTE DE PAGO RETENCIONES ASOCIACIONES Y OTROS (NO DEDUCIBLE IMP.RENTA)';

              plpdf.printcell   (p_w        => 150,
                                 p_txt      => v_descripcion_retencion,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_valor_retencion,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );


        v_total_factura:=NVL(v_total,0)+NVL(v_valor_retencion,0);
        plpdf_cell.newline;


            plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 6);
            plpdf.printcell     (p_w        => 80,
                                 p_txt      => 'Forma Pago:',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w        => 70,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

            plpdf.printcell     (p_w     =>50,
                                 p_txt   =>'',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

                plpdf_cell.newline;

          plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

            v_total_pagos:=0;
            FOR fpago IN c_formapago  (rec.TZRFACT_PIDM, rec.TZRFACT_SRI_DOCNUM)   LOOP

                plpdf.printcell (p_w        => 60,
                                 p_txt      => fpago.descripcion,
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 40,
                                 p_txt      => TO_CHAR (fpago.tzrfact_amnt_trans, l_num_mask),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>100,
                                 p_txt   =>' ',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

           v_total_pagos := v_total_pagos + NVL(fpago.tzrfact_amnt_trans,0);

            END LOOP;


             plpdf.setprintfont (p_family => 'Arial', p_style    => 'B', p_size => 6);

               plpdf.printcell  (p_w        => 60,
                                 p_txt      => 'TOTAL:',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w        => 40,
                                 p_txt      => TO_CHAR (v_total_pagos, l_num_mask),
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>100,
                                 p_txt   =>' ',
                                 p_border =>'0',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );

        plpdf_cell.newline;

        plpdf_cell.init;
        plpdf.setprintfont (p_family => 'Arial', p_style => 'B', p_size => 6);

                 plpdf.printcell   (p_w        => 150,
                                 p_txt      => 'TOTAL A PAGAR',
                                 p_border   => '1',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'L',
                                 p_fill     => FALSE);

                plpdf.printcell (p_w     =>50,
                                 p_txt   =>TO_CHAR (NVL(v_total_factura,0), l_num_mask),
                                 p_border =>'1',
                                 p_ln    =>plpdf_const.newline,
                                 p_align =>'L',
                                 p_fill  =>FALSE
                                 );



                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

                 plpdf.printcell  (p_w        => 75,
                                   p_h        => .3,
                                   p_txt      => '-',
                                   p_border   => '1',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'L',
                                   p_fill     => FALSE);

                  plpdf.printcell (p_w        => 40,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>75,
                                  p_h => .3,
                                  p_txt   =>'-',
                                  p_border =>'1',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>l_aligns_rigth,
                                  p_fill  =>FALSE
                                  );

                 plpdf.printcell  (p_w        => 75,
                                   p_h        => 6,
                                   p_txt      => 'Firma y Sello',
                                   p_border   => '0',
                                   p_ln       => plpdf_const.beside,
                                   p_align    => 'C',
                                   p_fill     => FALSE);

                  plpdf.printcell (p_w        => 40,
                                 p_txt      => '',
                                 p_border   => '0',
                                 p_ln       => plpdf_const.beside,
                                 p_align    => 'C',
                                 p_fill     => FALSE);

                  plpdf.printcell (p_w     =>80,
                                  p_h => 6,
                                  p_txt   =>'Recibi Conforme',
                                  p_border =>'0',
                                  p_ln    =>plpdf_const.newline,
                                  p_align =>'C',
                                  p_fill  =>FALSE
                                  );

                 plpdf_cell.newline;
                 plpdf_cell.newline;
                 plpdf_cell.newline;

                 plpdf.setprintfont (p_family => 'Arial',  p_size => 6);

                plpdf.printcell (p_w        => 0,             
                                 p_h =>     6,     
                                 p_txt      => tzkcone.f_get_dinamic_text(p_sede,'Pie de pagina factura', '1'),
                                 p_border   => '0',                 
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',      
                                 p_fill     => FALSE 
                                );

                plpdf.printcell (p_w        => 0,            
                                 p_h =>     5,    
                                 p_txt      => tzkcone.f_get_dinamic_text(p_sede,'Pie de pagina factura', '2,3,4'),  
                                 p_border   => '0',                 
                                 p_ln       => plpdf_const.newline, 
                                 p_align    => 'L',      
                                 p_fill     => FALSE 
                                );
        plpdf_cell.newline;
        plpdf_cell.newline;
        plpdf_cell.newline;
        plpdf_cell.newline;



v_row_print :=
                               gz_report.f_colum_format ( rec.TZRFACT_ID, 9,  'LEFT',     '  | ')
                           || gz_report.f_colum_format ( f_format_name (rec.TZRFACT_PIDM, 'FMIL'),  30,   'LEFT',  '  | ')
                           || gz_report.f_colum_format (rec.TZRFACT_DOC_NUMBER, 20,  'LEFT',    '  | ')
                            || gz_report.f_colum_format (rec.TZRFACT_SRI_DOCNUM, 20, 'LEFT',  '  | ')
                            || gz_report.f_colum_format (v_fecha_emision, 20, 'LEFT',  '  | ')
                            ;

gz_report.p_put_line (
                            p_one_up_no       => p_one_up_no,
                            p_user            => v_user_id_log,
                            p_job_name        => 'TZPFMAS',
                            p_file_number     => NVL (v_file_number, 1),
                            p_content_line    => v_row_print,
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', 
                            p_status          => v_status,
                            p_comments        => v_comments);                            

                EXCEPTION
                        WHEN OTHERS
                        THEN
                            gz_report.p_put_line (
                                p_one_up_no =>   p_one_up_no,
                                p_user =>      v_user_id_log,
                                p_job_name =>   'TZPFMAS',
                                p_file_number =>    NVL (v_file_number, 1),
                                p_content_line =>     'Error con el ID:'||rec.TZRFACT_ID||'-' ||rec.TZRFACT_SRI_DOCNUM||'-'|| SQLCODE   || '--'  || SUBSTR (SQLERRM, 1, 500),
                                p_content_width =>                          v_page_width,
                                p_content_align =>     'LEFT',   
                                p_status =>             v_status,
                                p_comments =>     v_comments);

                    END;

ELSE
v_row_print :=
                               gz_report.f_colum_format ( rec.TZRFACT_ID, 9,  'LEFT',     '  | ')
                           || gz_report.f_colum_format ( f_format_name (rec.TZRFACT_PIDM, 'FMIL'),  30,   'LEFT',  '  | ')
                           || gz_report.f_colum_format (rec.TZRFACT_DOC_NUMBER, 20,  'LEFT',    '  | ')
                            || gz_report.f_colum_format (rec.TZRFACT_SRI_DOCNUM, 20, 'LEFT',  '  | ')
                            || gz_report.f_colum_format (v_fecha_emision, 20, 'LEFT',  '  | ') 
                            ;

gz_report.p_put_line (
                            p_one_up_no       => p_one_up_no,
                            p_user            => v_user_id_log,
                            p_job_name        => 'TZPFMAS',
                            p_file_number     => NVL (v_file_number, 1),
                            p_content_line    => v_row_print,
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', 
                            p_status          => v_status,
                            p_comments        => v_comments);                            

    END IF; 

                ln_count := ln_count + 1;
                        EXCEPTION   WHEN OTHERS       THEN
                                lv_out_error :=   SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

            END;

end loop;


IF   v_modo = 'U' then

        plpdf.senddoc (p_blob => l_pdf);


        v_params := 'Campus: '||v_campus  || ' Fecha_desde: '|| v_date_from || ' Fecha_hasta: '|| v_date_to || ' Punto_emision: '|| v_punto_emision  || ' Appl: '|| v_appl_id || ' Sel_Id: '|| v_sel_id || ' Creator_id: '|| v_creator_id || ' User_id: '|| v_user_id;

     INSERT INTO tzrfmas (tzrfmas_filename, tzrfmas_desc, tzrfmas_pdf, tzrfmas_user, tzrfmas_activity_date)  
     VALUES ( p_filename
                    , v_params
                    ,l_pdf
                    ,user
                    ,sysdate);

IF v_correo is not null then        
        OPEN c_smtp;
        FETCH c_smtp INTO m_port, m_host;
        CLOSE c_smtp;

        OPEN c_get_mail_send;
        FETCH c_get_mail_send INTO m_from;
        CLOSE c_get_mail_send;
    begin
	send_mail (
                    p_to =>  v_correo,
                    p_from => m_from,
                    p_subject => 'TZPFMAS Facturación Masiva '||p_filename,
                    p_text_msg => 'Se adjunta archivo PDF masivo de facturas.'|| chr(10)|| chr(10)||'Parámetros utilizados:'|| chr(10)||v_params,
                    p_attach_name => p_filename || '.pdf',
                    p_attach_mime => 'application/pdf',
                    p_attach_blob =>  l_pdf,
                    p_smtp_host =>  m_host,
                    p_smtp_port =>  m_port);
    exception when others then null;
    end;
END IF;


tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_MASIVA', 'URL', p_url, user);


END IF;

-------------------------------------------------------

tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_MASIVA', 'Parametros', 'Campus: '||v_campus  || ' Fecha_desde: '|| v_date_from || ' Fecha_hasta: '|| v_date_to || ' Punto_emision: '|| v_punto_emision  || ' Appl: '|| v_appl_id || ' Sel_Id: '|| v_sel_id || ' Creator_id: '|| v_creator_id || ' User_id: '|| v_user_id, user);

    <<end_process>>

        gz_report.p_put_line (
            p_one_up_no =>                p_one_up_no,
            p_user =>                v_user_id_log,
            p_job_name =>                'TZPFMAS',
            p_file_number =>                NVL (v_file_number, 1),
            p_content_line =>                   'TZPFMAS - Se procesaron '                || ln_count                || ' registros. Proceso terminado',
            p_content_width =>                v_page_width,
            p_content_align =>                'LEFT',         
            p_status =>                v_status,
            p_comments =>                v_comments);
        EXCEPTION
            WHEN OTHERS
            THEN

                lv_out_error := SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

    END p_factura_masivo_pdf;


 procedure p_get_pdf_masivo (p_filename in varchar2)
is
l_pdf blob;
begin
        select tzrfmas_pdf into l_pdf from tzrfmas where tzrfmas_filename = p_filename;

            HTP.flush;
            HTP.init;
            --
            OWA_UTIL.mime_header ('application/pdf', FALSE);
            HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_pdf));
            OWA_UTIL.http_header_close;
            WPG_DOCLOAD.download_file (l_pdf);
end;

PROCEDURE p_gen_alter_doc (p_pidm            IN     NUMBER,
                               p_sdoc_code       IN     VARCHAR2,
                               p_trans_numbers   IN     VARCHAR2,
                               p_user IN varchar2,
                               p_error_msg          OUT VARCHAR2)
    IS

       p_interno   varchar2(30);
       p_error_ind     VARCHAR2 (100);
        v_prefix_1        tvrsdsq.tvrsdsq_prefix_1%TYPE;
        v_prefix_2        tvrsdsq.tvrsdsq_prefix_2%TYPE;       
        v_district        stvcamp.stvcamp_dicd_code%TYPE;
        v_doc_num         tvrsdsq.tvrsdsq_max_seq%TYPE;
        v_seq             tvrsdsq.tvrsdsq_seq_num%TYPE;
        v_error           VARCHAR2 (1000);
        lv_print_pidm     tvbsdoc.tvbsdoc_print_pidm%TYPE;
        lv_print_id       tvbsdoc.tvbsdoc_print_id%TYPE;
        lv_print_source   tvbsdoc.tvbsdoc_print_id_source%TYPE;
        lv_id             spriden.spriden_id%TYPE;
        v_atyp_code       tvvsdoc.tvvsdoc_atyp_code%TYPE;
        lv_out_error      VARCHAR2 (1000);

        cursor c_tzvaccd (p_pidm number,  p_sdoc_code varchar2, p_trans varchar2 ) is 
        select * 
        from TZVACCD where 
                            TZVACCD_PIDM = p_pidm 
                     and TZVACCD_SDOC_CODE = p_sdoc_code
                     and TZVACCD_BALANCE <> 0
                     AND TZVACCD_TYPE_IND = 'C'
                     AND TZVACCD_TRAN_NUMBER IN
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
            and not exists (select 'Y' from tzrfact where tzrfact_pidm = TZVACCD_PIDM and tzrfact_sdoc_code = TZVACCD_SDOC_CODE and TZRFACT_TRAN_NUM=TZVACCD_TRAN_NUMBER and TZRFACT_COMP_CANCEL_IND is null);

p_ind varchar2(1):= 'N';
p_campus varchar2(30);
p_term varchar2(30);

cursor c_get_cnt_folios (p_sdoc_code varchar2, p_camp_code varchar2) is 
select count(0) from tvrsdsq where TVRSDSQ_SDOC_CODE = p_sdoc_code and TVRSDSQ_CAMP_CODE = p_camp_code and trunc(TVRSDSQ_VALID_UNTIL) >= trunc(sysdate) and TVRSDSQ_FINAL_SEQ > TVRSDSQ_MAX_SEQ;

p_cnt_folio number;

cursor c_get_prefixs (p_sdoc_code varchar2, p_camp_code varchar2) is 
select TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2 from tvrsdsq where TVRSDSQ_SDOC_CODE =p_sdoc_code and TVRSDSQ_CAMP_CODE = p_camp_code and trunc(TVRSDSQ_VALID_UNTIL) >= trunc(sysdate) and TVRSDSQ_FINAL_SEQ > TVRSDSQ_MAX_SEQ;

p_program    varchar2(100);   


cursor c_get_terceros (p_pidm number, p_doc_number varchar2) is
  select TZRFACR_TRDPARTY_ID, TZRFACR_TRDPARTY_PIDM, TZRFACR_TRDPARTY_NAME 
   from tzrfacr 
 where
          tzrfacr_pidm = p_pidm
    and TZRFACR_DOC_NUMBER =  p_doc_number
    and TZRFACR_FACT_ALL = 'Y';

   v_id_ter         TZRFACR.TZRFACR_TRDPARTY_ID%type;
   v_pidm_ter     TZRFACR.TZRFACR_TRDPARTY_PIDM%type;
   v_name_ter     TZRFACR.TZRFACR_TRDPARTY_NAME%type;

   CURSOR get_ssn_c (p_pidm SPRIDEN.SPRIDEN_PIDM%TYPE)
    IS
        SELECT SPBPERS_SSN
          FROM SPBPERS
         WHERE SPBPERS_PIDM = p_pidm;

lv_inf          SPBPERS.SPBPERS_SSN%TYPE;
v_amt number;

BEGIN

       p_ind := 'N';
       v_amt := 0;

       FOR rec IN c_tzvaccd(p_pidm,  p_sdoc_code, p_trans_numbers)
       LOOP


          IF  p_ind = 'N' then
          open c_get_cnt_folios (p_sdoc_code, rec.TZVACCD_CAMPUS);
          fetch c_get_cnt_folios into p_cnt_folio;
          close c_get_cnt_folios;

          dbms_output.put_line('p_cnt_folio' ||p_cnt_folio);

          if p_cnt_folio = 1 then
              open c_get_prefixs (p_sdoc_code, rec.TZVACCD_CAMPUS);
              fetch c_get_prefixs into v_prefix_1, v_prefix_2;
              close c_get_prefixs;
                        dbms_output.put_line('v_prefix_1: ' ||v_prefix_1 || ' v_prefix_2: '||v_prefix_2);
          elsif p_cnt_folio > 1 then
                v_prefix_1 := SUBSTR (rec.TZVACCD_TERM_CODE, 1, 4);
                v_prefix_2 := SUBSTR (rec.TZVACCD_TERM_CODE, 5, 4);
          elsif   p_cnt_folio = 0 then      
                p_error_msg := g$_nls.get ('X', 'SQL', 'No hay folios configurados');                
                GOTO end_process;
          end if;


           tzkpufc.p_get_next_folio (p_doctype         => p_sdoc_code,
                                                     p_user                => p_user, 
                                                     p_camp_code     => rec.TZVACCD_CAMPUS,
                                                     p_prefix1            => v_prefix_1, 
                                                     p_prefix2            => v_prefix_2,
                                                     p_next_numdoc => v_doc_num, 
                                                     p_seq                 => v_seq,    
                                                     p_errormsg         => v_error,
                                                     p_camp_district  => v_district); 



          p_interno := v_district ||v_prefix_2|| lpad(v_doc_num,11,'0');

dbms_output.put_line('p_interno: ' ||p_interno || ' rec.TZVACCD_CAMPUS: '||rec.TZVACCD_CAMPUS);

            IF v_error IS NOT NULL
            THEN
                p_error_msg := g$_nls.get ('X', 'SQL', v_error);
				p_error_msg := p_error_msg || ' Verifique los perfiles asignados VBS. ';
                GOTO end_process;
            ELSE 

                tzkpufc.p_update_secuencia (p_sdoc_code,
                                    p_user,
                                    v_prefix_1,
                                    v_prefix_2,
                                    rec.TZVACCD_CAMPUS,
                                    v_doc_num,
                                    p_error_msg);

            p_ind := 'Y';

                IF p_error_msg IS NOT NULL
                THEN
                    p_error_msg :=
                        g$_nls.get (
                            'X',
                            'SQL',
                            'Ha ocurrido un error. Favor de contactar a su unidad académica');

                    GOTO end_process;
                END IF;

            END IF;

            OPEN get_ssn_c (p_pidm);
            FETCH get_ssn_c INTO lv_inf;
            CLOSE get_ssn_c;

            lv_id := gb_common.f_get_id (p_pidm);

            tvkrlib.p_get_printed_id (p_sdoc_code,
                                      lv_id,
                                      lv_print_pidm,
                                      lv_print_id,
                                      lv_print_source);

            IF     lv_inf IS NOT NULL
               AND v_prefix_1 IS NOT NULL
               AND v_prefix_2 IS NOT NULL
               AND v_district IS NOT NULL
               AND v_doc_num IS NOT NULL
            THEN

                tzkpufc.p_insert_tvbsdoc (p_sdoc_code =>p_sdoc_code,
                                     p_doc_number =>p_interno,
                                     p_pidm =>p_pidm,
                                     p_prefix_1 =>v_prefix_1,
                                     p_prefix_2 =>v_prefix_2,
                                     p_int_doc_number =>v_doc_num,
                                     p_comments =>NULL,
                                     p_user_id =>user,
                                     p_data_origin =>'tzkpufc.p_gen_alter_doc',
                                     p_date =>SYSDATE,
                                     p_print_pidm =>p_pidm,
                                     p_print_id =>lv_inf,
                                     p_print_id_source =>'SPBPERS_SSN',
                                     p_atyp_code => v_atyp_code,
                                     p_msg_out =>p_error_msg);

                IF p_error_msg is not null then
                    p_error_msg := p_error_msg || p_error_msg;
                    GOTO end_process;
                ELSE
                    p_error_msg := NULL;
                END IF;

                ELSE
                p_error_msg :=
                    g$_nls.get (
                        'X',
                        'SQL',
                           'Warning NSS is null. Please go to SPAIDEN form'
                        || 'p_pidm:'
                        || p_pidm
                        || ' lv_inf:'
                        || lv_inf
                        || ' v_prefix_1:'
                        || v_prefix_1
                        || ' v_prefix_2:'
                        || v_prefix_2
                        || ' v_district:'
                        || v_district
                        || ' v_doc_num:'
                        || v_doc_num);

            END IF;

      END IF; 


          IF v_doc_num is not null then
                    tzkpufc.p_insert_tvrsdoc (p_pidm => p_pidm,
                                         p_pay_tran_number =>0,
                                         p_chg_tran_number => rec.TZVACCD_TRAN_NUMBER,
                                         p_doc_number => p_interno,
                                         p_doc_type => SUBSTR (p_sdoc_code, 1, 2),
                                         p_int_doc_number => v_doc_num,
                                         p_user_id => p_user,
                                         p_data_origin => 'tzkpufc.p_gen_alter_doc',
                                         p_comments =>NULL,
                                         p_sdoc_code => p_sdoc_code,
                                         p_msg_out =>p_error_msg);


                IF p_error_msg is not null then
                    p_error_msg := p_error_msg || p_error_msg;
                    GOTO end_process;
                ELSE
                    p_error_msg := NULL;
                END IF;


                   BEGIN

                   IF rec.TZVACCD_STSP_KEY_SEQUENCE = 0 then
                        p_program :=  tzkpufc.f_get_sovlcur(p_pidm , rec.TZVACCD_TERM_CODE, 'PROGRAM');
                   ELSE     
                        p_program :=  tzkpufc.f_get_sovlcur(p_pidm , rec.TZVACCD_STSP_KEY_SEQUENCE, 'PROGRAM_DIRECT');
                           IF p_program is null then
                                p_program :=  tzkpufc.f_get_sovlcur(p_pidm , rec.TZVACCD_TERM_CODE, 'PROGRAM');
                           END IF;
                   END IF;
					if p_sdoc_code = 'XP' then 
						p_program :=  tzkpufc.f_get_sovlcur_xp(p_pidm , rec.TZVACCD_STSP_KEY_SEQUENCE);
					end if;

                   p_campus := rec.TZVACCD_CAMPUS;
                   p_term := rec.TZVACCD_TERM_CODE;

                    Insert into TZRFACT (TZRFACT_PIDM,TZRFACT_SDOC_CODE,TZRFACT_ID,TZRFACT_CURR_PROGRAM,TZRFACT_DET_CODE_DOC,TZRFACT_AMNT_TRANS,TZRFACT_TRAN_NUM,TZRFACT_RECEIPT_NUM,TZRFACT_TRDPARTY_ID,TZRFACT_TRDPARTY_PIDM,TZRFACT_TRDPARTY_NAME,TZRFACT_STPERDOC_QTY,TZRFACT_PREFACT_DATE,TZRFACT_ACTIVITY_DATE,TZRFACT_USER,TZRFACT_TERM_CODE,TZRFACT_CAMPUS,TZRFACT_INTERNAL_RECEIPT_NUM) 
                                          values (p_pidm, p_sdoc_code, lv_id, p_program, rec.TZVACCD_DETAIL_CODE, rec.TZVACCD_AMOUNT, rec.TZVACCD_TRAN_NUMBER,  null, v_id_ter, v_pidm_ter, v_name_ter,1,sysdate,sysdate,user,rec.TZVACCD_TERM_CODE,rec.TZVACCD_CAMPUS,p_interno);

                        tzkpufc.p_ins_tzrrlog(p_pidm,  'COMPROBANTES_ALT', 'INS TZRFACT', p_sdoc_code || ' p_interno: '||p_interno ||' lv_out_error: '||lv_out_error, p_user);

                v_amt := v_amt + rec.TZVACCD_AMOUNT;
                p_error_msg := 'OK';

                EXCEPTION
                    WHEN OTHERS
                    THEN


                        lv_out_error :=
                            SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

                     tzkpufc.p_ins_tzrrlog(p_pidm,  'COMPROBANTES_ALT', 'INS ERR', lv_out_error, p_user);

                        p_error_ind := 'Y';
                        p_error_msg :=
                               'Error: '
                            || SQLCODE
                            || '--'
                            || SUBSTR (SQLERRM, 1, 500);
                        GOTO end_process;
                END;
          end if;

       END LOOP; 

    IF v_doc_num is not null then
       BEGIN
                tzkpufc.p_insert_tzrdprf (
                    p_pidm,
                    p_sdoc_code, 
                    p_interno,
                    p_campus,
                    p_term,
                    'CREADO',
                    NULL,
                    SYSDATE,                    
                    tzkpufc.f_get_due_date (p_pidm,p_term, p_campus, p_sdoc_code,null ),
                    p_interno,
                    v_amt,
                    tzkpufc.f_get_iden (p_pidm, 'CEDULA', 'Y'),
                    tzkpufc.f_get_iden (p_pidm),
                    v_amt,
                    p_user,
                    'TZKPUFC');


                EXCEPTION WHEN OTHERS THEN
                   p_error_ind := 'Y';
                    p_error_msg := 'El ID '||gb_common.f_get_id(p_pidm)||' no cuenta con número de identificación';
                END;
        end if;

       <<end_process>>
        p_error_msg := p_error_msg;

        tzkpufc.p_ins_tzrrlog(p_pidm,  'COMPROBANTES_ALT', 'GENERA', p_error_msg, p_user);

    EXCEPTION
        WHEN OTHERS
        THEN
            p_error_ind := 'Y';
            p_error_msg :=
                'Error: ' || SQLCODE || '--' || SUBSTR (SQLERRM, 1, 500);

                tzkpufc.p_ins_tzrrlog(p_pidm,  'COMPROBANTES_ALT', 'GENREA ERR', p_error_ind||' - '||p_error_msg, p_user);

    END p_gen_alter_doc;

  procedure p_gen_factura_deposito (p_pidm  IN NUMBER, p_doc_num  IN VARCHAR2,  p_user in varchar2, p_return out varchar2)
is
cursor c_has_sri  is 
select TZRFACT_SRI_DOCNUM from TZRFACT where TZRFACT_PIDM = p_pidm
and TZRFACT_DOC_NUMBER = p_doc_num
and TZRFACT_SRI_DOCNUM is not null;

v_has_sri  TZRFACT.TZRFACT_SRI_DOCNUM%type;
v_sdoc_code varchar2(10);

cursor c_get_sdoc_code (p_code varchar2) is
        select  GTVSDAX_EXTERNAL_CODE 
        from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = p_code;

cursor c_get_pto_emision  IS
   select TVRSDSQ_CAMP_CODE, TVRSDSQ_PREFIX_1, TVRSDSQ_PREFIX_2 
   from TVRSDSQ where TVRSDSQ_SDOC_CODE = v_sdoc_code
   and TVRSDSQ_FBPR_CODE in (select GORFBPR_FBPR_CODE from GENERAL.GORFBPR where GORFBPR_FGAC_USER_ID = p_user);


p_program varchar2(12):= '';
p_campus varchar2(12);
p_term varchar2(8);
p_prefact_date date;

cursor c_get_data is
select TZRFACT_CURR_PROGRAM, TZRFACT_TERM_CODE, 
decode (TZRFACT_CAMPUS, null,  
        (select STVCAMP_CODE from stvcamp where STVCAMP_DICD_CODE = substr(TZRFACT_DOC_NUMBER,7,1) and rownum = 1) ,TZRFACT_CAMPUS) campus
        , trunc(TZRFACT_PREFACT_DATE) prefact_date
from tzrfact where tzrfact_pidm =  p_pidm and tzrfact_doc_number = p_doc_num;

   v_doc_num   tvrsdsq.tvrsdsq_max_seq%TYPE;
   v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
   v_error  varchar2(1000);
   v_district  VARCHAR2(3);

   p_folio_factura varchar2(20);
   v_prefix_1 TVRSDSQ.TVRSDSQ_PREFIX_1%type;
   v_prefix_2 TVRSDSQ.TVRSDSQ_PREFIX_1%type;
   v_err_update  varchar2(1000);
   v_pto_emision varchar2(9);
   v_sri varchar2(20):='';
   v_return_error varchar2(1000);
   p_pay_detail_code varchar2(4);

   ln_recepit_number            tbraccd.tbraccd_receipt_number%TYPE;
   ln_tbraccd_tran_number_out   NUMBER;
   lv_tbraccd_response_out      VARCHAR2 (300);

   v_user_create      VARCHAR2 (30) := NULL;
   v_pref_code  VARCHAR2 (30) := NULL;

cursor c_terceros is
select TZRFACR_PIDM, TZRFACR_ID, TZRFACR_TRDPARTY_NAME
from tzrfacr
where TZRFACR_PIDM = p_pidm
     and TZRFACR_TERM_CODE = p_term
     and TZRFACR_DOC_NUMBER = p_doc_num
     and TZRFACR_FACT_ALL = 'Y'
group by TZRFACR_PIDM, TZRFACR_ID, TZRFACR_TRDPARTY_NAME;

v_TRDPARTY_ID       varchar2(10);
v_TRDPARTY_PIDM number;
v_TRDPARTY_NAME varchar2(120);

cursor c_get_balance is 
SELECT SUM (TZVACCD_BALANCE)
                        FROM  tzvaccd
                       WHERE 
                                    tzvaccd_pidm = p_pidm
                             AND TZVACCD_SDOC_CODE = (select  GTVSDAX_EXTERNAL_CODE  from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_PREF')
                             AND tzvaccd_term_code = SUBSTR (p_doc_num, 1, 6) 
                               and TZVACCD_TYPE_IND = 'C'
                               AND tzvaccd_tran_number in (select tvrsdoc_chg_tran_number from tvrsdoc where 
                                    tzvaccd_pidm = tvrsdoc_pidm
                             AND tvrsdoc_doc_number = p_doc_num
                             AND tvrsdoc_doc_cancel_ind IS NULL);

v_balance number:=0;

--05MZO21 se agrega , TBRACCD_SRCE_CODE y condicion and TVRAPPL_REAPPL_IND is null
cursor c_pagos is 
select distinct TBRACCD_DETAIL_CODE, TBRACCD_AMOUNT, TBRACCD_TRAN_NUMBER , TBRACCD_SRCE_CODE
                                                                    from tvrappl, tvrsdoc, tbraccd, tbbdetc
                                                                        where tbraccd_detail_code = tbbdetc_detail_code
                                                                        and tbbdetc_type_ind = 'P'
                                                                        and tbbdetc_dcat_code <> 'BEC'
                                                                        and tvrappl_pidm = tbraccd_pidm 
                                                                        and TVRAPPL_PAY_TRAN_NUMBER = TBRACCD_TRAN_NUMBER
                                                                        and tvrappl_pidm = tvrsdoc_pidm
                                                                        and tvrappl_chg_tran_number = TVRSDOC_CHG_TRAN_NUMBER
                                                                        and TVRAPPL_REAPPL_IND is null
                                                                        and tvrappl_pidm = p_pidm
                                                                        and tvrsdoc_doc_number = p_doc_num;

cursor c_get_chg ( p_pay_tran number) is
select TBRAPPL_CHG_TRAN_NUMBER from tbrappl where tbrappl_pidm = p_pidm and TBRAPPL_PAY_TRAN_NUMBER = p_pay_tran;

begin

    OPEN c_get_balance;
    FETCH c_get_balance into v_balance;
    CLOSE c_get_balance;

    tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'llegada','00- '|| p_pidm||' p_doc_num: '||p_doc_num || ' v_balance: '||v_balance, p_user);


    IF v_balance = 0 then

                OPEN c_has_sri;
                FETCH c_has_sri into v_has_sri;
                CLOSE c_has_sri;

                 OPEN c_get_sdoc_code ('COD_FACT');
                 FETCH c_get_sdoc_code into v_sdoc_code;
                 CLOSE c_get_sdoc_code;

            tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Inicio','01- '|| p_pidm||' p_doc_num: '||p_doc_num || ' v_has_sri: '||v_has_sri, p_user);

            IF  v_has_sri is null then

                               OPEN c_get_pto_emision;
                               FETCH c_get_pto_emision into v_pto_emision, v_prefix_1, v_prefix_2;
                               CLOSE c_get_pto_emision;

                  tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Emision', '02- '||'v_pto_emision: '||v_pto_emision||' v_prefix_1: '||v_prefix_1 || ' v_prefix_2: '||v_prefix_2, p_user);

                               IF v_prefix_1 is not null and v_prefix_2 is not null then  

                                    open c_get_data;
                                    fetch c_get_data into p_program, p_term, p_campus, p_prefact_date;
                                    close c_get_data;

                                    tzkpufc.p_get_next_folio (p_doctype         => v_sdoc_code,
                                                                          p_user            => p_user, 
                                                                          p_camp_code       => p_campus,
                                                                          p_prefix1         => v_prefix_1,
                                                                          p_prefix2         => v_prefix_2,
                                                                          p_next_numdoc     => v_doc_num, 
                                                                          p_seq             => v_seq,    
                                                                          p_errormsg        => v_error,
                                                                          p_camp_district   => v_district); 

                tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'p_get_next_folio', '03- '||'v_sdoc_code: '||v_sdoc_code||' p_campus: '||p_campus || ' v_doc_num: '||v_doc_num|| ' v_error: '||v_error, p_user);

                               IF v_doc_num is not null then           

                                  p_folio_factura := v_prefix_1 || '-'||v_prefix_2 ||'-'|| lpad(v_doc_num,9,'0');

                                  p_return := v_has_sri;

                                   begin
                                            TZKPUFC.P_UPDATE_SECUENCIA(
                                                P_DOCTYPE => v_sdoc_code,
                                                P_USER => p_user,
                                                P_PREFIX1 => v_prefix_1,
                                                P_PREFIX2 => v_prefix_2,
                                                P_CAMP_CODE => p_campus,
                                                P_SECUENCIA => v_doc_num,
                                                P_ERROR => v_err_update
                                              );
                                    exception
                                    when others then null;
                                    end;

            tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'P_UPDATE_SECUENCIA', '04- '||'p_folio_factura: '||p_folio_factura||' v_err_update: '||v_err_update , p_user);

                  IF v_err_update is null then
                      tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'P_UPDATE_SECUENCIA', '05- '||'siembra pagos ' , p_user);

                  OPEN c_terceros;
                  fetch c_terceros into v_TRDPARTY_PIDM, v_TRDPARTY_ID,v_TRDPARTY_NAME;
                  CLOSE c_terceros;


                FOR r_pago IN c_pagos
                LOOP

                                begin 
                                INSERT INTO TZRFACT (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM,  TZRFACT_SRI_DOCNUM,  TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY,  TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE,  TZRFACT_ACTIVITY_DATE, TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS)
                                                        values (p_pidm, v_sdoc_code, p_doc_num, gb_common.f_get_id(p_pidm), p_program, tzkpufc.f_get_docnum_fmt(p_doc_num), r_pago.TBRACCD_DETAIL_CODE, r_pago.TBRACCD_AMOUNT, r_pago.TBRACCD_TRAN_NUMBER, p_folio_factura, v_TRDPARTY_ID, v_TRDPARTY_PIDM, v_TRDPARTY_NAME, 1, p_prefact_date, sysdate, sysdate, p_user,  p_term, sysdate,  p_campus);

                                            tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Insert TZRFACT', '07- '||'v_pref_code: '||v_sdoc_code, p_user);           
                                exception when others then null;
                                end;

--                               FOR r_chg IN c_get_chg(r_pago.TZVACCD_TRAN_NUMBER) 
--                               LOOP
                                 begin
                                           update tzrfact set TZRFACT_SRI_DOCNUM =  p_folio_factura
                                                            , TZRFACT_STPERDOC_QTY = 1
                                                            , TZRFACT_FACT_DATE = sysdate
                                                            , TZRFACT_ACTIVITY_DATE = sysdate
                                                            , TZRFACT_PAY_DATE = sysdate
                                                             where tzrfact_pidm = p_pidm
                                                                 and tzrfact_sdoc_code = (select  GTVSDAX_EXTERNAL_CODE  from gtvsdax where GTVSDAX_INTERNAL_CODE_GROUP = 'PUCE_FACT' and GTVSDAX_INTERNAL_CODE = 'COD_PREF')
                                                                 and TZRFACT_DOC_NUMBER = p_doc_num
                                                                 --and TZRFACT_TRAN_NUM = r_chg.TBRAPPL_CHG_TRAN_NUMBER
                                                                 and TZRFACT_SRI_DOCNUM is null;

                                         --  tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Update TZRFACT', '7.5- '||'SRIDOC in CHG: '||r_chg.TBRAPPL_CHG_TRAN_NUMBER || ' pay trx: ' ||r_pago.TZVACCD_TRAN_NUMBER, p_user);           
                                 exception when others then null;
                                 end;

                               --END LOOP;

                END LOOP;


                            TZKPUFC.p_upd_TZRDPRF (p_pidm,p_doc_num);

                                    p_return := p_folio_factura;
                        END IF;

                    END IF;  
                ELSE
                tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Salida', 'Excepcion', p_user);           
                GOTO end_process_cero;
                END IF; 

            ELSE
            -- 05MZO21 Se configura lado falso, para factura existente. REFACTURAR DEPOSITO. 
            p_return := v_has_sri;

            tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Refactura depósito', '09- '||p_return, p_user);           

           open c_get_data;
           fetch c_get_data into p_program, p_term, p_campus, p_prefact_date;
           close c_get_data;

           OPEN c_terceros;
                  fetch c_terceros into v_TRDPARTY_PIDM, v_TRDPARTY_ID,v_TRDPARTY_NAME;
                  CLOSE c_terceros;


           FOR r_pago IN c_pagos
                LOOP
                                begin                       
                                tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Refactura depósito c_pagos', '10- '||r_pago.TBRACCD_SRCE_CODE, p_user);           

                                IF r_pago.TBRACCD_SRCE_CODE <> 'D' THEN                                
                                INSERT INTO TZRFACT (TZRFACT_PIDM, TZRFACT_SDOC_CODE, TZRFACT_DOC_NUMBER, TZRFACT_ID, TZRFACT_CURR_PROGRAM, TZRFACT_SALE_DOCNUM, TZRFACT_DET_CODE_DOC, TZRFACT_AMNT_TRANS, TZRFACT_TRAN_NUM,  TZRFACT_SRI_DOCNUM,  TZRFACT_TRDPARTY_ID, TZRFACT_TRDPARTY_PIDM, TZRFACT_TRDPARTY_NAME, TZRFACT_STPERDOC_QTY,  TZRFACT_PREFACT_DATE, TZRFACT_FACT_DATE,  TZRFACT_ACTIVITY_DATE, TZRFACT_USER, TZRFACT_TERM_CODE, TZRFACT_PAY_DATE, TZRFACT_CAMPUS)
                                                        values (p_pidm, v_sdoc_code, p_doc_num, gb_common.f_get_id(p_pidm), p_program, tzkpufc.f_get_docnum_fmt(p_doc_num), r_pago.TBRACCD_DETAIL_CODE, r_pago.TBRACCD_AMOUNT, r_pago.TBRACCD_TRAN_NUMBER, v_has_sri, v_TRDPARTY_ID, v_TRDPARTY_PIDM, v_TRDPARTY_NAME, 1, p_prefact_date, sysdate, sysdate, p_user,  p_term, sysdate,  p_campus);

                                            tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'Insert TZRFACT', '08- '||'v_pref_code: '||v_sdoc_code ||' ,v_has_sri:'||v_has_sri||' ,trx_nueva: '||r_pago.TBRACCD_TRAN_NUMBER||' ,codigo_detalle_nuevo: '||r_pago.TBRACCD_DETAIL_CODE, p_user);           
                                 END IF;                                 
                                exception when others then null;
                                end;
                  END LOOP;              

                TZKPUFC.p_upd_TZRDPRF (p_pidm,p_doc_num);
             --------------------------------------------------------------------------

            END IF; 

END IF;

<<end_process_cero>> 

tzkpufc.p_ins_tzrrlog(p_pidm,  'FACTURA_DEPO', 'end_process_cero', '08- '||'Excepcion ', p_user);           

end p_gen_factura_deposito;

--acastillo refinanciación planes de pago PROC
      PROCEDURE p_create_headerTZPREFI (in_seq_no           NUMBER,
                              in_user_id          VARCHAR2,
                              p_file_number   OUT NUMBER)
   IS
      --constants for '.lis' file report
      const_out_line_headerj CONSTANT VARCHAR2 (130)
            :=    RPAD ('DATE RUN', 11, ' ')
               || RPAD (TO_CHAR (SYSDATE, 'mm/dd/yyyy'), 43, ' ')
               --  || RPAD ('FUNDACION AREANDINA', 58, ' ')
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
      DBMS_OUTPUT.enable (1000000);

      -- Get the name of the instance for which this job is running
      SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') INTO v_environment FROM DUAL;

      --========================================================================
      -- create headers
      --========================================================================
      IF SUBSTR (v_environment, 1, 4) = 'PROD'
      THEN
         v_environment_nm := 'PRODUCTION INSTANCE';
      ELSIF SUBSTR (v_environment, 1, 4) = 'PPRD'
      THEN
         v_environment_nm := 'PRE-PRODUCTION INSTANCE';
      ELSIF SUBSTR (v_environment, 1, 4) = 'TEST'
      THEN
         v_environment_nm := 'TEST INSTANCE';
      ELSIF SUBSTR (v_environment, 1, 4) = 'QA'
      THEN
         v_environment_nm := 'QA INSTANCE';
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
   END p_create_headerTZPREFI;

procedure p_califica_nivel2(p_seq_no            number default 999999999,
                             p_term_code   in     varchar2,
                             p_camp_code   in     varchar2 default null,
                             p_program     in     varchar2 default null,
                             p_area    in     varchar2 default null,
                             p_id    	   in  varchar2 default null,
							 p_err_code    out    varchar2,
    			        	 p_err_msg     out    varchar2,
                             p_user        in varchar2) is


    tckn_seq     number:=0;

  lv_error            varchar2 (10) := 'N';
  v_row_print         varchar2 (1000);
  v_page_width        number;
  v_status            varchar2 (10);
  v_comments          varchar2 (20000):='';
  v_file_number       guboutp.guboutp_file_number%type := 1;
  v_comment          varchar2 (20000):='';
  v_cal_nota   number;
  v_gcom_id    varchar2(2) :='-';
  lv_id               spriden.spriden_id%type;
  lv_pidm             sgrchrt.sgrchrt_pidm%type;
  v_nota   number(5,2):=0;
  v_nota_message varchar2(100):='';
  v_exist_tckg varchar2(2):='N';
  v_count_crses_n3_tckn   number;    
  v_count_crse_n3_szrasit number; 
  v_count_crses_n2_tckn   number;    
  v_count_crse_n2_szrasis number;    
  msg_comp varchar2(100) :='******';

	cursor c_nivel_1 (p_pidm number) is
	select sfrstcr_pidm,
            szbasip_camp_code, 
            sfrstcr_term_code,
			szbasip_program, 
			szbasip_area,
            ssbsect_crn,
			szbasip_subj_code, 
			szbasip_crse_num, 
			szbasip_calcre_ck, 
			szbasip_calpro_ck, 
			szbasip_asiste_ck, 
			szbasip_gcom_id, 
			szbasip_state, 
			szbasip_consec_id
		from szbasip, ssbsect, sfrstcr
		where szbasip_camp_code = p_camp_code
        and ssbsect_gradable_ind = 'Y'
        and sfrstcr_rsts_code   like 'R%' 
		and szbasip_program     = p_program
		and szbasip_area        = nvl(p_area,szbasip_area)
        and sfrstcr_pidm        = nvl(p_pidm,sfrstcr_pidm)
        and ssbsect_term_code   = p_term_code
        and szbasip_camp_code   = ssbsect_camp_code        
        and szbasip_subj_code   = ssbsect_subj_code
        and szbasip_crse_num    = ssbsect_crse_numb
        and sfrstcr_term_code   = ssbsect_term_code
        and sfrstcr_crn         = ssbsect_crn
        and exists (select 1 from sovlcur 
                     where sovlcur_program = p_program 
					 and   sovlcur_pidm = sfrstcr_pidm );

	cursor c_nivel_2 (p_pidm number, p_asip number) is
	select szrasis_appro_ck, szrasis_calcre_ck, szrasis_calpro_ck, szrasis_asiste_ck, szrasis_ruler, szrasis_gcom_id,
        szrasis_asip_consec_id,szrasis_consec_id,shrtckn_pidm, shrtckn_term_code, shrtckn_crn, shrtckn_camp_code, szrasis_subj_code, szrasis_crse_num
		from shrtckn tckn, szrasis asis 
		where tckn.shrtckn_pidm = nvl(p_pidm,shrtckn_pidm)
		and   tckn.shrtckn_term_code = p_term_code
		and   tckn.shrtckn_crse_numb = asis.szrasis_crse_num
		and   tckn.shrtckn_subj_code = asis.szrasis_subj_code
		and   szrasis_asip_consec_id = p_asip
	union         
    select szrasis_appro_ck, szrasis_calcre_ck, szrasis_calpro_ck, szrasis_asiste_ck, szrasis_ruler, szrasis_gcom_id,
        szrasis_asip_consec_id,szrasis_consec_id,
        sfrstcr_pidm, ssbsect_term_code, ssbsect_crn, ssbsect_camp_code, szrasis_subj_code, szrasis_crse_num
        from szrasis, ssbsect, sfrstcr
		where sfrstcr_pidm        = nvl(p_pidm,sfrstcr_pidm)
        and ssbsect_gradable_ind = 'Y' 
        and sfrstcr_rsts_code   like 'R%' 
        and ssbsect_term_code   = p_term_code
        and szrasis_subj_code   = ssbsect_subj_code
        and szrasis_crse_num    = ssbsect_crse_numb
        and sfrstcr_term_code   = ssbsect_term_code
        and sfrstcr_crn         = ssbsect_crn
        and szrasis_asip_consec_id=p_asip;

	--nota de cursos de nivel2 (calculada a partir de cursos nivel3, dependientes de nivel 1
	cursor 	c_notacre_nivel_2_pidm (p_pidm number,p_asis number) is	
	select szrasit_asis_consec_id,
    sum(shksels.f_shrgrde_value(substr(shksels.f_shrtckg_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no,1,'GC'),1,6),shrtckn_term_code,null,'QP') *
    substr(shksels.f_shrtckg_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no,1,'CH'),1,6))/sum(shksels.f_shrtckg_value(shrtckn_pidm,shrtckn_term_code,shrtckn_seq_no,1,'CH')) as nota
	from shrtckn tckn, szrasit asit 
	where tckn.shrtckn_pidm = nvl(p_pidm,shrtckn_pidm)
	and   tckn.shrtckn_term_code = p_term_code
	and   tckn.shrtckn_crse_numb = asit.szrasit_crse_num
	and   tckn.shrtckn_subj_code = asit.szrasit_subj_code
	and   szrasit_asis_consec_id in (p_asis)
	group by szrasit_asis_consec_id;		


Begin

	lv_id		 := p_id;
    v_nota_message := '--';
	if lv_id is not null then
		lv_pidm := gb_common.f_get_pidm(lv_id);
		else
		lv_pidm := null;
	end if;
      v_row_print :=
            gz_report.f_colum_format ('Periodo',
                                      7,
                                      'LEFT',
                                      ' | ')
         || gz_report.f_colum_format ('Plan Anulado',
                                      9,
                                      'LEFT',
                                      ' | ')
         || gz_report.f_colum_format ('Programa/Area',
                                      9,
                                      'LEFT',
                                      ' | ')
         || gz_report.f_colum_format ('MATERIA A PROCESAR',
                                      20,
                                      'LEFT',
                                      ' | ')
		  || gz_report.f_colum_format ('CRN',
                                      8,
                                      'LEFT',
                                      ' | ')
          || gz_report.f_colum_format ('COMPONENTE',
                                      6,
                                      'LEFT',
                                      ' | ')
		  || gz_report.f_colum_format ('NOTA',
                                      5,
                                      'LEFT',
                                      ' | ')
		  || gz_report.f_colum_format ('OBS.',
                                      10,
                                      'LEFT',
                                      ' | ');
      --DBMS_OUTPUT.put_line ('v_row_print START: ' || v_row_print);

      gz_report.p_put_line (p_one_up_no       => p_seq_no,
                            p_user            => USER,
                            p_job_name        => const_application_name,
                            p_file_number     => 1,  --NVL (v_file_number, 1),
                            p_content_line    => v_row_print,
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

      gz_report.p_put_line (p_one_up_no       => p_seq_no,
                            p_user            => USER,
                            p_job_name        => const_application_name,
                            p_file_number     => 1,  --NVL (v_file_number, 1),
                            p_content_line    => LPAD (' ', v_page_width, '-'),
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

	For crse_nivel_1 in c_nivel_1 (lv_pidm) Loop
       Begin  
		 --primero calcular notas de cursos de nivel dos que estan en la historia del estudiante
		 --basandose en los cursos de nivel 3 si hay dependientes
		 For crse_nivel_2 in c_nivel_2 (crse_nivel_1.sfrstcr_pidm,crse_nivel_1.szbasip_consec_id) Loop
                  v_comment:='';

                  --DBMS_OUTPUT.put_line ('crse_nivel_2.szrasis_consec_id: ' || crse_nivel_2.szrasis_consec_id);
            /*p_nota_nivel_2_pidm (crse_nivel_2.shrtckn_pidm,
                                    v_count_crses_n3_tckn,
                                    v_count_crse_n3_szrasit,
                                    crse_nivel_2.shrtckn_term_code,
                                    crse_nivel_2.szrasis_consec_id,
                                    v_nota,v_exist_tckg,
                                    crse_nivel_2.szrasis_calcre_ck,
                                    crse_nivel_2.szrasis_calpro_ck);*/

            if v_exist_tckg = 'N' then     
                --DBMS_OUTPUT.put_line ('p_update_sfrstcr v_nota: ' || v_nota);
                v_comment:= v_comment||' No hay calificación en historia.';
                if (v_count_crses_n3_tckn = v_count_crse_n3_szrasit) and v_nota is not null then  
                    szkcnan.p_update_sfrstcr (crse_nivel_2.shrtckn_pidm, 
											crse_nivel_2.shrtckn_term_code, 
											crse_nivel_2.shrtckn_crn, 
											crse_nivel_2.szrasis_gcom_id, 
											v_nota);
                                    v_nota_message := to_char(v_nota);                
                else
                v_nota_message := 'No cal';
                v_comment:= v_comment||' Faltan notas de nivel 3 en historia para calcular.';
                end if;
            else
                v_nota_message := to_char(v_nota);  
                v_comment:= v_comment||' Calificación tomada de historia.';
            end if;

			if crse_nivel_2.szrasis_gcom_id is not null then					
				msg_comp := crse_nivel_2.szrasis_gcom_id;
				else
				msg_comp := '******';
			end if;
			v_row_print :=
            gz_report.f_colum_format (p_term_code,
                                      7,
                                      'LEFT',
                                      ' | ')
            || gz_report.f_colum_format (gb_common.f_get_id(crse_nivel_2.shrtckn_pidm),
                                         9,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (p_program||'-'||crse_nivel_1.szbasip_area,
                                         9,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format ('N1:'||crse_nivel_1.szbasip_subj_code||'-'||crse_nivel_1.szbasip_crse_num ||' N2:'||crse_nivel_2.szrasis_subj_code||'-'||crse_nivel_2.szrasis_crse_num,
                                         24,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (crse_nivel_2.shrtckn_crn,
                                         8,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (msg_comp,--crse_nivel_2.szrasis_gcom_id,
                                         6,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (v_nota_message,--notacre_nivel_2_pidm.nota,
                                         5,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format ('Calc. créditos: '||crse_nivel_2.szrasis_calcre_ck,--notacre_nivel_2_pidm.nota,
                                         10,
                                         'LEFT',
                                         ' | ');
         --DBMS_OUTPUT.put_line ('v_row_print: ' || v_row_print);
         gz_report.p_put_line (p_one_up_no       => p_seq_no,
                               p_user            => USER,
                               p_job_name        => const_application_name,
                               p_file_number     => 1, --NVL (v_file_number, 1),
                               p_content_line    => v_row_print,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
         v_row_print := v_comment;                      
         gz_report.p_put_line (p_one_up_no       => p_seq_no,
                               p_user            => USER,
                               p_job_name        => const_application_name,
                               p_file_number     => 1, --NVL (v_file_number, 1),
                               p_content_line    => v_row_print,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
		 end loop;
         --calcular nota de nivel 1 despues de haber calculado todas las de nivel 2 dependientes

			v_exist_tckg := 'N';
			v_nota_message := 'No cal';
            v_comment := '';
			msg_comp :='******';
			/*p_nota_nivel_1_pidm (crse_nivel_1.sfrstcr_pidm,
                                    v_count_crses_n2_tckn,
                                    v_count_crse_n2_szrasis,
                                    crse_nivel_1.sfrstcr_term_code,
                                    crse_nivel_1.szbasip_consec_id,
                                    v_nota,v_exist_tckg,
                                    crse_nivel_1.szbasip_calcre_ck,
                                    crse_nivel_1.szbasip_calpro_ck);*/

			if crse_nivel_1.szbasip_gcom_id is not null then					
				msg_comp := crse_nivel_1.szbasip_gcom_id;
				else
				msg_comp := '******';
			end if;

            if v_exist_tckg = 'N' then     
                v_comment:= v_comment||' No hay calificación en historia.';
                if (v_count_crses_n2_tckn = v_count_crse_n2_szrasis) and v_nota is not null then  
                    szkcnan.p_update_sfrstcr (crse_nivel_1.sfrstcr_pidm, 
											crse_nivel_1.sfrstcr_term_code, 
											crse_nivel_1.ssbsect_crn, 
											crse_nivel_1.szbasip_gcom_id, 
											v_nota);
                                    v_nota_message := to_char(v_nota);                
                else
                v_nota_message := 'No cal';
                v_comment:= v_comment||' Faltan notas de nivel 2 en historia para calcular.';
                end if;
            else
                v_nota_message := to_char(v_nota);  
                v_comment:= v_comment||' Calificación tomada de historia.';
            end if;

		 v_row_print :=
            gz_report.f_colum_format (p_term_code,
                                      7,
                                      'LEFT',
                                      ' | ')
            || gz_report.f_colum_format (gb_common.f_get_id(crse_nivel_1.sfrstcr_pidm),
                                         9,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (p_program||'-'||crse_nivel_1.szbasip_area,
                                         9,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format ('N1:'||crse_nivel_1.szbasip_subj_code||'-'||crse_nivel_1.szbasip_crse_num,
                                         24,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (crse_nivel_1.ssbsect_crn,
                                         8,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (msg_comp,--crse_nivel_1.szbasip_gcom_id,
                                         6,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format (v_nota_message,--notacre_nivel_2_pidm.nota,
                                         5,
                                         'LEFT',
                                         ' | ')
            || gz_report.f_colum_format ('Calc. créditos: '||crse_nivel_1.szbasip_calcre_ck,--notacre_nivel_2_pidm.nota,
                                         10,
                                         'LEFT',
                                         ' | ');                                         

         --DBMS_OUTPUT.put_line ('v_row_print: ' || v_row_print);
         gz_report.p_put_line (p_one_up_no       => p_seq_no,
                               p_user            => USER,
                               p_job_name        => const_application_name,
                               p_file_number     => 1, --NVL (v_file_number, 1),
                               p_content_line    => v_row_print,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
         gz_report.p_put_line (p_one_up_no       => p_seq_no,
                               p_user            => USER,
                               p_job_name        => const_application_name,
                               p_file_number     => 1, --NVL (v_file_number, 1),
                               p_content_line    => v_comment,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
         gz_report.p_put_line (p_one_up_no       => p_seq_no,
                               p_user            => USER,
                               p_job_name        => const_application_name,
                               p_file_number     => 1, --NVL (v_file_number, 1),
                               p_content_line    => '******************************************************************************************************',
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
        Exception When Others THEN
	     gz_report.p_put_line (
                     p_one_up_no       => p_seq_no,
                     p_user            => USER,
                     p_job_name        => const_application_name,
                     p_file_number     => v_file_number,
                     p_content_line    => 'SZPCNAN - Error en la actualizacion sfrstcr de asignaturas hijas, pidm '||crse_nivel_1.sfrstcr_pidm||' crn: '||crse_nivel_1.ssbsect_crn
                                         || SQLCODE
                                         || ' - '
                                         || SUBSTR (SQLERRM, 1, 200),
                     p_content_width   => v_page_width,
                     p_content_align   => 'LEFT',       -- LEFT, RIGHT, CENTER
                     p_status          => v_status,
                     p_comments        => v_comments);
                  --DBMS_OUTPUT.put_line ('Error en actualizacion de sfrstcr');
                  ROLLBACK;
                  --RAISE exc_groups_exists;
                  lv_error := 'N';
	   End;
	End Loop;
p_err_code := 'OK';
End p_califica_nivel2;

procedure p_insert_tzrfact_refi (p_pidm number,p_sdoc_code varchar2,p_doc_number varchar2,
p_curr_program varchar2,p_sale_docnum varchar2,p_det_code_doc varchar2,p_amnt_trans number,
p_tran_num number,p_sri_docnum varchar2,p_int_rec_num number, p_fact_date date, p_prefact_date date,
p_activity_date date,p_campus varchar2, p_user varchar2,  p_term_code varchar2,
p_trdparty_id varchar2 default null, p_trdparty_pidm number default null, 
p_trdparty_name varchar2 default null, p_stperdoc_qty varchar2 default null)
is


begin

insert into tzrfact (tzrfact_pidm,
					tzrfact_sdoc_code,
					tzrfact_doc_number,
					tzrfact_id,
					tzrfact_curr_program,
					tzrfact_sale_docnum,
					tzrfact_det_code_doc,
					tzrfact_amnt_trans,
					tzrfact_tran_num,
					tzrfact_sri_docnum,
					tzrfact_internal_receipt_num, 
					tzrfact_fact_date,
					tzrfact_prefact_date,
					tzrfact_activity_date,
                    tzrfact_campus,
					tzrfact_user, 
					tzrfact_term_code, 
					tzrfact_trdparty_id, 
					tzrfact_trdparty_pidm, 
					tzrfact_trdparty_name, 
					tzrfact_stperdoc_qty 
					) 
			values ( p_pidm,
							p_sdoc_code,
							p_doc_number,
							gb_common.f_get_id(p_pidm),
							p_curr_program,
							p_sale_docnum,
							p_det_code_doc,
							p_amnt_trans,
							p_tran_num,
							p_sri_docnum,
							p_int_rec_num, 
							p_fact_date,
							p_prefact_date,
							sysdate,
							p_campus,
							p_user, 
							p_term_code, 
							p_trdparty_id, 
							p_trdparty_pidm, 
							p_trdparty_name, 
							p_stperdoc_qty 
							);
		exception when others then 
	p_ins_tzrrlog(p_pidm,  'p_insert_tzrfact_refi', 'p_insert_tzrfact_refi', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);

end p_insert_tzrfact_refi;    


PROCEDURE p_refin_plan_pago (p_term     varchar2, 
                             p_plan_old NUMBER,
							 p_plan_new NUMBER,
							 p_id       varchar2, 
                             p_one_up_no NUMBER,
							 p_error	IN OUT varchar2
							 ) 
                    IS
    cursor c_docs_anular is 
        select tzrfact_pidm, tzrfact_sdoc_code, tzrfact_doc_number, tzrfact_id, tzrfact_curr_program, tzrfact_sale_docnum, TZRFACT_DET_CODE_DOC, tzrfact_amnt_trans, tzrfact_tran_num, tzrfact_sri_docnum, tzrfact_term_code, tzrfact_campus, tzrfact_internal_receipt_num, tzrfact_prefact_date, tzrfact_fact_date
        from tzrfact fact
        where tzrfact_pidm= gb_common.f_get_pidm(p_id)
        and   tzrfact_sdoc_code = 'XC'
        and   tzrfact_term_code = p_term
        and tzrfact_internal_receipt_num not in (
                select tzrfact_internal_receipt_num 
                from tzrfact 
                where tzrfact_pidm = fact.tzrfact_pidm 
                and tzrfact_sdoc_code = 'BR' 
                and tzrfact_internal_receipt_num = fact.tzrfact_internal_receipt_num
                and tzrfact_term_code = fact.tzrfact_term_code
                )
        and tzrfact_comp_cancel_ind is null;

    --acastillo caso 3244 ajuste al refinanciar ultima cuota
    cursor c_docs_origen is 
        select tzrfact_pidm, tzrfact_sdoc_code, tzrfact_doc_number, tzrfact_id, tzrfact_curr_program, tzrfact_sale_docnum, TZRFACT_DET_CODE_DOC, tzrfact_amnt_trans, tzrfact_tran_num, tzrfact_sri_docnum, tzrfact_term_code, tzrfact_campus, tzrfact_internal_receipt_num, tzrfact_prefact_date, tzrfact_fact_date
        from tzrfact fact
        where tzrfact_pidm= gb_common.f_get_pidm(p_id)
        and   tzrfact_sdoc_code = 'XC'
        and   tzrfact_term_code = p_term
        fetch first 1 rows only;
        --
    v_row_print         varchar2 (1000);
	v_page_width        number;
	v_comments          varchar2 (20000):='';
    v_file_number       guboutp.guboutp_file_number%type := 1;
    v_status            varchar2 (10);
	v_pidm				tzrfact.tzrfact_pidm%type;
	v_doc_number		tzrfact.tzrfact_doc_number%type;
	v_program			tzrfact.TZRFACT_CURR_PROGRAM%type;
	v_sri				tzrfact.tzrfact_sri_docnum%type;
	v_campus			tzrfact.tzrfact_campus%type;
    v_fact_date   		tzrfact.tzrfact_fact_date%type;
	v_prefact_date		tzrfact.tzrfact_prefact_date%type;
	p_folio_comprobante number(13);
    v_doc_num NUMBER;
	v_district  varchar2(3);
	v_error  varchar2(1000);	
    v_seq   tvrsdsq.tvrsdsq_seq_num%TYPE;
    p_interno_cuotas varchar2(20);
    p_prefix2_cuotas TVRSDSQ.TVRSDSQ_PREFIX_2%type;
	p_tran_number 		tbrappl.tbrappl_chg_tran_number%type;
	v_trasac_rever		varchar2(2);
    cursor c_get_prefix2_internal (p_sdoc_cuotas varchar2) is
    select TVRSDSQ_PREFIX_2 from tvrsdsq where TVRSDSQ_SDOC_CODE = p_sdoc_cuotas and trunc(sysdate)<= trunc(TVRSDSQ_VALID_UNTIL);


    cursor c_rfact_regs is 
	select tbraccd_detail_code, tbraccd_amount, tbraccd_tran_number, tbraccd_term_code
	from tbraccd, tbbdetc, tbristl
	where tbraccd_pidm = gb_common.f_get_pidm(p_id)
	and tbraccd_pidm = tbristl_pidm
	and tbraccd_term_code = tbristl_term_code
	and tbraccd_detail_code = tbbdetc_detail_code
	and tbraccd_crossref_number = tbristl_ref_number
	and tbristl_ref_number = p_plan_new
	and tbbdetc_type_ind = 'C'
	and tbraccd_detail_code = tbristl_prin_detail_code
    and tbraccd_tran_number not in (select tzrfact_tran_num 
                                    from tzrfact 
                                    where tzrfact_pidm = tbraccd_pidm
                                    and   tzrfact_sdoc_code = 'XC'
                                    AND   TZRFACT_DET_CODE_DOC = tbraccd_detail_code
                                    AND   TZRFACT_TRAN_NUM = tbraccd_tran_number);

	cursor c_tbrappl is
	select 'Y'
	from tbrappl
	where tbrappl_pidm = gb_common.f_get_pidm(p_id)
	and tbrappl_chg_tran_number = p_tran_number
	and exists  (select tbraccd_tran_number 
				  from tbraccd 
				  where tbraccd_pidm = tbrappl_pidm 
				  and tbraccd_tran_number = tbrappl_pay_tran_number 
				  and tbraccd_amount = tbrappl_amount*-1);

    begin
        v_row_print :=
            gz_report.f_colum_format ('Periodo',
                                      7,
                                      'LEFT',
                                      ' | ')
         || gz_report.f_colum_format ('ID',
                                      9,
                                      'LEFT',
                                      ' | ')
         || gz_report.f_colum_format ('Tipo Documento',
                                      9,
                                      'LEFT',
                                      ' | ')
         || gz_report.f_colum_format ('Trans.',
                                      6,
                                      'LEFT',
                                      ' | ')
		  || gz_report.f_colum_format ('Comprobante Interno',
                                      8,
                                      'LEFT',
                                      ' | ')
          || gz_report.f_colum_format ('Prefactura',
                                      6,
                                      'LEFT',
                                      ' | ')
		  || gz_report.f_colum_format ('Valor',
                                      5,
                                      'LEFT',
                                      ' | ')
		  || gz_report.f_colum_format ('OBS.',
                                      10,
                                      'LEFT',
                                      ' | ');
      --DBMS_OUTPUT.put_line ('v_row_print START: ' || v_row_print);

      gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                            p_user            => USER,
                            p_job_name        => const_application_name,
                            p_file_number     => 1,  --NVL (v_file_number, 1),
                            p_content_line    => v_row_print,
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

      gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                            p_user            => USER,
                            p_job_name        => const_application_name,
                            p_file_number     => 1,  --NVL (v_file_number, 1),
                            p_content_line    => LPAD (' ', v_page_width, '-'),
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

		v_comments := '';
		for docs_anular in c_docs_anular loop
			begin

			p_tran_number := docs_anular.tzrfact_tran_num;

			open c_tbrappl;
			fetch c_tbrappl into v_trasac_rever;
			close c_tbrappl;	

			if v_trasac_rever = 'Y' then

				update tzrfact set tzrfact_comp_cancel_ind = 'Y' 
				where tzrfact_term_code 			= docs_anular.tzrfact_term_code
				and   tzrfact_id 					= docs_anular.tzrfact_id
				and   tzrfact_tran_num  			= docs_anular.tzrfact_tran_num
				and   tzrfact_internal_receipt_num  = docs_anular.tzrfact_internal_receipt_num;
  			    v_comments := 'Anulada';
			else
				v_comments := 'Error: Trans. no reversada';			
			end if;

				v_row_print :=
				gz_report.f_colum_format (docs_anular.tzrfact_term_code,7,'LEFT',' | ')
				|| gz_report.f_colum_format (docs_anular.tzrfact_id,9,'LEFT',' | ')
				|| gz_report.f_colum_format (docs_anular.tzrfact_sdoc_code,9,'LEFT',' | ')
				|| gz_report.f_colum_format (docs_anular.tzrfact_tran_num,6,'LEFT',' | ')
				|| gz_report.f_colum_format (docs_anular.tzrfact_internal_receipt_num,8,'LEFT',' | ')
				|| gz_report.f_colum_format (docs_anular.tzrfact_sale_docnum,6,'LEFT',' | ')
				|| gz_report.f_colum_format (docs_anular.tzrfact_amnt_trans,5,'LEFT',' | ')
				|| gz_report.f_colum_format (v_comments,26,'LEFT',' | ');
            --exception when others then   
			gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                               p_user            => USER,
                               p_job_name        => const_application_name,
                               p_file_number     => 1, --NVL (v_file_number, 1),
                               p_content_line    => v_row_print,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);



			commit;
			p_error := 'OK';			
			exception when others then
				p_error := 'ERROR';
                p_ins_tzrrlog(docs_anular.tzrfact_pidm,  'error p_insert_tzrfact_refi', 'p_insert_tzrfact_refi', SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);
      gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                            p_user            => USER,
                            p_job_name        => const_application_name,
                            p_file_number     => 1,  --NVL (v_file_number, 1),
                            p_content_line    => 'Error '||SUBSTR (SQLERRM, 1, 500),
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);
			end;

		end loop;
        --acastillo caso 3244 ajuste al refinanciar ultima cuota
 		for docs_origen in c_docs_origen loop
            v_pidm				:= gb_common.f_get_pidm(p_id);
			v_doc_number		:= docs_origen.tzrfact_doc_number;
			v_program			:= docs_origen.tzrfact_curr_program;
			v_sri				:= docs_origen.tzrfact_sri_docnum;
			v_campus			:= docs_origen.tzrfact_campus;
			v_fact_date   		:= docs_origen.tzrfact_fact_date;
			v_prefact_date		:= docs_origen.tzrfact_prefact_date;
        end loop;
        --
        gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                            p_user            => USER,
                            p_job_name        => const_application_name,
                            p_file_number     => 1,  --NVL (v_file_number, 1),
                            p_content_line    => 'Creación de registros en TZRFACT para nuevas cuotas plan '||p_plan_new,
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);

			for rfact_regs in c_rfact_regs loop
				begin

					OPEN c_get_prefix2_internal ('XC');
					fetch c_get_prefix2_internal into p_prefix2_cuotas;
					close c_get_prefix2_internal;


                     tzkpufc.p_get_next_folio (p_doctype         => 'XC',
								  p_user            => USER, 
								  p_camp_code       => v_campus,
								  p_prefix1         => substr(v_doc_number,7,1),
								  p_prefix2         => p_prefix2_cuotas,
								  p_next_numdoc     => v_doc_num, 
								  p_seq             => v_seq,    
								  p_errormsg        => v_error,
								  p_camp_district   => v_district);

					p_interno_cuotas := v_district ||p_prefix2_cuotas|| lpad(v_doc_num,11,'0');                         

				p_ins_tzrrlog(v_pidm,  'SZPREFI', 'p_refin_plan_pago: ', v_doc_number ||' v_sdoc_code:'||'XC'
				 ||' rfact_regs.tbraccd_term_code:'||rfact_regs.tbraccd_term_code||' rfact_regs.tbraccd_detail_code:'||rfact_regs.tbraccd_detail_code||' rfact_regs.tbraccd_tran_number:'||rfact_regs.tbraccd_tran_number||' v_user:'||user||' v_campus:'||v_campus
				 ||' v_program:'||v_program||' p_interno_cuotas:'||p_interno_cuotas||' v_error:'||v_error, user);


				IF v_doc_num is not null then           

						   UPDATE tvrsdsq
						   SET tvrsdsq_max_seq = v_doc_num,
							   TVRSDSQ_ACTIVITY_DATE = SYSDATE,
							   TVRSDSQ_DATA_ORIGIN = 'SZPREFI',
							   TVRSDSQ_USER_ID = USER
						 WHERE     tvrsdsq_sdoc_code = 'XC'
							   AND tvrsdsq_fbpr_code IN
									   (SELECT gorfbpr_fbpr_code
										  FROM gorfbpr
										 WHERE gorfbpr_fgac_user_id = USER)
							   AND tvrsdsq_valid_until >= SYSDATE
							   AND tvrsdsq_prefix_1 = v_district
							   AND tvrsdsq_prefix_2 = p_prefix2_cuotas
							   AND tvrsdsq_camp_code = v_campus;
					END IF;

					tzkpufc.p_insert_tzrfact_refi (
							p_pidm            => v_pidm,
							p_sdoc_code       => 'XC',
							p_doc_number      => v_doc_number,
							p_curr_program    => v_program,
							p_sale_docnum     => tzkpufc.f_get_docnum_fmt(v_doc_number),
							p_det_code_doc    => rfact_regs.tbraccd_detail_code,
							p_amnt_trans      => rfact_regs.tbraccd_amount,
							p_tran_num        => rfact_regs.tbraccd_tran_number, 
							p_sri_docnum      => v_sri,
							p_int_rec_num     => p_interno_cuotas,
							p_fact_date       => v_fact_date,
							p_prefact_date	  => v_prefact_date, 
							p_activity_date   => sysdate,							
							p_campus    	  => v_campus,
							p_user            => user,
							p_term_code => rfact_regs.tbraccd_term_code,
							p_trdparty_id => null, 
							p_trdparty_pidm => null, 
							p_trdparty_name =>null, 
							p_stperdoc_qty =>1
							); 
                            commit;

					v_row_print :=
				gz_report.f_colum_format (rfact_regs.tbraccd_term_code,7,'LEFT',' | ')
				|| gz_report.f_colum_format (gb_common.f_get_id(v_pidm),9,'LEFT',' | ')
				|| gz_report.f_colum_format ('XC',9,'LEFT',' | ')
				|| gz_report.f_colum_format (rfact_regs.tbraccd_tran_number,24,'LEFT',' | ')
				|| gz_report.f_colum_format (p_interno_cuotas,8,'LEFT',' | ')
				|| gz_report.f_colum_format (v_doc_number,6,'LEFT',' | ')
				|| gz_report.f_colum_format (rfact_regs.tbraccd_amount,5,'LEFT',' | ')
				|| gz_report.f_colum_format ('--',10,'LEFT',' | ');

				gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                               p_user            => USER,
                               p_job_name        => const_application_name,
                               p_file_number     => 1, --NVL (v_file_number, 1),
                               p_content_line    => v_row_print,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
				p_error := 'OK';			
			exception when others then
			rollback;
				p_error := 'ERROR';
                p_ins_tzrrlog(v_pidm,  'error p_insert_tzrfact_refi', 'p_insert_tzrfact_refi p_interno_cuotas', p_interno_cuotas||' '||SQLCODE || '-' || SUBSTR (SQLERRM, 1, 500), user);
			gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                            p_user            => USER,
                            p_job_name        => const_application_name,
                            p_file_number     => 1,  --NVL (v_file_number, 1),
                            p_content_line    => 'Error '||SUBSTR (SQLERRM, 1, 500),
                            p_content_width   => v_page_width,
                            p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                            p_status          => v_status,
                            p_comments        => v_comments);
			end;
			end loop;
	--end;

END p_refin_plan_pago;

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
      v_area            VARCHAR2 (10);
      v_mod             VARCHAR2 (1);                             -- requerido
      v_pidm            NUMBER (9);
      v_id              varchar2 (30);
      v_plan_old        tbristl.tbristl_ref_number%type;
      v_plan_new        tbristl.tbristl_ref_number%type;
      v_name            VARCHAR (60) := NULL;
      v_run_type        VARCHAR2 (30) := NULL;
   BEGIN
      -- creamos archivo lis y pintamos encabezado
      -- RETURN;
      --p_log (p_one_up_no, v_user_id, 'SZPCNAN - p_create_header ');
      p_create_headerTZPREFI (p_one_up_no, USER, v_file_number);
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
                                || v_job_rec.r_gjbprun_value
                                || '.',
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',                -- LEFT, RIGHT, CENTER
            p_status          => v_status,
            p_comments        => v_comments);


         -- almacenamos en variables locales los valores a ocupar para procesar los datos
         CASE v_job_rec.r_gjbprun_number
            WHEN '01'
            THEN
               v_term := v_job_rec.r_gjbprun_value;
            WHEN '02'
            THEN
               v_plan_old := v_job_rec.r_gjbprun_value;
            WHEN '03'
            THEN
               v_plan_new := v_job_rec.r_gjbprun_value;
            WHEN '04'
            then
               v_id := v_job_rec.r_gjbprun_value;
            else            
               NULL;
         END CASE;
      END LOOP;

      -- If no parameters required are found, the job must be stopped
      IF (v_term IS NULL OR v_plan_old is null or v_plan_new is null or v_id IS NULL)
      THEN

         -- se imprime mensaje en archivo LIS
         gz_report.p_put_line (
            p_one_up_no       => p_one_up_no,
            p_user            => v_user_id,
            p_job_name        => const_application_name,
            p_file_number     => 1,                           --v_file_number,
            p_content_line    => 'SZPREFI - Invalid parameters found.',
            p_content_width   => v_page_width,
            p_content_align   => 'LEFT',                -- LEFT, RIGHT, CENTER
            p_status          => v_status,
            p_comments        => v_comments);

         --RAISE exc_issue_already_logged;
      END IF;

      CLOSE v_job_ref;

      --p_log (p_one_up_no, v_user_id, 'Inicio de Proceso de alumnos.');

      --Proceso que obtiene a los alumnos a reportar --

             p_refin_plan_pago (p_term      => v_term,
							   p_plan_old   => v_plan_old,
							   p_plan_new   => v_plan_new,
							   p_id     => v_id,
                               p_one_up_no => p_one_up_no,
							   p_error => v_err_code);


      --p_log (p_one_up_no, v_user_id, 'Fin de Proceso de copia de componentes calificables.');

        v_err_code := 'OK';
      IF v_err_code = 'OK'      
      THEN
         v_row_print := 'Proceso SZPREFI, ejecutado satisfactoriamente.';
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
      ELSE
         v_row_print := 'Error :' || v_err_code || '-' || v_err_msg;
         gz_report.p_put_line (p_one_up_no       => p_one_up_no,
                               p_user            => v_user_id,
                               p_job_name        => const_application_name,
                               p_file_number     => NVL (v_file_number, 1),
                               p_content_line    => v_row_print,
                               p_content_width   => v_page_width,
                               p_content_align   => 'LEFT', -- LEFT, RIGHT, CENTER
                               p_status          => v_status,
                               p_comments        => v_comments);
      END IF;

      gb_common.p_commit;
   End p_main;

END tzkpufc;



--SET DEFINE OFF;


/
