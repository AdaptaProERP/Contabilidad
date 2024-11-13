// Programa   : BRWMAYORANALITICO
// Fecha/Hora : 08/03/2022 08:52:05
// Propósito  : Mayor Analitico
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep,dDesde,dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon,nPeriodo,cWhereAdd)
  LOCAL aData,nLen
  LOCAL aNumEje:=ATABLE("SELECT EJE_NUMERO FROM DPEJERCICIOS WHERE EJE_CODSUC"+GetWhere("=",oDp:cSucursal)+" GROUP BY EJE_NUMERO ORDER BY EJE_NUMERO ")
  LOCAL cTitle:="Mayor Analítico"
  LOCAL cWhere:=NIL
  LOCAL cNumEje
  LOCAL cServer,cCodPar,aTotal:={},aTotal1:={}

// ? oGenRep,dDesde,dHasta,RGO_C1,"<-RGO_C1",RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon,"oGenRep,dDesde,dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cCodMon"

  IF Type("oBrMayor")="O" .AND. oBrMayor:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oBrMayor,GetScript())
  ENDIF


  DEFAULT dDesde  :=oDp:dFchInicio,;
          dHasta  :=oDp:dFchCierre,;
          nPeriodo:=oDp:nEjercicio

 // DEFAULT RGO_C1:=oDp:cSucursal,; 12/05/2022

  DEFAULT RGO_C1:=oDp:cSucursal,;
          RGO_C2:="",;
          RGO_C3:="N",;
          RGO_C4:="",;
          RGO_I1:="",;
          RGO_F1:="",;
          RGO_I2:="",;
          RGO_F2:=""

  cNumEje:=EJECUTAR("GETNUMEJE",dDesde)

  aData:=HACERBALANCE(dDesde,dHasta,NIL,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cWhereAdd)

  IF Empty(aData)
     MensajeErr("Mayor Analítico no Generado")
     RETURN NIL
  ENDIF

//ViewArray(aData)

  aTotal:=aData[LEN(aData)]

RETURN ViewData(aData,cTitle,cWhere)


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors   :=GetCoors( GetDesktopWindow() )
   LOCAL cCodSuc  :=oDp:cSucursal
   LOCAL aTotalC  :=ACLONE(oDp:aTotalC)
   

