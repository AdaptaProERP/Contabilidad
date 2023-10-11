// Programa   : BCANUAL	
// Fecha/Hora : 25/07/2023 17:08:32
// Propósito  : Explorar BALANCE DE COMPROBACION TODOS LOS EJERCICIOS
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCta)
 LOCAL aData:={}
 LOCAL cTitle:="Resultado de los Ejercicios Contables",cWhere_:=""
 LOCAL nLen  :=0,cWhere:="",aBG:={},cTitBG:="",aGyP:={},cTiTGyP:=""

 AADD(aBG,oDp:cCtaBg1)
 AADD(aBG,oDp:cCtaBg2)
 AADD(aBG,oDp:cCtaBg3)

 AEVAL(aBG,{|a,n| cTitBG:=cTitBG+IF(Empty(cTitBG),"",",")+a})

 AADD(aGyP,oDp:cCtaGp1)
 AADD(aGyP,oDp:cCtaGp2)
 AADD(aGyP,oDp:cCtaGp3)
 AADD(aGyP,oDp:cCtaGp4)
 AADD(aGyP,oDp:cCtaGp5)
 AADD(aGyP,oDp:cCtaGp6)

 ADEPURA(aGyP,{|a,n| Empty(a) .OR. LEN(a)>2})

 AEVAL(aGyP,{|a,n| cTiTGyP:=cTiTGyP+IF(Empty(cTiTGyP),"",",")+a})

 DEFAULT cCodCta:=""

 cCodCta:=ALLTRIM(cCodCta)
 nLen   :=LEN(cCodCta)

 IF nLen>0
    cWhere:=[LEFT(MOC_CUENTA,]+LSTR(nLen)+[)]+GetWhere("=",cCodCta)
 ENDIF

 aData:=LEERDATA(NIL,cWhere)

 IF Empty(aData) 
    EJECUTAR("DPCBTEFIX")
    EJECUTAR("DPCBTEFIX2")
    aData:=LEERDATA()
 ENDIF

 IF Empty(aData) 
    MsgMemo("No hay Registros en los Asientos Contables")
    RETURN .T.
 ENDIF

 ViewData(aData,cTitle)

RETURN aData

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oBREJERTOTAL","BREJERTOTAL.EDT")
   oBREJERTOTAL:Windows(0,0,aCoors[3]-160,MIN(1496,aCoors[4]-10),.T.) // Maximizado

   oBREJERTOTAL:lMsgBar  :=.F.
   oBREJERTOTAL:cCodSuc  :=oDp:cSucursal
   oBREJERTOTAL:cNombre  :=""
   oBREJERTOTAL:cWhere   :=cWhere
   oBREJERTOTAL:cWhere_  :=""
   oBREJERTOTAL:cWhereQry:=""
   oBREJERTOTAL:cSql     :=oDp:cSql
   oBREJERTOTAL:oWhere   :=TWHERE():New(oBREJERTOTAL)
   oBREJERTOTAL:cCodPar  :=""
   oBREJERTOTAL:lWhen    :=.T.
   oBREJERTOTAL:cTextTit :="" // Texto del Titulo Heredado
   oBREJERTOTAL:oDb      :=oDp:oDb
   oBREJERTOTAL:cBrwCod  :=""
   oBREJERTOTAL:lTmdi    :=.T.
   oBREJERTOTAL:aHead    :={}
   oBREJERTOTAL:lBarDef  :=.T.     // Activar Modo Diseño.
   oBREJERTOTAL:cCodCta  :=cCodCta // Cuenta contable

   // Guarda los parámetros del Browse cuando cierra la ventana
   oBREJERTOTAL:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBREJERTOTAL)}

   oBREJERTOTAL:lBtnRun     :=.F.
   oBREJERTOTAL:lBtnMenuBrw :=.F.
   oBREJERTOTAL:lBtnSave    :=.F.
   oBREJERTOTAL:lBtnCrystal :=.F.
   oBREJERTOTAL:lBtnRefresh :=.T.
   oBREJERTOTAL:lBtnHtml    :=.T.
   oBREJERTOTAL:lBtnExcel   :=.T.
   oBREJERTOTAL:lBtnPreview :=.T.
   oBREJERTOTAL:lBtnQuery   :=.F.
   oBREJERTOTAL:lBtnOptions :=.T.
   oBREJERTOTAL:lBtnPageDown:=.T.
   oBREJERTOTAL:lBtnPageUp  :=.T.
   oBREJERTOTAL:lBtnFilters :=.T.
   oBREJERTOTAL:lBtnFind    :=.T.
   oBREJERTOTAL:lBtnColor   :=.T.

   oBREJERTOTAL:nClrPane1:=16775408
   oBREJERTOTAL:nClrPane2:=16771797

   oBREJERTOTAL:nClrText :=0
   oBREJERTOTAL:nClrText1:=0
   oBREJERTOTAL:nClrText2:=0
   oBREJERTOTAL:nClrText3:=0

   oBREJERTOTAL:oBrw:=TXBrowse():New( IF(oBREJERTOTAL:lTmdi,oBREJERTOTAL:oWnd,oBREJERTOTAL:oDlg ))
   oBREJERTOTAL:oBrw:SetArray( aData, .F. )
   oBREJERTOTAL:oBrw:SetFont(oFont)

   oBREJERTOTAL:oBrw:lFooter     := .T.
   oBREJERTOTAL:oBrw:lHScroll    := .T.
   oBREJERTOTAL:oBrw:nHeaderLines:= 3
   oBREJERTOTAL:oBrw:nDataLines  := 1
   oBREJERTOTAL:oBrw:nFooterLines:= 1

  oBREJERTOTAL:aData            :=ACLONE(aData)

  AEVAL(oBREJERTOTAL:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  // Campo: DOC_NUMERO
  oCol:=oBREJERTOTAL:oBrw:aCols[1]
  oCol:cHeader      :='Núm.'+CRLF+"Ejer."
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 50


  oCol:=oBREJERTOTAL:oBrw:aCols[2]
  oCol:cHeader      :='Fecha'+CRLF+'Desde'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 74

  oCol:=oBREJERTOTAL:oBrw:aCols[3]
  oCol:cHeader      :='Fecha'+CRLF+'Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 74

  oCol:=oBREJERTOTAL:oBrw:aCols[4]
  oCol:cHeader      :='Saldo'+CRLF+'Anterior'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,4],;
                              oCol   := oBREJERTOTAL:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}
