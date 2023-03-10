// Programa   : BRASIENTOSCOM
// Fecha/Hora : 01/03/2019 06:07:05
// Propósito  : "Asientos Originados desde Compras"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRASIENTOSCOM.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.,cTitleO:=cTitle

   IF !Empty(cWhere) .AND. ".TXT"$UPPER(cWhere)
      cWhere:=MEMOREAD(cWhere)
   ENDIF

   oDp:cRunServer:=NIL

   IF Type("oASIENTOSCOM")="O" .AND. oASIENTOSCOM:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oASIENTOSCOM,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Asientos Originados desde Compras " +IF(Empty(cTitle),"","["+cTitle+"]")

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

   oDp:oFrm:=oASIENTOSCOM
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oASIENTOSCOM","BRASIENTOSCOM.EDT")
   oASIENTOSCOM:Windows(0,0,aCoors[3]-160,MIN(1360,aCoors[4]-10),.T.) // Maximizado

   oASIENTOSCOM:cCodSuc  :=cCodSuc
   oASIENTOSCOM:lMsgBar  :=.F.
   oASIENTOSCOM:cPeriodo :=aPeriodos[nPeriodo]
   oASIENTOSCOM:cCodSuc  :=cCodSuc
   oASIENTOSCOM:nPeriodo :=nPeriodo
   oASIENTOSCOM:cNombre  :=""
   oASIENTOSCOM:dDesde   :=dDesde
   oASIENTOSCOM:cServer  :=cServer
   oASIENTOSCOM:dHasta   :=dHasta
   oASIENTOSCOM:cWhere   :=cWhere
   oASIENTOSCOM:cWhere_  :=cWhere_
   oASIENTOSCOM:cWhereQry:=""
   oASIENTOSCOM:cSql     :=oDp:cSql
   oASIENTOSCOM:oWhere   :=TWHERE():New(oASIENTOSCOM)
   oASIENTOSCOM:cCodPar  :=cCodPar // Código del Parámetro
   oASIENTOSCOM:lWhen    :=.T.
   oASIENTOSCOM:cTextTit :="" // Texto del Titulo Heredado
   oASIENTOSCOM:oDb       :=oDp:oDb
   oASIENTOSCOM:cBrwCod  :="ASIENTOSCOM"
   oASIENTOSCOM:lTmdi    :=.T.
   oASIENTOSCOM:cTitleO  :=cTitleO



   oASIENTOSCOM:oBrw:=TXBrowse():New( IF(oASIENTOSCOM:lTmdi,oASIENTOSCOM:oWnd,oASIENTOSCOM:oDlg ))
   oASIENTOSCOM:oBrw:SetArray( aData, .F. )
   oASIENTOSCOM:oBrw:SetFont(oFont)

   oASIENTOSCOM:oBrw:lFooter     := .T.
   oASIENTOSCOM:oBrw:lHScroll    := .T.
   oASIENTOSCOM:oBrw:nHeaderLines:= 2
   oASIENTOSCOM:oBrw:nDataLines  := 1
   oASIENTOSCOM:oBrw:nFooterLines:= 1

   oASIENTOSCOM:aData            :=ACLONE(aData)
   oASIENTOSCOM:nClrText :=0
   oASIENTOSCOM:nClrText1:=CLR_BLUE

   oASIENTOSCOM:nClrPane1:=16773087
   oASIENTOSCOM:nClrPane2:=16768185

   AEVAL(oASIENTOSCOM:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  

  oCol:=oASIENTOSCOM:oBrw:aCols[1]
  oCol:cHeader      :='Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oASIENTOSCOM:oBrw:aCols[2]
  oCol:cHeader      :='Número'+CRLF+'Cbte'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oASIENTOSCOM:oBrw:aCols[3]
  oCol:cHeader      :='Num.'+CRLF+'Partida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 50

  oCol:=oASIENTOSCOM:oBrw:aCols[4]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 90

  oCol:=oASIENTOSCOM:oBrw:aCols[5]
  oCol:cHeader      :='Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  oCol:=oASIENTOSCOM:oBrw:aCols[6]
  oCol:cHeader      :='Número'+CRLF+'Documento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  oCol:=oASIENTOSCOM:oBrw:aCols[7]
  oCol:cHeader      :='Nombre del Proveedor'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 320+60

  oCol:=oASIENTOSCOM:oBrw:aCols[8]
  oCol:cHeader      :='Monto'+CRLF+'Debe'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[8],'999,999,999,999.99')


  oCol:=oASIENTOSCOM:oBrw:aCols[9]
  oCol:cHeader      :='Monto'+CRLF+'Haber'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,9],FDP(nMonto,'999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[9],'999,999,999,999.99')

  oCol:=oASIENTOSCOM:oBrw:aCols[10]
  oCol:cHeader      :='Balance'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,10],FDP(nMonto,'999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[10],'999,999,999,999.99')

  oCol:=oASIENTOSCOM:oBrw:aCols[11]
  oCol:cHeader      :='#'+CRLF+'Asientos'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 50
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,11],FDP(nMonto,'999,999')}
  oCol:cFooter      :=FDP(aTotal[11],'999,999')

  oCol:=oASIENTOSCOM:oBrw:aCols[12]
  oCol:cHeader      :='Tipo'+CRLF+'Cbte'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  oCol:=oASIENTOSCOM:oBrw:aCols[13]
  oCol:cHeader      :='Cuenta'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  oCol:=oASIENTOSCOM:oBrw:aCols[14]
  oCol:cHeader      :='Descripción de la Cuenta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  oCol:=oASIENTOSCOM:oBrw:aCols[15]
  oCol:cHeader      :='Tipo'+CRLF+"Trans"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oASIENTOSCOM:oBrw:aCols[16]
  oCol:cHeader      :='Cbte'+CRLF+"Pago"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oASIENTOSCOM:oBrw:aCols[17]
  oCol:cHeader       := "Integrac."+CRLF+"Contab."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth        := 40
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bBmpData    := { |oBrw|oBrw:=oASIENTOSCOM:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,17],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bStrData    :={||""}


  oASIENTOSCOM:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oASIENTOSCOM:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oASIENTOSCOM:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                               nClrText:=oASIENTOSCOM:nClrText,;
                                               nClrText:=IF(aData[17],oASIENTOSCOM:nClrText1,nClrText),;
                                              {nClrText,iif( oBrw:nArrayAt%2=0, oASIENTOSCOM:nClrPane1, oASIENTOSCOM:nClrPane2 ) } }

   oASIENTOSCOM:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oASIENTOSCOM:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oASIENTOSCOM:oBrw:bLDblClick:={|oBrw|oASIENTOSCOM:RUNCLICK() }

   oASIENTOSCOM:oBrw:bChange:={||oASIENTOSCOM:BRWCHANGE()}
   oASIENTOSCOM:oBrw:CreateFromCode()
    oASIENTOSCOM:bValid   :={|| EJECUTAR("BRWSAVEPAR",oASIENTOSCOM)}
    oASIENTOSCOM:BRWRESTOREPAR()


   oASIENTOSCOM:oWnd:oClient := oASIENTOSCOM:oBrw


   oASIENTOSCOM:Activate({||oASIENTOSCOM:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oASIENTOSCOM:lTmdi,oASIENTOSCOM:oWnd,oASIENTOSCOM:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oASIENTOSCOM:oBrw:nWidth()

   oASIENTOSCOM:oBrw:GoBottom(.T.)
   oASIENTOSCOM:oBrw:Refresh(.T.)

   IF !File("FORMS\BRASIENTOSCOM.EDT")
     oASIENTOSCOM:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oASIENTOSCOM:ACTUALIZAR()

   oBtn:cToolTip:="Actualizar Asientos"

 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE2.BMP";
          MENU EJECUTAR("BRBTNMENU",{"Todos los Asientos"},"oASIENTOSCOM");
          ACTION oASIENTOSCOM:VERDETALLES()

   oBtn:cToolTip:="Ver Detalles"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.bmp";
          MENU EJECUTAR("BRBTNMENU",{"Según Partida"},"oASIENTOSCOM");
          ACTION oASIENTOSCOM:EDITCBTE()

  oBtn:cToolTip:="Editar Comprobante"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROVEEDORES.BMP";
          ACTION oASIENTOSCOM:VERPROVEEDOR(.F.)

   oBtn:cToolTip:="Ficha del Proveedor"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION oASIENTOSCOM:VERPROVEEDOR(.T.)

   oBtn:cToolTip:="Consultar Cliente"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP";
          ACTION oASIENTOSCOM:EDITFRM()

   oBtn:cToolTip:="Formularo del Documento"


 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oASIENTOSCOM:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oASIENTOSCOM:oBrw,oASIENTOSCOM:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF






  
/*
   IF Empty(oASIENTOSCOM:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","ASIENTOSCOM")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","ASIENTOSCOM"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oASIENTOSCOM:oBrw,"ASIENTOSCOM",oASIENTOSCOM:cSql,oASIENTOSCOM:nPeriodo,oASIENTOSCOM:dDesde,oASIENTOSCOM:dHasta,oASIENTOSCOM)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oASIENTOSCOM:oBtnRun:=oBtn



       oASIENTOSCOM:oBrw:bLDblClick:={||EVAL(oASIENTOSCOM:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oASIENTOSCOM:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oASIENTOSCOM:oBrw,oASIENTOSCOM);
          ACTION EJECUTAR("BRWSETFILTER",oASIENTOSCOM:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oASIENTOSCOM:oBrw);
          WHEN LEN(oASIENTOSCOM:oBrw:aArrayData)>1

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


IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oASIENTOSCOM:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oASIENTOSCOM)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oASIENTOSCOM:oBrw,oASIENTOSCOM:cTitle,oASIENTOSCOM:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oASIENTOSCOM:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oASIENTOSCOM:HTMLHEAD(),EJECUTAR("BRWTOHTML",oASIENTOSCOM:oBrw,NIL,oASIENTOSCOM:cTitle,oASIENTOSCOM:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oASIENTOSCOM:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oASIENTOSCOM:oBrw))

   oBtn:cToolTip:="Previsualización"

   oASIENTOSCOM:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRASIENTOSCOM")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oASIENTOSCOM:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oASIENTOSCOM:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oASIENTOSCOM:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oASIENTOSCOM:oBrw:GoTop(),oASIENTOSCOM:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oASIENTOSCOM:oBrw:PageDown(),oASIENTOSCOM:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oASIENTOSCOM:oBrw:PageUp(),oASIENTOSCOM:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oASIENTOSCOM:oBrw:GoBottom(),oASIENTOSCOM:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oASIENTOSCOM:Close()

  oASIENTOSCOM:oBrw:SetColor(0,oASIENTOSCOM:nClrPane1)

  EVAL(oASIENTOSCOM:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oASIENTOSCOM:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oASIENTOSCOM:oPeriodo  VAR oASIENTOSCOM:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oASIENTOSCOM:LEEFECHAS();
                WHEN oASIENTOSCOM:lWhen 


  ComboIni(oASIENTOSCOM:oPeriodo )

  @ 10, nLin+103 BUTTON oASIENTOSCOM:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oASIENTOSCOM:oPeriodo:nAt,oASIENTOSCOM:oDesde,oASIENTOSCOM:oHasta,-1),;
                         EVAL(oASIENTOSCOM:oBtn:bAction));
                WHEN oASIENTOSCOM:lWhen 


  @ 10, nLin+130 BUTTON oASIENTOSCOM:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oASIENTOSCOM:oPeriodo:nAt,oASIENTOSCOM:oDesde,oASIENTOSCOM:oHasta,+1),;
                         EVAL(oASIENTOSCOM:oBtn:bAction));
                WHEN oASIENTOSCOM:lWhen 


  @ 10, nLin+170 BMPGET oASIENTOSCOM:oDesde  VAR oASIENTOSCOM:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oASIENTOSCOM:oDesde ,oASIENTOSCOM:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oASIENTOSCOM:oPeriodo:nAt=LEN(oASIENTOSCOM:oPeriodo:aItems) .AND. oASIENTOSCOM:lWhen ;
                FONT oFont

   oASIENTOSCOM:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oASIENTOSCOM:oHasta  VAR oASIENTOSCOM:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oASIENTOSCOM:oHasta,oASIENTOSCOM:dHasta);
                SIZE 80,23;
                WHEN oASIENTOSCOM:oPeriodo:nAt=LEN(oASIENTOSCOM:oPeriodo:aItems) .AND. oASIENTOSCOM:lWhen ;
                OF oBar;
                FONT oFont

   oASIENTOSCOM:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oASIENTOSCOM:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oASIENTOSCOM:oPeriodo:nAt=LEN(oASIENTOSCOM:oPeriodo:aItems);
               ACTION oASIENTOSCOM:HACERWHERE(oASIENTOSCOM:dDesde,oASIENTOSCOM:dHasta,oASIENTOSCOM:cWhere,.T.);
               WHEN oASIENTOSCOM:lWhen

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

  oRep:=REPORTE("BRASIENTOSCOM",cWhere)
  oRep:cSql  :=oASIENTOSCOM:cSql
  oRep:cTitle:=oASIENTOSCOM:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oASIENTOSCOM:oPeriodo:nAt,cWhere

  oASIENTOSCOM:nPeriodo:=nPeriodo


  IF oASIENTOSCOM:oPeriodo:nAt=LEN(oASIENTOSCOM:oPeriodo:aItems)

     oASIENTOSCOM:oDesde:ForWhen(.T.)
     oASIENTOSCOM:oHasta:ForWhen(.T.)
     oASIENTOSCOM:oBtn  :ForWhen(.T.)

     DPFOCUS(oASIENTOSCOM:oDesde)

  ELSE

     oASIENTOSCOM:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oASIENTOSCOM:oDesde:VarPut(oASIENTOSCOM:aFechas[1] , .T. )
     oASIENTOSCOM:oHasta:VarPut(oASIENTOSCOM:aFechas[2] , .T. )

     oASIENTOSCOM:dDesde:=oASIENTOSCOM:aFechas[1]
     oASIENTOSCOM:dHasta:=oASIENTOSCOM:aFechas[2]

     cWhere:=oASIENTOSCOM:HACERWHERE(oASIENTOSCOM:dDesde,oASIENTOSCOM:dHasta,oASIENTOSCOM:cWhere,.T.)

     oASIENTOSCOM:LEERDATA(cWhere,oASIENTOSCOM:oBrw,oASIENTOSCOM:cServer)

  ENDIF

  oASIENTOSCOM:SAVEPERIODO()

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

     IF !Empty(oASIENTOSCOM:cWhereQry)
       cWhere:=cWhere + oASIENTOSCOM:cWhereQry
     ENDIF

     oASIENTOSCOM:LEERDATA(cWhere,oASIENTOSCOM:oBrw,oASIENTOSCOM:cServer)

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

   cSql :="   SELECT   "+;
          "   MOC_FECHA,  "+;
          "   MOC_NUMCBT,  "+;
          "   MOC_NUMPAR, "+;
          "   MOC_CODAUX, "+;
          "   MOC_TIPO  , "+;
          "   MOC_DOCUME, "+;
          "   IF(PRO_NOMBRE IS NULL,DPBANCOS.BAN_NOMBRE,PRO_NOMBRE) AS PRO_NOMBRE, "+;
          "   SUM(IF(MOC_MONTO>0,MOC_MONTO,0)) AS DEBE , "+;
          "   SUM(IF(MOC_MONTO<0,MOC_MONTO*-1,0)) AS HABER, "+;
          "   SUM(MOC_MONTO)                   AS SALDO, "+;
          "   COUNT(*) AS CUANTOS ,"+;
          "   MOC_ACTUAL,MOC_CUENTA,CTA_DESCRI,MOC_TIPTRA,MOC_DOCPAG,IF(MOC_CUENTA"+GetWhere("=",oDp:cCtaIndef)+",0,1) AS LOGICO" +;
          "   FROM DPASIENTOS  "+;
          "   INNER JOIN DPCBTE ON MOC_CODSUC=CBT_CODSUC AND MOC_ACTUAL=CBT_ACTUAL AND MOC_NUMCBT=CBT_NUMERO AND MOC_FECHA=CBT_FECHA "+;
          "   LEFT JOIN DPPROVEEDOR ON  MOC_CODAUX=PRO_CODIGO "+;
          "   LEFT JOIN DPCTA       ON  MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO "+;
          "   LEFT JOIN DPCTABANCO  ON  MOC_CODAUX=DPCTABANCO.BCO_CTABAN "+;
          "   LEFT JOIN DPBANCOS    ON DPBANCOS.BAN_CODIGO = DPCTABANCO.BCO_CODIGO "+;
          "   WHERE MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+IF(Empty(cWhere),""," AND ")+cWhere+" AND MOC_ORIGEN='COM' "+;
          "   GROUP BY MOC_FECHA,MOC_NUMCBT,MOC_NUMPAR,MOC_CODAUX "+;
          "   ORDER BY MOC_FECHA,MOC_NUMCBT,MOC_NUMPAR,MOC_CODAUX"+;
          ""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRASIENTOSCOM.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{CTOD(""),'','','','','','',0,''})
   ENDIF

   AEVAL(aData,{|a,n| aData[n,13]:=ALLTRIM(a[13])})

   IF ValType(oBrw)="O"

      oASIENTOSCOM:cSql   :=cSql
      oASIENTOSCOM:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oASIENTOSCOM:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'99,999,999,999.99')

      oASIENTOSCOM:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oASIENTOSCOM:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oASIENTOSCOM:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRASIENTOSCOM.MEM",V_nPeriodo:=oASIENTOSCOM:nPeriodo
  LOCAL V_dDesde:=oASIENTOSCOM:dDesde
  LOCAL V_dHasta:=oASIENTOSCOM:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oASIENTOSCOM)
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


    IF Type("oASIENTOSCOM")="O" .AND. oASIENTOSCOM:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oASIENTOSCOM:cWhere_),oASIENTOSCOM:cWhere_,oASIENTOSCOM:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oASIENTOSCOM:LEERDATA(oASIENTOSCOM:cWhere_,oASIENTOSCOM:oBrw,oASIENTOSCOM:cServer)
      oASIENTOSCOM:oWnd:Show()
      oASIENTOSCOM:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1 .AND. "Según"$cOption
      RETURN oASIENTOSCOM:EDITCBTE(.T.)
   ENDIF

   IF nOption=1
      RETURN oASIENTOSCOM:VERDETALLES(oASIENTOSCOM:dDesde,oASIENTOSCOM:dHasta,.T.)
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oASIENTOSCOM:aHead:=EJECUTAR("HTMLHEAD",oASIENTOSCOM)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

FUNCTION VERDETALLES(dDesde,dHasta,lAll) 
   LOCAL aLines:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt]
   LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo:=12,cTitle,cCodCta,cActual:=aLines[12]
   LOCAL aActual:={"S","N","A","F","X","P","C"}
   LOCAL lDelete:=ASCAN(aActual,cActual)=0

   DEFAULT dDesde:=aLines[1],;
           dHasta:=aLines[1],;
           lAll  :=.F.

   cTitle:=" Tipo de Asiento ["+cActual+"] Origen [COM] Partida ["+aLines[3]+"]"

   cWhere:=" MOC_ACTUAL"+GetWhere("=",cActual)+" AND MOC_ORIGEN"+GetWhere("=","COM")+IF(lAll,""," AND MOC_NUMCBT"+GetWhere("=",aLines[2]))

   EJECUTAR("BRDPASIENTOS",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCta,cActual,lDelete)

RETURN NIL

FUNCTION VERPROVEEDOR(lView) 
   LOCAL aLines:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt]

   IF lView
     EJECUTAR("DPPROVEEDORCON",NIL,aLines[4])
   ELSE
     EJECUTAR("DPPROVEEDOR",0,aLines[4])
   ENDIF

RETURN NIL

/*
// Visualizar Asientos
*/
FUNCTION EDITCBTE(lNumPar)
  LOCAL cNumero:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,2]
  LOCAL dFecha :=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,1]
  LOCAL cActual:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,12]

  LOCAL cWhereGrid

  DEFAULT lNumPar:=.F.

  IF lNumPar
    cWhereGrid:="MOC_NUMPAR"+GetWhere("=",oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,3])
  ENDIF


  EJECUTAR("DPCBTE",cActual,cNumero,dFecha,.F.,NIL,cWhereGrid)

