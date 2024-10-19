// Programa   : DPCTABANCOSLD
// Fecha/Hora : 02/05/2006 21:10:43
// Propósito  : Visualizar Resumen de Saldos
// Creado Por : Juan Navas
// Llamado por: DPCTABANCOCON
// Aplicación : Tesorería
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodBco,cCodCta,lConcil,cCodSuc)
  LOCAL cSql,oTable,aData,nSaldo:=0,cTitle:="Saldo"+" de Cuenta Bancaria "
  LOCAL cAno:="",nDebe:=0,nTDebe:=0,nHaber:=0,nTHaber:=0,nSaldo:=0,nTTran:=0,nTran:=0,nAnual:=0
  LOCAL nMes,nAno,aTotal:={},nMtoIdb:=0,nSaldoI:=0,nMtoIdb:=0
  LOCAL aNew:={},aLine:={},aMes:={},lEmpty:=.F.,nSumIdb:=0

  DEFAULT cCodBco:=SQLGET("DPCTABANCO","BCO_CODIGO"),;
          cCodCta:=SQLGET("DPCTABANCO","BCO_CTABAN","BCO_CODIGO"+GetWhere("=",cCodBco)),;
          cCodSuc:=oDp:cSucursal,;
          lConcil:=.T.


   IF Type("oSldBco")="O" .AND. oSldBco:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oSldBco,GetScript())
   ENDIF

  cSql:=" SELECT YEAR(MOB_FECHA) AS ANO, MONTH(MOB_FECHA) AS MES,COUNT(*) AS CUANTOS, "+;
        " SUM(IF(TDB_SIGNO=1,MOB_MONTO,0))  AS DEBE ,"+;
        " SUM(IF(TDB_SIGNO=-1,MOB_MONTO,0)) AS HABER,"+;
        " 0 AS SALDO, "+;
        " SUM(MOB_MTOIDB) AS MTOIDB,"+;
        " 0 AS SALDOI,"+;
        " 1 AS TYPE,YEAR(MOB_FECHA) AS NANO,MONTH(MOB_FECHA) AS NMES "+;
        " FROM DPCTABANCOMOV "+;
        " LEFT JOIN DPBANCOTIP ON TDB_CODIGO=MOB_TIPO "+;
        " WHERE MOB_CODBCO"+GetWhere("=",cCodBco)+;
        " AND   MOB_CUENTA"+GetWhere("=",cCodCta)+;
        " AND   MOB_CODSUC"+GetWhere("=",cCodSuc)+;
        " AND   MOB_ACT <> 0 "+;
        " AND   MOB_FECHA"+GetWhere("<>",CTOD(""))+;
        " GROUP BY YEAR(MOB_FECHA),MONTH(MOB_FECHA) "+;
        " ORDER BY MOB_FECHA "


  IF lConcil
     cSql  :=STRTRAN(cSql,"MOB_FECHA","MOB_FCHCON")
     cTitle:=cTitle + " Según Conciliación"
  ELSE
     cTitle:=cTitle + " Según Libros"
  ENDIF

  oTable:=OpenTable(cSql,.T.)

// oTable:Browse()
// RETURN 

  oTable:GoTop()
  nAno:=oTable:ANO

  WHILE !oTable:EOF() 



     // Total Anual

     IF nAno<>oTable:ANO 

        aTotal:=ACLONE(aNew)

        ADEPURA(aTotal,{|a,n| a[1]<>nAno  })

        aTotal :=ATOTALES(aTotal) // New,{|a,n|a[9]=1 .AND. a[1]=cAno} )

        // nSaldo :=aTotal[4]-aTotal[5]
        nSaldoI:=nSaldo-nMtoIdb // Aqui debe Colocar el Mismo Valor del Diciembre oTable:MTOIDB // aTotal[7]

        aLine :={nAno               ,;
               "Total "+LSTR(nAno),;
               aTotal[3]          ,;
               aTotal[4]          ,;
               aTotal[5]          ,;
               nSaldo             ,;
               aTotal[7]          ,;
               nSaldoI            ,;
               2                  ,;
               nAno               ,;
               nMes}


        AADD(aNew,aLine)

     ENDIF

