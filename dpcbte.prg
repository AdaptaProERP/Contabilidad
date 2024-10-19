// Programa   : DPCBTE
// Fecha/Hora : 22/11/2004 23:10:42
// Propósito  : Editar Comprobante Contable
// Creado Por : Juan Navas
// Llamado por: Contabilidad
// Aplicación : Contabilidad
// Tabla      : DPCBTE

#INCLUDE "DPXBASE.CH"

                                               
PROCE MAIN(cActual,cNumero,dFecha,lView,cScope,cWhereG,cCodDep,cCenCos,cNumEje,cTipDoc,cCodSuc)
 LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,oFontB,cTitle:="Asientos Contables por Actualizar"
 LOCAL oFont,oData,oBtn
 LOCAL cOrderBy:="CBT_FECHA,CBT_NUMERO"
 LOCAL aCoors:=GetCoors( GetDesktopWindow() )
 LOCAL nWidth:=800+210,nHeight:=410+200
 LOCAL cFieldMto:=""
 LOCAL oDefCol
 LOCAL dDesde:=oDp:dFchInicio
 LOCAL dHasta:=oDp:dFchCierre
 LOCAL nSizeFont

 IF Type("oCbte")="O" .AND. oCbte:oWnd:hWnd>0
    EJECUTAR("BRRUNNEW",oCbte,GetScript())
    RETURN oCbte
 ENDIF

 DEFAULT cActual:="N",oDp:lCenCos:=.T.,oDp:lNumCom:=.F.

 DEFAULT cCodSuc:=oDp:cSucursal

 DEFAULT lView:=.F.,;
         cWhereG:=""

 DEFAULT oDp:lDebCre  :=.F.,;
         oDp:nClrDebe :=0  ,;
         oDp:nClrHaber:=0  ,;
         cTipDoc      :="STD"

// oDp:lDebCre:=.F.

 oDp:nClrDebe :=CLR_BLUE
 oDp:nClrHaber:=CLR_HRED

 IF !Empty(cNumEje)

    dDesde :=SQLGET("DPEJERCICIOS","EJE_DESDE,EJE_HASTA,EJE_CTAMOD","EJE_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                                    "EJE_NUMERO"+GetWhere("=",cNumEje))
    dHasta :=DPSQLROW(2,CTOD(""))


 ENDIF

// ? dDesde,dHasta,"dDesde,dHasta",cNumEje,"cNumEje"

 cTitle:=IIF(cActual="S","Asientos Contables Actualizados",cTitle)
 cTitle:=IIF(cActual="A","Asientos de Auditoría"  ,cTitle)

 DEFAULT  cScope:="CBT_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND CBT_ACTUAL"+GetWhere("=",cActual)

// +" AND "+;
//                  GetWhereAnd("CBT_FECHA",dDesde,dHasta)
//? cScope,"cScope"

 IF !Empty(cNumero)

    cScope:="CBT_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
            "CBT_ACTUAL"+GetWhere("=",cActual      )+" AND "+;
            "CBT_NUMERO"+GetWhere("=",cNumero      )+" AND "+;
            "CBT_FECHA "+GetWhere("=",dFecha )

    SETEXCLUYE("DPASIENTOS","")
    SETEXCLUYE("DPCBTE","")
   

 ENDIF

 nSizeFont:=SQLGET("DPASIENTOSTIPCOL","TDC_SIZEFN","TDC_TIPO"+GetWhere("=",cTipDoc)+" AND TDC_USUARI"+GetWhere("=",oDp:cUsuario))
 nSizeFont:=IF(Empty(nSizeFont),14,nSizeFont)

 // Font Para el Browse

 DEFINE FONT oFontB NAME "TAHOMA"   SIZE 0, nSizeFont BOLD
 DEFINE FONT oFont  NAME "TAHOMA"   SIZE 0, nSizeFont

 oDefCol:=EJECUTAR("DPASIENTOSCOLPAR",cTipDoc)

 oCbte:=DOCENC(cTitle,"oCbte","DPCBTE"+oDp:cModeVideo+".EDT")

 IF oDp:lBtnText 
    oCbte:nBtnWidth   :=oDp:nBtnWidth
    oCbte:nBtnHeight  :=oDp:nBarnHeight-2
    oCbte:lBtnText    :=oDp:lBtnText
 ENDIF 

 oCbte:cFileEdt:="FORMS\DPCBTE"+oDp:cModeVideo+".EDT"

 oData:=DATASET("PRIV_CONTAB","USER",,,oDp:cUsuario)

 oCbte:cNumero    :=oData:Get("Numero",STRZERO(1,8))
 oCbte:lActCbte   :=oData:Get("lActCbte"   ,.T.)
 oCbte:lRevCbte   :=oData:Get("lRevCbte"   ,.T.)
 oCbte:lIncCbteAct:=oData:Get("lIncCbteAct",.T.)
 oCbte:cTipDoc    :=cTipDoc

 oData:End()

 IF !Empty(cNumero) .AND. lView
   oCbte:lMod:=.F.
   oCbte:lInc:=.F.
   oCbte:lEli:=.F.
 ENDIF

 oCbte:lView:=.F. // no requiere Opcion Consulta

 oCbte:Prepare()
 oCbte:cPreSave :="PRESAVE"
 oCbte:cCancel  :="CANCEL"
 oCbte:lBar     :=.T.
 oCbte:nBtnStyle:=1
 oCbte:lCbteOk  :=.F.
 oCbte:dFecha   :=CTOD("")
 oCbte:cNumero  :=""
 oCbte:SetScope(cScope)
 oCbte:cPostSave:="POSTGRABAR"
 oCbte:lMsgBar  :=.F.

 oCbte:cCenCos  :=cCenCos
 oCbte:cCodDep  :=cCodDep

 oCbte:dDesde   :=dDesde
 oCbte:dHasta   :=dHasta

 oCbte:nBtnWidth:=42
 oCbte:cBtnList :="xbrowse2.bmp"

 oCbtE:BtnSetMnu("BROWSE","Buscar por Asientos","BRWASIENTOS")        // Agregar Menú en Barra de Botones
 oCbtE:BtnSetMnu("BROWSE","Asientos Resumidos por Cuenta","BRWXCTA")  // Agregar Menú en Barra de Botones
 oCbtE:BtnSetMnu("BROWSE","Asientos Resumidos por Origen","BRWXORG")  // Agregar Menú en Barra de Botones
 oCbtE:BtnSetMnu("BROWSE","Asientos Resumidos por Origen y Tipo"    ,"BRWXORGTIP")  // Agregar Menú en Barra de Botones

 oCbtE:AddBtn("form.bmp","Formularios de Origen","(oCbtE:nOption=0)",;
                          "EJECUTAR('DPCBTEFRMORG',oCbte:CBT_CODSUC,oCbte:CBT_NUMERO,oCbte:CBT_FECHA,oCbte:CBT_ACTUAL)","MNU")

 oCbtE:AddBtn("PASTE.BMP","Duplicar Comprobante Contable","(oCbtE:nOption=0)",;
                           "oCbte:DUPLICAR()","MNU")

 oCbtE:AddBtn("favoritos.bmp","Asignar generación Fija y Periódica","(oCbtE:nOption=0)",;
                              "oCbte:FIJOS()","MNU")

 oCbte:SetTable("DPCBTE","CBT_CODSUC,CBT_ACTUAL,CBT_FECHA,CBT_NUMERO",NIL, NIL, NIL,NIL,cOrderBy)

 nHeight:=410+200
 oDp:nDifW:=MAX((aCoors[4]-150)-nWidth,0)
 oDp:nDifH:=MAX((aCoors[3]-040)-nHeight,0)
 oCbte:lAutoSize  :=(aCoors[4]>1200)  // . AND. ISRELEASE("18.11")  // AutoAjuste 

 oCbte:lAutoSize:=.T.

//? aCoors[3]-100

 IF oCbte:lAutoSize 
    aCoors[4]:=MIN(aCoors[4],1920)
//  oCbte:Windows(0,0,aCoors[3]-300,aCoors[4]-10) 
    oCbte:Windows(0,0,aCoors[3]-140,aCoors[4]-30) 
 ELSE
    oCbte:Windows(0,0,625,1010) 
 ENDIF

 oCbte:Repeat("CBT_ACTUAL,CBT_FECHA")
 oCbte:nDebe   :=0
 oCbte:nHaber  :=0
 oCbte:nTotal  :=0
 oCbte:cActual :=cActual
 oCbte:cList   :=NIL //"DPCBTE_"+cActual+".BRW"
 oCbte:cListBrw:="DPCBTE_"+cActual+".BRW"
 oCbte:lActual  :=.F.
 oCbte:nColMonto:=0
 oCbte:nColHaber:=0
 oCbte:oDefCol  :=oDefCol
 oCbte:lAutorizaSalida:=.F.

 oCbte:lFind   :=.t.
 oCbte:SetMemo("CBT_NUMMEM","Descripción Amplia para el Comprobante Contable")

 IF DPVERSION()>4
   oCbte:SetAdjuntos("CBT_FILMAI") // Vinculo con DPFILEEMP
 ENDIF

 // ag TJ
 oCbte:lActual:=(cActual=="A" .OR. cActual="S")

//IF cActual="N" .AND. !lView .AND. oCbte:lActCbte
 IF cActual="N" .AND. oCbte:lActCbte

   oCbte:AddBtn("ACTUALIZARCBTE.bmp","Actualizar","(oCbte:nOption=0)",;
                "EJECUTAR('DPCBTEACT',oCbte:CBT_NUMERO,oCbte:CBT_FECHA,oCbte)","CLI")
 ENDIF

 // .AND. !lView // lograr reversarlo 04/03/2024
 IF cActual="S"  .AND. oCbte:lRevCbte
   oCbte:AddBtn("REVERSARCBTE.bmp","Reversar","(oCbte:nOption=0)",;
                "EJECUTAR('DPCBTEREV',oCbte:CBT_NUMERO,oCbte:CBT_FECHA,oCbte)","CLI")
 ENDIF

 @ 2,1 SAY "Número:" RIGHT

 @ 2,5 GET oCbte:oCBT_NUMERO VAR oCbte:CBT_NUMERO;
       WHEN oCbte:nOption<>0;
       VALID CERO(oCbte:CBT_NUMERO)

 @ 2,1 SAY "Fecha:" RIGHT
 @ 3,5 BMPGET oCbte:oCBT_FECHA VAR oCbte:CBT_FECHA;
       PICTURE oDp:cFormatoFecha;
       WHEN oCbte:nOption<>0;
       VALID oCbte:CBTFECHA();
       NAME "BITMAPS\CALENDAR.BMP"; 
       ACTION LbxDate(oCbte:oCBT_FECHA,oCbte:CBT_FECHA);
       SIZE 50,NIL

 @ 2,15 SAY "Comentarios:" RIGHT
 @ 2,20 GET oCbte:oCBT_COMEN1 VAR oCbte:CBT_COMEN1;
        WHEN oCbte:nOption<>0;

 @ 3,20 GET oCbte:oCBT_COMEN2 VAR oCbte:CBT_COMEN2;
        WHEN oCbte:nOption<>0;

 // Totales
 @ 2,44 SAY oCbte:oDebe  PROMPT TRAN(oCbte:nDebe ,"9,999,999,999,999,999.99") RIGHT
 @ 3,44 SAY oCbte:oHaber PROMPT TRAN(oCbte:nHaber,"9,999,999,999,999,999.99") RIGHT
 @ 3,44 SAY oCbte:oSaldo PROMPT TRAN(oCbte:nDebe-oCbte:nHaber,"9,999,999,999,999,999.99") RIGHT

 @ 1,10 SAY oCbte:oCta PROMPT GetFromVar("{oDp:xDPCTA}"   )+SPACE(40)+CHR(10)+;
                              GetFromVar("{oDp:xDPCENCOS}")+SPACE(40)

 @ 2,45 SAY "Debe"  RIGHT
 @ 2,45 SAY "Haber" RIGHT
 @ 3,45 SAY "Saldo" RIGHT


 @ 3.2,1 CHECKBOX oCbte:oCBT_CENGEN  VAR  oCbte:CBT_CENGEN;
        PROMPT "C.Costo Unico";
        WHEN (AccessField("DPCBTE","CBT_CENGEN",oCbte:nOption))  UPDATE

 oCbte:oCBT_CENGEN:cMsg    :="Centro de Costo Unico para todos los Asientos de Origen Contabilidad"
 oCbte:oCBT_CENGEN:cToolTip:=oCbte:oCBT_CENGEN:cMsg

 @ 3,15 SAY "Código" RIGHT

 //
 // Campo : CBT_CENCOS
 // Uso   : Centro de Costos
 //

  @ 3.4, 10 BMPGET oCbte:oCBT_CENCOS  VAR oCbte:CBT_CENCOS ;
            VALID oCbte:VALCENCOS();
            NAME "BITMAPS\find22.BMP"; 
            ACTION (oDpLbx:=DpLbx("DPCENCOS.LBX",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oCbte:oCBT_CENCOS), oDpLbx:GetValue("CEN_CODIGO",oCbte:oCBT_CENCOS));
            WHEN oCbte:CBT_CENGEN .AND. (AccessField("DPCBTE","CBT_CENCOS",oCbte:nOption).AND. oCbte:nOption!=0);
            SIZE 50,10

  oCbte:oCBT_CENCOS:cMsg    :="Centro de Costos"
  oCbte:oCBT_CENCOS:cToolTip:="Centos de Costos"

   @ 3,10  SAY oCbte:oCEN_DESCRI;
           PROMPT SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oCbte:CBT_CENCOS));
           SIZE NIL,12 FONT oFont COLOR 16777215,16711680 

 oDp:lDebCre:=.F.

 IF oDefCol:MOC_MTOCRE_ACTIVO

   oDp:lDebCre:=.T.

   cSql :=" SELECT "+SELECTFROM("DPASIENTOS",.F.)+;
          " ,DPCTA.CTA_CODIGO,DPCTA.CTA_DESCRI "+;
          " ,DPCENCOS.CEN_DESCRI "+;
          " ,DPDPTO.DEP_DESCRI "+;
          " ,DPPROYECTOS.PRY_DESCRI "+;
          " ,DPRIF.RIF_NOMBRE "+;
          " ,IF(MOC_MONTO<0,MOC_MONTO*-1,0) AS MOC_MTOCRE "+;
          " FROM DPASIENTOS "+;
          " INNER JOIN DPCTA       ON MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO "+;
          " LEFT  JOIN DPCENCOS    ON MOC_CENCOS=CEN_CODIGO "+;
          " LEFT  JOIN DPDPTO      ON MOC_CODDEP=DEP_CODIGO "+;
          " LEFT  JOIN DPPROYECTOS ON MOC_CODPRY=PRY_CODIGO "+;
          " LEFT  JOIN DPRIF       ON MOC_RIF   =RIF_ID      "


   cSql  :=STRTRAN(cSql,"DPASIENTOS.MOC_MONTO","IF(DPASIENTOS.MOC_MONTO>0,DPASIENTOS.MOC_MONTO,0)    AS MOC_MONTO")

 ELSE

    cSql :=" SELECT "+SELECTFROM("DPASIENTOS",.F.)+;
           " ,DPCTA.CTA_CODIGO,DPCTA.CTA_DESCRI "+;
           " ,DPCENCOS.CEN_DESCRI "+;
           " ,DPDPTO.DEP_DESCRI"+;
           " ,DPPROYECTOS.PRY_DESCRI "+;
           " ,DPRIF.RIF_NOMBRE "+;
           " ,MOC_MONTO "+;
           " FROM DPASIENTOS "+;
           " INNER JOIN DPCTA       ON MOC_CTAMOD=CTA_CODMOD AND MOC_CUENTA=CTA_CODIGO "+;
           " LEFT  JOIN DPCENCOS    ON MOC_CENCOS=CEN_CODIGO "+;
           " LEFT  JOIN DPDPTO      ON MOC_CODDEP=DEP_CODIGO "+;
           " LEFT  JOIN DPPROYECTOS ON MOC_CODPRY=PRY_CODIGO "+;
           " LEFT  JOIN DPRIF       ON MOC_RIF   =RIF_ID     "

  ENDIF

  cScope:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND MOC_ACTUAL"+GetWhere("=",cActual)+;
          IIF(Empty(cWhereG),""," AND ")+cWhereG

  oGrid :=oCbte:GridEdit( "DPASIENTOS" , "CBT_CODSUC,CBT_FECHA,CBT_NUMERO,CBT_ACTUAL", "MOC_CODSUC,MOC_FECHA,MOC_NUMCBT,MOC_ACTUAL" , cSql , cScope)

  oGrid:cScript  :="DPCBTE"
  oGrid:aSize    :={110+20+20,0,770+220-2+oDp:nDifW,200+30+170}

  IF oCbte:lAutoSize 
     // oGrid:aSize      := {100.9+20+20,0,aCoors[4]-30,200+30+170}
     oGrid:aSize      := {100.9+20+150,0+50,aCoors[4]-30,aCoors[3]-390-30} 
  ENDIF

  oGrid:oFontH   :=oFontB
  oGrid:oFont    :=oFont
  oGrid:bWhen    :="!EMPTY(oCbte:CBT_NUMERO)"
  oGrid:bValid   :="!EMPTY(oGrid:MOC_CUENTA)"
  oGrid:CTA_DESCRI:=""
  oGrid:CEN_DESCRI:=""
  oGrid:bChange  :='oCbte:GRIDCHANGE()'

