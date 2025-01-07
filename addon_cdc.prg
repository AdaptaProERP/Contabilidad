// Programa   : ADDON_CDC
// Fecha/Hora : 18/09/2010 17:22:34
// Propósito  : Menú Contabilidad de Transcripción
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cCodSuc,cRif,cCenCos,cCodCaj)
   LOCAL cNombre:="",cSql,I,nGroup
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp,oCol
   LOCAL oBtn,nGroup,bAction,aBtn:={}
   LOCAL oData    :=DATACONFIG("CDCPERIODO","ALL")
   LOCAL dDesde   :=oDp:dFchInicio // FCHINIMES(oDp:dFecha)
   LOCAL dHasta   :=oDp:dFchCierre // FCHFINMES(oDp:dFecha)
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL cFileMem :="USER\ADDON_CDC.MEM",V_nPeriodo:=10,nPeriodo,aFechas:={},aTotal:={}
   LOCAL V_dDesde :=CTOD("")
   LOCAL V_dHasta :=CTOD("")
   LOCAL oDb      :=OpenOdbc(oDp:cDsnData)
   LOCAL aData    :={} 
   LOCAL aDataFis :={} 
   LOCAL dFecha   :=oDp:dFecha,cServer,cWhere
   LOCAL aTotal   :=ATOTALES(aData)

   DEFAULT oDp:lAplNomina:=.F. 

   EJECUTAR("DPIVATAB_CHK")
   SQLDELETE("DPRIF","RIF_ID"+GetWhere("=",""))

   IF Empty(oDp:cRif)
      oDp:cRif:=ALLTRIM(SQLGET("DPEMPRESA","EMP_RIF","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod)))
   ENDIF

   IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPLIBCOMPRASDET","LBC_ORIGEN",.F.) .OR.;
      !EJECUTAR("ISFIELDMYSQL",oDb,"DPLIBCOMPRASDET","LBC_CREFIS",.F.) 

      EJECUTAR("ADDFIELDS_2312",NIL,.T.)
      EJECUTAR("ADDFIELDS_2401",NIL,.T.)
   ENDIF

   IF !EJECUTAR("ISFIELDMYSQL",oDp:cDsnData,"DPDOCPROPROG","PLP_FCHDEC")
      EJECUTAR("ADDFIELDS_2209",NIL,.T.)
   ENDIF

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"DPLIBCOMPRASDET",.F.)
      EJECUTAR("DPLIBCOMPRACREA")
   ENDIF

   IF COUNT("DPDOCPROPROG",GetWhereAnd("PLP_FECHA",oDp:dFchInicio,oDp:dFchCierre)+" AND PLP_TIPDOC"+GetWhere("=","F30"))=0 
      EJECUTAR("CREARCALFIS")
   ENDIF

   IF COUNT("DPDOCPROPROG","PLP_FCHDEC"+GetWhere("=",CTOD(""))+" OR PLP_FCHDEC IS NULL")>0
      EJECUTAR("DPLIBCOMSETFECHA")
   ENDIF

   IF COUNT("VIEW_DPCALF30")=0
      EJECUTAR("SETVISTAS","<Multiple>","DPCALF30",NIL,.t.,NIL,NIL)
   ENDIF

   DEFAULT cCodigo   :="CDC",;
           oDp:aCoors:=GetCoors( GetDesktopWindow() ),;
           cRif      :=oDp:cRif,;
           cCodSuc   :=oDp:cSucursal

   oDp:lCondominio:=.F.

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=oDp:nEjercicio,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")

   aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

   IF !Empty(aFechas)
     dDesde :=aFechas[1]
     dHasta :=aFechas[2]
   ENDIF

   oData:End(.F.)

   cWhere:=NIL

   aDataFis:=LEERDATAFIS(HACERWHEREFIS(dDesde,dHasta,cWhere),NIL,cServer)

   aData   :=EJECUTAR("CONTAB_DEBERES",cCodSuc,oDp:dFechaIni,dFecha)
   aTotal  :=ATOTALES(aDataFis)

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-11 BOLD
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-11 BOLD

   DpMdi("Menú: Asistente Contable","oCDCADD","")

   oCDCADD:cCodigo   :=cCodigo
   oCDCADD:cCodSuc   :=cCodSuc
   oCDCADD:cNombre   :=cNombre
   oCDCADD:lSalir    :=.F.
   oCDCADD:nHeightD  :=45
   oCDCADD:lMsgBar   :=.F.
   oCDCADD:oGrp      :=NIL
   oCDCADD:ADD_AUTEJE:=SQLGET("DPADDON"  ,"ADD_AUTEJE","ADD_CODIGO"+GetWhere("=","CDC"))
   oCDCADD:lEnvAut   :=SQLGET("DPEMPRESA","EMP_ENVAUT","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))
   oCDCADD:dDesde    :=dDesde
   oCDCADD:dHasta    :=dHasta
   oCDCADD:cPeriodo  :=aPeriodos[nPeriodo]
   oCDCADD:lWhen     :=.T.
   oCDCADD:cRif      :=ALLTRIM(cRif)
   oCDCADD:cDir      :="CDC_"+cRif
   oCDCADD:cFileZip  :=""
   oCDCADD:cServer   :=""
   oCDCADD:nPeriodo  :=nPeriodo
   oCDCADD:cCenCos   :=cCenCos
   oCDCADD:cCodCaj   :=cCodCaj
   oCDCADD:SetFunction("MDISETPROCE")
   oCDCADD:cWhereQry :=NIL

   oCDCADD:nAltoBrw  :=160 // 100+100+08
   oCDCADD:nAnchoSpl1:=120+40


   SetScript("ADDON_CDC")

   AADD(aBtn,{"Documentos de Compras"    ,"COMPRAS.BMP"    ,"COMPRAS"}) 
   AADD(aBtn,{"Documentos de Ventas"     ,"VENTASCXC.BMP"  ,"VENTAS" }) 
   AADD(aBtn,{"Importar Nómina Quincenal","TRABAJADOR.BMP" ,"NOMQUINCENAL" }) 

   AADD(aBtn,{"Registrar Presupuesto por Cuenta Contable","objetivos.BMP"    ,"CNDPRESUPUESTO" })

   oCDCADD:Windows(0,0,oDp:aCoors[3]-160,oDp:aCoors[4]-10,.T.)  

  @ 48+40-10+20+15, -1 OUTLOOK oCDCADD:oOut ;
     SIZE (150+250)-40, oCDCADD:oWnd:nHeight()-140;
     PIXEL ;
     FONT oFont ;
     OF oCDCADD:oWnd;
     COLOR CLR_BLACK,oDp:nGris

   DEFINE GROUP OF OUTLOOK oCDCADD:oOut PROMPT "&Opciones "

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oCDCADD:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oCDCADD:oOut:aGroup)
      oBtn:=ATAIL(oCDCADD:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oCDCADD:INVACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oCDCADD:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   DEFINE GROUP OF OUTLOOK oCDCADD:oOut PROMPT "&Transferencia mediante la Oficina Virtual "

   aBtn:={}
   AADD(aBtn,{"Subir Transacciones "     ,"UPLOAD.BMP"    ,"UPLOAD_OV"   }) 
   AADD(aBtn,{"Descargar Transacciones"  ,"DOWNLOAD.BMP"  ,"DOWNLOAD_OV" }) 

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oCDCADD:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oCDCADD:oOut:aGroup)
      oBtn:=ATAIL(oCDCADD:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oCDCADD:INVACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oCDCADD:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   DEFINE GROUP OF OUTLOOK oCDCADD:oOut PROMPT "&Transferencia mediante otros Servidores "

   aBtn:={}
   AADD(aBtn,{"Subir Transacciones "     ,"UPLOAD.BMP"    ,"UPLOAD_OSRV"   }) 
   AADD(aBtn,{"Descargar Transacciones"  ,"DOWNLOAD.BMP"  ,"DOWNLOAD_OSRV" }) 

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oCDCADD:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oCDCADD:oOut:aGroup)
      oBtn:=ATAIL(oCDCADD:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oCDCADD:INVACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oCDCADD:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I


   oCDCADD:oBrw2:=TXBrowse():New(oCDCADD:oWnd)
   oCDCADD:oBrw2:SetArray( aData, .F. )

   oCDCADD:oBrw2:oFont       := oFont
   oCDCADD:oBrw2:lFooter     := .T.
   oCDCADD:oBrw2:lHScroll    := .F.
   oCDCADD:oBrw2:nHeaderLines:= 2
   oCDCADD:oBrw2:nDataLines  := 2
   oCDCADD:oBrw2:lFooter     :=.F.


   oCol:=oCDCADD:oBrw2:aCols[1]   
   oCol:cHeader      :="Indicador de Deberes por Realizar"
   oCol:nWidth       :=260+200+50

   oCol:=oCDCADD:oBrw2:aCols[2]
   oCol:cHeader      := "Proc."+CRLF+"Activo"
   oCol:nWidth       := 40

   oCol:AddBmpFile("BITMAPS\checkverde.bmp")
   oCol:AddBmpFile("BITMAPS\checkrojo.bmp")

   oCol:bBmpData    := { ||oBrw:=oCDCADD:oBrw2,IIF(oBrw:aArrayData[oBrw:nArrayAt,2],1,2) }
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bStrData    :={||""}

   oCol:=oCDCADD:oBrw2:aCols[3]   
   oCol:cHeader      :="Fecha"+CRLF+"Actlz."
   oCol:nWidth       :=55
   oCol:bStrData     :={|dFecha|dFecha:=oCDCADD:oBrw2:aArrayData[oCDCADD:oBrw2:nArrayAt,3],F82(dFecha)}

   oCol:=oCDCADD:oBrw2:aCols[4]
   oCol:cHeader      :="Reg x."+CRLF+"Procesar"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oCDCADD:oBrw2:aArrayData ) } 
   oCol:nWidth       := 60-5
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|nMonto|nMonto:= oCDCADD:oBrw2:aArrayData[oCDCADD:oBrw2:nArrayAt,4],FDP(nMonto,'99,999')}

   oCol:=oCDCADD:oBrw2:aCols[5]
   oCol:cHeader      := "Cond"+CRLF+"Activo"
   oCol:nWidth       := 40

   oCol:AddBmpFile("BITMAPS\checkverde.bmp")
   oCol:AddBmpFile("BITMAPS\checkrojo.bmp")

   oCol:bBmpData    := { ||oBrw:=oCDCADD:oBrw2,IIF(oBrw:aArrayData[oBrw:nArrayAt,5],1,2) }
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bStrData    :={||""}

   oCDCADD:oBrw2:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCDCADD:oBrw2,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                         nClrText:=oBrw:aArrayData[oBrw:nArrayAt,8],;
                                        {nClrText,iif( oBrw:nArrayAt%2=0, 16774120, 16769217) } }

   oCDCADD:oBrw2:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCDCADD:oBrw2:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCDCADD:oBrw2:bLDblClick:={|oBrw|oCDCADD:RUNCLICK() }

   oCDCADD:oBrw2:DelCol(6)
   oCDCADD:oBrw2:DelCol(6)
   oCDCADD:oBrw2:DelCol(6)
   
   oCDCADD:oBrw2:CreateFromCode()
   oCDCADD:oBrw2:Move(0,205+oCDCADD:nAnchoSpl1,.T.)
   oCDCADD:oBrw2:SetSize(300,200+oCDCADD:nAltoBrw)


   oCDCADD:oBrw:=TXBrowse():New(oCDCADD:oWnd)
   oCDCADD:oBrw:SetArray( aDataFis, .F. )

   oCDCADD:dFchIni  :=CTOD("")
   oCDCADD:dFchFin  :=CTOD("")

   oCDCADD:oBrw:SetFont(oFont)

   oCDCADD:oBrw:lFooter     := .T.
   oCDCADD:oBrw:lHScroll    := .T.
   oCDCADD:oBrw:nHeaderLines:= 2
   oCDCADD:oBrw:nDataLines  := 1
   oCDCADD:oBrw:nFooterLines:= 1

   oCDCADD:aData            :=ACLONE(aData)
   oCDCADD:nClrText :=0
   oCDCADD:nClrPane1:=16774120
   oCDCADD:nClrPane2:=16771797

   AEVAL(oCDCADD:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oCDCADD:oBrw:aCols[1]
   oCol:cHeader      :='Fecha'+CRLF+'Actividad'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
   oCol:nWidth       := 74

   oCol:=oCDCADD:oBrw:aCols[2]
   oCol:cHeader      :='Mes'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
   oCol:nWidth       := 32

   oCol:=oCDCADD:oBrw:aCols[3]
   oCol:cHeader      :='Día'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
   oCol:nWidth       := 32

   oCol:=oCDCADD:oBrw:aCols[4]
   oCol:cHeader      :='Tipo'+CRLF+'Doc.'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
   oCol:nWidth       := 35

  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oCDCADD:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oCDCADD:nClrPane1, oCDCADD:nClrPane2 ) } }


  oCol:=oCDCADD:oBrw:aCols[5]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 170


  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oCDCADD:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oCDCADD:nClrPane1, oCDCADD:nClrPane2 ) } }

  oCol:=oCDCADD:oBrw:aCols[6]
  oCol:cHeader      :='Referencia'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oCDCADD:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oCDCADD:nClrPane1, oCDCADD:nClrPane2 ) } }

  oCol:=oCDCADD:oBrw:aCols[7]
  oCol:cHeader      :='Fecha'+CRLF+'Registro'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oCDCADD:oBrw:aCols[8]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cFooter      :=FDP(aTotal[8],'9,999,999,999,999.99')

  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,8],;
                              oCol   := oCDCADD:oBrw:aCols[8],;
                              FDP(nMonto,oCol:cEditPicture)}


  oCol:=oCDCADD:oBrw:aCols[9]
  oCol:cHeader      :='Dias'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,9],FDP(nMonto,'9999999')}

  oCol:=oCDCADD:oBrw:aCols[10]
  oCol:cHeader      :='Estatus'+CRLF+'Registro'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       :=90

  oCol:=oCDCADD:oBrw:aCols[11]
  oCol:cHeader      :='Fecha'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oCDCADD:oBrw:aCols[12]
  oCol:cHeader      :='Dias'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,12],FDP(nMonto,'9999')}

  oCol:=oCDCADD:oBrw:aCols[13]
  oCol:cHeader      :='Estatus'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 65

  oCol:=oCDCADD:oBrw:aCols[14]
  oCol:cHeader      :='Cbte.'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 60

  oCol:=oCDCADD:oBrw:aCols[15]
  oCol:cHeader      :='Cbte.'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCDCADD:oBrw:aCols[16]
  oCol:cHeader      :='Dias'+CRLF+'x Transc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,16],FDP(nMonto,'9999')}


  oCDCADD:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))


  oCol:=oCDCADD:oBrw:aCols[17]
  oCol:cHeader      :='Color'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCDCADD:oBrw:aCols[18]
  oCol:cHeader      :='Código'+CRLF+'CxP'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCDCADD:oBrw:aCols[19]
  oCol:cHeader      :='Número'+CRLF+'Documento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oCDCADD:oBrw:aCols[20]
  oCol:cHeader      :='Código'+CRLF+'Planif.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 65

  oCol:=oCDCADD:oBrw:aCols[21]
  oCol:cHeader      :='Número'+CRLF+'Planificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 240


  oCol:=oCDCADD:oBrw:aCols[22]
  oCol:cHeader      :='Institución'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 300


  oCol:=oCDCADD:oBrw:aCols[23]
  oCol:cHeader      :='Color'+CRLF+'Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,23],FDP(nMonto,'9999999')}

  oCol:=oCDCADD:oBrw:aCols[24]
  oCol:cHeader      :='Monto'+CRLF+'Calculado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,24],;
                              oCol   := oCDCADD:oBrw:aCols[24],;
                              FDP(nMonto,oCol:cEditPicture)}


  oCol:=oCDCADD:oBrw:aCols[25]
  oCol:cHeader      :='Valor'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :=oDp:cPictValCam
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,25],;
                              oCol   := oCDCADD:oBrw:aCols[25],;
                              FDP(nMonto,oCol:cEditPicture)}

  oCol:=oCDCADD:oBrw:aCols[26]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCDCADD:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt,26],;
                              oCol   := oCDCADD:oBrw:aCols[26],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[26],'9,999,999,999,999.99')
 

  oCDCADD:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCDCADD:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                         {nClrText,iif( oBrw:nArrayAt%2=0, oCDCADD:nClrPane1, oCDCADD:nClrPane2 ) } }


  oCDCADD:oBrw:bClrFooter     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oCDCADD:oBrw:bClrHeader     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oCDCADD:oBrw:bLDblClick:={|oBrw| oCDCADD:RUNCLICK3() }

  oCDCADD:oBrw:bChange:={||oCDCADD:BRWCHANGE()}

  oCDCADD:oBrw:CreateFromCode()

  oCDCADD:oBrw:aCols[17]:lHide:=.T. // DelCol(17)

  oCDCADD:oBrw:CreateFromCode()
  oCDCADD:oBrw:Move(205+oCDCADD:nAltoBrw,205+oCDCADD:nAnchoSpl1,.T.)
  oCDCADD:oBrw:SetSize(300,150,.T.)

 @ 200+oCDCADD:nAltoBrw,205+oCDCADD:nAnchoSpl1 SPLITTER oCDCADD:oHSplit ;
             HORIZONTAL ;
             PREVIOUS CONTROLS oCDCADD:oBrw2 ;
             HINDS CONTROLS oCDCADD:oBrw ;
             TOP MARGIN 80 ;
             BOTTOM MARGIN 80 ;
             SIZE 300, 4  PIXEL ;
             OF oCDCADD:oWnd ;
             _3DLOOK

  @ 0,200+oCDCADD:nAnchoSpl1   SPLITTER oCDCADD:oVSplit ;
            VERTICAL ;
            PREVIOUS CONTROLS oCDCADD:oOut ;
            HINDS CONTROLS oCDCADD:oBrw2, oCDCADD:oHSplit, oCDCADD:oBrw ;
            LEFT MARGIN 80 ;
            RIGHT MARGIN 80 ;
            SIZE 4, 355  PIXEL ;
            OF oCDCADD:oWnd ;
            _3DLOOK

   oCDCADD:Activate("oCDCADD:FRMINIT()") // ,,"oCDCADD:oSpl:AdjRight()")
 
   EJECUTAR("DPSUBMENUCREAREG",oCDCADD,NIL,"A")

   IF COUNT("DPCTA")=0
      MsgMemo("Necesario Importar Plan de Cuentas")
      EJECUTAR("DPCTAIMPORT")
   ENDIF

   oCDCADD:bGotFocus:={|| oCDCADD:BTNSETFONT() }

