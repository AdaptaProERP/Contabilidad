// Programa   : BGCALCULAR
// Fecha/Hora : 27/02/2006 23:40:36
// Prop¢sito  : Calcular Balance General
// Creado Por : Juan Navas
// Llamado por: REPORTE BGCALCULAR
// Aplicaci¢n : Contabilidad
// Tabla      : DPCTA

#INCLUDE "DPXBASE.CH"
#include "DpxReport.ch"

PROCE MAIN(oGenRep,dHasta,nMaxCol,cPicture,cTipBal,cTextT,cPasCap,cCodSuc,cCenCos,cCodMon)
   LOCAL aCtaBg  :={oDp:cCtaBg1,oDp:cCtaBg2,oDp:cCtaBg3,oDp:cCtaBg4,oDp:cCtaCo1,oDp:cCtaCo2},nAt,nCol,nLen,aData:={},nField,aNew:={},lTotales:=.F.
   LOCAL aLenBg  :={},cWhere:="",I,cSql,oTable,cCodCta:="",oCuentas,nRecCount,nLen0,nMaxNiv:=0,nNivel,nNivMax:=0
   LOCAL nPasCap :=0,bSkip,bRup,aCuentas:={},aData:={}
   LOCAL cCtaCap :=IIF(Empty(oDp:cCtaBg3),oDp:cCtaBg2,oDp:cCtaBg3) // Cuenta Capital
   LOCAL nUtil   :=0,oDatos
   LOCAL cNumEje :=EJECUTAR("GETNUMEJE",RGO_C1)
   LOCAL cCodMod :=SQLGET("DPEJERCICIOS","EJE_CTAMOD","EJE_NUMERO"+GetWhere("=",cNumEje))
   LOCAL cCtaUtil:=SQLGET("VIEW_DPCODINTEGRA","CIN_CODCTA","CIN_CODIGO"+GetWhere("=","UTILIDAD")+" AND CIN_CTAMOD"+GetWhere("=",cCodMod))
   LOCAL nCuenta   :=0  // Posición del campo CTA_CODIGO
   LOCAL cCtaMod,dDesde,cNumEje,nUtilCta,cCodDep
   LOCAL oDlg
   LOCAL aTotal:={},nActivo:=0 // Monto del Activo

   DEFAULT dHasta:=oDp:dFecha,nMaxCol:=6,;
           cPicture:="99,999,999,999,999.99",;
           cTipBal :="BG",;
           cTextT  :="Total",;
           cPasCap :="Pasivo y Capital"

   DEFAULT oDp:lPrecontab:=.F.


   IF Empty(cCtaUtil) .OR. cCtaUtil=oDp:cCtaIndef

      MsgMemo("Balance Requiere Cuenta de Utilidad ","Validación del Balance")
      EJECUTAR("VALCODINT",.F.,{"UTILIDAD"})

      cSql:= [ SELECT MOC_CUENTA,SUM(IF(MOC_MTOORG>0 AND MOC_VALCAM>0,MOC_MTOORG,ROUND(MOC_MONTO/HMN_VALOR,2))) AS MOC_MONTO   ]+;
             [ FROM DPASIENTOS ]+;
             [ INNER JOIN DPHISMON ON HMN_CODIGO]+GetWhere("=",cCodMon)+[ AND MOC_FECHA=HMN_FECHA   ]+;
             [ WHERE 1=0 ]+;
	        [ GROUP BY MOC_CUENTA ]+;
	        [ ORDER BY MOC_CUENTA ]

        oTable:=OpenTable(cSql,.F.)
        oTable:End()
        RETURN oTable

   ENDIF

   IF oDp:lPrecontab
      cSql:=STRTRAN(cSql," DPASIENTOS "," DPASIENTOSPREC ")
   ENDIF


   IF Empty(cCodMon) .AND. TYPE("RGO_C9")="C" .AND. !Empty(RGO_C9)
      cCodMon:=RGO_C9
   ENDIF

   IF TYPE("RGO_C12")="C" .AND. !Empty(RGO_C12)
      cCodDep:=RGO_C12
   ENDIF
  

   nMaxCol :=CTOO(nMaxCol,"N")
   nMaxCol :=MIN(nMaxCol ,5+1)
   cPicture:=ALLTRIM(cPicture)
   cTextT  :=ALLTRIM(cTextT)+" "
   nUtil   :=GETUTILIDAD()

// ? nUtil,"UTILIDAD"

   nUtilCta:=CTAUTILIDAD()

   IF nUtilCta<>0 .AND. nUtil<>0

      MsgMemo("Saldo de la Cuenta "+ALLTRIM(cCtaUtil)+"="+FDP(nUtilCta,"999,999,999,999.99")+CRLF+;
              "Resultado GYP : "            +"="+FDP(nUtil,"999,999,999,999.99")   +CRLF+;
              "El saldo de la Cuenta "+ALLTRIM(cCtaUtil)+" debe ser Cero"+;
              "","Incidencia en Utilidad del Ejercicio")
            
              
   ENDIF

