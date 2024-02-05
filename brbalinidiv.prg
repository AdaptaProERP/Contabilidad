// Programa   : BRBALINIDIV
// Fecha/Hora : 27/04/2021 10:43:29
// Propósito  : "Balance Inicial Valorizado en Divisas"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumEje,cCodMon,cNumero)
   LOCAL aData,aFechas,cFileMem:="USER\BRBALINIDIV.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer,dFecha,cWhereA
   LOCAL lConectar:=.F.,cNumIni,aBalance:={}

   oDp:cRunServer:=NIL


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF

   AADD(aBalance,oDp:cCtaBg1)
   AADD(aBalance,oDp:cCtaBg2)
   AADD(aBalance,oDp:cCtaBg3)

   ADEPURA(aBalance,{|a,n| Empty(a)})

   AADD(aBalance,"")

   DEFAULT cCodSuc :=oDp:cSucursal,;
           cNumEje:=EJECUTAR("FCH_EJERGET",oDp:dFecha),;
           cCodMon:=oDp:cMonedaBcv,;
           dFecha :=SQLGET("DPEJERCICIOS","EJE_DESDE","EJE_CODSUC"+GetWhere("=",cCodSuc)+" AND EJE_NUMERO"+GetWhere("=",cNumEje))


   cTitle:="Balance Inicial Valorizado en Divisas" +IF(Empty(cTitle),"",cTitle)+" "+DTOC(dFecha)

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

   IF !Empty(cNumEje)
       dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_NUMERO"+GetWhere("=",cNumEje))
       dHasta:=DPSQLROW(2)
   ENDIF

   DEFAULT cNumero:=STRZERO(1,8)

   oDp:cCtaModIni:=SQLGET("DPEJERCICIOS","EJE_CTAMOD","EJE_NUMERO"+GetWhere("=",cNumEje)) // ejercicio Inicial
   oDp:lVacio    :=.F.

   cWhereA       :="MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;  
                   "MOC_ACTUAL"+GetWhere("=","S"    )+" AND "+;
                   "MOC_ORIGEN"+GetWhere("=","BAL"  )+" AND "+;
                   "MOC_FECHA" +GetWhere("=",dFecha )+" AND "+;
                   "MOC_MONTO=0"


   SQLDELETE("DPASIENTOS",cWhereA)


   cWhere:=NIL // HACERWHERE(dDesde,dHasta,cWhere)
   aData :=LEERDATA(cWhere,NIL,cServer,NIL,NIL,dFecha)

   IF !Empty(cNumEje) .AND. Empty(aData) .OR. Empty(aData[1,1])
      cNumIni:=STRZERO(VAL(cNumEje)-1,4)
      EJECUTAR("DPEJERCICIOBAL_INI",cNumIni)
      aData :=LEERDATA(cWhere,NIL,cServer,NIL,NIL,dFecha   )
   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,cWhere)

   oDp:oFrm:=oBALINIDIV

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oBALINIDIV","BRBALINIDIV.EDT")
// oBALINIDIV:CreateWindow(0,0,100,550)
   oBALINIDIV:Windows(0,0,aCoors[3]-160,MIN(752,aCoors[4]-10),.T.) // Maximizado

   oBALINIDIV:cCodSuc  :=cCodSuc
   oBALINIDIV:lMsgBar  :=.F.
   oBALINIDIV:cPeriodo :=aPeriodos[nPeriodo]
   oBALINIDIV:cCodSuc  :=cCodSuc
   oBALINIDIV:nPeriodo :=nPeriodo
   oBALINIDIV:cNombre  :=""
   oBALINIDIV:dDesde   :=dDesde
   oBALINIDIV:dFecha   :=dFecha
   oBALINIDIV:cServer  :=cServer
   oBALINIDIV:dHasta   :=dHasta
   oBALINIDIV:cWhere   :=cWhere
   oBALINIDIV:cWhere_  :=cWhere_
   oBALINIDIV:cWhereQry:=""
   oBALINIDIV:cSql     :=oDp:cSql
   oBALINIDIV:oWhere   :=TWHERE():New(oBALINIDIV)
   oBALINIDIV:cCodPar  :=cCodPar // Código del Parámetro
   oBALINIDIV:lWhen    :=.T.
   oBALINIDIV:cTextTit :="" // Texto del Titulo Heredado
   oBALINIDIV:oDb      :=oDp:oDb
   oBALINIDIV:cBrwCod  :="BALINIDIV"
   oBALINIDIV:lTmdi    :=.T.
   oBALINIDIV:aHead    :={}
   oBALINIDIV:lBarDef  :=.T. // Activar Modo Diseño.
   oBALINIDIV:cCodMon  :=cCodMon
   oBALINIDIV:dFecha   :=dFecha
