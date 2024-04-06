// Programa   : BRWGANANCIAYP
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
  LOCAL cTitle :="Estado de Resultado"
  LOCAL cWhere :=NIL
  LOCAL cNumEje
  LOCAL cServer,cCodPar,aTotal:={},aTotal1:={}
  LOCAL oCursor,aLine,cField
  LOCAL cCtaIng:=ALLTRIM(oDp:cCtaGp1)
  LOCAL cGp    :="GP"
  LOCAL cCenCos:="",cCodMon:="",cPorcen:=""

  IF Type("oBrBalGyP")="O" .AND. oBrBalGyP:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oBrBalGyP,GetScript())
  ENDIF
 
  DEFAULT dDesde:=oDp:dFchInicio,;
          dHasta:=oDp:dFchCierre

  DEFAULT RGO_C3:=4,;
          RGO_C4:="@E 99,999,999,999,999,999.99",;
          RGO_C6:=NIL,;
          RGO_I1:="",;
          RGO_F1:="",;
          RGO_I2:="",;
          RGO_F2:=""

// ? oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon

  aNumEje:=ATABLE(" SELECT EJE_NUMERO FROM DPEJERCICIOS "+;
                  " INNER JOIN DPCBTE ON CBT_CODSUC=EJE_CODSUC AND CBT_NUMEJE=EJE_NUMERO "+;
                  " WHERE EJE_CODSUC"+GetWhere("=",oDp:cSucursal)+" GROUP BY EJE_NUMERO ORDER BY EJE_NUMERO ")


  RGO_C1:=dDesde
  RGO_C2:=dHasta

  IF TYPE("RGO_C10")="C" .AND. !Empty(RGO_C10)
     cPorcen:=RGO_C10
  ENDIF

  IF TYPE("RGO_C11")<>"C"
     RGO_C11:=""
  ENDIF

  IF TYPE("RGO_C12")<>"C"
     RGO_C12:=""
  ENDIF

  IF TYPE("RGO_C13")<>"C"
     RGO_C13:=""
  ENDIF

  IF TYPE("RGO_C11")="C" .AND. !Empty(RGO_C11)
     cCodSuc:=RGO_C11
  ENDIF

  IF TYPE("RGO_C12")="C" .AND. !Empty(RGO_C12)
     cCenCos:=RGO_C12
  ENDIF

  IF TYPE("RGO_C13")="C" .AND. !Empty(RGO_C13)
     cCodMon:=RGO_C13
  ENDIF

  PUBLICO("RGO_C7","")

  IF Empty(RGO_C6)
     RGO_C6:="GP"
  ENDIF

  IF Empty(RGO_C10)
     RGO_C10:="N"
  ENDIF

  IF Empty(RGO_C7)
     RGO_C7:="Total"
  ENDIF

  IF Empty(RGO_C4)
     RGO_C4:="@E 99,999,999,999,999,999.99"
  ENDIF

  cNumEje:=EJECUTAR("GETNUMEJE",dDesde)

  aData  :=CREAR_GYP()

  IF Empty(aData)
     MensajeErr("Balance no Generado según Periodo "+DTOC(dDesde)+" "+DTOC(dHasta))
     RETURN {}
  ENDIF

  aTotal:=aData[LEN(aData)-1]

  ViewData(aData,cTitle,cWhere)

  oDp:aBalCom:=ACLONE(aData)

RETURN aData