// ? nUtilCta,"CON ASIENTO CONTABLE",nUtil,"UTILIDAD GYP"
  
   // Utilidad del Ejercicio Vs Cuenta de Utilidad
   IF nUtil<>0
   ENDIF

   // AEVAL(aCtaBg,{|a,n| IIF( Empty(a) , aCtaBg:=ARREDUCE(aCtaBg,n)   ,  AADD(aLenBg,LEN(ALLTRIM(a)))) })

   FOR I=1 TO LEN(aCtaBg)
     aCtaBg[I]:=ALLTRIM(aCtaBg[I])
     IF !Empty(aCtaBg[I])
       cWhere:=cWhere+IIF(Empty(cWhere), "" , " OR ")+"LEFT(MOC_CUENTA,"+LSTR(LEN(aCtaBg[I]))+")"+GetWhere("=",aCtaBg[I])
     ENDIF
   NEXT I


/*
   cWhere:="("+cWhere+") AND (MOC_FECHA"+GetWhere(">=",oDp:dFchInicio)+" AND MOC_FECHA"+GetWhere("<=",dHasta)+")"+;
           " AND MOC_ACTUAL<>'N'"

*/

   IF Empty(cCodMon)

     cWhere:=IIF( Empty(RGO_C7) , "" , " MOC_CODSUC"+GetWhere("=",RGO_C7)+" AND ")+;
             "("+cWhere+") AND (MOC_FECHA"+GetWhere("<=",dHasta)+" AND MOC_ACTUAL='S' )"

   ELSE

     // Solo asientos actualizados, NO AJUSTES FINANCIEROS
     cWhere:=IIF( Empty(RGO_C7) , "" , " MOC_CODSUC"+GetWhere("=",RGO_C7)+" AND ")+;
             "("+cWhere+") AND (MOC_FECHA"+GetWhere("<=",dHasta)+" AND MOC_ACTUAL='S' )"


   ENDIF
   
   IF !Empty(cCenCos) 
 
      cWhere:=cWhere+ iif(Empty(cWhere), " ", " AND ")+;
              "MOC_CENCOS"+GetWhere("=",cCenCos)
   ENDIF

   // 22/04/2023 
   IF !Empty(cCodDep) 
 
      cWhere:=cWhere+ iif(Empty(cWhere), " ", " AND ")+;
              "MOC_CODDEP"+GetWhere("=",cCodDep)
   ENDIF



   // JN 21/04/2019, no puede sumar asientos Vacios
   cWhere:=cWhere+ iif(Empty(cWhere), " ", " AND ")+;
              "MOC_CUENTA"+GetWhere("<>","")

   // QUITAR
   // 27/04/2021, si existe balance inicial, no lee los datos anteriores

   cNumEje:=EJECUTAR("GETNUMEJE",dHasta)
   dDesde :=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA,EJE_CTAMOD","EJE_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                                     "EJE_NUMERO"+GetWhere("=",cNumEje))

   IF COUNT("DPASIENTOS","MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND MOC_FECHA"+GetWhere("=",dDesde)+" AND MOC_ORIGEN"+GetWhere("=","INI"))=0
    // Empty(cCodMon)

     cWhere:=cWhere +IIF(Empty(cWhere),""," AND ")+" NOT (MOC_ORIGEN"+GetWhere("=","FIN")+" OR MOC_ORIGEN"+GetWhere("=","INI")+")"

   ELSE

     cWhere :=cWhere +IIF(Empty(cWhere),""," AND ")+" MOC_FECHA"+GetWhere(">=",dDesde)

   ENDIF

   DEFAULT oDp:dFchFinRec:=CTOD("")

   IF !Empty(oDp:dFchFinRec) .AND. COUNT("DPASIENTOS","MOC_NUMCBT"+GetWhere("=","RECM_BS")+" AND MOC_FECHA"+GetWhere("=",oDp:dFchFinRec))>0
      cWhere:=cWhere+" AND MOC_FECHA"+GetWhere(">=",oDp:dFchFinRec+1)
   ENDIF

// ? cCodMon,"cCodMon"

   IF Empty(cCodMon)

     cSql:=" SELECT MOC_CUENTA,SUM(MOC_MONTO) AS MOC_MONTO"+;
           " FROM DPASIENTOS "+;
           " WHERE "+cWhere+" "+;
           " GROUP BY MOC_CUENTA "+;
           " ORDER BY MOC_CUENTA "

   ELSE

