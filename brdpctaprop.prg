// Programa   : BRDPCTAPROP
// Fecha/Hora : 29/10/2014 18:09:52
// Propósito  : "Propiedades de las Cuentas"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,aCodCta)
   LOCAL aData,aFechas,cFileMem:="USER\BRDPCTAPROP.MEM",V_nPeriodo:=4,cCodPar,I
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer  :=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aPropB   :={}
   LOCAL aPropG   :={}
   LOCAL aCtas    :={oDp:cCtaBg1,oDp:cCtaBg2,oDp:cCtaBg3,oDp:cCtaBg4,oDp:cCtaGp1,oDp:cCtaGp2,oDp:cCtaGp3,oDp:cCtaGp4,oDp:cCtaGp5,oDp:cCtaGp6}
   LOCAL cWhereCta:="",aCtaCod:={},aCtaCombo:={}

   ADEPURA(aCtas,{|a,n| Empty(a)})

   IF Empty(aCtas)
      MensajeErr("Es Necesario Definir las Cuentas para Balances")
      EJECUTAR("DPCTAUSO")
      RETURN .T.
   ENDIF

   // Solo las Cuentas Definidas para su Utilización

   FOR I=1 TO LEN(aCtas)
      aCtas[I]:=ALLTRIM(aCtas[I])
      cWhereCta:=cWhereCta+ IIF(Empty(cWhereCta),""," OR ")+;
                 "LEFT(CTA_CODIGO,"+LSTR(LEN(aCtas[I]))+")"+GetWhere("=",aCtas[I])
   NEXT I

   oDp:cRunServer:=NIL

   IF COUNT("DPCTA","CTA_CTADET=1")=COUNT("DPCTA","CTA_CTADET=0")
      MsgRun("Asignado Cuentas de Asiento","Procesando",{||EJECUTAR("SETDPCTADET",NIL,.T.)})
   ENDIF

   EJECUTAR("DPCTAPROPIEDAD")
