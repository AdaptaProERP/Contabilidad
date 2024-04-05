// Programa   : BRWCOMPROBACION
// Fecha/Hora : 08/05/2021 08:52:05
// Propósito  : Balance de Comprobación en Browse
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon)
  LOCAL aData
  LOCAL aNumEje:={}
  LOCAL cTitle:="Balance de Comprobación"
  LOCAL cWhere:=NIL
  LOCAL cNumEje
  LOCAL cServer,cCodPar,aTotal:={},aTotal1:={}


  IF Type("oBrBalCom")="O" .AND. oBrBalCom:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oBrBalCom,GetScript())
  ENDIF

  // Solo Ejercicios con Cbte contables
  aNumEje:=ATABLE(" SELECT EJE_NUMERO FROM DPEJERCICIOS "+;
                  " INNER JOIN DPCBTE ON EJE_CODSUC=CBT_CODSUC AND EJE_NUMERO=CBT_NUMEJE "+;
                  " WHERE EJE_CODSUC"+GetWhere("=",oDp:cSucursal)+" GROUP BY EJE_NUMERO ORDER BY EJE_NUMERO ")



  DEFAULT dDesde:=oDp:dFchInicio,;
          dHasta:=oDp:dFchCierre

  DEFAULT RGO_C3:=8,;
          RGO_C4:="999,999,999,999,999.99",;
          RGO_C6:=NIL,;
          RGO_I1:="",;
          RGO_F1:="",;
          RGO_I2:="",;
          RGO_F2:=""

  PUBLICO("RGO_C7","")

//? RGO_I1,"<-RGO_I1",RGO_F1,"<-RGO_F1"
//? oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon,"oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon"

  cNumEje:=EJECUTAR("GETNUMEJE",dDesde)