/*
    cSql:= [ SELECT MOC_CUENTA,SUM(IF(MOC_MTOORG>0 AND MOC_VALCAM>0,MOC_MTOORG,ROUND(MOC_MONTO/HMN_VALOR,2))) AS MOC_MONTO   ]+;
           [ FROM ]+;   
	      [ view_dpasientosdia ]+;
           [ INNER JOIN DPHISMON ON HMN_CODIGO]+GetWhere("=",cCodMon)+[ AND MOC_FECHA=HMN_FECHA   ]+;
           [ WHERE ]+cWhere+;
	      [ GROUP BY MOC_CUENTA ]+;
	      [ ORDER BY MOC_CUENTA ]
*/

    cSql:= [ SELECT MOC_CUENTA,SUM(IF(MOC_MTOORG>0 AND MOC_VALCAM>0,MOC_MTOORG,ROUND(MOC_MONTO/HMN_VALOR,2))) AS MOC_MONTO   ]+;
           [ FROM DPASIENTOS ]+;
           [ INNER JOIN DPHISMON ON HMN_CODIGO]+GetWhere("=",cCodMon)+[ AND MOC_FECHA=HMN_FECHA   ]+;
           [ WHERE ]+cWhere+;
	      [ GROUP BY MOC_CUENTA ]+;
	      [ ORDER BY MOC_CUENTA ]

   ENDIF

   IF oDp:lPrecontab
      cSql:=STRTRAN(cSql," DPASIENTOS "," DPASIENTOSPREC ")
   ENDIF

   oTable:=OpenTable(cSql,.T.)

//   oTable:Browse()
//	 ? CLPCOPY(oTable:cSql)

   DPWRITE("TEMP\BGCALCULAR.SQL",cSql)

// ? CLPCOPY(cSql)
// ? nUtil

   IF nUtil<>0  // Agrega la Cuenta de Utilidad
      AADD(oTable:aDataFill,{cCtaUtil,nUtil})
      aData:=ASORT(oTable:aDataFill,,, { |x, y| x[1] < y[1] }) 
      oTable:aDataFill:=ACLONE(aData)
      // ViewArray(aData)
   ENDIF

   IF oTable:RecCount()=0
      oTable:End()
      RETURN oTable
   ENDIF

   oTable:GoBottom()
   cCodCta:=oTable:MOC_CUENTA
   cCtaMod:=EJECUTAR("DPCTAMOD_EJER",dHasta)

// ? cCtaMod,"cCtaMod",dHasta

   MsgRun("Leyendo Asientos","Por favor Espere...",;
          {||   oCuentas:=OpenTable(" SELECT CTA_CODIGO,CTA_DESCRI FROM DPCTA WHERE CTA_CODIGO"+GetWhere("<=",cCodCta)+;
                                    " AND CTA_CODMOD"+GetWhere("=",cCtaMod)+;
                                    " ORDER BY CTA_CODIGO",.T.) })

//  ? CLPCOPY(oDp:cSql)
// oCuentas:Browse()

   nCuenta:=oCuentas:FieldPos("CTA_CODIGO")

   AEVAL(oCuentas:aDataFill,{|a,n| oCuentas:aDataFill[n,nCuenta]:=ALLTRIM(a[nCuenta]) })

/*
   // Reemplazado por AEVAL
   WHILE !oCuentas:Eof()
      oCuentas:REPLACE("CTA_CODIGO",ALLTRIM(oCuentas:CTA_CODIGO))
      oCuentas:DbSkip()
   ENDDO
*/

   oCuentas:Replace("SALDO",0)
   oCuentas:Replace("COL"  ,0  )
   oCuentas:Replace("TIPO" ,"C") // Cuentas
   oCuentas:Replace("NUM"  ,0  ) // Cuentas

   FOR I=1 TO 10
     oCuentas:Replace("COL"+STRZERO(I,2),SPACE(30))
   NEXT I

   oCuentas:Replace("TITULO" ,SPACE(40))
   oCuentas:REPLACE("ASIENTO",1)  // Acepta Asientos

   MsgMeter( {|oMeter, oText, oDlg, lEnd, oBtn| BGCALSALDO(oMeter,oText),;
              "Calculando Totales", "Balance General"} )


   oDp:aBalaceGyP:={}

   // ? oCuentas:FieldPos("TITULO")
/*
   // Calcula los Saldos
   oTable:GoTop()
   WHILE !oTable:Eof()
      cCodCta:=ALLTRIM(oTable:MOC_CUENTA)
      // oTable:REPLACE("MOC_ASIENTO",.T.)
      WHILE LEN(cCodCta)>0
         nAt:=ASCAN(oCuentas:aDataFill,{|a,n|a[1]==cCodCta})
         IF nAt>0
            oCuentas:Goto(nAt)
            oCuentas:REPLACE("SALDO"  , oCuentas:SALDO+oTable:MOC_MONTO       )
            oCuentas:REPLACE("ASIENTO", IF(cCodCta==ALLTRIM(oTable:MOC_CUENTA) , 1 , 0 ))
//          ARREDUCE(oCuentas:aDataFill,nAt) // ya no hace falta
         ENDIF
         cCodCta:=LEFT(cCodCta,LEN(cCodCta)-1)
      ENDDO
      oTable:DbSkip()
   ENDDO

*/

// ViewArray(oCuentas:aDataFill)

   // Suma Activo + Capital
   nAt:=ASCAN(oCuentas:aDataFill,{|a,n|ALLTRIM(a[1])==ALLTRIM(oDp:cCtaBg2)})

   IF nAt>0
     oCuentas:Goto(nAt)
     nPasCap:=nPasCap+oCuentas:SALDO

     AADD(oDp:aBalaceGyP,{oDp:cCtaBg2,oCuentas:SALDO,nPasCap})