/*
  IF !oDp:lDebCre
     oGrid:bClrText :={|a,n,o| IF(a[7]>0,oDp:nClrDebe,oDp:nClrHaber)}
  ELSE
     oGrid:bClrText :={|a,n,o,nClrText| nClrText:=IF(!Empty(a[7]),oDp:nClrDebe,oDp:nClrHaber),nClrText:=IF(a[7]+a[8]=0,0,nClrText),nClrText}
  ENDIF
*/
//   oGrid:bClrText :={|a,n,o,nClrText| nClrText:=IF(!Empty(a[7]),oDp:nClrDebe,oDp:nClrHaber),nClrText:=IF(a[7]+a[8]=0,0,nClrText),nClrText}
//  IF oDp:lCenCos
//     oGrid:bChange  :='oCbte:oCta:SetText(GetFromVar("{oDp:xDPCTA}")+": "+oGrid:CTA_DESCRI+CHR(10)+GetFromVar("{oDP:xDPCENCOS}")+": "+oGrid:CEN_DESCRI)'
//  ENDIF

  oGrid:oSayOpc  :=oCbte:oCta
  oGrid:cRegistro:="Asiento Contable"
  oGrid:cPostSave:="GRIDPOSTSAVE"
  oGrid:cLoad    :="GRIDLOAD"
  oGrid:cTotal   :="GRIDTOTAL" 
  oGrid:cPreSave :="GRIDPRESAVE"
  oGrid:cItem    :="MOC_ITEM"
  oGrid:oFontH   :=oFontB // Fuente para los Encabezados
  oGrid:lTotal   :=.T.
  oGrid:nHeaderLines:=2
  oGrid:lHScroll := .T.
  oGrid:cFieldAud:="MOC_REGAUD" // Genera Auditoria de Registros Anulados o Modificados
  // 27/04/2023
  oGrid:cPrimary    :=oGrid:cLinkGrid+",MOC_ITEM"
  // oGrid:cPrimaryItem:=oGrid:cPrimary // Genera incidencia ORDER BY 
  oGrid:cKeyAudita  :=oGrid:cPrimary



  oGrid:AddBtn("VIEW2.BMP","Visualizar Origen","oGrid:nOption=0",;
                [oCbte:VERORIGEN()],"VIEW",STR(DP_CTRL_C))

  oGrid:SetAdjuntos("MOC_FILMAI") // Vinculo con DPFILEEMP

  oGrid:AddBtn("MENU2.BMP","Acceder hacia el Formulario de Origen","oGrid:nOption=0",;
                [oCbte:MNUORIGEN()],"VIEW",STR(DP_CTRL_C))

  oGrid:SetMemo("MOC_NUMMEM","Descripción Amplia",1,1,100,200)

  oGrid:nClrPane1:=14087148
  oGrid:nClrPane2:=11790521
  oGrid:nClrPaneH:=14680021
  oGrid:nClrTextH:=CLR_GREEN

  IF cActual="N"
    oGrid:nClrPane1:=16774636 // 16770764
    oGrid:nClrPane2:=16771538 // 16566954
    oGrid:nClrPaneH:=13216655
    oGrid:nClrTextH:=CLR_YELLOW
  ENDIF

  IF cActual="A"
    oGrid:nClrPane1:=16773087 // 14811135
    oGrid:nClrPane2:=16775408 // 13367294
    oGrid:nClrPaneH   := 11856126
    oGrid:nClrTextH   := CLR_BLACK
  ENDIF

  oGrid:nClrPaneF:=oGrid:nClrPaneH
  oGrid:nClrTextF:=oGrid:nClrTextH
  oGrid:nRecSelColor:=oGrid:nClrPaneH
  oGrid:nClrText :=0

  oGrid:nClrTextH   :=oDp:nGrid_ClrTextH
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
  oGrid:nRecSelColor:=oDp:nLbxClrHeaderPane // 12578047 // 16763283

  oGrid:cPreDelete   :="GRID_BEFORDEL"
  oGrid:cPostDelete  :="GRID_AFTERDEL"

  IF oDefCol:MOC_ITEM_ACTIVO
    oCol:=oGrid:AddCol("MOC_ITEM")
    oCol:cTitle   :=oDefCol:MOC_ITEM_TITLE
    oCol:cTitle   :=IF(Empty(oCol:cTitle),"#"+CRLF+"Item",oCol:cTitle)
    oCol:bWhen    :=".F."
    oCol:nWidth   :=42
  ENDIF

  // Cuenta Contable
  IF oDefCol:MOC_CUENTA_ACTIVO
    oCol:=oGrid:AddCol("MOC_CUENTA")
    // oCol:cTitle   :="Código"
    oCol:cTitle   :=oDefCol:MOC_CUENTA_TITLE
    oCol:bValid   :={||oGrid:VMOC_CUENTA(oGrid:MOC_CUENTA)}
    oCol:cMsgValid:="Cuenta no Existe"
    oCol:nWidth   :=130+IIF(Empty(oDp:cModeVideo),0,40)
    // oCol:cListBox :="DPCTA.BRW"
    oCol:cListBox :="DPCTAACT.LBX"
    oCol:bPostEdit:='oGrid:ColCalc("MOC_MONTO")'    // Obtiene el Nombre del Producto
    oCol:lItems   :=.T.
    oCol:cItems   :="Asientos : "
    oCol:nEditType:=EDIT_GET_BUTTON
    oCol:bRunOff  :={||EJECUTAR("DPCTACON",NIL,oGrid:MOC_CUENTA)}
    oCol:cWhereListBox:="CTA_ACTIVO=1"

    oCol:lRepeat  :=oDefCol:MOC_CUENTA_REPITE

  ENDIF

  // Agregamos Nombre de la Cuenta

  oCbte:oCol_CTA_DESCRI:=NIL

  IF oDefCol:CTA_DESCRI_ACTIVO

    oCol          :=oGrid:AddCol("CTA_DESCRI")
    oCol:cTitle   :=oDefCol:CTA_DESCRI_TITLE
    oCol:nWidth   :=140 
    oCol:bWhen    :=".F."
    oCol:bCalc    :={||SQLGET("DPCTA","CTA_DESCRI","CTA_CODMOD"+GetWhere("=",oGrid:MOC_CTAMOD)+" AND CTA_CODIGO"+GetWhere("=",oGrid:MOC_CUENTA))}

    oCbte:oCol_CTA_DESCRI:=oCol
    oCol:bRunOff  :={||EJECUTAR("DPCTACON",NIL,oGrid:MOC_CUENTA)}

  ENDIF

  oDp:lCenCos:=.T.

  IF oDefCol:MOC_CENCOS_ACTIVO

     // oGrid:nId:=2
     oCol:=oGrid:AddCol("MOC_CENCOS")
     // oCol:cTitle   :=FIELDLABEL("DPASIENTOS","MOC_CENCOS")
     oCol:cTitle   :=oDefCol:MOC_CENCOS_TITLE
     oCol:bValid   :={||oGrid:VMOC_CENCOS(oGrid:MOC_CENCOS)}
     oCol:cMsgValid:=GetFromVar("{oDp:xDPCENCOS}")+" no Existe"
     oCol:nWidth   :=90
     oCol:cListBox :="DPCENCOSACT.LBX"
     oCol:nEditType:=EDIT_GET_BUTTON
     oCol:bRunOff  :={||EJECUTAR("DPCENCOSCON",NIL,oGrid:MOC_CENCOS)}
     oCol:bWhen    :=[!oCbte:CBT_CENGEN .AND. COUNT("DPCENCOS","CEN_ACTIVO=1")>0]
     oCol:lRepeat  :=oDefCol:MOC_CENCOS_REPITE

  ENDIF

  oCbte:oCol_CEN_DESCRI:=NIL

  IF oDefCol:CEN_DESCRI_ACTIVO

     oCol:=oGrid:AddCol("CEN_DESCRI")
     // oCol:cTitle   :=FIELDLABEL("DPCENCOS","CEN_DESCRI")+CRLF+oDp:DPCENCOS
     oCol:cTitle   :=oDefCol:CEN_DESCRI_TITLE
     oCol:nWidth   :=90
     oCol:nEditType:=0
     oCol:bCalc    :={||SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oGrid:MOC_CENCOS))}
     oCol:bRunOff  :={||EJECUTAR("DPCENCOSCON",NIL,oGrid:MOC_CENCOS)}
     oCol:bWhen    :=[.F.]
     oCbte:oCol_CEN_DESCRI:=oCol

  ENDIF

  IF oDefCol:MOC_CODDEP_ACTIVO

     oCol:=oGrid:AddCol("MOC_CODDEP")
     oCol:cTitle   :=oDefCol:MOC_CODDEP_TITLE
     oCol:bValid   :={||oGrid:VMOC_CODDEP(oGrid:MOC_CODDEP)}
     oCol:cMsgValid:=GetFromVar("{oDp:xDPDPTO}")+" no Existe"
     oCol:nWidth   :=90
     oCol:cListBox :="DPDPTO.LBX"
     oCol:nEditType:=EDIT_GET_BUTTON

     oCol:bRunOff  :={||EJECUTAR("DPDPTOCON",NIL,oGrid:MOC_CODDEP)}

     oCol:lRepeat  :=oDefCol:MOC_CODDEP_REPITE

  ENDIF

  oCbte:oCol_DEP_DESCRI:=NIL

  IF oDefCol:DEP_DESCRI_ACTIVO

     oCol:=oGrid:AddCol("DEP_DESCRI")
     oCol:cTitle   :=oDefCol:DEP_DESCRI_TITLE
     oCol:nWidth   :=90
     oCol:nEditType:=0
     oCol:bWhen    :=".F."
     oCol:bCalc    :={||SQLGET("DPDPTO","DEP_DESCRI","DEP_CODIGO"+GetWhere("=",oGrid:MOC_CODDEP))}

     oCbte:oCol_DEP_DESCRI:=oCol
     oCol:bRunOff  :={||EJECUTAR("DPDPTOCON",NIL,oGrid:MOC_CODDEP)}

  ENDIF

  IF oDefCol:MOC_RIF_ACTIVO

     oCol:=oGrid:AddCol("MOC_RIF")
     oCol:cTitle   :=oDefCol:MOC_RIF_TITLE
     oCol:bValid   :={||oGrid:VMOC_RIF(oGrid:MOC_RIF)}
     oCol:cMsgValid:=GetFromVar("{oDp:xDPRIF}")+" no Existe"
     oCol:nWidth   :=90
     oCol:cListBox :="DPRIF.LBX"
     oCol:nEditType:=EDIT_GET_BUTTON
     oCol:lRepeat  :=oDefCol:MOC_RIF_REPITE


  ENDIF

  oCbte:oCol_RIF_NOMBRE:=NIL

  IF oDefCol:RIF_NOMBRE_ACTIVO .AND. oDefCol:MOC_RIF_ACTIVO

     oCol:=oGrid:AddCol("RIF_NOMBRE")
     oCol:cTitle   :=oDefCol:RIF_NOMBRE_TITLE
     oCol:nWidth   :=90
     oCol:nEditType:=0
     oCol:bWhen    :=".F."
     oCol:bCalc    :={||SQLGET("DPRIF","RIF_NOMBRE","RIF_ID"+GetWhere("=",oGrid:MOC_RIF))}

     oCbte:oCol_RIF_NOMBRE:=oCol

  ENDIF

  IF oDefCol:MOC_CODPRY_ACTIVO
      oCol:=oGrid:AddCol("MOC_CODPRY")
      oCol:cTitle   :=oDefCol:MOC_CODPRY_TITLE
      //oCol:bWhen :="!Empty(oGrid:MOC_CENCOS)"
      oCol:bValid   :={||oGrid:VMOC_CODPRY(oGrid:MOC_CODPRY)}
      oCol:cMsgValid:=GetFromVar("{oDp:xDPPROYECTOS}")+" no Existe"
      oCol:nWidth   :=MOC_CODPRY_SIZE
      oCol:cListBox :="DPPROYECTOS.LBX"
      oCol:nEditType:=EDIT_GET_BUTTON
  ENDIF

 IF oDefCol:PRY_DESCRI_ACTIVO

     oCol:=oGrid:AddCol("PRY_DESCRI")
     oCol:cTitle   :=oDefCol:PRY_DESCRI_TITLE
     oCol:nWidth   :=90
     oCol:nEditType:=0
     oCol:bWhen    :=".F."
     oCol:bCalc    :={||SQLGET("DPPROYECTOS","PRY_DESCRI","PRY_CODIGO"+GetWhere("=",oGrid:MOC_CODPRY))}

     oCbte:oCol_PRY_DESCRI:=oCol
     oCol:bRunOff  :={||EJECUTAR("DPPROYECTOSCON",NIL,oGrid:MOC_CODPRY)}

  ENDIF



  // Documento Asociado
  IF oDefCol:MOC_DOCUME_ACTIVO
    oCol:=oGrid:AddCol("MOC_DOCUME")
    oCol:cTitle:=oDefCol:MOC_DOCUME_TITLE // "Documento"+CRLF+"Asociado"
    oCol:bWhen :="!Empty(oGrid:MOC_CUENTA)"
    oCol:nWidth:=150+30