// ? dDesde,dHasta,NIL,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,"dDesde,dHasta,NIL,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2"

  aData:=HACERBALANCE(dDesde,dHasta,NIL,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
  
  oDp:aBalCom:={}


  IF Empty(aData)
     MensajeErr("Balance no Generado")
     RETURN {}
  ENDIF

  aTotal:=aData[LEN(aData)-1]

  ViewData(aData,cTitle,cWhere)

  oDp:aBalCom:=ACLONE(aData)

RETURN aData

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol
//,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL nPeriodo:=10,cCodSuc:=oDp:cSucursal

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oBrBalCom","BRCOMPROBACION.EDT")
// oBrBalCom:CreateWindow(0,0,100,550)
   oBrBalCom:Windows(0,0,aCoors[3]-160,aCoors[4]-10,.T.) // Maximizado

   oBrBalCom:cCodSuc  :=cCodSuc
   oBrBalCom:lMsgBar  :=.F.
   oBrBalCom:cPeriodo :=aPeriodos[nPeriodo]
   oBrBalCom:cCodSuc  :=cCodSuc
   oBrBalCom:nPeriodo :=nPeriodo
   oBrBalCom:cNombre  :=""
   oBrBalCom:dDesde   :=dDesde
   oBrBalCom:cServer  :=cServer
   oBrBalCom:dHasta   :=dHasta
   oBrBalCom:cWhere   :=cWhere
   oBrBalCom:cWhere_  :=cWhere_
   oBrBalCom:cWhereQry:=""
   oBrBalCom:cSql     :=oDp:cSql
   oBrBalCom:oWhere   :=TWHERE():New(oBrBalCom)
   oBrBalCom:cCodPar  :=cCodPar // Código del Parámetro
   oBrBalCom:lWhen    :=.T.
   oBrBalCom:cTextTit :="" // Texto del Titulo Heredado
   oBrBalCom:oDb     :=oDp:oDb
   oBrBalCom:cBrwCod  :=""
   oBrBalCom:lTmdi    :=.T.
   oBrBalCom:aNumEje  :=ACLONE(aNumEje)
   oBrBalCom:cNumEje  :=cNumEje
   oBrBalCom:cCodMon  :=cCodMon


   oBrBalCom:RGO_C3:=RGO_C3
   oBrBalCom:RGO_C4:=RGO_C4
   oBrBalCom:RGO_C6:=RGO_C6
   oBrBalCom:RGO_I1:=RGO_I1
   oBrBalCom:RGO_F1:=RGO_F1
   oBrBalCom:RGO_I2:=RGO_I2
   oBrBalCom:RGO_F2:=RGO_F2

   oBrBalCom:oBrw:=TXBrowse():New( IF(oBrBalCom:lTmdi,oBrBalCom:oWnd,oBrBalCom:oDlg ))
   oBrBalCom:oBrw:SetArray( aData, .F. )
   oBrBalCom:oBrw:SetFont(oFont)

   oBrBalCom:oBrw:lFooter     := .T.
   oBrBalCom:oBrw:lHScroll    := .F.
   oBrBalCom:oBrw:nHeaderLines:= 2
   oBrBalCom:oBrw:nDataLines  := 1
   oBrBalCom:oBrw:nFooterLines:= 1

   oBrBalCom:aData            :=ACLONE(aData)
   oBrBalCom:nClrText :=0
   oBrBalCom:nClrPane1:=16772829
   oBrBalCom:nClrPane2:=16771022


   oBrBalCom:nClrPane3:=CLR_HRED
   oBrBalCom:nClrPane4:=CLR_HBLUE
   oBrBalCom:nClrPane5:=4227072



   AEVAL(oBrBalCom:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oBrBalCom:oBrw:aCols[1]
   oCol:cHeader      :='Cuenta'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalCom:oBrw:aArrayData ) } 
   oCol:nWidth       := 110

   oCol:=oBrBalCom:oBrw:aCols[2]
   oCol:cHeader      :='Descripción'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalCom:oBrw:aArrayData ) } 
   oCol:nWidth       :=280

   oCol:=oBrBalCom:oBrw:aCols[3]
   oCol:cHeader      :='Saldo'+CRLF+'Anterior'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalCom:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[3]
   oCol:bClrStd      :={|oBrw,nClrText,cMonto|oBrw    :=oBrBalCom:oBrw,;
                                              cMonto  :=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,3],;
                                              nClrText:=IF("--"$cMonto .OR. "="$cMonto,oBrBalCom:nClrText,oBrBalCom:nClrPane4),;
                                              nClrText:=IF("-"$cMonto .AND. !("--"$cMonto .OR. "="$cMonto),oBrBalCom:nClrPane3,oBrBalCom:nClrPane4),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalCom:nClrPane1,oBrBalCom:nClrPane2 ) } }




   oCol:=oBrBalCom:oBrw:aCols[4]
   oCol:cHeader      :='Debe'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalCom:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[4]

   oCol:bClrStd      :={|oBrw,nClrText,cMonto|oBrw    :=oBrBalCom:oBrw,;
                                              cMonto  :=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,4],;
                                              nClrText:=IF("--"$cMonto .OR. "="$cMonto,oBrBalCom:nClrText,oBrBalCom:nClrPane4),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalCom:nClrPane1,oBrBalCom:nClrPane2 ) } }



   oCol:=oBrBalCom:oBrw:aCols[5]
   oCol:cHeader      :='Haber'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalCom:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[5]

   oCol:bClrStd      :={|oBrw,nClrText,cMonto|oBrw    :=oBrBalCom:oBrw,;
                                              cMonto  :=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,5],;
                                              nClrText:=IF("--"$cMonto .OR. "="$cMonto,oBrBalCom:nClrText,oBrBalCom:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalCom:nClrPane1,oBrBalCom:nClrPane2 ) } }



   oCol:=oBrBalCom:oBrw:aCols[6]
   oCol:cHeader      :='Saldo'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalCom:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:cFooter      :=aTotal[6]


   oCol:=oBrBalCom:oBrw:aCols[7]
   oCol:cHeader      :='Tipo'+CRLF+"Col"

   oCol:=oBrBalCom:oBrw:aCols[8]
   oCol:cHeader      :='#'+CRLF+"Col"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 

   oBrBalCom:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oBrBalCom:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oBrBalCom:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oBrBalCom:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalCom:nClrPane1, oBrBalCom:nClrPane2 ) } }

   oBrBalCom:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrBalCom:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrBalCom:oBrw:bLDblClick:={|oBrw|oBrBalCom:RUNCLICK() }

   oBrBalCom:oBrw:bChange:={||oBrBalCom:BRWCHANGE()}
   oBrBalCom:oBrw:CreateFromCode()
   oBrBalCom:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBrBalCom)}
   oBrBalCom:BRWRESTOREPAR()

   oBrBalCom:oWnd:oClient := oBrBalCom:oBrw

   oBrBalCom:Activate({||oBrBalCom:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBrBalCom:lTmdi,oBrBalCom:oWnd,oBrBalCom:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oBrBalCom:oBrw:nWidth()

   oBrBalCom:oBrw:GoBottom(.T.)
   oBrBalCom:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRDOCPROISLREDI.EDT")
//     oBrBalCom:oBrw:Move(44,0,850+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
  
   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+40 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oBrBalCom:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oBrBalCom:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oBrBalCom:oBrw:oLbx  :=oBrBalCom // MDI:GOTFOCUS()


 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Calcular";
          ACTION oBrBalCom:HACERBALANCE(oBrBalCom:dDesde,oBrBalCom:dHasta,oBrBalCom,oBrBalCom:RGO_C3,oBrBalCom:RGO_C4,oBrBalCom:RGO_C6,oBrBalCom:RGO_I1,oBrBalCom:RGO_F1,oBrBalCom:RGO_I2,oBrBalCom:RGO_F2)


   oBrBalCom:oBtn:=oBtn:bAction
 
   oBtn:cToolTip:="Ejecutar Balance"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIDAD.BMP";
          TOP PROMPT "Cuenta";
          ACTION oBrBalCom:VERCTA()

   oBtn:cToolTip:="Consultar Cuentas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\mayoranalitico.BMP";
          TOP PROMPT "Mayor";
          ACTION oBrBalCom:MAYOR()

   oBtn:cToolTip:="Mayor Analítico"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\edodegananciayperdida.bmp";
          TOP PROMPT "Resultado";
          ACTION EJECUTAR("BRWGANANCIAYP",NIL,oBrBalCom:dDesde,oBrBalCom:dHasta)

   oBtn:cToolTip:="Estado de ganancias y Pérdidas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          TOP PROMPT "Detalles"; 
          ACTION  oBrBalCom:VERBROWSE()

   oBtn:cToolTip:="Ver Asientos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  oBrBalCom:PRINTBALCOM()

   oBtn:cToolTip:="Imprimir Balance de Comprobación"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom";
          ACTION IF(oBrBalCom:oWnd:IsZoomed(),oBrBalCom:oWnd:Restore(),oBrBalCom:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"



 
   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DOCPROISLREDI"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oBrBalCom:oBrw,"DOCPROISLREDI",oBrBalCom:cSql,oBrBalCom:nPeriodo,oBrBalCom:dDesde,oBrBalCom:dHasta,oBrBalCom)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oBrBalCom:oBtnRun:=oBtn



       oBrBalCom:oBrw:bLDblClick:={||EVAL(oBrBalCom:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oBrBalCom:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBrBalCom:oBrw,oBrBalCom);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oBrBalCom:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION  EJECUTAR("BRWSETOPTIONS",oBrBalCom:oBrw);
          WHEN LEN(oBrBalCom:oBrw:aArrayData)>1

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
            TOP PROMPT "Refrescar"; 
              ACTION  oBrBalCom:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.bmp";
          MENU EJECUTAR("BRBTNMENU",{"Según Partida","Visualizar Asientos"},"oBrBalCom");
          ACTION oBrBalCom:EDITCBTE()

  oBtn:cToolTip:="Editar Comprobante"




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oBrBalCom)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

IF .T.
// nWidth>400 

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
              TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oBrBalCom:oBrw,oBrBalCom:cTitle,oBrBalCom:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBrBalCom:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oBrBalCom:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBrBalCom:oBrw,NIL,oBrBalCom:cTitle,oBrBalCom:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBrBalCom:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oBrBalCom:oBrw))

   oBtn:cToolTip:="Previsualización"

   oBrBalCom:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDOCPROISLREDI")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oBrBalCom:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oBrBalCom:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBrBalCom:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oBrBalCom:oBrw:GoTop(),oBrBalCom:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oBrBalCom:oBrw:PageDown(),oBrBalCom:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oBrBalCom:oBrw:PageUp(),oBrBalCom:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oBrBalCom:oBrw:GoBottom(),oBrBalCom:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oBrBalCom:Close()

  oBrBalCom:oBrw:SetColor(0,oBrBalCom:nClrPane1)

  EVAL(oBrBalCom:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBrBalCom:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  //AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  IF oDp:lBtnText
     oBrBalCom:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oBrBalCom:SETBTNBAR(40,40,oBar)
  ENDIF


  //
  // Campo : Periodo
  //

  @ 10+60, nLin COMBOBOX oBrBalCom:oPeriodo  VAR oBrBalCom:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oBrBalCom:LEEFECHAS();
                WHEN oBrBalCom:lWhen 


  ComboIni(oBrBalCom:oPeriodo )

  @ 10+60, nLin+103 BUTTON oBrBalCom:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalCom:oPeriodo:nAt,oBrBalCom:oDesde,oBrBalCom:oHasta,-1),;
                         EVAL(oBrBalCom:oBtn:bAction));
                WHEN oBrBalCom:lWhen 


  @ 10+60, nLin+130 BUTTON oBrBalCom:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalCom:oPeriodo:nAt,oBrBalCom:oDesde,oBrBalCom:oHasta,+1),;
                         EVAL(oBrBalCom:oBtn:bAction));
                WHEN oBrBalCom:lWhen 


  @ 10+60, nLin+170 BMPGET oBrBalCom:oDesde  VAR oBrBalCom:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalCom:oDesde ,oBrBalCom:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oBrBalCom:oPeriodo:nAt=LEN(oBrBalCom:oPeriodo:aItems) .AND. oBrBalCom:lWhen ;
                FONT oFont

   oBrBalCom:oDesde:cToolTip:="F6: Calendario"

  @ 10+60, nLin+252 BMPGET oBrBalCom:oHasta  VAR oBrBalCom:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalCom:oHasta,oBrBalCom:dHasta);
                SIZE 80,23;
                WHEN oBrBalCom:oPeriodo:nAt=LEN(oBrBalCom:oPeriodo:aItems) .AND. oBrBalCom:lWhen ;
                OF oBar;
                FONT oFont

   oBrBalCom:oHasta:cToolTip:="F6: Calendario"

   @ 10+60, nLin+335 BUTTON oBrBalCom:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oBrBalCom:oPeriodo:nAt=LEN(oBrBalCom:oPeriodo:aItems);
               ACTION oBrBalCom:HACERWHERE(oBrBalCom:dDesde,oBrBalCom:dHasta,oBrBalCom:cWhere,.T.);
               WHEN oBrBalCom:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})


  @ 10+60,nLin+325+70 COMBOBOX oBrBalCom:oNumEje  VAR oBrBalCom:cNumEje;
                ITEMS oBrBalCom:aNumEje;
                WHEN LEN(oBrBalCom:aNumEje)>1 OF oBAR PIXEL SIZE 60,NIL;
                ON CHANGE oBrBalCom:CAMBIAEJERCICIO() FONT oFont

  oBrBalCom:oNumEje:cMsg    :="Seleccione el Ejercicio"
  oBrBalCom:oNumEje:cToolTip:="Seleccione el Ejercicio"


RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

  oBrBalCom:VERBROWSE()

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRDOCPROISLREDI",cWhere)
  oRep:cSql  :=oBrBalCom:cSql
  oRep:cTitle:=oBrBalCom:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oBrBalCom:oPeriodo:nAt,cWhere

  oBrBalCom:nPeriodo:=nPeriodo


  IF oBrBalCom:oPeriodo:nAt=LEN(oBrBalCom:oPeriodo:aItems)

     oBrBalCom:oDesde:ForWhen(.T.)
     oBrBalCom:oHasta:ForWhen(.T.)
     oBrBalCom:oBtn  :ForWhen(.T.)

     DPFOCUS(oBrBalCom:oDesde)

  ELSE

     oBrBalCom:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oBrBalCom:oDesde:VarPut(oBrBalCom:aFechas[1] , .T. )
     oBrBalCom:oHasta:VarPut(oBrBalCom:aFechas[2] , .T. )

     oBrBalCom:dDesde:=oBrBalCom:aFechas[1]
     oBrBalCom:dHasta:=oBrBalCom:aFechas[2]

     cWhere:=oBrBalCom:HACERWHERE(oBrBalCom:dDesde,oBrBalCom:dHasta,oBrBalCom:cWhere,.T.)

//     oBrBalCom:LEERDATA(cWhere,oBrBalCom:oBrw,oBrBalCom:cServer)

  ENDIF

  oBrBalCom:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   oBrBalCom:HACERBALANCE(dDesde,dHasta,oBrBalCom)

RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDOCPROISLREDI.MEM",V_nPeriodo:=oBrBalCom:nPeriodo
  LOCAL V_dDesde:=oBrBalCom:dDesde
  LOCAL V_dHasta:=oBrBalCom:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oBrBalCom)
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


    IF Type("oBrBalCom")="O" .AND. oBrBalCom:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oBrBalCom:cWhere_),oBrBalCom:cWhere_,oBrBalCom:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oBrBalCom:LEERDATA(oBrBalCom:cWhere_,oBrBalCom:oBrw,oBrBalCom:cServer)
      oBrBalCom:oWnd:Show()
      oBrBalCom:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1 .AND. "Según"$cOption
      RETURN oBrBalCom:EDITCBTE(.T.,.F.)
   ENDIF

   IF nOption=2 .AND. "Visua"$cOption
      RETURN oBrBalCom:EDITCBTE(.T.,.T.)
   ENDIF


RETURN .T.

FUNCTION HTMLHEAD()

   oBrBalCom:aHead:=EJECUTAR("HTMLHEAD",oBrBalCom)

RETURN

FUNCTION EDITDOCCXP()
   LOCAL aLine  :=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt]
   LOCAL cDocOrg:=aLine[14]
   LOCAL cTipDoc:=aLine[1],cCodigo:=aLine[2],cNumero:=aLine[3]

   IF cDocOrg="D"
     RETURN EJECUTAR("DPDOCCXP",cTipDoc,cCodigo,cTipDoc,cNumero)
   ENDIF
   
   IF cDocOrg="C"
     RETURN EJECUTAR("DPDOCPROINV",oDp:cSucursal,cTipDoc,cCodigo,cNumero)
   ENDIF

