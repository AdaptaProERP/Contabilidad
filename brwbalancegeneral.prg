// Programa   : BRWBALANCEGENERAL 
// Fecha/Hora : 08/05/2021 08:52:05
// Prop�sito  : Balance de Comprobaci�n en Browse
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep,RGO_C1,RGO_C2,RGO_C3,"BG",RGO_C5,RGO_C6,RGO_C7,RGO_C8,RGO_C9,RGO_I1,RGO_RGO_F1)
  LOCAL aData
  LOCAL aNumEje:={}
  LOCAL cTitle :="Balance General"
  LOCAL cWhere :=NIL
  LOCAL cNumEje
  LOCAL cServer,cCodPar,aTotal:={},aTotal1:={}
  LOCAL oCursor,aLine,cField
  LOCAL cCtaIng:=ALLTRIM(oDp:cCtaGp1)
  LOCAL cGp    :="GP"
  LOCAL cCenCos:="",cCodMon:="",cPorcen:=""
  LOCAL dDesde :=CTOD(""),dHasta:=CTOD("")

  IF Type("oBrBalGen")="O" .AND. oBrBalGen:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oBrBalGen,GetScript())
  ENDIF
 
//  DEFAULT dDesde:=oDp:dFchInicio,;
//          dHasta:=oDp:dFchCierre

  DEFAULT RGO_C1:=FCHFINMES(oDp:dFecha),;
          RGO_C2:=4,;
          RGO_C3:="@E 99,999,999,999,999,999.99",;
          RGO_C4:=20,;
          RGO_C5:="Total",;
          RGO_C6:="Pasivo y Capital",;
          RGO_C7:=oDp:cSucursal,;
          RGO_C8:=NIL,;
          RGO_C9:="",;
          RGO_C10:=NIL,;
          RGO_C11:=10,;
          RGO_C12:=NIL,;
          RGO_I1:="",;
          RGO_F1:=""
          

// ? oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon

  aNumEje:=ATABLE(" SELECT EJE_NUMERO FROM DPEJERCICIOS "+;
                  " INNER JOIN DPCBTE ON CBT_CODSUC=EJE_CODSUC AND CBT_NUMEJE=EJE_NUMERO "+;
                  " WHERE EJE_CODSUC"+GetWhere("=",oDp:cSucursal)+" GROUP BY EJE_NUMERO ORDER BY EJE_NUMERO ")


//  RGO_C1:=dDesde
//  RGO_C2:=dHasta

  IF Empty(RGO_C1)
     RGO_C1:=FCHFINMES(oDp:dFecha)
  ENDIF

  IF EMPTY(RGO_C2)
     RGO_C2:=4
  ENDIF

  IF Empty(RGO_C3)
     RGO_C3:="@E 99,999,999,999,999,999.99"
  ENDIF

  IF Empty(RGO_C4)
      RGO_C4:=20
  ENDIF

  IF Empty(RGO_C5)
     RGO_C5:="Total"
  ENDIF

  IF Empty(RGO_C6)
     RGO_C6:="Pasivo y Capital"
  ENDIF

  IF Empty(RGO_C7)
     RGO_C7:=oDp:cSucursal
  ENDIF

  IF Empty(RGO_C9)  
     RGO_C9:="" // oDp:cMoneda
  ENDIF

  IF Empty(RGO_C10)
     RGO_C11:=10
  ENDIF
 
  IF Empty(RGO_I1)
     RGO_I1:=""
  ENDIF

  IF Empty(RGO_F1)
     RGO_F1:=""
  ENDIF

  dHasta:=RGO_C1


  cNumEje:=EJECUTAR("GETNUMEJE",RGO_C1)

  aData  :=CREAR_BG()

  IF Empty(aData)
     MensajeErr("Balance no Generado hasta la fecha "+DTOC(RGO_C1))
     RETURN {}
  ENDIF

  aTotal:=aData[LEN(aData)-1]

  ViewData(aData,cTitle,cWhere)

  oDp:aBalCom:=ACLONE(aData)