//  oCol:lRepeat:=.T.
    oCol:lRepeat  :=oDefCol:MOC_DOCUME_REPITE

  ENDIF

  // Tipo
  IF oDefCol:MOC_TIPO_ACTIVO
    oCol:=oGrid:AddCol("MOC_TIPO")
    oCol:cTitle:=oDefCol:MOC_TIPO_TITLE
    oCol:bWhen  :="!Empty(oGrid:MOC_CUENTA)"
    oCol:nWidth :=15+IIF(Empty(oDp:cModeVideo),0,30)
    oCol:lRepeat:=oDefCol:MOC_TIPO_REPITE
  ENDIF

  IF oDefCol:MOC_MTOCRE_ACTIVO

    // Descripción
    oCol:=oGrid:AddCol("MOC_DESCRI")
    oCol:cTitle:=oDefCol:MOC_DESCRI_TITLE // "Descripción"  
    oCol:bWhen :="!Empty(oGrid:MOC_CUENTA)"
    oCol:nWidth:=80+iif(oDp:lCenCos,-80,0)+IIF(Empty(oDp:cModeVideo),0,90)

    oCol:nWidth :=oCol:nWidth+IF(oDp:nDifW>0,oDp:nDifW-300,0)
    oCol:lRepeat:=oDefCol:MOC_DESCRI_REPITE  // cambio de F a T Ag TJ

    // Monto
    oCol:=oGrid:AddCol("MOC_MONTO")
    oCol:cTitle:=oDefCol:MOC_MONTO_TITLE
    // oCol:cTitle    :="Debe"
    oCol:bWhen     :="!Empty(oGrid:MOC_CUENTA)"
    // oCol:cPicture  :="999,999,999,999,999.99"
    oCol:cPicture  :=oDefCol:MOC_MONTO_PICTURE
    oCol:nWidth    :=155+10
    oCol:bValid    :="oGrid:VMOC_MONTO(oGrid:MOC_MONTO)"
    oCol:lEmpty    :=.T.
    oCol:lTotal    :=.T. // Genera Totales oCol:nTotal
    oCol:lViewEmpty:=.T.

    cFieldMto:="MOC_MONTO"

    oCol:=oGrid:AddCol("MOC_MTOCRE")
    // oCol:cTitle    :="Haber"
    oCol:cTitle    :=oDefCol:MOC_MTOCRE_TITLE
    oCol:bWhen     :="!Empty(oGrid:MOC_CUENTA) .AND. oGrid:MOC_MONTO=0"
    // oCol:cPicture  :="999,999,999,999,999.99"
    oCol:cPicture  :=oDefCol:MOC_MTOCRE_PICTURE

    oCol:nWidth    :=155+10
    oCol:bValid    :="oGrid:VMOC_MTOCRE(oGrid:MOC_MTOCRE)"
    oCol:lEmpty    :=.T.
    oCol:lTotal    :=.T. // Genera Totales oCol:nTotal
    oCol:lViewEmpty:=.T.

    cFieldMto:="MOC_MTOCRE"

  ELSE

    // Descripción
    oCol:=oGrid:AddCol("MOC_DESCRI")
    // oCol:cTitle:="Descripción"
    oCol:cTitle:=oDefCol:MOC_DESCRI_TITLE
    oCol:bWhen :="!Empty(oGrid:MOC_CUENTA)"
    oCol:nWidth:=280+iif(oDp:lCenCos,-80,0)+IIF(Empty(oDp:cModeVideo),0,90)

    oCol:nWidth:=oCol:nWidth+IF(oDp:nDifW>0,oDp:nDifW-300,0)

    // oCol:lRepeat:=.F.  // cambio de F a T Ag TJ
    oCol:lRepeat:=oDefCol:MOC_DESCRI_REPITE  // cambio de F a T Ag TJ

    // Monto
    oCol:=oGrid:AddCol("MOC_MONTO")
    // oCol:cTitle :="Monto"
    oCol:cTitle :=oDefCol:MOC_MONTO_TITLE
    oCol:bWhen  :="!Empty(oGrid:MOC_CUENTA)"
    //oCol:cPicture:="999,999,999,999,999.99"
    oCol:cPicture  :=oDefCol:MOC_MONTO_PICTURE
    oCol:nWidth :=155+10
    oCol:bValid :="oGrid:VMOC_MONTO(oGrid:MOC_MONTO)"
    oCol:lEmpty :=.T.
    oCol:lTotal :=.T. // Genera Totales oCol:nTotal

    cFieldMto:="MOC_MONTO"

  ENDIF

  IF oDefCol:MOC_DOCPAG_ACTIVO
      oCol:=oGrid:AddCol("MOC_DOCPAG") 
      oCol:cTitle   :=oDefCol:MOC_DOCPAG_TITLE
      oCol:bWhen    :=".F."
      oCol:nWidth   :=38
      oCol:bRunOff  :={||oCbte:VERPAGO()}
   ENDIF


   IF oDefCol:MOC_NUMPAR_ACTIVO
      oCol:=oGrid:AddCol("MOC_NUMPAR") 
      oCol:cTitle   :=oDefCol:MOC_NUMPAR_TITLE
      oCol:bWhen    :=".F."
      oCol:nWidth   :=38
   ENDIF

   
   IF oDefCol:MOC_REGAUD_ACTIVO
      oCol:=oGrid:AddCol("MOC_REGAUD") 
      oCol:cTitle   :=oDefCol:MOC_REGAUD_TITLE
      oCol:bWhen    :=".F."
      oCol:nWidth   :=38
   ENDIF

   IF oDefCol:MOC_CODAUX_ACTIVO
      oCol:=oGrid:AddCol("MOC_CODAUX") 
      // oCol:cTitle:="Código"+CRLF+"Auxiliar"
      oCol:cTitle   :=oDefCol:MOC_CODAUX_TITLE
      oCol:bWhen    :=".F."
      oCol:nWidth   :=38
      oCol:bRunOff  :={||oCbte:MNUAUXORIGEN()}
   ENDIF

   IF oDefCol:MOC_ORIGEN_ACTIVO
      oCol:=oGrid:AddCol("MOC_ORIGEN") 
      // oCol:cTitle:="Org"
      oCol:cTitle   :=oDefCol:MOC_ORIGEN_TITLE
      oCol:bWhen    :=".F."
      oCol:nWidth   :=38
      oCol:bRunOff  :={||oCbte:MNUORIGEN()}

  ENDIF

  oCbte:oFocus    :=oCbte:oCBT_NUMERO
  oCbte:oFocusFind:=oCbte:oCBT_NUMERO

  oCbte:nColMonto:=ASCAN(oGrid:aCols,{|oCol,n| oCol:cField="MOC_MONTO"})
  oCbte:nColHaber:=ASCAN(oGrid:aCols,{|oCol,n| oCol:cField="MOC_MTOCRE"})

  oCbte:oGrid   :=oGrid

  oCbte:Activate({||oCbte:INICIO()})

  // Ajusta el formulario segun Alto de la Resolución
