// Programa   : DPCTAMAYORLBX
// Fecha/Hora : 13/11/2024 04:49:14
// Propósito  : Ejecutar Mayor Analítico desde DPLBXCTA
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCta)

  DEFAULT cCodCta:="1"

  RGO_C1:=oDp:cSucursal
  RGO_C2:=NIL
  RGO_C3:=NIL
  RGO_C4:=NIL
  RGO_I1:=cCodCta
  RGO_F1:=cCodCta
  RGO_I2:=NIL
  RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oDp:dFchInicio,oDp:dFchCierre,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
// EOF
