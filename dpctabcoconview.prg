// Programa   : DPCTABCOCONVIEW
// Fecha/Hora : 19/09/2005 13:45:04
// Propósito  : Visualizar Movimientos Bancarios
// Creado Por : Juan Navas
// Llamado por: DPCTABANCOMOV (Consulta)
// Aplicación : Tesoreria
// Tabla      : DPCTABANCOMOV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodBco,cCuenta,cAno,dDesde,dHasta,cCodSuc,cTitle,lConcil,cWhereIni)
  LOCAL oTable,aLine
  LOCAL aMes:={"ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"}
  LOCAL cSql,cWhere,nAt,nSaldo:=0,nSaldoAnt:=0,nSaldoIdb:=0,nTotalIdb:=0,nRegIdb:=0,nMovIdb:=0
  LOCAL nDebe:=0,nHaber:=0,nMtoIdb:=0,cField,cWhereS,aVars:={},nDif
  LOCAL aDelMes:={}

  DEFAULT cCodBco:=SQLGET("DPCTABANCO","BCO_CODIGO"),;
          cCuenta:=SQLGET("DPCTABANCO","BCO_CTABAN","BCO_CODIGO"+GetWhere("=",cCodBco)),;
          cAno   :=STRZERO(YEAR(oDp:dFecha),4),;
          cCodSuc:=oDp:cSucursal,;
          cTitle :="Movimientos Bancarios ",;
          lConcil:=.F.

   IF Type("oVMobCon")="O" .AND. oVMobCon:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oVMobCon,GetScript())
   ENDIF

// ? cCodBco,cAno,dDesde,dHasta,cTipDoc,cTipTra,lCxC,cCodSuc,cTitle

  IF ValType(dDesde)="C"

     nAt:=ASCAN(aMes,{|a,n|a=UPPE(LEFT(dDesde,3))})

     IF nAt>0

       cAno  :=CTOO(cAno,"C")    

       dDesde:=CTOD("01/"+STRZERO(nAt,2)+"/"+cAno)
       dHasta:=FCHFINMES(dDesde)
       cTitle:=cTitle+" "+DTOC(dDesde)+" "+DTOC(dHasta)


     ENDIF

     IF nAt=0 .AND. VAL(cAno)>0

       dDesde:=CTOD("01/01/"+cAno)
       dHasta:=CTOD("31/12/"+cAno)

       cTitle:=cTitle+" Año : "+cAno

     ENDIF

     IF ValType(dDesde)="C" .AND. dDesde="TOTAL"
        dDesde:=CTOD("")
        dHasta:=CTOD("")
     ENDIF


  ENDIF

  DEFAULT dHasta:=dDesde

  cWhere:="MOB_CODSUC"+GetWhere("=" ,cCodSuc)+" AND "+;
          "MOB_CODBCO"+GetWhere("=" ,cCodBco)+" AND "+;
          "MOB_CUENTA"+GetWhere("=" ,cCuenta)

  IF !EMPTY(dDesde)

    cField   :=" SUM(IF(TDB_SIGNO=1 ,MOB_MONTO,0)) AS DEBE ,"+;
               " SUM(IF(TDB_SIGNO=-1,MOB_MONTO,0)) AS HABER,"+;
               " SUM(MOB_MONTO*TDB_SIGNO) AS SALDO,SUM(MOB_MTOIDB) AS MOB_MTOIDB,SUM(MOB_MONTO*TDB_SIGNO) AS SALDOIDB"
               
    cWhereS :=" INNER JOIN DPBANCOTIP ON TDB_CODIGO=MOB_TIPO "+;
              " WHERE "+cWhere+" AND MOB_FCHCON"+GetWhere("<",dDesde)+;
              " "+IF(lConcil,"AND MOB_FCHCON"+GetWhere("<>",CTOD("")),"")+" AND MOB_ACT=1"


    IF !lConcil
       cWhereS:=STRTRAN(cWhereS,"MOB_FCHCON","MOB_FECHA")
    ENDIF
   
    nDebe    :=SQLGET("DPCTABANCOMOV",cField,cWhereS)

    nHaber   :=DPSQLROW(2,0)
    nSaldoAnt:=DPSQLROW(3,0) 
    nMtoIdb  :=DPSQLROW(4,0) // No se puede sumar nuevamente debido a que saldoIDB ya lo incluye

// ? nMtoIdb,"nMtoIdb"