// IF .F.
//  EJECUTAR("FRMMOVEDOWN",oGrid:oBrw,oCbte)
// ENDIF

  oDp:nDif:=(oDp:aCoors[3]-180-oCbte:oWnd:nHeight())
  oDp:nDif:=(oDp:aCoors[3]-190-oCbte:oWnd:nHeight())


//? oDp:nDif,"oDp:nDif"

IF .F.

  oCbte:oWnd:SetSize(NIL,oDp:aCoors[3]-180,.T.)

  oGrid:oBrw:SetSize(NIL,oGrid:oBrw:nHeight()+oDp:nDif,.T.)

ENDIF

// Copia Altura y Tamaño del Grid
//  oGrid:oBrw:Move(120,10,.t.) // oGrid:aSize[1],oGrid:aSize[2],.T.)
  oCbte:oGrid     :=oGrid
  oCbte:nTop      :=120+10 // oGrid:oBrw:nTop()
  oCbte:nLeft     :=0 //oGrid:oBrw:nLeft()
  oCbte:nHeightBrw:=oGrid:oBrw:nHeight()

  // Cuando el Tamaño de la Ventana Principal es Reajustada, reajusta el Dialogo y luego el Browse incrustado
  oCbte:oWnd:bResized:={||oCbte:oDlg:Move(0,0,oCbte:oWnd:nWidth()-20,oCbte:oWnd:nHeight()-20,.T.),;
                          oCbte:oGrid:oBrw:Move(oCbte:nTop,oCbte:nLeft,oCbte:oWnd:nWidth()-20,oCbte:nHeightBrw,.T.),;
                          oCbte:oCta:Move(oCbte:oGrid:oBrw:nTop()+oCbte:oGrid:oBrw:nHeight(),200+100+120,400-100,200+100,.T.)}

  IF oCbte:nWidth_Size>0
    oCbte:oWnd:SetSize(oCbte:nWidth_Size,NIL,.T.) // Valor Obtenido desde GRIDRESTORE, Previamente Guardado mediante TDOCGRIDEND cuando sale del formulario garda en dpcbte*.grid       
  ENDIF

  EVAL(oCbte:oWnd:bResized)
  oGrid:AdjustBtn()

//  oCbte:oCta:Move(oCbte:oGrid:oBrw:nTop+oCbte:oGrid:oBrw:nHeight,400,.T.)
//  oCbte:oCta:Refresh(.T.)
// ? oCbte:oGrid:oBrw:nTop+oCbte:oGrid:oBrw:nHeight
// ? oCbte:oGrid:aBtn[1,1]:nTop(),oCbte:oGrid:aBtn[1,1]:nLeft()

RETURN .T.

FUNCTION INICIO()
  LOCAL oCol,oFontB

  DEFINE FONT oFontB NAME "TAHOMA"   SIZE 0, -14 BOLD

  oCbte:GRIDCHANGE()

  IF oCbte:nColHaber>0 

     oCol:=oGrid:oBrw:aCols[oCbte:nColMonto]
//     oCol:bClrStd:= {||{CLR_HBLUE ,iif( oGrid:oBrw:nArrayAt%2=0, oGrid:nClrPane1, oGrid:nClrPane2 ) } }
     oCol:oDataFont:=oFontB

     oCol:=oGrid:oBrw:aCols[oCbte:nColHaber]
//     oCol:bClrStd:= {||{CLR_HRED,iif( oGrid:oBrw:nArrayAt%2=0, oGrid:nClrPane1, oGrid:nClrPane2 ) } }
     oCol:oDataFont:=oFontB

     oGrid:bClrText:= {|oBrw,nClrText,aLine|aLine:=oCbte:oGrid:oBrw:aArrayData[oCbte:oGrid:oBrw:nArrayAt],;
                                            nClrText:=IF(aLine[oCbte:nColMonto]>0,CLR_HBLUE,CLR_HRED),;
                                            nClrText:=IF(aLine[oCbte:nColMonto]=0 .AND. aLine[oCbte:nColHaber]=0,0,nClrText),;
                                            nClrText:=IF(aLine[oCbte:nColMonto]=0 .AND. aLine[oCbte:nColHaber]=0,0,nClrText),;
                                            nClrText}
  ELSE

     oGrid:bClrText:= {|oBrw,nClrText,aLine|aLine:=oCbte:oGrid:oBrw:aArrayData[oCbte:oGrid:oBrw:nArrayAt],;
                                            nClrText:=IF(aLine[oCbte:nColMonto]>0,CLR_HBLUE,CLR_HRED),;
                                            nClrText}

  ENDIF

// oCbte:GRIDCHANGE()

RETURN .T.

/*
// Carga los Datos
*/
FUNCTION LOAD()
   LOCAL cNumero

   IF oCbte:nOption=1 .AND. oCbte:lActual

      oCbte:oCBT_FECHA :VarPut(oDp:dFecha,.T.)


      IF oCbte:CBT_FECHA>oCbte:dHasta .OR. oCbte:CBT_FECHA<oCbte:dDesde
         oCbte:oCBT_FECHA:VarPut(oCbte:dHasta,.T.)
      ENDIF

   ENDIF

   IF oCbte:nOption=1.AND. !oCbte:lActual

      oCbte:CBT_FECHA  :=oDp:dFecha

      IF oCbte:CBT_FECHA>oCbte:dHasta .OR. oCbte:CBT_FECHA<oCbte:dDesde
        oCbte:oCBT_FECHA:VarPut(oCbte:dHasta,.T.)
      ENDIF

/*
31/07/2024, Reemplazado por comprobante definible
      IF !oDp:lNumCom
         oCbte:CBT_NUMERO :=SQLINCREMENTAL("DPCBTE","CBT_NUMERO","CBT_CODSUC"+GetWhere("=",oDp:cSucursal   )+" AND "+;
                                                                 "CBT_FECHA "+GetWhere("=",oCbte:CBT_FECHA))
      ELSE
         oCbte:CBT_NUMERO :=EJECUTAR("DPNUMCBTE","CONTAB",oDp:dFecha)
      ENDIF
*/
      cNumero :=EJECUTAR("DPNUMCBTEXTIPDOC","DPCBTE","CBT",oCbte:CBT_FECHA)
 
      IF !Empty(cNumero)
         oCbte:oCBT_NUMERO:VarPut(cNumero,.T.)
      ENDIF

      oCbte:CBT_CODSUC :=oDp:cSucursal
      oCbte:oCBT_NUMERO:Refresh(.T.)
      oCbte:oCBT_FECHA :VarPut(oDp:dFecha,.T.)

      oCbte:CBT_ACTUAL:=oCbte:cActual
      oGrid:CancelEdit()

   ENDIF

   oGrid:ShowTotal()

   IF oCbte:nOption=0

      oGrid:CancelEdit()
      oCbte:dFecha   :=oCbte:CBT_FECHA
      oCbte:cNumero  :=oCbte:CBT_NUMERO
      oCbte:oCBT_FECHA:VarPut( oCbte:CBT_FECHA ,.T.)

   ELSE

      DpFocus(oCbte:oCBT_NUMERO)

   ENDIF

   IF oCbte:nOption=3.AND. oCbte:lActual .AND. !oCbte:lRevCbte
      MensajeErr("Comprobantes Actualizados no pueden ser Modificados")
      Return .f.
   ENDIF

   IF ValType(oCbte:oCEN_DESCRI)="O"
      oCbte:oCEN_DESCRI:Refresh(.T.)
   ENDIF

   // Esto Requiere Permiso por parte del usuario

   IF oCbte:nOption=1.AND. oCbte:lActual .And. oCbte:cNumero="" .AND. !oCbte:lIncCbteAct

      MensajeErr("Para Incluir, primero debe crear el comprobante como diferido."+CRLF+;
                 'Luego ejecute el proceso de "Actualizar".')

      Return .F.

   ENDIF