//? "aqui suma el activo",nPasCap,oCuentas:SALDO
   ENDIF

// ? oDp:cCtaBg3,"oDp:cCtaBg3"

   nAt:=ASCAN(oCuentas:aDataFill,{|a,n|ALLTRIM(a[1])==ALLTRIM(oDp:cCtaBg3)})
   IF nAt>0
     oCuentas:Goto(nAt)
     nPasCap:=nPasCap+oCuentas:SALDO

     AADD(oDp:aBalaceGyP,{oDp:cCtaBg3,oCuentas:SALDO,nPasCap})


// ? nPasCap,"pasivo y capital 1"

   ENDIF

   // Resultado del Ejercicio, 15/03/2024, la utilidad esta sumada en el Patrimonio
   nAt:=ASCAN(oCuentas:aDataFill,{|a,n|ALLTRIM(a[1])==ALLTRIM(oDp:cCtaBg4)})
   IF nAt>0 .AND.  .F. 
     oCuentas:Goto(nAt)
     nPasCap:=nPasCap+oCuentas:SALDO

     AADD(oDp:aBalaceGyP,{oDp:cCtaBg4,oCuentas:SALDO,nPasCap})

   ENDIF

   aTotal:=ATOTALES(oDp:aBalaceGyP)
   AADD(oDp:aBalaceGyP,{"Total",aTotal[2],0})

   nAt:=ASCAN(oCuentas:aDataFill,{|a,n|ALLTRIM(a[1])==ALLTRIM(oDp:cCtaBg1)})

   IF nAt>0

     oCuentas:Goto(nAt)
     nActivo:=oCuentas:SALDO

     aData:=ACLONE(oCuentas:aDataFill[nAt])
     AADD(oCuentas:aDataFill,aData)
     oCuentas:GoBottom()
     oCuentas:REPLACE("CTA_CODIGO","TOTAL") 
     oCuentas:REPLACE("CTA_DESCRI",cPasCap) 
     oCuentas:REPLACE("SALDO",nPasCap)

     AADD(oDp:aBalaceGyP,{oDp:cCtaBg1,nActivo,0})


     IF nPasCap<>nActivo
/*
       AADD(oCuentas:aDataFill,aData)
       oCuentas:GoBottom()
       oCuentas:REPLACE("CTA_CODIGO","TOTDIF") 
       oCuentas:REPLACE("CTA_DESCRI","Diferencia") 
       oCuentas:REPLACE("SALDO",nActivo-nPasCap)
*/
       AADD(oDp:aBalaceGyP,{"Diferencia",nActivo+nPasCap,0})

//    ViewArray(oDp:aBalaceGyP)

     ENDIF
     
     // ? nPasCap,nActivo,"AGREGADO"
     // Agrega Pasivo + Capital

   ENDIF
  
   //VIEWARRAY(oCuentas:aDataFill)

   // Depura Cuentas sin Montos
   WHILE .T.

     nAt:=ASCAN(oCuentas:aDataFill,{|a,n|a[3]=0})

     IF nAt=0
        EXIT
     ENDIF

     oCuentas:aDataFill:=ARREDUCE(oCuentas:aDataFill,nAt)

   ENDDO

   aCuentas:=ACLONE(oCuentas:aDataFill)

   IF ValType(oDlg)="O"

     oDlg:bStart = { || Eval( bAction, oMeter, oText, oDlg, @lEnd, oBtn ),;
                        lEnd := .t., oDlg:End() }

   ENDIF

   MsgMeter( {|oMeter, oText, oDlg, lEnd, oBtn| HacerBal(oMeter), "Calculando", "Balance General"} )

//   HacerBal()

   // Copia el BG 
   aCuentas:=ACLONE(oCuentas:aDataFill)
   // Ahora las Cuentas de Orden

   nColMax:=nNivMax
  

 // ? LEN(aCuentas),"aCuentas"
/*
   WHILE .T.

     oCuentas:Gotop()
     // ? oCuentas:CTA_CODIGO,"cCta"
     HacerBal()
     EXIT

     IF nNivMax>nMaxCol

        nMaxCol:=nNivMax
        oCuentas:aDataFill:=ACLONE(aCuentas)
        oCuentas:Gotop()
        HacerBal()

       //  ? "SUPER LAS COLS",nNivMax,nMaxCol,oCuentas:CTA_CODIGO

     ENDIF

     // ViewArray(aCuentas)
     // ? nNivMax,nMaxCol

     EXIT

   ENDDO

*/

