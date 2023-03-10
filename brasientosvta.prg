// Programa   : BRASIENTOSVTA
// Fecha/Hora : 28/12/2018 04:26:01
// Propósito  : "Asientos Originados desde Venta"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRASIENTOSVTA.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oASIENTOSVTA")="O" .AND. oASIENTOSVTA:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oASIENTOSVTA,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Asientos Originados desde Facturación y Clientes" +IF(Empty(cTitle),"",cTitle)

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

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oASIENTOSVTA
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oASIENTOSVTA","BRASIENTOSVTA.EDT")
// oASIENTOSVTA:CreateWindow(0,0,100,550)
   oASIENTOSVTA:Windows(0,0,aCoors[3]-160,MIN(1300+35,aCoors[4]-10),.T.) // Maximizado

   oASIENTOSVTA:cCodSuc  :=cCodSuc
   oASIENTOSVTA:lMsgBar  :=.F.
   oASIENTOSVTA:cPeriodo :=aPeriodos[nPeriodo]
   oASIENTOSVTA:cCodSuc  :=cCodSuc
   oASIENTOSVTA:nPeriodo :=nPeriodo
   oASIENTOSVTA:cNombre  :=""
   oASIENTOSVTA:dDesde   :=dDesde
   oASIENTOSVTA:cServer  :=cServer
   oASIENTOSVTA:dHasta   :=dHasta
   oASIENTOSVTA:cWhere   :=cWhere
   oASIENTOSVTA:cWhere_  :=cWhere_
   oASIENTOSVTA:cWhereQry:=""
   oASIENTOSVTA:cSql     :=oDp:cSql
   oASIENTOSVTA:oWhere   :=TWHERE():New(oASIENTOSVTA)
   oASIENTOSVTA:cCodPar  :=cCodPar // Código del Parámetro
   oASIENTOSVTA:lWhen    :=.T.
   oASIENTOSVTA:cTextTit :="" // Texto del Titulo Heredado
    oASIENTOSVTA:oDb     :=oDp:oDb
   oASIENTOSVTA:cBrwCod  :="ASIENTOSVTA"
   oASIENTOSVTA:lTmdi    :=.T.

   oASIENTOSVTA:oBrw:=TXBrowse():New( IF(oASIENTOSVTA:lTmdi,oASIENTOSVTA:oWnd,oASIENTOSVTA:oDlg ))
   oASIENTOSVTA:oBrw:SetArray( aData, .F. )
   oASIENTOSVTA:oBrw:SetFont(oFont)

   oASIENTOSVTA:oBrw:lFooter     := .T.
   oASIENTOSVTA:oBrw:lHScroll    := .T.
   oASIENTOSVTA:oBrw:nHeaderLines:= 2
   oASIENTOSVTA:oBrw:nDataLines  := 1
   oASIENTOSVTA:oBrw:nFooterLines:= 1

   oASIENTOSVTA:aData            :=ACLONE(aData)
  oASIENTOSVTA:nClrText :=0
  oASIENTOSVTA:nClrPane1:=16774120
  oASIENTOSVTA:nClrPane2:=16771538

   AEVAL(oASIENTOSVTA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

 

  oCol:=oASIENTOSVTA:oBrw:aCols[1]
  oCol:cHeader      :='Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oASIENTOSVTA:oBrw:aCols[2]
  oCol:cHeader      :='Cbte.'+CRLF+'Número'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oASIENTOSVTA:oBrw:aCols[3]
  oCol:cHeader      :='Num.'+CRLF+'Partida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 50

  oCol:=oASIENTOSVTA:oBrw:aCols[4]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 100

  oCol:=oASIENTOSVTA:oBrw:aCols[5]
  oCol:cHeader      :='Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oASIENTOSVTA:oBrw:aCols[6]
  oCol:cHeader      :='Número'+CRLF+"Documento"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80


  oCol:=oASIENTOSVTA:oBrw:aCols[7]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 380


  oCol:=oASIENTOSVTA:oBrw:aCols[8]
  oCol:cHeader      :='Monto'+CRLF+'Debe'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[8],'999,999,999,999.99')


  oCol:=oASIENTOSVTA:oBrw:aCols[9]
  oCol:cHeader      :='Monto'+CRLF+'Haber'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,9],FDP(nMonto,'9,999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[9],'999,999,999,999.99')

  oCol:=oASIENTOSVTA:oBrw:aCols[10]
  oCol:cHeader      :='Balance'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,10],FDP(nMonto,'9,999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[10],'999,999,999,999.99')

  oCol:=oASIENTOSVTA:oBrw:aCols[11]
  oCol:cHeader      :='#'+CRLF+'Asientos'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 50
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,11],FDP(nMonto,'999,999')}
  oCol:cFooter      :=FDP(aTotal[11],'999,999')

  oCol:=oASIENTOSVTA:oBrw:aCols[12]
  oCol:cHeader      :='Tipo'+CRLF+'Cbte'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 20


  oCol:=oASIENTOSVTA:oBrw:aCols[13]
  oCol:cHeader      :='Serie'+CRLF+'Fiscal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40


  oCol:=oASIENTOSVTA:oBrw:aCols[14]
  oCol:cHeader      :='Tipo'+CRLF+'Trans'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oASIENTOSVTA:oBrw:aCols[15]
  oCol:cHeader      :='Recibo'+CRLF+'Ingreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSVTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70




   oASIENTOSVTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oASIENTOSVTA:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oASIENTOSVTA:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oASIENTOSVTA:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oASIENTOSVTA:nClrPane1, oASIENTOSVTA:nClrPane2 ) } }

   oASIENTOSVTA:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oASIENTOSVTA:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oASIENTOSVTA:oBrw:bLDblClick:={|oBrw|oASIENTOSVTA:RUNCLICK() }

   oASIENTOSVTA:oBrw:bChange:={||oASIENTOSVTA:BRWCHANGE()}
   oASIENTOSVTA:oBrw:CreateFromCode()
    oASIENTOSVTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oASIENTOSVTA)}
    oASIENTOSVTA:BRWRESTOREPAR()


   oASIENTOSVTA:oWnd:oClient := oASIENTOSVTA:oBrw


   oASIENTOSVTA:Activate({||oASIENTOSVTA:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oASIENTOSVTA:lTmdi,oASIENTOSVTA:oWnd,oASIENTOSVTA:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oASIENTOSVTA:oBrw:nWidth()

   oASIENTOSVTA:oBrw:GoBottom(.T.)
   oASIENTOSVTA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRASIENTOSVTA.EDT")
     oASIENTOSVTA:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oASIENTOSVTA:ACTUALIZAR()

   oBtn:cToolTip:="Actualizar Comprobantes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE2.BMP";
          MENU EJECUTAR("BRBTNMENU",{"Todos los Asientos"},"oASIENTOSVTA");
          ACTION oASIENTOSVTA:VERDETALLES()

   oBtn:cToolTip:="Ver Detalles"




  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.bmp";
          MENU EJECUTAR("BRBTNMENU",{"Según Partida"},"oASIENTOSVTA");
          ACTION oASIENTOSVTA:EDITCBTE()

  oBtn:cToolTip:="Editar Comprobante"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP";
          ACTION oASIENTOSVTA:VERCLIENTE(.F.)

   oBtn:cToolTip:="Ficha del Cliente"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION oASIENTOSVTA:VERCLIENTE(.T.)

   oBtn:cToolTip:="Consultar Cliente"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP";
          ACTION oASIENTOSVTA:EDITFRM()

   oBtn:cToolTip:="Formularo del Documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIZAR.BMP";
          ACTION EJECUTAR("BRDOCCLIRESXCNT",NIL,NIL,oASIENTOSVTA:nPeriodo,oASIENTOSVTA:dDesde,oASIENTOSVTA:dHasta)

   oBtn:cToolTip:="Contabilizar"

  
/*
   IF Empty(oASIENTOSVTA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","ASIENTOSVTA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","ASIENTOSVTA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oASIENTOSVTA:oBrw,"ASIENTOSVTA",oASIENTOSVTA:cSql,oASIENTOSVTA:nPeriodo,oASIENTOSVTA:dDesde,oASIENTOSVTA:dHasta,oASIENTOSVTA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oASIENTOSVTA:oBtnRun:=oBtn



       oASIENTOSVTA:oBrw:bLDblClick:={||EVAL(oASIENTOSVTA:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oASIENTOSVTA:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oASIENTOSVTA:oBrw,oASIENTOSVTA);
          ACTION EJECUTAR("BRWSETFILTER",oASIENTOSVTA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oASIENTOSVTA:oBrw);
          WHEN LEN(oASIENTOSVTA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

/*
      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             MENU EJECUTAR("BRBTNMENU",{"Opción1","Opción"},"oFrm");
             FILENAME "BITMAPS\MENU.BMP";
             ACTION 1=1;

             oBtn:cToolTip:="Boton con Menu"

*/


IF nWidth>300 .OR. .T.

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oASIENTOSVTA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oASIENTOSVTA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oASIENTOSVTA:oBrw,oASIENTOSVTA:cTitle,oASIENTOSVTA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oASIENTOSVTA:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oASIENTOSVTA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oASIENTOSVTA:oBrw,NIL,oASIENTOSVTA:cTitle,oASIENTOSVTA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oASIENTOSVTA:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oASIENTOSVTA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oASIENTOSVTA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRASIENTOSVTA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oASIENTOSVTA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oASIENTOSVTA:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oASIENTOSVTA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oASIENTOSVTA:oBrw:GoTop(),oASIENTOSVTA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oASIENTOSVTA:oBrw:PageDown(),oASIENTOSVTA:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oASIENTOSVTA:oBrw:PageUp(),oASIENTOSVTA:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oASIENTOSVTA:oBrw:GoBottom(),oASIENTOSVTA:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oASIENTOSVTA:Close()

  oASIENTOSVTA:oBrw:SetColor(0,oASIENTOSVTA:nClrPane1)

  EVAL(oASIENTOSVTA:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oASIENTOSVTA:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oASIENTOSVTA:oPeriodo  VAR oASIENTOSVTA:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oASIENTOSVTA:LEEFECHAS();
                WHEN oASIENTOSVTA:lWhen 


  ComboIni(oASIENTOSVTA:oPeriodo )

  @ 10, nLin+103 BUTTON oASIENTOSVTA:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oASIENTOSVTA:oPeriodo:nAt,oASIENTOSVTA:oDesde,oASIENTOSVTA:oHasta,-1),;
                         EVAL(oASIENTOSVTA:oBtn:bAction));
                WHEN oASIENTOSVTA:lWhen 


  @ 10, nLin+130 BUTTON oASIENTOSVTA:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oASIENTOSVTA:oPeriodo:nAt,oASIENTOSVTA:oDesde,oASIENTOSVTA:oHasta,+1),;
                         EVAL(oASIENTOSVTA:oBtn:bAction));
                WHEN oASIENTOSVTA:lWhen 


  @ 10, nLin+170 BMPGET oASIENTOSVTA:oDesde  VAR oASIENTOSVTA:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oASIENTOSVTA:oDesde ,oASIENTOSVTA:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oASIENTOSVTA:oPeriodo:nAt=LEN(oASIENTOSVTA:oPeriodo:aItems) .AND. oASIENTOSVTA:lWhen ;
                FONT oFont

   oASIENTOSVTA:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oASIENTOSVTA:oHasta  VAR oASIENTOSVTA:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oASIENTOSVTA:oHasta,oASIENTOSVTA:dHasta);
                SIZE 80,23;
                WHEN oASIENTOSVTA:oPeriodo:nAt=LEN(oASIENTOSVTA:oPeriodo:aItems) .AND. oASIENTOSVTA:lWhen ;
                OF oBar;
                FONT oFont

   oASIENTOSVTA:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oASIENTOSVTA:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oASIENTOSVTA:oPeriodo:nAt=LEN(oASIENTOSVTA:oPeriodo:aItems);
               ACTION oASIENTOSVTA:HACERWHERE(oASIENTOSVTA:dDesde,oASIENTOSVTA:dHasta,oASIENTOSVTA:cWhere,.T.);
               WHEN oASIENTOSVTA:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})




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

  oRep:=REPORTE("BRASIENTOSVTA",cWhere)
  oRep:cSql  :=oASIENTOSVTA:cSql
  oRep:cTitle:=oASIENTOSVTA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oASIENTOSVTA:oPeriodo:nAt,cWhere

  oASIENTOSVTA:nPeriodo:=nPeriodo


  IF oASIENTOSVTA:oPeriodo:nAt=LEN(oASIENTOSVTA:oPeriodo:aItems)

     oASIENTOSVTA:oDesde:ForWhen(.T.)
     oASIENTOSVTA:oHasta:ForWhen(.T.)
     oASIENTOSVTA:oBtn  :ForWhen(.T.)

     DPFOCUS(oASIENTOSVTA:oDesde)

  ELSE

     oASIENTOSVTA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oASIENTOSVTA:oDesde:VarPut(oASIENTOSVTA:aFechas[1] , .T. )
     oASIENTOSVTA:oHasta:VarPut(oASIENTOSVTA:aFechas[2] , .T. )

     oASIENTOSVTA:dDesde:=oASIENTOSVTA:aFechas[1]
     oASIENTOSVTA:dHasta:=oASIENTOSVTA:aFechas[2]

     cWhere:=oASIENTOSVTA:HACERWHERE(oASIENTOSVTA:dDesde,oASIENTOSVTA:dHasta,oASIENTOSVTA:cWhere,.T.)

     oASIENTOSVTA:LEERDATA(cWhere,oASIENTOSVTA:oBrw,oASIENTOSVTA:cServer)

  ENDIF

  oASIENTOSVTA:SAVEPERIODO()

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

     IF !Empty(oASIENTOSVTA:cWhereQry)
       cWhere:=cWhere + oASIENTOSVTA:cWhereQry
     ENDIF

     oASIENTOSVTA:LEERDATA(cWhere,oASIENTOSVTA:oBrw,oASIENTOSVTA:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF


   cSql:=" SELECT   "+;
          "   MOC_FECHA,  "+;
          "   MOC_NUMCBT,  "+;
          "   MOC_NUMPAR, "+;
          "   MOC_CODAUX, "+;
          "   MOC_TIPO  , "+;
          "   MOC_DOCUME, "+;
          "   IF(CLI_NOMBRE IS NULL,DPBANCOS.BAN_NOMBRE,CLI_NOMBRE) AS CLI_NOMBRE, "+;
          "   SUM(IF(MOC_MONTO>0,MOC_MONTO,0)) AS DEBE , "+;
          "   SUM(IF(MOC_MONTO<0,MOC_MONTO*-1,0)) AS HABER, "+;
          "   SUM(MOC_MONTO)                   AS SALDO, "+;
          "   COUNT(*) AS CUANTOS ,"+;
          "   MOC_ACTUAL,MOC_SERFIS,MOC_TIPTRA,MOC_DOCPAG "+;
          "   FROM DPASIENTOS  "+;
          "   INNER JOIN DPCBTE ON MOC_CODSUC=CBT_CODSUC AND MOC_ACTUAL=CBT_ACTUAL AND MOC_NUMCBT=CBT_NUMERO AND MOC_FECHA=CBT_FECHA "+;
          "   LEFT JOIN DPCLIENTES  ON  MOC_CODAUX=CLI_CODIGO "+;
          "   LEFT JOIN DPCTABANCO  ON  MOC_CODAUX=DPCTABANCO.BCO_CTABAN "+;
          "   LEFT JOIN DPBANCOS    ON  DPBANCOS.BAN_CODIGO = DPCTABANCO.BCO_CODIGO "+;
          "   WHERE MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+IF(Empty(cWhere),""," AND ")+cWhere+" AND MOC_ORIGEN='VTA' "+;
          "   GROUP BY MOC_FECHA,MOC_NUMCBT,MOC_NUMPAR,MOC_DOCPAG "+;
          "   ORDER BY MOC_FECHA,MOC_NUMCBT,MOC_NUMPAR,MOC_DOCPAG "+;
          ""

// "   GROUP BY MOC_FECHA,MOC_NUMCBT,MOC_NUMPAR,MOC_CODAUX "+;
// "   ORDER BY MOC_FECHA,MOC_NUMCBT,MOC_NUMPAR,MOC_CODAUX "+;
// "   WHERE MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+IF(Empty(cWhere),""," AND ")+cWhere+" AND MOC_ORIGEN='VTA' AND MOC_NUMPAR<>'' "+;

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRASIENTOSVTA.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{CTOD(""),'','','','',0,'',0})
   ENDIF

   IF ValType(oBrw)="O"

      oASIENTOSVTA:cSql   :=cSql
      oASIENTOSVTA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1


      oCol:=oASIENTOSVTA:oBrw:aCols[8]
      oCol:cFooter      :=FDP(aTotal[8],'9,999,999,999,999.99')

      oCol:=oASIENTOSVTA:oBrw:aCols[9]
      oCol:cFooter      :=FDP(aTotal[9],'9,999,999,999,999.99')

      oCol:=oASIENTOSVTA:oBrw:aCols[10]
      oCol:cFooter      :=FDP(aTotal[10],'9,999,999,999,999.99')


      oASIENTOSVTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oASIENTOSVTA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oASIENTOSVTA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRASIENTOSVTA.MEM",V_nPeriodo:=oASIENTOSVTA:nPeriodo
  LOCAL V_dDesde:=oASIENTOSVTA:dDesde
  LOCAL V_dHasta:=oASIENTOSVTA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oASIENTOSVTA)
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


    IF Type("oASIENTOSVTA")="O" .AND. oASIENTOSVTA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oASIENTOSVTA:cWhere_),oASIENTOSVTA:cWhere_,oASIENTOSVTA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oASIENTOSVTA:LEERDATA(oASIENTOSVTA:cWhere_,oASIENTOSVTA:oBrw,oASIENTOSVTA:cServer)
      oASIENTOSVTA:oWnd:Show()
      oASIENTOSVTA:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1 .AND. "Según"$cOption
      RETURN oASIENTOSVTA:EDITCBTE(.T.)
   ENDIF

   IF nOption=1
      RETURN oASIENTOSVTA:VERDETALLES(oASIENTOSVTA:dDesde,oASIENTOSVTA:dHasta,.T.)
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oASIENTOSVTA:aHead:=EJECUTAR("HTMLHEAD",oASIENTOSVTA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

FUNCTION VERDETALLES(dDesde,dHasta,lAll) 
   LOCAL aLines:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt]
   LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=12,cTitle,cCodCta,cActual:=aLines[12]
   LOCAL aActual:={"S","N","A","F","X","P","C"}
   LOCAL lDelete:=ASCAN(aActual,cActual)=0

   DEFAULT dDesde:=aLines[1],;
           dHasta:=aLines[1],;
           lAll  :=.F.

   cTitle:=" Tipo de Asiento ["+cActual+"] Origen [VTA] Partida ["+aLines[3]+"]"

   cWhere:=" MOC_ACTUAL"+GetWhere("=",cActual)+" AND MOC_ORIGEN"+GetWhere("=","VTA")+IF(lAll,""," AND MOC_NUMCBT"+GetWhere("=",aLines[2]))

   EJECUTAR("BRDPASIENTOS",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCta,cActual,lDelete)

