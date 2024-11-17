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
   LOCAL cFileMem :="USER\ADDON_CDC.MEM",V_nPeriodo:=10,nPeriodo,aFechas:={}
   LOCAL V_dDesde :=CTOD("")
   LOCAL V_dHasta :=CTOD("")
   LOCAL oDb      :=OpenOdbc(oDp:cDsnData)
   LOCAL aData    :={} // EJECUTAR("DBFVIEWARRAY","DATADBF\DPLINK.DBF",NIL,.F.)
   LOCAL aMenu    :=EJECUTAR("DBFVIEWARRAY","DATADBF\DPMENU.DBF",NIL,.F.)
   LOCAL dFecha   :=oDp:dFecha

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

   aData:=EJECUTAR("CONTAB_DEBERES",cCodSuc,oDp:dFechaIni,dFecha)



   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-12 BOLD
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-14 BOLD

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

   oCDCADD:nAltoBrw  :=100+100+08
   oCDCADD:nAnchoSpl1:=120+40


   SetScript("ADDON_CDC")

   AADD(aBtn,{"Documentos de Compras"    ,"COMPRAS.BMP"    ,"COMPRAS"}) 
   AADD(aBtn,{"Documentos de Ventas"     ,"VENTASCXC.BMP"  ,"VENTAS" }) 
   AADD(aBtn,{"Importar Nómina Quincenal","TRABAJADOR.BMP" ,"NOMQUINCENAL" }) 

   AADD(aBtn,{"Registrar Presupuesto por Cuenta Contable","objetivos.BMP"    ,"CNDPRESUPUESTO" })

   oCDCADD:Windows(0,0,oDp:aCoors[3]-160,oDp:aCoors[4]-10,.T.)  

  @ 48+40-10+20+15, -1 OUTLOOK oCDCADD:oOut ;
     SIZE (150+250)-40, oCDCADD:oWnd:nHeight()-154;
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

   

 
   oCDCADD:oBrw3:=TXBrowse():New(oCDCADD:oWnd)
   oCDCADD:oBrw3:SetArray( aBotBar, .F. )
   oCDCADD:oBrw3:CreateFromCode()
   oCDCADD:oBrw3:Move(205+oCDCADD:nAltoBrw,205+oCDCADD:nAnchoSpl1,.T.)
   oCDCADD:oBrw3:SetSize(300,150,.T.)


   @ 200+oCDCADD:nAltoBrw,205+oCDCADD:nAnchoSpl1 SPLITTER oCDCADD:oHSplit ;
             HORIZONTAL ;
             PREVIOUS CONTROLS oCDCADD:oBrw2 ;
             HINDS CONTROLS oCDCADD:oBrw3 ;
             TOP MARGIN 80 ;
             BOTTOM MARGIN 80 ;
             SIZE 300, 4  PIXEL ;
             OF oCDCADD:oWnd ;
             _3DLOOK

   @ 0,200+oCDCADD:nAnchoSpl1   SPLITTER oCDCADD:oVSplit ;
             VERTICAL ;
             PREVIOUS CONTROLS oCDCADD:oOut ;
             HINDS CONTROLS oCDCADD:oBrw2, oCDCADD:oHSplit, oCDCADD:oBrw3 ;
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

RETURN

