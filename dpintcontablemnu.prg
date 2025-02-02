// Programa   : DPINTCONTABLEMNU
// Fecha/Hora : 14/11/2014 05:39:22
// Propósito  : Menú de Integración Contable
// Creado Por : Juan Navas
// Llamado por: DPACTIVO
// Aplicación : Activos
// Tabla      : DPACTIVOS

#INCLUDE "DPXBASE.CH"
#include "outlook.ch"
#include "splitter.Ch"

PROCE MAIN()
   LOCAL aData,cWhere
   LOCAL oFont,oOut,oSpl,oCursor,oBar,oBtn,oBar,aData:={},oBrw,I,oBmp,oFontBrw,nGroup,bAction,cTitle
   LOCAL cNombre:="",dDesde,dHasta
   LOCAL cCodSuc:=oDp:cSucursal,cCodMod
   LOCAL aCoors:=GetCoors( GetDesktopWindow() ),nCount

   IF !ISSQLFIND("DPCODINTEGRA","CIN_CODIGO"+GetWhere("=","CXPNAC"))
      EJECUTAR("DPCODINTEGRAFROMDBF")
      EJECUTAR("DPCODINTEGRA_ADDALL")
   ENDIF

   cNombre:="Integración Contable"

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontBrw NAME "Tahoma" SIZE 0,-10 BOLD

   cTitle:="Definición de la Integración Contable "

   DpMdi(cTitle,"oMnuIntC","TEST.EDT")

   oMnuIntC:cCodSuc :=cCodSuc
   oMnuIntC:cNombre :=cNombre
   oMnuIntC:lSalir  :=.F.
   oMnuIntC:nHeightD:=45
   oMnuIntC:cTitle  :=cTitle
   oMnuIntC:lMsgBar :=.F.
   oMnuIntC:oFrm    :=oFrm

   SetScript("DPINTCONTABLEMNU")

// oMnuIntC:Windows(0,0,400+195,410)

  oMnuIntC:Windows(0,0,oDp:aCoors[3]-170,415)  

  @ 48+18, -1 OUTLOOK oMnuIntC:oOut ;
              SIZE (150+250)-0, oMnuIntC:oWnd:nHeight()-106;
              PIXEL ;
              FONT oFont ;  
              OF oMnuIntC:oWnd;
              COLOR CLR_BLACK,oDp:nGris

   DEFINE GROUP OF OUTLOOK oMnuIntC:oOut PROMPT "&Definición de Transacciones"

/*
   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\grupos.BMP";
          PROMPT "Grupo de Productos";
          ACTION  EJECUTAR("BRDPGRUCTA")

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\producto.BMP";
          PROMPT "Productos";
          ACTION  EJECUTAR("BRDPINVCTA")
*/

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\codtransacciones.BMP";
          PROMPT " "+oDp:DPINVTRAN;
          ACTION  EJECUTAR("BRDPINVTRANCTA")


   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\CLIENTE.BMP";
          PROMPT "Tipo de Documento del Cliente";
          ACTION EJECUTAR("BRTIPDOCCLICTA")


   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\PROVEEDORES.BMP";
          PROMPT "Tipo de Documento del Proveedor";
          ACTION EJECUTAR("BRTIPDOCPROCTA")


   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\compras.BMP";
          PROMPT "Tipo de IVA Compras";
          ACTION EJECUTAR("BRTIPIVASETCTA",NIL,NIL,NIL,NIL,NIL," COMPRAS ",.F.,"CTACOM")

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\ventascxc.BMP";
          PROMPT "Integración con Tipo de IVA Ventas ";
          ACTION EJECUTAR("BRTIPIVASETCTA",NIL,NIL,NIL,NIL,NIL," VENTAS",.F.,"CTAVTA")

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\codintegracion.bmp";
          PROMPT "Cuentas por Códigos de Integración";
          ACTION EJECUTAR("BRDPCODINTCTA")

   DEFINE GROUP OF OUTLOOK oMnuIntC:oOut PROMPT "&Tablas Maestras"

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\grupos.BMP";
          PROMPT "Grupo de Productos";
          ACTION  EJECUTAR("BRDPGRUCTA")

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\producto.BMP";
          PROMPT "Productos";
          ACTION  EJECUTAR("BRDPINVCTA")

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\GACTIVOS.BMP";
          PROMPT "Grupo de Activos";
          ACTION  EJECUTAR("BRGRUACTIVOSCTA")

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\ACTIVOS.BMP";
          PROMPT "Activos";
          ACTION  EJECUTAR("BRDPATVCTA")

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\PROVEEDORES.BMP";
          PROMPT "Proveedor";
          ACTION EJECUTAR("BRPROVEEDORCTA")