// oCuentas:Browse()

  IF ValType(oGenRep)="O" .AND. (oGenRep:oRun:nOut=6 .OR. oGenRep:oRun:nOut=7 .OR. oGenRep:oRun:nOut=8)

      oDatos:=OpenTable("SELECT CTA_DESCRI AS PERIODO FROM DPCTA",.F.)
      oDatos:AddRecord(.T.)
      oDatos:Replace("PERIODO" ,DTOC(RGO_C1) )
      oDatos:Replace("SUCURSAL",SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",RGO_C7)))

      oDatos:CTODBF(oDp:cPathCrp+Alltrim(oGenRep:REP_CODIGO)+"ENC.DBF")
      oDatos:End() 

      oCuentas:CTODBF(oDp:cPathCrp+Alltrim(oGenRep:REP_CODIGO)+".DBF")
      oGenRep:oRun:lFileDbf:=.T. // ya Existe

  ENDIF

RETURN oCuentas

FUNCTION HacerBal(oMeter,oText)
   LOCAL cCod1,cCod2,cCod3,cCod4,cCod5,cCod6,cCod7,cCod8,cCod9
   LOCAL nPos1,nPos2,nPos3,nPos4,nPos5,nPos6,nPos7,nPos8,nPos9
   LOCAL nCan1,nCan2,nCan3,nCan4,nCan5,nCan6,nCan7,nCan8,nCan9
   LOCAL nNiv1,nNiv2,nNiv3,nNiv4,nNiv5,nNiv6,nNiv7,nNiv8,nNiv9
   LOCAL nLen1,nLen2,nLen3,nLen4,nLen5,nLen6,nLen7,nLen8,nLen9
   LOCAL nNivCta:=0,I,cCol,U,nPos

   aNew:={}
   oCuentas:GoTop()

// ? oMeter:ClassName()

   oMeter:SetTotal(oCuentas:RecCount())

   // oCuentas:Browse()
   // bRup := {|cCta,nLen,nNiv| cCta=LEFT(oCuentas:CTA_CODIGO,nLen) .AND. !oCuentas:EOF() }
   // bSkip:= {|nLen,nNiv,lRes| LEN(oCuentas:CTA_CODIGO)<>nLen .OR. nNiv>nMaxCol }

   nLen1:= LEN(oCuentas:CTA_CODIGO)

   // Todas las Cuentas ppales deben poseer 1, Digito pata Todos
  
   WHILE !oCuentas:Eof()

      nNivCta:=0

      oMeter:Set(oCuentas:RecNo())

      cCod1 :=ALLTRIM(oCuentas:CTA_CODIGO)
      nPos1 :=oCuentas:Recno()
      nNivel:=1

      IF LEN(oCuentas:CTA_CODIGO)<>nLen1 .OR. nNivel>nMaxCol
         oCuentas:DbSkip()
         LOOP
      ENDIF

      SETCUENTA()
      // Busca todas las Hijas de 1,2,3

      WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CTA_CODIGO,nLen1)==cCod1

         // ? "AQUI DEBE BUSCAR 1.1.",LEFT(oCuentas:CTA_CODIGO,nLen1),cCod1,oCuentas:CTA_CODIGO

         oMeter:Set(oCuentas:RecNo())

         IF LEN(oCuentas:CTA_CODIGO)<=nLen1 .OR. nNivel>nMaxCol
            oCuentas:DbSkip()
            LOOP
         ENDIF

         nPos2 :=oCuentas:Recno()
         cCod2 :=ALLTRIM(oCuentas:CTA_CODIGO)
         nLen2 :=LEN(cCod2)
         nNivel:=2

         SETCUENTA()

         WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CTA_CODIGO,nLen2)==cCod2

            IF LEN(oCuentas:CTA_CODIGO)<=nLen2 .OR. nNivel>nMaxCol
               oCuentas:DbSkip()
               LOOP
            ENDIF

            cCod3 :=ALLTRIM(oCuentas:CTA_CODIGO)
            nLen3 :=LEN(cCod3)
            nPos3 :=oCuentas:Recno()
            nNivel:=3

            SETCUENTA()

            WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CTA_CODIGO,nLen3)==cCod3

               IF LEN(oCuentas:CTA_CODIGO)<=nLen3 .OR. nNivel>nMaxCol
                  oCuentas:DbSkip()
                  LOOP
               ENDIF
  
               cCod4 :=ALLTRIM(oCuentas:CTA_CODIGO)
               nLen4 :=LEN(cCod4)
               nPos4 :=oCuentas:Recno()
               nNivel:=4
   
               SETCUENTA()

               WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CTA_CODIGO,nLen4)==cCod4  

                  IF LEN(oCuentas:CTA_CODIGO)<=nLen4 .OR. nNivel>nMaxCol
                     oCuentas:DbSkip()
                     LOOP
                  ENDIF

                  cCod5 :=oCuentas:CTA_CODIGO
                  nLen5 :=LEN(cCod5)
                  nPos5 :=oCuentas:Recno()
                  nNivel:=5
   
                  SETCUENTA()

                  WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CTA_CODIGO,nLen5)=cCod5  

                    IF LEN(oCuentas:CTA_CODIGO)<=nLen5 .OR. nNivel>nMaxCol
                       oCuentas:DbSkip()
                       LOOP
                    ENDIF

                    cCod6 :=ALLTRIM(oCuentas:CTA_CODIGO)
                    nLen6 :=LEN(cCod6)
                    nPos6 :=oCuentas:Recno()
                    nNivel:=6
   
                    SETCUENTA()

                    WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CTA_CODIGO,nLen6)==cCod6  

                      IF LEN(oCuentas:CTA_CODIGO)<=nLen6 .OR. nNivel>nMaxCol
                         oCuentas:DbSkip()
                         LOOP
                      ENDIF
  
                      cCod7 :=ALLTRIM(oCuentas:CTA_CODIGO)
                      nLen7 :=LEN(cCod7)
                      nPos7 :=oCuentas:Recno()
                      nNivel:=7

                      SETCUENTA()

                      WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CTA_CODIGO,nLen7)==cCod7  

                         IF LEN(oCuentas:CTA_CODIGO)<=nLen7 .OR. nNivel>nMaxCol
                            oCuentas:DbSkip()
                            LOOP
                         ENDIF
  
                         cCod8 :=ALLTRIM(oCuentas:CTA_CODIGO)
                         nLen8 :=LEN(cCod8)
                         nPos8 :=oCuentas:Recno()
                         nNivel:=8
  
                         SETCUENTA()

                         oCuentas:DbSkip()

                      ENDDO

                      TOTALCUENTA(7,nPos4)
          
                      // oCuentas:DbSkip()

                   ENDDO

                   TOTALCUENTA(6,nPos4)
              
                 ENDDO

                 TOTALCUENTA(5,nPos4)

               ENDDO

               TOTALCUENTA(4,nPos4)

            ENDDO

            TOTALCUENTA(3,nPos3) // Antes nPos2

         ENDDO

         TOTALCUENTA(2,nPos2)

      ENDDO

      TOTALCUENTA(1,nPos1)