nSumIdb:=nSumIdb+oTable:MTOIDB

     nMes   :=oTable:MES
     nAno   :=oTable:ANO
     nSaldo :=nSaldo+oTable:DEBE-oTable:HABER
//     nSaldoI:=nSaldo-oTable:MTOIDB
     nSaldoI:=nSaldo-nSumIdb

     nMtoIdb:=oTable:MTOIDB // Necesario para sumar al Final del Año

     aLine:={oTable:ANO         ,;
             CMES(oTable:MES)   ,;
             CTOO(oTable:CUANTOS,"N"),;
             oTable:DEBE        ,;
             oTable:HABER       ,;
             nSaldo             ,;
             oTable:MTOIDB      ,;
             nSaldoI            ,;
             oTable:TYPE        ,;
             oTable:NANO        ,;
             oTable:NMES}

      AADD(aNew,ACLONE(aLine))
 
//     nSaldo :=nSaldo+oTable:DEBE-oTable:HABER
//     nSaldoI:=nSaldo-oTable:MTOIDB

//     nMes  :=oTable:MES
//     nAno  :=oTable:ANO

     oTable:DbSkip()

  ENDDO


  // Total general

  oTable:Replace("TYPE",3)

//  aTotal:=ATOTALES(aNew,{|a,n|a[9]=1} )

  aTotal:=ACLONE(aNew)
  ADEPURA(aTotal,{|a,n| a[1]<>nAno  })
  aTotal:=ATOTALES(aTotal) // New,{|a,n|a[9]=1 .AND. a[1]=cAno} )


  nSaldo :=aTotal[4]-aTotal[5]
  nSaldoI:=nSaldo-aTotal[7]

  oTable:Replace("CUANTOS",aTotal[3])
  oTable:Replace("DEBE"   ,aTotal[4])
  oTable:Replace("HABER"  ,aTotal[5])
  oTable:Replace("SALDO"  ,nSaldo   )
  oTable:Replace("MTOIDB" ,aTotal[7])
  oTable:Replace("SALDOI" ,nSaldoI  )
  oTable:End()


  aLine:={nAno               ,;
         "Total General"     ,;
          CTOO(oTable:CUANTOS,"N"),;
          oTable:DEBE        ,;
          oTable:HABER       ,;
          nSaldo             ,;
          oTable:MTOIDB      ,;
          nSaldoI            ,;
          oTable:TYPE        ,;
          nAno               ,;
          nMes}

  IF Empty(aNew)
    lEmpty:=.T.
    AADD(aNew,aLine)
  ENDIF
 
//  ADEPURA(aNew,{|a,n| a[9]<>1})
// ViewArray(aNew)
// RETURN
 
  ViewData(aNew,cCodBco,cCodCta,cTitle)


  IF lEmpty
    oSldBco:oBrw:bLDblClick:={||NIL}
  ENDIF

RETURN NIL

FUNCTION ViewData(aData,cCodBco,cCodCta,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData,{|a,n| a[9]=1})
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   aTotal[6]:=aTotal[4]-aTotal[5]
   aTotal[8]:=aTotal[6]-aTotal[7]


   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

// oSldBco:=DPEDIT():New(cTitle,"DPBCOSLD.EDT","oSldBco",.T.)

   DpMdi(cTitle,"oSldBco","DPBCOSLD.EDT")


   oSldBco:Windows(0,0,aCoors[3]-200,650+200+180,.T.) // Maximizado

   oSldBco:cCodBco :=cCodBco
   oSldBco:lConcil :=lConcil
   oSldBco:cCodCta :=cCodCta
   oSldBco:aData   :=ACLONE(aData)
   oSldBco:cNombre :=MYSQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",cCodBco))
   oSldBco:lMsgBar :=.F.
   oSldBco:cPicture:="99,999,999,999,999.99"
   oSldBco:lTmdi   :=.T.

   oSldBco:nClrPane1:=oDp:nClrPane1
   oSldBco:nClrPane2:=oDp:nClrPane2

   IF oSldBco:lConcil

     oSldBco:nClrPane1:=15728607
     oSldBco:nClrPane2:=15466455

     oSldBco:nClrPaneT1:=12124063
     oSldBco:nClrPaneT2:=12124063

     oSldBco:nClrPaneM1:=13303754 
     oSldBco:nClrPaneM2:=13303754 

   ELSE

     oSldBco:nClrPane1:=14155775
     oSldBco:nClrPane2:=9240575

     oSldBco:nClrPaneT1:=10469119 // 33023
     oSldBco:nClrPaneT2:=10469119 // 33023

     oSldBco:nClrPaneM1:=12703487 //12046079 // 8235263
     oSldBco:nClrPaneM2:=12703487 // 12046079 // 8235263

   ENDIF