// oBALINIDIV:nValCam  :=0
// oBALINIDIV:nValCam  :=SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon)+" AND HMN_FECHA"+GetWhere("=",oBALINIDIV:dFecha))
   oBALINIDIV:nValCam  :=EJECUTAR("DPGETVALCAM",oBALINIDIV:cCodMon,oBALINIDIV:dFecha)
   oBALINIDIV:lVacio   :=oDp:lVacio // si esta vacio calculo en BS
   oBALINIDIV:cNumEje  :=cNumEje
   oBALINIDIV:cCtaMod  :=oDp:cCtaModIni
   oBALINIDIV:aBalance :=ACLONE(aBalance)
   oBALINIDIV:lValoriza:=.T.
   oBALINIDIV:cNumero  :=cNumero

   // Guarda los parámetros del Browse cuando cierra la ventana
   oBALINIDIV:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBALINIDIV)}

   oBALINIDIV:lBtnRun     :=.F.
   oBALINIDIV:lBtnMenuBrw :=.F.
   oBALINIDIV:lBtnSave    :=.F.
   oBALINIDIV:lBtnCrystal :=.F.
   oBALINIDIV:lBtnRefresh :=.F.
   oBALINIDIV:lBtnHtml    :=.T.
   oBALINIDIV:lBtnExcel   :=.T.
   oBALINIDIV:lBtnPreview :=.T.
   oBALINIDIV:lBtnQuery   :=.F.
   oBALINIDIV:lBtnOptions :=.T.
   oBALINIDIV:lBtnPageDown:=.T.
   oBALINIDIV:lBtnPageUp  :=.T.
   oBALINIDIV:lBtnFilters :=.T.
   oBALINIDIV:lBtnFind    :=.T.

   oBALINIDIV:nClrPane1:=16775408
   oBALINIDIV:nClrPane2:=16771797

   oBALINIDIV:nClrText :=0
   oBALINIDIV:nClrText1:=0
   oBALINIDIV:nClrText2:=0
   oBALINIDIV:nClrText3:=0

   oBALINIDIV:oBrw:=TXBrowse():New( IF(oBALINIDIV:lTmdi,oBALINIDIV:oWnd,oBALINIDIV:oDlg ))
   oBALINIDIV:oBrw:SetArray( aData, .F. )
   oBALINIDIV:oBrw:SetFont(oFont)

   oBALINIDIV:oBrw:lFooter     := .T.
   oBALINIDIV:oBrw:lHScroll    := .F.
   oBALINIDIV:oBrw:nHeaderLines:= 2
   oBALINIDIV:oBrw:nDataLines  := 1
   oBALINIDIV:oBrw:nFooterLines:= 1

   oBALINIDIV:aData            :=ACLONE(aData)

   AEVAL(oBALINIDIV:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  // Campo: MOC_CUENTA
  oCol:=oBALINIDIV:oBrw:aCols[1]
  oCol:cHeader      :='Cuenta'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: CTA_DESCRI
  oCol:=oBALINIDIV:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: MOC_MTOORG
  oCol:=oBALINIDIV:oBrw:aCols[3]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,3],;
                              oCol   := oBALINIDIV:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)
  oCol:lTotal       :=.T.

  oCol:nEditType  :=1
  oCol:bOnPostEdit:={|oCol,uValue|oBALINIDIV:PUTMONTO(oCol,uValue,3)}


  oCol:oDataFont:=oFontB


  // Campo: MOC_MONTO
  oCol:=oBALINIDIV:oBrw:aCols[4]
  oCol:cHeader      :='Monto'+CRLF+'Asiento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4],;
                              oCol  := oBALINIDIV:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)
  oCol:lTotal       :=.T.

  oCol:nEditType  :=1
  oCol:bOnPostEdit:={|oCol,uValue|oBALINIDIV:PUTMONTOBS(oCol,uValue,4)}




  // Campo: RECALC
  oCol:=oBALINIDIV:oBrw:aCols[5]
  oCol:cHeader      :='Monto'+CRLF+'Recalculado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,5],;
                              oCol  := oBALINIDIV:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)
  oCol:lTotal       :=.T.


  // Campo: AJUSTE
  oCol:=oBALINIDIV:oBrw:aCols[6]
  oCol:cHeader      :='Monto'+CRLF+'Ajuste'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,6],;
                              oCol  := oBALINIDIV:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)
  oCol:lTotal       :=.T.

  // Campo: CTA_DESCRI
  oCol:=oBALINIDIV:oBrw:aCols[7]
  oCol:cHeader      :='Propiedad'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBALINIDIV:oBrw:aArrayData ) } 
  oCol:nWidth       := 120



   oBALINIDIV:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oBALINIDIV:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oBALINIDIV:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oBALINIDIV:nClrText,;
                                                 nClrText:=IF(.F.,oBALINIDIV:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oBALINIDIV:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oBALINIDIV:nClrPane1, oBALINIDIV:nClrPane2 ) } }

