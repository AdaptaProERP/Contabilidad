// Programa   : DPBCOVIEWCON
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Visualizar Asiento Contables   
// Creado Por : Juan Navas
// Llamado por: DPDOCCONTAB
// Aplicación : Ventas
// Tabla      : DPASIENTOS

#INCLUDE "DPXBASE.CH"
#INCLUDE "SAYREF.CH"

PROCE MAIN(cNumCbt,cCodSuc,cTipDoc,cCodBco,cCtaBco,cNumero,cOrg,cTipTra,dFecha)
  LOCAL oData,cSql,oTable,aData,cTitle,aTotal
  LOCAL nSaldo   :=0,nDebe:=0,nHaber:=0,cActual
  LOCAL oBrw,oCol,oFont,oFontG,oFontB,oSayRef
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="CHQ"        ,;
          cCodBco:=STRZERO(1,06),;
          cCtaBco:="10202030"   ,;
          cNumCbt:=STRZERO(1,08),;
          cNumero:="1"          ,;
          cOrg   :="BCO",;
          cTipTra:="B",;
          dFecha :=oDp:dFecha-1

  cSql:="SELECT MOC_CUENTA,CTA_DESCRI,MOC_DESCRI,"+;
        " IF(MOC_MONTO>0,MOC_MONTO   ,0) AS DEBE ,"+;
        " IF(MOC_MONTO<0,MOC_MONTO*-1,0) AS HABER,"+;
        " 0 AS SALDO,MOC_ACTUAL "+;
        " FROM DPASIENTOS "+;
        "INNER JOIN DPCTA ON MOC_CUENTA=CTA_CODIGO AND MOC_CTAMOD=CTA_CODMOD "+;
        "WHERE "+;
        "MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
        "MOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
        "MOC_TIPO  "+GetWhere("=",cTipDoc)+" AND "+;
        "MOC_DOCUME"+GetWhere("=",cNumero)+" AND "+;
        "MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
        "MOC_TIPTRA"+GetWhere("=",cTipTra)+" AND "+;
        "MOC_ORIGEN"+GetWhere("=",cOrg   )+" AND "+;
        "MOC_MONTO<>0 "+;
        ""

  oTable:=OpenTable(cSql,.T.)

// ? CLPCOPY(oDp:cSql)

  nHaber:=0
  cActual:=oTable:MOC_ACTUAL

  WHILE !oTable:Eof()

    nSaldo:=nSaldo+oTable:DEBE-oTable:HABER

/*
    // nSaldo:=VAL(STR(nSaldo))

    IF oTable:DEBE<0
       oTable:Replace("HABER",oTable:DEBE*-1)
       oTable:Replace("DEBE" ,0)
       nHaber:=nHaber+oTable:HABER
    ELSE
       oTable:Replace("HABER",0)
    ENDIF

    nDebe :=nDebe +oTable:DEBE  
*/  
    oTable:Replace("SALDO",nSaldo)
    oTable:DbSkip()

  ENDDO

  aData:=oTable:aDataFill

  aTotal:=ATOTALES(aData)

  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Transacción no Posee Asientos Contables ")
     RETURN .F.
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//   DPEDIT():New("Asientos Contables de ["+cTipDoc+" "+cNumero+"]","DPDOCVIEWCON.EDT","oDocViewCon",.T.)


  cTitle:="Asientos Contables del Movimiento Bancario" // ["+cTipDoc+" "+cNumero+"]"

  DpMdi(cTitle,"oDocViewCon","DPDOCVIEWCON.EDT")
  oDocViewCon:Windows(0,0,aCoors[3]-160,MIN(1252,aCoors[4]-10),.T.) // Maximizado

  oDocViewCon:cTipDoc   :=cTipDoc
  oDocViewCon:cNumero   :=cNumero
  oDocViewCon:cNumCbt   :=cNumCbt
  oDocViewCon:dFecha    :=dFecha 
  oDocViewCon:cPictureM :="999,999,999,999.99"
  oDocViewCon:cCodigo   :=cCodBco
  oDocViewCon:aData     :=ACLONE(aData)
  oDocViewCon:cActual   :=cActual
  oDocViewCon:cOrg      :=cOrg
  oDocViewCon:cCodSuc   :=cCodSuc
  oDocViewCon:cCtaBco   :=cCtaBco
  oDocViewCon:cNombre   :=SQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oDocViewCon:cCodigo))

  oDocViewCon:nClrPane1 :=oDp:nClrPane1
  oDocViewCon:nClrPane2 :=oDp:nClrPane2