RETURN .T.

/*
// Valida Cancelación
*/
FUNCTION CANCEL()

  oCbte:GRIDTOTAL() // Calcula el Total  cScope:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND MOC_ACTUAL"+GetWhere("=",cActual)
  oCbte:nTotal:=oCbte:aGrids[1]:GetTotal("MOC_MONTO")

  IF oCbte:aGrids[1]:nOption=1
     oCbte:nTotal:=oCbte:nTotal-oCbte:aGrids[1]:MOC_MONTO
  ENDIF

  oCbte:nTotal:=oCbte:nDebe-oCbte:nHaber
  oCbte:nTotal:=VAL(LSTR(oCbte:nTotal))

  IF oCbte:cActual<>"N" .AND. oCbte:nTotal<>0 .AND. oCbte:lAutorizaSalida
     MensajeErr("Descuadre del Comprobante "+ALLTRIM(FDP(oCbte:nTotal,"99,999,999,999,999.99")),"No puede ser Cancelado")
     RETURN .F.
  ENDIF

  oCbte:LOAD() 

RETURN .T.
/*
// Ejecuta la Impresión del Documento
*/
FUNCTION PRINTER()
   LOCAL cRep:="ASIENTOACT",oRep

   IF oCbte:CBT_ACTUAL="N"
      cRep:="ASIENTODIF"
   ENDIF
   
   IF oCbte:CBT_ACTUAL="A"
      cRep:="ASIENTOAUD"
   ENDIF

   oRep:=REPORTE(cRep)
   oRep:SetRango(1,oCbte:CBT_NUMERO,oCbte:CBT_NUMERO)
   oRep:SetRango(2,oCbte:CBT_FECHA ,oCbte:CBT_FECHA )

RETURN .T.

FUNCTION PRESAVE()
  LOCAL aData:=oCbte:aGrids[1]:oBrw:aArrayData   // ag TJ 3.02

  oCbte:CBT_NUMEJE:=EJECUTAR("FCH_EJERGET",oCbte:CBT_FECHA)
  oCbte:Set("CBT_CODSUC",oDp:cSucursal)

  IF !oCbte:CBTFECHA()
     RETURN .F.
  ENDIF

  IF LEN(aData)=1 .AND. Empty(aData[1,2]) .AND. !MsgNoYes("Desea Grabar Comprobante Vacio")
     RETURN .F.
  ENDIF

  IF !oCbte:lSaved
     RETURN .T.
  ENDIF

  oCbte:GRIDTOTAL() // Calcula el Total  cScope:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND MOC_ACTUAL"+GetWhere("=",cActual)

/*
  oCbte:nTotal:=oCbte:aGrids[1]:GetTotal("MOC_MONTO")

  IF oCbte:aGrids[1]:nOption=1
     oCbte:nTotal:=oCbte:nTotal-oCbte:aGrids[1]:MOC_MONTO
  ENDIF
*/

  //En caso que el Total sea -0.00 pase a 0.00
  oCbte:nTotal:=oCbte:nDebe-oCbte:nHaber
  oCbte:nTotal:=VAL(LSTR(oCbte:nTotal))

  oCbte:lAutorizaSalida:=.F.

  IF oCbte:cActual<>"N" .AND. oCbte:nTotal<>0
     // MensajeErr("Descuadre del Comprobante","No puede ser Finalizado")

     IF !MsgNoYes("Desear Grabar Compronante con Descuadre?"+CRLF+"Los EEFF presentaran resultados incorrectos","Comprobante Descuadrado")
       RETURN .F.
     ENDIF

     oCbte:lAutorizaSalida:=.T.

  ENDIF

RETURN .T.

/*
// Permiso para Borrar
*/
FUNCTION PREDELETE(cActual)
 LOCAL cNumEje:=EJECUTAR("GETNUMEJE",oCbte:CBT_FECHA),lCierre

 IF oCbte:cActual="S" .AND. !EJECUTAR("DPVALFECHA",oCbte:CBT_FECHA,.T.,.T.)
   RETURN .F.
 ENDIF
 
 lCierre:=SQLGET("DPEJERCICIOS","EJE_CIERRE","EJE_NUMERO"+GetWhere("=",cNumEje))

 IF lCierre 
   MsgMemo("No es Posible Eliminar Cbte "+oCbte:CBT_NUMERO+" del "+DTOC(oCbte:CBT_FECHA),"Ejercicio "+cNumEje+" Está Cerrado")
   RETURN .F.
 ENDIF

 
 IF !MsgNoYes("Desea Eliminar el Comprobante: "+oCbte:CBT_NUMERO+;
                CRLF+"Fecha: "+DTOC(oCbte:CBT_FECHA),"Eliminar Registro")

     RETURN .F.

 ENDIF


RETURN .T.

/*
// Después de Eliminar
*/
FUNCTION POSTDELETE()

 // 24-06-2012 Marlon Ramos (Marcar como no contabilizado el Activo) 
 SQLUPDATE("DPDEPRECIAACT", {"DEP_COMPRO", "DEP_FCHCON", "DEP_ESTADO"}, {"", "0000-00-00", "A"}, "DEP_COMPRO" +GetWhere("=",  oCbte:CBT_NUMERO) + " AND DEP_FECHA" +GetWhere("=",  oCbte:CBT_FECHA))
 // Fin 24-06-2012 Marlon Ramos (Marcar como no contabilizado el Activo) 

 SQLDELETE("DPASIENTOS","MOC_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
                        "MOC_ACTUAL"+GetWhere("=",oCbte:CBT_ACTUAL)+" AND "+;
                        "MOC_FECHA" +GetWhere("=",oCbte:CBT_FECHA )+" AND "+;
                        "MOC_NUMCBT"+GetWhere("=",oCbte:CBT_NUMERO))

 // no hay mas Comprobante
 IF COUNT("DPCBTE",oCbte:cScope)=0
   oCbte:LoadData(1)
 ENDIF

RETURN .T.

FUNCTION VMOC_CUENTA(cCodCta)
  LOCAL cWhereC:=EJECUTAR("GETWHERELIKE","DPCTA","CTA_DESCRI",cCodCta,"CTA_CODIGO")
  LOCAL oCol   :=oGrid:GETCOL("MOC_CUENTA")
  oGrid:cWhereC:="",cCodCta

  IF EMPTY(oGrid:MOC_CUENTA)
     RETURN .F.
  ENDIF

  oCol:cWhereListBox:="CTA_ACTIVO=1"

  IF COUNT("DPCTA",cWhereC)>1
     oCol:cWhereListBox:="CTA_ACTIVO=1 AND "+cWhereC
     RETURN .F.
  ELSE
     cCodCta:=SQLGET("DPCTA","CTA_CODIGO",cWhereC)
     oGrid:SET("MOC_CUENTA",cCodCta,.T.)
  ENDIF

  oCbte:CTASETTEXT()

  IF !ISSQLGET("DPCTA","CTA_CODIGO",oGrid:MOC_CUENTA) .OR. !ISSQLGET("DPCTA","CTA_CODIGO",cCodCta)
     RETURN .F.
  ENDIF

  IF(oCbte:oCol_CTA_DESCRI=NIL,NIL,oGrid:ColCalc("CTA_DESCRI"))

  IF Empty(oGrid:MOC_CENCOS)
     oGrid:MOC_CENCOS:=oDp:cCenCos
     oGrid:SET("MOC_CENCOS",oDp:cCenCos , oDp:lCenCos )
  ENDIF

  oCbte:oCta:SetText(GetFromVar("{oDp:xDPCTA}"   )+": "+MYSQLGET("DPCTA"   ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oGrid:MOC_CUENTA))+CHR(10)+;
                     GetFromVar("{oDp:xDPCENCOS}")+": "+MYSQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oGrid:MOC_CENCOS)))

  IF !EJECUTAR("ISCTADET",cCodCta,.T.,oGrid:oBrw)
     RETURN .F.
  ENDIF

  oGrid:SET("MOC_CODSUC",oDp:cSucursal   )
  oGrid:SET("MOC_ACTUAL",oCbte:CBT_ACTUAL)
  oGrid:SET("MOC_ALTER" ,.T.             )

RETURN .T.

/*
// Validar Centro de Costo
*/

FUNCTION VMOC_CENCOS(cCodCen)

  oCbte:CTASETTEXT()

  IF EMPTY(oGrid:MOC_CENCOS)
     RETURN .F.
  ENDIF

  IF !ISMYSQLGET("DPCENCOS","CEN_CODIGO",oGrid:MOC_CENCOS)
     RETURN .F.
  ENDIF

  IF(oCbte:oCol_CEN_DESCRI=NIL,NIL,oGrid:ColCalc("CEN_DESCRI"))

  oCbte:oCta:SetText(GetFromVar("{oDp:xDPCTA}"   )+": "+MYSQLGET("DPCTA"   ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oGrid:MOC_CUENTA))+CHR(10)+;
                     GetFromVar("{oDp:xDPCENCOS}")+": "+MYSQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oGrid:MOC_CENCOS)))

  IF !EJECUTAR("ISCENDET",cCodCen,.T.)
     RETURN .F.
  ENDIF

RETURN .T.


FUNCTION VMOC_CODDEP(cCodDep)

  oCbte:CTASETTEXT()

  IF EMPTY(oGrid:MOC_CODDEP)
     RETURN .F.
  ENDIF

  IF !ISMYSQLGET("DPDPTO","DEP_CODIGO",oGrid:MOC_CODDEP)
     RETURN .F.
  ENDIF

  IF(oCbte:oCol_DEP_DESCRI=NIL,NIL,oGrid:ColCalc("DEP_DESCRI"))

/*
  oCbte:oCta:SetText(GetFromVar("{oDp:xDPCTA}"   )+": "+MYSQLGET("DPCTA"   ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oGrid:MOC_CUENTA))+CRLF+;
                     GetFromVar("{oDp:xDPCENCOS}")+": "+MYSQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oGrid:MOC_CENCOS))+CRLF+;
                     GetFromVar("{oDp:xDPCENCOS}")+": "+MYSQLGET("DPDPTO" ,"DEP_DESCRI","DEP_CODIGO"+GetWhere("=",oGrid:MOC_CODDEP)))
*/

RETURN .T.

/*
// Validar RIF
*/
FUNCTION VMOC_RIF(cRif)

  // RIF Puede quedar vacio

  oCbte:CTASETTEXT()

  IF(oCbte:oCol_RIF_NOMBRE=NIL,NIL,oGrid:ColCalc("RIF_NOMBRE"))

  IF EMPTY(oGrid:MOC_RIF)
     RETURN .T.
  ENDIF

  IF !ISMYSQLGET("DPRIF","RIF_ID",oGrid:MOC_RIF)
     RETURN .F.
  ENDIF

RETURN .T.