// ViewArray(aTotalC)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oBrMayor","BRMAYORANALITICO.EDT")
   oBrMayor:Windows(0,0,aCoors[3]-160,aCoors[4]-10,.T.) // Maximizado

   oBrMayor:cCodSuc  :=cCodSuc
   oBrMayor:lMsgBar  :=.F.
   oBrMayor:cPeriodo :=aPeriodos[nPeriodo]
   oBrMayor:cCodSuc  :=cCodSuc
   oBrMayor:nPeriodo :=nPeriodo
   oBrMayor:cNombre  :=""
   oBrMayor:dDesde   :=dDesde
   oBrMayor:cServer  :=cServer
   oBrMayor:dHasta   :=dHasta
   oBrMayor:cWhere   :=cWhere
   oBrMayor:cWhere_  :=cWhere_
   oBrMayor:cWhereQry:=""
   oBrMayor:cSql     :=oDp:cSql
   oBrMayor:oWhere   :=TWHERE():New(oBrMayor)
   oBrMayor:cCodPar  :=cCodPar // Código del Parámetro
   oBrMayor:lWhen    :=.T.
   oBrMayor:cTextTit :="" // Texto del Titulo Heredado
   oBrMayor:oDb     :=oDp:oDb
   oBrMayor:cBrwCod  :=""
   oBrMayor:lTmdi    :=.T.
   oBrMayor:aNumEje  :=ACLONE(aNumEje)
   oBrMayor:cNumEje  :=cNumEje
   oBrMayor:cCodMon  :=cCodMon
   oBrMayor:nAddBar  :=50+50+5+4+10+10
   oBrMayor:aActual  :={"S","C","A","F"}
   oBrMayor:cWhereAdd:=cWhereAdd


   oBrMayor:RGO_C1:=RGO_C1
   oBrMayor:RGO_C2:=RGO_C2
   oBrMayor:RGO_C3:=RGO_C3
   oBrMayor:RGO_C4:=RGO_C4

   oBrMayor:RGO_I1:=RGO_I1
   oBrMayor:RGO_F1:=RGO_F1
   oBrMayor:RGO_I2:=RGO_I2
   oBrMayor:RGO_F2:=RGO_F2

   oBrMayor:oBrw:=TXBrowse():New( IF(oBrMayor:lTmdi,oBrMayor:oWnd,oBrMayor:oDlg ))
   oBrMayor:oBrw:SetArray( aData, .F. )
   oBrMayor:oBrw:SetFont(oFont)

   oBrMayor:oBrw:lFooter     := .T.
   oBrMayor:oBrw:lHScroll    := .T.
   oBrMayor:oBrw:nHeaderLines:= 2
   oBrMayor:oBrw:nDataLines  := 1
   oBrMayor:oBrw:nFooterLines:= 1

   oBrMayor:aData            :=ACLONE(aData)
   oBrMayor:nClrText :=0
   oBrMayor:nClrText1:=10900224
   oBrMayor:nClrText2:=37632
   oBrMayor:nClrText3:=16321

   oBrMayor:nClrPane1:=oDp:nClrPane1
   oBrMayor:nClrPane2:=oDp:nClrPane2

   AEVAL(oBrMayor:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oBrMayor:oBrw:aCols[1]
   oCol:cHeader      :='Día'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oBrMayor:oBrw:aArrayData ) } 
   oCol:nWidth       := 40
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 

   oCol:=oBrMayor:oBrw:aCols[2]
   oCol:cHeader      :='Número'+CRLF+"Cbte."

   oCol:=oBrMayor:oBrw:aCols[3]
   oCol:cHeader      :='Tipo'

   oCol:=oBrMayor:oBrw:aCols[4]
   oCol:cHeader      :='Número'+CRLF+"Doc."

   oCol:=oBrMayor:oBrw:aCols[5]
   oCol:cHeader      :="Descripción"

   oCol:=oBrMayor:oBrw:aCols[6]
   oCol:cHeader      :="Debe"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bClrStd      := {|oBrw,nClrText,aLine|oBrw:=oBrMayor:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                              nClrText:=CLR_HBLUE,;
                                              nClrText:=IF("-"$aLine[1],0,nClrText),;                                         
                                             {nClrText,iif( oBrw:nArrayAt%2=0, oBrMayor:nClrPane1, oBrMayor:nClrPane2 ) } }
   oCol:cFooter      :=aTotal[6]




   oCol:=oBrMayor:oBrw:aCols[7]
   oCol:cHeader      :="Haber"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bClrStd      := {|oBrw,nClrText,aLine|oBrw:=oBrMayor:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                              nClrText:=CLR_HRED,;
                                              nClrText:=IF("-"$aLine[1],0,nClrText),;                                         
                                             {nClrText,iif( oBrw:nArrayAt%2=0, oBrMayor:nClrPane1, oBrMayor:nClrPane2 ) } }
   oCol:cFooter      :=aTotal[7]



   oCol:=oBrMayor:oBrw:aCols[8]
   oCol:cHeader      :="Saldo"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bClrStd      := {|oBrw,nClrText,aLine|oBrw:=oBrMayor:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                              nClrText:=IF("-"$aLine[8],CLR_HRED,CLR_HBLUE),;  
                                              nClrText:=IF("-"$aLine[1],0,nClrText),;    
                                              nClrText:=IF(aLine[8]=="0,00",0,nClrText),;                                      
                                             {nClrText,iif( oBrw:nArrayAt%2=0, oBrMayor:nClrPane1, oBrMayor:nClrPane2 ) } }
   oCol:cFooter      :=aTotal[8]


   oCol:=oBrMayor:oBrw:aCols[9]
   oCol:cHeader      :='Tipo'+CRLF+"Tran"

   oCol:=oBrMayor:oBrw:aCols[10]
   oCol:cHeader      :='Apl.'+CRLF+"Org."

   oCol:=oBrMayor:oBrw:aCols[11]
   oCol:cHeader      :='Num.'+CRLF+"Par."

   oCol:=oBrMayor:oBrw:aCols[12]
   oCol:cHeader      :='Num.'+CRLF+"Item"

   oCol:=oBrMayor:oBrw:aCols[13]
   oCol:cHeader      :='Tipo'+CRLF+"Cbte"

   oCol:=oBrMayor:oBrw:aCols[14]
   oCol:cHeader      :="Monto en"+CRLF+"Divisa"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='9,999,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,14],;
                                     oCol  := oBrMayor:oBrw:aCols[14],;
                        IF(Empty(oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,13]),"",FDP(nMonto,oCol:cEditPicture))}


   oCol:bClrStd      := {|oBrw,nClrText,aLine|oBrw:=oBrMayor:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                              nClrText:=IF(aLine[14]>0,CLR_HBLUE,CLR_HRED),;
                                              nClrText:=IF("-"$aLine[1],0,nClrText),;                                         
                                             {nClrText,iif( oBrw:nArrayAt%2=0, oBrMayor:nClrPane1, oBrMayor:nClrPane2 ) } }

   oCol:cFooter      :=FDP(aTotal[14],oCol:cEditPicture)


   oCol:=oBrMayor:oBrw:aCols[15]
   oCol:cHeader      :="Valor"+CRLF+"Divisa"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='9,999,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,15],;
                                     oCol  := oBrMayor:oBrw:aCols[15],;
                        IF(Empty(oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,13]),"",FDP(nMonto,oCol:cEditPicture))}


   oCol:bClrStd      := {|oBrw,nClrText,aLine|oBrw:=oBrMayor:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                              nClrText:=0,;
                                             {nClrText,iif( oBrw:nArrayAt%2=0, oBrMayor:nClrPane1, oBrMayor:nClrPane2 ) } }