//   oBALINIDIV:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oBALINIDIV:oBrw:bClrFooter            := {|| {0,14671839 }}

   oBALINIDIV:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBALINIDIV:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oBALINIDIV:oBrw:bLDblClick:={|oBrw|oBALINIDIV:RUNCLICK() }

   oBALINIDIV:oBrw:bChange:={||oBALINIDIV:BRWCHANGE()}
   oBALINIDIV:oBrw:CreateFromCode()


   oBALINIDIV:oWnd:oClient := oBALINIDIV:oBrw



   oBALINIDIV:Activate({||oBALINIDIV:ViewDatBar()})

   oBALINIDIV:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBALINIDIV:lTmdi,oBALINIDIV:oWnd,oBALINIDIV:oDlg)
   LOCAL nLin:=2,nCol:=0,I
   LOCAL nWidth:=oBALINIDIV:oBrw:nWidth()

   oBALINIDIV:oBrw:GoBottom(.T.)
   oBALINIDIV:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRBALINIDIV.EDT")
//     oBALINIDIV:oBrw:Move(44,0,752+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth+5,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 


   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD


 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oBALINIDIV:cServer)

   oBALINIDIV:oFontBtn   :=oFont    
   oBALINIDIV:nClrPaneBar:=oDp:nGris
   oBALINIDIV:oBrw:oLbx  :=oBALINIDIV

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          TOP PROMPT "Consulta"; 
          ACTION  EJECUTAR("BRWRUNLINK",oBALINIDIV:oBrw,oBALINIDIV:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF
  
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Calcular"; 
          ACTION  oBALINIDIV:CALCULARDIV()

   oBtn:cToolTip:="Calcular Según Valor de la Divisa"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbteactualizado.BMP";
          TOP PROMPT "Cbte.";
          ACTION EJECUTAR("DPCBTE","S",oBALINIDIV:cNumero,oBALINIDIV:dFecha)

   oBtn:cToolTip:="Comprobante Actualizado"

                                              
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\mayoranalitico.BMP";
          TOP PROMPT "Mayor A";
          ACTION oBALINIDIV:MAYOR()

    oBtn:cToolTip:="Mayor Analítico"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\balancecomprobacion.BMP";
          TOP PROMPT "B.Comp";
          ACTION oBALINIDIV:BALCOM()

   oBtn:cToolTip:="Balance de Comprobación"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP";
          TOP PROMPT "Eliminar"; 
          ACTION  oBALINIDIV:DELBALINI()

  oBtn:cToolTip:="Remover Balance Inicial"


/*
   IF Empty(oBALINIDIV:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","BALINIDIV")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","BALINIDIV"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles"; 
       ACTION  EJECUTAR("BRWRUNBRWLINK",oBALINIDIV:oBrw,"BALINIDIV",oBALINIDIV:cSql,oBALINIDIV:nPeriodo,oBALINIDIV:dDesde,oBALINIDIV:dHasta,oBALINIDIV)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oBALINIDIV:oBtnRun:=oBtn



       oBALINIDIV:oBrw:bLDblClick:={||EVAL(oBALINIDIV:oBtnRun:bAction) }


   ENDIF




IF oBALINIDIV:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oBALINIDIV");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oBALINIDIV:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oBALINIDIV:lBtnSave
/*
      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
               TOP PROMPT "Grabar"; 
              ACTION  EJECUTAR("DPBRWSAVE",oBALINIDIV:oBrw,oBALINIDIV:oFrm)
*/
ENDIF

IF oBALINIDIV:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú"; 
          ACTION  (EJECUTAR("BRWBUILDHEAD",oBALINIDIV),;
                  EJECUTAR("DPBRWMENURUN",oBALINIDIV,oBALINIDIV:oBrw,oBALINIDIV:cBrwCod,oBALINIDIV:cTitle,oBALINIDIV:aHead));
          WHEN !Empty(oBALINIDIV:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oBALINIDIV:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oBALINIDIV:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oBALINIDIV:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBALINIDIV:oBrw,oBALINIDIV);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oBALINIDIV:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oBALINIDIV:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION  EJECUTAR("BRWSETOPTIONS",oBALINIDIV:oBrw);
          WHEN LEN(oBALINIDIV:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oBALINIDIV:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar"; 
          ACTION  oBALINIDIV:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oBALINIDIV:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal"; 
          ACTION  EJECUTAR("BRWTODBF",oBALINIDIV)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oBALINIDIV:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
            ACTION  (EJECUTAR("BRWTOEXCEL",oBALINIDIV:oBrw,oBALINIDIV:cTitle,oBALINIDIV:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBALINIDIV:oBtnXls:=oBtn

ENDIF

IF oBALINIDIV:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION  (oBALINIDIV:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBALINIDIV:oBrw,NIL,oBALINIDIV:cTitle,oBALINIDIV:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBALINIDIV:oBtnHtml:=oBtn

ENDIF


IF oBALINIDIV:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview"; 
          ACTION  (EJECUTAR("BRWPREVIEW",oBALINIDIV:oBrw))

   oBtn:cToolTip:="Previsualización"

   oBALINIDIV:oBtnPreview:=oBtn

ENDIF

   IF .T. 

// ISSQLGET("DPREPORTES","REP_CODIGO","BRBALINIDIV")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
            ACTION  oBALINIDIV:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oBALINIDIV:oBtnPrint:=oBtn

   ENDIF

IF oBALINIDIV:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBALINIDIV:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oBALINIDIV:oBrw:GoTop(),oBALINIDIV:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oBALINIDIV:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
            ACTION  (oBALINIDIV:oBrw:PageDown(),oBALINIDIV:oBrw:Setfocus())
  ENDIF

  IF  oBALINIDIV:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior"; 
           ACTION  (oBALINIDIV:oBrw:PageUp(),oBALINIDIV:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oBALINIDIV:oBrw:GoBottom(),oBALINIDIV:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oBALINIDIV:Close()

  oBALINIDIV:oBrw:SetColor(0,oBALINIDIV:nClrPane1)

//  oBALINIDIV:SETBTNBAR(40,40,oBar)

  EVAL(oBALINIDIV:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  nCol:=32
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),nCol:=nCol+o:nWidth()})

  oBar:SetSize(NIL,80+20+15,.T.)

  oBALINIDIV:oBar:=oBar

  nCol:=200
  nLin:=2+20+20+25+3
//  nCol:=470+10+15+20+32+32


  @ nLin+0,nCol+60 BMPGET oBALINIDIV:oCodMon  VAR oBALINIDIV:cCodMon;
                 PIXEL;
                 NAME "BITMAPS\Calendar.bmp";
                 ACTION (oDpLbx:=DpLbx("DPTABMON",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oBALINIDIV:oCodMon,NIL),;
                         oDpLbx:GetValue("MON_CODIGO",oBALINIDIV:oCodMon));
                 VALID oAVINOTENTDET:VALCODMON();
                 SIZE 40,20;
                 WHEN oBALINIDIV:lWhen ;
                 OF oBar;
                 FONT oFont

  oBALINIDIV:oCodMon:bLostFocus:={|| oBALINIDIV:VALCODMON()}

  @ oBALINIDIV:oCodMon:nTop,nCol-55+60 SAY oDp:xDPTABMON+" " OF oBar BORDER SIZE 54,20 PIXEL;
                               BORDER RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ oBALINIDIV:oCodMon:nTop,nCol+60+60 SAY oBALINIDIV:oSayCodMon PROMPT " "+SQLGET("DPTABMON","MON_DESCRI","MON_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon));
                                       OF oBar PIXEL SIZE 220+40,20 BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

  @ oBALINIDIV:oCodMon:nTop+21,nCol-60+4+60 GET oBALINIDIV:oSayValCam VAR oBALINIDIV:nValCam PICTURE oDp:cPictValCam;
                                       OF oBar PIXEL SIZE 220,20  FONT oFont RIGHT;
                                       VALID oBALINIDIV:VALDIVISA()

  oBALINIDIV:oSayValCam:bKeyDown:={|nKey| IF(nKey=13,oBALINIDIV:VALDIVISA(),NIL)}


// BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT

//  @ oBALINIDIV:oCodMon:nTop+20,nCol+60+60 SAY oBALINIDIV:oSayValCam PROMPT TRAN(SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon)+" AND HMN_FECHA"+GetWhere("=",oBALINIDIV:dFecha)),"99,999,999,999.99");
//                                       OF oBar PIXEL SIZE 220,20 BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT

  BMPGETBTN(oBALINIDIV:oCodMon,oFont,13)

  FOR I=1 TO LEN(oBALINIDIV:aBalance)

     @ 44+20+3,20+(35*(I-1)) BUTTON oBtn PROMPT oBALINIDIV:aBalance[I] SIZE 27,24;
                        FONT oFont;
                        OF oBar;
                        PIXEL;
                        ACTION (1=1)

     oBtn:bAction:=BloqueCod([oBALINIDIV:BUSCARLETRA(]+GetWhere("",oBALINIDIV:aBalance[I])+[)])
     oBtn:CARGO:=oBALINIDIV:aBalance[I]

     IF Empty(oBALINIDIV:aBalance[I])
       oBtn:cToolTip:="Restaurar Todas las Cuentas"
     ELSE
       oBtn:cToolTip:="Filtrar Cuentas que empiecen con Dígito "+oBALINIDIV:aBalance[I]
     ENDIF

  NEXT I
//

 @ 50+20,600 CHECKBOX oBALINIDIV:oValoriza VAR oBALINIDIV:lValoriza  PROMPT "En divisa";
                 WHEN  .T.;
                 FONT oFont;
                 SIZE 180,20 OF oBar;
                 ON CHANGE 1=1 PIXEL


  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

//  oBALINIDIV:VALCODMON()
// ? oBALINIDIV:nValCam,"oBALINIDIV:nValCam"

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
  LOCAL oRep,cWhere:=NIL

  oRep:=REPORTE("BALANCEGEN",cWhere)
  oRep:cSql  :=oBALINIDIV:cSql
  oRep:cTitle:=oBALINIDIV:cTitle

  oRep:SETCRITERIO(1,oBALINIDIV:dDesde)

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oBALINIDIV:oPeriodo:nAt,cWhere
/*
  oBALINIDIV:nPeriodo:=nPeriodo


  IF oBALINIDIV:oPeriodo:nAt=LEN(oBALINIDIV:oPeriodo:aItems)

     oBALINIDIV:oDesde:ForWhen(.T.)
     oBALINIDIV:oHasta:ForWhen(.T.)
     oBALINIDIV:oBtn  :ForWhen(.T.)

     DPFOCUS(oBALINIDIV:oDesde)

  ELSE

     oBALINIDIV:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oBALINIDIV:oDesde:VarPut(oBALINIDIV:aFechas[1] , .T. )
     oBALINIDIV:oHasta:VarPut(oBALINIDIV:aFechas[2] , .T. )

     oBALINIDIV:dDesde:=oBALINIDIV:aFechas[1]
     oBALINIDIV:dHasta:=oBALINIDIV:aFechas[2]

     cWhere:=oBALINIDIV:HACERWHERE(oBALINIDIV:dDesde,oBALINIDIV:dHasta,oBALINIDIV:cWhere,.T.)

     oBALINIDIV:LEERDATA(cWhere,oBALINIDIV:oBrw,oBALINIDIV:cServer,oBALINIDIV)

  ENDIF

  oBALINIDIV:SAVEPERIODO()
*/

RETURN .T.

FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPASIENTOS.MOC_FECHA"$cWhere
     RETURN ""
   ENDIF

/*   
   IF !Empty(dDesde)
       cWhere:= "DPASIENTOS.MOC_FECHA           "+GetWhere("<=",dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:= "DPASIENTOS.MOC_FECHA           "+GetWhere("<=",dHasta)
     ENDIF
   ENDIF
*/

   IF !Empty(dDesde) .AND. !Empty(dHasta)
     cWhere:= GetWhereAnd("DPASIENTOS.MOC_FECHA",dDesde,dHasta)
   ENDIF

   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCTARESSLD:cWhereQry)
       cWhere:=cWhere + oBALINIDIV:cWhereQry
     ENDIF

     oBALINIDIV:LEERDATA(cWhere,oBALINIDIV:oBrw,oBALINIDIV:cServer,oBALINIDIV)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oBALINIDIV,nValCam,dFecha)
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
         "  MOC_CUENTA, "+;
         "  CTA_DESCRI, "+;
         "  SUM(IF(MOC_MTOORG IS NULL OR MOC_MTOORG=0,ROUND(MOC_MONTO/MOC_VALCAM,2),MOC_MTOORG)) AS MOC_MTOORG, "+;
         "  SUM(MOC_MONTO) AS MOC_MONTO, "+;
         "  0 AS RECALC,"+;
         "  0 AS AJUSTE,CTA_PROPIE "+;
         "  FROM "+;
         "  dpasientos "+;
         "  INNER JOIN dpcta ON MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO "+;
         "  WHERE MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+"  AND MOC_FECHA"+GetWhere("=",dFecha)+" AND MOC_ORIGEN='INI' "+;
         "  GROUP BY MOC_CUENTA "+;
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

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRBALINIDIV.SQL",cSql)

   aData:={} // ASQL(cSql,oDb)

   IF Empty(aData) 

    oDp:lVacio:=.T.

    cSql:=" SELECT  "+;
          "  CTA_CODIGO, "+;
          "  CTA_DESCRI, "+;
          "  MOC_MTOORG, "+;
          "  MOC_MONTO, "+;
          "  0 AS RECALC,"+;
          "  0 AS AJUSTE,CTA_PROPIE "+;
          "  FROM "+;
          "  dpcta "+;
          "  LEFT JOIN dpasientos ON MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO AND MOC_FECHA"+GetWhere("=",dFecha)+;
          "  WHERE CTA_CODMOD"+GetWhere("=",oDp:cCtaModIni)+" AND CTA_CTADET=1 "+;
          "  GROUP BY CTA_CODIGO "+;
          ""

// ? CLPCOPY(cSql)
//     IF !Empty(cWhere)
//       cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
//     ENDIF

     aData:=ASQL(cSql,oDb)

   ENDIF

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oBALINIDIV:cSql   :=cSql
      oBALINIDIV:cWhere_:=cWhere

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
      AEVAL(oBALINIDIV:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oBALINIDIV:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRBALINIDIV.MEM",V_nPeriodo:=oBALINIDIV:nPeriodo
  LOCAL V_dDesde:=oBALINIDIV:dDesde
  LOCAL V_dHasta:=oBALINIDIV:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oBALINIDIV)
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


    IF Type("oBALINIDIV")="O" .AND. oBALINIDIV:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oBALINIDIV:cWhere_),oBALINIDIV:cWhere_,oBALINIDIV:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oBALINIDIV:LEERDATA(oBALINIDIV:cWhere_,oBALINIDIV:oBrw,oBALINIDIV:cServer)
      oBALINIDIV:oWnd:Show()
      oBALINIDIV:oWnd:Restore()

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

   oBALINIDIV:aHead:=EJECUTAR("HTMLHEAD",oBALINIDIV)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oBALINIDIV)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/

FUNCTION VALCODMON(lRefresh)


   DEFAULT lRefresh:=.F.
 
   oBALINIDIV:nValCam:=SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon)+" AND HMN_FECHA"+GetWhere("=",oBALINIDIV:dFecha))

   oBALINIDIV:oSayCodMon:Refresh(.T.) 
   oBALINIDIV:oSayValCam:Refresh(.T.)

