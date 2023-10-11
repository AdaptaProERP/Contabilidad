// Programa   : BRPCCBTEDESCU
// Fecha/Hora : 08/08/2023 22:52:54
// Propósito  : "Asientos Contables descuadrados (Post-Conversión)"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRPCCBTEDESCU.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oPCCBTEDESCU")="O" .AND. oPCCBTEDESCU:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oPCCBTEDESCU,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF

   DEFAULT cTitle:="Asientos Contables descuadrados "

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oPCCBTEDESCU

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oPCCBTEDESCU","BRPCCBTEDESCU.EDT")
// oPCCBTEDESCU:CreateWindow(0,0,100,550)
   oPCCBTEDESCU:Windows(0,0,aCoors[3]-160,MIN(707,aCoors[4]-10),.T.) // Maximizado

   oPCCBTEDESCU:CIN_CODCTA:=EJECUTAR("DPGETCTAMOD","DPCODINTEGRA_CTA","DIFRECMON","","CODCTA")

   oPCCBTEDESCU:cCodSuc  :=cCodSuc
   oPCCBTEDESCU:lMsgBar  :=.F.
   oPCCBTEDESCU:cPeriodo :=aPeriodos[nPeriodo]
   oPCCBTEDESCU:cCodSuc  :=cCodSuc
   oPCCBTEDESCU:nPeriodo :=nPeriodo
   oPCCBTEDESCU:cNombre  :=""
   oPCCBTEDESCU:dDesde   :=dDesde
   oPCCBTEDESCU:cServer  :=cServer
   oPCCBTEDESCU:dHasta   :=dHasta
   oPCCBTEDESCU:cWhere   :=cWhere
   oPCCBTEDESCU:cWhere_  :=cWhere_
   oPCCBTEDESCU:cWhereQry:=""
   oPCCBTEDESCU:cSql     :=oDp:cSql
   oPCCBTEDESCU:oWhere   :=TWHERE():New(oPCCBTEDESCU)
   oPCCBTEDESCU:cCodPar  :=cCodPar // Código del Parámetro
   oPCCBTEDESCU:lWhen    :=.T.
   oPCCBTEDESCU:cTextTit :="" // Texto del Titulo Heredado
   oPCCBTEDESCU:oDb      :=oDp:oDb
   oPCCBTEDESCU:cBrwCod  :="PCCBTEDESCU"
   oPCCBTEDESCU:lTmdi    :=.T.
   oPCCBTEDESCU:aHead    :={}
   oPCCBTEDESCU:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oPCCBTEDESCU:bValid   :={|| EJECUTAR("BRWSAVEPAR",oPCCBTEDESCU)}

   oPCCBTEDESCU:lBtnRun     :=.F.
   oPCCBTEDESCU:lBtnMenuBrw :=.F.
   oPCCBTEDESCU:lBtnSave    :=.F.
   oPCCBTEDESCU:lBtnCrystal :=.F.
   oPCCBTEDESCU:lBtnRefresh :=.F.
   oPCCBTEDESCU:lBtnHtml    :=.T.
   oPCCBTEDESCU:lBtnExcel   :=.T.
   oPCCBTEDESCU:lBtnPreview :=.T.
   oPCCBTEDESCU:lBtnQuery   :=.F.
   oPCCBTEDESCU:lBtnOptions :=.T.
   oPCCBTEDESCU:lBtnPageDown:=.T.
   oPCCBTEDESCU:lBtnPageUp  :=.T.
   oPCCBTEDESCU:lBtnFilters :=.T.
   oPCCBTEDESCU:lBtnFind    :=.T.
   oPCCBTEDESCU:lBtnColor   :=.T.

   oPCCBTEDESCU:nClrPane1:=oDp:nClrPane1
   oPCCBTEDESCU:nClrPane2:=oDp:nClrPane2

   oPCCBTEDESCU:nClrText :=0
   oPCCBTEDESCU:nClrText1:=16744448
   oPCCBTEDESCU:nClrText2:=0
   oPCCBTEDESCU:nClrText3:=0




   oPCCBTEDESCU:oBrw:=TXBrowse():New( IF(oPCCBTEDESCU:lTmdi,oPCCBTEDESCU:oWnd,oPCCBTEDESCU:oDlg ))
   oPCCBTEDESCU:oBrw:SetArray( aData, .F. )
   oPCCBTEDESCU:oBrw:SetFont(oFont)

   oPCCBTEDESCU:oBrw:lFooter     := .T.
   oPCCBTEDESCU:oBrw:lHScroll    := .F.
   oPCCBTEDESCU:oBrw:nHeaderLines:= 2
   oPCCBTEDESCU:oBrw:nDataLines  := 1
   oPCCBTEDESCU:oBrw:nFooterLines:= 1




   oPCCBTEDESCU:aData            :=ACLONE(aData)

   AEVAL(oPCCBTEDESCU:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: MOC_CODSUC
  oCol:=oPCCBTEDESCU:oBrw:aCols[1]
  oCol:cHeader      :='Cód.'+CRLF+'Suc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCCBTEDESCU:oBrw:aArrayData ) } 
  oCol:nWidth       := 48

  // Campo: MOC_NUMCBT
  oCol:=oPCCBTEDESCU:oBrw:aCols[2]
  oCol:cHeader      :='#'+CRLF+'Cbte.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCCBTEDESCU:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  // Campo: MOC_FECHA
  oCol:=oPCCBTEDESCU:oBrw:aCols[3]
  oCol:cHeader      :='Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCCBTEDESCU:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: MOC_ACTUAL
  oCol:=oPCCBTEDESCU:oBrw:aCols[4]
  oCol:cHeader      :='Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCCBTEDESCU:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
oCol:bClrStd  := {|nClrText,uValue|uValue:=oPCCBTEDESCU:oBrw:aArrayData[oPCCBTEDESCU:oBrw:nArrayAt,4],;
                     nClrText:=COLOR_OPTIONS("DPASIENTOS ","MOC_ACTUAL",uValue),;
                     {nClrText,iif( oPCCBTEDESCU:oBrw:nArrayAt%2=0, oPCCBTEDESCU:nClrPane1, oPCCBTEDESCU:nClrPane2 ) } } 

  // Campo: CBT_DESCRI
  oCol:=oPCCBTEDESCU:oBrw:aCols[5]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCCBTEDESCU:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  // Campo: MOC_MONTO
  oCol:=oPCCBTEDESCU:oBrw:aCols[6]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCCBTEDESCU:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oPCCBTEDESCU:oBrw:aArrayData[oPCCBTEDESCU:oBrw:nArrayAt,6],;
                              oCol  := oPCCBTEDESCU:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)


  // Campo: LOGICO
  oCol:=oPCCBTEDESCU:oBrw:aCols[7]
  oCol:cHeader      :='Sel'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCCBTEDESCU:oBrw:aArrayData ) } 
  oCol:nWidth       := 35
  // Campo: LOGICO
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oPCCBTEDESCU:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,7],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}
 oCol:bLDClickData:={||oPCCBTEDESCU:oBrw:aArrayData[oPCCBTEDESCU:oBrw:nArrayAt,7]:=!oPCCBTEDESCU:oBrw:aArrayData[oPCCBTEDESCU:oBrw:nArrayAt,7],oPCCBTEDESCU:oBrw:DrawLine(.T.)} 
 oCol:bStrData    :={||""}
 oCol:bLClickHeader:={||oDp:lSel:=!oPCCBTEDESCU:oBrw:aArrayData[1,7],; 
 AEVAL(oPCCBTEDESCU:oBrw:aArrayData,{|a,n| oPCCBTEDESCU:oBrw:aArrayData[n,7]:=oDp:lSel}),oPCCBTEDESCU:oBrw:Refresh(.T.)} 

   oPCCBTEDESCU:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oPCCBTEDESCU:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oPCCBTEDESCU:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oPCCBTEDESCU:nClrText,;
                                                 nClrText:=IF(aLine[7],oPCCBTEDESCU:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oPCCBTEDESCU:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oPCCBTEDESCU:nClrPane1, oPCCBTEDESCU:nClrPane2 ) } }

