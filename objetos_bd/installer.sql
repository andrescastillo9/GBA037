--Reinstalar package principal tzklscl.sql con Baninst1
@01_TZKLSCL.sql
--Reinstalar package seg y tercera matricula con Baninst1 
@02_SB_CALCULO_SEG_TER_MATRICULA.sql
--Configurar mduu con BANSECR o BANINST1
@03_MDUUGBA037configuracion.sql
--Compilar 04_szpdnrc.pc
--dar de alta szpdnrc
@05_alta_szpdnrc.sql con BANSECR
--configurar mduu de anulacion prefacturas con BANSECR
@06_MDUU001_configuracion.sql
--instalar package TZKPRFA0 BANINST1
@07_TZKPRFA0.sql
