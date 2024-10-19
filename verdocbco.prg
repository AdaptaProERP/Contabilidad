// Programa   : VERDOCBCO
// Fecha/Hora : 18/10/2024 23:06:55
// Prop�sito  : Ver Documento del Banco
// Creado Por : Juan Navas
// Llamado por: DPASIENTOSFRMORG
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,cAplOrg)
  LOCAL cCodBco

  cCodBco:=SQLGET("DPCTABANCO","BCO_CODIGO","BCO_CTABAN"+GetWhere("=",cCodigo))

RETURN EJECUTAR("DPCTABANCOMOV",cTipDoc,cCodBco,cCodigo,cNumero,.T.)
// EOF