// ? oDp:cSql,oBALINIDIV:cCodMon,oBALINIDIV:dFecha
 
   IF !ISSQLFIND("DPTABMON","MON_CODIGO"+GetWhere("=",oBALINIDIV:cCodMon))
      EVAL(oBALINIDIV:oCodMon:bAction)
      RETURN .F.
   ENDIF

   IF lRefresh
     oBALINIDIV:HACERWHERE(oBALINIDIV:dDesde,oBALINIDIV:dHasta,oBALINIDIV:cWhere,.T.)
   ENDIF

RETURN .T.


FUNCTION PUTMONTO(oCol,uValue,nCol,nAt,lRefresh,nMontoBs)
  LOCAL aLine   :=oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt]
  LOCAL aTotales:={}
  LOCAL cWhere
  LOCAL nValCam :=IF(oBALINIDIV:nValCam=0,ROUND(aLine[4]/uValue,2),oBALINIDIV:nValCam)
  LOCAL oDb     :=OpenOdbc(oDp:cDsnData),cSql
  LOCAL cItem   :="",cWhereA
 
  DEFAULT lRefresh:=.T.,;
          nAt     :=oBALINIDIV:oBrw:nArrayAt,;
          nMontoBs:=aLine[4]

  oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,nCol]:=uValue

  IF oBALINIDIV:lValoriza .AND. nMontoBs=0

    IF oBALINIDIV:lVacio
      oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4   ]:=ROUND(uValue*oBALINIDIV:nValCam,2)
      oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,6   ]:=0
    ELSE
      oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,5   ]:=ROUND(uValue*oBALINIDIV:nValCam,2)
      oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,6   ]:=oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,5]-oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4]
    ENDIF

  ELSE

      oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4   ]:=nMontoBs
      oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,6   ]:=0

  ENDIF

  nMontoBs:=oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,4   ]

  EJECUTAR("BRWCALTOTALES",oBALINIDIV:oBrw,.F.)

  oBALINIDIV:oBrw:DrawLine(.T.)

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  cWhere:="CBT_CODSUC"+GetWhere("=",oBALINIDIV:cCodSuc)+" AND "+;
          "CBT_ACTUAL"+GetWhere("=","S"               )+" AND "+;
          "CBT_NUMERO"+GetWhere("=",oBALINIDIV:cNumero)+" AND "+;
          "CBT_FECHA" +GetWhere("=",oBALINIDIV:dFecha )

  IF !ISSQLFIND("DPCBTE",cWhere)

       EJECUTAR("CREATERECORD","DPCBTE",{"CBT_CODSUC"      ,"CBT_ACTUAL","CBT_NUMERO"      ,"CBT_FECHA"      ,"CBT_NUMEJE"      ,"CBT_COMEN1"     },;
                                        {oBALINIDIV:cCodSuc,"S"         ,oBALINIDIV:cNumero,oBALINIDIV:dFecha,oBALINIDIV:cNumEje,"Balance Inicial"},;
       NIL,.T.,cWhere)

  ENDIF

  cWhere:="MOC_CODSUC"+GetWhere("=",oBALINIDIV:cCodSuc)+" AND "+;
          "MOC_NUMCBT"+GetWhere("=",oBALINIDIV:cNumero)+" AND "+;
          "MOC_CUENTA"+GetWhere("=",aLine[1]          )+" AND "+;
          "MOC_ACTUAL"+GetWhere("=","S"               )+" AND "+;
          "MOC_ORIGEN"+GetWhere("=","BAL"             )+" AND "+;
          "MOC_FECHA" +GetWhere("=",oBALINIDIV:dFecha )

  IF nMontoBs=0 .AND. uValue=0
   
    SQLDELETE("DPASIENTOS",cWhere)

  ELSE

   cWhereA:="MOC_CODSUC"+GetWhere("=",oBALINIDIV:cCodSuc)+" AND "+;
            "MOC_ACTUAL"+GetWhere("=","S"               )+" AND "+;
            "MOC_ORIGEN"+GetWhere("=","BAL"             )+" AND "+;
            "MOC_FECHA" +GetWhere("=",oBALINIDIV:dFecha )+" AND "+;
            "MOC_NUMCBT"+GetWhere("=",oBALINIDIV:cNumero)

    cItem:=SQLINCREMENTAL("DPASIENTOS","MOC_ITEM",cWhereA,NIL,NIL,.T.,4)

    EJECUTAR("CREATERECORD","DPASIENTOS",{"MOC_CUENTA","MOC_CODSUC"       ,"MOC_ACTUAL","MOC_NUMCBT","MOC_FECHA"       ,"MOC_NUMEJE"      ,;
                                          "MOC_DESCRI","MOC_VALCAM"       ,"MOC_MTOORG","MOC_CODMON","MOC_CTAMOD"      ,"MOC_MONTO" ,"MOC_ORIGEN","MOC_ITEM"},;
                                          {aLine[1]    ,oBALINIDIV:cCodSuc,"S"         ,oBALINIDIV:cNumero ,oBALINIDIV:dFecha,oBALINIDIV:cNumEje,;
                                          "Balance Inicial",oBALINIDIV:nValCam,uValue,oBALINIDIV:cCodMon,oBALINIDIV:cCtaMod,nMontoBs,"BAL",cItem},;
            NIL,.T.,cWhere)
  ENDIF

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