//    nMtoIdb  :=SQLGET("DPCTABANCOMOV","DPSQLROW(4,0)

    nSaldoIdb:=DPSQLROW(5,0)-nMtoIdb

// ? CLPCOPY(oDp:cSql)

/*
    nSaldoIdb:=SQLGET("DPCTABANCOMOV","SUM(MOB_MTOIDB)",;
                      " INNER JOIN DPBANCOTIP ON TDB_CODIGO=MOB_TIPO "+;
                      " WHERE "+cWhere+" AND MOB_FCHCON"+GetWhere("<",dDesde)+;
                              " AND MOB_FCHCON"+GetWhere("<>",CTOD("")))

*/

  ENDIF

  IF !Empty(dDesde)

     cWhere:=cWhere+" AND ("+;
            "MOB_FCHCON" +GetWhere(">=",dDesde )+" AND "+;
            "MOB_FCHCON" +GetWhere("<=",dHasta )+")"

  ENDIF

  cSql:=" SELECT MOB_TIPO,MOB_DOCUME,MOB_FCHCON,MOB_FECHA,"+;
        " IF(TDB_SIGNO=1,MOB_MONTO,0) AS DEBE ,"+;
        " IF(TDB_SIGNO<0,MOB_MONTO,0) AS HABER,"+;
        " 0 AS SALDO                          ,"+;
        " MOB_IDB,MOB_MTOIDB,0 AS SALDOIDB,MOB_ORIGEN,MOB_NUMTRA,MOB_DESCRI,MOB_DOCASO,MOB_COMPRO,MOB_USUARI "+;
        " FROM DPCTABANCOMOV "+;
        " INNER JOIN DPBANCOTIP ON TDB_CODIGO=MOB_TIPO "+;
        " WHERE MOB_ACT=1 AND MOB_FCHCON"+GetWhere("<>",CTOD(""))+" AND "+cWhere+;
        " ORDER BY MOB_FCHCON "

// ? CLPCOPY(cSql)

   IF !lConcil
      cSql:=STRTRAN(cSql,"MOB_FCHCON","MOB_FECHA")
   ENDIF

   oTable:=OpenTable(cSql,.T.)

// ? CLPCOPY(oDp:cSql)
// oTable:browse()
// oTable:Replace("SALDO"   ,nSaldoAnt)
// oTable:Replace("MOB_MTOIDB",nMtoIdb)
// oTable:Replace("SALDOIDB",nSaldoIdb)


  IF nSaldoAnt<>0
    
     nSaldoAnt:=nDebe-nHaber

     aLine:=ACLONE(oTable:aDataFill[1])
     AEVAL(aLine,{|a,n|aLine[n]:=CTOEMPTY(a)})
     aLine[2]:="Anterior"
     aLine[9+2]:="Saldo Anterior "
     aLine[3]:=dDesde-1
     aLine[6]:=0 // nSaldoAnt
//   AADD(oTable:aDataFill,NIL)
//   AINS(oTable:aDataFill,1)
//   oTable:aDataFill[1]:=ACLONE(aLine)

     AINSERTAR(oTable:aDataFill,1,aLine)

     oTable:Gotop()
     oTable:Replace("SALDO"     ,nSaldoAnt)
     oTable:Replace("DEBE"      ,nDebe)
     oTable:Replace("HABER"     ,nHaber)
     oTable:Replace("MOB_MTOIDB",nMtoIdb)
     oTable:Replace("SALDOIDB"  ,nSaldoIdb)

  ENDIF

  oTable:Gotop()

  IF nSaldoAnt<>0   
//  nSaldoIdb:=nSaldoIdb-nMtoIdb
    oTable:DbSkip() // Viene con saldos Iniciales
// ? "AQUI ES SALDO INICIAL",nMtoIdb,"DEBE RESTAR nMtoIdb",nMtoIdb
// AADD(aVars,{nRegIdb,nMovIdb,nTotalIdb,oTable:Recno(),nSaldo,nSaldoIdb,"nRegIdb,nTotalIdb,oTable:Recno(),nSaldo,nSaldoIdb,nMovIdb "})

  ENDIF

  nSaldo   :=nSaldoAnt
  nTotalIdb:=nSaldoAnt // Aqui Duplica nSaldoIdb

  WHILE !oTable:Eof() 

    nSaldo   :=nSaldo   +oTable:DEBE-oTable:HABER

    //nTotalIdb:=nTotalIdb+oTable:MOB_MTOIDB
    nRegIdb    :=IF(nSaldoAnt<>0 .AND. oTable:Recno()=1,0,oTable:MOB_MTOIDB)
    nMovIdb    :=nMovIdb+nRegIdb

   AADD(aVars,{nRegIdb,nMovIdb,nTotalIdb,oTable:Recno(),nSaldo,nSaldoIdb,"nRegIdb,nTotalIdb,oTable:Recno(),nSaldo,nSaldoIdb,nMovIdb "})

    nSaldoIdb  :=nSaldo-nRegIdb // IF(nSaldoAnt<>0 .AND. oTable:Recno()=1,0,oTable:MOB_MTOIDB) //no se debe sumar nuevamente