RETURN aData

FUNCTION CREAR_BG(oCursor)
  LOCAL aData:={},aLine,cField,I

  DEFAULT oCursor   :=EJECUTAR("BGCALCULAR",oGenRep,RGO_C1,RGO_C2,RGO_C3,"BG",RGO_C5,RGO_C6,RGO_C7,RGO_C8,RGO_C9)

  IF !ValType(oCursor)="O"
     MensajeErr("Balance no Generado")
     RETURN {}
  ENDIF

  oCursor:GoTop()

  WHILE !oCursor:EOF()

     aLine:={oCursor:CTA_CODIGO,oCursor:TITULO}

     FOR I=1 TO RGO_C2

       cField:="COL"+STRZERO(I,2)

       IF oCursor:FieldPos(cField)>0
          AADD(aLine,oCursor:FieldGet(cField))
       ENDIF

     NEXT I

     AADD(aData,aLine)

     oCursor:DbSkip()

  ENDDO

RETURN aData

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL nPeriodo:=10,cCodSuc:=oDp:cSucursal

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oBrBalGen","BRWGANANCIAYP.EDT")
   oBrBalGen:Windows(0,0,aCoors[3]-10,aCoors[4]-10,.T.) // Maximizado

   oBrBalGen:cCodSuc  :=cCodSuc
   oBrBalGen:lMsgBar  :=.F.
   oBrBalGen:cPeriodo :=aPeriodos[nPeriodo]
   oBrBalGen:cCodSuc  :=cCodSuc
   oBrBalGen:nPeriodo :=nPeriodo
   oBrBalGen:cNombre  :=""
   oBrBalGen:dDesde   :=dDesde
   oBrBalGen:cServer  :=cServer
   oBrBalGen:dHasta   :=dHasta
   oBrBalGen:cWhere   :=cWhere
   oBrBalGen:cWhere_  :=cWhere_
   oBrBalGen:cWhereQry:=""
   oBrBalGen:cSql     :=oDp:cSql
   oBrBalGen:oWhere   :=TWHERE():New(oBrBalGen)
   oBrBalGen:cCodPar  :=cCodPar // C�digo del Par�metro
   oBrBalGen:lWhen    :=.T.
   oBrBalGen:cTextTit :="" // Texto del Titulo Heredado
   oBrBalGen:oDb     :=oDp:oDb
   oBrBalGen:cBrwCod  :=""
   oBrBalGen:lTmdi    :=.T.
   oBrBalGen:aNumEje  :=ACLONE(aNumEje)
   oBrBalGen:cNumEje  :=cNumEje
   oBrBalGen:cCodMon  :=cCodMon
   oBrBalGen:cCtaIng  :=cCtaIng

   oBrBalGen:cGp    :=cGp

   oBrBalGen:RGO_C1 :=RGO_C1
   oBrBalGen:RGO_C2 :=RGO_C2
   oBrBalGen:RGO_C3 :=RGO_C3
   oBrBalGen:RGO_C4 :=RGO_C4
   oBrBalGen:RGO_C5 :=RGO_C5
   oBrBalGen:RGO_C6 :=RGO_C6
   oBrBalGen:RGO_C7 :=RGO_C7
   oBrBalGen:RGO_C8 :=RGO_C8
   oBrBalGen:RGO_C9 :=RGO_C9
   oBrBalGen:RGO_C10:=RGO_C10
   oBrBalGen:RGO_C11:=RGO_C11
   oBrBalGen:RGO_C12:=RGO_C12
   oBrBalGen:RGO_C13:=RGO_C13

   oBrBalGen:RGO_I1:=RGO_I1
   oBrBalGen:RGO_F1:=RGO_F1
   oBrBalGen:RGO_I2:=RGO_I2
   oBrBalGen:RGO_F2:=RGO_F2

   oBrBalGen:oGenRep:=oGenRep