//    oSldBco:oBrw:=TXBrowse():New( oSldBco:oDlg )

   oSldBco:oBrw:=TXBrowse():New(oSldBco:oWnd)

   oSldBco:oBrw:SetArray( aData, .F. )

   oSldBco:oBrw:SetFont(oFont)
   oSldBco:oBrw:lFooter     := .T.
   oSldBco:oBrw:lHScroll    := .T.
   oSldBco:oBrw:nHeaderLines:= 2
   oSldBco:oBrw:lFooter     := .T.


   oSldBco:oCol:=oSldBco:oBrw:aCols[1]
   oSldBco:oCol:cHeader:="Año"   
   oSldBco:oCol:nWidth :=36
   oSldBco:oCol:nHeadStrAlign:=AL_RIGHT
   oSldBco:oCol:nDataStrAlign:=AL_RIGHT
   oSldBco:oCol:nFootStrAlign:=AL_RIGHT

   oSldBco:oCol:bStrData     :={|oBrw|oBrw:=oSldBco:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,1],"9999")}
   oSldBco:oCol:cFooter      :="Reg: "+LSTR(LEN(aData))

   oSldBco:oCol:=oSldBco:oBrw:aCols[2]
   oSldBco:oCol:cHeader:="Mes"   
   oSldBco:oCol:nWidth :=80
   oSldBco:oCol:cFooter      :="Total General "


//   oSldBco:oCol:bStrData     :={|uValue|uValue:=oSldBco:oBrw:aArrayData[oSldBco:oBrw:nArrayAt,2],;
//                                        uValue}
//
//                                      CMES(oSldBco:oBrw:aArrayData[oSldBco:oBrw:nArrayAt,2])}

   oSldBco:oCol:=oSldBco:oBrw:aCols[3]
   oSldBco:oCol:cHeader:="Cant."+CRLF+"Reg."   
   oSldBco:oCol:nWidth :=38
   oSldBco:oCol:nHeadStrAlign:=AL_RIGHT
   oSldBco:oCol:nDataStrAlign:=AL_RIGHT
   oSldBco:oCol:nFootStrAlign:=AL_RIGHT
   oSldBco:oCol:cFooter      :=FDP(aTotal[3],'999,999')


   oSldBco:oCol:=oSldBco:oBrw:aCols[4]
   oSldBco:oCol:cHeader      :="Debe"   
   oSldBco:oCol:nWidth       :=155
   oSldBco:oCol:bStrData     :={|oBrw|oBrw:=oSldBco:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oSldBco:cPicture)}
   oSldBco:oCol:nHeadStrAlign:=AL_RIGHT
   oSldBco:oCol:nDataStrAlign:=AL_RIGHT
   oSldBco:oCol:nFootStrAlign:=AL_RIGHT
   oSldBco:oCol:cFooter      :=FDP(aTotal[4],'9,999,999,999,999.99')


//   oSldBco:oCol:bClrStd      := {|oBrw|oBrw:=oSldBco:oBrw,{CLR_HBLUE, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }


   oSldBco:oCol:bClrStd      := {|oBrw,nClrPane1,nClrPane2|oBrw     :=oSldBco:oBrw,;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM1,oSldBco:nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM2,oSldBco:nClrPane2),;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT1,nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT2,nClrPane2),;
                                 {CLR_HBLUE,if( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }



   oSldBco:oCol:=oSldBco:oBrw:aCols[5]
   oSldBco:oCol:cHeader:="Haber"   
   oSldBco:oCol:nWidth :=155
   oSldBco:oCol:bStrData     :={|oBrw|oBrw:=oSldBco:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oSldBco:cPicture)}
   oSldBco:oCol:nHeadStrAlign:=AL_RIGHT
   oSldBco:oCol:nDataStrAlign:=AL_RIGHT
   oSldBco:oCol:nFootStrAlign:=AL_RIGHT
   oSldBco:oCol:cFooter      :=FDP(aTotal[5],'9,999,999,999,999.99')