//   oCol:cFooter      :=aTotal[14]


   oCol:=oBrMayor:oBrw:aCols[16]
   oCol:cHeader      :="Total en"+CRLF+"Divisa"
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:cEditPicture :='9,999,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,16],;
                                     oCol  := oBrMayor:oBrw:aCols[16],;
                        IF(Empty(oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,13]),"",FDP(nMonto,oCol:cEditPicture))}

   oCol:bClrStd      := {|oBrw,nClrText,aLine|oBrw:=oBrMayor:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                              nClrText:=IF(aLine[16]>0,CLR_HBLUE,CLR_HRED),;
                                              nClrText:=IF("-"$aLine[1],0,nClrText),;                                         
                                             {nClrText,iif( oBrw:nArrayAt%2=0, oBrMayor:nClrPane1, oBrMayor:nClrPane2 ) } }

   oCol:cFooter      :=FDP(aTotal[14],oCol:cEditPicture)



   oBrMayor:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oBrMayor:oBrw:bClrStd               := {|oBrw,nClrText,aLine|oBrw:=oBrMayor:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=oBrMayor:nClrText,;
                                           nClrText:=IF("CTA" =aLine[1],oBrMayor:nClrText1,nClrText),;
                                           nClrText:=IF("MES" =aLine[1],oBrMayor:nClrText2,nClrText),;
                                           nClrText:=IF("TMES"=aLine[1],oBrMayor:nClrText3,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oBrMayor:nClrPane1, oBrMayor:nClrPane2 ) } }

   oBrMayor:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrMayor:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrMayor:oBrw:bLDblClick:={|oBrw|oBrMayor:RUNCLICK() }

   oBrMayor:oBrw:bChange:={||oBrMayor:BRWCHANGE()}
   oBrMayor:oBrw:CreateFromCode()
   oBrMayor:bValid   :={|| EJECUTAR("BRWSAVEPAR",oBrMayor)}
   oBrMayor:BRWRESTOREPAR()
   oBrMayor:oWnd:oClient := oBrMayor:oBrw

   oBrMayor:Activate({||oBrMayor:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oBrMayor:lTmdi,oBrMayor:oWnd,oBrMayor:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oBrMayor:oBrw:nWidth()
   LOCAL nAltoBrw:=150+200


   oBrMayor:oBrw:GoBottom(.T.)
   oBrMayor:oBrw:Refresh(.T.)

   /*   
   //  Ubicamos el Area del Primer Objeto o Browse.
   */
/*

   oBrMayor:oBrw:Move(032+15,0,800,nAltoBrw,.T.)

   oBrMayor:oHSplit:Move(oBrMayor:oBrw:nHeight()+oBrMayor:oBrw:nTop(),0)
   oBrMayor:oMemo:Move(oBrMayor:oBrw:nHeight()+oBrMayor:oBrw:nTop()+5,0,800,400,.T.)

   oBrMayor:oHSplit:AdjLeft()
   oBrMayor:oHSplit:AdjRight()
*/

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD


 // Emanager no Incluye consulta de Vinculos

   oBrMayor:oFontBtn   :=oFont    
   oBrMayor:nClrPaneBar:=oDp:nGris
   oBrMayor:oBrw:oLbx  :=oBrMayor

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Ejecutar"; 
          ACTION  oBrMayor:HACERBALANCE(oBrMayor:dDesde,oBrMayor:dHasta,oBrMayor,oBrMayor:RGO_C3,oBrMayor:RGO_C4,oBrMayor:RGO_C6,oBrMayor:RGO_I1,oBrMayor:RGO_F1,oBrMayor:RGO_I2,oBrMayor:RGO_F2)


   oBrMayor:oBtn:=oBtn:bAction
 
   oBtn:cToolTip:="Ejecutar Balance"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIDAD.BMP";
          MENU EJECUTAR("BRBTNMENU",{"Cuentas"},;
                                    "oBrMayor");
          TOP PROMPT "Cuenta"; 
          ACTION oBrMayor:VERCTA()

   oBtn:cToolTip:="Consultar Cuentas"

   oBrMayor:oBtnCta:=oBtn
 
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.bmp";
          TOP PROMPT "Origen"; 
          ACTION oBrMayor:VERORG()

   oBtn:cToolTip:="Ver Origen"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbteactualizado.BMP";
          TOP PROMPT "Cbte."; 
          ACTION  oBrMayor:VERCBTE()

   oBtn:cToolTip:="Ver Comprobante Contable"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\balancecomprobacion.bmp";
          TOP PROMPT "Balance C."; 
          ACTION oBrMayor:aBalCom:=EJECUTAR("BRWCOMPROBACION",NIL,oBrMayor:dDesde,oBrMayor:dHasta)

   oBtn:cToolTip:="Balance de Comprobación"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          TOP PROMPT "Detalles"; 
          ACTION  oBrMayor:VERBROWSE(.F.)

   oBtn:cToolTip:="Ver Asientos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  oBrMayor:PRINTBALCOM()

   oBtn:cToolTip:="Imprimir Balance de Comprobación"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oBrMayor:oWnd:IsZoomed(),oBrMayor:oWnd:Restore(),oBrMayor:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"

   oBrMayor:oBtnColor:=NIL

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\COLORS.BMP";
          MENU EJECUTAR("BRBTNMENUCOLOR",oBrMayor:oBrw,oBrMayor,oBrMayor:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oBrMayor,.T.)});
            TOP PROMPT "Color"; 
              ACTION  EJECUTAR("BRWSELCOLORFIELD",oBrMayor,.T.)

   oBtn:cToolTip:="Personalizar Colores en los Campos"

   oBrMayor:oBtnColor:=oBtn