// EJECUTAR("SETDPCTADET") 

   AEVAL(oDp:aUtiliz,{|a,n| IIF(a[2]="B",AADD(aPropB,a[1]),NIL)})
   AEVAL(oDp:aUtiliz,{|a,n| IIF(a[2]="R",AADD(aPropG,a[1]),NIL)})

   ADEPURA(aPropB,{|a,n|Empty(a)})
   ADEPURA(aPropG,{|a,n|Empty(a)})

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SDB_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   AEVAL(aCtas,{|a,n| AADD(aCtaCod,{a,SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",a))})})

   ADEPURA(aCtas,{|a,n| Empty(a[2])})
   AEVAL(aCtaCod,{|a,n|AADD(aCtaCombo,a[2])})
   AADD(aCtaCombo,"Todas")

   cTitle:="Propiedades de las Cuentas" +IF(Empty(cTitle),"",cTitle)+" "+oDp:cCtaMod

   oDp:oFrm:=NIL

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4 

   // Obtiene el Código del Parámetro

   IF !Empty(aCodCta)
      cWhereCta:=GetWhereOr("CTA_CODIGO",aCodCta)
   ENDIF

   cWhere:=IIF(Empty(cWhere),""," AND ")+cWhereCta

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

// ViewArray(aData)
//return 

   ViewData(aData,cTitle)

   oDp:oFrm:=oDPCTAPROP
            
RETURN .T. 

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oDPCTAPROP","BRDPCTAPROP.EDT")

   oDPCTAPROP:Windows(0,0,aCoors[3]-160,MIN(1160,aCoors[4]-10),.T.) // Maximizado

   oDPCTAPROP:cCodSuc  :=cCodSuc
   oDPCTAPROP:lMsgBar  :=.F.
   oDPCTAPROP:cPeriodo :=aPeriodos[nPeriodo]
   oDPCTAPROP:cCodSuc  :=cCodSuc
   oDPCTAPROP:nPeriodo :=nPeriodo
   oDPCTAPROP:cNombre  :=""
   oDPCTAPROP:dDesde   :=dDesde
   oDPCTAPROP:cServer  :=cServer
   oDPCTAPROP:dHasta   :=dHasta
   oDPCTAPROP:cWhere   :=cWhere
   oDPCTAPROP:cWhere_  :=""
   oDPCTAPROP:cWhereQry:=""
   oDPCTAPROP:cSql     :=oDp:cSql
   oDPCTAPROP:oWhere   :=TWHERE():New(oDPCTAPROP)
   oDPCTAPROP:cCodPar  :=cCodPar // Código del Parámetro
   oDPCTAPROP:aPropB   :=ACLONE(aPropB)
   oDPCTAPROP:aPropG   :=ACLONE(aPropG)
   oDPCTAPROP:cBuscar1 :=SPACE(70)
   oDPCTAPROP:cBuscar2 :=SPACE(70)
   oDPCTAPROP:aCtaBg   :={oDp:cCtaBg1,oDp:cCtaBg2,oDp:cCtaBg3,oDp:cCtaBg4}
   oDPCTAPROP:aCtaGp   :={oDp:cCtaGp1,oDp:cCtaGp2,oDp:cCtaGp3,oDp:cCtaGp4,oDp:cCtaGp5,oDp:cCtaGp6}
   oDPCTAPROP:aCtaCod  :=aCtaCod
   oDPCTAPROP:aCtaCombo:=aCtaCombo
   oDPCTAPROP:cCodigo  :=ATAIL(aCtaCombo)
   oDPCTAPROP:nAsientos:=7

   ADEPURA(oDPCTAPROP:aCtaBg,{|a,n|Empty(a)})
   ADEPURA(oDPCTAPROP:aCtaGp,{|a,n|Empty(a)})

   oDPCTAPROP:oBrw:=TXBrowse():New( oDPCTAPROP:oDlg )
   oDPCTAPROP:oBrw:SetArray( aData, .F. )
   oDPCTAPROP:oBrw:SetFont(oFont)

   oDPCTAPROP:oBrw:lFooter     := .T.
   oDPCTAPROP:oBrw:lHScroll    := .T.
   oDPCTAPROP:oBrw:nHeaderLines:= 2
   oDPCTAPROP:oBrw:nDataLines  := 1
   oDPCTAPROP:oBrw:nFooterLines:= 1

   oDPCTAPROP:aData            :=ACLONE(aData)
   oDPCTAPROP:nClrText :=5197647
   oDPCTAPROP:nClrText1:=CLR_HBLUE
   oDPCTAPROP:nClrText2:=5197647
   oDPCTAPROP:nClrText3:=CLR_GREEN

   oDPCTAPROP:nClrPane1:=oDp:nClrPane1
   oDPCTAPROP:nClrPane2:=oDp:nClrPane2 // 13565951

   AEVAL(oDPCTAPROP:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   
   oCol:=oDPCTAPROP:oBrw:aCols[1]
   oCol:cHeader      :='Código'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPCTAPROP:oBrw:aArrayData ) } 
   oCol:nWidth       := 160
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue|oDPCTAPROP:PUTVALOR(oCol,uValue,1,NIL,NIL,"CTA_CODIGO")}

   oCol:=oDPCTAPROP:oBrw:aCols[2]
   oCol:cHeader      :='Descripción'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPCTAPROP:oBrw:aArrayData ) } 
   oCol:nWidth       := 320
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue|oDPCTAPROP:PUTVALOR(oCol,uValue,2,NIL,NIL,"CTA_DESCRI")}

   oCol:=oDPCTAPROP:oBrw:aCols[3]
   oCol:cHeader      :='Propiedad'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPCTAPROP:oBrw:aArrayData ) } 
   oCol:nWidth       := 140
   oCol:oFont        :=oFontB
   oCol:bOnPostEdit  :={|oCol,uValue|oDPCTAPROP:CTAGUARDAR(oCol,uValue)}


   oCol:=oDPCTAPROP:oBrw:aCols[4]
   oCol:cHeader      :='Ret'+CRLF+"ISLR"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPCTAPROP:oBrw:aArrayData ) } 
   oCol:nWidth       := 60
   oCol:oFont        :=oFontB

   oCol:=oDPCTAPROP:oBrw:aCols[5]
   oCol:cHeader      :='Descripción'+CRLF+"Retención"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPCTAPROP:oBrw:aArrayData ) } 
   oCol:nWidth       := 190
   oCol:oFont        :=oFontB

   oCol:=oDPCTAPROP:oBrw:aCols[6]
   oCol:cHeader      :='DPJ26'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPCTAPROP:oBrw:aArrayData ) } 
   oCol:nWidth       := 60
   oCol:oFont        :=oFontB
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 

   oCol:=oDPCTAPROP:oBrw:aCols[7]
   oCol:cHeader      :='Cód'+CRLF+"Int."
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPCTAPROP:oBrw:aArrayData ) } 
   oCol:nWidth       := 90
   oCol:oFont        :=oFontB
