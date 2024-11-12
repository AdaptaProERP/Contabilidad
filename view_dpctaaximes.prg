// Programa   : VIEW_DPCTAAXIMES
// Fecha/Hora : 09/11/2024 18:42:00
// Propósito  : Calcular AXI cuentas con moneda extranjera
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lRun)
  LOCAL cCodigo,cDescri,cSql
  LOCAL oDb    :=OpenOdbc(oDp:cDsnData)
  LOCAL cWhere :=GetWhereOr("CTA_PROPIE",{"Moneda Extranjera","Patrimonio","Monetarias"})
  LOCAL cPrg   :=""

  DEFAULT lRun   :=.T.

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"view_dpdiario_mes","FCH_FCHANT") .OR.;
     !EJECUTAR("ISFIELDMYSQL",oDb,"view_dpdiario_mes","FCH_FCHDIV")
     EJECUTAR("VIEW_DPDIARIO",lRun)
  ENDIF

  cCodigo:="DPCTAAXI"
  cDescri:="Cuentas Contables AXI"

  cSql:=[ SELECT MOC_CODSUC AS CTA_CODSUC,MOC_CTAMOD AS CTA_CODMOD, MOC_CUENTA AS CTA_CODIGO,CTA_DESCRI,CTA_PROPIE FROM dpasientos ]+;
        [ INNER JOIN dpcta ON MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO  AND ]+cWhere+;
        [ GROUP BY MOC_CTAMOD,MOC_CUENTA ]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

  cCodigo:="DPCTAAXI_MENSUAL"
  cDescri:="Ajuste por Inflación Mensual"

  cSql:=[ SELECT ]+CRLF+;
        [ MOC_CODSUC AS AME_CODSUC,]+CRLF+;
        [ MOC_CTAMOD AS AME_CTAMOD,]+CRLF+;
        [ MOC_CUENTA AS AME_CUENTA,]+CRLF+;
        [ FCH_ANO    AS AME_ANO,   ]+CRLF+;
        [ FCH_MES    AS AME_MES,   ]+CRLF+;
        [ EJE_DESDE  AS AME_EJEINI,]+CRLF+;
        [ EJE_HASTA  AS AME_EJEFIN,]+CRLF+;
        [ FCH_FCHANT AS AME_FCHANT,]+CRLF+;
        [ FCH_DESDE  AS AME_FCHINI,]+CRLF+;
        [ FCH_HASTA  AS AME_FCHFIN,]+CRLF+;
        [ FCH_MAXDIV AS AME_FCHDIV,]+CRLF+;
        [ HMN_VALOR  AS AME_VALCAM,]+CRLF+;
        [ IPC_TASA   AS AME_EJIPC ,]+CRLF+;
        [ IPC_INPC   AS AME_EJINPC,]+CRLF+;
        [ (SELECT SUM(MOC_MONTO) FROM dpasientos WHERE t2.MOC_CODSUC=dpasientos.MOC_CODSUC AND MOC_CTAMOD=dpcta.CTA_CODMOD   AND MOC_CUENTA=dpcta.CTA_CODIGO AND MOC_FECHA<=FCH_FCHANT AND MOC_ACTUAL="S") AS AME_MTOANT, ]+CRLF+;
        [ (SELECT SUM(MOC_MONTO) FROM dpasientos WHERE T2.MOC_CODSUC=dpasientos.MOC_CODSUC AND MOC_CTAMOD=dpcta.CTA_CODMOD   AND MOC_CUENTA=dpcta.CTA_CODIGO AND MOC_FECHA<=FCH_HASTA AND MOC_ACTUAL="S") AS AME_MTOHIS ]+CRLF+;
        [ FROM view_dpdiario_mes ]+CRLF+;
        [ INNER JOIN dphismon    ON FCH_CODMON=HMN_CODIGO AND HMN_FECHA=FCH_MAXDIV ]+CRLF+;
        [ INNER JOIN dpasientos AS t2 ON MOC_ACTUAL="S" AND YEAR(MOC_FECHA)=FCH_ANO AND MONTH(MOC_FECHA)=FCH_MES ]+CRLF+;
        [ INNER JOIN dpcta      ON  MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO AND ]+cWhere+CRLF+;
        [ INNER JOIN dpejercicios ON  MOC_NUMEJE=EJE_NUMERO ]+CRLF+;
        [ LEFT JOIN ]+UPPER(oDp:cDsnConfig)+[.dpipc ON YEAR(EJE_DESDE)=IPC_ANO AND MONTH(EJE_DESDE)=IPC_MES ]+CRLF+;
        [ GROUP BY MOC_CODSUC,MOC_CTAMOD,MOC_CUENTA,FCH_ANO,FCH_MES ]+CRLF+;
        [ ORDER BY MOC_CODSUC,MOC_CTAMOD,MOC_CUENTA,FCH_ANO,FCH_MES ]


   cSql:=[ SELECT  ]+CRLF+;
         [ CTA_CODSUC AS AME_CODSUC,]+CRLF+;
         [ CTA_CODMOD AS AME_CODMOD,]+CRLF+;
         [ CTA_CODIGO AS AME_CUENTA,]+CRLF+;
         [ EJE_DESDE  AS AME_EJEINI,]+CRLF+;
         [ EJE_HASTA  AS AME_EJEFIN,]+CRLF+;
         [ FCH_ANO    AS AME_ANO   ,]+CRLF+;
         [ FCH_MES    AS AME_MES   ,]+CRLF+;
         [ FCH_FCHANT AS AME_FCHANT,]+CRLF+;
         [ FCH_DESDE  AS AME_FCHINI,]+CRLF+;
         [ FCH_HASTA  AS AME_FCHFIN,]+CRLF+;
         [ FCH_MAXDIV AS AME_FCHDIV,]+CRLF+;
         [ IPC_TASA   AS AME_EJIPC ,]+CRLF+;
         [ IPC_INPC   AS AME_EJINPC,]+CRLF+;
         [ HMN_VALOR  AS AME_VALCAM,]+CRLF+;
         [ (SELECT HMN_VALOR      FROM view_dphismon_mes_valor WHERE YEAR(FCH_FCHANT)=HMN_ANO AND MONTH(FCH_FCHANT)=HMN_MES AND HMN_CODIGO="DBC" LIMIT 1  ) AS AME_ANTDIV, ]+CRLF+;
         [ (SELECT SUM(MOC_MONTO) FROM dpasientos WHERE MOC_CODSUC=CTA_CODSUC AND CTA_CODMOD=MOC_CTAMOD AND MOC_CUENTA=CTA_CODIGO AND MOC_FECHA< FCH_DESDE) AS AME_MTOANT, ]+CRLF+;
         [ (SELECT SUM(MOC_MONTO) FROM dpasientos WHERE MOC_CODSUC=CTA_CODSUC AND CTA_CODMOD=MOC_CTAMOD AND MOC_CUENTA=CTA_CODIGO AND MOC_FECHA<=FCH_HASTA) AS AME_MTOACT  ]+CRLF+;
         [ FROM VIEW_DPCTAAXI ]+CRLF+;
         [ INNER JOIN dpejercicios      ON CTA_CODSUC=EJE_CODSUC ]+CRLF+;
         [ LEFT  JOIN ]+UPPER(oDp:cDsnConfig)+[.dpipc ON YEAR(EJE_DESDE)=IPC_ANO AND MONTH(EJE_DESDE)=IPC_MES ]+CRLF+;
         [ INNER JOIN view_dpdiario_mes ON FCH_DESDE>=EJE_DESDE AND FCH_HASTA<=EJE_HASTA ]+CRLF+;
         [ LEFT  JOIN dphismon          ON FCH_CODMON=HMN_CODIGO AND HMN_FECHA=FCH_MAXDIV ]+CRLF+;
         [ GROUP BY CTA_CODSUC,CTA_CODMOD,CTA_CODIGO,FCH_ANO,FCH_MES ]+CRLF+;
         [ ORDER BY CTA_CODSUC,CTA_CODMOD,CTA_CODIGO,FCH_ANO,FCH_MES ]




  IF "51"$oDp:cDsnConfig
    cSql:=STRTRAN(cSql,".ADMCONFIG51",oDp:cDsnConfig)
  ENDIF


  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun,"VIEW_DPDIARIO")

  cSql:=[ SELECT ]+CRLF+;
        [ EJE_CODSUC AS AME_CODSUC, ]+CRLF+;
        [ MOC_CTAMOD AS AME_CTAMOD, ]+CRLF+;
        [ MOC_CUENTA AS AME_CUENTA, ]+CRLF+;
        [ date_add(EJE_DESDE, INTERVAL -1 DAY) AS FCH_FCHANT, ]+CRLF+;
        [ EJE_DESDE  AS AME_EJEINI, ]+CRLF+;
        [ EJE_HASTA  AS AME_EJEFIN, ]+CRLF+;
        [ SUM(IF(MOC_FECHA< EJE_DESDE,MOC_MONTO,0)) AS AME_MTOINI, ]+CRLF+;
        [ SUM(IF(MOC_FECHA<=EJE_HASTA,MOC_MONTO,0)) AS AME_MTOFIN, ]+CRLF+;
        [ HMN_VALOR AS AME_VALCAM, ]+CRLF+;
        [ IPC_ANO, ]+CRLF+;
        [ IPC_MES, ]+CRLF+;
        [ IPC_TASA, ]+CRLF+;
        [ IPC_INPC ]+CRLF+;
        [ FROM ]+CRLF+;
        [ dpejercicios ]+CRLF+;
        [ INNER JOIN dpasientos       ON EJE_CODSUC=MOC_CODSUC AND MOC_ACTUAL="S" ]+CRLF+;
        [ INNER JOIN dpcta            ON MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO AND ]+cWhere+CRLF+;
        [ LEFT  JOIN dphismon         ON date_add(EJE_DESDE, INTERVAL -1 DAY)=HMN_FECHA AND HMN_CODIGO="DBC" ]+CRLF+;
        [ LEFT JOIN ]+UPPER(oDp:cDsnConfig)+[.dpipc ON YEAR(EJE_DESDE)=IPC_ANO AND MONTH(EJE_DESDE)=IPC_MES ]+CRLF+;
        [ GROUP BY EJE_CODSUC,EJE_DESDE,EJE_HASTA,MOC_CTAMOD,MOC_CUENTA ]+CRLF+;
        [] 

  cCodigo:="DPCTAAXI_ANUAL"
  cDescri:="Ajuste por Inflación Anual"

  IF "51"$oDp:cDsnConfig
    cSql:=STRTRAN(cSql,".ADMCONFIG51",oDp:cDsnConfig)
  ENDIF

//? CLPCOPY(cSql)

  cPrg   :=[ LOCAL oDb:=OpenOdbc(oDp:cDsnData),lRun:=.T. ]+CRLF+;
           [  IF !EJECUTAR("ISFIELDMYSQL",oDb,"view_dpdiario_mes","FCH_FCHANT") .OR.; ]+CRLF+;
           [     !EJECUTAR("ISFIELDMYSQL",oDb,"view_dpdiario_mes","FCH_FCHDIV") ]+CRLF+;
           [     EJECUTAR("VIEW_DPDIARIO",lRun) ]+CRLF+;
           [  ENDIF ]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun,"VIEW_DPDIARIO",NIL,cPrg)

RETURN .T.
// EOF