RETURN .T.

FUNCTION ISLR()
   LOCAL aLine  :=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt]
   LOCAL cDocOrg:=aLine[14]
   LOCAL cTipDoc:=aLine[1],cCodigo:=aLine[2],cNumero:=aLine[3]

RETURN EJECUTAR("DPDOCISLR",oDp:cSucursal,cTipDoc,cCodigo,cNumero,NIL, 'C' )

/*
// Visualizar Asientos
*/
FUNCTION EDITCBTE(lNumPar,lView)
  LOCAL cActual
  LOCAL cTipDoc:=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,1]
  LOCAL cCodigo:=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,2]
  LOCAL cNumero:=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,3]
  LOCAL dFecha :=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,5]
  LOCAL cWhereGrid

  DEFAULT lNumPar:=.F.,;
          lView  :=.F.

  oDp:dFchCbt:=CTOD("")

  cActual:=EJECUTAR("DPDOCVIEWCON",oDp:cSucursal,cTipDoc,cCodigo,cNumero,"D",.F.,lView)

  IF lView
    RETURN .T.
  ENDIF

  dFecha :=IF(Empty(oDp:dFchCbt),dFecha,oDp:dFchCbt)
  cNumero:=oDp:cNumCbt

// ? oDp:dFchCbt,"oDp:dFchCbt",oDp:cNumCbt
 

  IF lNumPar
    cWhereGrid:="MOC_NUMPAR"+GetWhere("=",oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,18])