RETURN

FUNCTION BTNSETFONT()
  LOCAL oFont

  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -10 BOLD

  oCDCADD:oBar:SetFont(oFont)

// oDp:oFrameDp:SetText("AQUI "+TIME())

RETURN .T.

FUNCTION FRMINIT()
  LOCAL oCursor,oBar,oBtn,oFont,nCol:=12,nLin:=0,oFontB,oFontF
  LOCAL nLin:=0

  DEFINE BUTTONBAR oBar SIZE 44+25,44+20 OF oCDCADD:oWnd 3D CURSOR oCursor

  oCDCADD:oBar:=oBar

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -09 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -10 BOLD

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONFIGURA.BMP";
          TOP PROMPT "Configurar"; 
          MENU oCDCADD:MENU_CNF("MENU_CNFRUN","DOS");
          ACTION EJECUTAR("DPCONFIG")

  oBtn:cToolTip:="Configuración"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\contabilidad.BMP";
          MENU oCDCADD:MENU_CTA("MENU_CTARUN","UNO");
          TOP PROMPT "Cuentas"; 
          ACTION DPLBX("NMTRABAJADOR.LBX") 

  oBtn:cToolTip:="Contabilidad"

/*
  DEFINE BUTTON oBtn;
        OF oBar;
        NOBORDER;
        FONT oFont;
        TOP PROMPT "Integración"; 
        FILENAME oDp:cPathBitMaps+"codintegracion.bmp";
        ACTION EJECUTAR("BRTIPDOCPROCTA","TDC_LBCCDC=1")

  oBtn:cToolTip:="Integración"
*/


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\seniat.BMP";
          MENU oCDCADD:MENU_TRIB("MENU_TRIBRUN","UNO");
          TOP PROMPT "Tributos"; 
          ACTION EJECUTAR("BRCALFISDET")

  oBtn:cToolTip:="Calendario Fiscal"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\trabajador.BMP";
          MENU oCDCADD:MENU_NOM("MENU_NOMRUN","UNO");
          TOP PROMPT "Trabajador"; 
          ACTION DPLBX("NMTRABAJADOR.LBX") 

  oBtn:cToolTip:="Trabajadores"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Salir"; 
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCDCADD:End()

  oBtn:cToolTip:="Cerrar Formulario"

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0, -11  BOLD

  oBar:SetSize(NIL,70,.T.)

  DEFINE FONT oFontF  NAME "Tahoma"   SIZE 0, -10 BOLD

  nLin:=-15 // 45
  nCol:=20
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin+20, nCol COMBOBOX oCDCADD:oPeriodo  VAR oCDCADD:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFontF;
                ON CHANGE oCDCADD:LEEFECHAS();
                WHEN oCDCADD:lWhen 


  ComboIni(oCDCADD:oPeriodo )

  @ nLin+20, nCol+103 BUTTON oCDCADD:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFontF;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCDCADD:oPeriodo:nAt,oCDCADD:oDesde,oCDCADD:oHasta,-1),;
                         EVAL(oCDCADD:oBtn:bAction));
                WHEN oCDCADD:lWhen 


  @ nLin+20, nCol+130 BUTTON oCDCADD:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFontF;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCDCADD:oPeriodo:nAt,oCDCADD:oDesde,oCDCADD:oHasta,+1),;
                         EVAL(oCDCADD:oBtn:bAction));
                 WHEN oCDCADD:lWhen 


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

  @ nLin+20,nCol+170-8 BMPGET oCDCADD:oDesde  VAR oCDCADD:dDesde;
                  PICTURE "99/99/9999";
                  PIXEL;
                  NAME "BITMAPS\Calendar.bmp";
                  ACTION LbxDate(oCDCADD:oDesde ,oCDCADD:dDesde);
                  SIZE 76,24;
                  OF   oBar;
                  WHEN oCDCADD:oPeriodo:nAt=LEN(oCDCADD:oPeriodo:aItems) .AND. oCDCADD:lWhen ;
                  FONT oFontF

   oCDCADD:oDesde:cToolTip:="F6: Calendario"

  @ nLin+20, nCol+252+5 BMPGET oCDCADD:oHasta  VAR oCDCADD:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCDCADD:oHasta,oCDCADD:dHasta);
                SIZE 80,23;
                WHEN oCDCADD:oPeriodo:nAt=LEN(oCDCADD:oPeriodo:aItems) .AND. oCDCADD:lWhen ;
                OF oBar;
                FONT oFontF

   oCDCADD:oHasta:cToolTip:="F6: Calendario"

   @ nLin+20,nCol+335+15 BUTTON oCDCADD:oBtn PROMPT " > " SIZE 27,24;
               FONT oFontF;
               OF oBar;
               PIXEL;
               WHEN oCDCADD:oPeriodo:nAt=LEN(oCDCADD:oPeriodo:aItems);
               ACTION oCDCADD:HACERWHERE(oCDCADD:dDesde,oCDCADD:dHasta,oCDCADD:cWhere,.T.);
               WHEN oCDCADD:lWhen

  oBar:Refresh(.T.)

  @ nLin+50,nCol  CHECKBOX oCDCADD:oADD_AUTEJE VAR oCDCADD:ADD_AUTEJE  PROMPT "Auto-Ejecución";
                  WHEN  (AccessField("DPADDON","ADD_AUTEJE",1));
                  FONT oFontB;
                  SIZE 140,20 OF oBar;
                  ON CHANGE EJECUTAR("ADDONUPDATE","ADD_AUTEJE",oCDCADD:ADD_AUTEJE,"CDC") PIXEL

  oCDCADD:oADD_AUTEJE:cMsg    :="Auto-Ejecución cuando se Inicia el Sistema"
  oCDCADD:oADD_AUTEJE:cToolTip:="Auto-Ejecución cuando se Inicia el Sistema"

  // 17/11/2024

  oCDCADD:oWnd:bResized:={||( oCDCADD:oVSplit:AdjLeft(), ;
                              oCDCADD:oHSplit:AdjRight())}

  Eval( oCDCADD:oWnd:bResized )

  oCDCADD:oBrw2:SetColor(0,oCDCADD:nClrPane1)

  BMPGETBTN(oBar)
                       