//  oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)


  oCol:=oBREJERTOTAL:oBrw:aCols[5]
  oCol:cHeader      :='Monto'+CRLF+'Debe'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,5],;
                              oCol  := oBREJERTOTAL:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)

  oCol:=oBREJERTOTAL:oBrw:aCols[6]
  oCol:cHeader      :='Monto'+CRLF+'Haber'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,6],;
                              oCol  := oBREJERTOTAL:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)

  oCol:=oBREJERTOTAL:oBrw:aCols[7]
  oCol:cHeader      :='Monto'+CRLF+'Saldo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,7],;
                              oCol  := oBREJERTOTAL:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
//  oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


  oCol:=oBREJERTOTAL:oBrw:aCols[8]
  oCol:cHeader      :='Resultado'+CRLF+'Ejercicio'+CRLF+cTiTGyP
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,8],;
                              oCol  := oBREJERTOTAL:oBrw:aCols[8],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[8],oCol:cEditPicture)

  oCol:=oBREJERTOTAL:oBrw:aCols[9]
  oCol:cHeader      :='Balance'+CRLF+'General'+CRLF+cTitBG
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,9],;
                              oCol  := oBREJERTOTAL:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[9],oCol:cEditPicture)

  oCol:=oBREJERTOTAL:oBrw:aCols[10]
  oCol:cHeader      :='Asientos'+CRLF+'Cierre'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,10],;
                              oCol  := oBREJERTOTAL:oBrw:aCols[10],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[10],oCol:cEditPicture)


  oCol:=oBREJERTOTAL:oBrw:aCols[11]
  oCol:cHeader      :='Cant.'+CRLF+'Asientos'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,11],;
                              oCol  :=  oBREJERTOTAL:oBrw:aCols[11],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[11],oCol:cEditPicture)

  oCol:=oBREJERTOTAL:oBrw:aCols[12]
  oCol:cHeader      :='#Cbte.'+CRLF+'<>0'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBREJERTOTAL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,12],;
                              oCol  := oBREJERTOTAL:oBrw:aCols[12],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[12],oCol:cEditPicture)



  oCol:=oBREJERTOTAL:oBrw:aCols[12+1]
  oCol:cHeader      :='Sel'
  oCol:nWidth       := 40
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")


  oCol:bBmpData    := {|oBrw|oBrw:=oBREJERTOTAL:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,12+1],1,2) }
  oCol:bLDClickData:= {||oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,12+1]:=!oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt,12+1],oBREJERTOTAL:oBrw:DrawLine(.T.)} 
  oCol:bStrData    := {||""}
  oCol:bLClickHeader:={||oDp:lSel:=!oBREJERTOTAL:oBrw:aArrayData[1,12+1],; 
                       AEVAL(oBREJERTOTAL:oBrw:aArrayData,{|a,n| oBREJERTOTAL:oBrw:aArrayData[n,12+1]:=oDp:lSel}),oBREJERTOTAL:oBrw:Refresh(.T.)} 


  oBREJERTOTAL:oBrw:bLDblClick:=oCol:bLDClickData



   oBREJERTOTAL:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oBREJERTOTAL:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oBREJERTOTAL:nClrText,;
                                                 nClrText:=IF(.F.,oBREJERTOTAL:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oBREJERTOTAL:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oBREJERTOTAL:nClrPane1, oBREJERTOTAL:nClrPane2 ) } }

   oBREJERTOTAL:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBREJERTOTAL:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oBREJERTOTAL:oBrw:bLDblClick:={|oBrw|oBREJERTOTAL:RUNCLICK() }

   oBREJERTOTAL:oBrw:bChange:={||oBREJERTOTAL:BRWCHANGE()}
   oBREJERTOTAL:oBrw:CreateFromCode()

   oBREJERTOTAL:oWnd:oClient := oBREJERTOTAL:oBrw

   oBREJERTOTAL:Activate({||oBREJERTOTAL:ViewDatBar()})

   oBREJERTOTAL:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBREJERTOTAL:lTmdi,oBREJERTOTAL:oWnd,oBREJERTOTAL:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oBREJERTOTAL:oBrw:nWidth()

   oBREJERTOTAL:oBrw:GoBottom(.T.)
   oBREJERTOTAL:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRPEDAPROBAR.EDT")