//+" AND "+;
//                "MOC_DOCUME"+GetWhere("=",oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt,03])
  ENDIF

  EJECUTAR("DPCBTE",cActual,cNumero,dFecha,.F.,NIL,cWhereGrid)

RETURN .T.


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oBrBalCom)


FUNCTION CAMBIAEJERCICIO()

  oBrBalCom:dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_CODSUC"+GetWhere("=",oBrBalCom:cCodSuc)+" AND EJE_NUMERO"+GetWhere("=",oBrBalCom:cNumEje))
  oBrBalCom:dHasta:=DPSQLROW(2,CTOD(""))

  oBrBalCom:oDesde:Refresh(.T.)
  oBrBalCom:oHasta:Refresh(.T.)

  oDp:oCursor:=NIL

//? "DEBE REHACER EL BALANCE"

RETURN oBrBalCom:HACERBALANCE(oBrBalCom:dDesde,oBrBalCom:dHasta,oBrBalCom)

// ? oBrBalCom:dDesde,oBrBalCom:dHasta

RETURN .T.

FUNCTION HACERBALANCE(dDesde,dHasta,oBrBalCom,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
  LOCAL oCursor,cCodPar,cServer,aLine
  LOCAL oGenRep:=NIL
  LOCAL RGO_C1,RGO_C2
  
  LOCAL aData :={}

  DEFAULT  dDesde:=oDp:dFchInicio,;
           dHasta:=oDp:dFchCierre

  DEFAULT oDp:oCursor:=NIL

  RGO_C1:=dDesde
  RGO_C2:=dHasta

  IF ValType(oBrBalCom)="O"

     aLine:=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt]

     oBrBalCom:RGO_I2:=aLine[1]
     oBrBalCom:RGO_F2:=aLine[1]

     RGO_C3:=oBrBalCom:RGO_C3
     RGO_C4:=oBrBalCom:RGO_C4
     RGO_C6:=oBrBalCom:RGO_C6
     RGO_I1:=oBrBalCom:RGO_I1
     RGO_F1:=oBrBalCom:RGO_F1
     RGO_I2:=oBrBalCom:RGO_I2
     RGO_F2:=oBrBalCom:RGO_F2

  ENDIF

// ? dDesde,dHasta
  oDp:oCursor:=NIL

  IF !ISPCPRG()
     oDp:oCursor:=NIL
  ENDIF
  