//   oCol:nDataStrAlign:= AL_RIGHT 
//   oCol:nHeadStrAlign:= AL_RIGHT 
//   oCol:nFootStrAlign:= AL_RIGHT 


   oCol:=oDPCTAPROP:oBrw:aCols[8]
   oCol:cHeader      :='Acepta'+CRLF+'Asientos'
   oCol:nWidth       := 65
   oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
   oCol:AddBmpFile("BITMAPS\checkverde.bmp")
   oCol:bBmpData    := { |oBrw|oBrw:=oDPCTAPROP:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,8],1,2) }
   oCol:bStrData:={||""}


   oDPCTAPROP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

/*
   oDPCTAPROP:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDPCTAPROP:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=IIF(oBrw:aArrayData[oBrw:nArrayAt,8],CLR_HBLUE,5197647),;
                                           nClrText:=IIF(!Empty(oBrw:aArrayData[oBrw:nArrayAt,3]),CLR_GREEN,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDPCTAPROP:nClrPane1, oDPCTAPROP:nClrPane2 ) } }
*/


   oDPCTAPROP:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDPCTAPROP:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=IIF(oBrw:aArrayData[oBrw:nArrayAt,8],oDPCTAPROP:nClrText1,oDPCTAPROP:nClrText2),;
                                           nClrText:=IIF(!Empty(oBrw:aArrayData[oBrw:nArrayAt,3]),oDPCTAPROP:nClrText3,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDPCTAPROP:nClrPane1, oDPCTAPROP:nClrPane2 ) } }


   oDPCTAPROP:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDPCTAPROP:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oDPCTAPROP:oBrw:bLDblClick:={||oDPCTAPROP:RUNCLICK() }

   oDPCTAPROP:oBrw:bChange:={||oDPCTAPROP:BRWCHANGE()}
   oDPCTAPROP:oBrw:CreateFromCode()
    oDPCTAPROP:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDPCTAPROP)}
    oDPCTAPROP:BRWRESTOREPAR()
   oDPCTAPROP:oBrw:DelCol(9)

   oDPCTAPROP:oWnd:oClient := oDPCTAPROP:oBrw
   oDPCTAPROP:oFocus       :=oDPCTAPROP:oBrw

   oDPCTAPROP:Activate({||oDPCTAPROP:ViewDatBar(oDPCTAPROP)})

   DPFOCUS(oDPCTAPROP:oBrw)

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oDPCTAPROP)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oDPCTAPROP:oDlg
   LOCAL nLin:=0

   oDPCTAPROP:oBrw:GoBottom(.T.)
   oDPCTAPROP:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   
   oDPCTAPROP:oFontBtn   :=oFont    
   oDPCTAPROP:nClrPaneBar:=oDp:nGris
   oDPCTAPROP:oBrw:oLbx  :=oDPCTAPROP

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          TOP PROMPT "Consulta"; 
          ACTION  EJECUTAR("DPCTACON",NIL,oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Buscar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oDPCTAPROP:oWnd:IsZoomed(),oDPCTAPROP:oWnd:Restore(),oDPCTAPROP:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CXP.BMP";
          TOP PROMPT "CxP"; 
          ACTION oDPCTAPROP:VERCXP()

   oBtn:cToolTip:="Detalles en Documentos de CxP"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\dbf.BMP";
          TOP PROMPT "Exportar"; 
          ACTION oDPCTAPROP:EXPORTDBF()

   oBtn:cToolTip:="Exportar hacia tabla temp\dpcta.dbf"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oDPCTAPROP:oBrw)

   oBtn:cToolTip:="Buscar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oDPCTAPROP:oBrw)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oDPCTAPROP:oBrw)

   oBtn:cToolTip:="Filtrar por Campo"

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
            TOP PROMPT "Refrescar"; 
              ACTION  oDPCTAPROP:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"
