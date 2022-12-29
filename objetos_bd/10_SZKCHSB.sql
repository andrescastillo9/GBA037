CREATE OR REPLACE package SZKCHSB as
   FUNCTION f_get_credits (p_pidm in number, p_aidy_code in varchar2, p_aidp_code in varchar2) return varchar2;
   FUNCTION f_stu_insc (p_pidm in number, p_aidy_code in varchar2, p_aidp_code in varchar2) return varchar2;
   FUNCTION f_disbursed_ind (p_pidm in number, p_AIDY_CODE in varchar2, p_AIDP_CODE in varchar2,  p_FNDC_CODE in varchar2 default null) return varchar2;
   procedure  p_exe_change_benefits (p_AIDY_CODE in varchar2, p_AIDP_CODE  in varchar2, P_ID in varchar2);
   procedure  p_change_benefits;

   procedure p_ins_datablock (p_ID in varchar2, p_PIDM in number, p_AIDY_CODE in varchar2, p_AIDP_CODE in varchar2, p_TERM_CODE in varchar2, p_chg_stat_bene in varchar2, p_USER_ID in varchar2, p_DATA_ORIGIN in varchar2);
 end SZKCHSB;

/


CREATE OR REPLACE PACKAGE BODY SZKCHSB IS
 
 FUNCTION f_disbursed_ind (p_pidm in number, p_AIDY_CODE in varchar2, p_AIDP_CODE in varchar2,  p_FNDC_CODE in varchar2 default null) return varchar2
 is
 p_disbursed_ind     KVRAWRD.KVRAWRD_FUND_DISB_IND%type;

  cursor c_get_awrd_disb_ind (p_pidm in number, p_AIDY_CODE in varchar2, p_AIDP_CODE in varchar2,  p_FNDC_CODE in varchar2 default null) is
   SELECT  DISTINCT
     x.kvrawrd_fund_disb_ind   
 FROM
     kvrawrd x
 WHERE 
     x.kvrawrd_pidm = p_pidm
     AND   x.kvrawrd_aidy_code = p_aidy_code
     AND   x.kvrawrd_aidp_code = p_aidp_code
     AND   x.kvrawrd_fndc_code = nvl(p_fndc_code,x.kvrawrd_fndc_code)
     AND   x.kvrawrd_fndc_seq_no = (
         SELECT 
              nvl(MAX(y.kvrawrd_fndc_seq_no),0)
         FROM
             kvrawrd y
         WHERE
             y.kvrawrd_pidm = x.kvrawrd_pidm
             AND   y.kvrawrd_aidy_code = x.kvrawrd_aidy_code
             AND   y.kvrawrd_aidp_code = x.kvrawrd_aidp_code
             AND   y.kvrawrd_fndc_code = x.kvrawrd_fndc_code
     )
     AND   x.kvrawrd_fsta_status_cde NOT IN (
         'REV',
         'CANC'
     ); -- para ya no considerar los REV y CANC        


 begin

     open c_get_awrd_disb_ind(p_pidm, p_AIDY_CODE, p_AIDP_CODE, p_FNDC_CODE);
     fetch c_get_awrd_disb_ind into p_disbursed_ind;
     close c_get_awrd_disb_ind;

 return (p_disbursed_ind);
 end;



 FUNCTION f_stu_insc (p_pidm in number, p_aidy_code in varchar2, p_aidp_code in varchar2) return varchar2
 is
 p_inscrito varchar2(1);

 cursor c_student_inscr is
  select distinct 'Y' --SFRSTCR_RSTS_CODE
    from sfrstcr
   where sfrstcr_pidm = p_pidm and
         sfrstcr_term_code = ( select kvrdsdf_term_code
                                 from kvrdsdf
                                where kvrdsdf_aidy_code = p_aidy_code and
                                      kvrdsdf_aidp_code = p_aidp_code) and
         --sfrstcr_rsts_code like 'R%';
         sfrstcr_rsts_code in (select STVRSTS_CODE from STVRSTS where STVRSTS_VOICE_TYPE = 'R');

  begin
    open c_student_inscr;
    fetch  c_student_inscr into p_inscrito;
    close c_student_inscr;

   return nvl(p_inscrito,'N');
 end;

  FUNCTION f_get_credits (p_pidm in number, p_aidy_code in varchar2, p_aidp_code in varchar2) return varchar2   
  is
  p_credits number;
  cursor c_get_credits is
  select count(sfrstcr_bill_hr) -- into p_creditos
    from sfrstcr
   where sfrstcr_pidm = p_pidm and
         sfrstcr_term_code = ( select kvrdsdf_term_code
                                 from kvrdsdf
                                where kvrdsdf_aidy_code = p_aidy_code and
                                      kvrdsdf_aidp_code = p_aidp_code) and
         --sfrstcr_rsts_code like 'R%';
         sfrstcr_rsts_code in (select STVRSTS_CODE from STVRSTS where STVRSTS_VOICE_TYPE = 'R');

  begin
    open c_get_credits;
    fetch  c_get_credits into p_credits;
    close c_get_credits;

   return p_credits;
 end;


 procedure  p_change_benefits 
      is
    --
     lv_aidy   VARCHAR2 (100);
     lv_aidp   VARCHAR2 (100);
     lv_err_msg    VARCHAR2 (200);
     lv_id   varchar2(12);

    begin

        gkkpsql.writediagnostictodb (35,'Reading parameters for user:  ' || USER);
        gkkpsql.api_retrieverulesetparameter ('P1101_AIDY_CODE_SRC',
                                              lv_aidy,
                                              lv_err_msg);
        gkkpsql.api_retrieverulesetparameter ('P1102_AIDP_CODE_SRC',
                                              lv_aidp,
                                              lv_err_msg);
        gkkpsql.api_retrieverulesetparameter ('P1101_ID',
                                              lv_id,
                                              lv_err_msg);
        gkkpsql.writediagnostictodb (35, 'Parameter P1101_AIDY_CODE = ' || lv_aidy);
        gkkpsql.writediagnostictodb (35, 'Parameter P1102_AIDP_CODE = ' || lv_aidp);
        gkkpsql.writediagnostictodb (35, 'Parameter P1101_ID = ' || lv_id);

        gkkpsql.writediagnostictodb (35, 'Execute Process Change of Benefit Status');

        p_exe_change_benefits (p_AIDY_CODE => lv_aidy, p_AIDP_CODE => lv_aidp, P_ID => lv_id);

        gkkpsql.writediagnostictodb (35,'End Process Change of Benefit Status');

 end;


 procedure  p_exe_change_benefits (p_AIDY_CODE in varchar2, p_AIDP_CODE  in varchar2, P_ID in varchar2) 
    is
     v_pidm varchar2(10);
     v_term_code     KVRDSDF.KVRDSDF_TERM_CODE%type;
     v_sql           varchar2(2000);
     p_ind_disb      KVRAWRD.KVRAWRD_FUND_DISB_IND%type;
     P_FNDC_SEQ_NO   KVRAWRD.KVRAWRD_FNDC_SEQ_NO%type;
       P_REV_MEMO_AMT KVRAWRD.KVRAWRD_MEMO_AMT%TYPE;
       P_REV_PAID_AMT KVRAWRD.KVRAWRD_PAID_AMT%TYPE;
       P_AR_HOLD_OVR_IND VARCHAR2(200);
       P_ERROR_IND VARCHAR2(200);
       P_ERROR_MSG VARCHAR2(500);

  --   
     cursor c_get_term_code (p_AIDY_code varchar2,p_AIDP_code varchar2 ) is
     SELECT KVRDSDF_TERM_CODE 
     FROM KVRDSDF
     WHERE KVRDSDF_AIDY_CODE = p_AIDY_code 
       AND KVRDSDF_AIDP_CODE = p_AIDP_code;


      cursor c_get_students (p_AIDY_code varchar2, p_AIDP_code varchar2, p_pidm varchar2) is
      SELECT  x.*
           , SZKCHSB.f_get_credits(x.kvrawrd_pidm,  x.kvrawrd_aidy_code, x.kvrawrd_aidp_code) num_credits
           , SZKCHSB.f_stu_insc(x.kvrawrd_pidm,  x.kvrawrd_aidy_code, x.kvrawrd_aidp_code) stu_ins 
 FROM
     kvrawrd x
 WHERE 
               x.kvrawrd_aidy_code = p_aidy_code
     AND   x.kvrawrd_aidp_code = p_aidp_code
     AND   x.kvrawrd_pidm = p_pidm
     --AND   x.kvrawrd_fndc_code = nvl(:p_fndc_code,x.kvrawrd_fndc_code)
     AND   x.kvrawrd_fndc_seq_no = (
         SELECT 
              nvl(MAX(y.kvrawrd_fndc_seq_no),0)
         FROM
             kvrawrd y
         WHERE
             y.kvrawrd_pidm = x.kvrawrd_pidm
             AND   y.kvrawrd_aidy_code = x.kvrawrd_aidy_code
             AND   y.kvrawrd_aidp_code = x.kvrawrd_aidp_code
             AND   y.kvrawrd_fndc_code = x.kvrawrd_fndc_code
     )
     AND   x.kvrawrd_fsta_status_cde NOT IN (
         'REVO',
         'CANC'
     ); -- para ya no considerar los REV y CANC        



 BEGIN
         v_pidm := null;
         v_pidm := gb_common.f_get_pidm(P_ID);

         open c_get_term_code (p_AIDY_CODE, p_AIDP_CODE);
         fetch c_get_term_code into v_term_code;
         close c_get_term_code;

        FOR stu_rec IN c_get_students (p_AIDY_CODE, p_AIDP_CODE, v_pidm) LOOP                     
        -- 

           gkkpsql.writediagnostictodb (40, 'ID = ' || gb_common.f_get_id(stu_rec.KVRAWRD_PIDM)||' FNDC_CODE= '||stu_rec.KVRAWRD_FNDC_CODE||' NUM_CREDITS= '||stu_rec.NUM_CREDITS || ' STU_INS= '||stu_rec.STU_INS || ' fund_disb_ind= '||stu_rec.kvrawrd_fund_disb_ind);   

          IF   stu_rec.STU_INS = 'N' then

             IF stu_rec.kvrawrd_fund_disb_ind = 'Y' then
         -- si revocar
               begin
                 KVP_AWARD_DISBURSE.P_REVOKE_AWARD(
                                                     P_PIDM => stu_rec.KVRAWRD_PIDM,
                                                     P_AIDY_CODE => stu_rec.KVRAWRD_AIDY_CODE,
                                                     P_AIDP_CODE => stu_rec.KVRAWRD_AIDP_CODE,
                                                     P_FNDC_CODE => stu_rec.KVRAWRD_FNDC_CODE,
                                                     P_FNDC_SEQ_NO => stu_rec.KVRAWRD_FNDC_SEQ_NO,
                                                     P_TBBMISC_REC => null,
                                                     --P_DISB_AMT_DECR_IND => P_DISB_AMT_DECR_IND,
                                                     --P_DETAIL_CODE => P_DETAIL_CODE,
                                                     P_DATA_ORIGIN => 'REVOKE_MDUU_SZKCHSB',
                                                     P_USER_ID => user,
                                                     --P_UPDATE_MODE => P_UPDATE_MODE,
                                                     P_REV_MEMO_AMT => P_REV_MEMO_AMT,
                                                     P_REV_PAID_AMT => P_REV_PAID_AMT,
                                                     P_AR_HOLD_OVR_IND => P_AR_HOLD_OVR_IND,
                                                     P_ERROR_IND => P_ERROR_IND,
                                                     P_ERROR_MSG => P_ERROR_MSG
                                                   );

                     update kvrawrd
                     set kvrawrd_fsta_status_cde='REVO',
                     kvrawrd_offer_amt='',
                     kvrawrd_offer_date='',
                     kvrawrd_accept_amt='',
                     kvrawrd_accept_date='',
                     KVRAWRD_ACTIVITY_DATE = sysdate
                     where kvrawrd_pidm= stu_rec.KVRAWRD_PIDM and
                     kvrawrd_aidy_code=stu_rec.KVRAWRD_AIDY_CODE and
                     kvrawrd_aidp_code=stu_rec.KVRAWRD_AIDP_CODE and
                     kvrawrd_fndc_code=stu_rec.KVRAWRD_FNDC_CODE and
                     kvrawrd_fndc_seq_no=stu_rec.KVRAWRD_FNDC_SEQ_NO;
                     commit;   


                     p_ins_datablock (gb_common.f_get_id(stu_rec.KVRAWRD_PIDM), stu_rec.KVRAWRD_PIDM,  p_AIDY_CODE, p_AIDP_CODE,v_term_code, 'REV', user,'SZKCHSB');                              
                     gkkpsql.writediagnostictodb (40, 'ID = ' || gb_common.f_get_id(stu_rec.KVRAWRD_PIDM) || ' Beca Revocada');

                exception
                       when OTHERS then
                       P_ERROR_IND := SQLCODE;
                       P_ERROR_MSG := SUBSTR(sqlerrm,1,255);
                end;                                   
             ELSIF stu_rec.kvrawrd_fund_disb_ind = 'N' then
         -- no -> cancelar
                 begin
                     update kvrawrd
                     set kvrawrd_fsta_status_cde='CANC',
                     KVRAWRD_DATA_ORIGIN = 'CANCEL_MDUU_SZKCHSB',
                     kvrawrd_offer_amt='',
                     kvrawrd_offer_date='',
                     kvrawrd_accept_amt='',
                     kvrawrd_accept_date='',
                     KVRAWRD_ACTIVITY_DATE = sysdate
                     where kvrawrd_pidm= stu_rec.KVRAWRD_PIDM and
                     kvrawrd_aidy_code=stu_rec.KVRAWRD_AIDY_CODE and
                     kvrawrd_aidp_code=stu_rec.KVRAWRD_AIDP_CODE and
                     kvrawrd_fndc_code=stu_rec.KVRAWRD_FNDC_CODE and
                     kvrawrd_fndc_seq_no=stu_rec.KVRAWRD_FNDC_SEQ_NO;
                     commit;   

                     p_ins_datablock (gb_common.f_get_id(stu_rec.KVRAWRD_PIDM), stu_rec.KVRAWRD_PIDM,  p_AIDY_CODE, p_AIDP_CODE,v_term_code, 'CANC', user,'SZKCHSB');                              
                     gkkpsql.writediagnostictodb (40, 'ID = ' || gb_common.f_get_id(stu_rec.KVRAWRD_PIDM) || ' Beca Cancelada');
                exception
                       when OTHERS then
                       P_ERROR_IND := SQLCODE;
                       P_ERROR_MSG := SUBSTR(sqlerrm,1,255);
                end;                                        
             ELSE
               null;
             END IF;
         END IF;
        --   
        END LOOP;

       END p_exe_change_benefits;

  procedure p_ins_datablock (p_ID in varchar2, p_PIDM in number, p_AIDY_CODE in varchar2, p_AIDP_CODE in varchar2, p_TERM_CODE in varchar2, p_chg_stat_bene in varchar2, p_USER_ID in varchar2, p_DATA_ORIGIN in varchar2)
  is
  begin
  insert into SZRCHSB (SZRCHSB_ID, SZRCHSB_PIDM, SZRCHSB_AIDY_CODE, SZRCHSB_AIDP_CODE, SZRCHSB_TERM_CODE, SZRCHSB_CHG_STAT_BENE,  SZRCHSB_USER_ID, SZRCHSB_ACTIVITY_DATE, SZRCHSB_DATA_ORIGIN) 
               values (p_ID, p_PIDM, p_AIDY_CODE, p_AIDP_CODE, p_TERM_CODE, p_chg_stat_bene ,p_USER_ID, sysdate, p_DATA_ORIGIN);
  gb_common.p_commit;              
  exception when others then null;
  end p_ins_datablock;


 end SZKCHSB;

/