// oGenRep,RGO_C1,RGO_C2,RGO_C3,RGO_C4,"GP",RGO_C6,RGO_C7,RGO_C8,RGO_C9,RGO_C10

   oBrBalGen:oBrw:=TXBrowse():New( IF(oBrBalGen:lTmdi,oBrBalGen:oWnd,oBrBalGen:oDlg ))
   oBrBalGen:oBrw:SetArray( aData, .F. )
   oBrBalGen:oBrw:SetFont(oFont)

   oBrBalGen:oBrw:lFooter     := .T.
   oBrBalGen:oBrw:lHScroll    := .F.
   oBrBalGen:oBrw:nHeaderLines:= 2
   oBrBalGen:oBrw:nDataLines  := 1
   oBrBalGen:oBrw:nFooterLines:= 1

   oBrBalGen:aData            :=ACLONE(aData)
   oBrBalGen:nClrText :=0
   oBrBalGen:nClrPane1:=oDp:nClrPane1
   oBrBalGen:nClrPane2:=oDp:nClrPane2

   oBrBalGen:nClrPane3:=CLR_HRED
   oBrBalGen:nClrPane4:=CLR_HBLUE
   oBrBalGen:nClrPane5:=4227072



   AEVAL(oBrBalGen:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oBrBalGen:oBrw:aCols[1]
   oCol:cHeader      :='Cuenta'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGen:oBrw:aArrayData ) } 
   oCol:nWidth       := 110

   oCol:=oBrBalGen:oBrw:aCols[2]
   oCol:cHeader      :='Descripci�n'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGen:oBrw:aArrayData ) } 
   oCol:nWidth       :=280

   oCol:=oBrBalGen:oBrw:aCols[3]
   oCol:cHeader      :='Nivel'+CRLF+'(1)'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGen:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
//   oCol:cFooter      :=aTotal[3]
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGen:oBrw,;
                                              cCuenta :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGen:cCtaIng=LEFT(cCuenta,1),oBrBalGen:nClrText,oBrBalGen:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGen:nClrPane1,oBrBalGen:nClrPane2 ) } }

   oCol:=oBrBalGen:oBrw:aCols[4]
   oCol:cHeader      :='Nivel'+CRLF+"(2)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGen:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGen:oBrw,;
                                              cCuenta :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGen:cCtaIng=LEFT(cCuenta,1),oBrBalGen:nClrText,oBrBalGen:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGen:nClrPane1,oBrBalGen:nClrPane2 ) } }


   oCol:=oBrBalGen:oBrw:aCols[5]
   oCol:cHeader      :='Nivel'+CRLF+"(3)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGen:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'

   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGen:oBrw,;
                                              cCuenta :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGen:cCtaIng=LEFT(cCuenta,1),oBrBalGen:nClrText,oBrBalGen:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGen:nClrPane1,oBrBalGen:nClrPane2 ) } }



   oCol:=oBrBalGen:oBrw:aCols[6]
   oCol:cHeader      :='Nivel'+CRLF+"(4)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGen:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGen:oBrw,;
                                              cCuenta :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGen:cCtaIng=LEFT(cCuenta,1),oBrBalGen:nClrText,oBrBalGen:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGen:nClrPane1,oBrBalGen:nClrPane2 ) } }

IF LEN(oBrBalGen:oBrw:aCols)>6

   oCol:=oBrBalGen:oBrw:aCols[7]
   oCol:cHeader      :='Nivel'+CRLF+"(5)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGen:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGen:oBrw,;
                                              cCuenta :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGen:cCtaIng=LEFT(cCuenta,1),oBrBalGen:nClrText,oBrBalGen:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGen:nClrPane1,oBrBalGen:nClrPane2 ) } }

