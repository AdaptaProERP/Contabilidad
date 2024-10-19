// Programa   : DPCTABANCOMOV
// Fecha/Hora : 18/01/2005 23:10:42
// Propósito  : Movimiento Bancario
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Tesorería
// Tabla      : DPCTABANCOMOV
// Modificado por Orlando Perez para incluir ITF 24/11/2207
// Modificado  Leandro Sandoval para incluir la posibilidad de excluir transacciones del ITF

#INCLUDE "DPXBASE.CH"
#INCLUDE "SAYREF.CH"

PROCE MAIN(cTipo,cCodBco,cCuenta,cNumero,lView)
  LOCAL I,aData:={},oFontG,oBrwO,oBrwP,oCol,cSql,oFontB,cScope,oFont,oSayRef
  LOCAL cTitle:="Movimientos de Cuentas Bancarios",cExcluye:="",aCajas:={},aCaja:={},aPlaza:={}
  LOCAL aBcoTipo:={},aTipo:={}

  cScope:="MOB_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "MOB_ORIGEN='BCO'"

  // Solo Consulta
  DEFAULT lView:=.F. 

  IF lView

    cScope:="MOB_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
            "MOB_TIPO  "+GetWhere("=",cTipo        )+" AND "+;
            "MOB_CODBCO"+GetWhere("=",cCodBco      )+" AND "+;
            "MOB_CUENTA"+GetWhere("=",cCuenta      )+" AND "+;
            "MOB_DOCUME"+GetWhere("=",cNumero      )+" AND "+;
            "MOB_ORIGEN='BCO'"

  ELSE

    IF !Empty(cCodBco) .AND. !Empty(cCuenta)

      cScope:="MOB_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
              "MOB_CODBCO"+GetWhere("=",cCodBco      )+" AND "+;
              "MOB_CUENTA"+GetWhere("=",cCuenta      )+" AND "+;
              "MOB_ORIGEN='BCO'"

    ENDIF


  ENDIF


  aBcoTipo:=ASQL("SELECT TDB_CODIGO,TDB_NOMBRE,TDB_SIGNO FROM DPBANCOTIP ORDER BY TDB_CODIGO")

  AEVAL(aBcoTipo,{|a,n|AADD(aTipo,a[2])})

  // Font Para el Browse
  DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0, -12 BOLD
  DEFINE FONT oFont   NAME "Tahoma"   SIZE 0, -12
  DEFINE FONT oFontG  NAME "Tahoma"   SIZE 0, -12

  oBcoMov:=DOCENC(cTitle,"oBcoMov","DPCTABANCOMOV"+oDp:cModeVideo+".EDT")

  oBcoMov:cList     :="DPCTABANCOMOV.BRW"
  oBcoMov:lBar      :=.T.
  oBcoMov:nBtnStyle :=1
  oBcoMov:SetScope(cScope)
  oBcoMov:SetTable("DPCTABANCOMOV","MOB_CODSUC,MOB_CODBCO,MOB_CUENTA,MOB_TIPO,MOB_DOCUME") 
  oBcoMov:lFind     :=.T.
  oBcoMov:cScope    :=cScope
  oBcoMov:cScopeOrg :=cScope // Necesario para Desfiltrar los documentos
  oBcoMov:cCuenta   :=""
  oBcoMov:aBcoTipo  :=ACLONE(aBcoTipo)
  oBcoMov:aTipo     :=ACLONE(aTipo)
  oBcoMov:cTipo     :=aBcoTipo[1,1]
  oBcoMov:MOB_TIPO  :=oBcoMov:cTipo
  oBcoMov:cCtaNombre:=SPACE(50)
  oBcoMov:cEgrNombre:=SPACE(50)
  oBcoMov:cCenNombre:=SPACE(40)
  oBcoMov:cMoneda   :=oDp:cMoneda
  oBcoMov:lMoneda   :=.F. // No pemite editar valor cambiario
  oBcoMov:oConcil   :=NIL
  oBcoMov:cSingular :=oDp:xDPCTABANCOMOV
  oBcoMov:cList     :=NIL
  oBcoMov:cView     :="VERASIENTOS"
 
  IF lView
    oBcoMov:lInc :=.F.
    oBcoMov:lView:=.T.
    oBcoMov:lMod :=.F.
    oBcoMov:lEli :=.F.
  ENDIF

  oBcoMov:AddBtn("BANCO.bmp","Bancos","(oBcoMov:nOption=0)",;
                    "oBcoMov:LISTBANCOS()","BCO",,STR(DP_CTRL_O))

  IF DPVERSION()>4
    oBcoMov:SetAdjuntos("MOB_FILMAI") // Vinculo con DPFILEEMP
  ENDIF

   IF ISRELEASE("20.01")
 
    oBcoMov:nBtnWidth:=42
    oBcoMov:cBtnList :="xbrowse2.bmp"

    oBcoMov:BtnSetMnu("BROWSE","No Anulados"                 ,"BRWXNOA")  // No Anuladas
    oBcoMov:BtnSetMnu("BROWSE","Anulados"                    ,"BRWANUL")  // Anuladas
    oBcoMov:BtnSetMnu("BROWSE","Agrupado Por Cuenta Bancaria","BRWXCTA")  // Por Cuenta
    oBcoMov:BtnSetMnu("BROWSE","Agrupado Por Transacción"    ,"BRWXTIP")  // Por Tipo de Transaccion
    oBcoMov:BtnSetMnu("BROWSE","Agrupado Por Cuenta Contable","BRWXCTA")  // Por Cuenta Contable
    oBcoMov:BtnSetMnu("BROWSE","Agrupado Por Cuenta "+oDp:xDPCTAEGRESO,"BRWXEGR")  // Cta Egreso
    oBcoMov:BtnSetMnu("BROWSE","Liberar Filtros"         ,"BRWXLIB")  // Liberar Filtro

  ENDIF



////////////
  oBcoMov:cChk		 :=""
  oBcoMov:cFlag	 :=0
///////////

  oBcoMov:Repeat("MOB_TIPO,MOB_CODBCO,MOB_CUENTA")
  oBcoMov:cFindNoEnter:="MOB_CODBCO"
  oBcoMov:SetMemo("MOB_NUMMEM","Descripción Amplia")

  oBcoMov:AddBtn("menu.bmp","Menú de Opciones","oDoc:nOption=0","oDoc:MenuOpc()"   ,"BCO")

 // oBcoMov:AddBtn("xbrowsefecha.bmp","Visualizar por Fecha","oDoc:nOption=0","oDoc:VIEWMOVBCO()","BCO")

  oBcoMov:cPreSave   :="PRESAVE"
  oBcoMov:cPostSave  :="POSTGRABAR"
  oBcoMov:cPreDelete :="PREDELETE"
  oBcoMov:cPostDelete:="POSTDELETE" 
  oBcoMov:cSetFind   :="SETFIND"
  oBcoMov:cPreList   :="PRELIST"

  oBcoMov:cBcoNombre:="NOMBRE DEL BANCO"
  oBcoMov:cTIPO     :="CHQ"