RETURN .T.

/*
// Calcular Segun Valor de la Divisa
*/
FUNCTION CALCULARDIV()
  LOCAL I,uValue

  FOR I=1 TO LEN(oBALINIDIV:oBrw:aArrayData)

    uValue:= oBALINIDIV:oBrw:aArrayData[I,04]/oBALINIDIV:nValCam
    oBALINIDIV:oBrw:aArrayData[I,03]:=uValue
    oBALINIDIV:oBrw:aArrayData[I,05]:=uValue*oBALINIDIV:nValCam
    oBALINIDIV:oBrw:aArrayData[I,06]:=oBALINIDIV:oBrw:aArrayData[I,5]-oBALINIDIV:oBrw:aArrayData[I,4]

  NEXT I

  EJECUTAR("BRWCALTOTALES",oBALINIDIV:oBrw,.T.)

RETURN .T.

FUNCTION DELBALINI()
   LOCAL cWhere

   IF !MsgNoYes("Desea Remover Balance Inicial "+oBALINIDIV:cNumero+" "+DTOC(oBALINIDIV:dFecha))
      RETURN .T.
   ENDIF

   cWhere:="MOC_CODSUC"+GetWhere("=",oBALINIDIV:cCodSuc)+" AND "+;  
           "MOC_ACTUAL"+GetWhere("=","S"               )+" AND "+;
           "MOC_ORIGEN"+GetWhere("=","BAL"             )+" AND "+;
           "MOC_FECHA" +GetWhere("=",oBALINIDIV:dFecha )+" AND "+;
           "MOC_NUMCBT"+GetWhere("=",oBALINIDIV:cNumero)

   SQLDELETE("DPASIENTOS",cWhere)

   cWhere:="CBT_CODSUC"+GetWhere("=",oBALINIDIV:cCodSuc)+" AND "+;
           "CBT_ACTUAL"+GetWhere("=","S"               )+" AND "+;
           "CBT_NUMERO"+GetWhere("=",oBALINIDIV:cNumero)+" AND "+;
           "CBT_FECHA" +GetWhere("=",oBALINIDIV:dFecha )

   SQLDELETE("DPCBTE",cWhere)

   AEVAL(oBALINIDIV:oBrw:aArrayData,{|a,n| oBALINIDIV:oBrw:aArrayData[n,3]:=0,;
                                           oBALINIDIV:oBrw:aArrayData[n,4]:=0})

   oBALINIDIV:oBrw:Refresh(.F.)