ENDIF

  oCol:cFooter      :=FDP(oDp:nUtilidad,"999,999,999,999,999,999.99")


   oBrBalGen:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oBrBalGen:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oBrBalGen:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oBrBalGen:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGen:nClrPane1, oBrBalGen:nClrPane2 ) } }

   oBrBalGen:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrBalGen:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrBalGen:oBrw:bLDblClick:={|oBrw|oBrBalGen:RUNCLICK() }

   oBrBalGen:oBrw:bChange:={||oBrBalGen:BRWCHANGE()}
   oBrBalGen:oBrw:CreateFromCode()
   oBrBalGen:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBrBalGen)}
   oBrBalGen:BRWRESTOREPAR()

   oBrBalGen:oWnd:oClient := oBrBalGen:oBrw

   oBrBalGen:Activate({||oBrBalGen:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBrBalGen:lTmdi,oBrBalGen:oWnd,oBrBalGen:oDlg)
   LOCAL nLin:=0,I
   LOCAL nWidth:=oBrBalGen:oBrw:nWidth()

   oBrBalGen:oBrw:GoBottom(.T.)
   oBrBalGen:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD


 // Emanager no Incluye consulta de Vinculos

/*
   oBrBalGen:oFontBtn   :=oFont    
   oBrBalGen:nClrPaneBar:=oDp:nGris
   oBrBalGen:oBrw:oLbx  :=oBrBalGen

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Ejecutar"; 
          ACTION  oBrBalGen:GPCALCULAR()

   oBrBalGen:oBtn:=oBtn:bAction
 
   oBtn:cToolTip:="Ejecutar Balance"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIDAD.BMP";
          TOP PROMPT "Cuenta"; 
          ACTION oBrBalGen:VERCTA()

   oBtn:cToolTip:="Consultar Cuentas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONFIGURA.bmp";
          TOP PROMPT "Configura"; 
          ACTION EJECUTAR("DPCTAUSO")

   oBtn:cToolTip:="Uso de las Cuentas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\mayoranalitico.BMP";
          TOP PROMPT "Mayor A."; 
          ACTION oBrBalGen:MAYOR()

   oBtn:cToolTip:="Mayor Anal�tico"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\balancecomprobacion.bmp";
          TOP PROMPT "Balance"; 
          ACTION oBrBalGen:BALCOM()

   oBtn:cToolTip:="Balance de Comprobaci�n"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          TOP PROMPT "Asientos"; 
          ACTION  oBrBalGen:VERBROWSE()

   oBtn:cToolTip:="Ver Asientos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  oBrBalGen:PRINTBALGYP()

   oBtn:cToolTip:="Imprimir Ganancias y P�rdidas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oBrBalGen:oWnd:IsZoomed(),oBrBalGen:oWnd:Restore(),oBrBalGen:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oBrBalGen:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBrBalGen:oBrw,oBrBalGen);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oBrBalGen:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION  EJECUTAR("BRWSETOPTIONS",oBrBalGen:oBrw);
          WHEN LEN(oBrBalGen:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar seg�n Valores Comunes"

/*
      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             MENU EJECUTAR("BRBTNMENU",{"Opci�n1","Opci�n"},"oFrm");
             FILENAME "BITMAPS\MENU.BMP";
               TOP PROMPT "Men�"; 
              ACTION  1=1;

             oBtn:cToolTip:="Boton con Menu"

*/


IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar"; 
           ACTION  oBrBalGen:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.bmp";
          MENU EJECUTAR("BRBTNMENU",{"Seg�n Partida","Visualizar Asientos"},"oBrBalGen");
          ACTION oBrBalGen:EDITCBTE()

  oBtn:cToolTip:="Editar Comprobante"




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal"; 
          ACTION  EJECUTAR("BRWTODBF",oBrBalGen)

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
              ACTION  (EJECUTAR("BRWTOEXCEL",oBrBalGen:oBrw,oBrBalGen:cTitle,oBrBalGen:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBrBalGen:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oBrBalGen:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBrBalGen:oBrw,NIL,oBrBalGen:cTitle,oBrBalGen:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBrBalGen:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oBrBalGen:oBrw))

   oBtn:cToolTip:="Previsualizaci�n"

   oBrBalGen:oBtnPreview:=oBtn

ENDIF


IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBrBalGen:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oBrBalGen:oBrw:GoTop(),oBrBalGen:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oBrBalGen:oBrw:PageDown(),oBrBalGen:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oBrBalGen:oBrw:PageUp(),oBrBalGen:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oBrBalGen:oBrw:GoBottom(),oBrBalGen:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oBrBalGen:Close()

  oBrBalGen:oBrw:SetColor(0,oBrBalGen:nClrPane1)

  EVAL(oBrBalGen:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBrBalGen:oBar:=oBar

  nLin:=490-90

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  nLin:=nLin-460
  //
  // Campo : Periodo
  //

  @ 10+35+20, nLin COMBOBOX oBrBalGen:oPeriodo;
             VAR oBrBalGen:cPeriodo ITEMS aPeriodos;
             SIZE 100,200;
             PIXEL;
             OF oBar;
             FONT oFont;
             ON CHANGE oBrBalGen:LEEFECHAS();
             WHEN oBrBalGen:lWhen 

  ComboIni(oBrBalGen:oPeriodo )

//oBrBalGen:oPeriodo:bWhen:={||.F.}
  oBrBalGen:oPeriodo:ForWhen(.T.)


  @ 10+35+20, nLin+103 BUTTON oBrBalGen:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalGen:oPeriodo:nAt,oBrBalGen:oDesde,oBrBalGen:oHasta,-1),;
                         oBrBalGen:LEEFECHAS());
                WHEN oBrBalGen:lWhen 


  @ 10+35+20, nLin+130 BUTTON oBrBalGen:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalGen:oPeriodo:nAt,oBrBalGen:oDesde,oBrBalGen:oHasta,+1),;
                         oBrBalGen:LEEFECHAS());
                WHEN oBrBalGen:lWhen 

 

  @ 10+35+20, nLin+170 BMPGET oBrBalGen:oDesde  VAR oBrBalGen:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalGen:oDesde ,oBrBalGen:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oBrBalGen:oPeriodo:nAt=LEN(oBrBalGen:oPeriodo:aItems) .AND. oBrBalGen:lWhen ;
                FONT oFont

   oBrBalGen:oDesde:cToolTip:="F6: Calendario"

  @ 10+35+20, nLin+252 BMPGET oBrBalGen:oHasta  VAR oBrBalGen:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalGen:oHasta,oBrBalGen:dHasta);
                SIZE 80,23;
                WHEN oBrBalGen:oPeriodo:nAt=LEN(oBrBalGen:oPeriodo:aItems) .AND. oBrBalGen:lWhen ;
                OF oBar;
                FONT oFont

   oBrBalGen:oHasta:cToolTip:="F6: Calendario"

   @ 10+35+20, nLin+335 BUTTON oBrBalGen:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oBrBalGen:oPeriodo:nAt=LEN(oBrBalGen:oPeriodo:aItems);
               ACTION oBrBalGen:HACERWHERE(oBrBalGen:dDesde,oBrBalGen:dHasta,oBrBalGen:cWhere,.T.);
               WHEN oBrBalGen:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})


  @ 10+35+20,nLin+325+50 COMBOBOX oBrBalGen:oNumEje;
                   VAR oBrBalGen:cNumEje;
                   ITEMS oBrBalGen:aNumEje;
                   WHEN LEN(oBrBalGen:aNumEje)>1;
                   OF oBAR PIXEL SIZE 60,NIL;
                   ON CHANGE oBrBalGen:CAMBIAEJERCICIO() FONT oFont

  oBrBalGen:oNumEje:cMsg    :="Seleccione el Ejercicio"
  oBrBalGen:oNumEje:cToolTip:="Seleccione el Ejercicio"

  oBrBalGen:oNumEje:ForWhen(.T.)

  oBrBalGen:aBalance:={}
  AADD(oBrBalGen:aBalance,oDp:cCtaBg1)
  AADD(oBrBalGen:aBalance,oDp:cCtaBg2)
  AADD(oBrBalGen:aBalance,oDp:cCtaBg3)

  ADEPURA(oBrBalGen:aBalance,{|a,n| Empty(a)})

  AADD(oBrBalGen:aBalance," ")


  oBar:SetSize(NIL,80+15,.T.)

  FOR I=1 TO LEN(oBrBalGen:aBalance)

     @ 44+20,20+(35*(I-1))+0 BUTTON oBtn PROMPT oBrBalGen:aBalance[I] SIZE 27,24;
                           FONT oFont;
                           OF oBar;
                           PIXEL;
                           ACTION (1=1)

     oBtn:bAction:=BloqueCod([oBrBalGen:BUSCARLETRA(]+GetWhere("",oBrBalGen:aBalance[I])+[)])
     oBtn:CARGO:=oBrBalGen:aBalance[I]

     IF Empty(oBrBalGen:aBalance[I])

       oBtn:cToolTip:="Restaurar Todas las Cuentas"

     ELSE

       oBtn:cToolTip:=ALLTRIM(SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oBrBalGen:aBalance[I])))

     ENDIF

  NEXT I



RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

  oBrBalGen:VERBROWSE()

RETURN .T.


FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oBrBalGen:oPeriodo:nAt,cWhere,nAt,cAno,bAction:=oBrBalGen:oNumEje:bAction

  oBrBalGen:nPeriodo:=nPeriodo

  IF oBrBalGen:oPeriodo:nAt=LEN(oBrBalGen:oPeriodo:aItems)

     oBrBalGen:oDesde:ForWhen(.T.)
     oBrBalGen:oHasta:ForWhen(.T.)
     oBrBalGen:oBtn  :ForWhen(.T.)

     DPFOCUS(oBrBalGen:oDesde)

  ELSE

     oBrBalGen:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,oBrBalGen:dDesde,oBrBalGen:dDesde)

     oBrBalGen:oDesde:VarPut(oBrBalGen:aFechas[1] , .T. )
     oBrBalGen:oHasta:VarPut(oBrBalGen:aFechas[2] , .T. )

     oBrBalGen:dDesde:=oBrBalGen:aFechas[1]
     oBrBalGen:dHasta:=oBrBalGen:aFechas[2]

  ENDIF

  cAno:=STRZERO(YEAR(oBrBalGen:dDesde),4)
  nAt :=ASCAN(oBrBalGen:aNumEje,cAno)

  IF nAt>0 
     oBrBalGen:oNumEje:bAction:={||.T.}
     oBrBalGen:oNumEje:Select(nAt)
     oBrBalGen:oNumEje:bAction:=bAction
  ENDIF

  oBrBalGen:HACERWHERE(oBrBalGen:dDesde,oBrBalGen:dHasta)

  oBrBalGen:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   oDp:oCursor:=NIL

   oBrBalGen:HACERBALANCE(dDesde,dHasta,oBrBalGen)