FUNCTION CREAR_GYP(oCursor)
  LOCAL aData:={},aLine,cField,I

  DEFAULT oCursor:=EJECUTAR("GPCALCULAR",oGenRep,RGO_C1,RGO_C2,RGO_C3,RGO_C4,"GP",RGO_C6,RGO_C7,RGO_C8,RGO_C9,RGO_C10)

  IF !ValType(oCursor)="O"
     MensajeErr("Balance no Generado")
     RETURN {}
  ENDIF

  oCursor:GoTop()

  WHILE !oCursor:EOF()

     aLine:={oCursor:CTA_CODIGO,oCursor:TITULO}

     FOR I=1 TO RGO_C3

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

   DpMdi(cTitle,"oBrBalGyP","BRWGANANCIAYP.EDT")
   oBrBalGyP:Windows(0,0,aCoors[3]-10,aCoors[4]-10,.T.) // Maximizado

   oBrBalGyP:cCodSuc  :=cCodSuc
   oBrBalGyP:lMsgBar  :=.F.
   oBrBalGyP:cPeriodo :=aPeriodos[nPeriodo]
   oBrBalGyP:cCodSuc  :=cCodSuc
   oBrBalGyP:nPeriodo :=nPeriodo
   oBrBalGyP:cNombre  :=""
   oBrBalGyP:dDesde   :=dDesde
   oBrBalGyP:cServer  :=cServer
   oBrBalGyP:dHasta   :=dHasta
   oBrBalGyP:cWhere   :=cWhere
   oBrBalGyP:cWhere_  :=cWhere_
   oBrBalGyP:cWhereQry:=""
   oBrBalGyP:cSql     :=oDp:cSql
   oBrBalGyP:oWhere   :=TWHERE():New(oBrBalGyP)
   oBrBalGyP:cCodPar  :=cCodPar // Código del Parámetro
   oBrBalGyP:lWhen    :=.T.
   oBrBalGyP:cTextTit :="" // Texto del Titulo Heredado
   oBrBalGyP:oDb     :=oDp:oDb
   oBrBalGyP:cBrwCod  :=""
   oBrBalGyP:lTmdi    :=.T.
   oBrBalGyP:aNumEje  :=ACLONE(aNumEje)
   oBrBalGyP:cNumEje  :=cNumEje
   oBrBalGyP:cCodMon  :=cCodMon
   oBrBalGyP:cCtaIng  :=cCtaIng

   oBrBalGyP:cGp    :=cGp

   oBrBalGyP:RGO_C1 :=RGO_C1
   oBrBalGyP:RGO_C2 :=RGO_C2
   oBrBalGyP:RGO_C3 :=RGO_C3
   oBrBalGyP:RGO_C4 :=RGO_C4
   oBrBalGyP:RGO_C5 :=RGO_C5
   oBrBalGyP:RGO_C6 :=RGO_C6
   oBrBalGyP:RGO_C7 :=RGO_C7
   oBrBalGyP:RGO_C8 :=RGO_C8
   oBrBalGyP:RGO_C9 :=RGO_C9
   oBrBalGyP:RGO_C10:=RGO_C10
   oBrBalGyP:RGO_C11:=RGO_C11
   oBrBalGyP:RGO_C12:=RGO_C12
   oBrBalGyP:RGO_C13:=RGO_C13

   oBrBalGyP:RGO_I1:=RGO_I1
   oBrBalGyP:RGO_F1:=RGO_F1
   oBrBalGyP:RGO_I2:=RGO_I2
   oBrBalGyP:RGO_F2:=RGO_F2

   oBrBalGyP:oGenRep:=oGenRep

// oGenRep,RGO_C1,RGO_C2,RGO_C3,RGO_C4,"GP",RGO_C6,RGO_C7,RGO_C8,RGO_C9,RGO_C10

   oBrBalGyP:oBrw:=TXBrowse():New( IF(oBrBalGyP:lTmdi,oBrBalGyP:oWnd,oBrBalGyP:oDlg ))
   oBrBalGyP:oBrw:SetArray( aData, .F. )
   oBrBalGyP:oBrw:SetFont(oFont)

   oBrBalGyP:oBrw:lFooter     := .T.
   oBrBalGyP:oBrw:lHScroll    := .F.
   oBrBalGyP:oBrw:nHeaderLines:= 2
   oBrBalGyP:oBrw:nDataLines  := 1
   oBrBalGyP:oBrw:nFooterLines:= 1

   oBrBalGyP:aData            :=ACLONE(aData)
   oBrBalGyP:nClrText :=0
   oBrBalGyP:nClrPane1:=oDp:nClrPane1
   oBrBalGyP:nClrPane2:=oDp:nClrPane2

   oBrBalGyP:nClrPane3:=CLR_HRED
   oBrBalGyP:nClrPane4:=CLR_HBLUE
   oBrBalGyP:nClrPane5:=4227072



   AEVAL(oBrBalGyP:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oBrBalGyP:oBrw:aCols[1]
   oCol:cHeader      :='Cuenta'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGyP:oBrw:aArrayData ) } 
   oCol:nWidth       := 110

   oCol:=oBrBalGyP:oBrw:aCols[2]
   oCol:cHeader      :='Descripción'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGyP:oBrw:aArrayData ) } 
   oCol:nWidth       :=280

   oCol:=oBrBalGyP:oBrw:aCols[3]
   oCol:cHeader      :='Nivel'+CRLF+'(1)'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGyP:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