//    oCuentas:DbSkip()

   ENDDO

   // Total Pasivo + Patrimonio

   oCuentas:GoBottom()
   TOTALCUENTA(1 , oCuentas:Recno() )
   oCuentas:aDataFill:=ACLONE(aNew)

   // Depura, Busca que la Columna no posea Valores Vacios con Anterioridad

   FOR I=2 TO oCuentas:RecCount()
      oCuentas:GOTO(I)
      FOR U=1 TO 10
         cCol:=oCuentas:FieldGet("COL"+STRZERO(U,2))
         IF "---"$cCol
            nPos:=oCuentas:FieldPos("COL"+STRZERO(U,2))
            IF Empty(oCuentas:aDataFill[I-1,nPos])
               ARREDUCE(oCuentas:aDataFill,I)
            ENDIF
         ENDIF
      NEXT 
   NEXT I

   oMeter:Set(oCuentas:RecCount())

 
// oCuentas:Browse()
// ViewArray(aNew)

RETURN oCuentas

/*
// Califica la Cuenta
*/
FUNCTION SETCUENTA(nPos)
    LOCAL aData,lAsiento:=.F.,lOk:=.F.,cTotal:=""

    nPos:=oCuentas:Recno()

    IF oCuentas:ASIENTO=1
       lAsiento:=.T.
    ENDIF

    IF ALLTRIM(oCuentas:CTA_CODIGO)="TOTAL"
       RETURN .T.
    ENDIF

    IF ValType(oText)="O"
      oText:SetText(oCuentas:CTA_CODIGO)
    ENDIF

    oCuentas:REPLACE("TITULO",SPACE(nNivel)+oCuentas:CTA_DESCRI)

    IF nNivel=nMaxCol 
       // Este es el Nivel Maximo

       lOk:=.T.

       IF lTotales 

         Atail(aNew)[6]:=LEN(aNew)
         aData:=ACLONE(oCuentas:aDataFill[nPos])
         AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
         AADD(aNew,ACLONE(aData))

       ENDIF

       oCuentas:Replace("TIPO","D") // Cuenta de Detalle
       oCuentas:Replace("COL"+STRZERO(nMaxCol-nNivel+1,2),BUILDTOTAL(TRAN(oCuentas:SALDO,cPicture)))
       oCuentas:Replace("COL",nNivel)

       AADD(aNew,ACLONE(oCuentas:aDataFill[nPos]))

    ENDIF

    IF nNivel<nMaxCol // Cuenta Titulo

       lOk:=.T.

       IF lTotales

         Atail(aNew)[6]:=LEN(aNew)
         aData:=ACLONE(oCuentas:aDataFill[nPos])
         AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
         AADD(aNew,ACLONE(aData))

       ENDIF

       IF lAsiento
         cTotal:=BUILDTOTAL(TRAN(oCuentas:SALDO,cPicture))
       ENDIF

       oCuentas:Replace("TIPO ","T") // Titulo
       oCuentas:Replace("COL"+STRZERO(nMaxCol-nNivel+1,2),cTotal)
       oCuentas:Replace("COL",nNivel)

       AADD(aNew,ACLONE(oCuentas:aDataFill[nPos]))

    ENDIF