RETURN cWhere

FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRWGANANCIAYP.MEM",V_nPeriodo:=oBrBalGen:nPeriodo
  LOCAL V_dDesde:=oBrBalGen:dDesde
  LOCAL V_dHasta:=oBrBalGen:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las B�quedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oBrBalGen)
RETURN .T.

/*
// Ejecuci�n Cambio de Linea 
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oBrBalGen")="O" .AND. oBrBalGen:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oBrBalGen:cWhere_),oBrBalGen:cWhere_,oBrBalGen:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oBrBalGen:LEERDATA(oBrBalGen:cWhere_,oBrBalGen:oBrw,oBrBalGen:cServer)
      oBrBalGen:oWnd:Show()
      oBrBalGen:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1 .AND. "Seg�n"$cOption
      RETURN oBrBalGen:EDITCBTE(.T.,.F.)
   ENDIF

   IF nOption=2 .AND. "Visua"$cOption
      RETURN oBrBalGen:EDITCBTE(.T.,.T.)
   ENDIF


RETURN .T.

FUNCTION HTMLHEAD()

   oBrBalGen:aHead:=EJECUTAR("HTMLHEAD",oBrBalGen)

RETURN

/*
// Visualizar Asientos
*/
FUNCTION EDITCBTE(lNumPar,lView)
  LOCAL cActual
  LOCAL cTipDoc:=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,1]
  LOCAL cCodigo:=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,2]
  LOCAL cNumero:=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,3]
  LOCAL dFecha :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,5]
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
    cWhereGrid:="MOC_NUMPAR"+GetWhere("=",oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,18])