//   oCol:cFooter      :=aTotal[3]
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGyP:oBrw,;
                                              cCuenta :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGyP:cCtaIng=LEFT(cCuenta,1),oBrBalGyP:nClrText,oBrBalGyP:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGyP:nClrPane1,oBrBalGyP:nClrPane2 ) } }

   oCol:=oBrBalGyP:oBrw:aCols[4]
   oCol:cHeader      :='Nivel'+CRLF+"(2)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGyP:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGyP:oBrw,;
                                              cCuenta :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGyP:cCtaIng=LEFT(cCuenta,1),oBrBalGyP:nClrText,oBrBalGyP:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGyP:nClrPane1,oBrBalGyP:nClrPane2 ) } }


   oCol:=oBrBalGyP:oBrw:aCols[5]
   oCol:cHeader      :='Nivel'+CRLF+"(3)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGyP:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'

   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGyP:oBrw,;
                                              cCuenta :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGyP:cCtaIng=LEFT(cCuenta,1),oBrBalGyP:nClrText,oBrBalGyP:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGyP:nClrPane1,oBrBalGyP:nClrPane2 ) } }



   oCol:=oBrBalGyP:oBrw:aCols[6]
   oCol:cHeader      :='Nivel'+CRLF+"(4)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGyP:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGyP:oBrw,;
                                              cCuenta :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGyP:cCtaIng=LEFT(cCuenta,1),oBrBalGyP:nClrText,oBrBalGyP:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGyP:nClrPane1,oBrBalGyP:nClrPane2 ) } }

IF LEN(oBrBalGyP:oBrw:aCols)>6

   oCol:=oBrBalGyP:oBrw:aCols[7]
   oCol:cHeader      :='Nivel'+CRLF+"(5)"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrBalGyP:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='999,999,999,999.99'
   oCol:bClrStd      :={|oBrw,nClrText,cCuenta|oBrw   :=oBrBalGyP:oBrw,;
                                              cCuenta :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,1],;
                                              nClrText:=IF(!oBrBalGyP:cCtaIng=LEFT(cCuenta,1),oBrBalGyP:nClrText,oBrBalGyP:nClrPane3),;
                        {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGyP:nClrPane1,oBrBalGyP:nClrPane2 ) } }

