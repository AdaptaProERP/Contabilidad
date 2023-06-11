// Programa   : DPCREACONTADOR
// Fecha/Hora : 10/06/2023 01:28:31
// Prop�sito  : Creaci�n del Registro del Contador para activaci�n de la Licencia
// Creado Por : Juan Navas
// Llamado por: DPLLAVE.HRB
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oBtnFrm,cRif)
  LOCAL oDlg,oFont,oFontB,oBtn,aSay:={},I,oSay,nLine
  LOCAL lOk:=.F.
  LOCAL nWidth   :=390+60+40+50, nHeight:=300-40
  LOCAL aPoint   :=IF(oBtnFrm=NIL , NIL , AdjustWnd( oBtnFrm, nWidth, nHeight ))
  LOCAL aUtiliz  :={"Independiente","Firma Contable","Estudiante","Acad�mico","Otro"}
  LOCAL aSexo    :={"Femenino","Masculino"}
  LOCAL aLine    :={}
  LOCAL aEstados :={"-Seleccionar","Amazonas","Anzo�tegui","Apure","Aragua","Barinas","Bol�var","Carabobo","Cojedes","Delta Amacuro","Distrito Federal","Falc�n","Gu�rico",;
                    "Lara","M�rida","Miranda","Monagas","Nueva Esparta","Portuguesa","Sucre","T�chira","Trujillo","Vargas","Yaracuy","Zulia"}

  LOCAL oTel1,oTel2,oEmail,oCI
  LOCAL oBtn2,oBtn2
  LOCAL oCliente,cCodigo

  LOCAL oRif,oNombre,oCantCli,oEstado
  LOCAL cNombre:=SPACE(80)
  LOCAL cTel1  :=SPACE(20)
  LOCAL cTel2  :=SPACE(20)
  LOCAL cEmail :=SPACE(80)
  LOCAL cCPC   :=SPACE(06)
  LOCAL cSexo  :=aSexo[1]
  LOCAL cUtiliz:=aUtiliz[1]
  LOCAL cEstado:=aEstados[1]
  LOCAL nCantCli:=0

  DEFAULT cRif:=SPACE(12)

  AADD(aSay,{"RIF:"            ,NIL})
  AADD(aSay,{"Nombre:"         ,NIL})
  AADD(aSay,{"Uso:"            ,NIL})
  AADD(aSay,{"Sexo:"           ,NIL})
  AADD(aSay,{"Cant. Clientes:" ,NIL})
  AADD(aSay,{"Tel�fono 1:"     ,NIL})
  AADD(aSay,{"Tel�fono 2:"     ,NIL})
  AADD(aSay,{"Correo:"         ,NIL})
  AADD(aSay,{"#CPC:"           ,NIL})
  AADD(aSay,{"Regi�n:"         ,NIL})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0,-10
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0,-11 BOLD

  IF aPoint=NIL

     DEFINE DIALOG oDlg;
            TITLE "Registro de Usuario Contable ";
            FROM 0,0 TO 18+06+5-08,47+10+10+5;
            COLOR NIL,oDp:nGris
  ELSE

     DEFINE DIALOG oDlg;
            TITLE "Registro de Usuario Contable ";
            PIXEL OF oBtnFrm:oWnd;
            STYLE nOr( DS_SYSMODAL, DS_MODALFRAME );
            COLOR NIL,oDp:nGris


  ENDIF

  oDlg:lHelpIcon:=.F.

  @ .5+1.2,22+0.1 BITMAP oDp:oBmp FILENAME "bitmaps\contadur�a.bmp" OF oDlg  SIZE 58.5+48,097+25.7+14 NOBORDER

  FOR I=1 TO LEN(aSay)

    nLine:=1.2+(I*.8)

    @ nLine,.5 SAY oSay PROMPT aSay[I,1] SIZE 45,10;
              COLOR NIL,oDp:nGris RIGHT FONT oFontB OF oDlg

    aSay[I,2]:=oSay:nTop

  NEXT I


  @ aSay[1,2],50 GET oRif VAR cRif PICTURE "@!";
                 SIZE 42,10;
                 VALID VALRIFCLI(cRif,oRif);
                 COLOR NIL,CLR_WHITE PIXEL FONT oFontB OF oDlg

  @ aSay[2,2],50 GET oNombre VAR cNombre;
                 VALID !Empty(cNombre);
                 SIZE 120,10;
                 COLOR NIL,CLR_WHITE PIXEL FONT oFontB

   @ aSay[3,2],50 COMBOBOX oUtiliz  VAR cUtiliz ITEMS aUtiliz;
                  SIZE 100,NIL;
                  COLOR NIL,CLR_WHITE PIXEL FONT oFontB

   @ aSay[4,2],50 COMBOBOX oSexo  VAR cSexo ITEMS aSexo;
                  SIZE 100,NIL;
                  COLOR NIL,CLR_WHITE PIXEL FONT oFontB

  @ aSay[5,2],50 GET oCantCli VAR nCantCli;
                 COLOR NIL,CLR_WHITE;
                 PICTURE "999" RIGHT;
                 SIZE 20,10 PIXEL FONT oFontB

  @ aSay[6,2],50 GET oTel1 VAR cTel1;
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[7,2],50 GET oTel2 VAR cTel2;
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[8,2],50 GET oEmail VAR cEmail;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[9,2],50 GET oCPC VAR cCPC PICTURE "999999999";
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[10,2],50 COMBOBOX oEstado  VAR cEstado ITEMS aEstados;
                  SIZE 100,NIL;
                  COLOR NIL,CLR_WHITE PIXEL FONT oFontB;
                  ON CHANGE VALCONTADOR()