//  oBcoMov:Windows(0,0,430+20,790)

  IIF( Empty(oDp:cModeVideo),  oBcoMov:Windows(0,0,444,798) , oBcoMov:Windows(0,0,450,810) )

  oBcoMov:aCuentas   :={}
  AADD(oBcoMov:aCuentas,"Ninguno")

  oBcoMov:cNameBco:=oDp:xDPBANCOS

  @ 2.0,0 SAYREF oSayRef PROMPT oBcoMov:cNameBco+":";
          SIZE 42,12;
          RIGHT;
          COLORS CLR_HBLUE,oDp:nGris

  oSayRef:bAction:={||oBcoMov:RUNBANCO()}

  @ 3.0,0 SAYREF oSayRef PROMPT "Cuenta:";
          SIZE 42,12;
          RIGHT;
          COLORS CLR_HBLUE,oDp:nGris

  oSayRef:bAction:={||oBcoMov:RUNCUENTA()}

  // Código Bancario
  @ 2,06 BMPGET oBcoMov:oMOB_CODBCO VAR oBcoMov:MOB_CODBCO;
                 VALID oBcoMov:VALCODBCO();
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPBANCOS",NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,oBcoMov:oMOB_CODBCO),;
                         oDpLbx:GetValue("BAN_CODIGO",oBcoMov:oMOB_CODBCO)); 
                 WHEN (AccessField("DPCTABANCOMOV","MOB_CODBCO",oBcoMov:nOption) .AND. ;
                       oBcoMov:nOption!=0 ) .OR. (oBcoMov:nOption=0 .AND. !oBcoMov:lView);
                SIZE 48,10

  oBcoMov:oMOB_CODBCO:bKeyDown:={|nKey| IIF(nKey=13, oBcoMov:VALCODBCO(), NIL ) }

  @ 3,10 SAY oBcoMov:oBcoNombre PROMPT;
             oBcoMov:cBcoNombre UPDATE

  //
  // Campo : MOB_CUENTA
  // Uso   : Moneda                                  
  //
  @ 6, 06.0 COMBOBOX oBcoMov:oMOB_CUENTA VAR oBcoMov:MOB_CUENTA ITEMS oBcoMov:aCuentas;
                     VALID oBcoMov:MOBCUENTA();
                     WHEN (AccessField("DPCTABANCOMOV","MOB_CUENTA",oBcoMov:nOption) .AND. !EMPTY(oBcoMov:MOB_CODBCO);
                           .AND.LEN(oBcoMov:oMOB_CUENTA:aItems)>1) .OR. (oBcoMov:nOption=0 .AND. LEN(oBcoMov:oMOB_CUENTA:aItems)>1)

  ComboIni(oBcoMov:oMOB_CUENTA)

  @ 4,10 SAY "Tipo Documento:" RIGHT

  //
  // Campo : MOB_TIPO
  // Uso   : Moneda                                  
  //
  @ 5, 06.0 COMBOBOX oBcoMov:oMOB_TIPO VAR oBcoMov:cTIPO ITEMS oBcoMov:aTipo;
                       VALID oBcoMov:MOBTIPO();
                       ON CHANGE oBcoMov:CHANGETIP();
                       WHEN (AccessField("DPCTABANCOMOV","MOB_TIPO",oBcoMov:nOption) .AND. !EMPTY(oBcoMov:MOB_CODBCO);
                             .AND. oBcoMov:nOption!=0)

  ComboIni(oBcoMov:oMOB_TIPO)

  @ 5,1 SAY "Transacción :" RIGHT

  @ 4,1 SAY "Documento:" RIGHT

  @ 6,60 GET oBcoMov:oMOB_DOCUME VAR oBcoMov:MOB_DOCUME;
             VALID oBcoMov:MOBDOCUME();
             WHEN (AccessField("DPCTABANCOMOV","MOB_DOCUME",oBcoMov:nOption);
                   .AND. oBcoMov:nOption!=0);
             SIZE NIL,10 PIXEL

  @ 1,1 SAY "Fecha:" RIGHT

  @ 0.9,43 BMPGET oBcoMov:oMOB_FECHA  VAR oBcoMov:MOB_FECHA;
           PICTURE "99/99/9999";
           NAME "BITMAPS\Calendar.bmp";
           VALID oBcoMov:MOBFECHA();
           ACTION LbxDate(oBcoMov:oMOB_FECHA ,oBcoMov:MOB_FECHA);
           WHEN  (AccessField("DPCTABANCOMOV","MOB_FECHA",oBcoMov:nOption);
                 .AND. oBcoMov:nOption!=0 .AND. !Empty(oBcoMov:MOB_CUENTA));
           SIZE 46,10

  @ 5,1 SAY "Descripción:" RIGHT

  @ 7,10 GET oBcoMov:oMOB_DESCRI VAR oBcoMov:MOB_DESCRI;
             VALID oBcoMov:MOBDESCRI();
             WHEN (AccessField("DPCTABANCOMOV","MOB_DESCRI",oBcoMov:nOption);
                   .AND. oBcoMov:nOption!=0 .AND. !Empty(oBcoMov:MOB_CUENTA));
             SIZE NIL,10 PIXEL

  @ 9,1 SAY "Monto:" RIGHT

  @ 9,10 GET oBcoMov:oMOB_MONTO VAR oBcoMov:MOB_MONTO;
             PICTURE "9,999,999,999,999.99" RIGHT;
             VALID oBcoMov:MOBMONTO();
             WHEN (AccessField("DPCTABANCOMOV","MOB_MONTO",oBcoMov:nOption);
                   .AND. oBcoMov:nOption!=0);
             SIZE NIL,10 PIXEL

//           .AND. oBcoMov:nOption!=0 .AND. !EMPTY(oBcoMov:MOB_DESCRI));

  @ 9,1 SAY "Valor Cambiario:" RIGHT

  @ 9,10 GET oBcoMov:oMOB_VALCAM VAR oBcoMov:MOB_VALCAM;
             PICTURE "9,999,999,999,999.99" RIGHT;
             VALID oBcoMov:MOBMONNAC();
             WHEN (AccessField("DPCTABANCOMOV","MOB_VALCAM",oBcoMov:nOption);
                   .AND. oBcoMov:nOption!=0 .AND. !EMPTY(oBcoMov:MOB_MONTO) .AND. oBcoMov:lMoneda);
             SIZE NIL,10 PIXEL

  @ 9,1 SAY "En Moneda Nacional:" RIGHT

  @ 9,10 GET oBcoMov:oMOB_MONNAC VAR oBcoMov:MOB_MONNAC;
             PICTURE "9,999,999,999,999.99" RIGHT;
             VALID oBcoMov:MOBMONNAC();
             WHEN (AccessField("DPCTABANCOMOV","MOB_MONNAC",oBcoMov:nOption);
                   .AND. oBcoMov:nOption!=0 .AND. !EMPTY(oBcoMov:MOB_MONTO) .AND. oBcoMov:lMoneda);
             SIZE NIL,10 PIXEL

// Cuenta de Egreso
  @ 8,1 SAY GetFromvar("{oDp:xDPCTAEGRESO}") RIGHT 

  @ 9,06 BMPGET oBcoMov:oMOB_CTAEGR VAR oBcoMov:MOB_CTAEGR;
                 VALID oBcoMov:MOBCTAEGR();
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPCTAEGRESO",NIL,""),;
                         oDpLbx:GetValue("CEG_CODIGO",oBcoMov:oMOB_CTAEGR)); 
                 WHEN (AccessField("DPCTABANCOMOV","MOB_CTAEGR",oBcoMov:nOption) .AND. ;
                       oBcoMov:nOption!=0 .AND. !Empty(oBcoMov:MOB_DOCUME) .AND. oDp:P_LCtaEgrBco);
                 SIZE 100,NIL

  @10,10 SAY oBcoMov:oEgrNombre PROMPT;
             SQLGET("DPCTAEGRESO","CEG_DESCRI","CEG_CODIGO"+GetWhere("=",oBcoMov:MOB_CTAEGR))

//         oBcoMov:cEgrNombre UPDATE

// Código Contable
  @ 8,1 SAY "Cuenta Contable:" RIGHT 

  @ 9,06 BMPGET oBcoMov:oMOB_CTACON VAR oBcoMov:MOB_CTACON;
                 VALID oBcoMov:MOBCTACON(.T.);
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPCTAACT",NIL,""),;
                         oDpLbx:GetValue("CTA_CODIGO",oBcoMov:oMOB_CTACON)); 
                 WHEN (AccessField("DPCTABANCOMOV","MOB_CTACON",oBcoMov:nOption) .AND. ;
                       oBcoMov:nOption!=0 .AND. !Empty(oBcoMov:MOB_CUENTA) .AND. !oDp:P_LCtaEgrBco);
                 SIZE 100,NIL

  @10,10 SAY oBcoMov:oCtaNombre PROMPT;
             SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oBcoMov:MOB_CTACON))

  // Muestra de Datos
  @ 5,20 SAY "% I.T.F. :"       RIGHT
  @ 7,20 SAY "Monto I.T.F. :"   RIGHT
  @ 7,20 SAY "Moneda :"         RIGHT
  @ 7,20 SAY "Comprobante :"    RIGHT
  @ 8,20 SAY "Fecha Registro :" RIGHT

  @ 8,60 SAY oBcoMov:oMOB_NUMTRA PROMPT oBcoMov:MOB_NUMTRA
  @ 9,60 SAY oBcoMov:oMOB_IDB    PROMPT TRAN(oBcoMov:MOB_IDB,"999.99") RIGHT
  @ 9,60 SAY oBcoMov:oMOBMTOIDB  PROMPT TRAN(oBcoMov:MOB_MTOIDB,"999,999,999,999.99");
             RIGHT

  @10,60 SAY oBcoMov:oMoneda PROMPT SQLGET("DPTABMON","MON_DESCRI","MON_CODIGO"+GetWhere("=",oBcoMov:cMoneda))
  @11,60 SAY oBcoMov:MOB_COMPRO
  @12,50 SAY oBcoMov:MOB_FCHREG


  @ 9,06 BMPGET oBcoMov:oMOB_CENCOS VAR oBcoMov:MOB_CENCOS;
              VALID oBcoMov:MOBCENCOS();
              NAME "BITMAPS\FIND.BMP"; 
              ACTION (oDpLbx:=DpLbx("DPCENCOSACT.LBX",NIL,""),;
                      oDpLbx:GetValue("CEN_CODIGO",oBcoMov:oMOB_CENCOS)); 
               WHEN (AccessField("DPCTABANCOMOV","MOB_CENCOS",oBcoMov:nOption) .AND. ;
                     oBcoMov:nOption!=0 );
               SIZE 045,NIL

  @10,10 SAY oBcoMov:oCenNombre PROMPT;
             oBcoMov:cCenNombre UPDATE

  @ 8,20 SAY GetFromVar("{oDp:xDPCENCOS}")+":" RIGHT

  @ 08,40 SAY "Estado:" RIGHT

  @ 08,50 SAY oBcoMov:oEstado PROMPT SayOptions("DPCTABANCOMOV","MOB_ESTADO",oBcoMov:MOB_ESTADO,.T.);
                             UPDATE


  @ 9, 35 CHECKBOX oBcoMov:oChk VAR oBcoMov:cChk PROMPT ANSITOOEM("NO Aplica ITF");
          WHEN (oBcoMov:nOption!=0);
		ON CHANGE oBcoMov:NOITF()

  oBcoMov:Activate({||oBcoMov:BCOMOVINI()})

