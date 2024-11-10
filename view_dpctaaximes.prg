// Programa   : VIEW_DPCTAAXIMES
// Fecha/Hora : 09/11/2024 18:42:00
// Propósito  : Calcular AXI cuentas con moneda extranjera
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cCodigo:="DPCTAAXI_MENSUAL"
  LOCAL cDescri:="Ajuste por Inflación Mensual"
  LOCAL lRun   :=.T.
  LOCAL cSql
  LOCAL oDb    :=OpenOdbc(oDp:cDsnData)
  LOCAL cWhere :=GetWhereOr("CTA_PROPIE",{"Moneda Extranjera","Patrimonio","Monetarias"})

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"view_dpdiario_mes","FCH_MAXDIV")
     EJECUTAR("VIEW_DPDIARIO")
  ENDIF

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
        [ LEFT JOIN ]+oDp:cDsnConfig+[.dpipc ON YEAR(EJE_DESDE)=IPC_ANO AND MONTH(EJE_DESDE)=IPC_MES ]+CRLF+;
        [ GROUP BY MOC_CODSUC,MOC_CTAMOD,MOC_CUENTA,FCH_ANO,FCH_MES ]+CRLF+;
        [ ORDER BY MOC_CODSUC,MOC_CTAMOD,MOC_CUENTA,FCH_ANO,FCH_MES ]


? CLPCOPY(cSql)

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

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
        [ LEFT JOIN ]+oDp:cDsnConfig+[.dpipc ON YEAR(EJE_DESDE)=IPC_ANO AND MONTH(EJE_DESDE)=IPC_MES ]+CRLF+;
        [ GROUP BY EJE_CODSUC,EJE_DESDE,EJE_HASTA,MOC_CTAMOD,MOC_CUENTA ]+CRLF+;
        [] 

  cCodigo:="DPCTAAXI_ANUAL"
  cDescri:="Ajuste por Inflación Anual"

? CLPCOPY(cSql)

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

RETURN .T.
// EOF
