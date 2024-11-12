// Programa   : BRACTXAXIFIS
// Fecha/Hora : 24/10/2014 17:17:27
// Propósito  : "Activos sin Ajuste fiscal"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRACTXAXIFIS.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SDB_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Activos sin Ajuste fiscal" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4 


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .F.

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .T.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.F.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)

   oDp:oFrm:=oACTXAXIFIS
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tajoma" SIZE 0, -12 BOLD

   DpMdi(cTitle,"oACTXAXIFIS","BRACTXAXIFIS.EDT")

   oACTXAXIFIS:Windows(0,0,aCoors[3]-160,MIN(1286,aCoors[4]-10),.T.) // Maximizado

//  DPEDIT():New(cTitle,"BRACTXAXIFIS.EDT","oACTXAXIFIS",.F.)
//  oACTXAXIFIS:CreateWindow(NIL,NIL,NIL,550,760+58)

   oACTXAXIFIS:cCodSuc  :=cCodSuc
   oACTXAXIFIS:lMsgBar  :=.F.
   oACTXAXIFIS:cPeriodo :=aPeriodos[nPeriodo]
   oACTXAXIFIS:cCodSuc  :=cCodSuc
   oACTXAXIFIS:nPeriodo :=nPeriodo
   oACTXAXIFIS:cNombre  :=""
   oACTXAXIFIS:dDesde   :=dDesde
   oACTXAXIFIS:cServer  :=cServer
   oACTXAXIFIS:dHasta   :=dHasta
   oACTXAXIFIS:cWhere   :=cWhere
   oACTXAXIFIS:cWhere_  :=""
   oACTXAXIFIS:cWhereQry:=""
   oACTXAXIFIS:cSql     :=oDp:cSql
   oACTXAXIFIS:oWhere   :=TWHERE():New(oACTXAXIFIS)
   oACTXAXIFIS:cCodPar  :=cCodPar // Código del Parámetro


   oACTXAXIFIS:oBrw:=TXBrowse():New( oACTXAXIFIS:oDlg )
   oACTXAXIFIS:oBrw:SetArray( aData, .F. )
   oACTXAXIFIS:oBrw:SetFont(oFont)

   oACTXAXIFIS:oBrw:lFooter     := .T.
   oACTXAXIFIS:oBrw:lHScroll    := .F.
   oACTXAXIFIS:oBrw:nHeaderLines:= 2
   oACTXAXIFIS:oBrw:nDataLines  := 1
   oACTXAXIFIS:oBrw:nFooterLines:= 1

   oACTXAXIFIS:aData            :=ACLONE(aData)

   AEVAL(oACTXAXIFIS:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oACTXAXIFIS:oBrw:aCols[1]
   oCol:cHeader      :='Código'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 120

   oCol:=oACTXAXIFIS:oBrw:aCols[2]
   oCol:cHeader      :='Descripción'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 250

   oCol:=oACTXAXIFIS:oBrw:aCols[3]
   oCol:cHeader      :='Código'+CRLF+"Grupo"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 60

   oCol:=oACTXAXIFIS:oBrw:aCols[4]
   oCol:cHeader      :='Descripción'+CRLF+"Grupo"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 180

   oCol:=oACTXAXIFIS:oBrw:aCols[5]
   oCol:cHeader      :='Fecha'+CRLF+'Desde'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 70

   oCol:=oACTXAXIFIS:oBrw:aCols[6]
   oCol:cHeader      :='Fecha'+CRLF+'Hasta'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 70


   oCol:=oACTXAXIFIS:oBrw:aCols[7]
   oCol:cHeader      :='Monto'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 110
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oACTXAXIFIS:oBrw:aArrayData[oACTXAXIFIS:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')

   oCol:=oACTXAXIFIS:oBrw:aCols[8]
   oCol:cHeader      :="Me-"+CRLF+"ses"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 40
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oACTXAXIFIS:oBrw:aArrayData[oACTXAXIFIS:oBrw:nArrayAt,8],FDP(nMonto,'9999')}
   oCol:cFooter      :=FDP(aTotal[8],'99999')

   oCol:=oACTXAXIFIS:oBrw:aCols[9]
   oCol:cHeader      :='#'+CRLF+'Reg.'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXAXIFIS:oBrw:aArrayData ) } 
   oCol:nWidth       := 30
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oACTXAXIFIS:oBrw:aArrayData[oACTXAXIFIS:oBrw:nArrayAt,9],FDP(nMonto,'9999')}
   oCol:cFooter      :=FDP(aTotal[9],'99999')


  oACTXAXIFIS:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oACTXAXIFIS:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oACTXAXIFIS:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773087, 16770252 ) } }

  oACTXAXIFIS:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oACTXAXIFIS:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oACTXAXIFIS:oBrw:bLDblClick:={|oBrw|oACTXAXIFIS:oRep:=oACTXAXIFIS:RUNCLICK() }

  oACTXAXIFIS:oBrw:bChange:={||oACTXAXIFIS:BRWCHANGE()}
  oACTXAXIFIS:oBrw:CreateFromCode()

  oACTXAXIFIS:oWnd:oClient := oACTXAXIFIS:oBrw


  oACTXAXIFIS:Activate({||oACTXAXIFIS:ViewDatBar(oACTXAXIFIS)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oACTXAXIFIS)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oACTXAXIFIS:oDlg
   LOCAL nLin:=0

   oACTXAXIFIS:oBrw:GoBottom(.T.)
   oACTXAXIFIS:oBrw:Refresh(.T.)


   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


   IF .F. .AND. Empty(oACTXAXIFIS:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oACTXAXIFIS:oBrw,oACTXAXIFIS:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   IF Empty(oACTXAXIFIS:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","ACTXAXIFIS")))

         DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XBROWSE.BMP";
         ACTION EJECUTAR("BRWRUNBRWLINK",oACTXAXIFIS:oBrw,"ACTXAXIFIS",oACTXAXIFIS:cSql,oACTXAXIFIS:nPeriodo,oACTXAXIFIS:dDesde,oACTXAXIFIS:dHasta)

         oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"

         oACTXAXIFIS:oBtnRun:=oBtn

         oACTXAXIFIS:oBrw:bLDblClick:={||EVAL(oACTXAXIFIS:oBtnRun:bAction) }


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oACTXAXIFIS:CALAXI()

   oBtn:cToolTip:="Ejecutar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oACTXAXIFIS:oBrw);
          WHEN LEN(oACTXAXIFIS:oBrw:aArrayData)>1 


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oACTXAXIFIS:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION EJECUTAR("DPACTIVOCON",NIL,oACTXAXIFIS:oBrw:aArrayData[oACTXAXIFIS:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Consultar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oACTXAXIFIS:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oACTXAXIFIS:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oACTXAXIFIS)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oACTXAXIFIS:oBrw,oACTXAXIFIS:cTitle,oACTXAXIFIS:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oACTXAXIFIS:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oACTXAXIFIS:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oACTXAXIFIS:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oACTXAXIFIS:oBrw))

   oBtn:cToolTip:="Previsualización"

   oACTXAXIFIS:oBtnPreview:=oBtn

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRACTXAXIFIS")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oACTXAXIFIS:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oACTXAXIFIS:oBtnPrint:=oBtn

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oACTXAXIFIS:BRWQUERY()

   oBtn:cToolTip:="Imprimir"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oACTXAXIFIS:oBrw:GoTop(),oACTXAXIFIS:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oACTXAXIFIS:oBrw:PageDown(),oACTXAXIFIS:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oACTXAXIFIS:oBrw:PageUp(),oACTXAXIFIS:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oACTXAXIFIS:oBrw:GoBottom(),oACTXAXIFIS:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oACTXAXIFIS:Close()

  oACTXAXIFIS:oBrw:SetColor(0,16773087)

  EVAL(oACTXAXIFIS:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oACTXAXIFIS:oBar:=oBar

    //
  // Campo : Fecha
  //


  nLin:=650+30

  @ 10, nLin GET oACTXAXIFIS:oHasta  VAR oACTXAXIFIS:dHasta;
               SIZE 100,20;
               COLOR CLR_BLACK,CLR_WHITE;
               VALID !Empty(oACTXAXIFIS:dHasta);
               OF oBar;
               SPINNER;
               ON CHANGE EVAL(oACTXAXIFIS:oHasta:bValid);
               FONT oFont PIXEL

   oACTXAXIFIS:oHasta:bKeyDown:={|nKey| IF( nKey=117 , LbxDate(oACTXAXIFIS:oHasta ,oACTXAXIFIS:dHasta) , NIL )}


  @ oACTXAXIFIS:oHasta:nTop,nLin-56 SAY "Hasta:" OF oBar BORDER SIZE 54,20 PIXEL

  @ oACTXAXIFIS:oHasta:nTop,nLin+123 BUTTON oACTXAXIFIS:oBtn PROMPT " > " SIZE 27,20;
              FONT oFont;
              PIXEL;
              OF oBar;
              ACTION oACTXAXIFIS:HACERWHERE(oACTXAXIFIS:dDesde,oACTXAXIFIS:dHasta,oACTXAXIFIS:cWhere,.T.)




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

  oRep:=REPORTE("BRACTXAXIFIS",cWhere)
  oRep:cSql  :=oACTXAXIFIS:cSql
  oRep:cTitle:=oACTXAXIFIS:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oACTXAXIFIS:oPeriodo:nAt,cWhere

  oACTXAXIFIS:nPeriodo:=nPeriodo

  IF oACTXAXIFIS:oPeriodo:nAt=LEN(oACTXAXIFIS:oPeriodo:aItems)

     oACTXAXIFIS:oDesde:ForWhen(.T.)
     oACTXAXIFIS:oHasta:ForWhen(.T.)
     oACTXAXIFIS:oBtn  :ForWhen(.T.)

     DPFOCUS(oACTXAXIFIS:oDesde)

  ELSE

     oACTXAXIFIS:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oACTXAXIFIS:oDesde:VarPut(oACTXAXIFIS:aFechas[1] , .T. )
     oACTXAXIFIS:oHasta:VarPut(oACTXAXIFIS:aFechas[2] , .T. )

     oACTXAXIFIS:dDesde:=oACTXAXIFIS:aFechas[1]
     oACTXAXIFIS:dHasta:=oACTXAXIFIS:aFechas[2]

     cWhere:=oACTXAXIFIS:HACERWHERE(oACTXAXIFIS:dDesde,oACTXAXIFIS:dHasta,oACTXAXIFIS:cWhere,.T.)

     oACTXAXIFIS:LEERDATA(cWhere,oACTXAXIFIS:oBrw,oACTXAXIFIS:cServer)

  ENDIF

  oACTXAXIFIS:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       cWhere:= "DPACTIVOS.ATV_FCHADQ"+GetWhere("<=",dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:= "DPACTIVOS.ATV_FCHADQ"+GetWhere("<=",dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oACTXAXIFIS:cWhereQry)
       cWhere:=cWhere + oACTXAXIFIS:cWhereQry
     ENDIF

     oACTXAXIFIS:LEERDATA(cWhere,oACTXAXIFIS:oBrw,oACTXAXIFIS:cServer)

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


   cSql:=" SELECT DEP_CODACT,"+;
         "        ATV_DESCRI, "+;
         "        ATV_CODGRU, "+;
           "           GAC_DESCRI, "+;
         "  MIN(DEP_DESDE) AS DEP_FCHMIN, "+;
         "  MAX(DEP_FECHA) AS DEP_FCHMAX, "+;
         "  SUM(DEP_MONTO) AS DEP_MONTO , "+;
         "  0 AS MESES, "+;
         "  COUNT(*) "+;
         "  FROM  "+;
         "  DPDEPRECIAACT  "+;
         "  INNER JOIN DPACTIVOS ON ATV_CODIGO=DEP_CODACT AND ATV_DEPRE='D'  "+;
           "   INNER JOIN DPGRUACTIVOS ON ATV_CODGRU=GAC_CODIGO "+;
         "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DEP_MTOFIS=0 AND DEP_TIPTRA='D' "+;
         "  GROUP BY DEP_CODACT "

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   aData:=ASQL(cSql,oDb)

   AEVAL(aData,{|a,n|aData[n,8]:=MESES(a[3+2],a[4+2]) })

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   IF ValType(oBrw)="O"

      oACTXAXIFIS:cSql   :=cSql
      oACTXAXIFIS:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oACTXAXIFIS:oBrw:aCols[5]
      
      oCol:=oACTXAXIFIS:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')

      oACTXAXIFIS:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oACTXAXIFIS:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oACTXAXIFIS:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRACTXAXIFIS.MEM",V_nPeriodo:=oACTXAXIFIS:nPeriodo
  LOCAL V_dDesde:=oACTXAXIFIS:dDesde
  LOCAL V_dHasta:=oACTXAXIFIS:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oACTXAXIFIS)
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

    IF Type("oACTXAXIFIS")="O" .AND. oACTXAXIFIS:oWnd:hWnd>0

      oACTXAXIFIS:LEERDATA(oACTXAXIFIS:cWhere_,oACTXAXIFIS:oBrw,oACTXAXIFIS:cServer)
      oACTXAXIFIS:oWnd:Show()
      oACTXAXIFIS:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/

FUNCTION CALAXI()

   EJECUTAR("DPCALAJUFICACT")

   EVAL(oActAju:oBtnRun:bAction)

RETURN .T.
// EOF


// EOF