// oSldBco:oCol:bClrStd      := {|oBrw|oBrw:=oSldBco:oBrw,{CLR_HRED, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

   oSldBco:oCol:bClrStd      := {|oBrw,nClrPane1,nClrPane2|oBrw     :=oSldBco:oBrw,;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM1,oSldBco:nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM2,oSldBco:nClrPane2),;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT1,nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT2,nClrPane2),;
                                 {CLR_HRED,if( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }


   oSldBco:oCol:=oSldBco:oBrw:aCols[6]
   oSldBco:oCol:cHeader:="Saldo"+CRLF+"Sin ITF"   
   oSldBco:oCol:nWidth :=155
   oSldBco:oCol:bStrData     :={|oBrw|oBrw:=oSldBco:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oSldBco:cPicture)}
   oSldBco:oCol:nHeadStrAlign:=AL_RIGHT
   oSldBco:oCol:nDataStrAlign:=AL_RIGHT
   oSldBco:oCol:nFootStrAlign:=AL_RIGHT
   oSldBco:oCol:bClrStd      := {|oBrw,nClrPane1,nClrPane2|oBrw     :=oSldBco:oBrw,;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM1,oSldBco:nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM2,oSldBco:nClrPane2),;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT1,nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT2,nClrPane2),;
                                 {IIF(oBrw:aArrayData[oBrw:nArrayAt,6]>0,CLR_HBLUE,CLR_HRED),if( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }

   oSldBco:oCol:cFooter      :=FDP(aTotal[6],'9,999,999,999,999.99')

   AEVAL(oSldBco:oBrw:aCols,{|oCol|oCol:oHeaderFont  :=oFontB})



   oSldBco:oCol:=oSldBco:oBrw:aCols[7]
   oSldBco:oCol:cHeader:="Monto"+CRLF+"ITF"   
   oSldBco:oCol:nWidth :=125
   oSldBco:oCol:bStrData     :={|oBrw|oBrw:=oSldBco:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],oSldBco:cPicture)}
   oSldBco:oCol:nHeadStrAlign:=AL_RIGHT
   oSldBco:oCol:nDataStrAlign:=AL_RIGHT
   oSldBco:oCol:nFootStrAlign:=AL_RIGHT
   oSldBco:oCol:cFooter      :=FDP(aTotal[7],'9,999,999,999,999.99')


   oSldBco:oCol:bClrStd      := {|oBrw,nClrPane1,nClrPane2|oBrw     :=oSldBco:oBrw,;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM1,oSldBco:nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM2,oSldBco:nClrPane2),;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT1,nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT2,nClrPane2),;
                                 {CLR_HRED,if( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }



   oSldBco:oCol:=oSldBco:oBrw:aCols[8]
   oSldBco:oCol:cHeader:="Saldo"+CRLF+"Con ITF"   
   oSldBco:oCol:nWidth :=155
   oSldBco:oCol:bStrData     :={|oBrw|oBrw:=oSldBco:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,8],oSldBco:cPicture)}
   oSldBco:oCol:nHeadStrAlign:=AL_RIGHT
   oSldBco:oCol:nDataStrAlign:=AL_RIGHT
   oSldBco:oCol:nFootStrAlign:=AL_RIGHT
   oSldBco:oCol:bClrStd      := {|oBrw,nClrPane1,nClrPane2|oBrw     :=oSldBco:oBrw,;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM1,oSldBco:nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM2,oSldBco:nClrPane2),;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT1,nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT2,nClrPane2),;
                                 {IIF(oBrw:aArrayData[oBrw:nArrayAt,8]>0,CLR_HBLUE,CLR_HRED),if( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }

   oSldBco:oCol:cFooter      :=FDP(aTotal[8],'9,999,999,999,999.99')


   oSldBco:oCol:=oSldBco:oBrw:aCols[9]
   oSldBco:oCol:cHeader :="Tipo"   
   oSldBco:oCol:nWidth  :=80
   oSldBco:oCol:cFooter :=""
   oSldBco:oCol:bStrData:={|oBrw|oBrw:=oSldBco:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,9],"99")}


   oSldBco:oCol:=oSldBco:oBrw:aCols[10]
   oSldBco:oCol:cHeader :="Año"   
   oSldBco:oCol:nWidth  :=40
   oSldBco:oCol:cFooter :=""

   oSldBco:oCol:=oSldBco:oBrw:aCols[11]
   oSldBco:oCol:cHeader :="#"+CRLF+"Mes"   
   oSldBco:oCol:nWidth  :=40
   oSldBco:oCol:cFooter :=""


   AEVAL(oSldBco:oBrw:aCols,{|oCol|oCol:oHeaderFont  :=oFontB})


   AEVAL(oSldBco:oBrw:aCols,{|oCol|oCol:bLClickFooter:= {|r,c,f,o| oSldBco:VIEWRECORD(.T.)} } )

