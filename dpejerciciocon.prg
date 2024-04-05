// Programa   : DPEJERCICIOCON
// Fecha/Hora : 14/11/2014 05:39:22
// Propósito  : Menú de Activo
// Creado Por : Juan Navas
// Llamado por: DPACTIVO
// Aplicación : Activos
// Tabla      : DPACTIVOS

#INCLUDE "DPXBASE.CH"
#include "outlook.ch"
#include "splitter.Ch"

PROCE MAIN(oFrm,cNumEje)
   LOCAL aData,cWhere
   LOCAL oFont,oOut,oSpl,oCursor,oBar,oBtn,oBar,aData:={},oBrw,I,oBmp,oFontBrw,nGroup,bAction,cTitle
   LOCAL cNombre:="",dDesde,dHasta
   LOCAL cCodSuc:=oDp:cSucursal,cCodMod,nContab:=0
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   IF Empty(oDp:cNumEje)
      oDp:cNumEje:=EJECUTAR("GETNUMEJE")
   ENDIF

   DEFAULT cNumEje:=oDp:cNumEje

   IF ValType(oFrm)="O"
     cNumEje:=oFrm:EJE_NUMERO
     cCodSuc:=oFrm:EJE_CODSUC
   ENDIF

   dDesde :=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA,EJE_CTAMOD","EJE_NUMERO"+GetWhere("=",cNumEje))
   dHasta :=DPSQLROW(2)
   cCodMod:=DPSQLROW(3)

   cNombre:=DTOC(dDesde)+" - "+DTOC(dHasta)

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontBrw NAME "Tahoma" SIZE 0,-10 BOLD

   cTitle:="Consulta "+GetFromVar("{oDp:xDPEJERCICIOS}")

   DpMdi(cTitle,"oConEje","TEST.EDT")

   oConEje:cNumEje :=cNumEje
   oConEje:cCodSuc :=cCodSuc
   oConEje:cNombre :=cNombre
   oConEje:lSalir  :=.F.
   oConEje:nHeightD:=45
   oConEje:cTitle  :=cTitle
   oConEje:lMsgBar :=.F.
   oConEje:oFrm    :=oFrm
// oConEje:cTipoAct:=cTipoAct
   oConEje:nContab :=nContab
// oConEje:nDesinc :=nDesinc
   oConEje:cCodMod :=cCodMod
   oConEje:cWhereC :=NIL

   oConEje:dDesde  :=dDesde
   oConEje:dHasta  :=dHasta

   SetScript("DPEJERCICIOMNU")

//   oConEje:Windows(0,0,400+195,410)
   oConEje:Windows(0,0,aCoors[3]-160,415)  

  @ 48, -1 OUTLOOK oConEje:oOut ;
     SIZE 150+250, oConEje:oWnd:nHeight()-85 ;
     PIXEL ;
     FONT oFont ;
     OF oConEje:oWnd;
     COLOR CLR_BLACK,oDp:nGris2

   DEFINE GROUP OF OUTLOOK oConEje:oOut PROMPT "&Estados Financieros"

   DEFINE BITMAP OF OUTLOOK oConEje:oOut;
          BITMAP "BITMAPS\balancecomprobacion.bmp";
          PROMPT "Balance de Comprobación";
          ACTION EJECUTAR("BRWCOMPROBACION",NIL,oConEje:dDesde,oConEje:dHasta)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\mayoranalitico.BMP";
          PROMPT "Mayor Analítico";
          ACTION  EJECUTAR("BRWMAYORANALITICO",NIL,oConEje:dDesde,oConEje:dHasta)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\BalanceGeneral.BMP";
          PROMPT "Balance General";
          ACTION  EJECUTAR("BRWBALANCEGENERAL",NIL,oConEje:dHasta)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut;
          BITMAP "BITMAPS\edodegananciayperdida.bmp";
          PROMPT "Resultado (Ganancias y Pérdidas)";
          ACTION EJECUTAR("BRWGANANCIAYP",NIL,oConEje:dDesde,oConEje:dHasta,4)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\XSALIR.BMP";
          PROMPT "Salida";
          ACTION oConEje:End()

   DEFINE GROUP OF OUTLOOK oConEje:oOut PROMPT "&Otras Consultas"

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\VIEW.BMP";
          PROMPT "Ficha del Ejercicio";
          ACTION  EJECUTAR("DPEJERCICIOS",2,oConEje:cNumEje)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\XBROWSEAMARILLO.BMP";
          PROMPT "Comprobantes del Ejercicio";
          ACTION  EJECUTAR("BRRECCBTCON",oConEje:cWhereC,oConEje:cCodSuc,11,oConEje:dDesde,oConEje:dHasta,NIL)


   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\contabilidad.BMP";
          PROMPT "Resumen de Saldos por Cuenta";
          ACTION  EJECUTAR("BRCTARESSLD",NIL,NIL,11,oConEje:dDesde,oConEje:dHasta," Ejercicio "+oConEje:cNumEje)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\xbrowse.BMP";
          PROMPT "Resumen con Acceso a Detalles";
          ACTION  oConEje:VERRESUMEN()


   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\depreciacionver.BMP";
          PROMPT "Depreciación de Activos";
          ACTION  oConEje:VERDEPRECIA()

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\cbteactualizado.BMP";
          PROMPT "Balance de Apertura";
          ACTION  EJECUTAR("BRCTARESSLD",NIL,NIL,11,oConEje:dDesde,oConEje:dHasta," Ejercicio "+oConEje:cNumEje)

 

IF ISRELEASE("22.01")

