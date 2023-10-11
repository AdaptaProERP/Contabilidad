// Programa   : DPCBTEFIX
// Fecha/Hora : 16/05/2013 00:57:07
// Propósito  : Recuperar Comprobantes contables sin Integridad referencial (DPCBTE y DPASIENTOS)
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lSay)
   LOCAL oAsientos,oCbte,cSql,cActual,cMemo:="",nAt,aFiles:={},nContar:=0,cWhere,cNumEje
   LOCAL oDb:=OpenOdbc(oDp:cDsnData)

   DEFAULT lSay:=.F.

   IF oDp:cType="NOM"
      RETURN NIL
   ENDIF

   IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPASIENTOS","MOC_CTAMOD")
     EJECUTAR("ADDFIELDS_1900",NIL,.T.,.T.)
   ENDIF
  

   Checktable("DPASIENTOS")

   EJECUTAR("DPCAMPOSADD","DPCTASLD"      ,"SLD_ASIACT" ,"N",10,2,"Asientos Actualizados","",NIL,NIL)
   EJECUTAR("DPCAMPOSADD","DPCTASLD"      ,"SLD_ASIPEN" ,"N",10,2,"Asientos Pendientes"  ,"",NIL,NIL)
   EJECUTAR("DPCAMPOSADD","DPCTASLD"      ,"SLD_FCHINI" ,"D",08,0,"Fecha Desde"          ,"",NIL,NIL)
   EJECUTAR("DPCAMPOSADD","DPCTASLD"      ,"SLD_FCHFIN" ,"D",08,0,"Fecha Hasta"          ,"",NIL,NIL)

   oCbte:=OpenTable("SELECT * FROM DPCBTE",.F.)

   // Buscamos Comprobantes

   cSql:=" SELECT MOC_CODSUC,MOC_NUMCBT,MOC_FECHA,MOC_ACTUAL,CBT_NUMERO "+;
         " FROM DPASIENTOS  "+;
         " LEFT JOIN DPCBTE ON MOC_CODSUC=CBT_CODSUC AND MOC_NUMCBT=CBT_NUMERO AND MOC_FECHA=CBT_FECHA AND MOC_ACTUAL=CBT_ACTUAL "+;
         " WHERE CBT_NUMERO IS NULL "+;
         " GROUP BY MOC_CODSUC,MOC_NUMCBT,MOC_FECHA,MOC_ACTUAL,CBT_NUMERO "

   oAsientos:=OpenTable(cSql,.T.)
   // oAsientos:Browse()

   oAsientos:GoTop()

   WHILE !oAsientos:Eof()

      cActual:=oAsientos:MOC_ACTUAL