*/
 
   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DOCPROISLREDI"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oBrMayor:oBrw,"DOCPROISLREDI",oBrMayor:cSql,oBrMayor:nPeriodo,oBrMayor:dDesde,oBrMayor:dHasta,oBrMayor)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oBrMayor:oBtnRun:=oBtn



       oBrMayor:oBrw:bLDblClick:={||EVAL(oBrMayor:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oBrMayor:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oBrMayor:oBrw,oBrMayor);
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oBrMayor:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oBrMayor:oBrw);
          WHEN LEN(oBrMayor:oBrw:aArrayData)>1

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


// IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
            TOP PROMPT "Refrescar"; 
              ACTION  oBrMayor:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

   oBrMayor:oBtn:=oBtn // Cambiar el Periodo refresca

// ENDIF

/*
  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.bmp";
          MENU EJECUTAR("BRBTNMENU",{"Según Partida","Visualizar Asientos"},"oBrMayor");
          ACTION oBrMayor:EDITCBTE()

  oBtn:cToolTip:="Editar Comprobante"




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oBrMayor)

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
              ACTION  (EJECUTAR("BRWTOEXCEL",oBrMayor:oBrw,oBrMayor:cTitle,oBrMayor:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oBrMayor:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oBrMayor:HTMLHEAD(),EJECUTAR("BRWTOHTML",oBrMayor:oBrw,NIL,oBrMayor:cTitle,oBrMayor:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oBrMayor:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oBrMayor:oBrw))

   oBtn:cToolTip:="Previsualización"

   oBrMayor:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDOCPROISLREDI")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oBrMayor:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oBrMayor:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oBrMayor:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oBrMayor:oBrw:GoTop(),oBrMayor:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oBrMayor:oBrw:PageDown(),oBrMayor:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oBrMayor:oBrw:PageUp(),oBrMayor:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oBrMayor:oBrw:GoBottom(),oBrMayor:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oBrMayor:Close()

  oBrMayor:oBrw:SetColor(0,oBrMayor:nClrPane1)

  EVAL(oBrMayor:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBrMayor:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=15+5
  // AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })
  oBar:SetSize(NIL,100,.T.)


  //
  // Campo : Periodo
  //

  @ 70, nLin COMBOBOX oBrMayor:oPeriodo  VAR oBrMayor:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE (oBrMayor:LEEFECHAS(),oBrMayor:BRWREFRESCAR());
                WHEN oBrMayor:lWhen 


  ComboIni(oBrMayor:oPeriodo )

  @ 70, nLin+103 BUTTON oBrMayor:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrMayor:oPeriodo:nAt,oBrMayor:oDesde,oBrMayor:oHasta,-1),;
                         oBrMayor:BRWREFRESCAR());
                WHEN oBrMayor:lWhen 


  @ 70, nLin+130 BUTTON oBrMayor:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oBrMayor:oPeriodo:nAt,oBrMayor:oDesde,oBrMayor:oHasta,+1),;
                         oBrMayor:BRWREFRESCAR());
                WHEN oBrMayor:lWhen 


  @ 70, nLin+170 BMPGET oBrMayor:oDesde  VAR oBrMayor:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrMayor:oDesde ,oBrMayor:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oBrMayor:oPeriodo:nAt=LEN(oBrMayor:oPeriodo:aItems) .AND. oBrMayor:lWhen ;
                FONT oFont

   oBrMayor:oDesde:cToolTip:="F6: Calendario"

  @ 70, nLin+252 BMPGET oBrMayor:oHasta  VAR oBrMayor:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oBrMayor:oHasta,oBrMayor:dHasta);
                SIZE 80,23;
                WHEN oBrMayor:oPeriodo:nAt=LEN(oBrMayor:oPeriodo:aItems) .AND. oBrMayor:lWhen ;
                OF oBar;
                FONT oFont

   oBrMayor:oHasta:cToolTip:="F6: Calendario"

   @ 70, nLin+335 BUTTON oBrMayor:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oBrMayor:oPeriodo:nAt=LEN(oBrMayor:oPeriodo:aItems);
               ACTION oBrMayor:HACERWHERE(oBrMayor:dDesde,oBrMayor:dHasta,oBrMayor:cWhere,.T.);
               WHEN oBrMayor:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})


  @ 70,nLin+325+70 COMBOBOX oBrMayor:oNumEje  VAR oBrMayor:cNumEje;
                ITEMS oBrMayor:aNumEje;
                WHEN LEN(oBrMayor:aNumEje)>1 OF oBAR PIXEL SIZE 60,NIL;
                ON CHANGE oBrMayor:CAMBIAEJERCICIO() FONT oFont

  oBrMayor:oNumEje:cMsg    :="Seleccione el Ejercicio"
  oBrMayor:oNumEje:cToolTip:="Seleccione el Ejercicio"

  oBrMayor:oNumEje:ForWhen(.T.)

  IF !Empty(oBrMayor:RGO_I1) 

    oBar:SetSize(NIL,123,.T.)

    @ 50+47,15 SAY oBrMayor:oCodCta PROMPT " "+oBrMayor:RGO_I1+" " OF oBrMayor:oBar BORDER PIXEL;
              COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 140,20

    @ 50+47,160 SAY oBrMayor:oDescri PROMPT " "+SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oBrMayor:RGO_I1));
             OF oBrMayor:oBar BORDER PIXEL;
             COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 420,20

  ENDIF

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

  oBrMayor:VERBROWSE(.T.)

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRDOCPROISLREDI",cWhere)
  oRep:cSql  :=oBrMayor:cSql
  oRep:cTitle:=oBrMayor:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oBrMayor:oPeriodo:nAt,cWhere

  oBrMayor:nPeriodo:=nPeriodo


  IF oBrMayor:oPeriodo:nAt=LEN(oBrMayor:oPeriodo:aItems)

     oBrMayor:oDesde:ForWhen(.T.)
     oBrMayor:oHasta:ForWhen(.T.)
     oBrMayor:oBtn  :ForWhen(.T.)

     DPFOCUS(oBrMayor:oDesde)

  ELSE

     oBrMayor:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,oBrMayor:dDesde,oBrMayor:dHasta)

     oBrMayor:oDesde:VarPut(oBrMayor:aFechas[1] , .T. )
     oBrMayor:oHasta:VarPut(oBrMayor:aFechas[2] , .T. )

     oBrMayor:dDesde:=oBrMayor:aFechas[1]
     oBrMayor:dHasta:=oBrMayor:aFechas[2]

     cWhere:=oBrMayor:HACERWHERE(oBrMayor:dDesde,oBrMayor:dHasta,oBrMayor:cWhere,.T.)

//     oBrMayor:LEERDATA(cWhere,oBrMayor:oBrw,oBrMayor:cServer)

  ENDIF

  oBrMayor:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   oBrMayor:HACERBALANCE(dDesde,dHasta,oBrMayor)

RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
  LOCAL aData:={}

  aData:=HACERBALANCE(oBrMayor:dDesde,oBrMayor:dHasta,NIL,oBrMayor:RGO_C1,oBrMayor:RGO_C2,oBrMayor:RGO_C3,oBrMayor:RGO_C4,oBrMayor:RGO_I1,oBrMayor:RGO_F1,oBrMayor:RGO_I2,oBrMayor:RGO_F2)

  IF ValType(oBrw)="O"

     oBrw:aArrayData:=ACLONE(aData)
     oBrw:nArrayAt  :=1
     oBrw:nRowSel   :=1
     EJECUTAR("BRWCALTOTALES",oBrw,.T.)

  ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDOCPROISLREDI.MEM",V_nPeriodo:=oBrMayor:nPeriodo
  LOCAL V_dDesde:=oBrMayor:dDesde
  LOCAL V_dHasta:=oBrMayor:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oBrMayor)
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

    IF Type("oBrMayor")="O" .AND. oBrMayor:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oBrMayor:cWhere_),oBrMayor:cWhere_,oBrMayor:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oBrMayor:LEERDATA(oBrMayor:cWhere_,oBrMayor:oBrw,oBrMayor:cServer)
      oBrMayor:oWnd:Show()
      oBrMayor:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNMENU(nOption,cOption)
   LOCAL aCodCta:={}

 //? nOption,cOption,"nOption,cOption"

   IF nOption=1 .AND. "Cuenta"$cOption
     aCodCta:=ACLONE(oBrMayor:oBrw:aArrayData)
     ADEPURA(aCodCta,{|a,n| !a[1]="CTA" })
     AEVAL(aCodCta,{|a,n| aCodCta[n]:=a[2]})
     oBrMayor:VERCUENTAS(aCodCta)
     RETURN .T.
   ENDIF


   IF nOption=1 .AND. "Según"$cOption
      RETURN oBrMayor:EDITCBTE(.T.,.F.)
   ENDIF

   IF nOption=2 .AND. "Visua"$cOption
      RETURN oBrMayor:EDITCBTE(.T.,.T.)
   ENDIF


RETURN .T.

FUNCTION VERCUENTAS(aCodCta)
  LOCAL cWhere:="",cCodigo,oCol:=oBrMayor:oBrw:aCols[2]
  LOCAL cTitle:="Cuentas Contables",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL oBtnBrw:=oBrMayor:oBtnCta,nLastKey:=NIL
 
  cWhere    := GetWhereOr("CTA_CODIGO",aCodCta)
  cOrderBy:=" GROUP BY CTA_CODIGO ORDER BY CTA_CODIGO "
  aTitle  :={"Código","Nombre"}

  oDp:aPicture   :={NIL,NIL}
  oDp:aSize      :={120,300}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCTA","CTA_CODIGO,CTA_DESCRI",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

    oCol:oBrw:ADD("aColsOrg",ARRAY(LEN(oCol:oBrw:aCols)))
    AEVAL(oCol:oBrw:aCols,{|oCol,n|  oCol:oBrw:aColsOrg[n]:={oCol:nEditType,oCol:bOnPostEdit} })
   
    oBrMayor:oBrw:nColSel:=2
    EJECUTAR("BRWFILTER",oCol,cCodigo,nLastKey,oCol:CARGO,NIL,oCol:oBrw:aColsOrg)

  ENDIF

RETURN


FUNCTION HTMLHEAD()

   oBrMayor:aHead:=EJECUTAR("HTMLHEAD",oBrMayor)

RETURN

FUNCTION EDITDOCCXP()
   LOCAL aLine  :=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt]
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
   LOCAL aLine  :=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt]
   LOCAL cDocOrg:=aLine[14]
   LOCAL cTipDoc:=aLine[1],cCodigo:=aLine[2],cNumero:=aLine[3]

RETURN EJECUTAR("DPDOCISLR",oDp:cSucursal,cTipDoc,cCodigo,cNumero,NIL, 'C' )

/*
// Visualizar Asientos
*/
FUNCTION EDITCBTE(lNumPar,lView)
  LOCAL cActual
  LOCAL cTipDoc:=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,1]
  LOCAL cCodigo:=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,2]
  LOCAL cNumero:=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,3]
  LOCAL dFecha :=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,5]
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
    cWhereGrid:="MOC_NUMPAR"+GetWhere("=",oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,18])
