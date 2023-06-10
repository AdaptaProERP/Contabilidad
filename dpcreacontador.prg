// Programa   : DPCREACONTADOR
// Fecha/Hora : 10/06/2023 01:28:31
// Propósito  : Creación del Registro del Contador para activación de la Licencia
// Creado Por : Juan Navas
// Llamado por: DPLLAVE.HRB
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oBtnFrm,cRif)
  LOCAL oDlg,oFont,oFontB,oBtn,aSay:={},I,oSay,nLine
  LOCAL lOk:=.F.
  LOCAL nWidth   :=390+60+40, nHeight:=310
  LOCAL aPoint   :=IF(oBtnFrm=NIL , NIL , AdjustWnd( oBtnFrm, nWidth, nHeight ))
  LOCAL aTipo    :={"Independiente","Firma Contable","Estudiante","Académico","Otro"}
  LOCAL aSexo    :={"Femenino","Masculino"}
  LOCAL aLine    :={}
  LOCAL aEstados :={"Amazonas","Anzoátegui","Apure","Aragua","Barinas","Bolívar","Carabobo","Cojedes","Delta Amacuro","Distrito Federal","Falcón","Guárico",;
                    "Lara","Mérida","Miranda","Monagas","Nueva Esparta","Portuguesa","Sucre","Táchira","Trujillo","Vargas","Yaracuy","Zulia"}

  LOCAL oTel1,oTel2,oEmail,oCI
  LOCAL oBtn2,oBtn2
  LOCAL oCliente,cCodigo

  LOCAL oRif,oNombre,oCantCli
  LOCAL cNombre:=SPACE(80)
  LOCAL cTel1  :=SPACE(20)
  LOCAL cTel2  :=SPACE(20)
  LOCAL cEmail :=SPACE(80)
  LOCAL cCPC   :=SPACE(06)
  LOCAL cSexo  :=aSexo[1]
  LOCAL cTipo  :=aTipo[1]
  LOCAL cEstado:=aEstados[1]
  LOCAL nCantCli:=0

  DEFAULT cRif:=SPACE(12)

  AADD(aSay,{"RIF:"            ,NIL})
  AADD(aSay,{"Nombre:"         ,NIL})
  AADD(aSay,{"Tipo:"           ,NIL})
  AADD(aSay,{"Sexo:"           ,NIL})
  AADD(aSay,{"Cant. Clientes:" ,NIL})
  AADD(aSay,{"Teléfono 1:"     ,NIL})
  AADD(aSay,{"Teléfono 2:"     ,NIL})
  AADD(aSay,{"Correo:"         ,NIL})
  AADD(aSay,{"#CPC:"           ,NIL})
  AADD(aSay,{"Región:"         ,NIL})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0,-10
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0,-11 BOLD

  IF aPoint=NIL

     DEFINE DIALOG oDlg;
            TITLE "Registro de Usuario Contable ";
            FROM 0,0 TO 18+06+5-08,47+10+10-00;
            COLOR NIL,oDp:nGris
  ELSE

     DEFINE DIALOG oDlg;
            TITLE "Registro de Usuario Contable ";
            PIXEL OF oGet:oWnd;
            STYLE nOr( DS_SYSMODAL, DS_MODALFRAME );
            COLOR NIL,oDp:nGris


  ENDIF

  oDlg:lHelpIcon:=.F.

  FOR I=1 TO LEN(aSay)

    nLine:=(I*.8)

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

   @ aSay[3,2],50 COMBOBOX oTipo  VAR cTipo ITEMS aTipo;
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

  @ aSay[7,2],50 GET oTel1 VAR cTel2;
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[8,2],50 GET oEmail VAR cEmail;
                 COLOR NIL,CLR_WHITE;
                 SIZE 120,10 PIXEL FONT oFontB

  @ aSay[9,2],50 GET oCI VAR cCPC PICTURE "999999999";
                 COLOR NIL,CLR_WHITE;
                 SIZE 80,10 PIXEL FONT oFontB

  @ aSay[10,2],50 COMBOBOX oEstado  VAR cEstado ITEMS aEstados;
                  SIZE 100,NIL;
                  COLOR NIL,CLR_WHITE PIXEL FONT oFontB

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0,-14

  @ 6.5+2.5+.5-2,17+5+8-14 BUTTON " Aceptar ";
             SIZE 32,12;
             FONT oFontB;
             ACTION (lOk:=CLIGRABAR(cRif) ,;
                 IF(lOk,oDlg:End(),NIL))

  @ 6.5+2.5+.5-2,23+5+8-14 BUTTON " Salir   ";
             SIZE 32,12;
             FONT oFontB;
             ACTION (lOk:=.F.,oDlg:End()) CANCEL


  IF aPoint=NIL

    ACTIVATE DIALOG oDlg CENTERED

  ELSE

    ACTIVATE DIALOG oDlg ON INIT (oDlg:Move(aPoint[1], aPoint[2],NIL,NIL,.T.),;
                                  oDlg:SetSize(nWidth+40,nHeight+70+16))
                                  

  ENDIF

  IF lOk 
     aLine:={cRif}
  ENDIF

RETURN aLine

FUNCTION VALRIFCLI()
RETURN .T.
// EOF