//     oBREJERTOTAL:oBrw:Move(44,0,1496+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
//   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBtnHeight OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -09 BOLD

 // Emanager no Incluye consulta de Vinculos

   IF .F. .AND. Empty(oBREJERTOTAL:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oBREJERTOTAL:oBrw,oBREJERTOTAL:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Cierre";
            ACTION oBREJERTOTAL:CERRAR()

  oBtn:cToolTip:="Cerrar Ejercicio"

  
  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Resumen";
            FILENAME "BITMAPS\XBROWSE.BMP";
            ACTION oBREJERTOTAL:VERDETALLES()

   oBtn:cToolTip:="Resumido por Mes"

 

  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXPORTS.BMP";
            TOP PROMPT "Exportar";
            ACTION oBREJERTOTAL:EXPORTAR()

   oBtn:cToolTip:="Exportar hacia Tabla DBF"


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Importar";
            FILENAME "BITMAPS\IMPORTAR.BMP";
            ACTION  oBREJERTOTAL:EXPORTAR(.F.)

   oBtn:cToolTip:="Importar Asientos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIDAD.BMP";
          TOP PROMPT "Asientos";
          ACTION oBREJERTOTAL:BRASIENTOACTRES()

   oBtn:cToolTip:="Resumido por Cuenta Contable"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BUG.BMP";
          TOP PROMPT "Descuadre";
          ACTION oBREJERTOTAL:ASIENTOSDESC()

   oBtn:cToolTip:="Asientos Descuadrados"


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\balancegeneral.BMP";
            TOP PROMPT "B.General";
            ACTION oBREJERTOTAL:BALANCEGEN()

   oBtn:cToolTip:="Balance General"

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Comprob.";
            FILENAME "BITMAPS\balancecomprobacion.BMP";
            ACTION oBREJERTOTAL:BALANCECOM()

   oBtn:cToolTip:="Balance Comprobación"

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Mayor A.";
            FILENAME "BITMAPS\mayoranalitico.BMP";
            ACTION oBREJERTOTAL:MAYORANALITICO()

   oBtn:cToolTip:="Mayor Analítico"


  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Resultado";
            FILENAME "BITMAPS\edodegananciayperdida.bmp";
            ACTION oBREJERTOTAL:GYP()

   oBtn:cToolTip:="Ganancias y Perdidas"


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Eliminar";
            FILENAME "BITMAPS\XDELETE.bmp";
            ACTION oBREJERTOTAL:DELEJERCICIOS()

   oBtn:cToolTip:="Remover Asientos del Ejercicio"


/*
   IF Empty(oBREJERTOTAL:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","PEDAPROBAR")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","PEDAPROBAR"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oBREJERTOTAL:oBrw,"PEDAPROBAR",oBREJERTOTAL:cSql,oBREJERTOTAL:nPeriodo,oBREJERTOTAL:dDesde,oBREJERTOTAL:dHasta,oBREJERTOTAL)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oBREJERTOTAL:oBtnRun:=oBtn



       oBREJERTOTAL:oBrw:bLDblClick:={||EVAL(oBREJERTOTAL:oBtnRun:bAction) }


   ENDIF



IF oBREJERTOTAL:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oBREJERTOTAL");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oBREJERTOTAL:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oBREJERTOTAL:lBtnColor

     oBREJERTOTAL:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Colores";
            MENU EJECUTAR("BRBTNMENUCOLOR",oBREJERTOTAL:oBrw,oBREJERTOTAL,oBREJERTOTAL:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oBREJERTOTAL,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oBREJERTOTAL,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oBREJERTOTAL:oBtnColor:=oBtn

ENDIF



IF oBREJERTOTAL:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oBREJERTOTAL:oBrw,oBREJERTOTAL:oFrm)
ENDIF

IF oBREJERTOTAL:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oBREJERTOTAL),;
                  EJECUTAR("DPBRWMENURUN",oBREJERTOTAL,oBREJERTOTAL:oBrw,oBREJERTOTAL:cBrwCod,oBREJERTOTAL:cTitle,oBREJERTOTAL:aHead));
          WHEN !Empty(oBREJERTOTAL:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oBREJERTOTAL:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oBREJERTOTAL:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oBREJERTOTAL:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Filtrar";
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBREJERTOTAL:oBrw,oBREJERTOTAL);
          ACTION EJECUTAR("BRWSETFILTER",oBREJERTOTAL:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oBREJERTOTAL:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oBREJERTOTAL:oBrw);
          WHEN LEN(oBREJERTOTAL:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oBREJERTOTAL:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Refrescar";
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oBREJERTOTAL:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oBREJERTOTAL:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oBREJERTOTAL)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oBREJERTOTAL:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oBREJERTOTAL:oBrw,oBREJERTOTAL:cTitle,oBREJERTOTAL:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBREJERTOTAL:oBtnXls:=oBtn

ENDIF

IF oBREJERTOTAL:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "HTML";
          FILENAME "BITMAPS\html.BMP";
          ACTION (oBREJERTOTAL:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBREJERTOTAL:oBrw,NIL,oBREJERTOTAL:cTitle,oBREJERTOTAL:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBREJERTOTAL:oBtnHtml:=oBtn

ENDIF


IF oBREJERTOTAL:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Previo";
          ACTION (EJECUTAR("BRWPREVIEW",oBREJERTOTAL:oBrw))

   oBtn:cToolTip:="Previsualización"

   oBREJERTOTAL:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRPEDAPROBAR")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oBREJERTOTAL:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oBREJERTOTAL:oBtnPrint:=oBtn

   ENDIF

IF oBREJERTOTAL:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBREJERTOTAL:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oBREJERTOTAL:oBrw:GoTop(),oBREJERTOTAL:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oBREJERTOTAL:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oBREJERTOTAL:oBrw:PageDown(),oBREJERTOTAL:oBrw:Setfocus())
  ENDIF

  IF  oBREJERTOTAL:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oBREJERTOTAL:oBrw:PageUp(),oBREJERTOTAL:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oBREJERTOTAL:oBrw:GoBottom(),oBREJERTOTAL:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oBREJERTOTAL:Close()

  oBREJERTOTAL:oBrw:SetColor(0,oBREJERTOTAL:nClrPane1)

  oBREJERTOTAL:SETBTNBAR(65,50+8,oBar)


  EVAL(oBREJERTOTAL:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11	 BOLD

  oBREJERTOTAL:oBar:=oBar
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth(),o:ForWhen(.T.) })

  oBREJERTOTAL:oBar:SetSize(NIL,95+10+10,.T.)

  @ 45+25,15 SAY oBREJERTOTAL:oSay PROMPT " Registros " OF oBREJERTOTAL:oBar BORDER PIXEL;
          COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 380,20

  oBREJERTOTAL:nTotal:=0

  @ 66+25,15 METER oBREJERTOTAL:oMeter VAR oBREJERTOTAL:nTotal OF oBREJERTOTAL:oBar PIXEL;
          FONT oFont SIZE 380,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  IF !Empty(oBREJERTOTAL:cCodCta)

     @ 45+25,420 SAY oBREJERTOTAL:oCodCta PROMPT " "+oBREJERTOTAL:cCodCta+" " OF oBREJERTOTAL:oBar BORDER PIXEL;
              COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 120,20

     @ 66+25,420 SAY oBREJERTOTAL:oDescri PROMPT " "+SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oBREJERTOTAL:cCodCta));
              OF oBREJERTOTAL:oBar BORDER PIXEL;
              COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 420,20

  ENDIF

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL aLine :=oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt]
  LOCAL cWhere:=NIL,dDesde:=aLine[2],dHasta:=aLine[3],cTitle:=NIL

  IF oBREJERTOTAL:oBrw:nColSel=12 .AND. aLine[12]<>0
     EJECUTAR("BRPCCBTEDESCU",cWhere,oBREJERTOTAL:cCodSuc,oDp:nEjercicio,dDesde,dHasta,cTitle)
  ENDIF

RETURN .T.  

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oBREJERTOTAL)
RETURN .T.

FUNCTION LEERDATA(oBrw,cWhereCta)
  LOCAL aNumEje:={},aData:={},oTableE,cSql,oTable,oFrm
  LOCAL cWhere :=[(MOC_ACTUAL="S" OR MOC_ACTUAL="A" OR MOC_ACTUAL="C") ]
  LOCAL aBg    :={},aGyP:={},cWhereGyP:="",cWhereBG:="",nCantid:=0
  LOCAL cWhereC:=[ AND MOC_ACTUAL]+GetWhere("=","C")
  LOCAL cWhereI:=[ AND ]+GetWhereOr("MOC_ORIGEN",{"INI","FIN"})

  LOCAL nAt,nRowSel

  AADD(aBG,oDp:cCtaBg1)
  AADD(aBG,oDp:cCtaBg2)
  AADD(aBG,oDp:cCtaBg3)

  ADEPURA(aBG,{|a,n| Empty(a)})

  AEVAL(aBG,{|a,n,nLen,cCta|a       :=ALLTRIM(a),;
                            nLen    :=LEN(a)    ,;
                            cWhereBG:=cWhereBG+IF(Empty(cWhereBG),""," OR ")+;
                            [LEFT(MOC_CUENTA,]+LSTR(nLen)+[)]+GetWhere("=",a)})
   

//  IF !Empty(cWhere
//? cWhereBG,"cWhereBG"

  AADD(aGyP,oDp:cCtaGp1)
  AADD(aGyP,oDp:cCtaGp2)
  AADD(aGyP,oDp:cCtaGp3)
  AADD(aGyP,oDp:cCtaGp4)
  AADD(aGyP,oDp:cCtaGp5)
  AADD(aGyP,oDp:cCtaGp6)

  ADEPURA(aGyP,{|a,n| Empty(a)})

  AEVAL(aGyP,{|a,n,nLen,cCta|a        :=ALLTRIM(a),;
                             nLen     :=LEN(a)    ,;
                             cWhereGyP:=cWhereGyP+IF(Empty(cWhereGyP),""," OR ")+;
                             [LEFT(MOC_CUENTA,]+LSTR(nLen)+[)]+GetWhere("=",a)})

  cWhereGyP:=[(]+cWhereGyP+[)]
  cWhereBG :=[(]+cWhereBG +[)]

  IF !Empty(cWhereCta)
     cWhere:=cWhere+" AND "+cWhereCta
  ENDIF

  CursorWait()

  oFrm:=MSGRUNVIEW("Leyendo Ejercicios Contables","Calculando")


  cSql:=[ SELECT MOC_NUMEJE, EJE_DESDE,EJE_HASTA,0 SLD_ANT,]+;
        [ 0 AS SLD_DEB,]+;
        [ 0 AS SLD_CRE,]+;
        [ 0 AS SLD_TOT,]+;
        [ 0 AS SLD_GYP,]+;
        [ 0 AS SLD_BG ,]+;
        [ 0 AS CIERRE ,]+;
        [ COUNT(*) AS CUANTOS,0 AS CBT_DES,0 AS LOGICO]+;
        [ FROM DPASIENTOS ]+;
        [ INNER JOIN DPEJERCICIOS  ON EJE_NUMERO=MOC_NUMEJE ]+;
        [ WHERE ]+cWhere+;
        [ GROUP BY MOC_NUMEJE ]+;
        [ ORDER BY EJE_HASTA DESC ]

  oTableE:=OpenTable(cSql)

  oFrm:=MSGRUNVIEW("Leyendo Ejercicios Contables","Calculando",oTableE:RecCount())
  oFrm:FRMSETTOTAL(oTableE:RecCount())

  WHILE !oTableE:Eof() 

      oFrm:FRMSET(oTableE:RecNo(),.T.,NIL,LSTR(YEAR(oTableE:EJE_DESDE)))

      cSql:=[ SELECT ]+;
            [ SUM(IF(MOC_FECHA]+GetWhere("<" ,oTableE:EJE_DESDE)+[ ,MOC_MONTO,0)) AS ANTERIOR , ]+;
            [ SUM(IF(MOC_FECHA]+GetWhere(">=",oTableE:EJE_DESDE)+[ AND MOC_FECHA]+GetWhere("<=",oTableE:EJE_HASTA)+[ AND MOC_MONTO>0 , MOC_MONTO   ,0 )) AS DEBE   ,]+;
            [ SUM(IF(MOC_FECHA]+GetWhere(">=",oTableE:EJE_DESDE)+[ AND MOC_FECHA]+GetWhere("<=",oTableE:EJE_HASTA)+[ AND MOC_MONTO<0 , MOC_MONTO*-1,0 )) AS HABER  ,]+;
            [ SUM(IF(MOC_FECHA]+GetWhere("<=",oTableE:EJE_HASTA)+[ ,MOC_MONTO,0)) AS SALDO , ]+;
            [ SUM(IF(MOC_FECHA]+GetWhere(">=",oTableE:EJE_DESDE)+[ AND MOC_FECHA]+GetWhere("<=",oTableE:EJE_HASTA)+[ AND ]+cWhereGyP+[ , MOC_MONTO   ,0 )) AS GYP   ,]+;
            [ SUM(IF(MOC_FECHA]+GetWhere("<=",oTableE:EJE_HASTA)+[ AND ]+cWhereBG+[ , MOC_MONTO   ,0                                                    )) AS BG    ,]+;
            [ SUM(IF(MOC_FECHA]+GetWhere(">=",oTableE:EJE_DESDE)+[ AND MOC_FECHA]+GetWhere("<=",oTableE:EJE_HASTA)        +cWhereC  +[ ,1            ,0 )) AS CIERRE,]+;
            [ 0 AS CBT_DES ]+CRLF+;
            [ FROM dpasientos ]+;
            [ WHERE ]+cWhere+[ AND MOC_FECHA]+GetWhere("<=",oTableE:EJE_HASTA)

     oTable :=OpenTable(cSql,.T.)
     nCantid:=0

     IF oTable:BG<>0
        nCantid:=COUNT("VIEW_DPCBTESLD",GetWhereAnd("CBT_FECHA",oTableE:EJE_DESDE,oTableE:EJE_HASTA))
     ENDIF

     oTableE:Replace("SLD_ANT",oTable:ANTERIOR)
     oTableE:Replace("SLD_DEB",oTable:DEBE    )
     oTableE:Replace("SLD_CRE",oTable:HABER   )
     oTableE:Replace("SLD_TOT",oTable:SALDO   )
     oTableE:Replace("SLD_GYP",oTable:GYP     )
     oTableE:Replace("SLD_BG" ,oTable:BG      )
     oTableE:Replace("CIERRE" ,oTable:CIERRE  )
     oTableE:Replace("CBT_DES",nCantid  )
     oTableE:Replace("LOGICO" ,.F.            )
     oTableE:End()

     SysRefresh(.t.)
     oTableE:DbSkip()

  ENDDO

  aData:=ACLONE(oTableE:aDataFill)
  oTableE:End()

  oFrm:FRMCLOSE()

  IF ValType(oBrw)="O"

     oBrw:aArrayData:=ACLONE(aData)
     EJECUTAR("BRWCALTOTALES",oBrw,.F.)

     nAt    :=oBrw:nArrayAt
     nRowSel:=oBrw:nRowSel

     oBrw:Refresh(.F.)
     oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
     oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
     AEVAL(oBREJERTOTAL:oBar:aControls,{|o,n| o:ForWhen(.T.)})

  ENDIF

RETURN aData

FUNCTION CERRAR()
  LOCAL aLine:=oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt]
  LOCAL dDesde:=aLine[2]
  LOCAL dHasta:=aLine[3]

  EJECUTAR("CIERRECONTABLE20",NIL,dDesde,dHasta)

RETURN .T.


/*
// Genera Correspondencia Masiva
*/

FUNCTION EXPORTAR(lExport)
  LOCAL aSelect:={},cSql,oData,cWhere:="",aNumEje:={},cTitle:=""

  DEFAULT lExport:=.T.

  IF lExport

    cTitle:="Exportar Comprobantes Contables"

    AEVAL(oBREJERTOTAL:oBrw:aArrayData,{|a,n| IIF(a[12+1],AADD(aNumEje,a[1]),NIL)})

    IF EMPTY(aNumEje) 
      MensajeErr("No hay Comprobantes Seleccionados")
      RETURN .F.
    ENDIF
 
    cWhere:=GetWhereOr("CBT_NUMEJE",aNumEje)

    cSql:="SELECT * FROM DPCBTE WHERE "+cWhere

  ELSE

    cTitle:="Importar Comprobantes Contables"

  ENDIF

//  cSql :=cSql+CRLF+"ORDER BY CONCAT(CBT_FECHA,CBT_NUMERO) "

  oData:=DATASET("CBTEXPORT","PC")

  oEdit:=DPEDIT():New(cTitle,"forms\EXPPRG.edt","oEdit",.T.)
 
  oEdit:nCantid:=LEN(aNumEje)
  oEdit:nRecord:=0
  oEdit:oMeterT:=NIL
  oEdit:oMeterR:=NIL
  oEdit:cSql   :=cSql
  oEdit:cDir   :=PADR(oData:Get("CPATH","C:"),90)          // Días disfrutados  
  oData:End()
  oEdit:cDir   :=STRTRAN(oEdit:cDir  ,"\\","\")
  oEdit:lZip   :=.T.
  oEdit:lMsgBar:=.F.
  oEdit:lBmp   :=.F. // Incluir imágenes BMP
  oEdit:lExport:=lExport

  @ 03,02 SAY "Carpeta del Archivo "+IF(lExport,"Destino:","Origen:")
  @ 04,01 SAY "Cantidad:"
  @ 04,12 SAY " "+STRZERO(oEdit:nCantid,4)+"/"+STRZERO(Len(oBREJERTOTAL:oBrw:aArrayData),4)+" " 

  @ 03,02 SAY oEdit:oSayRecord PROMPT "Registros: "

  @ 01,01 BMPGET oEdit:oDir VAR oEdit:cDir NAME "BITMAPS\FOLDER5.BMP";
                          ACTION (cDir:=cGetDir(oEdit:cDir),;
                          IIF(!EMPTY(cDir),oEdit:cDir:=PADR(cDir,90),NIL),DPFOCUS(oEdit:oDir))

  @ 02,01 METER oEdit:oMeterR VAR oEdit:nRecord

  @ 6,07 BUTTON oEdit:oBtnRun PROMPT "Iniciar " ACTION IF(oEdit:lExport,oEdit:EXPORTRUN(oEdit),oEdit:IMPORTRUN(oEdit))
  @ 6,10 BUTTON "Cerrar  " ACTION (oEdit:Close()) CANCEL

  IF lExport
    @ 2,50 CHECKBOX oEdit:lZip PROMPT ANSITOOEM("Generar DPCBTE.ZIP")
  ENDIF

  oEdit:Activate(NIL)

  aSelect:=NIL

RETURN NIL

/*
// Iniciar Exportar Programas
*/
FUNCTION EXPORTRUN(oEdit)
   LOCAL cFileDbf,oData,oCursor,cError:="",aFiles:={},cFileZip,cPass,aFileEdt:={}
   LOCAL aFileBmp:={},cFile:="",cInner,cSql,cSqlC,cWhere
   LOCAL cFileDbfA:=NIL
   LOCAL cFileDbfC:=NIL,nAt,nTotal

   oEdit:cDir:=STRTRAN(ALLTRIM(oEdit:cDir)," ","")
   oEdit:cDir:=PADR(oEdit:cDir+IIF(Right(oEdit:cDir,1)="\","","\"),90)

   cFileDbf  :=ALLTRIM(oEdit:cDir)+"DPCBTE.DBF"
   cFileDbfA :=ALLTRIM(oEdit:cDir)+"DPASIENTOS.DBF"
   cFileDbfC :=ALLTRIM(oEdit:cDir)+"DPCTA.DBF"

   cFileZip  :=STRTRAN(cFileDbf,".DBF",".ZIP")

   lmkdir(oEdit:cDir)

   FERASE(cFileDbf)
   FERASE(cFileZip)

   IF FILE(cFileDbf) .OR. FILE(cFileZip)
      MensajeErr("Fichero "+cFileDbf+" posiblemente esta abierto o Protegido")
      RETURN .F.
   ENDIF

   // Grabar DataSet
   oData:=DATASET("CBTEXPORT","PC")
   oData:SET("cPath",ALLTRIM(oEdit:cDir))
   oData:End()

   // Exporta los Datos
   oEdit:oBtnRun:Disable()

   oEdit:oSayRecord:SetText("Copiando Comprobantes ")

   DPWRITE("TEMP\DPCBTE.SQL",oEdit:cSql)

   oCursor:=OpenTable(oEdit:cSql,.T.)
   oCursor:GoTop()
   IF !oCursor:CTODBF(cFileDbf,NIL,oEdit:oMeterR,oEdit:oSayRecord,@cError)
      MensajeErr(cError,"No pudo Exportar Programas")
   ENDIF
   oCursor:End()


   cSql:=oEdit:cSql
   cSql:=STRTRAN(cSql,"DPCBTE"    ,"DPASIENTOS")
   cSql:=STRTRAN(cSql,"CBT_NUMERO","MOC_NUMCBT")
   cSql:=STRTRAN(cSql,"CBT_"      ,"MOC_")
   cSqlC:=cSql
// 01/08/2023 debe asegurar el orden original de los datos   cSql:=cSql+" ORDER BY MOC_CODSUC,MOC_FECHA,MOC_NUMCBT,MOC_ACTUAL,MOC_ITEM"

   nAt   :=AT(" WHERE ",cSql)
   cWhere:=SUBS(cSql,nAt,LEN(cSql))
   nTotal:=COUNT("DPASIENTOS",cWhere)

   oEdit:oSayRecord:SetText("Copiando Asientos ")
   DPWRITE("TEMP\DPASIENTOS.SQL",cSql)

   oCursor:=EJECUTAR("OPENTABLEPAG2",cSql,5000,"Leyendo Asientos",NIL,nTotal,oEdit:oSayRecord,oEdit:oMeterR)
// oCursor:=OpenTable(cSql,.T.)
   oCursor:GoTop()
   IF !oCursor:CTODBF(cFileDbfA,NIL,oEdit:oMeterR,oEdit:oSayRecord,@cError)
      MensajeErr(cError,"No pudo Exportar Programas")
   ENDIF
   oCursor:End()

   /*
   // Plan de Cuentas
   */
   oEdit:oSayRecord:SetText("Copiando Cuentas ")

   cSql  :=cSqlC
   cInner:="  INNER JOIN DPASIENTOS ON MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO  "
   nAt   :=AT(" WHERE ",cSql)
   cSql  :=SELECTFROM("DPCTA",.T.)+SUBS(cSql,nAt,LEN(cSql))
   cSql  :=STRTRAN(cSql," WHERE ",cInner+" WHERE ")+" GROUP BY CTA_CODMOD,MOC_CUENTA"

   DPWRITE("TEMP\DPCTA.SQL",cSql)

   oCursor:=OpenTable(cSql,.T.)
   oCursor:GoTop()
   IF !oCursor:CTODBF(cFileDbfC,NIL,oEdit:oMeterR,oEdit:oSayRecord,@cError)
      MensajeErr(cError,"No pudo Exportar Programas")
   ENDIF
   oCursor:End()

   aFiles:={}
   AADD(aFiles,cFileDbf )
   AADD(aFiles,cFileDbfA)
   AADD(aFiles,cFileDbfC)

   AADD(aFiles,STRTRAN(cFileDbf,".DBF",".FPT"))

   // Comprime el Archivo
   HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

   oEdit:oSayRecord:SetText("Exportación Finalizada")

   IF !EMPTY(cError)
      MensajeErr("Comprobantes Contables "+cFileDbf,"Mensaje")
      oEdit:Close()
   ELSE
      oEdit:oBtnRun:Enable()
   ENDIF

   CursorArrow()

RETURN .T.

FUNCTION DELEJERCICIOS()
  LOCAL cWhere:="",aNumEje:={},aTablas:={},aData:={}
  LOCAL cSql
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)
  LOCAL cId:=F6(oDp:dFecha)+"_"+RIGHT(STRTRAN(oDp:cHora,":",""),4)
  LOCAL I,nAt,nRowSel

  AEVAL(oBREJERTOTAL:oBrw:aArrayData,{|a,n| IIF(a[12+1],AADD(aNumEje,a[1]),NIL)})

  IF EMPTY(aNumEje) 
     MensajeErr("No hay Comprobantes Seleccionados")
     RETURN .F.
  ENDIF

  IF !MsgNoYes("Desea Remover Asientos Contable de "+LSTR(LEN(aNumEje))+" Ejercicios")
     RETURN .T.
  ENDIF
  
  cWhere:=GetWhereOr("CBT_NUMEJE",aNumEje)

  AADD(aTablas,{"DPASIENTOS",GetWhereOr("MOC_NUMEJE",aNumEje)})
  AADD(aTablas,{"DPCBTE"    ,GetWhereOr("CBT_NUMEJE",aNumEje)})

  CursorWait()

  FOR I=1 TO LEN(aTablas)
 
     cWhere:=aTablas[I,2]
    
     cSql:=" CREATE TABLE "+ALLTRIM(aTablas[I,1])+"_COPY_"+cId+" AS SELECT * FROM "+ALLTRIM(aTablas[I,1])+" WHERE "+cWhere
     oDb:Execute(cSql)

     cSql:=" DELETE FROM "+aTablas[I,1]+" WHERE "+cWhere
     oDb:Execute(cSql)

  NEXT I

  aData:=oBREJERTOTAL:LEERDATA(oBREJERTOTAL:oBrw)

  IF Empty(aData)
     oBREJERTOTAL:Close()
  ENDIF

RETURN .T.

FUNCTION IMPORTRUN(oEdit)
  LOCAL cFile,cDir:=ALLTRIM(oEdit:cDir),cFileZip,cFile
  LOCAL nCant
  LOCAL aData:={} // Todo el Archivo
  LOCAL oData :=NIL,oSay:=NIL,cFileA

  oEdit:Close()

  cDir  :=cDir+IIF(RIGHT(cDir,1)="\","","\")
  cFile :=cDir+"DPCBTE.dbf"
  cFileA:=cDir+"DPASIENTOS.dbf"

  ferase(cFile)
  ferase(cFileA)

  cFileZip:=STRTRAN(cFile,".dbf",".zip")

  IF FILE(cFileZip)
     ferase(cFile)
     HB_UNZIPFILE( cFileZip , {|| nil }, .t., NIL, cDir , NIL )
  ENDIF

  IF !FILE(cFile) 
     MensajeErr(cFile,"Archivo no Existe")
     RETURN .F.
  ENDIF

  CLOSE ALL
  USE (cFile) 
  nCant:=RECCOUNT()
  CLOSE ALL

  IF !MsgNoYes("Desea Importar "+LSTR(nCant)+" Comprobantes")
     RETURN .F.
  ENDIF


  CursorWait()

  EJECUTAR("IMPORTDBF32","DPCBTE"    ,cFile ,oDp:cDsnData,oBREJERTOTAL:oSay,.T.,.T.,NIL,.T.,oBREJERTOTAL:oMeter)
  EJECUTAR("IMPORTDBF32","DPASIENTOS",cFileA,oDp:cDsnData,oBREJERTOTAL:oSay,.T.,.T.,NIL,.T.,oBREJERTOTAL:oMeter)

  aData:=oBREJERTOTAL:LEERDATA(oBREJERTOTAL:oBrw)

  IF Empty(aData)
     oBREJERTOTAL:Close()
  ENDIF

RETURN .T.

FUNCTION MAYORANALITICO()
 LOCAL aLine :=oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt]
 LOCAL dDesde:=aLine[2],dHasta:=aLine[3]
 LOCAL RGO_C1:=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=oBREJERTOTAL:cCodCta,RGO_F1:=oBREJERTOTAL:cCodCta,RGO_I2:=NIL,RGO_F2:=NIL

RETURN EJECUTAR("BRWMAYORANALITICO",NIL,dDesde,dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)
 
// RETURN EJECUTAR("BRWMAYORANALITICO",NIL,dDesde,dHasta)

FUNCTION BRASIENTOACTRES()
 LOCAL cWhere:=NIL,cCodSuc:=NIL,cTitle:=NIL
 LOCAL aLine :=oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt]
 LOCAL dDesde:=aLine[2],dHasta:=aLine[3]

RETURN EJECUTAR("BRASIENTOACTRES",cWhere,cCodSuc,oDp:nEjercicio,dDesde,dHasta,cTitle)

FUNCTION VERDETALLES()
  LOCAL aLine  :=oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt]
  LOCAL dDesde :=aLine[2],dHasta:=aLine[3]
  LOCAL cWhere :=NIL,cCodSuc:=NIL,nPeriodo:=NIL,dDesde,dHasta,cTitle,cActual:={"S","A","C"},lDelete:=.f.
  LOCAL cCodCta:=oBREJERTOTAL:cCodCta
  LOCAL nLen   :=LEN(cCodCta)

  cWhere:=GetWhereOr("MOC_ACTUAL",cActual)

  IF !Empty(cCodCta)
     cWhere:=cWhere+[ AND LEFT(MOC_CUENTA,]+LSTR(nLen)+[)]+GetWhere("=",cCodCta)
  ENDIF

  EJECUTAR("BRDPASIENTOS",cWhere,cCodSuc,oDp:nEjercicio,dDesde,dHasta,cTitle,cCodCta,cActual,lDelete)

RETURN NIL


FUNCTION BALANCECOM()
  LOCAL aLine  :=oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt]
  LOCAL dDesde :=aLine[2],dHasta:=aLine[3]