/*
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0,-14

  @ 6.5+2.5+.5-2,17+5+8-14 BUTTON " Aceptar ";
             SIZE 32,12;
             FONT oFontB;
             ACTION (lOk:=.t.,;
                 IF(lOk,oDlg:End(),NIL))

  @ 6.5+2.5+.5-2,23+5+8-14 BUTTON " Salir   ";
             SIZE 32,12;
             FONT oFontB;
             ACTION (lOk:=.F.,oDlg:End()) CANCEL

*/
  IF aPoint=NIL

    ACTIVATE DIALOG oDlg CENTERED ON INIT SETBTBAR()

  ELSE

    ACTIVATE DIALOG oDlg ON INIT (SETBTBAR(),oDlg:Move(aPoint[1], aPoint[2],NIL,NIL,.T.),;
                                  oDlg:SetSize(nWidth+40,nHeight+70+16))
                                  

  ENDIF

  IF lOk 
     aLine:={cRif,cNombre,cUtiliz,cSexo,nCantCli,cTel1,cTel2,cEmail,cCPC,cEstado}
  ENDIF

RETURN aLine

FUNCTION SETBTBAR()
  LOCAL oCursor,oBar,oBtn,oFont
 
  DEFINE CURSOR oCursor HAND
  DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (lOk:=VALCONTADOR(),;
                   IF(lOk,oDlg:End(),NIL))

   oBtn:cToolTip:="Guardar"
  
   DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XCANCEL.BMP";
         ACTION (lOk:=.F.,oDlg:End()) CANCEL

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })


RETURN .T.

FUNCTION VALRIFCLI()
RETURN .T.

FUNCTION VALCONTADOR()
   LOCAL cTitle:="Validaci�n",cTipRif:=LEFT(ALLTRIM(cRif),1)

   IF "-"$cEstado
      oEstado:MsgErr("Seleccione Estado",cTitle,220,110)
      CursorArrow()
      oEstado:Open()
      RETURN .F.
   ENDIF

   IF !(cTipRif$"VE")
      oRif:MsgErr("RIF "+cRif+" debe empezar por V o E",cTitle,280,110)
      CursorArrow()
      RETURN .F.
   ENDIF

   IF Empty(cNombre)
      oNombre:MsgErr("Introduzca el Nombre",cTitle,280,110)
      CursorArrow()
      RETURN .F.
   ENDIF

   IF Empty(cTel1+cTel2)
      oTel1:MsgErr("Introduzca #de Tel�fono",cTitle,280,110)
      CursorArrow()
      RETURN .F.
   ENDIF

   IF Empty(cEmail)
      oEmail:MsgErr("eMail Requerido",cTitle,280,110)
      CursorArrow()
      RETURN .F.
   ENDIF

   IF !EJECUTAR("EMAILVALID",cEmail)
      oEmail:MsgErr(oDp:cMail,cTitle,280,110)
      CursorArrow()
      RETURN .F.
   ENDIF

RETURN .T.
// EOF