//    IF !lOk .AND. lAsiento
//       ? "ESTE DEBE LLEVAR TOTALES",oCuentas:CTA_CODIGO,nNivel,"nNivel"
//       ? nMaxCol,nNivel,STRZERO(nMaxCol-nNivel+2,2)
//    ENDIF

    lTotales:=.F.

    Atail(aNew)[6]:=LEN(aNew)

RETURN .T.

FUNCTION TOTALCUENTA(nNiv,nPos,lPasCap)
  LOCAL nRec:=oCuentas:Recno(),aData:={},nAt,cCol

  nNivel:=nNiv

  DEFAULT lPasCap:=.F.
//? cVar,MacroEje(cVar)

  nNivMax:=MAX(nNivMax,nNiv)

  IF nNivel<nMaxCol .AND. oCuentas:aDataFill[nPos,18]=0

     cCol :="COL"+STRZERO(nMaxCol-nNivel+2-1,2)
     nAt  :=oCuentas:FieldPos(cCol)

     // Agrega las Rayas
     IF !Empty(oCuentas:CTA_CODIGO) .AND. oCuentas:CTA_CODIGO<>"TOTAL" .OR. EJECUTAR("ISCTADET",oCuentas:CTA_CODIGO,.F.)

       aData:=ACLONE(oCuentas:aDataFill[nPos])
       AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
       aData[nAt-1]:=REPLICATE("-",40)
       // Linea Vacia de Totales
       AADD(aNew,ACLONE(aData))
       Atail(aNew)[6]:=LEN(aNew)

     ENDIF

     aData:=ACLONE(oCuentas:aDataFill[nPos])

     // aData[02]:="Total "+aData[2]
     aData[17]:=ALLTRIM(cTextT)+" "+aData[2]
     aData[05]:="R"
     aData[04]:=nNivel
     aData[nAt]:=BUILDTOTAL(TRAN(aData[3],cPicture))
 
/*
//   oCuentas:Replace("TIPO","R") // Resultado
//   oCuentas:Replace("COL"+STRZERO(nMaxCol-nNivel+2,2),"")
//   oCuentas:Replace("COL",nNivel)
*/

     AADD(aNew,ACLONE(aData))
     Atail(aNew)[6]:=LEN(aNew)

     // Separador

     IF nNivel=1
        AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
        aData[nAt]:=REPLICATE("=",40)
        AADD(aNew,ACLONE(aData))
        Atail(aNew)[6]:=LEN(aNew)
        AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
        AADD(aNew,ACLONE(aData))
     ENDIF

     lTotales:=.T.

//  ENDIF

  ENDIF

  Atail(aNew)[6]:=LEN(aNew)

  IF ALLTRIM(cCtaCap)=oCuentas:aDataFill[nPos,1] .AND. .F.

      cCol :="COL"+STRZERO(nMaxCol-nNivel+2-1,2)
      nAt  :=oCuentas:FieldPos(cCol)

      aData:=ACLONE(oCuentas:aDataFill[nPos])
      // AADD(oCuentas:aDataFill,aData)

      aData[01]:="TOTAL"
      aData[02]:=cPasCap
      aData[05]:="R"
      aData[04]:=nNivel
      aData[nAt]:=BUILDTOTAL(TRAN(nPasCap,cPicture))
      aData[17]:=ALLTRIM(cTextT)+" "+aData[2]

      Atail(aNew)[6]:=LEN(aNew)
      // AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
      AADD(aNew,ACLONE(aData))

      AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
      aData[nAt]:=REPLICATE("=",40)
      AADD(aNew,ACLONE(aData))
      Atail(aNew)[6]:=LEN(aNew)
      AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
      AADD(aNew,ACLONE(aData))

  ENDIF

RETURN .T.

FUNCTION BUILDTOTAL(cTotal)

   IF oDp:cBalCre="-" .OR. !("-"$cTotal)
      RETURN cTotal
   ENDIF

   IF oDp:cBalCre="C" .AND. "-"$cTotal
      cTotal:=STRTRAN(cTotal,"-","")+"CR"
   ENDIF

   IF oDp:cBalCre="(" .AND. "-"$cTotal
      cTotal:="("+ALLTRIM(STRTRAN(cTotal,"-",""))+")"
   ENDIF

RETURN cTotal