//          BITMAP "BITMAPS\CONTABCXC.BMP";

   DEFINE BITMAP OF OUTLOOK oMnuIntC:oOut ;
          BITMAP "BITMAPS\CLIENTE.BMP";
          PROMPT "Cliente";
          ACTION EJECUTAR("BRCLIENTESCTA")

  
   oMnuIntC:Activate("oMnuIntC:FRMINIT()")

RETURN NIL

FUNCTION FRMINIT()
  LOCAL oCursor,oBar,oBtn,oFont,nCol:=12

  DEFINE BUTTONBAR oBar SIZE 44+10+17,44+20 OF oMnuIntC:oWnd 3D CURSOR oCursor

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\codintegracion.bmp";
          MENU oMnuIntC:MENU_TES("MENU_TESRUN","UNO");
          TOP PROMPT "Códigos"; 
          ACTION DPLBX("DPCODINTEGRA.LBX")

  oBtn:cToolTip:="Códigos de Integración"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oMnuIntC:End()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10  BOLD

  @ 00.0,20+32 SAY " "+DTOC(oDp:dFchInicio)+" " OF oBar BORDER SIZE 80,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
  @ 01.4,20+32 SAY " "+DTOC(oDp:dFchCierre)+" " OF oBar BORDER SIZE 80,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont 

  oBar:Refresh(.T.)

  oMnuIntC:oWnd:bResized:={||oMnuIntC:oWnd:oClient := oMnuIntC:oOut,;
                              oMnuIntC:oWnd:bResized:=NIL}

                       
RETURN .T.


FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPINTCONTAB",oMnuIntC:cCodSuc,NIL,NIL,NIL,NIL,cConsulta)

FUNCTION MENU_TES(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oMnuIntC:cVarName

   AADD(aOption,{"Exportar",".F."})
   AADD(aOption,{"Importar",".F."})
   AADD(aOption,{"",""})
   AADD(aOption,{"Subir"    ,".F."})
   AADD(aOption,{"Descargar",".F."})

   C5MENU oPopFind POPUP;
          COLOR    oDp:nMenuItemClrText,oDp:nMenuItemClrPane;
          COLORSEL oDp:nMenuItemSelText,oDp:nMenuItemSelPane;
          COLORBOX oDp:nMenuBoxClrText;
          HEIGHT   oDp:nMenuHeight;
          FONT     oDp:oFontMenu;
          LOGOCOLOR oDp:nMenuMainClrText

          FOR I=1 TO LEN(aOption)

           IF Empty(aOption[I,1])

              C5SEPARATOR

            ELSE

              nContar++

              bAction:=cFrm+":lTodos:=.F.,oMnuIntC:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_TESRUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF nOption=1
      RETURN EJECUTAR("BRCNDPLACTAXPRO")
   ENDIF

   IF nOption=2
     RETURN EJECUTAR("DPDOCCXP")
   ENDIF

   IF nOption=3
      RETURN EJECUTAR("BRCXP")
   ENDIF

   IF nOption=4
      RETURN EJECUTAR("BRDOCPROCREAPLA")
   ENDIF

   IF nOption=5
      RETURN EJECUTAR("DPDOCCXC")
   ENDIF

   IF nOption=6
      RETURN EJECUTAR("BRCXC")
   ENDIF
                                                                                                 
RETURN .T.




// EOF