/*
  @ 1, 1.0 GROUP oDocViewCon:oGroup TO 11.4,6 PROMPT " Documento ";
           FONT oFontG

  @ 1, 1.0 GROUP oDocViewCon:oGroup TO 11.4,6 PROMPT " Cuenta Contable ";
           FONT oFontG

  @ 1,1 SAY "Comprobante:" RIGHT
  @ 5,1 SAY "Fecha:"       RIGHT
  @ 2,1 SAY "Documento:"   RIGHT
  @ 3,1 SAY "Número:"      RIGHT
  @ 4,1 SAY "Código:"      RIGHT

  @ 1,1 SAYREF oSayRef PROMPT oDocViewCon:cNumCbt;
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris

  oSayRef:bAction:={||oDocViewCon:COBCBTE()}

  @ 1,1 SAYREF oSayRef PROMPT oDocViewCon:cCodigo+"-"+oDocViewCon:cCtaBco;
        RIGHT;
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris

  oSayRef:bAction:={|| EJECUTAR("DPCTABANCOCON",oDocViewCon:cCtaBco,oDocViewCon:cNombre,oDocViewCon:cCodigo )}

  @ 01,1 SAY oDocViewCon:dFecha

  @ 04,1 SAY oDocViewCon:oNombre VAR oDocViewCon:cNombre
  @ 02,1 SAY oDocViewCon:cCtaBco

  @ 03,1 SAY oDocViewCon:cNumero+" "+oDocViewCon:cTipDoc+" "+SQLGET("DPBANCOTIP","TDB_NOMBRE","TDB_CODIGO"+GetWhere("=",oDocViewCon:cTipDoc))

  @ 1,1 SAYREF oDocViewCon:oSayCta PROMPT oDocViewCon:aData[1,6];
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris

  oDocViewCon:oSayCta:bAction:={||EJECUTAR("DPCTACON",NIL,oDocViewCon:aData[oDocViewCon:oBrw:nArrayAt,1])}
*/

  oBrw:=TXBrowse():New( oDocViewCon:oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .T.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 2

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  

  oBrw:aCols[1]:cHeader:="Código"+CRLF+"Cuenta"
  oBrw:aCols[1]:nWidth :=120

  oBrw:aCols[2]:cHeader:="Descripción"+CRLF+"de la Cuenta"
  oBrw:aCols[2]:nWidth :=220


  oBrw:aCols[3]:cHeader:="Descripción"+CRLF+"del Asiento"
  oBrw:aCols[3]:nWidth :=220

  oBrw:aCols[4]:cHeader:="Debe"
  oBrw:aCols[4]:nWidth :=120
  oBrw:aCols[4]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[4]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[4]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[4]:cFooter       := TRAN(aTotal[4],oDocViewCon:cPictureM)
  oBrw:aCols[4]:bStrData      := { |oBrw|oBrw:=oDocViewCon:oBrw,IIF(Empty(oBrw:aArrayData[oBrw:nArrayAt,4]),"",TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oDocViewCon:cPictureM))}
  oBrw:aCols[4]:bClrStd       :={|oBrw,nClrText|oBrw:=oDocViewCon:oBrw,;
                                  nClrText:=CLR_HBLUE,;
                                 {nClrText, iif( oBrw:nArrayAt%2=0, oDocViewCon:nClrPane1 ,oDocViewCon:nClrPane2 ) } }


  oBrw:aCols[5]:cHeader:="Haber"
  oBrw:aCols[5]:nWidth :=120
  oBrw:aCols[5]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[5]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[5]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[5]:cFooter       := TRAN(aTotal[5],oDocViewCon:cPictureM)
  oBrw:aCols[5]:bStrData      := { |oBrw|oBrw:=oDocViewCon:oBrw,IIF(Empty(oBrw:aArrayData[oBrw:nArrayAt,5]),"",TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oDocViewCon:cPictureM))}
//  oBrw:aCols[5]:bStrData      := { |oBrw|oBrw:=oDocViewCon:oBrw,IIF(Empty(oBrw:aArrayData[oBrw:nArrayAt,5]),"",TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oDocViewCon:cPictureM))}


  oBrw:aCols[5]:bClrStd       :={|oBrw,nClrText|oBrw:=oDocViewCon:oBrw,;
                                  nClrText:=CLR_HRED,;
                                 {nClrText, iif( oBrw:nArrayAt%2=0, oDocViewCon:nClrPane1, oDocViewCon:nClrPane2 ) } }

  oBrw:aCols[6]:cHeader:="Saldo"
  oBrw:aCols[6]:nWidth :=120
  oBrw:aCols[6]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[6]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[6]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[6]:cFooter       := TRAN(aTotal[4]-aTotal[5],oDocViewCon:cPictureM)
  oBrw:aCols[6]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oDocViewCon:cPictureM)}