//  ? RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,"RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2"

  IF oDp:oCursor=NIL 

    oCursor:=EJECUTAR("BCCALCULAR",oGenRep,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2)

    oDp:oCursor:=oCursor

  ELSE

    oCursor:=oDp:oCursor

  ENDIF
 
  oCursor:GoTop()

 

  WHILE !oCursor:EOF()

     IF oCursor:TIPO="R" 
       AADD(aData,{oCursor:CTA_CODIGO,oCursor:TITULO    ,oCursor:ANTERIOR,oCursor:DEBE,oCursor:HABER,oCursor:SALDO,oCursor:TIPO,oCursor:COL})
     ELSE
       AADD(aData,{oCursor:CTA_CODIGO,oCursor:CTA_DESCRI,oCursor:ANTERIOR,oCursor:DEBE,oCursor:HABER,oCursor:SALDO,oCursor:TIPO,oCursor:COL})
     ENDIF

     oCursor:DbSkip()

  ENDDO

  IF ValType(oBrBalCom)="O"

     IF Empty(aData)
        aData:={}
        AADD(aData,{"","",0,0,0,0,"T"})
     ENDIF

     oBrBalCom:oBrw:aArrayData:=ACLONE(aData)
     oBrBalCom:oBrw:nArrayAt:=1
     oBrBalCom:oBrw:nRowSel :=1
     oBrBalCom:oBrw:GoTop()
     oBrBalCom:oBrw:Refresh(.F.)
  ENDIF

// oCursor:Browse()

RETURN aData

FUNCTION VERCTA()
  LOCAL aLine:=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt]

  EJECUTAR("DPCTACON",NIL,aLine[1])

RETURN .T.

FUNCTION VERBROWSE()
  LOCAL aLine  :=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt]
  LOCAL cCodCta:=ALLTRIM(aLine[1]),nLen:=LEN(cCodCta)
  LOCAL cWhereL:="LEFT(MOC_CUENTA,"+LSTR(LEN(ALLTRIM(cCodCta)))+")"+GetWhere("=",ALLTRIM(cCodCta))
  LOCAL cActual:={"S","C","A"}
  LOCAL lDelete:=NIL,cCodMon:=oBrBalCom:cCodMon,lSldIni:=.T.
  LOCAL dDesdeA,dHastaA,nPeriodo:=10
  LOCAL dDesde  :=oBrBalCom:dDesde
  LOCAL dHasta  :=oBrBalCom:dHasta

  IF Empty(cCodCta) .OR. !ISSQLFIND("DPCTA","CTA_CODIGO"+GetWhere("=",cCodCta))
     RETURN .F.
  ENDIF

  IF oBrBalCom:oBrw:nColSel=3
     // Buscamos el ejercicio Anterior
     dDesdeA:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_HASTA"+GetWhere("<",oBrBalCom:dDesde)+" ORDER BY EJE_HASTA DESC LIMIT 1")
     dHastaA:=DPSQLROW(2,dDesdeA)

     IF !Empty(dDesdeA)
        dDesde  :=dDesdeA
        dHasta  :=dHastaA
        nPeriodo:=11
     ENDIF

// ? dDesdeA,dHastaA,CLPCOPY(oDp:cSql)

  ENDIF

  EJECUTAR("BRDPASIENTOS","MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+cWhereL+" AND "+;
                          GetWhereOr("MOC_ACTUAL",cActual),NIL,nPeriodo,dDesde,dHasta,NIL,cCodCta,cActual,lDelete,cCodMon,lSldIni)

// cActual,lDelete,cCodMon,lSldIni


RETURN .T.

/*
// Imprimir Balance de Comprobación
*/
FUNCTION PRINTBALCOM()
  LOCAL oRep:=REPORTE("BALANCECOM")

  oRep:SetCriterio(1,oBrBalCom:dDesde)
  oRep:SetCriterio(2,oBrBalCom:dHasta)

RETURN .T.

FUNCTION MAYOR()
  LOCAL aLine:=oBrBalCom:oBrw:aArrayData[oBrBalCom:oBrw:nArrayAt]
  LOCAL RGO_C1:=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=aLine[1],RGO_F1:=aLine[1],RGO_I2:=NIL,RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oBrBalCom:dDesde,oBrBalCom:dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
// EOF