FUNCTION FRMINIT()
  LOCAL oCursor,oBar,oBtn,oFont,nCol:=12,nLin:=0
  LOCAL nLin:=0

  DEFINE BUTTONBAR oBar SIZE 44+25,44+20 OF oCDCADD:oWnd 3D CURSOR oCursor

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -09 BOLD

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONFIGURA.BMP";
          TOP PROMPT "Configurar"; 
          ACTION EJECUTAR("DPCONFIG")

  oBtn:cToolTip:="Configuración"


  DEFINE BUTTON oBtn;
        OF oBar;
        NOBORDER;
        FONT oFont;
        TOP PROMPT "Tip/Doc"; 
        FILENAME oDp:cPathBitMaps+"TipDocument.bmp",NIL,"BITMAPS\TipDocument.bmp";
        ACTION DPLBX("cdctipdocpro.lbx")

  oBtn:cToolTip:="Tipo Documentos"

 DEFINE BUTTON oBtn;
        OF oBar;
        NOBORDER;
        FONT oFont;
        TOP PROMPT "Integración"; 
        FILENAME oDp:cPathBitMaps+"codintegracion.bmp";
        ACTION EJECUTAR("BRTIPDOCPROCTA","TDC_LBCCDC=1")

  oBtn:cToolTip:="Integración"

  DEFINE BUTTON oBtn;
        OF oBar;
        NOBORDER;
        FONT oFont;
        TOP PROMPT "Proveedores"; 
        FILENAME oDp:cPathBitMaps+"proveedores.bmp";
        ACTION DPLBX("dpproveedor_ocasional.LBX")                                                                                      

  oBtn:cToolTip:="Proveedor Ocasionales"

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

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11  BOLD

  oBar:SetSize(NIL,100+15,.T.)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

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
                FONT oFont;
                ON CHANGE oCDCADD:LEEFECHAS();
                WHEN oCDCADD:lWhen 


  ComboIni(oCDCADD:oPeriodo )

  @ nLin+20, nCol+103 BUTTON oCDCADD:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCDCADD:oPeriodo:nAt,oCDCADD:oDesde,oCDCADD:oHasta,-1),;
                         EVAL(oCDCADD:oBtn:bAction));
                WHEN oCDCADD:lWhen 


  @ nLin+20, nCol+130 BUTTON oCDCADD:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
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
                  FONT oFont

   oCDCADD:oDesde:cToolTip:="F6: Calendario"

  @ nLin+20, nCol+252+5 BMPGET oCDCADD:oHasta  VAR oCDCADD:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCDCADD:oHasta,oCDCADD:dHasta);
                SIZE 80,23;
                WHEN oCDCADD:oPeriodo:nAt=LEN(oCDCADD:oPeriodo:aItems) .AND. oCDCADD:lWhen ;
                OF oBar;
                FONT oFont

   oCDCADD:oHasta:cToolTip:="F6: Calendario"

   @ nLin+20,nCol+335+15 BUTTON oCDCADD:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oCDCADD:oPeriodo:nAt=LEN(oCDCADD:oPeriodo:aItems);
               ACTION oCDCADD:HACERWHERE(oCDCADD:dDesde,oCDCADD:dHasta,oCDCADD:cWhere,.T.);
               WHEN oCDCADD:lWhen

  oBar:Refresh(.T.)

  @ nLin+50,nCol  CHECKBOX oCDCADD:oADD_AUTEJE VAR oCDCADD:ADD_AUTEJE  PROMPT "Auto-Ejecución";
                  WHEN  (AccessField("DPADDON","ADD_AUTEJE",1));
                  FONT oFont;
                  SIZE 140,20 OF oBar;
                   ON CHANGE EJECUTAR("ADDONUPDATE","ADD_AUTEJE",oCDCADD:ADD_AUTEJE,"CDC") PIXEL

  oCDCADD:oADD_AUTEJE:cMsg    :="Auto-Ejecución cuando se Inicia el Sistema"
  oCDCADD:oADD_AUTEJE:cToolTip:="Auto-Ejecución cuando se Inicia el Sistema"

/*
  oCDCADD:oWnd:bResized:={||oCDCADD:oWnd:oClient := oCDCADD:oOut,;
                          oCDCADD:oWnd:bResized:=NIL}
*/

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

FUNCTION SAVEPERIODO()
  LOCAL cFileMem  :="USER\ADDON_CDC.MEM"
  LOCAL V_nPeriodo:=oCDCADD:nPeriodo
  LOCAL V_dDesde  :=oCDCADD:dDesde
  LOCAL V_dHasta  :=oCDCADD:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.
// EOF