//+" AND "+;
//                "MOC_DOCUME"+GetWhere("=",oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt,03])
  ENDIF

  EJECUTAR("DPCBTE",cActual,cNumero,dFecha,.F.,NIL,cWhereGrid)

RETURN .T.


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oBrMayor)


FUNCTION CAMBIAEJERCICIO()

  oBrMayor:dDesde:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_CODSUC"+GetWhere("=",oBrMayor:cCodSuc)+" AND EJE_NUMERO"+GetWhere("=",oBrMayor:cNumEje))
  oBrMayor:dHasta:=DPSQLROW(2,CTOD(""))

  oBrMayor:oDesde:Refresh(.T.)
  oBrMayor:oHasta:Refresh(.T.)

  oDp:oCursor:=NIL

  oBrMayor:BRWREFRESCAR()

//? "DEBE REHACER EL BALANCE"

RETURN
//  oBrMayor:HACERBALANCE(oBrMayor:dDesde,oBrMayor:dHasta,oBrMayor)
// ? oBrMayor:dDesde,oBrMayor:dHasta

RETURN .T.

FUNCTION HACERBALANCE(dDesde,dHasta,oBrMayor,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2,cWhereAdd)
  LOCAL oCursor,cCodPar,cServer,nLen,cWhereC
  LOCAL oGenRep:=NIL
  LOCAL RGO_I2:=oDp:dFchInicio
  LOCAL RGO_F2:=oDp:dFchCierre
  LOCAL aData :={},cWhere:=NIL

  DEFAULT  dDesde:=oDp:dFchInicio,;
           dHasta:=oDp:dFchCierre

  DEFAULT oDp:oCursor:=NIL

  RGO_I2:=dDesde
  RGO_F2:=dHasta

  IF ValType(oBrMayor)="O"

     RGO_C1:=oBrMayor:RGO_C1
     RGO_C2:=oBrMayor:RGO_C2
     RGO_C3:=oBrMayor:RGO_C3
     RGO_C4:=oBrMayor:RGO_C4
     RGO_I1:=oBrMayor:RGO_I1
     RGO_F1:=oBrMayor:RGO_F1
     RGO_I2:=oBrMayor:RGO_I2
     RGO_F2:=oBrMayor:RGO_F2

     cWhereAnd:=oBrMayor:cWhereAdd

  ENDIF

  oDp:oCursor:=NIL

  IF !ISPCPRG()
     oDp:oCursor:=NIL
  ENDIF
  
  cWhere:=IF(Empty(cWhere),"1=1",cWhere)

  IF !Empty(RGO_C1)
     cWhere :=cWhere+IF(Empty(cWhere),""," AND MOC_CODSUC"+GetWhere("=",RGO_C1))
  ENDIF