RETURN .T.

FUNCTION MAYOR()
  LOCAL RGO_C1:=oBALINIDIV:cCodSuc,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=SPACE(20),RGO_F1:=SPACE(20),RGO_I2:=NIL,RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oDp:dFchInicio,oDp:dFchCierre,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)

FUNCTION BALCOM()
  LOCAL oGenRep:=NIL,dDesde:=oBALINIDIV:dDesde,dHasta:=oBALINIDIV:dHasta,RGO_C3:=NIL,RGO_C4:=NIL,RGO_C6:=NIL,RGO_I1:=NIL,RGO_F1:=NIL,RGO_I2:=SPACE(20),RGO_F2:=SPACE(20),cCodMon:=NIL

RETURN EJECUTAR("BRWCOMPROBACION",oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon)


FUNCTION PUTMONTOBS(oCol,uValue,nCol,nAt,lRefresh)
  LOCAL nAt:=oBALINIDIV:oBrw:nArrayAt

  oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,nCol  ]:=uValue

  IF oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,3 ]=0
    oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,3  ]:=ROUND(uValue/oBALINIDIV:nValCam,2)
  ENDIF

  oCol:=oBALINIDIV:oBrw:aCols[3]

  oBALINIDIV:PUTMONTO(oCol,oBALINIDIV:oBrw:aArrayData[oBALINIDIV:oBrw:nArrayAt,3],3,NIL,uValue)

  IF oBALINIDIV:oBrw:nArrayAt<LEN(oBALINIDIV:oBrw:aArrayData)
    oBALINIDIV:oBrw:nRowSel++
    oBALINIDIV:oBrw:nArrayAt++
    oBALINIDIV:oBrw:Refresh(.F.) // Drawline(.T.)
  ELSE
    oBALINIDIV:oBrw:Drawline(.T.)
  ENDIF