// oSldBco:oBrw:DelCol(9)
// oSldBco:oBrw:DelCol(9)
// oSldBco:oBrw:DelCol(9)
//   oSldBco:oBrw:bClrStd := {|oBrw|oBrw:=oSldBco:oBrw,{0, iif( oBrw:nArrayAt%2=0,14155775,9240575 ) } }

   oSldBco:oBrw:bClrStd      := {|oBrw,nClrPane1,nClrPane2|oBrw     :=oSldBco:oBrw,;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM1,oSldBco:nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=2,oSldBco:nClrPaneM2,oSldBco:nClrPane2),;
                                                           nClrPane1:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT1,nClrPane1),;
                                                           nClrPane2:=IF(oBrw:aArrayData[oBrw:nArrayAt,7+2]=3,oSldBco:nClrPaneT2,nClrPane2),;
                                 {0,if( oBrw:nArrayAt%2=0,nClrPane1,nClrPane2 ) } }

   oSldBco:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oSldBco:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oSldBco:oBrw:CreateFromCode()
   oSldBco:bValid   :={|| EJECUTAR("BRWSAVEPAR",oSldBco)}
   oSldBco:BRWRESTOREPAR()

   oSldBco:oWnd:oClient   := oSldBco:oBrw
   oSldBco:oBrw:bLDblClick:={|oBrw|oSldBco:ViewRecord()}

   oSldBco:Activate( {||oSldBco:ViewDatBar(oSldBco)} )

   oSldBco:oBrw:GoBottom()   

RETURN NIL

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oSldBco:oDlg

   // oSldBco:oBrw:GoBottom(.T.)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD 


   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   oSldBco:oFontBtn   :=oFont    
   oSldBco:nClrPaneBar:=oDp:nGris
   oSldBco:oBrw:oLbx  :=oSldBco

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP" ;
          TOP PROMPT "Detalles"; 
          ACTION  oSldBco:ViewRecord()


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\COMPARATIVO.BMP" ;
          TOP PROMPT "Comparar"; 
          ACTION oSldBco:COMPARATIVOS()


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oSldBco:oBrw)

   oBtn:cToolTip:="Filtrar Registros"



/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
              ACTION  (oSldBco:oRep:=REPORTE("INVCOSULT"),;
                  oSldBco:oRep:SetRango(1,oSldBco:cCodBco,oSldBco:cCodBco))

   oBtn:cToolTip:="Imprimir Intereses"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oSldBco:oBrw,oSldBco:cTitle,oSldBco:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (EJECUTAR("BRWTOHTML",oSldBco:oBrw))

   oBtn:cToolTip:="Generar Archivo html"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oSldBco:oBrw:GoTop(),oSldBco:oBrw:Setfocus())

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oSldBco:oBrw:PageDown(),oSldBco:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oSldBco:oBrw:PageUp(),oSldBco:oBrw:Setfocus())
*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oSldBco:oBrw:GoBottom(),oSldBco:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oSldBco:Close()

  oSldBco:oBrw:SetColor(0,oSldBco:nClrPane1) // 14155775)