// ? cWhere,RGO_I1,RGO_F1

  IF ValType(RGO_I1)="C" .AND. !Empty(RGO_I1) .AND. ValType(RGO_F1)="C" .AND. !Empty(RGO_F1) .AND. RGO_I1=RGO_F1 .AND. !"CTA_CODIGO"$cWhere

     RGO_I1 :=ALLTRIM(RGO_I1)
     nLen   :=LEN(RGO_I1)
     cWhereC:="LEFT(MOC_CUENTA,"+LSTR(nLen)+")"+GetWhere("=",RGO_I1)

     cWhere :=cWhere+IF(Empty(cWhere),""," AND "+cWhereC)

  ENDIF

  oDp:aTotalC:={}

  IF !Empty(cWhereAdd)
     cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+cWhereAdd
  ENDIF

  aData:=EJECUTAR("BRMABROWSECALC",oGenRep,dDesde,dHasta,cWhere)

ViewArray(aData)

  AEVAL(aData,{|a,n| aData[n,8]:=ALLTRIM(a[8])})

  IF Empty(oDp:aTotalC)
     oDp:aTotalC:={}
     AADD(oDp:aTotalC,{"","",0,0,0,0,0,0,0})
  ENDIF

RETURN aData

FUNCTION VERCTA()
  LOCAL cCodCta:=oBrMayor:GETCTACON()

  IF !Empty(cCodCta)
     EJECUTAR("DPCTACON",NIL,cCodCta)
  ENDIF