*/
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oDPCTAPROP)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

*/
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          TOP PROMPT "Excel"; 
          ACTION  (EJECUTAR("BRWTOEXCEL",oDPCTAPROP:oBrw,oDPCTAPROP:cTitle,oDPCTAPROP:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oDPCTAPROP:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION  (EJECUTAR("BRWTOHTML",oDPCTAPROP:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oDPCTAPROP:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview"; 
          ACTION  (EJECUTAR("BRWPREVIEW",oDPCTAPROP:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDPCTAPROP:oBtnPreview:=oBtn

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDPCTAPROP")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
            ACTION  oDPCTAPROP:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDPCTAPROP:oBtnPrint:=oBtn

   ENDIF
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDPCTAPROP:BRWQUERY()

   oBtn:cToolTip:="Imprimir"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oDPCTAPROP:oBrw:GoTop(),oDPCTAPROP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          TOP PROMPT "Avance"; 
          ACTION  (oDPCTAPROP:oBrw:PageDown(),oDPCTAPROP:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          TOP PROMPT "Anterior"; 
          ACTION  (oDPCTAPROP:oBrw:PageUp(),oDPCTAPROP:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oDPCTAPROP:oBrw:GoBottom(),oDPCTAPROP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oDPCTAPROP:Close()

  oDPCTAPROP:oBrw:SetColor(0,oDPCTAPROP:nClrPane1)

  EVAL(oDPCTAPROP:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  nLin:=32
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nLin:=nLin+o:nWidth()})

  @01,nLin+10 SAY " Cuentas " OF oBar SIZE 190+90,20 BORDER PIXEL FONT oFont COLOR 0,oDp:nClrYellow

  ADEPURA(oDPCTAPROP:aCtaCombo,{|a,n| Empty(a)})

  @21,nLin+10 COMBOBOX oDPCTAPROP:oCodigo VAR oDPCTAPROP:cCodigo ITEMS oDPCTAPROP:aCtaCombo OF oBar SIZE 190+90,20;
         ON CHANGE oDPCTAPROP:FILTRARCUENTAS() FONT oFont PIXEL

  oDPCTAPROP:oBar:=oBar
  

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRDPCTAPROP",cWhere)
  oRep:cSql  :=oDPCTAPROP:cSql
  oRep:cTitle:=oDPCTAPROP:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDPCTAPROP:oPeriodo:nAt,cWhere

  oDPCTAPROP:nPeriodo:=nPeriodo

  IF oDPCTAPROP:oPeriodo:nAt=LEN(oDPCTAPROP:oPeriodo:aItems)

     oDPCTAPROP:oDesde:ForWhen(.T.)
     oDPCTAPROP:oHasta:ForWhen(.T.)
     oDPCTAPROP:oBtn  :ForWhen(.T.)

     DPFOCUS(oDPCTAPROP:oDesde)

  ELSE

     oDPCTAPROP:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDPCTAPROP:oDesde:VarPut(oDPCTAPROP:aFechas[1] , .T. )
     oDPCTAPROP:oHasta:VarPut(oDPCTAPROP:aFechas[2] , .T. )

     oDPCTAPROP:dDesde:=oDPCTAPROP:aFechas[1]
     oDPCTAPROP:dHasta:=oDPCTAPROP:aFechas[2]

     cWhere:=oDPCTAPROP:HACERWHERE(oDPCTAPROP:dDesde,oDPCTAPROP:dHasta,oDPCTAPROP:cWhere,.T.)

     oDPCTAPROP:LEERDATA(cWhere,oDPCTAPROP:oBrw,oDPCTAPROP:cServer)

  ENDIF

  oDPCTAPROP:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF

   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oDPCTAPROP:cWhereQry)
       cWhere:=cWhere + oDPCTAPROP:cWhereQry
     ENDIF

     oDPCTAPROP:LEERDATA(cWhere,oDPCTAPROP:oBrw,oDPCTAPROP:cServer)

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

   cSql:=[ SELECT CTA_CODIGO,CTA_DESCRI,CTA_PROPIE,CTA_CODCON,CTR_CODIGO,CTA_DPJ26,CTA_CODINT,CTA_CTADET,0 AS LOGICO FROM DPCTA ]+;
         [ LEFT JOIN ]+oDp:cDsnConfig+[.DPCONRETISLR ON CTA_CODCON=CTR_CODIGO ]+;
         [ WHERE CTA_CODMOD]+GetWhere("=",oDp:cCtaMod)+IIF(Empty(cWhere),[],[ AND ])+cWhere+;
         [ GROUP BY CTA_CODIGO]+CRLF+;
         [ ORDER BY CTA_CODIGO]

   aData:=ASQL(cSql,oDb)
   AEVAL(aData,{|a,n|aData[n,9]=.F.})

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   IF ValType(oBrw)="O"

      oDPCTAPROP:cSql   :=cSql
      oDPCTAPROP:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      oDPCTAPROP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oDPCTAPROP:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDPCTAPROP:SAVEPERIODO()

   ENDIF

RETURN aData


/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDPCTAPROP)
RETURN .T.

/*
// Ejecución Cambio de Linea 
*/
FUNCTION BRWCHANGE()
   LOCAL cCodCta:=oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,1]
   LOCAL lDet   :=oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,8]
   LOCAL lDet2  :=oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,9]
   LOCAL oCol   :=oDPCTAPROP:oBrw:aCols[3]
   LOCAL lCtaBg :=.F.

   // Busca las Cuentas de Balances

   oCol:bOnPostEdit  :={|oCol,uValue|oDPCTAPROP:CTAGUARDAR(oCol,uValue)}

   IF ASCAN(oDPCTAPROP:aCtaBg,{|a,n|LEFT(cCodCta,LEN(ALLTRIM(a)))==ALLTRIM(a) })>0
      lCtaBg:=.T.
   ENDIF

   IF lDet .OR. lDet2

      IF lCtaBg
        oCol:aEditListTxt   :=oDPCTAPROP:aPropB
        oCol:aEditListBound :=oDPCTAPROP:aPropB
      ELSE
        oCol:aEditListTxt   :=oDPCTAPROP:aPropG
        oCol:aEditListBound :=oDPCTAPROP:aPropG
      ENDIF

      IF !Empty(oCol:aEditListTxt)

        oCol:nEditType      :=EDIT_LISTBOX

        // Casilla DPJ26
        oCol   :=oDPCTAPROP:oBrw:aCols[6]
        oCol:nEditType  :=EDIT_GET_BUTTON
        oCol:bOnPostEdit:={|oCol,uValue|oDPCTAPROP:CTADPJ26(oCol,uValue)}
        oCol:bEditBlock :={||oDPCTAPROP:BROWSEDPJ26()}

      ELSE

        oCol:nEditType      :=0

      ENDIF

   ENDIF

   oCol   :=oDPCTAPROP:oBrw:aCols[6]
   oCol:nEditType  :=EDIT_GET_BUTTON
   oCol:bOnPostEdit:={|oCol,uValue|oDPCTAPROP:CTADPJ26(oCol,uValue)}
   oCol:bEditBlock :={||oDPCTAPROP:BROWSEDPJ26()}

   oCol   :=oDPCTAPROP:oBrw:aCols[7]  

   IF lDet .OR. lDet2
     // Código de Integración
     oCol:nEditType  :=EDIT_GET_BUTTON
     oCol:bOnPostEdit:={|oCol,uValue|oDPCTAPROP:CTAINT(oCol,uValue)}
     oCol:bEditBlock :={||oDPCTAPROP:BROWSECODINT()}
   ELSE
     oCol:nEditType  :=0
   ENDIF

   oCol   :=oDPCTAPROP:oBrw:aCols[3]

   IF Empty(oCol:aEditListTxt) .OR. Empty(oCol:aEditListBound)
      oCol:aEditListTxt   :={}
      oCol:aEditListBound :={}
      oCol:nEditType      :=0
//      oDPCTAPROP:oBrw:aCols[6]:nEditType:=0
   ENDIF

RETURN .T.

FUNCTION BROWSECODINT()
  LOCAL uValue
  LOCAL cCodCta :=oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,1]
  LOCAL cCodInt :=oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,7] 

  uValue:=EJECUTAR("BRCODINT")

  IF !Empty(uValue)
     SQLUPDATE("DPCTA","CTA_CODINT",uValue,"CTA_CODIGO"+GetWhere("=",cCodCta))
     oDPCTAPROP:oBrw:KeyBoard(VK_DOWN)
  ENDIF

  oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,7]:=uValue 
  oDPCTAPROP:oBrw:DrawLine(.T.)