/*
  @ 0.1,46 SAY " Código: "+oSldBco:cCodBco+" Cuenta: "+oSldBco:cCodCta ;
           OF oBar BORDER SIZE 345,18

  @ 1.4,46 SAY " Banco: "+oSldBco:cNombre OF oBar BORDER SIZE 345,18
*/

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD

  oBar:SetSize(NIL,110,.T.)

  @ 65,15 SAY "  Banco " OF oBar BORDER SIZE 70,18 COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT PIXEL
  @ 85,15 SAY " Nombre " OF oBar BORDER SIZE 70,18 COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT PIXEL

  @ 65,88 SAY " "+oSldBco:cCodBco+"  "+oSldBco:cCodCta OF oBar BORDER SIZE 375,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont PIXEL
  @ 85,88 SAY " "+oSldBco:cNombre OF oBar BORDER SIZE 375,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont PIXEL

RETURN .T.

FUNCTION VIEWRECORD(lTotal)
  LOCAL oBrw:=oSldBco:oBrw
  LOCAL nAno:=oBrw:aArrayData[oBrw:nArrayAt,1]
  LOCAL nMes:=oBrw:aArrayData[oBrw:nArrayAt,9+2]
  LOCAL dDesde,dHasta
  LOCAL cTitle:=""

  DEFAULT lTotal:=.F.

  IF nMes=0
    dDesde:=CTOD("01/01/"+LSTR(nAno))
    dHasta:=CTOD("31/12/"+LSTR(nAno))
    cTitle:="Año "+LSTR(nAno)
  ELSE
    dDesde:=CTOD("01/"+LSTR(nMes)+"/"+LSTR(nAno))
    dHasta:=FCHFINMES(dDesde)
    cTitle:=" "+LSTR(nAno)+"/"+CMES(nMes)
  ENDIF

  IF "Gener"$oBrw:aArrayData[oBrw:nArrayAt,2] .OR. lTotal
    dDesde:=CTOD("")
    dHasta:=CTOD("")
    cTitle:="Total hasta el Año "+LSTR(nAno)
  ENDIF
 
  IF oSldBco:lConcil

      EJECUTAR("DPCTABCOCONVIEW",oSldBco:cCodBco,oSldBco:cCodCta,;
                                 oBrw:aArrayData[oBrw:nArrayAt,1],;
                                 dDesde,;
                                 dHasta,oDp:cSucursal,"Conciliación Bancaria ["+cTitle+"]",oSldBco:lConcil)

  ELSE


      EJECUTAR("DPCTABCOCONVIEW",oSldBco:cCodBco,oSldBco:cCodCta,;
                                 oBrw:aArrayData[oBrw:nArrayAt,1],;
                                 dDesde,;
                                 dHasta,oDp:cSucursal,"Movimientos Bancarios ["+cTitle+"]",oSldBco:lConcil)

/*
      RUNNEW("DPCTABCOMOVVIEW",oSldBco:cCodBco,oSldBco:cCodCta,;
                                 oBrw:aArrayData[oBrw:nArrayAt,1],;
                                 dDesde,;
                                 dHasta,oDp:cSucursal,"Estado de Cuenta ["+cTitle+"]",oSldBco:lConcil)
*/

/*
      EJECUTAR("DPCTABCOMOVVIEW",oSldBco:cCodBco,oSldBco:cCodCta,;
                                 oBrw:aArrayData[oBrw:nArrayAt,1],;
                                 oBrw:aArrayData[oBrw:nArrayAt,2],;
                                 oBrw:aArrayData[oBrw:nArrayAt,3],oDp:cSucursal,"Estado de Cuenta",oSldBco:lConcil)

*/

  ENDIF
RETURN .T.

FUNCTION VERTOTAL()
   ? "VER TOTAL DEBE MOSTRAR TODOS"
RETURN .T.

/*
// Visualizar Comparativos
*/
FUNCTION COMPARATIVOS()
   LOCAL cScope
   LOCAL cTitle  :="Valores Comparativos de Saldos en Cuentas Bancarias"

   cScope :="MOB_CODBCO"+GetWhere("=",oSldBco:cCodBco)+" AND "+;
            "MOB_CUENTA"+GetWhere("=",oSldBco:cCodCta)

   EJECUTAR("DPRUNCOMP","DPBANCOSALDO",oSldBco:cCodCta,oSldBco:cNombre,cTitle,"Mensual",cScope, .T. , .T. )
 
RETURN NIL




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oSldBco)
// EOF