RETURN .T.

FUNCTION GETCTACON()
  LOCAL nAt:=oBrMayor:oBrw:nArrayAt,aLine:={},cCodCta:=""

  oBrMayor:cMes:=""
  oBrMayor:cAno:=""

  WHILE nAt>0 

    aLine:=oBrMayor:oBrw:aArrayData[nAt]

    IF aLine[1]=="MES"
       oBrMayor:cMes:=aLine[02]
       oBrMayor:cAno:=aLine[03]
    ENDIF

    IF aLine[1]=="CTA"
       EXIT
    ENDIF

    nAt  :=nAt-1

    IF nAt=0
      EXIT
    ENDIF

  ENDDO

  IF !Empty(aLine) .AND. aLine[1]="CTA"
     cCodCta:=aLine[2]
  ENDIF

  IF !Empty(oBrMayor:RGO_I1) .AND. Empty(cCodCta)
     cCodCta:=oBrMayor:RGO_I1
  ENDIF

RETURN ALLTRIM(cCodCta)

FUNCTION GETFECHA()
  LOCAL nAt  :=oBrMayor:oBrw:nArrayAt,dFecha:=CTOD("")
  LOCAL aLine:=oBrMayor:oBrw:aArrayData[nAt]
  LOCAL cDia :=aLine[1],cMes,cAno

  WHILE nAt>0 

    aLine:=oBrMayor:oBrw:aArrayData[nAt]

    IF aLine[1]=="MES"
       EXIT
    ENDIF

    nAt  :=nAt-1

    IF nAt=0
      EXIT
    ENDIF

  ENDDO

  oBrMayor:cMes:=""
  oBrMayor:cAno:=""

  IF !Empty(aLine) .AND. aLine[1]="MES"
     cMes  :=aLine[2]
     cAno  :=aLine[3]
     dFecha:=CTOD(cDia+"/"+cMes+"/"+cAno)

     oBrMayor:cMes:=cMes
     oBrMayor:cAno:=cAno

  ENDIF

RETURN dFecha


FUNCTION VERBROWSE(lMayor)
  LOCAL aLine  :=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt]
  LOCAL cCodCta:=oBrMayor:GETCTACON(),nLen:=LEN(cCodCta)
  LOCAL cWhereL:="LEFT(MOC_CUENTA,"+LSTR(LEN(ALLTRIM(cCodCta)))+")"+GetWhere("=",ALLTRIM(cCodCta))
  LOCAL cActual:={"S","C","A","F"}
  LOCAL lDelete:=NIL,cCodMon:=oBrMayor:cCodMon,lSldIni:=.T.
  LOCAL dDesdeA,dHastaA,nPeriodo:=10
  LOCAL dDesde  :=oBrMayor:dDesde
  LOCAL dHasta  :=oBrMayor:dHasta
  LOCAL cWhere  

  LOCAL RGO_C1:=NIL,RGO_C2:=NIL,RGO_C3:=NIL,RGO_C4:=NIL,RGO_I1:=cCodCta,RGO_F1:=cCodCta,RGO_I2:=NIL,RGO_F2:=NIL

  DEFAULT lMayor:=.F.

  IF Empty(cCodCta) .OR. !ISSQLFIND("DPCTA","CTA_CODIGO"+GetWhere("=",cCodCta))
     RETURN .F.
  ENDIF

  IF oBrMayor:oBrw:nColSel=3
     // Buscamos el ejercicio Anterior
     dDesdeA:=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA","EJE_HASTA"+GetWhere("<",oBrMayor:dDesde)+" ORDER BY EJE_HASTA DESC LIMIT 1")
     dHastaA:=DPSQLROW(2,dDesdeA)

     IF !Empty(dDesdeA)
        dDesde  :=dDesdeA
        dHasta  :=dHastaA
        nPeriodo:=11
     ENDIF

// ? dDesdeA,dHastaA,CLPCOPY(oDp:cSql)

  ENDIF

  cActual:={"S","A","C","F"}
  cWhere :="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+cWhereL+" AND "+;
                       GetWhereOr("MOC_ACTUAL",cActual)

//cWhere:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)

// ? cWhere,"cWhere"


  IF oBrMayor:oBrw:nColSel=8 .AND. lMayor .AND. "Saldo Anterior"$aLine[5]

    EJECUTAR("PERIODOMAS",oBrMayor:oPeriodo:nAt,NIL,NIL,-1,oBrMayor:dHasta)
                        
    dDesde  :=oDp:aFechas[1]
    dHasta  :=oDp:aFechas[2]

    EJECUTAR("BRWMAYORANALITICO",NIL,dDesde,dHasta,RGO_C1,RGO_C2,RGO_C3,RGO_C4,RGO_I1,RGO_F1,RGO_I2,RGO_F2)

  ELSE

    EJECUTAR("BRDPASIENTOS",cWhere,NIL,nPeriodo,dDesde,dHasta,NIL,cCodCta,cActual,lDelete,cCodMon,lSldIni)

  ENDIF

// cActual,lDelete,cCodMon,lSldIni


RETURN .T.