ENDIF

  oCol:cFooter      :=FDP(oDp:nUtilidad,"999,999,999,999,999,999.99")


   oCol:oHeaderFont:=oFontB
   oCol:oDataFont  :=oFontB

   oBrBalGyP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oBrBalGyP:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oBrBalGyP:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oBrBalGyP:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oBrBalGyP:nClrPane1, oBrBalGyP:nClrPane2 ) } }

   oBrBalGyP:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrBalGyP:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrBalGyP:oBrw:bLDblClick:={|oBrw|oBrBalGyP:RUNCLICK() }

   oBrBalGyP:oBrw:bChange:={||oBrBalGyP:BRWCHANGE()}
   oBrBalGyP:oBrw:CreateFromCode()
   oBrBalGyP:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBrBalGyP)}
   oBrBalGyP:BRWRESTOREPAR()

   oBrBalGyP:oWnd:oClient := oBrBalGyP:oBrw

   oBrBalGyP:Activate({||oBrBalGyP:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBrBalGyP:lTmdi,oBrBalGyP:oWnd,oBrBalGyP:oDlg)
   LOCAL nLin:=0,I
   LOCAL nWidth:=oBrBalGyP:oBrw:nWidth()

   oBrBalGyP:oBrw:GoBottom(.T.)
   oBrBalGyP:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD


 // Emanager no Incluye consulta de Vinculos

/*
   oBrBalGyP:oFontBtn   :=oFont    
   oBrBalGyP:nClrPaneBar:=oDp:nGris
   oBrBalGyP:oBrw:oLbx  :=oBrBalGyP

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Ejecutar"; 
          ACTION  oBrBalGyP:GPCALCULAR()

   oBrBalGyP:oBtn:=oBtn:bAction
 
   oBtn:cToolTip:="Ejecutar Balance"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIDAD.BMP";
          TOP PROMPT "Cuenta"; 
          ACTION oBrBalGyP:VERCTA()

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
          ACTION oBrBalGyP:MAYOR()

   oBtn:cToolTip:="Mayor Analítico"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\balancecomprobacion.bmp";
          TOP PROMPT "Balance"; 
          ACTION oBrBalGyP:BALCOM()

   oBtn:cToolTip:="Balance de Comprobación"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          TOP PROMPT "Asientos"; 
          ACTION  oBrBalGyP:VERBROWSE()

   oBtn:cToolTip:="Ver Asientos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  oBrBalGyP:PRINTBALGYP()

   oBtn:cToolTip:="Imprimir Ganancias y Pérdidas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oBrBalGyP:oWnd:IsZoomed(),oBrBalGyP:oWnd:Restore(),oBrBalGyP:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oBrBalGyP:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBrBalGyP:oBrw,oBrBalGyP);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oBrBalGyP:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION  EJECUTAR("BRWSETOPTIONS",oBrBalGyP:oBrw);
          WHEN LEN(oBrBalGyP:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

/*
      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             MENU EJECUTAR("BRBTNMENU",{"Opción1","Opción"},"oFrm");
             FILENAME "BITMAPS\MENU.BMP";
               TOP PROMPT "Menú"; 
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
           ACTION  oBrBalGyP:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.bmp";
          MENU EJECUTAR("BRBTNMENU",{"Según Partida","Visualizar Asientos"},"oBrBalGyP");
          ACTION oBrBalGyP:EDITCBTE()

  oBtn:cToolTip:="Editar Comprobante"




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal"; 
          ACTION  EJECUTAR("BRWTODBF",oBrBalGyP)

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
              ACTION  (EJECUTAR("BRWTOEXCEL",oBrBalGyP:oBrw,oBrBalGyP:cTitle,oBrBalGyP:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBrBalGyP:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oBrBalGyP:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBrBalGyP:oBrw,NIL,oBrBalGyP:cTitle,oBrBalGyP:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBrBalGyP:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oBrBalGyP:oBrw))

   oBtn:cToolTip:="Previsualización"

   oBrBalGyP:oBtnPreview:=oBtn

ENDIF


IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBrBalGyP:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oBrBalGyP:oBrw:GoTop(),oBrBalGyP:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oBrBalGyP:oBrw:PageDown(),oBrBalGyP:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oBrBalGyP:oBrw:PageUp(),oBrBalGyP:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oBrBalGyP:oBrw:GoBottom(),oBrBalGyP:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oBrBalGyP:Close()

  oBrBalGyP:oBrw:SetColor(0,oBrBalGyP:nClrPane1)

  EVAL(oBrBalGyP:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBrBalGyP:oBar:=oBar

  nLin:=490-90

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  nLin:=nLin-460
  //
  // Campo : Periodo
  //

  @ 10+35+20, nLin COMBOBOX oBrBalGyP:oPeriodo;
             VAR oBrBalGyP:cPeriodo ITEMS aPeriodos;
             SIZE 100,200;
             PIXEL;
             OF oBar;
             FONT oFont;
             ON CHANGE oBrBalGyP:LEEFECHAS();
             WHEN oBrBalGyP:lWhen 

  ComboIni(oBrBalGyP:oPeriodo )

//oBrBalGyP:oPeriodo:bWhen:={||.F.}
  oBrBalGyP:oPeriodo:ForWhen(.T.)


  @ 10+35+20, nLin+103 BUTTON oBrBalGyP:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalGyP:oPeriodo:nAt,oBrBalGyP:oDesde,oBrBalGyP:oHasta,-1),;
                         oBrBalGyP:LEEFECHAS());
                WHEN oBrBalGyP:lWhen 


  @ 10+35+20, nLin+130 BUTTON oBrBalGyP:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrBalGyP:oPeriodo:nAt,oBrBalGyP:oDesde,oBrBalGyP:oHasta,+1),;
                         oBrBalGyP:LEEFECHAS());
                WHEN oBrBalGyP:lWhen 

 

  @ 10+35+20, nLin+170 BMPGET oBrBalGyP:oDesde  VAR oBrBalGyP:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalGyP:oDesde ,oBrBalGyP:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oBrBalGyP:oPeriodo:nAt=LEN(oBrBalGyP:oPeriodo:aItems) .AND. oBrBalGyP:lWhen ;
                FONT oFont

   oBrBalGyP:oDesde:cToolTip:="F6: Calendario"

  @ 10+35+20, nLin+252 BMPGET oBrBalGyP:oHasta  VAR oBrBalGyP:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrBalGyP:oHasta,oBrBalGyP:dHasta);
                SIZE 80,23;
                WHEN oBrBalGyP:oPeriodo:nAt=LEN(oBrBalGyP:oPeriodo:aItems) .AND. oBrBalGyP:lWhen ;
                OF oBar;
                FONT oFont

   oBrBalGyP:oHasta:cToolTip:="F6: Calendario"

   @ 10+35+20, nLin+335 BUTTON oBrBalGyP:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oBrBalGyP:oPeriodo:nAt=LEN(oBrBalGyP:oPeriodo:aItems);
               ACTION oBrBalGyP:HACERWHERE(oBrBalGyP:dDesde,oBrBalGyP:dHasta,oBrBalGyP:cWhere,.T.);
               WHEN oBrBalGyP:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})


  @ 10+35+20,nLin+325+50 COMBOBOX oBrBalGyP:oNumEje;
                   VAR oBrBalGyP:cNumEje;
                   ITEMS oBrBalGyP:aNumEje;
                   WHEN LEN(oBrBalGyP:aNumEje)>1;
                   OF oBAR PIXEL SIZE 60,NIL;
                   ON CHANGE oBrBalGyP:CAMBIAEJERCICIO() FONT oFont

  oBrBalGyP:oNumEje:cMsg    :="Seleccione el Ejercicio"
  oBrBalGyP:oNumEje:cToolTip:="Seleccione el Ejercicio"

  oBrBalGyP:oNumEje:ForWhen(.T.)

  oBrBalGyP:aBalance:={}
  AADD(oBrBalGyP:aBalance,oDp:cCtaGp1)
  AADD(oBrBalGyP:aBalance,oDp:cCtaGp2)
  AADD(oBrBalGyP:aBalance,oDp:cCtaGp3)
  AADD(oBrBalGyP:aBalance,oDp:cCtaGp4)
  AADD(oBrBalGyP:aBalance,oDp:cCtaGp5)
  AADD(oBrBalGyP:aBalance,oDp:cCtaGp6)

  ADEPURA(oBrBalGyP:aBalance,{|a,n| Empty(a)})

  AADD(oBrBalGyP:aBalance," ")


  oBar:SetSize(NIL,80+15,.T.)

  FOR I=1 TO LEN(oBrBalGyP:aBalance)

     @ 44+20,20+(35*(I-1))+0 BUTTON oBtn PROMPT oBrBalGyP:aBalance[I] SIZE 27,24;
                           FONT oFont;
                           OF oBar;
                           PIXEL;
                           ACTION (1=1)

     oBtn:bAction:=BloqueCod([oBrBalGyP:BUSCARLETRA(]+GetWhere("",oBrBalGyP:aBalance[I])+[)])
     oBtn:CARGO:=oBrBalGyP:aBalance[I]

     IF Empty(oBrBalGyP:aBalance[I])

       oBtn:cToolTip:="Restaurar Todas las Cuentas"

     ELSE

       oBtn:cToolTip:=ALLTRIM(SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oBrBalGyP:aBalance[I])))

     ENDIF

  NEXT I



RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

  oBrBalGyP:VERBROWSE()

RETURN .T.


FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oBrBalGyP:oPeriodo:nAt,cWhere,nAt,cAno,bAction:=oBrBalGyP:oNumEje:bAction

  oBrBalGyP:nPeriodo:=nPeriodo

  IF oBrBalGyP:oPeriodo:nAt=LEN(oBrBalGyP:oPeriodo:aItems)

     oBrBalGyP:oDesde:ForWhen(.T.)
     oBrBalGyP:oHasta:ForWhen(.T.)
     oBrBalGyP:oBtn  :ForWhen(.T.)

     DPFOCUS(oBrBalGyP:oDesde)

  ELSE

     oBrBalGyP:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,oBrBalGyP:dDesde,oBrBalGyP:dDesde)

     oBrBalGyP:oDesde:VarPut(oBrBalGyP:aFechas[1] , .T. )
     oBrBalGyP:oHasta:VarPut(oBrBalGyP:aFechas[2] , .T. )

     oBrBalGyP:dDesde:=oBrBalGyP:aFechas[1]
     oBrBalGyP:dHasta:=oBrBalGyP:aFechas[2]

  ENDIF

  cAno:=STRZERO(YEAR(oBrBalGyP:dDesde),4)
  nAt :=ASCAN(oBrBalGyP:aNumEje,cAno)

  IF nAt>0 
     oBrBalGyP:oNumEje:bAction:={||.T.}
     oBrBalGyP:oNumEje:Select(nAt)
     oBrBalGyP:oNumEje:bAction:=bAction
  ENDIF

  oBrBalGyP:HACERWHERE(oBrBalGyP:dDesde,oBrBalGyP:dHasta)

  oBrBalGyP:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   oDp:oCursor:=NIL

   oBrBalGyP:HACERBALANCE(dDesde,dHasta,oBrBalGyP)

RETURN cWhere

FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRWGANANCIAYP.MEM",V_nPeriodo:=oBrBalGyP:nPeriodo
  LOCAL V_dDesde:=oBrBalGyP:dDesde
  LOCAL V_dHasta:=oBrBalGyP:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oBrBalGyP)
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


    IF Type("oBrBalGyP")="O" .AND. oBrBalGyP:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oBrBalGyP:cWhere_),oBrBalGyP:cWhere_,oBrBalGyP:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oBrBalGyP:LEERDATA(oBrBalGyP:cWhere_,oBrBalGyP:oBrw,oBrBalGyP:cServer)
      oBrBalGyP:oWnd:Show()
      oBrBalGyP:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1 .AND. "Según"$cOption
      RETURN oBrBalGyP:EDITCBTE(.T.,.F.)
   ENDIF

   IF nOption=2 .AND. "Visua"$cOption
      RETURN oBrBalGyP:EDITCBTE(.T.,.T.)
   ENDIF


RETURN .T.

FUNCTION HTMLHEAD()

   oBrBalGyP:aHead:=EJECUTAR("HTMLHEAD",oBrBalGyP)

RETURN

/*
// Visualizar Asientos
*/
FUNCTION EDITCBTE(lNumPar,lView)
  LOCAL cActual
  LOCAL cTipDoc:=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,1]
  LOCAL cCodigo:=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,2]
  LOCAL cNumero:=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,3]
  LOCAL dFecha :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,5]
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
    cWhereGrid:="MOC_NUMPAR"+GetWhere("=",oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,18])