FUNCTION CTASETTEXT()
  LOCAL cText:=""
  LOCAL oDefCol:=oCbte:oDefCol
 
  IF oGrid:nOption=0

    cText:=GetFromVar("{oDp:xDPCTA   }")+": "+oGrid:CTA_DESCRI

    IF oCbte:oDefCol:MOC_CENCOS_ACTIVO .AND. !oCbte:oDefCol:CEN_DESCRI_ACTIVO
      cText:=cText+CRLF+GetFromVar("{oDp:xDPCENCOS}")+": "+oGrid:CEN_DESCRI
    ENDIF

    IF oCbte:oDefCol:MOC_CODDEP_ACTIVO .AND. !oCbte:oDefCol:DEP_DESCRI_ACTIVO
      cText:=cText+CRLF+GetFromVar("{oDp:xDPDPTO  }")+": "+oGrid:DEP_DESCRI
    ENDIF

    IF oCbte:oDefCol:MOC_RIF_ACTIVO .AND. !oCbte:oDefCol:RIF_NOMBRE_ACTIVO
      cText:=cText+CRLF+GetFromVar("{oDp:xDPRIF  }")+": "+oGrid:RIF_NOMBRE
    ENDIF

  ELSE

    cText:=GetFromVar("{oDp:xDPCTA   }")+": "+MYSQLGET("DPCTA"   ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oGrid:MOC_CUENTA))

    IF oCbte:oDefCol:MOC_CENCOS_ACTIVO .AND. !oCbte:oDefCol:CEN_DESCRI_ACTIVO
      cText:=cText+CRLF+GetFromVar("{oDp:xDPCENCOS}")+": "+MYSQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oGrid:MOC_CENCOS))
    ENDIF

    IF oCbte:oDefCol:MOC_CODDEP_ACTIVO .AND. !oCbte:oDefCol:DEP_DESCRI_ACTIVO
      cText:=cText+CRLF+GetFromVar("{oDp:xDPDPTO  }")+": "+MYSQLGET("DPDPTO" ,"DEP_DESCRI","DEP_CODIGO"+GetWhere("=",oGrid:MOC_CODDEP))
    ENDIF

    IF oCbte:oDefCol:MOC_RIF_ACTIVO .AND. !oDefCol:RIF_NOMBRE_ACTIVO
      cText:=cText+CRLF+GetFromVar("{oDp:xDPRIF  }")+": "+MYSQLGET("DPRIF" ,"RIF_NOMBRE","RIF_ID"+GetWhere("=",oGrid:MOC_RIF))
    ENDIF

  ENDIF

  oCbte:oCta:SetText(cText)

RETURN .T.


/*
// Carga para Incluir o Modificar en el Grid
*/
FUNCTION GRIDLOAD()
  LOCAL nTotal:=0,nDebe:=0,nHaber:=0,cItem:="",cNumPar

 // UniColumna
 oGrid:Set("MOC_CTAMOD",oDp:cCtaMod  )

 IF oGrid:nOption=1 .AND. !oCbte:lActual .AND. !oDp:lDebCre
    nTotal:=oGrid:GetTotal("MOC_MONTO")
    nTotal:=nTotal*IIF(nTotal=0,1,-1)
    oGrid:oBrw:GoBottom()
    oGrid:Set("MOC_MONTO",nTotal,.T.)
 ENDIF

 IF oGrid:nOption=1 .AND. !oCbte:lActual .AND. oDp:lDebCre

    nDebe :=oGrid:GetTotal("MOC_MONTO")
    nHaber:=oGrid:GetTotal("MOC_MTOCRE")
    nTotal:=nDebe-nHaber
    nTotal:=nTotal*IIF(nTotal=0,1,-1)
    oGrid:oBrw:GoBottom()

    IF nTotal>0
      oGrid:Set("MOC_MONTO",nTotal,.T.)
      oGrid:Set("MOC_MTOCRE",0    ,.T.)
    ELSE
      nTotal:=ABS(nTotal)
      oGrid:Set("MOC_MTOCRE",nTotal,.T.)
      oGrid:Set("MOC_MONTO" ,0     ,.T.)
    ENDIF

 ENDIF

 IF oGrid:nOption=1

    IF (oCbte:nDebe-oCbte:nHaber)=0

      cNumPar:=SQLINCREMENTAL("DPASIENTOS","MOC_NUMPAR","MOC_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
                                                        "MOC_NUMCBT"+GetWhere("=",oCbte:CBT_NUMERO)+" AND "+;
                                                        "MOC_FECHA "+GetWhere("=",oCbte:CBT_FECHA ),NIL,NIL,.T.,5)

    ELSE

      cNumPar:=SQLGETMAX("DPASIENTOS","MOC_NUMPAR","MOC_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
                                                   "MOC_NUMCBT"+GetWhere("=",oCbte:CBT_NUMERO)+" AND "+;
                                                   "MOC_FECHA "+GetWhere("=",oCbte:CBT_FECHA ),NIL,NIL,.T.,5)
    ENDIF

    // Si al Momento de Iniciar el Asiento es 0, se crea una nueva partida
    cNumPar:=IF(Empty(cNumPar),STRZERO(1,6),cNumPar)

    cItem  :=SQLINCREMENTAL("DPASIENTOS","MOC_ITEM","MOC_CODSUC"+GetWhere("=",oDp:cSucursal   )+" AND "+;
                                                    "MOC_NUMCBT"+GetWhere("=",oCbte:CBT_NUMERO)+" AND "+;
                                                    "MOC_FECHA "+GetWhere("=",oCbte:CBT_FECHA ),NIL,NIL,.T.,4)

    oGrid:Set("MOC_ITEM"  ,cItem  ,.T.)
    oGrid:Set("MOC_NUMPAR",cNumPar,.T.)

    // Posiciona en Cuenta Contable
    IF oCbte:oDefCol:MOC_ITEM_ACTIVO
      oGrid:oBrw:nColSel:=2
    ENDIF

    // oGrid:GetCol("MOC_CUENTA"):Edit()
    // oGrid:SET("MOC_CODDEP",oDp:cCodDep,.T.)
    oGrid:SET("MOC_NUMPAR",cNumPar    ,.T.)

    IF  !oCbte:oDefCol:MOC_RIF_REPITE
       oGrid:SET("MOC_RIF",CTOEMPTY(oGrid:MOC_RIF),.T.)
    ENDIF

    IF  !oCbte:oDefCol:MOC_CODDEP_REPITE
       oGrid:SET("MOC_CODDEP",oDp:cCodDep,.T.)
    ENDIF

    IF Empty(oGrid:MOC_CENCOS) .OR. oCbte:CBT_CENGEN
       oGrid:MOC_CENCOS:=oCbte:CBT_CENCOS
       oGrid:SET("MOC_CENCOS",oCbte:CBT_CENCOS , oDp:lCenCos )
    ENDIF

    // Refrescar 
    IF oCbte:oDefCol:CEN_DESCRI_ACTIVO
       oCol:=oGrid:GetCol("CEN_DESCRI")
       oGrid:ColCalc("CEN_DESCRI")
    ENDIF

 ENDIF

RETURN NIL

/*
// Ejecución despues de Grabar el Item
*/
FUNCTION GRIDPOSTSAVE()
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)


  IF COUNT("DPPLACOS","PLA_CODCTA"+GetWhere("=",oGrid:MOC_CUENTA))>0

     EJECUTAR("DPCENCOSDIST",oGrid:MOC_CODSUC ,;
                             oGrid:MOC_ACTUAL ,;
                             oGrid:MOC_FECHA  ,;
                             oGrid:MOC_NUMCBT ,;
                             oGrid:MOC_ITEM   ,;
                             oGrid:MOC_CUENTA,;
                             oGrid:MOC_MONTO)

  ENDIF

  oDb:Execute("SET FOREIGN_KEY_CHECKS=0")


RETURN .T.

/*
// Genera los Totales por Grid
*/
FUNCTION GRIDTOTAL()
   LOCAL nDebe:=0,nHaber:=0
   LOCAL oCol:=oGrid:GetCol("MOC_MONTO")

   oCbte:nDebe :=oCol:CalCuleRow("IIF(oGrid:MOC_MONTO>0,oGrid:MOC_MONTO,0)")
   oCbte:nHaber:=oCol:CalCuleRow("IIF(oGrid:MOC_MONTO<0,oGrid:MOC_MONTO,0)")*-1

   IF oCbte:nColHaber>0
     oCbte:nHaber:=oGrid:GetTotal("MOC_MTOCRE")
   ENDIF

   oCbte:nTotal:=oCbte:nDebe-oCbte:nHaber

   oCbte:oDebe :Refresh(.T.)
   oCbte:oHaber:Refresh(.T.)
   oCbte:oSaldo:Refresh(.T.)

RETURN .F.

FUNCTION CBTFECHA()
  LOCAL lResp:=.T.,lCierre
  LOCAL cNumEje:=EJECUTAR("GETNUMEJE",oCbte:CBT_FECHA)

  IF !oCbte:ValUnique(NIL,NIL,NIL,"Comprobante Contable ya Existe")
     RETURN .F.
  ENDIF

  lCierre:=SQLGET("DPEJERCICIOS","EJE_CIERRE","EJE_NUMERO"+GetWhere("=",cNumEje))

  IF !(oCbte:CBT_FECHA>=oCbte:dDesde .AND. oCbte:CBT_FECHA<=oCbte:dHasta) .AND. lCierre
   oCbte:oCBT_FECHA:MsgErr("Fecha debe estar dentro del Ejercicio"+CRLF+"Ejercicio :"+cNumEje+" está Cerrado",DTOC(oCbte:dDesde)+" - "+DTOC(oCbte:dHasta))
   lResp:=.F.
  ENDIF

/*
  lResp:=EJECUTAR("VALFCHEJER",oCbte:CBT_FECHA,"Comprobante Contable") .AND.;
        oCbte:ValUnique(NIL,NIL,NIL,"Comprobante Contable ya Existe")
*/

RETURN lResp

FUNCTION GRIDCHANGE()
  LOCAL cText:=""

  cText:=CTOO(oDp:xDPCTA,"C")+": "+CTOO(oGrid:CTA_DESCRI,"C")

//  IF oDp:lCenCos
//     cText:=cText+CHR(10)+CTOO(oDP:xDPCENCOS,"C")+": "+CTOO(oGrid:CEN_DESCRI,"C")
//  ENDIF

  oCbte:CTASETTEXT()

//  oCbte:oCta:SetText(cText)

RETURN ""

/*
// Validar Monto
*/
FUNCTION VMOC_MONTO(nMonto)

  IF nMonto>0 .AND. oDp:lDebCre
    oGrid:Set("MOC_MTOCRE",0,.T.)
  ENDIF

RETURN .T.

/*
// Validar Monto
*/
FUNCTION VMOC_MTOCRE(nMonto)

   IF nMonto<>0
      oGrid:Set("MOC_MONTO",0,.T.)
   ENDIF

   IF nMonto<0
      nMonto:=ABS(nMonto)
      oGrid:Set("MOC_MTOCRE",nMonto,.T.)
      RETURN .F.
   ENDIF

RETURN .T.