//+" AND "+;
//                "MOC_DOCUME"+GetWhere("=",oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt,03])
  ENDIF

  EJECUTAR("DPCBTE",cActual,cNumero,dFecha,.F.,NIL,cWhereGrid)

RETURN .T.


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oBrBalGen)


FUNCTION CAMBIAEJERCICIO()

  oBrBalGen:dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_CODSUC"+GetWhere("=",oBrBalGen:cCodSuc)+" AND EJE_NUMERO"+GetWhere("=",oBrBalGen:cNumEje))
  oBrBalGen:dHasta:=DPSQLROW(2,CTOD(""))

  oBrBalGen:oDesde:Refresh(.T.)
  oBrBalGen:oHasta:Refresh(.T.)

  oDp:oCursor:=NIL

RETURN oBrBalGen:HACERBALANCE(oBrBalGen:dDesde,oBrBalGen:dHasta,oBrBalGen)


FUNCTION HACERBALANCE(dDesde,dHasta,oBrBalGen,oGenRep,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon)

  LOCAL oCursor,cCodPar,cServer,aLine,oBrw
  LOCAL oGenRep:=NIL
  
  LOCAL aData :={}

  DEFAULT  dDesde:=oDp:dFchInicio,;
           dHasta:=oDp:dFchCierre

  DEFAULT oDp:oCursor:=NIL

  RGO_C1:=dDesde
  RGO_C2:=dHasta

  IF ValType(oBrBalGen)="O"

     oBrw :=oBrBalGen:oBrw
     aLine:=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt]

     RGO_C3:=oBrBalGen:RGO_C3
     RGO_C4:=oBrBalGen:RGO_C4
     RGO_C6:=oBrBalGen:RGO_C6
     RGO_I1:=oBrBalGen:RGO_I1
     RGO_F1:=oBrBalGen:RGO_F1
     RGO_I2:=oBrBalGen:RGO_I2
     RGO_F2:=oBrBalGen:RGO_F2

  ENDIF
  
  oCursor:=EJECUTAR("GPCALCULAR",oGenRep,RGO_C1,RGO_C2,RGO_C3,RGO_C4,"GP",RGO_C6,RGO_C7,RGO_C8,RGO_C9,RGO_C10)

  aData  :=oBrBalGen:CREAR_GYP(oCursor)

  IF ValType(oBrw)="O" 

     aLine:=ACLONE(oBrw:aArrayData[1])

     IF Empty(aData)
        aData:={}
        AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(a)})
        AADD(aData,aLine)
     ENDIF

     oBrw:aArrayData:=ACLONE(aData)
     oBrw:nArrayAt:=1
     oBrw:nRowSel :=1
     oBrw:GoTop()
     oBrw:Refresh(.F.)

  ENDIF

RETURN aData

FUNCTION VERCTA()
  LOCAL aLine:=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt]

  EJECUTAR("DPCTACON",NIL,aLine[1])

RETURN .T.