//+" AND "+;
//                "MOC_DOCUME"+GetWhere("=",oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt,03])
  ENDIF

  EJECUTAR("DPCBTE",cActual,cNumero,dFecha,.F.,NIL,cWhereGrid)

RETURN .T.


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oBrBalGyP)


FUNCTION CAMBIAEJERCICIO()

  oBrBalGyP:dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_CODSUC"+GetWhere("=",oBrBalGyP:cCodSuc)+" AND EJE_NUMERO"+GetWhere("=",oBrBalGyP:cNumEje))
  oBrBalGyP:dHasta:=DPSQLROW(2,CTOD(""))

  oBrBalGyP:oDesde:Refresh(.T.)
  oBrBalGyP:oHasta:Refresh(.T.)

  oDp:oCursor:=NIL

RETURN oBrBalGyP:HACERBALANCE(oBrBalGyP:dDesde,oBrBalGyP:dHasta,oBrBalGyP)


FUNCTION HACERBALANCE(dDesde,dHasta,oBrBalGyP,oGenRep,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon)

  LOCAL oCursor,cCodPar,cServer,aLine,oBrw
  LOCAL oGenRep:=NIL
  
  LOCAL aData :={}

  DEFAULT  dDesde:=oDp:dFchInicio,;
           dHasta:=oDp:dFchCierre

  DEFAULT oDp:oCursor:=NIL

  RGO_C1:=dDesde
  RGO_C2:=dHasta

  IF ValType(oBrBalGyP)="O"

     oBrw :=oBrBalGyP:oBrw
     aLine:=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt]

     RGO_C3:=oBrBalGyP:RGO_C3
     RGO_C4:=oBrBalGyP:RGO_C4
     RGO_C6:=oBrBalGyP:RGO_C6
     RGO_I1:=oBrBalGyP:RGO_I1
     RGO_F1:=oBrBalGyP:RGO_F1
     RGO_I2:=oBrBalGyP:RGO_I2
     RGO_F2:=oBrBalGyP:RGO_F2

  ENDIF
  
  oCursor:=EJECUTAR("GPCALCULAR",oGenRep,RGO_C1,RGO_C2,RGO_C3,RGO_C4,"GP",RGO_C6,RGO_C7,RGO_C8,RGO_C9,RGO_C10)

  aData  :=oBrBalGyP:CREAR_GYP(oCursor)

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
  LOCAL aLine:=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt]

  EJECUTAR("DPCTACON",NIL,aLine[1])