RETURN .T.

FUNCTION INVACTION(cAction,cTexto,lUpload)
   LOCAL cTitle:=NIL,cWhere:=NIL,aFiles:={},cFileZip,cFileUp,lOk,cDir,nT1:=SECONDS()

  IF cAction="COMPRAS" 
     EJECUTAR("BRLIBCOMFCH",cWhere,oCDCADD:cCodSuc,oCDCADD:nPeriodo,oCDCADD:dDesde,oCDCADD:dHasta,cTitle,oCDCADD:cCenCos,oCDCADD:cCodCaj,.F.)
  ENDIF

  IF cAction="VENTAS" 
     EJECUTAR("BRLIBCOMFCH",cWhere,oCDCADD:cCodSuc,oCDCADD:nPeriodo,oCDCADD:dDesde,oCDCADD:dHasta,cTitle,oCDCADD:cCenCos,oCDCADD:cCodCaj,.T.)
  ENDIF

  IF cAction="CNDPRESUPUESTO"
    cWhere:=[(LEFT(CTA_CODIGO,1)="4" OR LEFT(CTA_CODIGO,1)="6")]
    EJECUTAR("BRCNDPLAGENXCTA",cWhere,oDp:cSucMain,oDp:nEjercicio,oDp:dFchInicio,oDp:dFchCierre," [General sin Prestadores de Servicios]",STRZERO(0,10))
  ENDIF

  IF cAction="NOMQUINCENAL"
     EJECUTAR("BRMOMXLSQUIN")
  ENDIF

  IF cAction="VENTAS" .OR. Empty(cAction)