//   oPCCBTEDESCU:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oPCCBTEDESCU:oBrw:bClrFooter            := {|| {0,14671839 }}

   oPCCBTEDESCU:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oPCCBTEDESCU:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oPCCBTEDESCU:oBrw:bLDblClick:={|oBrw|oPCCBTEDESCU:RUNCLICK() }

   oPCCBTEDESCU:oBrw:bChange:={||oPCCBTEDESCU:BRWCHANGE()}
   oPCCBTEDESCU:oBrw:CreateFromCode()


   oPCCBTEDESCU:oWnd:oClient := oPCCBTEDESCU:oBrw



   oPCCBTEDESCU:Activate({||oPCCBTEDESCU:ViewDatBar()})

   oPCCBTEDESCU:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oPCCBTEDESCU:lTmdi,oPCCBTEDESCU:oWnd,oPCCBTEDESCU:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oPCCBTEDESCU:oBrw:nWidth()

   oPCCBTEDESCU:oBrw:GoBottom(.T.)
   oPCCBTEDESCU:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRPCCBTEDESCU.EDT")
//     oPCCBTEDESCU:oBrw:Move(44,0,707+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD


 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oPCCBTEDESCU:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oPCCBTEDESCU:oBrw,oPCCBTEDESCU:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oPCCBTEDESCU:CREAR_ASIENTOS()

   oBtn:cToolTip:="Crear Asiento Contable para Cuadrar el Asiento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbteactualizado.bmp";
          ACTION oPCCBTEDESCU:EDIT_CBTE()

   oBtn:cToolTip:="Ver Comprobante Contable"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\codintegracion.bmp";
          ACTION EJECUTAR("DPCODINTEGRA",3,"DIFRECMON",oPCCBTEDESCU)

   oBtn:cToolTip:="Código de Integración"





