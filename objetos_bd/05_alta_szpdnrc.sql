-- Set Security Object
    DELETE FROM BANSECR.GURAOBJ WHERE GURAOBJ_OBJECT = 'SZPDNRC';
    
    INSERT INTO BANSECR.GURAOBJ(GURAOBJ_OBJECT, GURAOBJ_DEFAULT_ROLE, GURAOBJ_CURRENT_VERSION, GURAOBJ_SYSI_CODE, GURAOBJ_ACTIVITY_DATE, GURAOBJ_CHECKSUM)
                         VALUES('SZPDNRC',      'BAN_DEFAULT_M',      '1.0',                  'S',                SYSDATE,               NULL);
    COMMIT;

    -- Set Security Class
    DELETE FROM BANSECR.GURUOBJ WHERE GURUOBJ_OBJECT = 'SZPDNRC';
    
    INSERT INTO BANSECR.GURUOBJ(GURUOBJ_OBJECT, GURUOBJ_ROLE, GURUOBJ_USERID, GURUOBJ_ACTIVITY_DATE)
                         VALUES('SZPDNRC',      'BAN_DEFAULT_M',  USER,  SYSDATE);
    COMMIT;

    -- Set Security Owner to PUBLIC
    DELETE FROM BANSECR.GUROWNR WHERE GUROWNR_OBJECT = 'SZPDNRC';    
    COMMIT;
    
    INSERT INTO BANSECR.GUROWNR(GUROWNR_OWNER,
                                GUROWNR_OBJECT,
                                GUROWNR_OBJECT_TYPE,
                                GUROWNR_GRANTOR,
                                GUROWNR_PRIV_GRANT,
                                GUROWNR_PRIV_GRANT_ASSIGN,
                                GUROWNR_PRIV_REVOKE,
                                GUROWNR_PRIV_REVOKE_ASSIGN,
                                GUROWNR_PRIV_DELETE,
                                GUROWNR_PRIV_DELETE_ASSIGN,
                                GUROWNR_PRIV_MODIFY,
                                GUROWNR_PRIV_MODIFY_ASSIGN,
                                GUROWNR_USER_ID,
                                GUROWNR_ACTIVITY_DATE,
                                GUROWNR_COMMENTS,
                                GUROWNR_DATA_ORIGIN)
    VALUES('PUBLIC',
           'SZPDNRC',
           'O',
           'BANSECR',
           'Y',
           'Y',
           'Y',
           'Y',
           'Y',
           'Y',
           'Y',
           'Y',
           'BANSECR',
           SYSDATE,
           NULL,
           NULL);
    
    COMMIT;    
    
    -- Create Job Submission Obj
    DELETE FROM GUBOBJS WHERE GUBOBJS_NAME = 'SZPDNRC';
    
    INSERT INTO GUBOBJS(GUBOBJS_NAME,
                        GUBOBJS_DESC,
                        GUBOBJS_OBJT_CODE,
                        GUBOBJS_SYSI_CODE,
                        GUBOBJS_USER_ID,
                        GUBOBJS_ACTIVITY_DATE,
                        GUBOBJS_HELP_IND,
                        GUBOBJS_EXTRACT_ENABLED_IND)
    VALUES('SZPDNRC',
           'Borrado / Actualización NRCs',
           'JOBS',
           'S',
           'LOCAL',
           SYSDATE,
           'N',
           'N');
    
    COMMIT;
    
-- Create Job Submission Definition
  DELETE FROM GJBJOBS WHERE GJBJOBS_NAME = 'SZPDNRC';
  
  SET DEFINE OFF;
  INSERT INTO GJBJOBS(GJBJOBS_NAME,
                            GJBJOBS_TITLE,
                            GJBJOBS_ACTIVITY_DATE,
                            GJBJOBS_SYSI_CODE,
                            GJBJOBS_JOB_TYPE_IND,
                            GJBJOBS_DESC,
                            GJBJOBS_PRNT_CODE )
        VALUES('SZPDNRC',
               'Borrado / Actualización NRCs',
               SYSDATE,
               'S',
               'C',
               'Proceso Borrado / Actualización NRCs',
               '');
               
        COMMIT;
        