/*
// Imprimir Balance de Comprobación
*/
FUNCTION PRINTBALCOM()
  LOCAL oRep:=REPORTE("MAYOR_AN3")

  oRep:SetRango(2,oBrMayor:dDesde,oBrMayor:dHasta)

RETURN .T.

FUNCTION VERORG()
  LOCAL aLine  :=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt]
  LOCAL cNumCbt:=aLine[02]
  LOCAL dFecha :=aLine[01]
  LOCAL cActual:=aLine[13] // FALTA EL ASIENTO DEL AUDITOR, AJUSTE FISCAL O AJUSTE FINANCIERO aLine[10]
  LOCAL cItem  :=aLine[12] // MOC_ITEM
  LOCAL cCodSuc:=oDp:cSucursal
  LOCAL cTipDoc:=aLine[03]
  LOCAL cOrg   :=aLine[10]
  LOCAL cCodigo:=""
  LOCAL cNumero:=aLine[04]
  LOCAL cTipTra:=aLine[09]
  LOCAL cCodCta:=oBrMayor:GETCTACON()
  LOCAL cWhere 
  LOCAL dDesde  :=oBrMayor:dDesde
  LOCAL dHasta  :=oBrMayor:dHasta
  LOCAL nPeriodo:=oBrMayor:nPeriodo

  IF aLine[01]="MES" .OR. aLine[01]="TMES"
     dDesde  :=CTOD("01/"+aLine[02]+"/"+aLine[03])
     dHasta  :=FCHFINMES(dDesde)
     nPeriodo:=oDp:nMensual
  ENDIF




  IF aLine[01]="CTA" .OR. aLine[01]="MES" .OR. aLine[01]="TMES"
     // busca por Origen
    cWhere:="MOC_CUENTA"+GetWhere("=",cCodCta)
    EJECUTAR("BRASIENTORESORG",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,NIL,NIL,NIL,cCodCta)
    RETURN 
  ENDIF

  
  dDesde :=CTOO(aLine[01]+"/"+oBrMayor:cMes+"/"+oBrMayor:cAno,"D")
  cWhere :="MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "MOC_CUENTA"+GetWhere("=",cCodCta)+" AND "+;
           "MOC_FECHA" +GetWhere("=",dDesde )+" AND "+;
           "MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
           "MOC_ITEM"  +GetWhere("=",cItem  )
          
  cCodigo:=SQLGET("DPASIENTOS","MOC_CODAUX",cWhere)

  // ? oBrMayor:cMes,oBrMayor:cAno,"MES,AÑO",dDesde,"<-dDesde",cCodigo,"<-cCodigo",CLPCOPY(oDp:cSql)

  EJECUTAR("DPASIENTOSFRMORG",cCodSuc,cOrg,cTipDoc,cCodigo,cNumero,cTipTra,cCodCta)

//? "PENDIENTE POR IMPLEMENTAR, Falta el MOC_ACTUAL"

RETURN 
/*
// Ver Cbte Contable
*/
FUNCTION VERCBTE()
  LOCAL aLine     :=oBrMayor:oBrw:aArrayData[oBrMayor:oBrw:nArrayAt]
  LOCAL cNumCbt   :=aLine[02]
  LOCAL dFecha    :=oBrMayor:GETFECHA()
  LOCAL cActual   :=aLine[13]  // FALTA EL ASIENTO DEL AUDITOR, AJUSTE FISCAL O AJUSTE FINANCIERO aLine[10]
  LOCAL cWhere    :="MOC_NUMPAR"+GetWhere("=",aLine[11])
  LOCAL cCodSuc   :=oDp:cSucursal
  LOCAL cCodCta   :=oBrMayor:GETCTACON()
  LOCAL nPeriodo  :=oBrMayor:nPeriodo
  LOCAL dDesde    :=dFecha
  LOCAL dHasta    :=dFecha

  // Por resolver
  IF .F. // aLine[01]="MES" .OR. aLine[01]="TMES"
     dDesde  :=CTOD("01/"+aLine[02]+"/"+aLine[03])
     dHasta  :=FCHFINMES(dDesde)
     dFecha  :=dDesde
     nPeriodo:=oDp:nMensual
  ENDIF

  IF Empty(cNumCbt) 

    EJECUTAR("DPCBTE",cActual,cNumCbt,dFecha,.F.,NIL,cWhere)

  ELSE
   
    cWhere:="MOC_ORIGEN"+GetWhere("=",aLine[10])+" AND "+;
            "MOC_FECHA "+GetWhere("=",dFecha   )+" AND "+;
            "MOC_ACTUAL"+GetWhere("=",cActual  )+" AND "+;
            "MOC_CUENTA"+GetWhere("=",cCodCta  )

    IF Empty(dFecha)

       dDesde  :=CTOD("")
       dHasta  :=CTOD("")
       cWhere  :="MOC_CUENTA"+GetWhere("=",cCodCta)+" AND "+GetWhereOr("MOC_ACTUAL",oBrMayor:aActual)
       nPeriodo:=oDp:nIndefinida

    ENDIF

    EJECUTAR("BRRECCBTCON",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,"TITULO",cCodCta)

  ENDIF

RETURN .T.
// EJECUTAR('DPCBTEFRMORG',cCodSuc,cNumCbt,dFecha,cActual)


// EOF
