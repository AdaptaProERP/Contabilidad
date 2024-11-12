// Programa   : VIEW_DPDIARIO
// Fecha/Hora : 17/09/2024 01:23:06
// Propósito  : Crear vistas VIEW_DPDIARIO
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lRun)
  LOCAL cCodigo,cDescri,cSql

  DEFAULT lRun   :=.T.

  cSql:=[ SELECT ]+CRLF+;
        [ HMN_CODIGO       AS HMN_CODIGO,]+CRLF+;
        [ YEAR(HMN_FECHA)  AS HMN_ANO   ,]+CRLF+;
        [ MONTH(HMN_FECHA) AS HMN_MES   ,]+CRLF+;
        [ MAX(HMN_FECHA)   AS HMN_FECHA ]+CRLF+;
        [ FROM dphismon ]+CRLF+;
        [ GROUP BY HMN_CODIGO,YEAR(HMN_FECHA),MONTH(HMN_FECHA) ]+CRLF+;
        [ ORDER BY HMN_CODIGO,YEAR(HMN_FECHA),MONTH(HMN_FECHA) ]

  cCodigo:="DPHISMON_MES"
  cDescri:="Histórico Divisa Fin de Mes"

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

  cSql:=[ SELECT ]+CRLF+;
        [ VIEW_DPHISMON_MES.HMN_CODIGO,]+CRLF+;
        [ VIEW_DPHISMON_MES.HMN_ANO,]+CRLF+;
        [ VIEW_DPHISMON_MES.HMN_MES,]+CRLF+;
        [ VIEW_DPHISMON_MES.HMN_FECHA,]+CRLF+;
        [ DPHISMON.HMN_VALOR AS HMN_VALOR ]+CRLF+;
        [ FROM VIEW_DPHISMON_MES ]+CRLF+;
        [ INNER JOIN dphismon ON  VIEW_DPHISMON_MES.HMN_CODIGO=dphismon.HMN_CODIGO AND VIEW_DPHISMON_MES.HMN_FECHA =dphismon.HMN_FECHA ]

  cCodigo:="DPHISMON_MES_VALOR"
  cDescri:="Histórico Divisa Fin de Mes con valor"

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

  /*
  // Quincenal
  */
  cCodigo:="DPDIARIO_QUINCE"
  cDescri:="Quincenario"

  cSql:=[ SELECT DIA_ANO AS FCH_ANO,]+CRLF+;
        [ DIA_QUINCE AS FCH_QUINCE,]+CRLF+;
        [ DIA_CMES   AS FCH_CMES,]+CRLF+;
        [ MIN(DIA_FECHA) AS FCH_DESDE,]+CRLF+;
        [ MAX(DIA_FECHA) AS FCH_HASTA ]+CRLF+;
        [ FROM   DPDIARIO ]+CRLF+;
        [ GROUP BY DIA_ANO,DIA_QUINCE ]+CRLF+;
        [ ORDER BY DIA_ANO,DIA_QUINCE ]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

  /*
  // Mensual
  */

  cCodigo:="DPDIARIO_MES"
  cDescri:="Mensual"

  cSql:=[ SELECT  ]+CRLF+;
        [ DIA_ANO AS FCH_ANO, ]+CRLF+;     
        [ DIA_MES AS FCH_MES, ]+CRLF+;  
        [ MIN(date_add(DIA_FECHA, INTERVAL -1 DAY)) AS FCH_FCHANT, ]+CRLF+;
        [ MIN(DIA_FECHA) AS FCH_DESDE, ]+CRLF+;
        [ MAX(DIA_FECHA) AS FCH_HASTA, ]+CRLF+;
        [ DIA_CMES       AS FCH_CMES, ]+CRLF+;
        [ MAX(HMN_FECHA) AS FCH_MAXDIV, ]+CRLF+;
        [ HMN_CODIGO     AS FCH_CODMON, ]+CRLF+;
        [ IPC_TASA       AS FCH_IPC, ]+CRLF+;
        [ IPC_INPC       AS FCH_INPC ]+CRLF+;
        [ FROM DPDIARIO ]+CRLF+;
        [ LEFT JOIN dphismon ON YEAR(HMN_FECHA)=YEAR(DIA_FECHA) AND MONTH(HMN_FECHA)=MONTH(DIA_FECHA) AND HMN_CODIGO="DBC" ]+CRLF+;  
        [ LEFT JOIN ]+oDp:cDsnConfig+[.dpipc ON YEAR(DIA_FECHA)=IPC_ANO AND MONTH(DIA_FECHA)=IPC_MES ]+CRLF+;
        [ GROUP BY DIA_ANO,DIA_MES  ]+CRLF+;
        [ ORDER BY DIA_ANO,DIA_MES ]

  IF "51"$oDp:cDsnConfig
    cSql:=STRTRAN(cSql,".ADMCONFIG51",oDp:cDsnConfig)
  ENDIF
     
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

  /*
  // Anual
  */     
  cCodigo:="DPDIARIO_ANO"
  cDescri:="Anual"

  cSql:=[ SELECT ]+CRLF+;
        [ FCH_ANO,]+CRLF+;
        [ MIN(FCH_DESDE)  AS FCH_DESDE ,]+CRLF+;
        [ MAX(FCH_HASTA)  AS FCH_HASTA ,]+CRLF+;
        [ MAX(FCH_MAXDIV) AS FCH_MAXDIV,]+CRLF+;
        [ FCH_CODMON      AS FCH_CODMON,]+CRLF+;
        [ IPC_TASA        AS FCH_IPC   ,]+CRLF+;
        [ IPC_INPC        AS FCH_INPC  ,]+CRLF+;
        [ IPC_MES         AS FCH_IPCMES,]+CRLF+;
        [ HMN_VALOR       AS FCH_VALCAM ]+CRLF+;
        [ FROM VIEW_DPDIARIO_MES ]+CRLF+;
        [ LEFT JOIN dphismon ON FCH_MAXDIV=HMN_FECHA AND HMN_CODIGO="DBC" ]+CRLF+;
        [ LEFT JOIN ]+oDp:cDsnConfig+[.dpipc ON FCH_ANO=IPC_ANO AND FCH_MES=IPC_MES ]+CRLF+;
        [ GROUP BY FCH_ANO ]+CRLF+;
        [ ORDER BY FCH_ANO ]

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

RETURN .T.
// EOF