/*
      cActual:=SQLGET("DPCBTE","CBT_ACTUAL","CBT_CODSUC"+GetWhere("=",oAsientos:MOC_CODSUC)+" AND "+;
                                            "CBT_FECHA "+GetWhere("=",oAsientos:MOC_FECHA )+" AND "+;
                                            "CBT_NUMERO"+GetWhere("=",oAsientos:MOC_NUMCBT)+" AND "+;
                                            "CBT_ACTUAL"+GetWhere("=",oAsientos:MOC_ACTUAL))
*/
      IF !Empty(cActual)

         nContar++

         cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+;
                oAsientos:MOC_NUMCBT+" Fecha: "+DTOC(oAsientos:MOC_FECHA)

         oCbte:Append()
         oCbte:Replace("CBT_CODSUC",oAsientos:MOC_CODSUC)
         oCbte:Replace("CBT_FECHA ",oAsientos:MOC_FECHA )
         oCbte:Replace("CBT_NUMERO",oAsientos:MOC_NUMCBT)
         oCbte:Replace("CBT_ACTUAL",oAsientos:MOC_ACTUAL)
         oCbte:Replace("CBT_COMEN1","Recuperado el "+DTOC(oDp:dFecha)        )
         oCbte:Replace("CBT_NUMEJE",EJECUTAR("GETNUMEJE",oAsientos:MOC_FECHA))

         oCbte:Commit()

      ENDIF

      oAsientos:DbSkip()

   ENDDO

   oAsientos:End()
   oCbte:End()

   IF lSay
      MensajeErr(LSTR(nContar)+" Asiento(s) Recuperados")
   ENDIF

   SQLDELETE("DPASIENTOS","MOC_MONTO=0")
   SQLDELETE("DPASIENTOS",GetWhereOr("MOC_ORIGEN",{"INI","FIN"})) // 07/08/2023 descuadra los balances

   SQLUPDATE("DPASIENTOS","MOC_NUMPAR",STRZERO(0,5),[MOC_NUMPAR IS NULL OR MOC_NUMPAR=""])
   SQLUPDATE("DPASIENTOS","MOC_ORIGEN","CON"       ,[MOC_ACTUAL="C"]) // 02/08/2023 Incidencia en EEFF cuando MOC_ORIGEN está en el WHERE

   cSql:=" DELETE DPCBTE FROM DPCBTE "+;
         " LEFT JOIN DPASIENTOS ON CBT_CODSUC=MOC_CODSUC AND CBT_ACTUAL=MOC_ACTUAL AND CBT_FECHA =MOC_FECHA  AND CBT_NUMERO=MOC_NUMCBT "+;
         " WHERE MOC_ACTUAL IS NULL "

   oCbte:EXECUTE(cSql)

   EJECUTAR("DPCTAMODCREA")

   cSql:="UPDATE DPASIENTOS SET MOC_CTAMOD"+GetWhere("=",oDp:cCtaMod)+" WHERE MOC_CTAMOD IS NULL" 
   oCbte:EXECUTE(cSql)

   IF !EJECUTAR("ISFIELDMYSQL",NIL,"DPASIENTOS","MOC_NUMEJE")
      EJECUTAR("DPCAMPOSADD","DPASIENTOS","MOC_NUMEJE","C",04,2,"Número Ejercicio",NIL)
   ENDIF

   cSql=[ UPDATE ]+;
        [ dpasientos ]+;
        [ INNER JOIN dpcbte       ON MOC_CODSUC=CBT_CODSUC AND MOC_ACTUAL=CBT_ACTUAL AND MOC_FECHA=CBT_FECHA AND MOC_NUMCBT=CBT_NUMERO  ]+;
        [ SET MOC_NUMEJE=CBT_NUMEJE ]+;
        [ WHERE MOC_NUMEJE IS NULL OR MOC_NUMEJE="" ]

   oCbte:Execute(cSql)

   cSql:=[ DELETE DPCBTEINCXPAR FROM DPCBTEINCXPAR ]+;
         [ LEFT JOIN DPASIENTOS ON MOC_CODSUC=IPC_CODSUC AND MOC_NUMCBT=IPC_NUMCBT AND MOC_FECHA=IPC_FECHA AND MOC_ACTUAL="N" AND MOC_ORIGEN=IPC_ORIGEN ]+;
         [ WHERE MOC_ACTUAL IS NULL ]

   oCbte:EXECUTE(cSql)

   // 
   cSql:=[ UPDATE dpasientos SET MOC_ORIGEN=MOC_TIPO WHERE MOC_ORIGEN IS NULL AND MOC_TIPO]+GetWhere("<>","")
   oCbte:EXECUTE(cSql)

   cSql:=" SELECT * "+;
         " FROM DPCBTE  "+;
         " WHERE CBT_NUMEJE IS NULL "

   oCbte:=OpenTable(cSql,.T.)
   oCbte:GoTop()

   WHILE !oCbte:Eof()

      cWhere:="CBT_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
              "CBT_NUMERO"+GetWhere("=",oCbte:CBT_NUMERO)+" AND "+;
              "CBT_FECHA" +GetWhere("=",oCbte:CBT_FECHA )+" AND "+;
              "CBT_ACTUAL"+GetWhere("=",oCbte:CBT_ACTUAL)

      cNumEje:=EJECUTAR("GETNUMEJE",oCbte:CBT_FECHA)

      SQLUPDATE("DPCBTE","CBT_NUMEJE",cNumEje,cWhere)

      oCbte:DbSkip()

   ENDDO

   oCbte:End()

RETURN NIL

// EOF
