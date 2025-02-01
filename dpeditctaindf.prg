// Programa   : DPEDITCTAINDF
// Fecha/Hora : 20/08/2014 17:21:13
// Propósito  : Editar las Cuentas Modelos
// Creado Por : Juan Navas
// Llamado por: DPACTIVOS
// Aplicación : Ventas
// Tabla      : DPPROVEEDORCTA

#INCLUDE "DPXBASE.CH"
#INCLUDE "SAYREF.CH"

PROCE MAIN(cTable,cCodigo,cCod2,cDescri,aRef,cTitle,lView,cNumEje)
  LOCAL cSql,aData,cTableD,I,nAt
  LOCAL oBrw,oCol,oFont,oFontG,oFontB,oSayRef,oTable,oBtn
  LOCAL aCoors :=GetCoors( GetDesktopWindow() )
  
  DEFAULT cNumEje:=oDp:cNumEje
  
  DEFAULT cTable :="DPDICDATFRX",;
          cCodigo:="DPINDINFIN",;
          cCod2  :="",;
          cDescri:="Cuentas Asociadas para Indices Financieros",;
          cTitle :="",;
          lView  :=.F.

  IF Type("oEditInf")="O" .AND. oEditInf:oWnd:hWnd>0
      EJECUTAR("BRRUNNEW",oEditInf,GetScript())
      RETURN .T.
  ENDIF

  EJECUTAR("DPCTAXINDFIN")

  IF !TYPE("oFRX")="O"
     EJECUTAR("DPFRXCLASS")
  ENDIF

  IF aRef=NIL

    aRef:={}
    aRef:=ASQL("SELECT DDF_CODIGO,DDF_DESCRI,SPACE(1) FROM DPDICDATFRX WHERE DDF_ACTIVO=1")
 
    IF Empty(aRef)
      AADD(aRef,{"INDEF","Indefinido",""})
    ENDIF

  ENDIF

  
  cTableD:="DPINDINF_CTA"

  cSql:=" SELECT CIC_CODINT,0 AS REF,CIC_CUENTA,CTA_DESCRI,SLD_SALDO FROM "+cTableD+;
        " INNER JOIN DPCTA    ON CIC_CTAMOD=CTA_CODMOD AND CIC_CUENTA=CTA_CODIGO AND CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+;
        " LEFT  JOIN dpctasld ON SLD_CUENTA=CTA_CODIGO AND SLD_NUMEJE"+GetWhere("=",cNumEje)+;
        " WHERE  CIC_CODIGO"+GetWhere("=",cCodigo)+" AND CIC_COD2"+GetWhere("=",cCod2)+;
        " GROUP BY CIC_CODINT "+;
        " ORDER BY CIC_CUENTA "

  aData:=ASQL(cSql)

//? CLPCOPY(oDp:cSql)

  FOR I=1 TO LEN(aRef)

     nAt:=ASCAN(aData,{|a,n|a[1]=aRef[I,1]})

     IF nAt=0
       AADD(aData,{aRef[I,1],aRef[I,2],oDp:cCtaIndef,"",0}) // "",CTOD(""),"","",""})
     ELSE
       aData[nAt,2]:=aRef[I,2]
       // aData[nAt,8]:=OPE_NOMBRE(aData[nAt,7])
     ENDIF

  NEXT I

// ViewArray(aData)
// return 

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  cTitle:=IF(lView,"Consultar","Asignar")+;
          " Cuentas Contables "+;
          IIF(!Empty(cTitle),"("+cTitle+") "," ")+;
          "para ["+GetFromVar("{oDp:x"+cTable+"}")+" ]"