RETURN .T.

FUNCTION CTAINT(oCol,uValue)
//   ? "CTAINT"
RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK(lOk)
   oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,8+1]:=.T.
   oDPCTAPROP:BRWCHANGE()

RETURN .T.

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()

    IF Type("oDPCTAPROP")="O" .AND. oDPCTAPROP:oWnd:hWnd>0

      oDPCTAPROP:LEERDATA(oDPCTAPROP:cWhere_,oDPCTAPROP:oBrw,oDPCTAPROP:cServer)
      oDPCTAPROP:oWnd:Show()
      oDPCTAPROP:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION CTAGUARDAR(oCol,uValue)
 LOCAL lDet   :=oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,7+1]
 LOCAL cCodCta:=ALLTRIM(oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,1])
 LOCAL nAt    :=oDPCTAPROP:oBrw:nArrayAt
 LOCAL aCta   :={},I
 LOCAL oTable,aLine:={},aFields:={}
 LOCAL cWhere 

 IF Empty(uValue)
    uValue:=""
 ENDIF

 IF "Ninguno"$uValue
     uValue:=""
 ENDIF

 CursorWait()

 oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,3]:=uValue 

 IF lDet 

    AADD(aCta,cCodCta)

 ELSE
    
   WHILE nAt<=LEN(oDPCTAPROP:oBrw:aArrayData) .AND. cCodCta=LEFT(oDPCTAPROP:oBrw:aArrayData[nAt,1],LEN(cCodCta))

      oDPCTAPROP:oBrw:aArrayData[nAt,3]:=uValue 

      AADD(aCta,oDPCTAPROP:oBrw:aArrayData[nAt,1])

      nAt++
   ENDDO

 ENDIF 

 cWhere:=GetWhereOr("CTA_CODIGO",aCta)

