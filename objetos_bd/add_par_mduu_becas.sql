select *
from GKVSVBA
where GKVSVBA_CODE = 'MDUU_CAMBIO_BENEFICIOS'

SZKCHSB.P_CHANGE_BENEFITS

select *
from GKVSQPA
where GKVSQPA_CODE like '%P1101%';

Insert into GKVSQPA (GKVSQPA_CODE,GKVSQPA_DESC,GKVSQPA_DATA_TYPE_CDE,GKVSQPA_START_DATE,GKVSQPA_ACTIVITY_DATE,GKVSQPA_USER_ID,GKVSQPA_END_DATE,GKVSQPA_SURROGATE_ID,GKVSQPA_VERSION,GKVSQPA_DATA_ORIGIN,GKVSQPA_VPDI_CODE) 
values ('P1101_ID','id Estudiante','C',sysdate-1,sysdate-1,'SAISUSR',null,null,null,null,null);

Insert into GKRSQPA (GKRSQPA_SQPR_CODE,GKRSQPA_SQPA_CODE,GKRSQPA_SYS_REQ_IND,GKRSQPA_ACTIVITY_DATE,GKRSQPA_USER_ID,GKRSQPA_SURROGATE_ID,GKRSQPA_VERSION,GKRSQPA_DATA_ORIGIN,GKRSQPA_VPDI_CODE) 
VALUES ('MDUU_CAMBIO_BENEFICIOS','P1101_ID','S',SYSDATE-1,'SAISUSR',NULL,NULL,NULL,NULL);