FUNCTION GRIDPRESAVE()
    LOCAL cWhere,oDb:=OpenOdbc(oDp:cDsnData)

    IF !oCbte:CBTFECHA()
        RETURN .F.
    ENDIF

    IF Empty(oGrid:MOC_CUENTA) 
       Return .F.
    ENDIF

    IF Empty(oGrid:MOC_DESCRI) 
       oGrid:MensajeErr("Requiere Descripción del Asiento","Validación Campo Descripción")
       RETURN .F.
    ENDIF


    IF Empty(oGrid:MOC_ORIGEN) 
       oGrid:Set("MOC_ORIGEN","CON") // Contabilidad
    ENDIF

    IF oGrid:MOC_ORIGEN="CON"
       oGrid:MOC_MTOORG:=IF(Empty(oGrid:MOC_MTOORG),0 ,oGrid:MOC_MTOORG)
       oGrid:MOC_ITEM_O:=IF(Empty(oGrid:MOC_ITEM_O),"",oGrid:MOC_ITEM_O)
       oGrid:MOC_TIPASI:=IF(Empty(oGrid:MOC_TIPASI),"",oGrid:MOC_TIPASI)
       oGrid:MOC_ESTORG:=IF(Empty(oGrid:MOC_ESTORG),"",oGrid:MOC_ESTORG)
    ENDIF


//  JN 7/2/2017, Solicitado por Orlando Perez para Incluir Cheques Anulados
//  IF Empty(oGrid:MOC_MONTO)
//     Return .T.
//  ENDIF

    IF oCbte:nOption=3 .AND.  ( oCbte:dFecha<>oCbte:CBT_FECHA  .OR. oCbte:cNumero<>oCbte:CBT_NUMERO)

       cWhere:="CBT_CODSUC"+GetWhere("=", oCbte:CBT_CODSUC)+" AND "+;
               "CBT_FECHA" +GetWhere("=", oCbte:dFecha    )+" AND "+;
               "CBT_NUMERO"+GetWhere("=", oCbte:cNumero   )+" AND "+;
               "CBT_ACTUAL"+GetWhere("=", oCbte:cActual   )

       SQLUPDATE("DPCBTE" , {"CBT_FECHA","CBT_NUMERO"},{oCbte:CBT_FECHA,oCbte:CBT_NUMERO} , cWhere)

       oCbte:cWhereOpen:=oCbte:GetWhere(NIL,.T.) // Necesario para Validar VALUNIQUE()

    ENDIF

    IF oGrid:nOption=1

       oGrid:MOC_ITEM:=SQLINCREMENTAL("DPASIENTOS","MOC_ITEM","MOC_CODSUC"+GetWhere("=",oDp:cSucursal   )+" AND "+;
                                                              "MOC_NUMCBT"+GetWhere("=",oCbte:CBT_NUMERO)+" AND "+;
                                                              "MOC_FECHA "+GetWhere("=",oCbte:CBT_FECHA ),NIL,NIL,.T.,4)
    ENDIF

    oCbte:dFecha :=oCbte:CBT_FECHA 
    oCbte:cNumero:=oCbte:CBT_NUMERO

    oGrid:Set("MOC_ACTUAL",oCbte:cActual)
    oGrid:Set("MOC_CTAMOD",oDp:cCtaMod  )
    oGrid:Set("MOC_CODSUC",oDp:cSucursal)
    oGrid:Set("MOC_NUMEJE",oCbte:CBT_NUMEJE)

    IF Empty(oGrid:MOC_CENCOS) 
      oGrid:Set("MOC_CENCOS",oCbte:CBT_CENCOS) // oDp:cCenCos )
    ENDIF

    IF !Empty(oCbte:cCodDep) .AND. Empty(oGrid:MOC_CODDEP)
      oGrid:Set("MOC_CODDEP",oCbte:cCodDep)
    ENDIF

    IF oDp:lDebCre .AND. oGrid:MOC_MTOCRE<>0
      oGrid:MOC_MONTO:=oGrid:MOC_MTOCRE*-1
    ENDIF

    oDb:Execute("SET FOREIGN_KEY_CHECKS=0")

RETURN .T.

/*
// JN Visualizar Origen del Documento
*/
FUNCTION VERORIGEN()
  LOCAL cWhere:=""
  LOCAL cCodSuc,nPeriodo,dDesde,dHasta,cTitle
  LOCAL cOrg,cNumero,nAt
  LOCAL lAuto:=.F.,cTipPag:=NIL,cCodSuc:=oCbte:CBT_CODSUC,cCodPro:=NIL,cRecord,lView:=.T.,cCenCos:=NIL
  LOCAL cSucCli,lPagEle:=.F.

  IF Empty(oGrid:MOC_ORIGEN) 
     oGrid:MensajeErr("Asiento no es Generado por el Sistema","Asiento Contable")
     RETURN .T.
  ENDIF

  IF oGrid:MOC_ORIGEN="COM"

     IF Empty(oGrid:MOC_DOCUME) .AND. AT(":",oGrid:MOC_DESCRI)

       // Efectivo no tiene Numero de Transacción

       nAt    :=AT(":",oGrid:MOC_DESCRI)
       cNumero:=SUBS(oGrid:MOC_DESCRI,nAt+1,LEN(oGrid:MOC_DESCRI))
       cNumero:=LEFT(cNumero,AT(" ",cNumero))

       cWhere :="CAJ_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
                "CAJ_TIPO  "+GetWhere("=",oGrid:MOC_TIPO  )+" AND "+;
                "CAJ_DOCASO"+GetWhere("=",cNumero         )+" AND "+;
                "CAJ_ORIGEN"+GetWhere("=","PAG"           )

       cOrg   :=SQLGET("DPCAJAMOV","CAJ_ORIGEN,CAJ_DOCASO",cWhere)

       IF !Empty(cNumero) .AND. cOrg="PAG"
          cRecord:="PAG_NUMERO"+GetWhere("=",cNumero)
          EJECUTAR("DPCBTEPAGOX",lAuto,cTipPag,cCodSuc,cCodPro,cRecord,lView,cCenCos)
          RETURN .T.
       ENDIF

     ENDIF

     cWhere:="CAJ_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
             "CAJ_TIPO  "+GetWhere("=",oGrid:MOC_TIPO  )+" AND "+;
             "CAJ_NUMERO"+GetWhere("=",oGrid:MOC_DOCUME)

     cOrg   :=SQLGET("DPCAJAMOV","CAJ_ORIGEN,CAJ_DOCASO",cWhere)
     cNumero:=DPSQLROW(2,"")

     IF !Empty(cNumero) .AND. cOrg="PAG"
        cRecord:="PAG_NUMERO"+GetWhere("=",cNumero)
        EJECUTAR("DPCBTEPAGOX",lAuto,cTipPag,cCodSuc,cCodPro,cRecord,lView,cCenCos)
        RETURN .T.
     ENDIF

     EJECUTAR('DPDOCPROFACCON',NIL,oCbte:CBT_CODSUC,;
                                   oGrid:MOC_TIPO  ,;
                                   oGrid:MOC_DOCUME,;
                                   oGrid:MOC_CODAUX,NIL,NIL)
     RETURN NIL

  ENDIF

  IF oGrid:MOC_ORIGEN="VTA"

     IF Empty(oGrid:MOC_DOCUME) .AND. AT(":",oGrid:MOC_DESCRI)

       // Efectivo no tiene Numero de Transacción

       nAt    :=AT(":",oGrid:MOC_DESCRI)
       cNumero:=ALLTRIM(SUBS(oGrid:MOC_DESCRI,nAt+1,LEN(oGrid:MOC_DESCRI)))
       cNumero:=LEFT(cNumero,AT(" ",cNumero))

       cWhere :="CAJ_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
                "CAJ_TIPO  "+GetWhere("=",oGrid:MOC_TIPO  )+" AND "+;
                "CAJ_DOCASO"+GetWhere("=",cNumero         )+" AND "+;
                "CAJ_ORIGEN"+GetWhere("=","REC"           )

       cOrg   :=SQLGET("DPCAJAMOV","CAJ_ORIGEN,CAJ_DOCASO",cWhere)

       IF !Empty(cNumero) .AND. cOrg="REC"
          cRecord:="REC_NUMERO"+GetWhere("=",cNumero)
          EJECUTAR("DPRECIBOSCLIX",lAuto,cTipPag,cCodSuc,cCodPro,cRecord,lView,cSucCli,lPagEle,cCenCos)
          RETURN .T.
       ENDIF

     ENDIF

     cWhere:="CAJ_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
             "CAJ_TIPO  "+GetWhere("=",oGrid:MOC_TIPO  )+" AND "+;
             "CAJ_NUMERO"+GetWhere("=",oGrid:MOC_DOCUME)

     cOrg   :=SQLGET("DPCAJAMOV","CAJ_ORIGEN,CAJ_DOCASO",cWhere)
     cNumero:=DPSQLROW(2,"")

     IF !Empty(cNumero) .AND. cOrg="REC"
        cRecord:="REC_NUMERO"+GetWhere("=",cNumero)
        EJECUTAR("DPRECIBOSCLIX",lAuto,cTipPag,cCodSuc,cCodPro,cRecord,lView,cSucCli,lPagEle,cCenCos)
        RETURN .T.
     ENDIF

     EJECUTAR("DPDOCCLIFAVCON",NIL,oCbte:CBT_CODSUC,;
                                   oGrid:MOC_TIPO  ,;
                                   oGrid:MOC_DOCUME,;
                                   oGrid:MOC_CODAUX,NIL,NIL)
     RETURN NIL

  ENDIF

  IF oGrid:MOC_ORIGEN="INV"
     EJECUTAR("DPDOCMOV",oGrid:MOC_DOCUME)
  ENDIF

RETURN .T.

/*
// JN Visualizar Origen del Documento
*/
FUNCTION MNUORIGEN()
RETURN EJECUTAR("DPASIENTOMNUORG",oGrid:MOC_CODSUC,oCbte:CBT_ACTUAL,oCbte:CBT_NUMERO,oCbte:CBT_FECHA,oGrid:MOC_ITEM,oGrid,oGrid:oBrw)

/*
// AG20080401. Browser
*/
FUNCTION LIST(cList,cList2)
  LOCAL cWhere:="",dDesde,dHasta,cScope
  LOCAL nAt:=ASCAN(oCbte:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oCbte:aBtn[nAt,1],NIL)

  cWhere:="CBT_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "CBT_ACTUAL"+GetWhere("=",oCbte:cActual)

  dHasta:=SQLGETMAX("DPCBTE","CBT_FECHA",cWhere)
  dDesde:=FCHINIMES(dHasta)

  dHasta:=SQLGETMAX(oCbte:cTable,"CBT_FECHA",oCbte:cScope)
  dDesde:=FCHINIMES(dHasta)

  IF !EJECUTAR("CSRANGOFCH","DPCBTE",cWhere,"CBT_FECHA",dDesde,dHasta,oBtnBrw)
      RETURN .T.
  ENDIF

  cWhere:=""

  oCbte:cListBrw:="DPCBTE_"+oCbte:cActual+".BRW"

  IF !Empty(oDp:dFchIniDoc)
     cWhere:=GetWhereAnd("CBT_FECHA",oDp:dFchIniDoc,oDp:dFchFinDoc)
  ENDIF

  cScope      :=oCbte:cScope
  oCbte:cScope:="" // CBT_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND CBT_ACTUAL"+GetWhere("=",cActual)

  oDp:lExcluye:=.T.
  oCbte:ListBrw(cWhere,oCbte:cListBrw)

  oCbte:cScope:=cScope

RETURN .T.