/*
   DEFINE BITMAP OF OUTLOOK oConEje:oOut;
          BITMAP "BITMAPS\balancecomprobacion.bmp";
          PROMPT "Balance de Comprobación";
          EJECUTAR("BRWCOMPROBACION",NIL,oConEje:dDesde,oConEje:dHasta)
*/


 

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\comparativo.BMP";
          PROMPT "Balance de Comprobación Vs Mayor Analítico";
          ACTION  EJECUTAR("BRMAYVSBALCOM",NIL,NIL,12,oConEje:dDesde,oConEje:dHasta)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\math.BMP";
          PROMPT "Ecuación del Patrimonio";
          ACTION  EJECUTAR("BREJERRESRES",NIL,NIL,12,oConEje:dDesde,oConEje:dHasta)

ENDIF

/*

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\DEPRECIACIONVER.BMP";
          PROMPT "Balance de Cierre y Apertura";
          ACTION  EJECUTAR("BRBALANCEFIN",oConEje:cCodSuc,oConEje:cNumEje)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\cierrecontab.bmp";
          PROMPT "Ejecutar Cierre del Ejercicio";
          ACTION EJECUTAR("CIERRECONTAB",oConEje:cCodSuc,oConEje:dDesde,oConEje:dHasta,oConEje:cNumEje)

// Futuro Release, hacer transición
IF .F.

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\exportdocum.bmp";
          PROMPT "Transición Contable";
          ACTION EJECUTAR("BRBALANCETRAN",oConEje:cCodSuc,oConEje:cNumEje)

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\exportdocum.bmp";
          PROMPT "Consultar Cuentas Transición";
          ACTION EJECUTAR("BRCTATRANSIC","BTI_NUMEJE"+GetWhere("=",oConEje:cNumEje)+" AND "+;
                                         "BTI_CODSUC"+GetWhere("=",oConEje:cCodSuc))
ENDIF

  

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\exportdocum.bmp";
          PROMPT "Reversión de Cierre";
          ACTION EJECUTAR("BRDPCBTEFIN","CBT_CODSUC"+GetWhere("=",oConEje:cCodSuc)+" AND CBT_NUMEJE"+GetWhere("=",oConEje:cNumEje),NIL,11)

//EJECUTAR("REVCIERRECON",oConEje:cCodSuc,oConEje:cNumEje)
   

  DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\Procesos.bmp";
          PROMPT "Cálcular Saldos de las Cuentas";
          ACTION EJECUTAR("DPCTASLDCREA",oConEje:cCodSuc,oConEje:dDesde,oConEje:dHasta,oConEje:cCodMod,.T.,.T.)

*/
/*

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\balancecomprobacion.bmp";
          PROMPT "Balance de Comprobación";
          ACTION EJECUTAR("BRWCOMPROBACION",NIL,oConEje:dDesde,oConEje:dHasta)
*/

   DEFINE BITMAP OF OUTLOOK oConEje:oOut ;
          BITMAP "BITMAPS\PASTE.BMP";
          PROMPT "Ver Asientos Depurados desde Repetidos";
          ACTION EJECUTAR("BRASIENTOSDEP",NIL,NIL,12,oConEje:dDesde,oConEje:dHasta)

   DEFINE DIALOG oConEje:oDlg FROM 0,oConEje:oOut:nWidth() TO oConEje:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oConEje:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oConEje:oGrp TO 10,10 PROMPT "Código ["+oConEje:cNumEje+"]"

   @ .5,.5 SAY oConEje:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontBrw

   ACTIVATE DIALOG oConEje:oDlg NOWAIT VALID .F.

   oConEje:Activate("oConEje:FRMINIT()")

   EJECUTAR("DPSUBMENUCREAREG",oConEje,NIL,"C","DPEJERCICIOS")

RETURN .T.


FUNCTION FRMINIT()


   oConEje:oWnd:bResized:={||oConEje:oDlg:Move(0,0,oConEje:oWnd:nWidth(),50,.T.),;
                             oConEje:oGrp:Move(0,0,oConEje:oWnd:nWidth()-15,oConEje:nHeightD,.T.)}

   EVal(oConEje:oWnd:bResized)


RETURN .T.

/*
// Importar Cuentas
*/
FUNCTION IMPORTARCTA()
   LOCAL cCtaMod:=SQLGET("DPEJERCICIOS","EJE_CTAMOD","EJE_NUMERO"+GetWhere("=",oConEje:cNumEje))

   EJECUTAR("DPCTAIMPORT",NIL,NIL,cCtaMod)

RETURN .F.

FUNCTION VERCUENTAS()
   LOCAL cWhere:="BTI_NUMEJE"+GetWhere("=",oConEje:cNumEje)+" AND "+;
                 "BTI_CODSUC"+GetWhere("=",oConEje:cCodSuc)

// ? cWhere

  EJECUTAR("BRCTATRANSIC",cWhere)

RETURN .T.

FUNCTION VERRESUMEN()
  LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo,dDesde,dHasta,cTitle:=" Ejercicio "+oConEje:cNumEje

  cWhere:="MOC_NUMEJE"+GetWhere("=",oConEje:cNumEje)
  
RETURN EJECUTAR("BRDPCTARES",cWhere,cCodSuc,12,oConEje:dDesde,oConEje:dHasta,cTitle)

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPACTIVO",oConEje:cCodSuc,NIL,NIL,NIL,NIL,cConsulta)

FUNCTION VERDEPRECIA()
 LOCAL cWhere,cCodSuc:=oDp:cSucursal,nPeriodo,dDesde,dHasta,cTitle:=" Ejercicio "+oConEje:cNumEje

  cWhere:="DEP_NUMEJE"+GetWhere("=",oConEje:cNumEje)
  
RETURN EJECUTAR("BRRESDEPACT",cWhere,cCodSuc,12,oConEje:dDesde,oConEje:dHasta,cTitle)

// EOF