/*
// Calcula la Utilidad del Ejercicio
*/
FUNCTION GETUTILIDAD()
   LOCAL aCtaGp:={oDp:cCtaGp1,oDp:cCtaGp2,oDp:cCtaGp3,oDp:cCtaGp4,oDp:cCtaGp5,oDp:cCtaGp6}
   LOCAL nLen,cWhere:="",cInner:=""

   FOR I=1 TO LEN(aCtaGp)

     aCtaGp[I]:=ALLTRIM(aCtaGp[I])
     nLen:=LEN(aCtaGp[I])
     IF !Empty(aCtaGp[I])
       cWhere:=cWhere+IIF(Empty(cWhere), "" , " OR ")+"LEFT(MOC_CUENTA,"+LSTR(nLen)+")"+GetWhere("=",aCtaGp[I])
     ENDIF

   NEXT I

   IF !Empty(cCodMon)
      cInner:=[ INNER JOIN DPHISMON ON HMN_CODIGO]+GetWhere("=",cCodMon)+[ AND MOC_FECHA=HMN_FECHA WHERE ]+CRLF
   ENDIF0

   cWhere:=cInner+" ("+cWhere+") AND (MOC_FECHA"+GetWhere(">=",oDp:dFchInicio)+" AND MOC_FECHA"+GetWhere("<=",dHasta)+")"+;
           " AND MOC_CODSUC"+GetWhere("=",RGO_C7)+;
           " AND MOC_ACTUAL<>'N'"

   IF !Empty(cCenCos) 
 
      cWhere:=cWhere+ iif(Empty(cWhere), " ", " AND ")+;
              "MOC_CENCOS"+GetWhere("=",cCenCos)
   ENDIF

   IF !Empty(cCodDep) 
 
      cWhere:=cWhere+ iif(Empty(cWhere), " ", " AND ")+;
              "MOC_CODDEP"+GetWhere("=",cCodDep)
   ENDIF


   IF Empty(cCodMon)
      nUtil:=SQLGET(IF(oDp:lPrecontab,"DPASIENTOSPREC","DPASIENTOS"),"SUM(MOC_MONTO)",cWhere)
   ELSE

      nUtil :=SQLGET(IF(oDp:lPrecontab,"DPASIENTOSPREC","DPASIENTOS"),"ROUND(MOC_MONTO/HMN_VALOR,2) AS MOC_MONTO ",cWhere)

   ENDIF

   nUtil:=CTOO(nUtil,"N")

  // ? nUtil,CLPCOPY(oDp:cSql),cCtaUtil

RETURN nUtil

/*
// Obtiene el monto de la Utilidad según la la cuenta de Integración
*/
FUNCTION CTAUTILIDAD()
   LOCAL nUtil :=0
   LOCAL cWhere:="",cInner:=""

   cWhere:=cWhere+"MOC_CUENTA"+GetWhere("=",cCtaUtil)

   cWhere:="("+cWhere+" AND MOC_FECHA"+GetWhere("<=",dHasta)+")"+;
           " AND MOC_CODSUC"+GetWhere("=",RGO_C7)+;
           " AND MOC_ACTUAL<>'N'"

   IF !Empty(cCenCos) 
 
      cWhere:=cWhere+ iif(Empty(cWhere), " ", " AND ")+;
              "MOC_CENCOS"+GetWhere("=",cCenCos)
   ENDIF


   IF !Empty(cCodDep) 
 
      cWhere:=cWhere+ iif(Empty(cWhere), " ", " AND ")+;
              "MOC_CODDEP"+GetWhere("=",cCodDep)
   ENDIF



   IF Empty(cCodMon)

      nUtil:=SQLGET(IF(oDp:lPrecontab,"DPASIENTOSPREC","DPASIENTOS"),"SUM(MOC_MONTO)",cWhere)

   ELSE

      cInner:=[ INNER JOIN DPHISMON ON HMN_CODIGO]+GetWhere("=",cCodMon)+[ AND MOC_FECHA=HMN_FECHA  WHERE ]
      nUtil :=SQLGET(IF(oDp:lPrecontab,"DPASIENTOSPREC","DPASIENTOS"),"ROUND(MOC_MONTO/HMN_VALOR,2)",cInner+cWhere)

   ENDIF

   nUtil:=CTOO(nUtil,"N")

//  ? nUtil,CLPCOPY(oDp:cSql),cCtaUtil

RETURN nUtil



FUNCTION BGCALSALDO(oMeter,oText)
   LOCAL cCodCta
 
   oMeter:SetTotal(oTable:RecCount())

   //ClassName(),oText:ClassName()

   // Calcula los Saldos
   oTable:GoTop()
   WHILE !oTable:Eof()

      cCodCta:=ALLTRIM(oTable:MOC_CUENTA)
      oMeter:Set(oTable:RecNo())

      IF ValType(oText)="O"
        oText:SetText(cCodCta)
      ENDIF

      // oTable:REPLACE("MOC_ASIENTO",.T.)
      WHILE LEN(cCodCta)>0

         nAt:=ASCAN(oCuentas:aDataFill,{|a,n|a[1]==cCodCta})

         IF nAt>0
            nLastAt:=nAt
            oCuentas:Goto(nAt)

// ? cCodCta,oTable:MOC_CUENTA,oCuentas:SALDO,oTable:MOC_MONTO

            oCuentas:REPLACE("SALDO"  , oCuentas:SALDO+oTable:MOC_MONTO       )

            oCuentas:REPLACE("ASIENTO", IF(cCodCta==ALLTRIM(oTable:MOC_CUENTA) , 1 , 0 ))
         ENDIF

         cCodCta:=LEFT(cCodCta,LEN(cCodCta)-1)

      ENDDO
      
      oTable:DbSkip()

   ENDDO

// oTable:Browse()

RETURN NIL

// EOF