/*
   IF Empty(oPCCBTEDESCU:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","PCCBTEDESCU")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","PCCBTEDESCU"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oPCCBTEDESCU:oBrw,"PCCBTEDESCU",oPCCBTEDESCU:cSql,oPCCBTEDESCU:nPeriodo,oPCCBTEDESCU:dDesde,oPCCBTEDESCU:dHasta,oPCCBTEDESCU)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oPCCBTEDESCU:oBtnRun:=oBtn



       oPCCBTEDESCU:oBrw:bLDblClick:={||EVAL(oPCCBTEDESCU:oBtnRun:bAction) }


   ENDIF




IF oPCCBTEDESCU:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oPCCBTEDESCU");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oPCCBTEDESCU:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oPCCBTEDESCU:lBtnColor

     oPCCBTEDESCU:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oPCCBTEDESCU:oBrw,oPCCBTEDESCU,oPCCBTEDESCU:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oPCCBTEDESCU,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oPCCBTEDESCU,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oPCCBTEDESCU:oBtnColor:=oBtn

ENDIF



IF oPCCBTEDESCU:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oPCCBTEDESCU:oBrw,oPCCBTEDESCU:oFrm)
ENDIF

IF oPCCBTEDESCU:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oPCCBTEDESCU),;
                  EJECUTAR("DPBRWMENURUN",oPCCBTEDESCU,oPCCBTEDESCU:oBrw,oPCCBTEDESCU:cBrwCod,oPCCBTEDESCU:cTitle,oPCCBTEDESCU:aHead));
          WHEN !Empty(oPCCBTEDESCU:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oPCCBTEDESCU:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oPCCBTEDESCU:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oPCCBTEDESCU:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oPCCBTEDESCU:oBrw,oPCCBTEDESCU);
          ACTION EJECUTAR("BRWSETFILTER",oPCCBTEDESCU:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oPCCBTEDESCU:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oPCCBTEDESCU:oBrw);
          WHEN LEN(oPCCBTEDESCU:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oPCCBTEDESCU:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oPCCBTEDESCU:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oPCCBTEDESCU:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oPCCBTEDESCU)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oPCCBTEDESCU:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oPCCBTEDESCU:oBrw,oPCCBTEDESCU:cTitle,oPCCBTEDESCU:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oPCCBTEDESCU:oBtnXls:=oBtn

ENDIF

IF oPCCBTEDESCU:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oPCCBTEDESCU:HTMLHEAD(),EJECUTAR("BRWTOHTML",oPCCBTEDESCU:oBrw,NIL,oPCCBTEDESCU:cTitle,oPCCBTEDESCU:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oPCCBTEDESCU:oBtnHtml:=oBtn

ENDIF


IF oPCCBTEDESCU:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oPCCBTEDESCU:oBrw))

   oBtn:cToolTip:="Previsualización"

   oPCCBTEDESCU:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRPCCBTEDESCU")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oPCCBTEDESCU:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oPCCBTEDESCU:oBtnPrint:=oBtn

   ENDIF

IF oPCCBTEDESCU:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oPCCBTEDESCU:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oPCCBTEDESCU:oBrw:GoTop(),oPCCBTEDESCU:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oPCCBTEDESCU:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oPCCBTEDESCU:oBrw:PageDown(),oPCCBTEDESCU:oBrw:Setfocus())
  ENDIF

  IF  oPCCBTEDESCU:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oPCCBTEDESCU:oBrw:PageUp(),oPCCBTEDESCU:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oPCCBTEDESCU:oBrw:GoBottom(),oPCCBTEDESCU:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oPCCBTEDESCU:Close()

  oPCCBTEDESCU:oBrw:SetColor(0,oPCCBTEDESCU:nClrPane1)

  oPCCBTEDESCU:SETBTNBAR(40,40,oBar)


  EVAL(oPCCBTEDESCU:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oPCCBTEDESCU:oBar:=oBar

    nCol:=347
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  nLin:=48

  //  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  oBar:SetSize(0,80+45,.T.)

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oPCCBTEDESCU:oPeriodo  VAR oPCCBTEDESCU:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oPCCBTEDESCU:LEEFECHAS();
                WHEN oPCCBTEDESCU:lWhen


  ComboIni(oPCCBTEDESCU:oPeriodo )

  @ nLin, nCol+103 BUTTON oPCCBTEDESCU:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oPCCBTEDESCU:oPeriodo:nAt,oPCCBTEDESCU:oDesde,oPCCBTEDESCU:oHasta,-1),;
                         EVAL(oPCCBTEDESCU:oBtn:bAction));
                WHEN oPCCBTEDESCU:lWhen


  @ nLin, nCol+130 BUTTON oPCCBTEDESCU:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oPCCBTEDESCU:oPeriodo:nAt,oPCCBTEDESCU:oDesde,oPCCBTEDESCU:oHasta,+1),;
                         EVAL(oPCCBTEDESCU:oBtn:bAction));
                WHEN oPCCBTEDESCU:lWhen


  @ nLin, nCol+160 BMPGET oPCCBTEDESCU:oDesde  VAR oPCCBTEDESCU:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oPCCBTEDESCU:oDesde ,oPCCBTEDESCU:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oPCCBTEDESCU:oPeriodo:nAt=LEN(oPCCBTEDESCU:oPeriodo:aItems) .AND. oPCCBTEDESCU:lWhen ;
                FONT oFont

   oPCCBTEDESCU:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oPCCBTEDESCU:oHasta  VAR oPCCBTEDESCU:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oPCCBTEDESCU:oHasta,oPCCBTEDESCU:dHasta);
                SIZE 76-2,24;
                WHEN oPCCBTEDESCU:oPeriodo:nAt=LEN(oPCCBTEDESCU:oPeriodo:aItems) .AND. oPCCBTEDESCU:lWhen ;
                OF oBar;
                FONT oFont

   oPCCBTEDESCU:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oPCCBTEDESCU:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oPCCBTEDESCU:oPeriodo:nAt=LEN(oPCCBTEDESCU:oPeriodo:aItems);
               ACTION oPCCBTEDESCU:HACERWHERE(oPCCBTEDESCU:dDesde,oPCCBTEDESCU:dHasta,oPCCBTEDESCU:cWhere,.T.);
               WHEN oPCCBTEDESCU:lWhen

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  @ nLin+30,30 SAY " Cuenta " OF oBar BORDER PIXEL;
               COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 50,20  RIGHT

  @ nLin+30,81 SAY oPCCBTEDESCU:oCIN_CODCTA PROMPT " "+oPCCBTEDESCU:CIN_CODCTA BORDER PIXEL;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 100,20


  @ nLin+52,30 SAY " Nombre " OF oBar BORDER PIXEL;
               COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 50,20 RIGHT 

  @ nLin+52,81 SAY oPCCBTEDESCU:oSAY_CODCTA PROMPT " "+SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oPCCBTEDESCU:CIN_CODCTA));
               BORDER PIXEL;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 300,20


RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRPCCBTEDESCU",cWhere)
  oRep:cSql  :=oPCCBTEDESCU:cSql
  oRep:cTitle:=oPCCBTEDESCU:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oPCCBTEDESCU:oPeriodo:nAt,cWhere

  oPCCBTEDESCU:nPeriodo:=nPeriodo


  IF oPCCBTEDESCU:oPeriodo:nAt=LEN(oPCCBTEDESCU:oPeriodo:aItems)

     oPCCBTEDESCU:oDesde:ForWhen(.T.)
     oPCCBTEDESCU:oHasta:ForWhen(.T.)
     oPCCBTEDESCU:oBtn  :ForWhen(.T.)

     DPFOCUS(oPCCBTEDESCU:oDesde)

  ELSE

     oPCCBTEDESCU:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oPCCBTEDESCU:oDesde:VarPut(oPCCBTEDESCU:aFechas[1] , .T. )
     oPCCBTEDESCU:oHasta:VarPut(oPCCBTEDESCU:aFechas[2] , .T. )

     oPCCBTEDESCU:dDesde:=oPCCBTEDESCU:aFechas[1]
     oPCCBTEDESCU:dHasta:=oPCCBTEDESCU:aFechas[2]

     cWhere:=oPCCBTEDESCU:HACERWHERE(oPCCBTEDESCU:dDesde,oPCCBTEDESCU:dHasta,oPCCBTEDESCU:cWhere,.T.)

     oPCCBTEDESCU:LEERDATA(cWhere,oPCCBTEDESCU:oBrw,oPCCBTEDESCU:cServer,oPCCBTEDESCU)

  ENDIF

  oPCCBTEDESCU:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPASIENTOS.MOC_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPASIENTOS.MOC_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPASIENTOS.MOC_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oPCCBTEDESCU:cWhereQry)
       cWhere:=cWhere + oPCCBTEDESCU:cWhereQry
     ENDIF

     oPCCBTEDESCU:LEERDATA(cWhere,oPCCBTEDESCU:oBrw,oPCCBTEDESCU:cServer,oPCCBTEDESCU)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oPCCBTEDESCU)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT  "+;
          " MOC_CODSUC, "+;
          " MOC_NUMCBT, "+;
          " MOC_FECHA, "+;
          " MOC_ACTUAL, "+;
          " CONCAT(CBT_COMEN1,' ',CBT_COMEN2) AS CBT_DESCRI, "+;
          " SUM(MOC_MONTO) AS MOC_MONTO , "+;
          " 0 AS LOGICO "+;
          " FROM DPASIENTOS  "+;
             " INNER JOIN DPCBTE ON MOC_CODSUC=CBT_CODSUC AND MOC_ACTUAL=CBT_ACTUAL AND MOC_NUMCBT=CBT_NUMERO AND MOC_FECHA=CBT_FECHA "+;
          " WHERE (MOC_ACTUAL='S' OR MOC_ACTUAL='A'  OR MOC_ACTUAL='F' OR  MOC_ACTUAL='C' ) "+;
          " GROUP BY MOC_CODSUC,MOC_NUMCBT,MOC_FECHA,MOC_ACTUAL   "+;
          " HAVING SUM(MOC_MONTO)<>0"+;
""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRPCCBTEDESCU.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',CTOD(""),'','',0,0})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,4]:=SAYOPTIONS("DPASIENTOS","MOC_ACTUAL",a[4])})

   IF ValType(oBrw)="O"

      oPCCBTEDESCU:cSql   :=cSql
      oPCCBTEDESCU:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oPCCBTEDESCU:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oPCCBTEDESCU:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRPCCBTEDESCU.MEM",V_nPeriodo:=oPCCBTEDESCU:nPeriodo
  LOCAL V_dDesde:=oPCCBTEDESCU:dDesde
  LOCAL V_dHasta:=oPCCBTEDESCU:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oPCCBTEDESCU)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oPCCBTEDESCU")="O" .AND. oPCCBTEDESCU:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oPCCBTEDESCU:cWhere_),oPCCBTEDESCU:cWhere_,oPCCBTEDESCU:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oPCCBTEDESCU:LEERDATA(oPCCBTEDESCU:cWhere_,oPCCBTEDESCU:oBrw,oPCCBTEDESCU:cServer,oPCCBTEDESCU)
      oPCCBTEDESCU:oWnd:Show()
      oPCCBTEDESCU:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oPCCBTEDESCU:aHead:=EJECUTAR("HTMLHEAD",oPCCBTEDESCU)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros 
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oPCCBTEDESCU)
RETURN .T.

FUNCTION EDIT_CBTE()
  LOCAL aLine  :=oPCCBTEDESCU:oBrw:aArrayData[oPCCBTEDESCU:oBrw:nArrayAt]
  LOCAL cActual:=LEFT(ALLTRIM(aLine[4]),1),cCodSuc:=aLine[1],cNumero:=aLine[2],dFecha:=aLine[3]

  IF !Empty(cNumero)
    EJECUTAR("DPCBTE",cActual,cNumero,dFecha)
  ENDIF

RETURN .T.

FUNCTION CREAR_ASIENTOS()
  LOCAL aData:=ACLONE(oPCCBTEDESCU:oBrw:aArrayData),I
  LOCAL cActual,cCodSuc,cNumero,dFecha,nMonto,aLine

  oPCCBTEDESCU:CIN_CODCTA:=EJECUTAR("DPGETCTAMOD","DPCODINTEGRA_CTA","DIFRECMON","","CODCTA")
  oPCCBTEDESCU:oCIN_CODCTA:Refresh(.T.)
  oPCCBTEDESCU:oSAY_CODCTA:Refresh(.T.)

  IF Empty(oPCCBTEDESCU:CIN_CODCTA) .OR. oDp:cCtaIndef$ALLTRIM(oPCCBTEDESCU:CIN_CODCTA)
    EJECUTAR("DPCODINTEGRA",3,"DIFRECMON",oPCCBTEDESCU)
    RETURN .F.
  ENDIF
  
  ADEPURA(aData,{|a,n| !a[7]})

  IF Empty(aData)
     MsgMemo("Debe Seleccionar los Comprobantes")
     RETURN .F.
  ENDIF

  IF !MsgNoYes("Desea Ajustar Residuos en "+LSTR(LEN(aData))+" Comprobantes Contables")
      RETURN .F.
  ENDIF

  CursorWait()

  FOR I=1 TO LEN(aData)

     aLine  :=aData[I]
     cActual:=LEFT(ALLTRIM(aLine[4]),1)
     cCodSuc:=aLine[1]
     cNumero:=aLine[2]
     dFecha :=aLine[3]
     nMonto :=aLine[6]*-1

     EJECUTAR("ASIENTOCREA",cCodSuc,cNumero,dFecha,"CON",oPCCBTEDESCU:CIN_CODCTA,"AJU","","AJUSTE DE RESIDUO",nMonto,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cActual)

  NEXT I
  
  oPCCBTEDESCU:BRWREFRESCAR()

RETURN .T.
/*
// Genera Correspondencia Masiva
*/


// EOF