RETURN .T.

FUNCTION EDITFRM()
  LOCAL aLine  :=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt]
  LOCAL cNumero:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,6]
  LOCAL cTipDoc:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,5]
  LOCAL cCodigo:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,4]
  LOCAL cRecord 

  // Pago
  IF aLine[15]="P" .OR. (aLine[15]="D" .AND. aLine[05]="ANT")  
    cRecord:="PAG_NUMERO"+GetWhere("=",aLine[16])
    EJECUTAR("DPCBTEPAGOX",NIL,NIL,NIL,NIL,cRecord,.T.) // lView,cCenCos,cCodMon,nValCam)
    RETURN .T.
  ENDIF

/*
  oCol:=oASIENTOSCOM:oBrw:aCols[15]
  oCol:cHeader      :='Tipo'+CRLF+"Trans"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oASIENTOSCOM:oBrw:aCols[16]
  oCol:cHeader      :='Cbte'+CRLF+"Pago"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oASIENTOSCOM:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
*/

EJECUTAR("DPDOCPROFACCON",NIL,oDp:cSucursal,cTipDoc,cNumero,cCodigo)


FUNCTION ACTUALIZAR()
  LOCAL cNumCbt,dFecha,oCbte:=NIL,cWhere,cTitle:=oASIENTOSCOM:cTitle
  LOCAL cTipDoc:=oASIENTOSCOM:oBrw:aArrayData[oASIENTOSCOM:oBrw:nArrayAt,5]

  cWhere:="CBT_ACTUAL"+GetWhere("=","N")+IF(Empty(oASIENTOSCOM:dDesde),""," AND ")+GetWhereAnd("CBT_FECHA",oASIENTOSCOM:dDesde,oASIENTOSCOM:dHasta)+" AND MOC_ORIGEN"+GetWhere("=","COM")

  DEFAULT oASIENTOSCOM:cTitleO:=""

  cTitle:=oASIENTOSCOM:cTitleO

EJECUTAR("DPCBTEACT",cNumCbt,dFecha,oCbte,cWhere,cTitle)

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oASIENTOSCOM)
// EOF