// ? oTable:Recno(),nSaldoAnt,IF(nSaldoAnt<>0 .AND. oTable:Recno()=1,0,oTable:MOB_MTOIDB)

    oTable:Replace("SALDO"   ,nSaldo)
    oTable:Replace("SALDOIDB",nSaldoIdb)

    oTable:DbSkip()

  ENDDO

// ViewArray(aVars)

//? nRegIdb,nMovIdb,nTotalIdb,oTable:Recno(),nSaldo,nSaldoIdb,"nRegIdb,nTotalIdb,oTable:Recno(),nSaldo,nSaldoIdb,nMovIdb, ESTE ES EL TOTAL REAL "


  oTable:End()

  IF Empty(oTable:aDataFill)
     RETURN .F.
  ENDIF

  DEFAULT lConcil:=.T.

  ViewData(oTable:aDataFill,cCodBco,cCuenta,cTitle)

RETURN .T.
 
FUNCTION ViewData(aData,cCodBco,cCuenta,cTitle)
   LOCAL oBrw
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable,cNombre:=""
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL aTotal:=ATOTALES(aData)

   cNombre:=SQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",cCodBco))

   AEVAL(aData,{|a|nDebe:=nDebe+a[5],nHaber:=nHaber+a[6]})

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oVMobCon","DPBCOSLD.EDT")

   oVMobCon:Windows(0,0,aCoors[3]-200,aCoors[4]-10,.T.) // Maximizado

   oVMobCon:cWhereIni:=cWhereIni
   oVMobCon:cCodBco  :=cCodBco
   oVMobCon:cNombre  :=cNombre
   oVMobCon:cCuenta  :=cCuenta
   oVMobCon:dDesde   :=dDesde
   oVMobCon:dHasta   :=dHasta
   oVMobCon:cAno     :=cAno
   oVMobCon:dDesde   :=dDesde
   oVMobCon:dHasta   :=dHasta
   oVMobCon:cCodSuc  :=cCodSuc
   oVMobCon:lConcil  :=lConcil

   oVMobCon:nClrPane1:=oDp:nClrPane1
   oVMobCon:nClrPane2:=oDp:nClrPane2

   oVMobCon:SETSCRIPT() // "DPCTABCOCONVIEW")


   oVMobCon:oBrw:=TXBrowse():New( oVMobCon:oWnd) // oDlg )
   oVMobCon:oBrw:SetArray( aData, .F. )
   oVMobCon:oBrw:SetFont(oFont)
   oVMobCon:oBrw:lFooter := .T.
   oVMobCon:oBrw:lHScroll:= .T.
   oVMobCon:oBrw:nFreeze :=3
   oVMobCon:oBrw:nHeaderLines:= 2

   IF lConcil

     oVMobCon:nClrPane1:=15728607
     oVMobCon:nClrPane2:=15466455
 
     oVMobCon:nClrPaneT1:=12124063
     oVMobCon:nClrPaneT2:=12124063

     oVMobCon:nClrPaneM1:=13303754 
     oVMobCon:nClrPaneM2:=13303754 

  ELSE

     oVMobCon:nClrPane1:=14155775
     oVMobCon:nClrPane2:=9240575

     oVMobCon:nClrPaneT1:=10469119 // 33023
     oVMobCon:nClrPaneT2:=10469119 // 33023

     oVMobCon:nClrPaneM1:=12703487 //12046079 // 8235263
     oVMobCon:nClrPaneM2:=12703487 // 12046079 // 8235263

   ENDIF

   oVMobCon:nClrPane1:=oDp:nClrPane1
   oVMobCon:nClrPane2:=oDp:nClrPane2

   AEVAL(oVMobCon:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oVMobCon:oBrw:aCols[1]:cHeader      :="Tipo"
   oVMobCon:oBrw:aCols[1]:nWidth       :=040
   oVMobCon:oBrw:aCols[1]:cFooter      :=LSTR(LEN(aData)-1)

   oVMobCon:oBrw:aCols[2]:cHeader      :="Número"
   oVMobCon:oBrw:aCols[2]:nWidth       :=080
   oVMobCon:oBrw:aCols[2]:bLClickHeader := {|r,c,f,o| SortArray( o, oVMobCon:oBrw:aArrayData ) }

   oVMobCon:oBrw:aCols[3]:cHeader      :="Fecha"+CRLF+"Conciliado"
   oVMobCon:oBrw:aCols[3]:nWidth       :=70
   oVMobCon:oBrw:aCols[3]:bLClickHeader := {|r,c,f,o| SortArray( o, oVMobCon:oBrw:aArrayData ) }

   oVMobCon:oBrw:aCols[4]:cHeader      :="Fecha"+CRLF+"Registro"
   oVMobCon:oBrw:aCols[4]:nWidth       :=70
   oVMobCon:oBrw:aCols[4]:bLClickHeader := {|r,c,f,o| SortArray( o, oVMobCon:oBrw:aArrayData ) }


   oVMobCon:oBrw:aCols[5]:cHeader      :="Monto"+CRLF+"Debe"
   oVMobCon:oBrw:aCols[5]:nWidth       :=120
   oVMobCon:oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[5]:nFootStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[5]:bStrData     :={|nMonto|nMonto:=oVMobCon:oBrw:aArrayData[oVMobCon:oBrw:nArrayAt,5],;
                                                 IF(nMonto<=0,"",TRAN(nMonto,"99,999,999,999.99"))}


   oVMobCon:oBrw:aCols[5]:cFooter      :=TRAN(aTotal[5],"99,999,999,999.99")
//TRAN(nDebe,"99,999,999,999.99")

   oVMobCon:oBrw:aCols[5]:bClrStd      := {|oBrw,nClrText|oBrw:=oVMobCon:oBrw,;
                                           nClrText:=CLR_HBLUE,;
                                         {nClrText,iif( oBrw:nArrayAt%2=0, oVMobCon:nClrPane1, oVMobCon:nClrPane2  ) } }

   oVMobCon:oBrw:aCols[6]:cHeader      :="Haber"
   oVMobCon:oBrw:aCols[6]:nWidth       :=120
   oVMobCon:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[6]:bStrData     :={|nMonto|nMonto:=oVMobCon:oBrw:aArrayData[oVMobCon:oBrw:nArrayAt,6],;
                                                 IF(nMonto<=0,"",TRAN(nMonto,"99,999,999,999.99"))}

   oVMobCon:oBrw:aCols[6]:cFooter      :=TRAN(aTotal[6],"999,999,999,999.99")
// TRAN(nHaber,"99,999,999,999.99")
   oVMobCon:oBrw:aCols[6]:bClrStd      := {|oBrw,nClrText|oBrw:=oVMobCon:oBrw,;
                                           nClrText:=CLR_HRED,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oVMobCon:nClrPane1, oVMobCon:nClrPane2  ) } }

   oVMobCon:oBrw:aCols[7]:cHeader      :="Saldo"+CRLF+"sin ITF"
   oVMobCon:oBrw:aCols[7]:nWidth       :=140
   oVMobCon:oBrw:aCols[7]:nDataStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[7]:nHeadStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[7]:nFootStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[7]:bStrData     :={|oBrw,nClrText|oBrw:=oVMobCon:oBrw,;
                                                         TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],"99,999,999,999.99")}

   oVMobCon:oBrw:aCols[7]:bClrStd      := {|oBrw,nClrText|oBrw:=oVMobCon:oBrw,;
                                           nClrText:=IF(oBrw:aArrayData[oBrw:nArrayAt,7]<0,157,CLR_BLUE),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oVMobCon:nClrPane1, oVMobCon:nClrPane2  ) } }


   oVMobCon:oBrw:aCols[7]:cFooter      :=TRAN(aTotal[5]-aTotal[6],"999,999,999,999.99")