//     EJECUTAR("CDCVENTAS",oCDCADD:cCodSuc,oCDCADD:dDesde,oCDCADD:dHasta,oCDCADD:cDir)
  ENDIF

RETURN .T.

/*
// genera calendario fiscal del periodo
*/
FUNCTION HACERWHERE(dDesde,dHasta)
   EJECUTAR("CREARCALFIS",dDesde,dHasta,.F.,.F.)
RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCDCADD:oPeriodo:nAt,cWhere

  oCDCADD:nPeriodo:=nPeriodo

  IF oCDCADD:oPeriodo:nAt=LEN(oCDCADD:oPeriodo:aItems)

     oCDCADD:oDesde:ForWhen(.T.)
     oCDCADD:oHasta:ForWhen(.T.)
     oCDCADD:oBtn  :ForWhen(.T.)

     DPFOCUS(oCDCADD:oDesde)

  ELSE

     oCDCADD:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCDCADD:oDesde:VarPut(oCDCADD:aFechas[1] , .T. )
     oCDCADD:oHasta:VarPut(oCDCADD:aFechas[2] , .T. )

     oCDCADD:dDesde:=oCDCADD:aFechas[1]
     oCDCADD:dHasta:=oCDCADD:aFechas[2]

     cWhere:=oCDCADD:HACERWHERE(oCDCADD:dDesde,oCDCADD:dHasta,oCDCADD:cWhere,.T.)

     oCDCADD:LEERDATA(cWhere,oCDCADD:oBrw,oCDCADD:cServer)

  ENDIF

  oCDCADD:SAVEPERIODO()

