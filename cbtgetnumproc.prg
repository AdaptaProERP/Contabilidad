// Programa   : CBTGETNUMPROC
// Fecha/Hora : 09/03/2023 18:03:03
// Propósito  : Obtener número del Proceso
// Creado Por : Juan Navas
// Llamado por: Procesos de Contabilización
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc)
   LOCAL cNumPro,cWhere

   DEFAULT cCodSuc:=oDp:cSucursal

   cWhere:="CBT_CODSUC"+GetWhere("=",cCodSuc)+" AND CBT_ACTUAL"+GetWhere("=","N")

   cNumPro:=SQLINCREMENTAL("DPCBTE","CBT_NUMPRO",cWhere,NIL,NIL,.T.,6)

   oDp:cNumPro:=cNumPro

RETURN cNumPro
// EOF