// TRAN(nSaldo,"99,999,999,999.99")


   oVMobCon:oBrw:aCols[8]:cHeader      :="%ITF"
   oVMobCon:oBrw:aCols[8]:nWidth       :=50
   oVMobCon:oBrw:aCols[8]:nDataStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[8]:nHeadStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[8]:nFootStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[8]:bStrData     :={|nMonto|nMonto:=oVMobCon:oBrw:aArrayData[oVMobCon:oBrw:nArrayAt,8],;
                                                   TRAN(nMonto,"999.99")}

   oVMobCon:oBrw:aCols[9]:cHeader      :="Monto"+CRLF+"ITF"
   oVMobCon:oBrw:aCols[9]:nWidth       :=100
   oVMobCon:oBrw:aCols[9]:nDataStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[9]:nHeadStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[9]:nFootStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[9]:bStrData     :={|nMonto|nMonto:=oVMobCon:oBrw:aArrayData[oVMobCon:oBrw:nArrayAt,9],;
                                                   TRAN(nMonto,"999,999,999,999.99")}
   oVMobCon:oBrw:aCols[9]:bClrStd      := {|oBrw,nClrText|oBrw:=oVMobCon:oBrw,;
                                           nClrText:=CLR_HRED,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oVMobCon:nClrPane1, oVMobCon:nClrPane2  ) } }



   oVMobCon:oBrw:aCols[9]:cFooter      :=TRAN(aTotal[9],"9,999,999,999,999.99")


   oVMobCon:oBrw:aCols[10]:cHeader      :="Saldo"+CRLF+"con ITF"
   oVMobCon:oBrw:aCols[10]:nWidth       :=140
   oVMobCon:oBrw:aCols[10]:nDataStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[10]:nHeadStrAlign:= AL_RIGHT
   oVMobCon:oBrw:aCols[10]:nFootStrAlign:= AL_RIGHT

   oVMobCon:oBrw:aCols[10]:bStrData     :={|nMonto|nMonto:=oVMobCon:oBrw:aArrayData[oVMobCon:oBrw:nArrayAt,10],;
                                                   TRAN(nMonto,"9,99,999,999,999.99")}

   oVMobCon:oBrw:aCols[10]:bClrStd      := {|oBrw,nClrText|oBrw:=oVMobCon:oBrw,;
                                             nClrText:=IF(oBrw:aArrayData[oBrw:nArrayAt,10]<0,157,CLR_BLUE),;
                                           {nClrText,iif( oBrw:nArrayAt%2=0, oVMobCon:nClrPane1, oVMobCon:nClrPane2  ) } }


   oVMobCon:oBrw:aCols[10]:cFooter      :=TRAN(nSaldoIdb,"9,999,999,999,999.99")
