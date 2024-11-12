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
  LOCAL nMtoDiv:=0,nMtoDif:=0,nTotDif:=0,dFecha,cWhere,cNumEje
  LOCAL cNumero:="001"

  DEFAULT cCodSuc:=oDp:cSucursal  ,;
          cCodCta:="1101003",;
          cTipAxi:="F",;
          dDesde :=oDp:dFchInicio,;
          dHasta :=oDp:dFchCierre


  SQLDELETE("DPCBTE"    ,"CBT_ACTUAL"+GetWhere("=",cTipAxi))
  SQLDELETE("DPASIENTOS","MOC_ACTUAL"+GetWhere("=",cTipAxi))

  cSql:=[ SELECT ]+CRLF+;
        [ AME_EJEINI, ]+;
        [ AME_CODMOD, ]+;
        [ AME_FCHANT, ]+;
        [ AME_FCHDIV, ]+;
        [ IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT) AS AME_MTOANT,]+;
        [ AME_ANTDIV, ]+;
        [ IF(AME_MTOANT IS NULL,AME_MTOACT,AME_MTOANT)/AME_ANTDIV AS AME_MTODIV, ]+;
        [ AME_VALCAM AS AME_ACTDIV, ]+;
        [ ( SELECT SUM(MOC_MONTO) FROM dpasientos  WHERE AME_CODSUC=MOC_CODSUC AND MOC_CUENTA=AME_CUENTA AND MOC_ACTUAL="F" AND YEAR(MOC_FECHA)=AME_ANO AND MONTH(MOC_FECHA)=AME_MES) AS AME_MONTO ]+;
        [ FROM view_dpctaaxi_mensual ]+;
        [ WHERE AME_CUENTA]+GetWhere("=",cCodCta)+;
        [ AND (AME_FCHINI]+GetWhere(">=",dDesde)+;
        [ AND  AME_FCHFIN]+GetWhere("<=",dHasta)+[)]+;
        [ HAVING AME_FCHDIV IS NOT NULL ]+;
        [ ORDER BY AME_ANO,AME_MES ]

   IF oAsiento=NIL
      lClose:=.T.
      oAsiento:=INSERTINTO("DPASIENTOS",NIL,12)
      oCbte   :=INSERTINTO("DPCBTE"    ,NIL,12)
   ENDIF

   oTable  :=OpenTable(cSql,.T.)
   cNumEje :=EJECUTAR("GETNUMEJE",oTable:AME_EJEINI)

  nMtoDiv:=oTable:AME_MTODIV

  WHILE !oTable:EOF()
   
      nMtoDif:=(nMtoDiv-oTable:AME_MTODIV)*oTable:AME_ACTDIV

      dFecha :=CTOO(FCHFINMES(oTable:AME_FCHDIV),"D")

      ? nMtoDif,oTable:AME_ACTDIV,nMtoDif*oTable:AME_ACTDIV,dFecha
 
      nMtoDiv:=oTable:AME_MTODIV
      nTotDif:=nTotDif+nMtoDif

      oCbte:AppendBlank()
      oCbte:Replace("CBT_CODSUC",cCodSuc)
      oCbte:Replace("CBT_ACTUAL",cTipAxi)
      oCbte:Replace("CBT_NUMERO",cNumero)
      oCbte:Replace("CBT_FECHA" ,dFecha )
      oCbte:Replace("CBT_NUMEJE",cNumEje)
      oCbte:Commit()

      oAsiento:AppendBlank()

      oAsiento:Replace("MOC_NUMEJE",cNumEje)
      oAsiento:Replace("MOC_ACTUAL",cTipAxi)
      oAsiento:Replace("MOC_MONTO" ,nTotDif)
      oAsiento:Replace("MOC_CUENTA",cCodCta)
      oAsiento:Replace("MOC_NUMCBT",cNumero)
      oAsiento:Replace("MOC_FECHA" ,dFecha )
      oAsiento:Replace("MOC_CODSUC",cCodSuc)
      oAsiento:Replace("MOC_ORIGEN","AX"+cTipAxi)
      oAsiento:Replace("MOC_CTAMOD",oTable:AME_CODMOD)
      oAsiento:Replace("MOC_VALCAM",oTable:AME_ACTDIV)
      oAsiento:Commit()

      oTable:DbSkip()

  ENDDO

  oTable:End()

  IF lClose
    oAsiento:End()
    oCbte:End()
  ENDIF


? CLPCOPY(cSql)

RETURN .T.
// EOF