RETURN NIL

FUNCTION VERCLIENTE(lView) 
   LOCAL aLines:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt]

   IF lView
     EJECUTAR("DPCLIENTESCON",NIL,aLines[4])
   ELSE
     EJECUTAR("DPCLIENTES",0,aLines[4])
   ENDIF

RETURN NIL

/*
// Visualizar Asientos
*/
FUNCTION EDITCBTE(lNumPar)
  LOCAL cNumero:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,2]
  LOCAL dFecha :=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,1]
  LOCAL cActual:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,12]

  LOCAL cWhereGrid

  DEFAULT lNumPar:=.F.

  IF lNumPar
    cWhereGrid:="MOC_NUMPAR"+GetWhere("=",oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,3])
  ENDIF


  EJECUTAR("DPCBTE",cActual,cNumero,dFecha,.F.,NIL,cWhereGrid)

RETURN .T.

FUNCTION EDITFRM()
  LOCAL aLine  :=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt]
  LOCAL cNumero:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,06]
  LOCAL cTipDoc:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,05]
  LOCAL cCodigo:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,04]
  LOCAL cTipTra:=oASIENTOSVTA:oBrw:aArrayData[oASIENTOSVTA:oBrw:nArrayAt,14]
  LOCAL cRecord:="REC_NUMERO"+GetWhere("=",aLine[15])

  IF cTipTra="P"
      RETURN EJECUTAR("DPRECIBOSCLIX",NIL,NIL,NIL,NIL,cRecord) //,lView,cSucCli,lPagEle,cCenCos,cCodMon,nValCam)
  ENDIF

RETURN EJECUTAR("VERDOCCLI",oDp:cSucursal,cTipDoc,cCodigo,cNumero,cTipTra)

FUNCTION ACTUALIZAR()
  LOCAL cNumCbt,dFecha,oCbte
  LOCAL cWhere:=NIL // "MOC_ORIGEN"+GetWhere("=","VTA")

  cWhere:="CBT_ACTUAL"+GetWhere("=","N")+IF(Empty(oASIENTOSVTA:dDesde),""," AND ")+GetWhereAnd("CBT_FECHA",oASIENTOSVTA:dDesde,oASIENTOSVTA:dHasta)+" AND MOC_ORIGEN"+GetWhere("=","VTA")

  EJECUTAR("DPCBTEACT",cNumCbt,dFecha,oCbte,cWhere)
RETURN .T.

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oASIENTOSVTA)
// EOF