//(aTotal[5]-aTotal[6])-aTotal[9],"9,999,999,999,999.99")


   oVMobCon:oBrw:aCols[11]:cHeader      :="Org."
   oVMobCon:oBrw:aCols[11]:nWidth       :=040

   oVMobCon:oBrw:aCols[12]:cHeader      :="Num."+CRLF+"Tran."
   oVMobCon:oBrw:aCols[12]:nWidth       :=70

   oVMobCon:oBrw:aCols[13]:cHeader      :="Descripción"
   oVMobCon:oBrw:aCols[13]:nWidth       :=400

   oVMobCon:oBrw:aCols[14]:cHeader      :="Doc."+CRLF+"Asociado"
   oVMobCon:oBrw:aCols[14]:nWidth       :=080
   oVMobCon:oBrw:aCols[14]:bLClickHeader := {|r,c,f,o| SortArray( o, oVMobCon:oBrw:aArrayData ) }

   oVMobCon:oBrw:aCols[15]:cHeader      :="Cbte"+CRLF+"Contable"
   oVMobCon:oBrw:aCols[15]:nWidth       :=70
   oVMobCon:oBrw:aCols[15]:bLClickHeader := {|r,c,f,o| SortArray( o, oVMobCon:oBrw:aArrayData ) }

   oVMobCon:oBrw:aCols[16]:cHeader      :="ID"+CRLF+"US"
   oVMobCon:oBrw:aCols[16]:nWidth       :=50
   oVMobCon:oBrw:aCols[16]:bLClickHeader := {|r,c,f,o| SortArray( o, oVMobCon:oBrw:aArrayData ) }




   oVMobCon:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oVMobCon:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oVMobCon:nClrPane1, oVMobCon:nClrPane2 ) } }

   oVMobCon:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oVMobCon:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oVMobCon:oBrw:CreateFromCode()
    oVMobCon:bValid   :={|| EJECUTAR("BRWSAVEPAR",oVMobCon)}
    oVMobCon:BRWRESTOREPAR()

   oVMobCon:oBrw:bLDblClick:={|oBrw|oVMobCon:RUNCLICK() }



   oVMobCon:oWnd:oClient := oVMobCon:oBrw

   oVMobCon:Activate({||oVMobCon:ViewDatBar(oVMobCon)})