//  oBrw:DelCol(6)

  oBrw:aCols[7]:cHeader:="Tipo"+CRLF+"Cbte."


  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd   :={|oBrw,nMto,nClrText|oBrw:=oDocViewCon:oBrw,nMonto:=oBrw:aArrayData[oBrw:nArrayAt,3],;
                               nClrText:=0,;
                              {nClrText, iif( oBrw:nArrayAt%2=0, oDocViewCon:nClrPane1, oDocViewCon:nClrPane2 ) } }

  oBrw:bLDblClick:={|oBrw|oDocViewCon:RUNCLICK() }

//  oBrw:bLDblClick:={||EVAL(oDocViewCon:oSayCta:bAction)}
//  oBrw:bChange:={||oDocViewCon:oSayCta:SetText(oDocViewCon:aData[oDocViewCon:oBrw:nArrayAt,6])}

  oBrw:SetFont(oFont)

  oBrw:CreateFromCode()

  oDocViewCon:oBrw:=oBrw

  oDocViewCon:oWnd:oClient := oDocViewCon:oBrw

  oDocViewCon:Activate({||oDocViewCon:LeyBar(oDocViewCon)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oDocViewCon)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif,oFontG
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oDocViewCon:oDlg

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD
   
   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   oDocViewCon:oFontBtn   :=oFont    
   oDocViewCon:nClrPaneBar:=oDp:nGris
   oDocViewCon:oBrw:oLbx  :=oDocViewCon

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\contabilidad.BMP";
          TOP PROMPT "Cuenta"; 
          ACTION  oDocViewCon:RUNCLICK()

   oBtn:cToolTip:="Ver Cuenta Contable"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\banco.BMP";
          TOP PROMPT "Banco"; 
          ACTION  oDocViewCon:VERCTABANCO()

   oBtn:cToolTip:="Ver Cuenta Bancaria"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbteactualizado.BMP";
          TOP PROMPT "Cbte"; 
          ACTION  oDocViewCon:DPCBTE()

   oBtn:cToolTip:="Ver Cbte Contable"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          TOP PROMPT "Excel"; 
          ACTION  (EJECUTAR("BRWTOEXCEL",oDocViewCon:oBrw,oDocViewCon:cTitle,oDocViewCon:cNombre+;
                  " Comprobante:"+oDocViewCon:cNumCbt+" del "+DTOC(oDocViewCon:dFecha)))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION  (EJECUTAR("BRWTOHTML",oDocViewCon:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  oDocViewCon:oRep:=REPORTE("ASIENTODIF"),;
                  oDocViewCon:oRep:SetRango(1,oDocViewCon:cNumCbt,oDocViewCon:cNumCbt),;
                  oDocViewCon:oRep:SetRango(2,oDocViewCon:dFecha,oDocViewCon:dFecha),;
                  oDocViewCon:oRep:SetCriterio(5,oDocViewCon:cCodSuc)

   oBtn:cToolTip:="Imprimir Comprobante de Asiento Diferido"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oDocViewCon:oBrw:GoTop(),oDocViewCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          TOP PROMPT "Avance"; 
          ACTION  (oDocViewCon:oBrw:PageDown(),oDocViewCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          TOP PROMPT "Anterior"; 
          ACTION  (oDocViewCon:oBrw:PageUp(),oDocViewCon:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oDocViewCon:oBrw:GoBottom(),oDocViewCon:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oDocViewCon:Close()

  oDocViewCon:oBrw:SetColor(0,oDocViewCon:nClrPane1)

//  @ 0.1,60 SAY oDocViewCon:cTrabajad OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBar:SetSize(NIL,160,.T.)

//  @ 1, 1.0 GROUP oDocViewCon:oGroup TO 11.4,6 PROMPT " Documento ";
//           FONT oFontG
//  @ 1, 1.0 GROUP oDocViewCon:oGroup TO 11.4,6 PROMPT " Cuenta Contable ";
//           FONT oFontG

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD


  @ 70,015 SAY " #Cbte. "     RIGHT OF oBar PIXEL BORDER SIZE 80,20 FONT oFont;
                              COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  @ 92,015 SAY " Fecha "      RIGHT OF oBar PIXEL BORDER SIZE 80,20 FONT oFont;
                              COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  @114,015 SAY " Banco "      RIGHT OF oBar PIXEL BORDER SIZE 80,20 FONT oFont;
                              COLOR oDp:nClrLabelText,oDp:nClrLabelPane


  @136,015 SAY " Documento "  RIGHT OF oBar PIXEL BORDER SIZE 80,20 FONT oFont;
                              COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  @ 70,100 SAY oSayRef PROMPT oDocViewCon:cNumCbt;
           SIZE 80,20;
           FONT oFont;
           OF oBar PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER

  @ 92,100 SAY oDocViewCon:dFecha;
           SIZE 80,20;
           FONT oFont;
           OF oBar PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER


  @ 114,100 SAY " "+oDocViewCon:cCtaBco+" "+oDocViewCon:cNombre+" ";
            SIZE 420,20;
            FONT oFont;
            OF oBar PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER


  @ 136,100 SAY oDocViewCon:cNumero+" "+oDocViewCon:cTipDoc+" "+SQLGET("DPBANCOTIP","TDB_NOMBRE","TDB_CODIGO"+GetWhere("=",oDocViewCon:cTipDoc));
            SIZE 420,20;
            FONT oFont;
            OF oBar PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER


//  @ 92,200 SAY " Número "     RIGHT OF oBar PIXEL BORDER SIZE 80,20 FONT oFont;
//                              COLOR oDp:nClrLabelText,oDp:nClrLabelPane

//  @ 4,1 SAY "Código:"      RIGHT
/*
  @ 70,100 SAY oSayRef PROMPT oDocViewCon:cNumCbt;
           SIZE 80,20;
           FONT oFontB;
           OF oBar PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER
*/
//  oSayRef:bAction:={||oDocViewCon:COBCBTE()}

/*
  @ 1,1 SAY oSayRef PROMPT oDocViewCon:cCodigo+"-"+oDocViewCon:cCtaBco;
        RIGHT;
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris
*/   
//  oSayRef:bAction:={|| EJECUTAR("DPCTABANCOCON",oDocViewCon:cCtaBco,oDocViewCon:cNombre,oDocViewCon:cCodigo )}

//  @ 04,1 SAY oDocViewCon:oNombre VAR oDocViewCon:cNombre
//  @ 02,1 SAY oDocViewCon:cCtaBco
//  @ 03,1 SAY oDocViewCon:cNumero+" "+oDocViewCon:cTipDoc+" "+SQLGET("DPBANCOTIP","TDB_NOMBRE","TDB_CODIGO"+GetWhere("=",oDocViewCon:cTipDoc))

/*
  @ 1,1 SAYREF oDocViewCon:oSayCta PROMPT oDocViewCon:aData[1,6];
        SIZE 42,12;
        FONT oFontB;
        COLORS CLR_HBLUE,oDp:nGris
*/
RETURN .T.

/*
FUNCTION RECIMPRIME(oDocViewCon)
  LOCAL aVar   :={}
  LOCAL oBrw   :=oDocViewCon:oBrw
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[1]

  ? "AQUI DEBE IMPRIMIR EL COMPROBANTE"

  RETURN .T.

  aVar:={oDp:cTipoNom  ,;
         oDp:cOtraNom  ,;
         oDp:cCodTraIni,;
         oDp:cCodTraFin,;
         oDp:cCodGru   ,;
         oDp:dDesde    ,;
         oDp:dHasta    ,;
         oDp:cRecIni   ,;
         oDp:cRecFin    }

  oDP:cTipoNom  :=""
  oDp:cOtraNom  :=""
  oDp:cCodTraIni:=""
  oDp:cCodTraFin:=""
  oDp:cCodGru   :=""
  oDp:dDesde    :=CTOD("")
  oDp:dHasta    :=CTOD("")
  oDp:cRecIni   :=cNumRec
  oDp:cRecFin   :=cNumRec

  REPORTE("RECIBOS")

  oDp:cTipoNom  :=aVar[1]
  oDp:cOtraNom  :=aVar[2]
  oDp:cCodTraIni:=aVar[3]
  oDp:cCodTraFin:=aVar[4]
  oDp:cCodGru   :=aVar[5]
  oDp:dDesde    :=aVar[6]
  oDp:dHasta    :=aVar[7]
  oDp:cRecIni   :=aVar[8]
  oDp:cRecFin   :=aVar[9]

RETURN .T.
*/

FUNCTION COBCBTE()

  EJECUTAR("DPCBTE",oDocViewCon:cActual)

  oCbte:Find()
  oCbte:oCBT_NUMERO:VarPut(oDocViewCon:cNumCbt,.T.)
  oCbte:oCBT_FECHA:VarPut(oDocViewCon:dFecha,.T.)    
  oCbte:oCBT_NUMERO:KeyBoard(13)

RETURN .T.

FUNCTION RUNCLICK()
  LOCAL aLine:=oDocViewCon:oBrw:aArrayData[oDocViewCon:oBrw:nArrayAt]
  
  EJECUTAR("DPCTACON",NIL,aLine[1])

RETURN .T.

FUNCTION VERCTABANCO()
RETURN EJECUTAR("DPCTABANCOCON",NIL,oDocViewCon:cCtaBco)

FUNCTION DPCBTE()
  LOCAL aLine  :=oDocViewCon:oBrw:aArrayData[oDocViewCon:oBrw:nArrayAt]
  LOCAL cActual:=aLine[7]

RETURN EJECUTAR("DPCBTE",cActual,oDocViewCon:cNumCbt,oDocViewCon:dFecha,.T.)
// EOF