FUNCTION BRWASIENTOS(nOption,cOption)
  LOCAL cList:="DPCBTE_ASIENTO_"+oCbte:cActual+".BRW"
  LOCAL cWhere:="",dDesde,dHasta
  LOCAL nAt:=ASCAN(oCbte:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oCbte:aBtn[nAt,1],NIL)

  cWhere:="CBT_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "CBT_ACTUAL"+GetWhere("=",oCbte:cActual)+" AND "+GetWhereAnd("CBT_FECHA",oDp:dFchInicio,oDp:dFchCierre)


  dHasta:=SQLGETMAX("DPCBTE","CBT_FECHA",cWhere)
  dDesde:=FCHINIMES(dHasta)

  IF !EJECUTAR("CSRANGOFCH","DPCBTE",cWhere,"CBT_FECHA",dDesde,dHasta,oBtnBrw)
      RETURN .T.
  ENDIF

  cWhere:=NIL

  oCbte:ListBrw(cWhere,cList)

RETURN .T.

/*
// Browse por Cuenta Contable
*/
FUNCTION BRWXCTA()
  LOCAL cWhere:="",cCodigo
  LOCAL cTitle:=" Asientos Contables Agrupados por Cuenta Contable ",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt  :=ASCAN(oCbte:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oCbte:aBtn[nAt,1],NIL)
  LOCAL cList:="DPCBTE_ASIENTO_"+oCbte:cActual+".BRW"

  cWhere :=" INNER JOIN DPCTA  ON MOC_CUENTA=CTA_CODIGO "+;
           " WHERE MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND MOC_ACTUAL "+GetWhere("=",oCbte:cActual)+" AND "+GetWhereAnd("MOC_FECHA",oDp:dFchInicio,oDp:dFchCierre)


  cOrderBy:=" GROUP BY MOC_CUENTA ORDER BY MOC_CUENTA "
  aTitle  :={"Código;Cuenta","Descripción","Desde","Hasta","Acumulado","Cant.;Reg"}


  oDp:aPicture   :={NIL,NIL,NIL,NIL,"999,999,999,999.99","9999"}
  oDp:aSize      :={120,300,60,60,120,40}
  oDp:lFullHeight:=.T.

  oDp:aLine:={}
  cCodigo:=EJECUTAR("REPBDLIST","DPASIENTOS","MOC_CUENTA,CTA_DESCRI,MIN(MOC_FECHA) AS DESDE ,MAX(MOC_FECHA) AS HASTA,SUM(MOC_MONTO) AS CCD_MONTO,COUNT(*) AS CUANTOS",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(oDp:aLine)

     cWhere:="MOC_CUENTA"+GetWhere("=",cCodigo)
     oDp:dFchIniDoc:=oDp:aLine[3]
     oDp:dFchFinDoc:=oDp:aLine[4]

     oCbte:ListBrw(cWhere,cList)

  ENDIF

RETURN .T.

/*
// Browse por Cuenta Contable
*/
FUNCTION BRWXORG()
  LOCAL cWhere:="",cCodigo
  LOCAL cTitle:=" Asientos Contables Agrupados por Origen ",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt  :=ASCAN(oCbte:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oCbte:aBtn[nAt,1],NIL)
  LOCAL cList:="DPCBTE_ASIENTO_"+oCbte:cActual+".BRW"

  cWhere :=" WHERE MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND MOC_ACTUAL "+GetWhere("=",oCbte:cActual)+" AND "+GetWhereAnd("MOC_FECHA",oDp:dFchInicio,oDp:dFchCierre)


  cOrderBy:=" GROUP BY MOC_ORIGEN ORDER BY MOC_ORIGEN "
  aTitle  :={"Origen","Desde","Hasta","Acumulado","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,"999,999,999,999.99","9999"}
  oDp:aSize      :={50,60,60,120,40}
  oDp:lFullHeight:=.F.

  oDp:aLine:={}
  cCodigo:=EJECUTAR("REPBDLIST","DPASIENTOS","MOC_ORIGEN,MIN(MOC_FECHA) AS DESDE ,MAX(MOC_FECHA) AS HASTA,SUM(MOC_MONTO) AS CCD_MONTO,COUNT(*) AS CUANTOS",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(oDp:aLine)

     cWhere:="MOC_ORIGEN"+GetWhere("=",cCodigo)
     oDp:dFchIniDoc:=oDp:aLine[2]
     oDp:dFchFinDoc:=oDp:aLine[3]
     oCbte:ListBrw(cWhere,cList)

  ENDIF

RETURN .T.


/*
// Browse por Cuenta Contable
*/
FUNCTION BRWXORGTIP()
  LOCAL cWhere:="",cCodigo
  LOCAL cTitle:=" Asientos Contables Agrupados por Origen y Tipo ",aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
  LOCAL nAt  :=ASCAN(oCbte:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oCbte:aBtn[nAt,1],NIL)
  LOCAL cList:="DPCBTE_ASIENTO_"+oCbte:cActual+".BRW"

  cWhere :=" WHERE MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND MOC_ACTUAL "+GetWhere("=",oCbte:cActual)+" AND "+GetWhereAnd("MOC_FECHA",oDp:dFchInicio,oDp:dFchCierre)


  cOrderBy:=" GROUP BY MOC_ORIGEN,MOC_TIPO ORDER BY MOC_ORIGEN "
  aTitle  :={"Origen","Tipo","Desde","Hasta","Acumulado","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"99,999,999,999,999.99","9999"}
  oDp:aSize      :={50,50,60,60,130,40}
  oDp:lFullHeight:=.T.

  oDp:aLine:={}
  cCodigo:=EJECUTAR("REPBDLIST","DPASIENTOS","MOC_ORIGEN,MOC_TIPO,MIN(MOC_FECHA) AS DESDE ,MAX(MOC_FECHA) AS HASTA,SUM(MOC_MONTO) AS CCD_MONTO,COUNT(*) AS CUANTOS",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(oDp:aLine)

     cWhere:="MOC_ORIGEN"+GetWhere("=",cCodigo)+" AND MOC_TIPO"+GetWhere("=",oDp:aLine[2])
     oDp:dFchIniDoc:=oDp:aLine[3]
     oDp:dFchFinDoc:=oDp:aLine[4]
     oCbte:ListBrw(cWhere,cList)

  ENDIF

RETURN .T.



FUNCTION POSTGRABAR()
  LOCAL cWhere

  cWhere:="MOC_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC)+" AND "+;
          "MOC_NUMCBT"+GetWhere("=",oCbte:CBT_NUMERO)+" AND "+;
          "MOC_FECHA" +GetWhere("=",oCbte:CBT_FECHA )


  IF oCbte:nOption=3 .AND.(oCbte:CBT_NUMERO<>oCbte:CBT_NUMERO_ .OR. oCbte:CBT_FECHA<>oCbte:CBT_FECHA_)

     cWhere:="MOC_CODSUC"+GetWhere("=",oCbte:CBT_CODSUC_)+" AND "+;
             "MOC_NUMCBT"+GetWhere("=",oCbte:CBT_NUMERO_)+" AND "+;
             "MOC_FECHA" +GetWhere("=",oCbte:CBT_FECHA_ )


     SQLUPDATE("DPASIENTOS",{"MOC_NUMCBT","MOC_FECHA"},{oCbte:CBT_NUMERO,oCbte:CBT_FECHA},cWhere)

  ENDIF

  // Asigna Centro de Costo Unico
  IF oCbte:CBT_CENGEN
     // Solo Afecta los asientos Contables
     SQLUPDATE("DPASIENTOS","MOC_CENCOS",oCbte:CBT_CENCOS,cWhere+" AND MOC_ORIGEN"+GetWhere("=","CON"))
//? oDp:cSql
  ENDIF

RETURN NIL


FUNCTION GRID_BEFORDEL()

  oGrid:nArrayAt_:=oGrid:oBrw:nArrayAt

RETURN .T.

FUNCTION GRID_AFTERDEL()

//  oGrid:oBrw:nArrayAt:=oGrid:nArrayAt_
//  oGrid:oBrw:Refresh(.F.)

RETURN .T.

FUNCTION VERPAGO()
   LOCAL cRecord
   LOCAL lView:=.T.,cCenCos:=NIL
   LOCAL lAuto,cTipPag,cCodSuc,cCodPro
 
   IF oGrid:MOC_ORIGEN="COM" .AND. !Empty(oGrid:MOC_DOCPAG)
      cRecord:="PAG_NUMERO"+GetWhere("=",oGrid:MOC_DOCPAG)
      RETURN EJECUTAR("DPCBTEPAGOX",lAuto,cTipPag,cCodSuc,cCodPro,cRecord,lView,cCenCos)
   ENDIF

   IF oGrid:MOC_ORIGEN="VTA" .AND. !Empty(oGrid:MOC_DOCPAG)
      cRecord:="REC_NUMERO"+GetWhere("=",oGrid:MOC_DOCPAG)
      RETURN EJECUTAR("DPRECIBOSCLIX",lAuto,cTipPag,cCodSuc,cCodPro,cRecord,lView,cCenCos)
   ENDIF


RETURN .T.

FUNCTION DUPLICAR()
RETURN EJECUTAR("DPDCBTE",oCbte:CBT_NUMERO,oCbte:CBT_FECHA,oCbte:CBT_ACTUAL,oCbte:CBT_COMEN1,oCbte:CBT_COMEN2)

FUNCTION FIJOS()
RETURN EJECUTAR("DPCBTEFIJO",oCbte:CBT_ACTUAL,oCbte:CBT_NUMERO,oCbte:CBT_FECHA,oCbte:CBT_COMEN1,oCbte:CBT_COMEN2)

FUNCTION GRID_VIEW()
RETURN .T.

FUNCTION VIEW()
RETURN EJECUTAR("DPCBTEFRMORG",oCbte:CBT_CODSUC,oCbte:CBT_NUMERO,oCbte:CBT_FECHA,oCbte:CBT_ACTUAL)

// Pre-Grabar
FUNCTION PREGRABAR(oForm,lSave)
RETURN .T.

/*
// Menú del Auxiliar 
*/
FUNCTION MNUAUXORIGEN()

  IF oGrid:MOC_ORIGEN="VTA" .AND. !Empty(oGrid:MOC_CODAUX)
     EJECUTAR("DPCLIENTES",0,oGrid:MOC_CODAUX)
  ENDIF

  IF oGrid:MOC_ORIGEN="COM" .AND. !Empty(oGrid:MOC_CODAUX)
     EJECUTAR("DPPROVEEDOR",0,oGrid:MOC_CODAUX)
  ENDIF

RETURN .T.

/*
// VALIDAR CENTROS DE COSTOS
*/
FUNCTION VALCENCOS()

   IF ValType(oCbte:oCEN_DESCRI)="O"
     oCbte:oCEN_DESCRI:Refresh(.T.)
   ENDIF	

   IF !ISSQLFIND("DPCENCOS","CEN_CODIGO"+GetWhere("=",oCbte:CBT_CENCOS))
      oCbte:oCBT_CENCOS:KeyBoard(VK_F6)
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION VMOC_CODPRY(cCodCen)

  IF EMPTY(oGrid:MOC_CODPRY)
     RETURN .T.
  ENDIF

  IF !ISMYSQLGET("DPPROYECTOS","PRY_CODIGO",oGrid:MOC_CODPRY)
     RETURN .F.
  ENDIF

RETURN .T.

// EOF