// ? cWhere

 SQLUPDATE("DPCTA","CTA_PROPIE",uValue,cWhere)

/*
 FOR I=1 TO LEN(aCta)
    
    oDp:lExcluye:=.F.
    oTable:=OpenTable("SELECT CTA_CODIGO,CTA_PROPIE FROM DPCTA WHERE CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+" AND CTA_CODIGO"+GetWhere("=",aCta[I]),.T.)
//? oDp:cCtaMod,cCodCta,aCta[I],CLPCOPY(oDp:cSql)
//? oTable:Browse()
    oTable:cPrimary:="CTA_CODIGO"
    oTable:SetAuditar()
    oTable:Replace("CTA_PROPIE",uValue)
    oTable:Commit(oTable:cWhere)
    oTable:End()
//? oDp:cSql
 NEXT I
*/
  oDPCTAPROP:oBrw:Refresh(.F.)
  oDPCTAPROP:oBrw:nArrayAt:=nAt

 
RETURN .T.

FUNCTION FILTRARCUENTAS()
   LOCAL cCodigo:="%"+ALLTRIM(oDPCTAPROP:aCtaCod[oDPCTAPROP:oCodigo:nAt,1])

   oDPCTAPROP:oBrw:nColSel:=1
   EJECUTAR("BRWFILTER",oDPCTAPROP:oBrw:aCols[1],cCodigo)