RETURN .T.

FUNCTION VERBROWSE()
  LOCAL aLine  :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt]
  LOCAL cCodCta:=ALLTRIM(oBrBalGyP:GETCTACON())
  LOCAL nLen   :=LEN(cCodCta)
  LOCAL cWhereL:="LEFT(MOC_CUENTA,"+LSTR(LEN(ALLTRIM(cCodCta)))+")"+GetWhere("=",ALLTRIM(cCodCta))
  LOCAL cActual:={"S","C","A"}
  LOCAL lDelete:=NIL,cCodMon:=oBrBalGyP:cCodMon,lSldIni:=.T.
  LOCAL dDesdeA,dHastaA,nPeriodo:=10
  LOCAL dDesde  :=oBrBalGyP:dDesde
  LOCAL dHasta  :=oBrBalGyP:dHasta

  IF Empty(cCodCta) .OR. !ISSQLFIND("DPCTA","CTA_CODIGO"+GetWhere("=",cCodCta))
     RETURN .F.
  ENDIF
/*
  IF oBrBalGyP:oBrw:nColSel=3
     // Buscamos el ejercicio Anterior
     dDesdeA:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_HASTA"+GetWhere("<",oBrBalGyP:dDesde)+" ORDER BY EJE_HASTA DESC LIMIT 1")
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
// Imprimir Balance de Comprobación
*/
FUNCTION PRINTBALGYP()
  LOCAL oRep:=REPORTE("GANANCIAYP")

  oRep:SetCriterio(1,oBrBalGyP:dDesde)
  oRep:SetCriterio(2,oBrBalGyP:dHasta)