delete from GENERAL.GJBPDEF where GJBPDEF_JOB = 'SZPDNRC';
commit;

Insert into GENERAL.GJBPDEF
   (GJBPDEF_JOB, GJBPDEF_NUMBER, GJBPDEF_DESC, GJBPDEF_LENGTH, GJBPDEF_TYPE_IND, GJBPDEF_OPTIONAL_IND, GJBPDEF_SINGLE_IND, GJBPDEF_ACTIVITY_DATE, GJBPDEF_HELP_TEXT, GJBPDEF_VALIDATION, GJBPDEF_LIST_VALUES)
 Values
   ('SZPDNRC', '01', 'ID', 20, 'C', 
    'O', 'S', SYSDATE, 
    'ID (Vacío para todos)', '', '');	
Insert into GENERAL.GJBPDEF
   (GJBPDEF_JOB, GJBPDEF_NUMBER, GJBPDEF_DESC, GJBPDEF_LENGTH, GJBPDEF_TYPE_IND, GJBPDEF_OPTIONAL_IND, GJBPDEF_SINGLE_IND, GJBPDEF_ACTIVITY_DATE, GJBPDEF_HELP_TEXT, GJBPDEF_VALIDATION, GJBPDEF_LIST_VALUES)
 Values
   ('SZPDNRC', '02', 'Periodo Academico', 6, 'C', 
    'R', 'S', SYSDATE, 
    'Periodo Académico', 'STVTERM_EQUAL', 'STVTERM');
Insert into GENERAL.GJBPDEF
   (GJBPDEF_JOB, GJBPDEF_NUMBER, GJBPDEF_DESC, GJBPDEF_LENGTH, GJBPDEF_TYPE_IND, GJBPDEF_OPTIONAL_IND, GJBPDEF_SINGLE_IND, GJBPDEF_ACTIVITY_DATE, GJBPDEF_HELP_TEXT, GJBPDEF_VALIDATION, GJBPDEF_LIST_VALUES)
 Values
   ('SZPDNRC', '03', 'Campus', 4, 'C', 
    'O', 'S', SYSDATE, 
    'Campus', 'STVCAMP_EQUAL', 'STVCAMP');
	
Insert into GENERAL.GJBPDEF
   (GJBPDEF_JOB, GJBPDEF_NUMBER, GJBPDEF_DESC, GJBPDEF_LENGTH, GJBPDEF_TYPE_IND, GJBPDEF_OPTIONAL_IND, GJBPDEF_SINGLE_IND, GJBPDEF_ACTIVITY_DATE, GJBPDEF_HELP_TEXT, GJBPDEF_VALIDATION, GJBPDEF_LIST_VALUES)
 Values
   ('SZPDNRC', '04', 'Tipo Alumno', 20, 'C', 
    'O', 'S', SYSDATE, 
    '<> TIpo Tipo Alumno ', '', '');	

COMMIT;

delete from GENERAL.GJBPDFT where GJBPDFT_JOB='SZPDNRC';
commit;

Insert into GENERAL.GJBPDFT
   (GJBPDFT_JOB, GJBPDFT_NUMBER, GJBPDFT_ACTIVITY_DATE)
 Values
   ('SZPDNRC', '01', SYSDATE);
   
Insert into GENERAL.GJBPDFT
   (GJBPDFT_JOB, GJBPDFT_NUMBER, GJBPDFT_ACTIVITY_DATE)
 Values
   ('SZPDNRC', '02', SYSDATE);
   
Insert into GENERAL.GJBPDFT
   (GJBPDFT_JOB, GJBPDFT_NUMBER, GJBPDFT_ACTIVITY_DATE)
 Values
   ('SZPDNRC', '03', SYSDATE);
   
Insert into GENERAL.GJBPDFT
   (GJBPDFT_JOB, GJBPDFT_NUMBER, GJBPDFT_ACTIVITY_DATE)
 Values
   ('SZPDNRC', '04', SYSDATE);
   COMMIT;