RETURN .T.

/*
// Guarda Casilla DPJ26
*/
FUNCTION CTADPJ26(oCol,uValue)
   LOCAL oTable,aCta:={},I
   LOCAL cCodCta:=ALLTRIM(oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,1])
   LOCAL aData  :=EJECUTAR("DEPDPJ26"),nAt

   IF !ValType(uValue)="C"
      RETURN .T.
   ENDIF

   uValue:=ALLTRIM(uValue)
   nAt   :=ASCAN(aData,{|a,n|a[2]=uValue})

   IF nAt=0
      MensajeErr("Casilla no Existe en Forma DPJ26")
      RETURN .T.
   ENDIF

   AADD(aCta,cCodCta)

   FOR I=1 TO LEN(aCta)
     oTable:=OpenTable("SELECT CTA_CODIGO,CTA_DPJ26 FROM DPCTA WHERE CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+" AND CTA_CODIGO"+GetWhere("=",aCta[I]),.T.)
     oTable:cPrimary:="CTA_CODIGO"
     oTable:SetAuditar()
     oTable:Replace("CTA_DPJ26",uValue)
     oTable:Commit(oTable:cWhere)
     oTable:End()
   NEXT I

   oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,6]:=uValue
   oDPCTAPROP:oBrw:DrawLine(.T.)

RETURN .T.

/*
// Genera Correspondencia Masiva
*/

FUNCTION BROWSEDPJ26(cCasilla)
  LOCAL uValue

  DEFAULT cCasilla:= oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,6] 

  uValue:=EJECUTAR("BRDEFDPJ26",cCasilla,.T.)

  IF !Empty(uValue)
     oDPCTAPROP:CTADPJ26(oDPCTAPROP:oBrw:aCols[6],uValue)
     oDPCTAPROP:oBrw:KeyBoard(VK_DOWN)
  ENDIF

//  ViewArray(aData)

RETURN .T.

FUNCTION EXPORTDBF()
   LOCAL cFileDbf:="TEMP\DPCTA.DBF"
   LOCAL cTitle  :="Table "+cFileDbf,oTable

   CursorWait()

   oTable:=OpenTable("SELECT CTA_CODIGO,CTA_DESCRI,CTA_PROPIE,CTA_CODCON,CTA_DPJ26,CTA_CODINT,CTA_CTADET FROM DPCTA ORDER BY CTA_CODIGO")
   oTable:CTODBF(cFileDbf)

   HRBLOAD("DPGENREP.HRB")

   RepViewDbf(cFileDbf,cTitle,oTable)

RETURN .T.


FUNCTION PUTVALOR(oCol,uValue,nCol,nAt,lRefresh,cField)
  LOCAL aLine   :={},cWhere

  DEFAULT lRefresh:=.T.,;
          nAt     :=oDPCTAPROP:oBrw:nArrayAt

  aLine :=oDPCTAPROP:oBrw:aArrayData[nAt]

  cWhere:=[CTA_CODMOD]+GetWhere("=",oDp:cCtaMod)+" AND "+;
          [CTA_CODIGO]+GetWhere("=",aLine[1]   )

  oDPCTAPROP:oBrw:aArrayData[nAt,nCol]:=uValue
  oDPCTAPROP:oBrw:DrawLine(.T.)

  SQLUPDATE("DPCTA",cField,uValue,cWhere)

RETURN .T.


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oDPCTAPROP)

FUNCTION VERCXP()
  LOCAL cCodCta:=ALLTRIM(oDPCTAPROP:oBrw:aArrayData[oDPCTAPROP:oBrw:nArrayAt,1])
  LOCAL nLen   :=LEN(cCodCta)

  EJECUTAR("BRDOCPROCTADET","LEFT(CCD_CODCTA,"+LSTR(nLen)+")"+GetWhere("=",cCodCta))
RETURN .T.


// EOF
