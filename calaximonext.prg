// Programa   : CALAXIMONEXT
// Fecha/Hora : 11/11/2024 17:32:58
// Propósito  : Calcular Ajuste por Inflación Moneda Extranjera
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodCta,cTipAxi,dDesde,dHasta,oAsiento,oCbte)
  LOCAL oTable,cSql,oTable,lClose:=.F.
  LOCAL cWhere,cNumEje
  LOCAL cNumero:="001"
  LOCAL cWhereCta:="",nT1

  DEFAULT cCodSuc:=oDp:cSucursal  ,;
          cCodCta:="" ,;
          cTipAxi:="F",;
          dDesde :=oDp:dFchInicio,;
          dHasta :=oDp:dFchCierre


  IF Empty(cCodCta)
    cWhereCta:=[1=1]
  ELSE
    cWhereCta:=[AME_CUENTA]+GetWhere("=",cCodCta)
  ENDIF

  SQLDELETE("DPCBTE"    ,"CBT_ACTUAL"+GetWhere("=",cTipAxi))
  SQLDELETE("DPASIENTOS","MOC_ACTUAL"+GetWhere("=",cTipAxi))

  // [ ( SELECT SUM(MOC_MONTO) FROM dpasientos  WHERE AME_CODSUC=MOC_CODSUC AND MOC_CUENTA=AME_CUENTA AND MOC_ACTUAL="F" AND YEAR(MOC_FECHA)=AME_ANO AND MONTH(MOC_FECHA)=AME_MES) AS AME_MONTO ]+;

  cSql:=[ SELECT ]+CRLF+;
        [ AME_CUENTA, ]+;
        [ AME_EJEINI, ]+;
        [ AME_CODMOD, ]+;
        [ AME_FCHANT, ]+;
        [ AME_FCHDIV, ]+;
        [ IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT) AS AME_MTOANT,]+;
        [ AME_ANTDIV, ]+;
        [ (IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT))/AME_ANTDIV AS AME_DIVANT,]+;
        [ IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT)/AME_ANTDIV   AS AME_MTODIV, ]+;
        [ AME_VALCAM AS AME_ACTDIV, ]+;
        [ AME_VALCAM*((IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT))/AME_ANTDIV) AS AME_VALACT,]+;
        [ IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT)-(AME_VALCAM*((IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT))/AME_ANTDIV)) AS AME_MTODIF ]+;
        [ FROM view_dpctaaxi_mensual ]+;
        [ WHERE ]+cWhereCta+;
        [ AND (AME_FCHINI]+GetWhere(">=",dDesde)+;
        [ AND  AME_FCHFIN]+GetWhere("<=",dHasta)+[)]+;
        [ HAVING AME_FCHDIV IS NOT NULL ]+;
        [ ORDER BY AME_CUENTA,AME_ANO,AME_MES ]

   nT1:=SECONDS()

   IF oAsiento=NIL
      lClose:=.T.
      oAsiento:=INSERTINTO("DPASIENTOS",NIL,12)
      oCbte   :=INSERTINTO("DPCBTE"    ,NIL,12)
   ENDIF

   oTable  :=OpenTable(cSql,.T.)
   cNumEje :=EJECUTAR("GETNUMEJE",oTable:AME_EJEINI)

 // oTable:Browse()

   WHILE !oTable:EOF()
   
      oCbte:AppendBlank()
      oCbte:Replace("CBT_CODSUC",cCodSuc)
      oCbte:Replace("CBT_ACTUAL",cTipAxi)
      oCbte:Replace("CBT_NUMERO",cNumero)
      oCbte:Replace("CBT_FECHA" ,CTOO(FCHFINMES(oTable:AME_FCHDIV),"D"))
      oCbte:Replace("CBT_NUMEJE",cNumEje)
      oCbte:Commit()

      oAsiento:AppendBlank()

      oAsiento:Replace("MOC_NUMEJE",cNumEje)
      oAsiento:Replace("MOC_ACTUAL",cTipAxi)
      oAsiento:Replace("MOC_MONTO" ,oTable:AME_MTODIF*-1) // nTotDif)
      oAsiento:Replace("MOC_CUENTA",oTable:AME_CUENTA)
      oAsiento:Replace("MOC_NUMCBT",cNumero)
      oAsiento:Replace("MOC_FECHA" ,CTOO(FCHFINMES(oTable:AME_FCHDIV),"D"))
      oAsiento:Replace("MOC_CODSUC",cCodSuc)
      oAsiento:Replace("MOC_ORIGEN","AX"+cTipAxi)
      oAsiento:Replace("MOC_CTAMOD",oTable:AME_CODMOD)
      oAsiento:Replace("MOC_VALCAM",oTable:AME_ACTDIV)
      oAsiento:Replace("MOC_DESCRI","Ajuste Financiero "+CMES(oAsiento:MOC_FECHA))
      oAsiento:Commit()

      oTable:DbSkip()

  ENDDO

  oTable:End()

  IF lClose
    oAsiento:End()
    oCbte:End()
  ENDIF

// ? SECONDS()-nT1,"tiempo"
// ? CLPCOPY(cSql)

RETURN .T.
// EOF