FUNCTION VERBROWSE()
  LOCAL aLine  :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt]
  LOCAL cCodCta:=ALLTRIM(oBrBalGen:GETCTACON())
  LOCAL nLen   :=LEN(cCodCta)
  LOCAL cWhereL:="LEFT(MOC_CUENTA,"+LSTR(LEN(ALLTRIM(cCodCta)))+")"+GetWhere("=",ALLTRIM(cCodCta))
  LOCAL cActual:={"S","C","A"}
  LOCAL lDelete:=NIL,cCodMon:=oBrBalGen:cCodMon,lSldIni:=.T.
  LOCAL dDesdeA,dHastaA,nPeriodo:=10
  LOCAL dDesde  :=oBrBalGen:dDesde
  LOCAL dHasta  :=oBrBalGen:dHasta

  IF Empty(cCodCta) .OR. !ISSQLFIND("DPCTA","CTA_CODIGO"+GetWhere("=",cCodCta))
     RETURN .F.
  ENDIF
/*
  IF oBrBalGen:oBrw:nColSel=3
     // Buscamos el ejercicio Anterior
     dDesdeA:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_HASTA"+GetWhere("<",oBrBalGen:dDesde)+" ORDER BY EJE_HASTA DESC LIMIT 1")
     dHastaA:=DPSQLROW(2,dDesdeA)

     IF !Empty(dDesdeA)
        dDesde  :=dDesdeA
        dHasta  :=dHastaA
        nPeriodo:=11
     ENDIF

  ENDIF
*/
  EJECUTAR("BRDPASIENTOS","MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+cWhereL+" AND "+;
                          GetWhereOr("MOC_ACTUAL",cActual),NIL,nPeriodo,dDesde,dHasta,NIL,cCodCta,cActual,lDelete,cCodMon,lSldIni)


RETURN .T.

/*
// Imprimir Balance de Comprobaci�n
*/
FUNCTION PRINTBALGYP()
  LOCAL oRep:=REPORTE("GANANCIAYP")

  oRep:SetCriterio(1,oBrBalGen:dDesde)
  oRep:SetCriterio(2,oBrBalGen:dHasta)

RETURN .T.

FUNCTION MAYOR()
  LOCAL aLine  :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt]
  LOCAL cCodCta:=oBrBalGen:GETCTACON()
  LOCAL RGO_C1:=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=cCodCta,RGO_F1:=cCodCta,RGO_I2:=NIL,RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oBrBalGen:dDesde,oBrBalGen:dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)

FUNCTION BALCOM()
  LOCAL aLine  :=oBrBalGen:oBrw:aArrayData[oBrBalGen:oBrw:nArrayAt]
  LOCAL cCodCta:=oBrBalGen:GETCTACON()
  LOCAL oGenRep:=NIL
  LOCAL RGO_C1 :=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=cCodCta,RGO_F1:=cCodCta,RGO_I2:=NIL,RGO_F2:=NIL
  LOCAL cCtaD  :=RGO_I1
  LOCAL cCtaH  :=RGO_F1
  LOCAL nMaxCol:=NIL,cPicture:=NIL,cTextT:=NIL,cCecod:=NIL,cCecoh:=NIL

RETURN EJECUTAR("BRWCOMPROBACION",oGenRep,oBrBalGen:dDesde,oBrBalGen:dHasta,nMaxCol,cPicture,cTextT,cCecod,cCecoh,cCtaD,cCtaH)


FUNCTION GETCTACON()
  LOCAL nAt:=oBrBalGen:oBrw:nArrayAt,aLine:={},cCodCta:=""

  WHILE nAt>0 

    aLine:=oBrBalGen:oBrw:aArrayData[nAt]

    IF !Empty(aLine[1])
       EXIT
    ENDIF

    nAt  :=nAt-1

    IF nAt=0
      EXIT
    ENDIF

  ENDDO

  IF !Empty(aLine) 
     cCodCta:=aLine[1]
  ENDIF

//  IF !Empty(oBrMayor:RGO_I1) .AND. Empty(cCodCta)
//   cCodCta:=oBrMayor:RGO_I1
//ENDIF

RETURN ALLTRIM(cCodCta)



FUNCTION BUSCARLETRA(cLetra)
RETURN EJECUTAR("BRWBUSCARLETRA",cLetra,oBrBalGen:oBrw,1)
// EOF