RETURN oBcoMov

FUNCTION BCOMOVINI()

   SayLine(oBcoMov:oMOB_NUMTRA)
   oBcoMov:oFocus:=oBcoMov:oMOB_CODBCO

RETURN .T.

/*
// Carga los Datos
*/
FUNCTION LOAD()
  LOCAL aDataO:={},aDataP:={},cSql,aQuery,I,aCuentas:={oBcoMov:MOB_CUENTA},nAt
  LOCAL nAt

  IF oBcoMov:nOption=2
     oBcoMov:VERASIENTOS()
     RETURN .F.
  ENDIF

  IF oBcoMov:nOption=3

    nAt:=ASCAN(oBcoMov:aBcoTipo,{|a,n|a[1]=oBcoMov:MOB_TIPO })
    oBcoMov:oMOB_TIPO:Select(nAt)

    IF oBcoMov:MOB_ACT=0
       oBcoMov:oMOB_DOCUME:MsgErr("Transaccióbn Nula")
       RETURN .F.
    ENDIF

    IF EJECUTAR("ISCONTAB_ACT",oBcoMov:MOB_COMPRO,oBcoMov:MOB_FECHA,oBcoMov:MOB_TIPO,oBcoMov:MOB_DOCUME,oBcoMov:MOB_CUENTA,"B",oBcoMov:MOB_CODBCO,"BCO",NIL,oBcoMov:oMOB_DOCUME)
       RETURN .F.
    ENDIF

    RETURN .T.

  ENDIF

  IF !Empty(oBcoMov:cCuenta) .AND. oBcoMov:nOption=1 
     aCuentas:={oBcoMov:cCuenta}
  ENDIF

  IF oBcoMov:nOption=1

    oBcoMov:MOB_CODSUC:=oDp:cSucursal
    oBcoMov:MOB_FCHREG:=oDp:dFecha
    oBcoMov:MOB_CUENTA:=oBcoMov:cCuenta  
    oBcoMov:oMOB_FECHA:VarPut(oDp:dFecha,.T.)
    oBcoMov:oMOB_CENCOS:VarPut(oDp:cCenCos,.T.)
    oBcoMov:MOB_TIPO  :=oBcoMov:aBcoTipo[oBcoMov:oMOB_TIPO:nAt,1]
    oBcoMov:MOB_HORA  :=TIME()
    oBcoMov:MOB_MTOIDB:=0.00
    oBcoMov:MOB_ESTADO:="A"

    oBcoMov:oEstado:Refresh(.T.)
 
    oBcoMov:BuildNumTra()

  ELSE

     oBcoMov:cCuenta:=oBcoMov:MOB_CUENTA

  ENDIF

  SQLGET("DPBANCOS","BAN_CODIGO,BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oBcoMov:MOB_CODBCO))

  IF !Empty(oDp:aRow)
    oBcoMov:cBcoNombre:=oDp:aRow[2]
    oBcoMov:oBcoNombre:Refresh(.T.)
  ENDIF

  IF !Empty(aCuentas)
     oBcoMov:oMOB_CUENTA:SetItems(aCuentas)
//   oBcoMov:oMOB_CUENTA:Set(aCuentas[1])
     oBcoMov:oMOB_CUENTA:Select(1)
     oBcoMov:MOB_CUENTA:=aCuentas[1]
     oBcoMov:oMOB_CUENTA:Refresh(.T.)
  ENDIF

  nAt:=ASCAN(oBcoMov:aBcoTipo,{|a,n|a[1]=oBcoMov:MOB_TIPO})

  IF nAt>0
     oBcoMov:oMOB_TIPO:Select(nAt)
  ENDIF

  oBcoMov:oCtaNombre:Refresh(.T.)
  oBcoMov:oEgrNombre:Refresh(.T.)

// oBcoMov:MOBCUENTA()
// oBcoMov:CALTOTAL()

  IF oBcoMov:nOption=1 .OR. oBcoMov:nOption=3
     DPFOCUS(oBcoMov:oMOB_CODBCO)
  ENDIF



RETURN .T.

FUNCTION PRESAVE()
  LOCAL cErr:=""

  IF oBcoMov:nOption=1
     oBcoMov:BUILDNUMTRA()
  ENDIF

  IF oBcoMov:MOB_MONTO=0
     oBcoMov:oMOB_MONTO:MsgErr("Monto debe ser mayor que Cero")
     RETURN .F.
  ENDIF

  IF Empty(oBcoMov:MOB_CODBCO)
     oBcoMov:oMOB_CODBCO:MsgErr("Introduzca el Código del Banco")
     RETURN .F.
  ENDIF

  IF Empty(oBcoMov:MOB_DOCUME)
     oBcoMov:oMOB_DOCUME:MsgErr("Introduzca el Número del Documento")
     RETURN .F.
  ENDIF

  IF !oDp:P_LCtaEgrBco 
    oBcoMov:AUTOCTAEGR(.T.)
  ENDIF

  IF Empty(oBcoMov:MOB_CTAEGR)
     oBcoMov:oMOB_CTAEGR:MsgErr("Introduzca el Código: Cuenta Egreso")
     RETURN .F.
  ENDIF

  IF Empty(oBcoMov:MOB_DOCUME)
     oBcoMov:oMOB_DOCUME:MsgErr("Introduzca el Número del Documento")
     RETURN .F.
  ENDIF

  IF Empty(oBcoMov:MOB_CTACON)
     oBcoMov:oMOB_CTACON:MsgErr("Introduzca la Cuenta Bancaria")
     RETURN .F.
  ENDIF

  IF Empty(oBcoMov:MOB_DESCRI)
     oBcoMov:oMOB_DESCRI:MsgErr("Introduzca Descripción del Registro")
     RETURN .F.
  ENDIF


  oBcoMov:CALIDB()

  oBcoMov:MOB_CUENTA:=oBcoMov:oMOB_CUENTA:aItems[oBcoMov:oMOB_CUENTA:nAt]
  oBcoMov:MOB_CODBCO:=SQLGET("DPCTABANCO","BCO_CODIGO","BCO_CTABAN"+GetWhere("=",oBcoMov:MOB_CUENTA))

  IF oBcoMov:nOption=1
     oBcoMov:MOB_HORA  :=TIME()
     oBcoMov:MOB_FCHREG:=oDp:dFecha
  ENDIF

//oBcoMov:MOB_TIPO  :="BCO"
  oBcoMov:MOB_TIPCTA:=IIF(oDp:P_LCtaEgrBco,"E","C")
  oBcoMov:MOB_CODSUC:=oDp:cSucursal
  oBcoMov:MOB_FCHCOM:=oBcoMov:MOB_FECHA
  oBcoMov:MOB_ESTADO:="A" // Activo

  oBcoMov:MOB_ACT   :=1
//oBcoMov:MOB_DESCRI:=IIF(EMPTY(oBcoMov:MOB_DESCRI),"Depósito",oBcoMov:MOB_DESCRI)
  oBcoMov:MOB_ASODOC:=oBcoMov:MOB_NUMTRA
//oBcoMov:MOB_DEBCRE:=1 // Debe ser Positivo
  oBcoMov:MOB_FCHCON:=CTOD("")
  oBcoMov:MOB_ORIGEN:="BCO" // Debe ser Positivo
// ? oBcoMov:MOB_CUENTA,"MOB_CUENTA"

  oBcoMov:MOB_CODMOD:=oDp:cCtaMod

  // Remueve Asiento Contable (NO ACTUALIZADO)
  IF oBcoMov:nOption=3 .AND. EJECUTAR("ISCONTAB_ACT",oBcoMov:MOB_COMPRO_,oBcoMov:MOB_FECHA_,oBcoMov:MOB_TIPO_,oBcoMov:MOB_DOCUME_,oBcoMov:MOB_CUENTA_,"B",oBcoMov:MOB_CODBCO_,"BCO",.T.,oBcoMov:oMOB_DOCUME)
     RETURN .F.
  ENDIF

RETURN .T.

// Graba los Registros de Caja
FUNCTION POSTGRABAR()

   LOCAL aCaja:={},I,oData,cSql,oTable,oCaja,aData,aUpdate:={},aDelete:={}


   // Si la Transaccion estaba Contabilizada Debera rehacer el Asiento Contable
   IF oBcoMov:nOption=3 .AND. !Empty(oBcoMov:MOB_COMPRO)

     MsgRun("Contabilizando Transacción Bancaria","Por favor espere..",{||  EJECUTAR("DPBCOCONTAB",;
                                   oBcoMov:MOB_COMPRO,;
                                   oBcoMov:MOB_CODSUC,;
                                   oBcoMov:MOB_CODBCO,;
                                   oBcoMov:MOB_CUENTA,;
                                   oBcoMov:MOB_TIPO  ,;
                                   oBcoMov:MOB_DOCUME,NIL,NIL,.F. ) })

   ENDIF

   oBcoMov:MenuOpc()

   IF ValType(oBcoMov:oConcil)="O"
      oBcoMov:oConcil:RefreshCon()
   ENDIF

  // NO APLICA ITF O IDB
  IF oBcoMov:cFlag = 1

    SQLUPDATE("DPCTABANCOMOV","MOB_IDB","0.00","MOB_CODBCO = '"+oBcoMov:MOB_CODBCO+"' AND MOB_CUENTA = '"+oBcoMov:MOB_CUENTA+"' AND MOB_TIPO = '"+oBcoMov:MOB_TIPO+"' AND MOB_DOCUME = '"+oBcoMov:MOB_DOCUME+"' AND MOB_CODSUC = '"+oBcoMov:MOB_CODSUC+"' ")
    SQLUPDATE("DPCTABANCOMOV","MOB_MTOIDB","0.00","MOB_CODBCO = '"+oBcoMov:MOB_CODBCO+"' AND MOB_CUENTA = '"+oBcoMov:MOB_CUENTA+"' AND MOB_TIPO = '"+oBcoMov:MOB_TIPO+"' AND MOB_DOCUME = '"+oBcoMov:MOB_DOCUME+"' AND MOB_CODSUC = '"+oBcoMov:MOB_CODSUC+"'")

    oBcoMov:MOB_IDB:=0.00
    oBcoMov:MOB_MTOIDB:=0.00

    oBcoMov:oMOB_IDB:Refresh(.T.)
    oBcoMov:oMOBMTOIDB:Refresh(.T.)

  ENDIF

RETURN .T.


/*
// Debe Generar el Número del Documento
*/
FUNCTION BUILDNUMDOC()
RETURN .T.

/*
// Valida Código del Banco
*/
FUNCTION VALCODBCO()
   LOCAL aCuentas,cCodBco:="",nAt

   cCodBco:=SQLGET("DPBANCOS","BAN_CODIGO,BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oBcoMov:MOB_CODBCO))

   IF !(cCodBco==oBcoMov:MOB_CODBCO) .OR. EMPTY(oBcoMov:MOB_CODBCO)
     oBcoMov:oMOB_CODBCO:KeyBoard(VK_F6)
     RETURN .F.
   ENDIF

   oBcoMov:cBcoNombre:=oDp:aRow[2]
   oBcoMov:oBcoNombre:Refresh(.T.)

   aCuentas:=ASQL("SELECT BCO_CTABAN FROM DPCTABANCO WHERE BCO_CODIGO"+GetWhere("=",oBcoMov:MOB_CODBCO))

   IF Empty(aCuentas)
      MensajeErr("Banco no Posee Cuentas Bancarias")
      RETURN .F.
   ENDIF

   AEVAL(aCuentas,{|a,n|aCuentas[n]:=a[1]})

   IF EMPTY(aCuentas)
     oBcoMov:aCuentas:={"Ninguna"}
   ENDIF

   nAt:=MAX(ASCAN(oBcoMov:oMOB_CUENTA:aItems,oBcoMov:MOB_CUENTA),1)

   oBcoMov:oMOB_CUENTA:SetItems(aCuentas)
   oBcoMov:oMOB_CUENTA:ForWhen(.T.)

   oBcoMov:oMOB_CUENTA:Set(aCuentas[nAt])
   oBcoMov:oMOB_CUENTA:Select(nAt)
   oBcoMov:oMOB_CUENTA:Refresh(.T.)
   oBcoMov:oMOB_CUENTA:ForWhen(.T.)
   oBcoMov:MOB_CUENTA:=aCuentas[nAt]

//   oBcoMov:oMOB_CUENTA:ForWhen(.T.)
   COMBOINI(oBcoMov:oMOB_CUENTA)

   oBcoMov:MOBCUENTA()
//   SysRefresh(.T.)

RETURN .T.

FUNCTION RUNCUENTA()

   LOCAL cCodBco:=oBcoMov:MOB_CODBCO
   LOCAL cCodCta:=oBcoMov:MOB_CUENTA

   IF Empty(cCodBco)
      MensajeErr("Es necesario el Código de Banco")
      RETURN .F.
   ENDIF

   IF !ISMYSQLGET("DPBANCOS","BAN_CODIGO",cCodBco)
      MensajeErr("Código de Banco: "+cCodBco+" no Existe")
      RETURN .F.
   ENDIF

   EJECUTAR("DPCTABANCOCON",cCodCta,MYSQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",cCodBco)),cCodBco)

RETURN .T.

FUNCTION RUNBANCO(cCodBco)

  DEFAULT cCodBco:=oBcoMov:MOB_CODBCO

  IF Empty(cCodBco)
     MensajeErr("Es necesario el Código de Banco")
     RETURN .F.
  ENDIF

  IF !ISMYSQLGET("DPBANCOS","BAN_CODIGO",cCodBco)
     MensajeErr("Código de Banco: "+cCodBco+" no Existe")
     RETURN .F.
  ENDIF

  EJECUTAR("DPBANCOS",2,oBcoMov:MOB_CODBCO)

RETURN .T.

FUNCTION RUNCAJA()
RETURN .T.

FUNCTION MOBDOCUME()

  IF Empty(oBcoMov:MOB_DOCUME)
     RETURN .F.
  ENDIF

  IF !oBcoMov:ValUnique(NIL,NIL,.F.)
     MensajeErr("Documento ya Existe ")
     RETURN .F.
  ENDIF

RETURN .T.

FUNCTION MOBCUENTA()

  oBcoMov:lMoneda:=!(SQLGET("DPCTABANCO","BCO_CODMON","BCO_CODIGO"+GetWhere("=",oBcoMov:MOB_CODBCO)+" AND "+;
                                                      "BCO_CTABAN"+GetWhere("=",oBcoMov:MOB_CUENTA))=oDp:cMoneda)

  oBcoMov:cMoneda:=oDp:aRow[1]
  oBcoMov:oMoneda:Refresh(.T.)

  IF oBcoMov:nOption=1 .OR. Empty(oBcoMov:MOB_VALCAM)
    oBcoMov:MOB_VALCAM:=EJECUTAR("DPGETVALCAM",oBcoMov:cMoneda,oBcoMov:MOB_FECHA,oBcoMov:MOB_HORA)
    oBcoMov:oMOB_VALCAM:VarPut(oBcoMov:MOB_VALCAM,.T.)
  ENDIF

  IF oBcoMov:nOption=0
     oBcoMov:SETDOCSCOPE(.T.)
  ENDIF

RETURN .T.

FUNCTION CALTOTAL()
RETURN  .T.

FUNCTION VALEFECTIVO()
RETURN .T.

FUNCTION PRINTER()
  LOCAL oRep

  oRep:=REPORTE("CTABANCOMO")
  oRep:SetRango(1,oBcoMov:MOB_CODBCO,oBcoMov:MOB_CODBCO)
  oRep:SetRango(2,oBcoMov:MOB_CUENTA,oBcoMov:MOB_CUENTA)
  oRep:SetRango(3,oBcoMov:MOB_DOCUME,oBcoMov:MOB_DOCUME)
  oRep:SetCriterio(1, oBcoMov:MOB_TIPO)
  //oRep:SetRango(4,oBcoMov:MOB_FCHREG,oBcoMov:MOB_FCHREG,.T.)
 

RETURN .T.

FUNCTION PREDELETE()  
  LOCAL lResp:=.F.,cWhere
  LOCAL cEstado:=IF(oBcoMov:MOB_ACT=0,"A","N")
  LOCAL nAct   :=IF(oBcoMov:MOB_ACT=0,1  ,0)
  LOCAL cText  :=IF(oBcoMov:MOB_ACT=0,"Reactivar","Anular")
  LOCAL aData  :={},lOk
  LOCAL aSize,nAlto,nDataLines,aCols

  // Valida sin Remover
  IF EJECUTAR("ISCONTAB_ACT",oBcoMov:MOB_COMPRO,oBcoMov:MOB_FECHA,oBcoMov:MOB_TIPO,oBcoMov:MOB_DOCUME,oBcoMov:MOB_CUENTA,"B",oBcoMov:MOB_CODBCO,"BCO",.F.,oBcoMov:oMOB_DOCUME)
     RETURN .F.
  ENDIF

  AADD(aData,{"Tipo"      ,oBcoMov:MOB_TIPO  })
  AADD(aData,{"Numero"    ,oBcoMov:MOB_DOCUME})
  AADD(aData,{"Trasacción",oBcoMov:MOB_NUMTRA})
  AADD(aData,{"Código"    ,oBcoMov:MOB_CODBCO})
  AADD(aData,{"Cuenta"    ,oBcoMov:MOB_CUENTA})
  AADD(aData,{"Banco"     ,oBcoMov:cBcoNombre})
  AADD(aData,{"Monto"     ,TRAN(oBcoMov:MOB_MONTO,"99,999,999,999,999.99")})

  lOk:=EJECUTAR("MSGBROWSE",aData,cText+" Registro Bancario",aSize,45,nDataLines,aCols,.F.,oBcoMov:oMOB_DOCUME)

  IF !lOk
    RETURN .F.
  ENDIF

  // Remueve Asientos Contables
  IF EJECUTAR("ISCONTAB_ACT",oBcoMov:MOB_COMPRO,oBcoMov:MOB_FECHA,oBcoMov:MOB_TIPO,oBcoMov:MOB_DOCUME,oBcoMov:MOB_CUENTA,"B",oBcoMov:MOB_CODBCO,"BCO",.T.)
     RETURN .F.
  ENDIF

  cWhere:="MOB_CODSUC"+GetWhere("=",oBcoMov:MOB_CODSUC)+" AND "+;
          "MOB_CODBCO"+GetWhere("=",oBcoMov:MOB_CODBCO)+" AND "+;
          "MOB_CUENTA"+GetWhere("=",oBcoMov:MOB_CUENTA)+" AND "+;
          "MOB_TIPO"  +GetWhere("=",oBcoMov:MOB_TIPO  )+" AND "+;
          "MOB_DOCUME"+GetWhere("=",oBcoMov:MOB_DOCUME)+" AND "+;
          "MOB_NUMTRA"+GetWhere("=",oBcoMov:MOB_NUMTRA)

  SQLUPDATE("DPCTABANCOMOV",{"MOB_ACT","MOB_ESTADO"},{nAct,cEstado},cWhere+" LIMIT 1" )

  oBcoMov:MOB_ESTADO:=cEstado
  oBcoMov:MOB_ACT   :=nAct

  oBcoMov:OEstado:Refresh(.T.)

RETURN .F.

FUNCTION POSTDELETE()
RETURN NIL

FUNCTION PUTCHQCTA(uValue,oBrw)
RETURN .T.

FUNCTION MOBTIPO()

   oBcoMov:MOB_TIPO:=oBcoMov:aBcoTipo[oBcoMov:oMOB_TIPO:nAt,1]
   oBcoMov:BUILDNUMTRA()

   IF oBcoMov:nOption=1 .AND.  oBcoMov:MOB_TIPO="CHQ"
     oBcoMov:MOB_DOCUME:=EJECUTAR("DPGETCHQMAX", oBcoMov:MOB_CODSUC, oBcoMov:MOB_CODBCO, oBcoMov:MOB_CUENTA)
     oBcoMov:oMOB_DOCUME:Refresh(.T.)
   ENDIF

   oBcoMov:GETCTAEGRESO()

RETURN .T.

FUNCTION MOVDESCRI()
RETURN .T.

FUNCTION  MenuOpc()

   EJECUTAR("DPCTABANCOMOVMN",oBcoMov:MOB_CODSUC,oBcoMov:MOB_CODBCO,oBcoMov:MOB_DOCUME,oBcoMov:MOB_CUENTA,oBcoMov:MOB_FCHREG,oBcoMov)

RETURN .T.

FUNCTION MOBDESCRI()

   IF EMPTY(oBcoMov:MOB_DESCRI)
      MensajeErr("Es necesario Indicar Descripción")
   ENDIF

RETURN .T.

FUNCTION MOBMONTO()

   IF oBcoMov:MOB_MONTO<0
      MensajeErr("Monto debe ser Positivo")
   ENDIF

   oBcoMov:CALIDB()

RETURN .T.

FUNCTION MOBCTAEGR()

  SQLGET("DPCTAEGRESO","CEG_CODIGO,CEG_CUENTA,CEG_DESCRI","CEG_CODIGO"+GetWhere("=",oBcoMov:MOB_CTAEGR))

  IF !Empty(oDp:aRow) .AND. !Empty(oBcoMov:MOB_CTAEGR)

    oBcoMov:MOB_CTACON:=oDp:aRow[2]
    oBcoMov:cEgrNombre:=oDp:aRow[3]
    oBcoMov:oEgrNombre:Refresh(.T.)
    oBcoMov:oMOB_CTACON:Refresh(.T.)
    oBcoMov:MOBCTACON()

  ELSE

    oBcoMov:oMOB_CTAEGR:nLastKey=0

    EVAL(oBcoMov:oMOB_CTAEGR:bAction)

    RETURN .F.

  ENDIF

RETURN .T.

FUNCTION MOBCTACON(lGet)
  LOCAL lFound:=.F.

  DEFAULT lGet:=.F.

  SQLGET("DPCTA","CTA_CODIGO,CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oBcoMov:MOB_CTACON))

  IF !Empty(oDp:aRow)
    oBcoMov:MOB_CTACON:=oDp:aRow[1]
    oBcoMov:cCtaNombre:=oDp:aRow[2]
    oBcoMov:oCtaNombre:Refresh(.T.)
    lFound:=.T.
  ENDIF

  IF !Empty(oBcoMov:MOB_CTACON) .AND. !EJECUTAR("ISCTADET",oBcoMov:MOB_CTACON,.T.)
     RETURN .F.
  ENDIF

  oBcoMov:AUTOCTAEGR(.F.)

  IF !lFound .AND. lGet
    Eval(oBcoMov:oMOB_CTACON:bAction)
    RETURN .T.
  ENDIF

RETURN lFound
/*
// En Otra Moneda
*/
FUNCTION MOBMONNAC()

  oBcoMov:MOB_MONNAC:=(oBcoMov:MOB_MONTO*oBcoMov:MOB_VALCAM)
  oBcoMov:oMOB_MONNAC:VarPut(oBcoMov:MOB_MONNAC,.T.)

RETURN .T.

FUNCTION BUILDNUMTRA()

   IF oBcoMov:nOption=1
   

      oBcoMov:MOB_NUMTRA:=SQLINCREMENTAL("DPCTABANCOMOV","MOB_NUMTRA","MOB_CODSUC"+GetWhere("=",oDp:cSucursal     )+" AND "+;
                                                                      "MOB_TIPO"  +GetWhere("=",oBcoMov:MOB_TIPO  )+" AND "+;
                                                                      "MOB_CODBCO"+GetWhere("=",oBcoMov:MOB_CODBCO)+" AND "+;
                                                                      "MOB_CUENTA"+GetWhere("=",oBcoMov:MOB_CUENTA))

      oBcoMov:oMOB_NUMTRA:Refresh(.T.)

   ENDIF

RETURN .T.

FUNCTION CALIDB()

  oBcoMov:MOB_IDB   :=0
///////////
  IF SQLGET("DPCTABANCO","BCO_IDB","BCO_CODIGO"+GetWhere("=",oBcoMov:MOB_CODBCO)+" AND "+;
                                   "BCO_CTABAN"+GetWhere("=",oBcoMov:MOB_CUENTA))
     oBcoMov:MOB_IDB   :=EJECUTAR("IDBCAL",oBcoMov:MOB_TIPO,oBcoMov:MOB_MONTO,oBcoMov:MOB_FECHA)
  ENDIF

  IF oBcoMov:MOB_TIPO="DEP".OR.oBcoMov:MOB_ORIGEN="REC"
     oBcoMov:MOB_MTOIDB:=0
     oBcoMov:MOB_IDB:=0
  ENDIF

  oBcoMov:MOB_MTOIDB:=PORCEN(oBcoMov:MOB_MONTO,oBcoMov:MOB_IDB)
  oBcoMov:oMOB_IDB:Refresh(.T.)
  oBcoMov:oMOBMTOIDB:Refresh(.T.)
/////////////

////////// de orlando
/*
 IF SQLGET("DPCTABANCO","BCO_IDB","BCO_CODIGO"+GetWhere("=",oBcoMov:MOB_CODBCO)+" AND "+;
                                   "BCO_CTABAN"+GetWhere("=",oBcoMov:MOB_CUENTA))
////////////////////////   Se incluyo esto 
  IF oBcoMov:MOB_TIPO="CHQ".OR.oBcoMov:MOB_TIPO="CRED".OR.oBcoMov:MOB_TIPO="DCD"
     oBcoMov:MOB_IDB   :=EJECUTAR("IDBCAL",oBcoMov:MOB_TIPO,oBcoMov:MOB_MTOIDB,oBcoMov:MOB_FECHA)
  ENDIF
  IF oBcoMov:MOB_TIPO="GAS".OR.oBcoMov:MOB_TIPO="PTRA" .OR. SUBS(oBcoMov:MOB_TIPO,1,4)="DEB ".OR.!oBcoMov:MOB_TIPO="DEBT"
     oBcoMov:MOB_IDB   :=EJECUTAR("IDBCAL",oBcoMov:MOB_TIPO,oBcoMov:MOB_MTOIDB,oBcoMov:MOB_FECHA)
  ENDIF
/////////////////////////
 ENDIF
  oBcoMov:MOB_MTOIDB:=PORCEN(oBcoMov:MOB_MONTO,oBcoMov:MOB_IDB)
  oBcoMov:oMOB_IDB:Refresh(.T.)
  oBcoMov:oMOBMTOIDB:Refresh(.T.)
*/
//////////////////////////////
RETURN .T.

FUNCTION MOBFECHA()
 LOCAL lResp:=.T.

 lResp:=EJECUTAR("DPVALFECHA",oBcoMov:MOB_FECHA,.T.,.T.)

RETURN lResp

/*
// Buscar
*/
FUNCTION SETFIND()

  oBcoMov:oMOB_TIPO:bValid :={||oBcoMov:MOBTIPO()  }
  oBcoMov:oMOB_TIPO:bChange:={||oBcoMov:CHANGETIP()}

  oBcoMov:MOB_TIPO   :=""
  oBcoMov:MOB_NUMTRA :=SPACE(0)
  oBcoMov:oMOB_NUMTRA:Refresh(.T.)

RETURN .T.

/*
// 
*/
FUNCTION CHANGETIP()

  oBcoMov:MOB_TIPO:=oBcoMov:oMOB_TIPO:aItems[oBcoMov:oMOB_TIPO:nAt]

//IF oBcoMov:nOption=/
  oBcoMov:MOB_TIPO:=oBcoMov:aBcoTipo[oBcoMov:oMOB_TIPO:nAt,1]
//ENDIF
//  aBcoTipo:=ASQL("SELECT TDB_CODIGO,TDB_NOMBRE,TDB_SIGNO FROM DPBANCOTIP ORDER BY TDB_CODIGO")

RETURN .T.

FUNCTION PRELIST()

    oBcoMov:LoadData(0)

RETURN .T.

/*
// Centro de Costos
*/
FUNCTION MOBCENCOS(lSay)

  DEFAULT lSay:=.F.

  SQLGET("DPCENCOS","CEN_CODIGO,CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oBcoMov:MOB_CENCOS))

  IF !Empty(oDp:aRow) .AND. !Empty(oBcoMov:MOB_CENCOS)

    oBcoMov:cCenNombre:=oDp:aRow[2]
    oBcoMov:oCenNombre:Refresh(.T.)

  ELSE

    IF oBcoMov:nOption=0 .OR. lSay
       RETURN .T.
    ENDIF

    oBcoMov:oMOB_CENCOS:nLastKey=0

    EVAL(oBcoMov:oMOB_CENCOS:bAction)

    RETURN .F.

  ENDIF

RETURN .T.

/*
// Obtiene, Cuenta de Egreso
*/
FUNCTION GETCTAEGRESO()
   LOCAL cNumTra:="",cCtaEgreso:=""

   cNumTra:=SQLGET("DPCTABANCOMOV","MAX(MOB_NUMTRA)","MOB_CODSUC"+GetWhere("=",oBcoMov:MOB_CODSUC)+" AND "+;
                                                     "MOB_TIPO  "+GetWhere("=",oBcoMov:MOB_TIPO  )+" AND "+;
                                                     "MOB_ACT   =1 AND MOB_ORIGEN='BCO'")

   IF !Empty(cNumTra)

     cCtaEgreso:=SQLGET("DPCTABANCOMOV","MOB_CTAEGR","MOB_CODSUC"+GetWhere("=",oBcoMov:MOB_CODSUC)+" AND "+;
                                                     "MOB_TIPO  "+GetWhere("=",oBcoMov:MOB_TIPO  )+" AND "+;
                                                     "MOB_NUMTRA"+GetWhere("=",cNumTra           )+" AND "+;
                                                     "MOB_ACT   =1 AND MOB_ORIGEN='BCO'")
   ENDIF

   IF !Empty(cCtaEgreso) .AND. ISSQLGET("DPCTAEGRESO","CEG_CODIGO",cCtaEgreso)
     oBcoMov:oMOB_CTAEGR:VarPut(cCtaEgreso,.T.)
     oBcoMov:MOBCTAEGR()
   ENDIF

RETURN .T.
/*
// Cuenta de Egreso
*/
FUNCTION AUTOCTAEGR(lCrear)
  LOCAL oTable,cMemo:=""
  LOCAL cCodEgr:=SQLGET("DPCTAEGRESO","CEG_CODIGO","CEG_CUENTA"+GetWhere("=",oBcoMov:MOB_CTACON))

  DEFAULT lCrear:=.F

  IF !Empty(cCodEgr)
    oBcoMov:oMOB_CTAEGR:VarPut(cCodEgr,.T.)
    oBcoMov:MOB_CTAEGR:=cCodEgr
  ENDIF

  IF lCrear .AND. Empty(cCodEgr)

   cMemo:="Código:"+oBcoMov:MOB_CODBCO+CRLF+;
          "Cuenta:"+oBcoMov:MOB_CUENTA+CRLF+;
          "Numero:"+oBcoMov:MOB_DOCUME

    oTable:=OpenTable("SELECT * FROM DPCTAEGRESO",.T.)
    oTable:Append()
    oTable:Replace("CEG_CODIGO",STRTRAN(oBcoMov:MOB_CTACON,".",""))
    oTable:Replace("CEG_DESCRI",SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oBcoMov:MOB_CTACON)))
    oTable:Replace("CEG_CUENTA",oBcoMov:MOB_CTACON)
    oTable:Replace("CCE_MEMO"  ,"Codigo Creado en Movimiento Bancario"+CRLF+cMemo)

    oBcoMov:MOB_CTAEGR:=oTable:CEG_CODIGO
    oTable:Commit()
    oTable:End()

  ENDIF

RETURN .T.

FUNCTION VIEWMOVBCO()
   LOCAL oDlg,oDesde,oHasta,oFontB,lOk:=.F.,cList,cWhere
   LOCAL dDesde:=FCHINIMES(oDp:dFecha),dHasta:=FCHFINMES(oDp:dFecha)

   DEFINE FONT oFontB  NAME "Times New Roman"   SIZE 0, -14 BOLD

   DEFINE DIALOG oDlg TITLE "Visualizar Transacciones por Fecha"

   @ 1.7,1 BMPGET oDesde VAR dDesde;
           FONT oFontB;
           PICTURE "99/99/9999";
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oDesde,dDesde);
           VALID !Empty(dDesde);
           SIZE 46,12


   @ 2.7,1 BMPGET oDesde VAR dHasta;
           FONT oFontB;
           PICTURE "99/99/9999";
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oHasta,dHasta);
           VALID !Empty(dHasta);
           SIZE 46,12

   @ 3,10 BUTTON " Aceptar " ACTION (lOk:=.T.,oDlg:End());
          FONT oFontB SIZE 46,12


   @ 3,18 BUTTON " Salir   " ACTION (lOk:=.F.,oDlg:End());
          FONT oFontB SIZE 46,12


   ACTIVATE DIALOG oDlg CENTERED

   IF lOk
      cList:="DPCTABANCOFCH.BRW"
      cWhere:=GetWhereAnd("MOB_FECHA",dDesde,dHasta)
      oBcoMov:ListBrw(cWhere,cList," Movimientos Bancarios "+DTOC(dDesde)+" - "+DTOC(dHasta))
   ENDIF

RETURN .T.

FUNCTION NOITF()

  IF oBcoMov:cFlag = 0
   oBcoMov:cFlag := 1
  ELSE
   oBcoMov:cFlag := 0
  ENDIF
/*
////////////////////// orlando
IF oBcoMov:cFlag = 0
    oBcoMov:cFlag := 1
    oBcoMov:MOB_IDB:=0.00
    oBcoMov:MOB_MTOIDB:=0.00 
    oBcoMov:oMOB_IDB:Refresh(.T.)
    oBcoMov:oMOBMTOIDB:Refresh(.T.) 

  ELSE

    oBcoMov:cFlag := 0
    oBcoMov:MOB_IDB   :=EJECUTAR("IDBCAL",oBcoMov:MOB_TIPO,oBcoMov:MOB_MTOIDB,oBcoMov:MOB_FECHA)
    oBcoMov:MOB_MTOIDB:=PORCEN(oBcoMov:MOB_MONTO,oBcoMov:MOB_IDB)
    oBcoMov:oMOB_IDB:Refresh(.T.)
    oBcoMov:oMOBMTOIDB:Refresh(.T.) 

  ENDIF
/////////////////
*/
RETURN .T.

/*
// Listar Documentos por fechas
*/
FUNCTION LIST(cWhere,cTitle)
  LOCAL dDesde,dHasta
  LOCAL nAt:=ASCAN(oBcoMov:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oBcoMov:aBtn[nAt,1],NIL)
  LOCAL cScope

  DEFAULT cWhere:=""

  cWhere:=oBcoMov:cScope+IF(Empty(cWhere),""," AND "+cWhere)

  dHasta:=SQLGETMAX(oBcoMov:cTable,"MOB_FECHA",cWhere)
  dDesde:=FCHINIMES(dHasta)

  IF !EJECUTAR("CSRANGOFCH","DPCTABANCOMOV",cWhere,"MOB_FECHA",dDesde,dHasta,oBtnBrw,cTitle)
      RETURN .T.
  ENDIF

  IF !Empty(oDp:dFchIniDoc)
     cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+GetWhereAnd("MOB_FECHA",oDp:dFchIniDoc,oDp:dFchFinDoc)
  ENDIF

ErrorSys(.T.)

  oBcoMov:ListBrw(cWhere,"DPCTABANCOMOV.BRW",cTitle)

RETURN .T.

/*
// Ver Asientos
*/
FUNCTION VERASIENTOS()

//oBcoMov:MOB_COMPRO,oBcoMov:MOB_FECHA,oBcoMov:MOB_TIPO,oBcoMov:MOB_DOCUME,oBcoMov:MOB_CUENTA,"B",oBcoMov:MOB_CODBCO,"BCO",NIL,oBcoMov:oMOB_DOCUME)
// cNumCbt,cCodSuc,cTipDoc,cCodBco,cCtaBco,cNumero,cOrg,cTipTra,dFecha

   EJECUTAR("DPBCOVIEWCON",oBcoMov:MOB_COMPRO,;
                           oBcoMov:MOB_CODSUC,;
                           oBcoMov:MOB_TIPO  ,;
                           oBcoMov:MOB_CODBCO,;
                           oBcoMov:MOB_CUENTA,;
                           oBcoMov:MOB_DOCUME,;
                           "BCO"             ,;
                           "B"               , ;
                           oBcoMov:MOB_FECHA  )

RETURN NIL

// Asigna Scope
FUNCTION SETDOCSCOPE(lRefresh)
  LOCAL cWhere:=oBcoMov:cWhereRecord,nOption:=0,cScope

  DEFAULT lRefresh:=.T.

  cScope:="MOB_CODSUC"+GetWhere("=",oBcoMov:MOB_CODSUC)+" AND "+;
          "MOB_CODBCO"+GetWhere("=",oBcoMov:MOB_CODBCO)+" AND "+;
          "MOB_CUENTA"+GetWhere("=",oBcoMov:MOB_CUENTA)+" AND "+;
          "MOB_ORIGEN='BCO'"

  nOption:=IIF(MYCOUNT("DPCTABANCOMOV",cScope)=0,1,0)

  oBcoMov:SetScope(cScope)

  oBcoMov:cWhereRecord:=cWhere

  IF lRefresh .OR. nOption=1
    oBcoMov:nOption:=nOption

    IF oBcoMov:nOption=0
      oBcoMov:Primero(.T.," WHERE "+cScope)
    ENDIF

  ENDIF

  oBcoMov:LoadData(nOption,NIL,.T.,cWhere)
  oBcoMov:Skip(0)

RETURN .T.

/*
// ListBancos
*/
FUNCTION LISTBANCOS()
  LOCAL cTable:="DPCTABANCOMOV",cFields:="MOB_CODBCO,BAN_NOMBRE,MOB_CUENTA,MIN(MOB_FECHA),MAX(MOB_FECHA),COUNT(*)"
  LOCAL lGroup:=.T.,cWhere,cTitle
  LOCAL aTitle:={"Código","Nombre","Cuenta","Desde","Hasta","Reg."}
  LOCAL cOrderBy:="MOB_CODBCO",oControl:=oBcoMov:oMOB_CODBCO,oDb
  LOCAL cCodBco :=""

  cWhere :=" INNER JOIN DPBANCOS ON MOB_CODBCO=BAN_CODIGO WHERE MOB_ORIGEN='BCO' AND MOB_ACT=1 GROUP BY MOB_CODBCO,MOB_CUENTA "
  cCodBco:=EJECUTAR("REPBDLIST","DPCTABANCOMOV",cFields,.F.,cWhere,"Cuentas Bancarias con Movimientos",aTitle,NIL,NIL,NIL,cOrderBy,oControl,NIL)

  IF !Empty(oDp:aLine)
    oBcoMov:MOB_CUENTA:=oDp:aLine[3]
    oBcoMov:SETDOCSCOPE(.T.)
  ENDIF

RETURN NIL


FUNCTION BRWXNOA()
  LOCAL cWhere:="MOB_ACT"+GetWhere("=",1)

  oBcoMov:LIST(cWhere,"Sin Anular")

RETURN .T.

FUNCTION BRWANUL()
  oBcoMov:LIST("MOB_ACT"+GetWhere("=",0),"Anulados")
RETURN .T.

FUNCTION BRWXCTA()
  LOCAL cWhere:="",cCodigo,uValue
  LOCAL cTitle:=" Agrupados por Cuenta",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt:=ASCAN(oBcoMov:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oBcoMov:aBtn[nAt,1],NIL)

  cWhere       := " LEFT JOIN DPCTABANCO ON MOB_CODBCO=BCO_CODIGO AND MOB_CUENTA=BCO_CTABAN "+;
                  " LEFT JOIN DPBANCOS   ON MOB_CODBCO=BAN_CODIGO "+;
                  " LEFT JOIN DPBANCOTIP ON MOB_TIPO=TDB_CODIGO "+;
                  " WHERE "+oBcoMov:cScope

  cOrderBy  :=" GROUP BY MOB_CUENTA,MOB_CODBCO ORDER BY MOB_CUENTA,MOB_CODBCO "
  aTitle    :={"Cuenta","Código","Banco","Desde","Hasta","Debitos","Créditos","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,NIL,"999,999,999,999.99","999,999,999,999.99","9999"}
  oDp:aSize      :={120,120,300,60,60,120,120,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCTABANCOMOV","MOB_CUENTA,MOB_CODBCO,BAN_NOMBRE,MIN(MOB_FECHA) AS DESDE ,MAX(MOB_FECHA) AS HASTA,SUM(IF(TDB_SIGNO=1,MOB_MONTO,0)) AS DEBE,SUM(IF(TDB_SIGNO=-11,MOB_MONTO,0)) AS HABER,COUNT(*)",.F.,;
                    cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="MOB_CUENTA"+GetWhere("=",cCodigo)

     oBcoMov:cScope:=oBcoMov:cScope+ " AND "+cWhere
     oBcoMov:RECCOUNT(.T.)
     oBcoMov:RECCOUNT(.F.)

     // Todas las Facturas estan Filtradas por Cliente
     oDp:dFchIniDoc:=oDp:aLine[4]
     oDp:dFchFinDoc:=oDp:aLine[5] 

     cTitle:="Cuenta "+cCodigo+" Banco "+oDp:aLine[3]

// oDocCli:cTipDoc+" ["+cCodigo+" "+ALLTRIM(SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodigo)))+"]"
//  oBcoMov:ListBrw(cWhere,oBcoMov:cFileBrw,cTitle)

     oBcoMov:ListBrw(cWhere,"DPCTABANCOMOV.BRW",cTitle)

 

  ENDIF

RETURN .T.

/*
// Por tipo de Documento
*/

FUNCTION BRWXTIP()
  LOCAL cWhere:="",cCodigo,uValue
  LOCAL cTitle:=" Agrupados por Tipo de Transacción",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt:=ASCAN(oBcoMov:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oBcoMov:aBtn[nAt,1],NIL)

  cWhere       := " LEFT JOIN DPCTABANCO ON MOB_CODBCO=BCO_CODIGO AND MOB_CUENTA=BCO_CTABAN "+;
                  " LEFT JOIN DPBANCOTIP ON MOB_TIPO=TDB_CODIGO "+;
                  " WHERE "+oBcoMov:cScope

  cOrderBy  :=" GROUP BY MOB_TIPO ORDER BY  MOB_TIPO "
  aTitle    :={"Tipo","Nombre","Desde","Hasta","Debitos","Créditos","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"999,999,999,999.99","999,999,999,999.99","9999"}
  oDp:aSize      :={80 ,300,60 ,60 ,120                 ,120                 ,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCTABANCOMOV","MOB_TIPO,TDB_NOMBRE,MIN(MOB_FECHA) AS DESDE ,MAX(MOB_FECHA) AS HASTA,SUM(IF(TDB_SIGNO=1,MOB_MONTO,0)) AS DEBE,SUM(IF(TDB_SIGNO=-11,MOB_MONTO,0)) AS HABER,COUNT(*)",.F.,;
                    cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="MOB_TIPO"+GetWhere("=",cCodigo)

     oBcoMov:cScope:=oBcoMov:cScope+ " AND "+cWhere
     oBcoMov:RECCOUNT(.T.)
     oBcoMov:RECCOUNT(.F.)

     // Todas las Facturas estan Filtradas por Cliente
     oDp:dFchIniDoc:=oDp:aLine[3]
     oDp:dFchFinDoc:=oDp:aLine[4] 

     cTitle:="Tipo "+cCodigo+" Nombre "+oDp:aLine[2]

     oBcoMov:ListBrw(cWhere,"DPCTABANCOMOV.BRW",cTitle)

  ENDIF

RETURN .T.


/*
// Cuenta Contable
*/
FUNCTION BRWXCTA()
  LOCAL cWhere:="",cCodigo,uValue
  LOCAL cTitle:=" Agrupados por Cuenta Contable",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt:=ASCAN(oBcoMov:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oBcoMov:aBtn[nAt,1],NIL)

  cWhere       := " LEFT JOIN DPCTA      ON MOB_CODMOD=CTA_CODMOD AND MOB_CTACON=CTA_CODIGO "+;
                  " LEFT JOIN DPBANCOTIP ON MOB_TIPO=TDB_CODIGO "+;
                  " WHERE "+oBcoMov:cScope

  cOrderBy  :=" GROUP BY MOB_CTACON ORDER BY MOB_CTACON "
  aTitle    :={"Cuenta","Nombre","Desde","Hasta","Debitos","Créditos","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"999,999,999,999.99","999,999,999,999.99","9999"}
  oDp:aSize      :={120,300,60 ,60 ,120                 ,120                 ,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCTABANCOMOV","MOB_CTACON,CTA_DESCRI,MIN(MOB_FECHA) AS DESDE ,MAX(MOB_FECHA) AS HASTA,SUM(IF(TDB_SIGNO=1,MOB_MONTO,0)) AS DEBE,SUM(IF(TDB_SIGNO=-11,MOB_MONTO,0)) AS HABER,COUNT(*)",.F.,;
                    cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="MOB_CTACON"+GetWhere("=",cCodigo)

     oBcoMov:cScope:=oBcoMov:cScope+ " AND "+cWhere
     oBcoMov:RECCOUNT(.T.)
     oBcoMov:RECCOUNT(.F.)

     // Todas las Facturas estan Filtradas por Cliente
     oDp:dFchIniDoc:=oDp:aLine[3]
     oDp:dFchFinDoc:=oDp:aLine[4] 

     cTitle:="Cuenta "+cCodigo+" Nombre "+oDp:aLine[2]

     oBcoMov:ListBrw(cWhere,"DPCTABANCOMOV.BRW",cTitle)

  ENDIF

RETURN .T.


/*
// Cuenta Contable
*/
FUNCTION BRWXEGR()
  LOCAL cWhere:="",cCodigo,uValue
  LOCAL cTitle:=" Agrupados por Cuenta "+oDp:xDPCTAEGRESO,aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt:=ASCAN(oBcoMov:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oBcoMov:aBtn[nAt,1],NIL)

  cWhere       := " LEFT JOIN DPCTAEGRESO ON MOB_CTAEGR=CEG_CODIGO "+;
                  " LEFT JOIN DPBANCOTIP  ON MOB_TIPO  =TDB_CODIGO "+;
                  " WHERE "+oBcoMov:cScope

  cOrderBy  :=" GROUP BY MOB_CTAEGR ORDER BY MOB_CTAEGR "
  aTitle    :={"Código","Nombre","Desde","Hasta","Debitos","Créditos","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"999,999,999,999.99","999,999,999,999.99","9999"}
  oDp:aSize      :={120,300,60 ,60 ,120                 ,120                 ,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","DPCTABANCOMOV","MOB_CTAEGR,CEG_DESCRI,MIN(MOB_FECHA) AS DESDE ,MAX(MOB_FECHA) AS HASTA,SUM(IF(TDB_SIGNO=1,MOB_MONTO,0)) AS DEBE,SUM(IF(TDB_SIGNO=-11,MOB_MONTO,0)) AS HABER,COUNT(*)",.F.,;
                    cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="MOB_CTAEGR"+GetWhere("=",cCodigo)

     oBcoMov:cScope:=oBcoMov:cScope+ " AND "+cWhere
     oBcoMov:RECCOUNT(.T.)
     oBcoMov:RECCOUNT(.F.)

     // Todas las Facturas estan Filtradas por Cliente
     oDp:dFchIniDoc:=oDp:aLine[3]
     oDp:dFchFinDoc:=oDp:aLine[4] 

     cTitle:="Código "+cCodigo+" Nombre "+oDp:aLine[2]

     oBcoMov:ListBrw(cWhere,"DPCTABANCOMOV.BRW",cTitle)

  ENDIF

RETURN .T.






FUNCTION BRWXLIB()

     CursorWait()
     oBcoMov:cScope:=oBcoMov:cScopeOrg
     oBcoMov:RECCOUNT(.T.)
     oBcoMov:RECCOUNT(.F.)

RETURN .T.





// EOF