RETURN .T.


FUNCTION BUSCARLETRA(cLetra)
   LOCAL oBrw  :=oBALINIDIV:oBrw
   LOCAL oCol  :=oBALINIDIV:oBrw:aCols[1]
   LOCAL uValue:=IF(Empty(cLetra),"","%")+cLetra,nLastKey,lExact
   LOCAL cWhere:=NIL

   // Recalcular 
   oBrw:aData:=oBALINIDIV:LEERDATA(cWhere,NIL,NIL,NIL,oBALINIDIV:nValCam,oBALINIDIV:dFecha)

   IF Empty(oBrw:aData)
     oBrw:aData     :=ACLONE(oBrw:aArrayData)
     oBrw:lSetFilter:=.F.
   ENDIF

   oBrw:nColSel:=1
  
   EJECUTAR("BRWFILTER",oCol,uValue,nLastKey,lExact)

RETURN .T.
/*
// Guadar el valor de la divisa y recalcular el balance inicial
*/
FUNCTION VALDIVISA()

    EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO"   ,"HMN_FECHA"         ,"HMN_VALOR"          ,"HMN_HORA " },;
                                       {oDp:cMonedaBcv,oBALINIDIV:dFecha,oBALINIDIV:nValCam  ,"00:00:00"},;
                                        NIL,.T.,"HMN_CODIGO"+GetWhere("=",oDp:cMonedaExt)+" AND HMN_FECHA"+GetWhere("=",oBALINIDIV:dFecha))

RETURN .T.

// EOF