RETURN EJECUTAR("BRWCOMPROBACION",NIL,dDesde,dHasta,NIL,NIL,NIL,NIL,NIL,oBREJERTOTAL:cCodCta,oBREJERTOTAL:cCodCta)

FUNCTION BALANCEGEN()

? "BALANCEGEN"
RETURN .T.

FUNCTION GYP()
  LOCAL aLine  :=oBREJERTOTAL:oBrw:aArrayData[oBREJERTOTAL:oBrw:nArrayAt]
  LOCAL dDesde :=aLine[2],dHasta:=aLine[3]
  LOCAL oGenRep:=NIL,RGO_C3 :=NIL,RGO_C4:=NIL,RGO_C6:=NIL,RGO_I1:=NIL,RGO_F1:=NIL,RGO_I2:=NIL,RGO_F2:=NIL,cCodMon:=NIL

  EJECUTAR("BRWGANANCIAYP",oGenRep,dDesde,dHasta,RGO_C3,RGO_C4,RGO_C6,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon)
RETURN .T.       

FUNCTION BRWREFRESCAR()

  LOCAL aData:=oBREJERTOTAL:LEERDATA(oBREJERTOTAL:oBrw,oBREJERTOTAL:cWhere)

RETURN .T.

/*
// Asientos Descuadradis
*/
FUNCTION ASIENTOSDESC()
  LOCAL cWhere:=NIL,cCodSuc:=oDp:cSucursal,nPeriodo:=oDp:nIndefinida,dDesde:=CTOD(""),dHasta:=CTOD(""),cTitle:="Comprobantes Descuadrados"

RETURN EJECUTAR("BRPCCBTEDESCU",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
// EOF