RETURN .T.

FUNCTION MAYOR()
  LOCAL aLine  :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt]
  LOCAL cCodCta:=oBrBalGyP:GETCTACON()
  LOCAL RGO_C1:=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=cCodCta,RGO_F1:=cCodCta,RGO_I2:=NIL,RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oBrBalGyP:dDesde,oBrBalGyP:dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)

FUNCTION BALCOM()
  LOCAL aLine  :=oBrBalGyP:oBrw:aArrayData[oBrBalGyP:oBrw:nArrayAt]
  LOCAL cCodCta:=oBrBalGyP:GETCTACON()
  LOCAL oGenRep:=NIL
  LOCAL RGO_C1 :=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=cCodCta,RGO_F1:=cCodCta,RGO_I2:=NIL,RGO_F2:=NIL
  LOCAL cCtaD  :=RGO_I1
  LOCAL cCtaH  :=RGO_F1
  LOCAL nMaxCol:=NIL,cPicture:=NIL,cTextT:=NIL,cCecod:=NIL,cCecoh:=NIL

RETURN EJECUTAR("BRWCOMPROBACION",oGenRep,oBrBalGyP:dDesde,oBrBalGyP:dHasta,nMaxCol,cPicture,cTextT,cCecod,cCecoh,cCtaD,cCtaH)


FUNCTION GETCTACON()
  LOCAL nAt:=oBrBalGyP:oBrw:nArrayAt,aLine:={},cCodCta:=""

  WHILE nAt>0 

    aLine:=oBrBalGyP:oBrw:aArrayData[nAt]

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
RETURN EJECUTAR("BRWBUSCARLETRA",cLetra,oBrBalGyP:oBrw,1)
// EOF