RETURN .T.

FUNCTION LEERDATA()
RETURN .T.

FUNCTION LEERDATAFIS(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={},I,nMes:=MONTH(oDp:dFecha)
   LOCAL oDb,aOptions:={}

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cSql:= "  SELECT  "+;
          "  PLP_FECHA, "+;
          "  MONTHNAME(PLP_FECHA) AS MES, "+;
          "  DAYNAME(PLP_FECHA) AS DIA, "+;
          "  PLP_TIPDOC, "+;
          "  TDC_DESCRI, "+;
          "  PLP_REFERE, "+;
          "  DOC_FECHA  AS FCHREG, "+;
          "  IF(DOC_NETO=0 OR DOC_NETO IS NULL ,PLP_MTOCAL,DOC_NETO), "+;
          "  DOC_FECHA-PLP_FECHA AS DIASDOC, "+;
          "  '' AS REGESTATUS, "+;
          "  PAG_FECHA  AS FCHPAGO, "+;
          "  PAG_FECHA-DOC_FECHA AS DIASPAG, "+;
          "  '' AS PAGESTATUS, "+;
          "  PAG_PAGNUM AS PAGNUMERO, "+;
          "  DOC_CBTNUM AS CBTNUM, "+;
          "  0 AS DIAS, "+;
          "  0 AS COLOR,PRO_CODIGO,DOC_NUMERO,PGC_NUMERO,PLP_NUMREG,PRO_NOMBRE,TDC_CLRGRA,PLP_MTOCAL,PLP_VALCAM,"+;
          "  PLP_MTOCAL/PLP_VALCAM AS PLP_MTODIV "+;
          "  FROM DPDOCPROPROG   "+;
          "  INNER JOIN DPTIPDOCPRO      ON PLP_TIPDOC=TDC_TIPO   AND TDC_TRIBUT=1 AND TDC_ACTIVO=1 "+;
          "  INNER JOIN DPPROVEEDOR      ON PLP_CODIGO=PRO_CODIGO      "+;
          "  INNER JOIN DPPROVEEDORPROG  ON PLP_CODSUC=PGC_CODSUC AND  "+;
          "                                 PLP_CODIGO=PGC_CODIGO AND  "+;
          "                                 PLP_TIPDOC=PGC_TIPDOC AND  "+;
          "                                 PLP_REFERE=PGC_REFERE      "+;
          "  LEFT  JOIN       DPDOCPRO   ON PLP_CODSUC=DOC_CODSUC AND  "+;
          "                                 PLP_TIPDOC=DOC_TIPDOC AND  "+;
          "                                 PLP_CODIGO=DOC_CODIGO AND  "+;
          "                                 PLP_NUMREG=DOC_PPLREG AND  "+;
          "                                 PLP_NUMDOC=DOC_NUMERO AND  "+;
          "                                 DOC_TIPTRA='D'   "+;
          "  LEFT  JOIN VIEW_DPDOCPROPAG ON DOC_CODSUC=PAG_CODSUC AND "+;
          "                                 DOC_TIPDOC=PAG_TIPDOC AND "+;
          "  							 DOC_CODIGO=PAG_CODIGO AND "+;
          "  							 DOC_NUMERO=PAG_NUMERO     "+;       
          "  WHERE "+cWhere+;
          "  GROUP BY PLP_FECHA,PLP_TIPDOC,PLP_REFERE,PLP_NUMREG "+;
          "  ORDER BY PLP_FECHA   "+;
          ""

   aData:=ASQL(cSql,oDb)


   AEVAL(aData,{|a,n| aData[n,2] :=LEFT(CMES(a[1]),3)   ,;
                      aData[n,3] :=LEFT(CSEMANA(a[1]),3),;
                      aData[n,16]:=a[1]-oDp:dFecha})


   DPWRITE("TEMP\BRCALFISDET.SQL",cSql)


   FOR I=1 TO LEN(aData)

      IF Empty(aData[I,7]) .AND. aData[I,16]<0
        aData[I,10]:="Extemporáneo"
        aData[I,17]:=CLR_HRED
      ENDIF

      IF Empty(aData[I,7]) .AND. MONTH(aData[I,1])=nMes .AND. aData[I,16]>0
        aData[I,10]:="Por Realizar"
        aData[I,17]:=26316
      ENDIF

      IF !Empty(aData[I,7]) 
        aData[I,10]:="Registrado"
        aData[I,17]:=CLR_HBLUE
      ENDIF

      IF !Empty(aData[I,11]) 
        aData[I,10]:="Pagado"
        aData[I,17]:=CLR_GREEN
      ENDIF


      IF !Empty(aData[I,10]) .AND.!Empty(aData[I,7])
        aData[I,13]:=IIF(Empty(aData[I,15]),"Sin Efecto","Por Pagar")
      ENDIF

   NEXT I

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   IF ValType(oBrw)="O"

      oCDCADD:cSql   :=cSql
      oCDCADD:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1
/*
      oCol:=oCDCADD:oBrw:aCols[9]
      oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')
      oCol:=oCDCADD:oBrw:aCols[12]
      oCol:cFooter      :=FDP(aTotal[12],'999,999,999.99')

      oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      oBrw:RefreshFooters()
*/
      EJECUTAR("BRWCALTOTALES",oBrw,.T.)

      FOR I=1 TO LEN(aData)
        IF ASCAN(aOptions,aData[I,10])=0
          AADD(aOptions,aData[I,10])
        ENDIF
      NEXT I

      ADEPURA(aOptions,{|a,n| Empty(a)})

      AADD(aOptions,"Todos")

      oCDCADD:oOptions:aItems:=ACLONE(aOptions)


      AEVAL(oCDCADD:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCDCADD:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION HACERWHEREFIS(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCPROPROG.PLP_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCPROPROG.PLP_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF

   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCDCADD:cWhereQry)
       cWhere:=cWhere + oCDCADD:cWhereQry
     ENDIF

     oCDCADD:LEERDATAFIS(cWhere,oCDCADD:oBrw,oCDCADD:cServer)

   ENDIF


RETURN cWhere

/*
// Aqui ejecuta Proceso Automático
*/
FUNCTION RUNCLICK()
  LOCAL cProce:=oCDCADD:oBrw2:aArrayData[oCDCADD:oBrw2:nArrayAt,5+1]

  oDp:lPanel:=.F.

  IF !Empty(cProce)
    EJECUTAR("DPPROCESOSRUN", cProce )
  ENDIF

RETURN .T

FUNCTION BRWCHANGE()
RETURN .T.

PROCE MENU_NOM(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oCDCADD:cVarName

   AADD(aOption,{"Seleccionar Nómina",""})
   AADD(aOption,{"Pre-Nómina",[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Actualizar Nómina (Generar Recibos) ",[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Reversar"  ,[COUNT("NMFECHAS")>0]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Variaciones"  ,[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Liquidaciones",[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Vacaciones"   ,[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Ausencias"    ,[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Conceptos"      ,""})
   AADD(aOption,{"Constantes"     ,""})
   AADD(aOption,{"Feriados"       ,""})
   AADD(aOption,{"Tipos de Nómina",""})
   AADD(aOption,{"",""})
   AADD(aOption,{"Importar Trabajadores desde EXCEL",""})



   C5MENU oPopFind POPUP;
          COLOR    oDp:nMenuItemClrText,oDp:nMenuItemClrPane;
          COLORSEL oDp:nMenuItemSelText,oDp:nMenuItemSelPane;
          COLORBOX oDp:nMenuBoxClrText;
          HEIGHT   oDp:nMenuHeight;
          FONT     oDp:oFontMenu;
          LOGOCOLOR oDp:nMenuMainClrText

          FOR I=1 TO LEN(aOption)

           IF Empty(aOption[I,1])

              C5SEPARATOR

            ELSE

              nContar++

              bAction:=cFrm+":lTodos:=.F.,oCDCADD:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_NOMRUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF !oDp:lAplNomina
      MsgRun("Aperturando Nómina")
      EJECUTAR("APLNOM")
   ENDIF

   IF nOption=1
      EJECUTAR("NMSELTIPO")    
      RETURN
   ENDIF

   IF nOption=2
      EJECUTAR("PRENOMINA")
      RETURN
   ENDIF

   IF nOption=3
      EJECUTAR("ACTUALIZA")
      RETURN
   ENDIF

   IF nOption=4
      EJECUTAR("REVERSAR")
      RETURN
   ENDIF
 
   IF nOption=5
      EJECUTAR("VARIACIONES")                                                                                                 
   ENDIF

   IF nOption=6
      DPLBX("NMTABLIQ.LBX")
      RETURN
   ENDIF

   IF nOption=7
      DPLBX("NMTABVAC.LBX")
      RETURN
   ENDIF

   IF nOption=8
      DPLBX("NMAUSENCIA.LBX")
      RETURN
   ENDIF

   IF nOption=9
      DPLBX("NMCONCEPTOS.LBX")
      RETURN
   ENDIF

   IF nOption=10
      DPLBX("NMCONSTANTES")
      RETURN
   ENDIF

   IF nOption=11
      DPLBX("DPFERIADOS.LBX")
      RETURN
   ENDIF

   IF nOption=11
      DPLBX("DPFERIADOS.LBX")
      RETURN
   ENDIF

   IF nOption=12
      DPLBX("NMOTRASNM.LBX")                                                                                                  
   ENDIF

   IF nOption=13
      EJECUTAR("NMIMPTRABXLS")                                                                                         
   ENDIF

                                                                                                 
RETURN .T.



PROCE MENU_CNF(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oCDCADD:cVarName

   AADD(aOption,{"Configurar Nómina",""})
   AADD(aOption,{"",""})
   AADD(aOption,{"Plan de Cuentas"  ,""})
   AADD(aOption,{"Tipos de Documentos para Libro de Compras"  ,""})
   AADD(aOption,{"Cuenta Contable por tipo de documentos del proveedor"  ,""})




   C5MENU oPopFind POPUP;
          COLOR    oDp:nMenuItemClrText,oDp:nMenuItemClrPane;
          COLORSEL oDp:nMenuItemSelText,oDp:nMenuItemSelPane;
          COLORBOX oDp:nMenuBoxClrText;
          HEIGHT   oDp:nMenuHeight;
          FONT     oDp:oFontMenu;
          LOGOCOLOR oDp:nMenuMainClrText

          FOR I=1 TO LEN(aOption)

           IF Empty(aOption[I,1])

              C5SEPARATOR

            ELSE

              nContar++

              bAction:=cFrm+":lTodos:=.F.,oCDCADD:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_CNFRUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF nOption=1

      IF !oDp:lAplNomina
        MsgRun("Aperturando Nómina")
        EJECUTAR("APLNOM")
      ENDIF

      EJECUTAR("NMCONFIG")

      RETURN
   ENDIF

   IF nOption=2
     
      IF COUNT("DPCTA")<=1
        EJECUTAR("DPCTAIMPORT")
      ELSE
        DPLBX("DPCTAMENU.LBX")
      ENDIF

      RETURN NIL

   ENDIF
                                                                                                 
RETURN .T.


PROCE MENU_CTA(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oCDCADD:cVarName

   AADD(aOption,{"Código de Integración",""})
   AADD(aOption,{"Ejercicios Contables" ,[]})
   AADD(aOption,{"Centro de Costos"     ,[]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Comprobantes Defiridos"   ,[COUNT("DPCTA")>0]})
   AADD(aOption,{"Comprobantes Actualizados",[COUNT("DPCTA")>0]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Actualizar"                    ,""})
   AADD(aOption,{"Reversar"                      ,""})
   AADD(aOption,{"Comprobantes Fijos Repetitivos",""})

   AADD(aOption,{"",""})
   AADD(aOption,{"Contabilizar Compras",""})
   AADD(aOption,{"Contabilizar Ventas" ,""})
   AADD(aOption,{"Contabilizar Nómina" ,""})

   C5MENU oPopFind POPUP;
          COLOR    oDp:nMenuItemClrText,oDp:nMenuItemClrPane;
          COLORSEL oDp:nMenuItemSelText,oDp:nMenuItemSelPane;
          COLORBOX oDp:nMenuBoxClrText;
          HEIGHT   oDp:nMenuHeight;
          FONT     oDp:oFontMenu;
          LOGOCOLOR oDp:nMenuMainClrText

          FOR I=1 TO LEN(aOption)

           IF Empty(aOption[I,1])

              C5SEPARATOR

            ELSE

              nContar++

              bAction:=cFrm+":lTodos:=.F.,oCDCADD:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_CTARUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF nOption=1
      DPLBX("DPCODINTEGRA.LBX")                                                                                               
      RETURN
   ENDIF

  IF nOption=2
      DPLBX("DPEJERCICIOS.LBX")                                                                                               
      RETURN
   ENDIF

   IF nOption=3
      DPLBX("DPCENCOS.LBX")                                                                                                   
      RETURN
   ENDIF

   IF nOption=4
      EJECUTAR("DPCBTE","N")                                                                                                  
      RETURN
   ENDIF

   IF nOption=5
      EJECUTAR("DPCBTE","S")                                                                                                  
      RETURN
   ENDIF
 
   IF nOption=6
      EJECUTAR("DPCBTEACT")                                                                                                   
   ENDIF

   IF nOption=7
      EJECUTAR("DPCBTEREV")                                                                                                   
      RETURN
   ENDIF

   IF nOption=8
      EJECUTAR("BRCBTFIJORES",NIL,NIL,11)                                                                                     
      RETURN
   ENDIF

   IF nOption=9
      EJECUTAR("DPCONTABCXP")
      RETURN
   ENDIF

   IF nOption=10
      EJECUTAR("DPCONTABCXC")                                                                                                 
      RETURN
   ENDIF
   
   IF nOption=11
      EJECUTAR("NMCONTABILIZAR")                                                                                              
      RETURN
   ENDIF

   IF nOption=12
   ENDIF

   IF nOption=13
   ENDIF
                                                                                                 
RETURN .T.


PROCE MENU_TRIB(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oCDCADD:cVarName

   AADD(aOption,{"URL Oficiales",""})
   AADD(aOption,{"Multas y Sanciones",""})
   AADD(aOption,{"Búscar en legislación",""})
   AADD(aOption,{"",""})
   AADD(aOption,{"ARC-Anual"      ,""})
   AADD(aOption,{"",""})
   AADD(aOption,{"Tipo de Alícuotas",""})
   AADD(aOption,{"% Alicuotas de IVA",""})

   C5MENU oPopFind POPUP;
          COLOR    oDp:nMenuItemClrText,oDp:nMenuItemClrPane;
          COLORSEL oDp:nMenuItemSelText,oDp:nMenuItemSelPane;
          COLORBOX oDp:nMenuBoxClrText;
          HEIGHT   oDp:nMenuHeight;
          FONT     oDp:oFontMenu;
          LOGOCOLOR oDp:nMenuMainClrText

          FOR I=1 TO LEN(aOption)

           IF Empty(aOption[I,1])

              C5SEPARATOR

            ELSE

              nContar++

              bAction:=cFrm+":lTodos:=.F.,oCDCADD:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_TRIBRUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF nOption=1
      DPLBX("DPURL.LBX")
      RETURN
   ENDIF

   IF nOption=2
      EJECUTAR("COTMULTASSANCIONES")
      RETURN
   ENDIF

   IF nOption=3
      EJECUTAR("NMLEYTRA")
      RETURN
   ENDIF

   IF nOption=4
      EJECUTAR("BRARCANUALXCALC")
      RETURN
   ENDIF
 
   IF nOption=5
      DPLBX("DPIVATIP.LBX")
      RETURN NIL
   ENDIF

   IF nOption=6
      DPLBX("DPTARIFASRET.LBX")
      RETURN NIL
   ENDIF

   IF nOption=7
      RETURN
   ENDIF

   IF nOption=8
      RETURN
   ENDIF

   IF nOption=9
      RETURN
   ENDIF

   IF nOption=10
      RETURN
   ENDIF

   IF nOption=11
      RETURN
   ENDIF

   IF nOption=11
      RETURN
   ENDIF

RETURN .T.

FUNCTION RUNCLICK3()
   LOCAL lFecha:=.T.
RETURN EJECUTAR("BRCALFISDETRUN",lFecha,oCDCADD)

FUNCTION HACERQUINCENA()
   LOCAL aLine  :=oCDCADD:oBrw:aArrayData[oCDCADD:oBrw:nArrayAt]
   LOCAL dDesde :=aLine[1],dHasta

   EJECUTAR("GETQUINCENAFISCAL",dDesde)

   oCDCADD:dFchIni:=oDp:aLine[1]
   oCDCADD:dFchFin:=oDp:aLine[2]

RETURN .T.


FUNCTION SAVEPERIODO()
  LOCAL cFileMem  :="USER\ADDON_CDC.MEM"
  LOCAL V_nPeriodo:=oCDCADD:nPeriodo
  LOCAL V_dDesde  :=oCDCADD:dDesde
  LOCAL V_dHasta  :=oCDCADD:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

// EOF