RETURN .T.


/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oVMobCon)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oVMobCon:oDlg

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD 

   oVMobCon:oFontBtn   :=oFont    
   oVMobCon:nClrPaneBar:=oDp:nGris
   oVMobCon:oBrw:oLbx  :=oVMobCon

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP",NIL,"BITMAPS\VIEWG.BMP";
          WHEN ISRELEASE("19.01");
            TOP PROMPT "Origen"; 
              ACTION  oVMobCon:VERDETALLE()

   oBtn:cToolTip:="Consultar Detalles"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
              ACTION  (oDp:oRep:=REPORTE(IF(oVMobCon:lConcil,"EDOCTABCOC","EDOCTABCOI")),;
                  oDp:oRep:SetRango(1,oVMobCon:cCodBco,oVMobCon:cCodBco),;
                  oDp:oRep:SetRango(2,oVMobCon:cCuenta,oVMobCon:cCuenta),;
                  IIF(!Empty(oVMobCon:dDesde) ,  oDp:oRep:SetRango(3,oVMobCon:dDesde ,oVMobCon:dHasta ) , NIL ))


   oBtn:cToolTip:="Emitir Estados de Cuenta"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oVMobCon:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oVMobCon:oBrw);
          WHEN LEN(oVMobCon:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oVMobCon:oBrw,oVMobCon:cTitle,oVMobCon:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (EJECUTAR("BRWTOHTML",oVMobCon:oBrw))

   oBtn:cToolTip:="Generar Archivo html"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oVMobCon:oBrw:GoTop(),oVMobCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oVMobCon:oBrw:PageDown(),oVMobCon:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oVMobCon:oBrw:PageUp(),oVMobCon:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oVMobCon:oBrw:GoBottom(),oVMobCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oVMobCon:Close()


  oVMobCon:oBrw:SetColor(0,oVMobCon:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBar:SetSize(NIL,110,.T.)

  DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 65,15 SAY " Banco  " OF oBar BORDER SIZE 70,18 COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT PIXEL
  @ 85,15 SAY " Nombre " OF oBar BORDER SIZE 70,18 COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT PIXEL

  @ 65,88 SAY " "+oVMobCon:cCodBco+" Cuenta: "+oVMobCon:cCuenta OF oBar BORDER SIZE 375,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont PIXEL
  @ 85,88 SAY " "+oVMobCon:cNombre OF oBar BORDER SIZE 375,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont PIXEL

 
RETURN .T.

/*
// Llamarse a si mismo
*/

FUNCTION RUNCLICK()

  EJECUTAR("DPCTABCOCON2VIEW",oVMobCon)

RETURN .T.

FUNCTION VERDETALLE()
  LOCAL aLine:=oVMobCon:oBrw:aArrayData[oVMobCon:oBrw:nArrayAt],cWhere
  LOCAL cTipo:=aLine[01]
  LOCAL cOrg :=aLine[11]
  LOCAL cDoc :=aLine[14]

  IF cOrg="REC"
     cWhere:="REC_NUMERO"+GetWhere("=",cDoc)
     RETURN EJECUTAR("DPRECIBOSCLIX",NIL,NIL,NIL,NIL,cWhere)
  ENDIF

  IF cOrg="PAG"
     cWhere:="PAG_NUMERO"+GetWhere("=",cDoc)
     RETURN EJECUTAR("DPCBTEPAGOX",NIL,NIL,NIL,NIL,cWhere)
  ENDIF

  IF cOrg="DEP"
     cWhere:="MOB_DOCUME"+GetWhere("=",aLine[2])
     RETURN EJECUTAR("DEPOSITO",NIL,cWhere)
  ENDIF

 IF cOrg="BCO"
    RETURN EJECUTAR("DPCTABANCOMOV",cTipo,oVMobCon:cCodBco,oVMobCon:cCuenta,aLine[2],.T.)
 ENDIF

 IF cOrg="TRA"

    cWhere:="MOB_CODBCO"+GetWhere("=",oVMobCon:cCodBco)+" AND "+;
            "MOB_DOCUME"+GetWhere("=",aLine[2])

    RETURN EJECUTAR("DPTRANSFBCO",oVMobCon:cCodBco,cWhere)

 ENDIF

RETURN .T.
// EOF



 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oVMobCon)
// EOF