// DPEDIT():New(cTitle,"DPEDITCTAMOD.EDT","oEditInf",.T.)

  DpMdi(cTitle,"oEditInf","DPEDITCTAMOD.EDT")

  oEditInf:Windows(0,0,400,MIN(998,aCoors[4]-10),.T.) // Maximizado

  oEditInf:cCodigo   :=cCodigo
  oEditInf:cCod2     :=cCod2
  oEditInf:aData     :=ACLONE(aData)
  oEditInf:cNombre   :=cDescri
  oEditInf:cNumEje   :=cNumEje

  oEditInf:nClrPane1:=oDp:nClrPane1
  oEditInf:nClrPane2:=oDp:nCLrPane2

  oEditInf:lAcction  :=.F.
  oEditInf:cCtaDoc   :=""
  oEditInf:cCtaCxP   :=""
  oEditInf:lView     :=lView  
  oEditInf:cTableD   :=cTableD

  oBrw:=TXBrowse():New( oEditInf:oWnd )

  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .T.
  oBrw:lFooter             := .F.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 2

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  oEditInf:oBrw:=oBrw

  oBrw:aCols[1]:cHeader:="Código"+CRLF+"Diccionario"
  oBrw:aCols[1]:nWidth :=80
  oBrw:aCols[1]:bLClickHeader := {|r,c,f,o| SortArray( o, oEditInf:oBrw:aArrayData ) } 

  oBrw:aCols[2]:cHeader:="Referencia"
  oBrw:aCols[2]:nWidth :=140
  oBrw:aCols[2]:bLClickHeader := {|r,c,f,o| SortArray( o, oEditInf:oBrw:aArrayData ) } 


  oBrw:aCols[3]:cHeader   :="Cuenta "
  oBrw:aCols[3]:nWidth    :=180
  oBrw:aCols[3]:nEditType :=IIF( lView, 0, EDIT_GET_BUTTON)
  oBrw:aCols[3]:bEditBlock:={||oEditInf:EditCta(3,.F.)}
  oBrw:aCols[3]:bOnPostEdit:={|oCol,uValue,nKey|oEditInf:ValCta(oCol,uValue,3,nKey)}
  oBrw:aCols[3]:lButton   :=.F.
  oBrw:aCols[3]:bLClickHeader := {|r,c,f,o| SortArray( o, oEditInf:oBrw:aArrayData ) } 

  oBrw:aCols[4]:cHeader   :="Nombre de la Cuenta "
  oBrw:aCols[4]:nWidth    :=300
  oBrw:aCols[4]:bLClickHeader := {|r,c,f,o| SortArray( o, oEditInf:oBrw:aArrayData ) } 


  oBrw:aCols[5]:cHeader     :="Saldo"
  oBrw:aCols[5]:nWidth      :=110
  oBrw:aCols[5]:cEditPicture:="999,999,999,999.99"
  oBrw:aCols[5]:bStrData    :={|nMonto,oCol|nMonto:= oEditInf:oBrw:aArrayData[oEditInf:oBrw:nArrayAt,5],;
                                       oCol       := oEditInf:oBrw:aCols[5],;
                               FDP(nMonto,oCol:cEditPicture)}


/*
  oBrw:aCols[5]:cHeader   :="Fecha"
  oBrw:aCols[5]:nWidth    :=80

  oBrw:aCols[6]:cHeader   :="Hora"
  oBrw:aCols[6]:nWidth    :=80

  oBrw:aCols[7]:cHeader   :="Número"+CRLF+"Usuario"
  oBrw:aCols[7]:nWidth    :=70

  oBrw:aCols[8]:cHeader   :="Nombre"+CRLF+"Usuario"
  oBrw:aCols[8]:nWidth    :=120
*/

  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd   :={|oBrw,nClrText|oBrw:=oEditInf:oBrw,;
                                   nClrText:=0,;
                                   {nClrText, iif( oBrw:nArrayAt%2=0, oEditInf:nClrPane1, oEditInf:nClrPane2 ) } }

  oBrw:CreateFromCode()

  oBrw:bChange:={||NIL}

  oBrw:SetFont(oFont)

  

  oEditInf:oWnd:oClient := oEditInf:oBrw

  oEditInf:bValid   :={|| EJECUTAR("BRWSAVEPAR",oEditInf)}
  
 
  oEditInf:Activate({||oEditInf:BotBarra()})
  oEditInf:BRWRESTOREPAR()

  DpFocus(oBrw)

//  STORE NIL TO oBrw,oDlg

RETURN NIL

FUNCTION EditCta(nCol,lSave)
   LOCAL oBrw  :=oEditInf:oBrw,oLbx
   LOCAL nAt   :=oBrw:nArrayAt
   LOCAL uValue:=oBrw:aArrayData[oBrw:nArrayAt,nCol]

   oLbx:=DpLbx("DPCTAUTILIZACION.LBX")
   oLbx:GetValue("CTA_CODIGO",oBrw:aCols[nCol],,,uValue)
   oEditInf:lAcction  :=.T.
   oBrw:nArrayAt:=nAt

   SysRefresh(.t.)


RETURN uValue

FUNCTION VALCTA(oCol,uValue,nCol,nKey)
 LOCAL cTipDoc,oTable,cWhere:="",cCtaOld:="",cDescri,aLine:={},cWhere
 LOCAL nSaldo:=0

 DEFAULT nKey:=0

 DEFAULT oCol:lButton:=.F.

 nSaldo:=SQLGET("DPCTASLD","SLD_SALDO","SLD_CUENTA"+GetWhere("=",uValue)+" AND SLD_NUMEJE"+GetWhere("=",oEditInf:cNumEje))

 IF oCol:lButton=.T.
    oCol:lButton:=.F.
    RETURN .T.
 ENDIF

 IF !SQLGET("DPCTA","CTA_CODIGO,CTA_DESCRI","CTA_CODIGO"+GetWhere("=",uValue))==uValue
    MensajeErr("Cuenta Contable no Existe")
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF

 cDescri:=oDp:aRow[2]

/*
 IF !EJECUTAR("ISCTADET",uValue,.T.)
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF
*/

 oEditInf:lAcction  :=.F.

 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,3]:=uValue
 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,4]:=cDescri
 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,5]:=nSaldo
// oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,6]:=DPHORA()
// oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,7]:=oDp:cUsuario

 aLine:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt]

 cWhere:="CIC_CODIGO"+GetWhere("=",oEditInf:cCodigo)+" AND "+;
         "CIC_COD2"  +GetWhere("=",oEditInf:cCod2  )+" AND "+;
         "CIC_CODINT"+GetWhere("=",aLine[1])

 oTable:=OpenTable("SELECT * FROM "+oEditInf:cTableD+" WHERE "+cWhere,.T.)

 IF oTable:RecCount()=0
    oTable:Append()
    cWhere:=""
 ELSE
    cWhere:=oTable:cWhere
 ENDIF

 oTable:cPrimary:="CIC_CTAMOD,CIC_CODIGO,CIC_COD2,CIC_CODINT"
 oTable:SetAuditar()
 oTable:Replace("CIC_COD2"  ,oEditInf:cCod2  )
 oTable:Replace("CIC_CODIGO",oEditInf:cCodigo)
 oTable:Replace("CIC_CODINT",aLine[1])
 oTable:Replace("CIC_CUENTA",aLine[3])
 oTable:Replace("CIC_FECHA" ,oDp:dFecha  ) // aLine[5])
 oTable:Replace("CIC_HORA"  ,oDp:cHora   ) // aLine[6])
 oTable:Replace("CIC_USUARI",oDp:cUsuario) // aLine[7])
 otable:Replace("CIC_CTAMOD",oDp:cCtaMod)
 oTable:Commit(cWhere)
 oTable:End()

 SysRefresh(.t.)

 oCol:oBrw:DrawLine(.T.)

RETURN .T.

/*
// Consultar la Cuenta
*/

FUNCTION VERCUENTA()
RETURN .T.

FUNCTION QUITAR()
RETURN .T.

/*
// Barra de Botones
*/
FUNCTION BotBarra()
   LOCAL oCursor,oBar,oBtn,oFont,oDlg:=oEditInf:oWnd

   oEditInf:oBrw:SetColor(0,oEditInf:nClrPane1)
   oEditInf:oBrw:nColSel:=3

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD 

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oEditInf:oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   oEditInf:oFontBtn   :=oFont    
   oEditInf:nClrPaneBar:=oDp:nGris
   oEditInf:oBrw:oLbx  :=oEditInf


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE DPBMP("XNEW.BMP"),NIL,DPBMP("XNEWG.BMP");
          TOP PROMPT "Incluir"; 
          WHEN ISTABINC("DPDICDATFRX");
          ACTION oEditInf:NEWFRX()

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Crear Diccionario"
   oBtn:cMsg    :=oBtn:cToolTip



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE DPBMP("XEDIT.BMP"),NIL,DPBMP("XEDITG.BMP");
          TOP PROMPT "Modificar"; 
          WHEN ISTABMOD("DPDICDATFRX");
          ACTION oEditInf:EDITFRX()

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Editar Diccionario"
   oBtn:cMsg    :=oBtn:cToolTip


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE DPBMP("CONTABILIDAD.BMP"),NIL,DPBMP("CONTABILIDADG.BMP");
          TOP PROMPT "Cuenta"; 
          WHEN !Empty(oEditInf:oBrw:aArrayData[oEditInf:oBrw:nArrayAt,3]);
          ACTION oEditInf:VERCUENTA()

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Consultar Cuenta Contable"
   oBtn:cMsg    :=oBtn:cToolTip

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oEditInf:oBrw)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oEditInf::oBrw);
          WHEN LEN(oEditInf:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (EJECUTAR("BRWTOHTML",oEditInf:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oEditInf:oBtnHtml:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
              ACTION  oEditInf:IMPRIMIRCTAS()

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Imprimir Cuentas Contables"
   oBtn:cMsg    :=oBtn:cToolTip


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION   oEditInf:Close()

   oBtn:cToolTip:="Cerrar"

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

   @ 0.1,40+30+6 SAY " "+oEditInf:cCodigo OF oBar BORDER SIZE 395,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
   @ 1.4,40+30+6 SAY " "+oEditInf:cNombre OF oBar BORDER SIZE 395,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

RETURN .T.

FUNCTION VERCUENTA()
  LOCAL cCodCta:=oEditInf:oBrw:aArrayData[oEditInf:oBrw:nArrayAt,3]

  EJECUTAR("DPCTACON",NIL,cCodCta)

RETURN NIL

FUNCTION IMPRIMIRCTAS()
  LOCAL oRep:=REPORTE(oEditInf:cTableD)

  IF ValType(oRep)="O"
     oRep:SetRango(1,oEditInf:cCodigo,oEditInf:cCodigo)
  ENDIF

RETURN NIL

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oEditInf)

FUNCTION EDITFRX()
   LOCAL cCodigo:=oEditInf:oBrw:aArrayData[oEditInf:oBrw:nArrayAt,1]

RETURN EJECUTAR("DPDICDATFRX",3,cCodigo,.T.)

FUNCTION NEWFRX()
   LOCAL cCodigo:=oEditInf:oBrw:aArrayData[oEditInf:oBrw:nArrayAt,1]

RETURN EJECUTAR("DPDICDATFRX",1,cCodigo,.T.)

// EOF
