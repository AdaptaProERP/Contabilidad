// Programa   : BRLIBCOMEDIT
// Fecha/Hora : 18/11/2022 22:43:00
// Prop�sito  : "Libro de Compras editable"
// Creado Por : Autom�ticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicaci�n : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,dFchDec,lView,cCodCaj,cCodBco,cNumRei,cCodCli,cId,cCenCos,aTipDoc,lCondom,lCtaEgr,lVenta)
   LOCAL aData,aFechas,cFileMem:="USER\BRLIBCOMEDIT.MEM",V_nPeriodo:=1,cCodPar,dFchPag:=CTOD("")
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL oDb    :=OpenOdbc(oDp:cDsnData)
   LOCAL lConectar:=.F.,aFields:={},I
   LOCAL aIva   :={} // ATABLE("SELECT TIP_CODIGO FROM DPIVATIP WHERE TIP_ACTIVO=1 AND TIP_COMPRA=1")
   LOCAL aCodCta:={}
   LOCAL cTable,cField,dFchMax,cInner,aPorIva:={}  
   
   // cuenta de Egreso para condominios

   oDp:cRunServer:=NIL

   IF Type("oLIBCOMEDIT")="O" .AND. oLIBCOMEDIT:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oLIBCOMEDIT,GetScript())
   ENDIF

   DEFAULT lVenta:=.F.

   IF COUNT("DPIVATIP","TIP_ACTIVO=1")=0
      SQLUPDATE("DPIVATIP",{"TIP_ACTIVO","TIP_VENTA","TIP_COMPRA"},{.T.,.T.,.T.},"TIP_CODIGO"+GetWhere("=","GN"))
   ENDIF

   dFchMax:=SQLGETMAX("dpivatabc","CTI_FECHA")
   cInner:=[ INNER JOIN dpivatabc ON CTI_TIPO=TIP_CODIGO WHERE CTI_FECHA]+GetWhere("=",dFchMax)

   IF lVenta
     aIva   :=ATABLE("SELECT TIP_CODIGO FROM DPIVATIP "+cInner+" AND TIP_ACTIVO=1 AND TIP_VENTA=1 ORDER BY CTI_VENTA")
     aPorIva:=ATABLE("SELECT CTI_VENTA  FROM DPIVATIP "+cInner+" AND TIP_ACTIVO=1 AND TIP_VENTA=1 ORDER BY CTI_VENTA")
   ELSE
     aIva   :=ATABLE("SELECT TIP_CODIGO FROM DPIVATIP "+cInner+" AND TIP_ACTIVO=1 AND TIP_COMPRA=1 ORDER BY CTI_COMPRA")
     aPorIva:=ATABLE("SELECT CTI_COMPRA FROM DPIVATIP "+cInner+" AND TIP_ACTIVO=1 AND TIP_COMPRA=1 ORDER BY CTI_COMPRA")
   ENDIF

// ViewArray(aPorIva)


   IF Empty(aIva)
      MsgMemo("Debes Activar las Al�cuotas de IVA")
      DPLBX("DPIVATIP.LBX")
      RETURN NIL
   ENDIF

   IF Empty(dFchMax) 
      MsgMemo("Debes Introducir los % de Al�cuotas de IVA")
      EJECUTAR("DPIVATAB")
      RETURN NIL
   ENDIF

   DEFAULT oDp:lCondominio:=.F.,;
           cNumRei:=""


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF

   // Agrega las columnas Base Necesarias, mas una columna TOTAL IVA
   aFields:={}
   cTable :=IF(!lVenta,"DPLIBCOMPRASDET","DPLIBVENTASDET")

   FOR I=1 TO LEN(aIva)

      cField:="LBC_BAS"+aIva[I]

      IF !EJECUTAR("ISFIELDMYSQL",oDb,cTable,cField)
         AADD(aFields,cField)
      ENDIF

   NEXT I

   IF !Empty(aFields)

      FOR I=1 TO LEN(aFields)
        EJECUTAR("DPCAMPOSADD",cTable,aFields[I],"N",19,2,"Base "+aFields[I])
      NEXT I

      // ViewArray(aFields)
      DpMsgClose()

      // Agrega los Campos
   ENDIF

   aFields:={}

   IF Empty(cNumRei)

     IF lVenta
       cTitle :="Registro de Documentos de Ventas [Editable]" +IF(Empty(cTitle),"",cTitle)
       lCondom:=.F.
       // lCtaEgr:=.F. // las ventas tambien puede ser cta egreso
     ELSE
       cTitle :="Registro Compras para Proveedores Ocasionales en el Libro de Compras [Editable]" +IF(Empty(cTitle),"",cTitle)
     ENDIF

   ENDIF

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD(""),;
           lView   :=.F.   

   DEFAULT lCtaEgr:=.F.,;
           lCondom:=.T.

   // Condominio 
   IF lCondom .AND. !lVenta

      IF !oDp:IsDef("lCndCtaEgr")
         EJECUTAR("CNDCONFIGLOAD")
      ENDIF

      lCtaEgr:=oDp:lCndCtaEgr // Cuentas de Egreso

      cTitle:="Registro de Compras y Gastos " 

   ENDIF

   DEFAULT dFchDec :=FCHFINMES(oDp:dFecha)

   EJECUTAR("IVALOAD",dFchDec)

   IF LEFT(oDp:cTipCon,1)="O"

     DEFAULT cWhere:="LBC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                     "YEAR(LBC_FCHDEC)"+GetWhere("=",YEAR(dFchDec))+" AND MONTH(LBC_FCHDEC)"+GetWhere("=",MONTH(dFchDec))

   ELSE

     DEFAULT cWhere:="LBC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                     "LBC_FCHDEC"+GetWhere("=",dFchDec)


   ENDIF

   IF !Empty(cCenCos) .AND. !"CEN_CENCOS"$cWhere

      cWhere:=cWhere+" AND LBC_CENCOS"+GetWhere("=",cCenCos)

   ENDIF

   dFchPag:=SQLGET("DPDOCPROPROG","PLP_FECHA","PLP_TIPDOC"+GetWhere("=","F30")+" AND PLP_FCHDEC"+GetWhere("=",dFchDec))

   // Obtiene el C�digo del Par�metro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF nPeriodo=10
      dDesde :=V_dDesde
      dHasta :=V_dHasta
   ELSE
      aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
      dDesde :=aFechas[1]
      dHasta :=aFechas[2]
   ENDIF

   oDp:nValCam :=EJECUTAR("DPGETVALCAM",oDp:cMonedaExt,oDp:dFecha) // nValCam

   aData  :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL,lCondom,lCtaEgr,lVenta,aIva)
   aFields:=ACLONE(oDp:aFields)

   IF Empty(aTipDoc) .AND. lCondom .AND. !lVenta
     aTipDoc:=ATABLE("SELECT TDC_TIPO FROM DPTIPDOCPRO WHERE TDC_GASCND=1 AND TDC_ACTIVO=1")
   ENDIF

   IF Empty(aTipDoc) .AND. !lVenta
     aTipDoc:=ATABLE("SELECT TDC_TIPO FROM DPTIPDOCPRO WHERE TDC_LBCCDC=1 AND TDC_ACTIVO=1")
   ENDIF

   IF Empty(aTipDoc) .AND. !lVenta
     aTipDoc:={"FAC","DEB","CRE","OPA","NRC","GAS"}
   ENDIF

   IF Empty(aTipDoc) .AND. lVenta
     aTipDoc:={"FAV","FAM","DEB","CRE"}
   ENDIF

   IF lVenta
 
      // Cliente Vacio
      IF !ISSQLFIND("DPCLIENTES","CLI_RIF"+GetWhere("=",SPACE(10)))

         EJECUTAR("CREATERECORD","DPCLIENTES",{"CLI_CODIGO","CLI_RIF"           ,"CLI_NOMBRE","CLI_RETIVA"          ,"CLI_ESTADO"},;
                                              {SPACE(10)   ,SPACE(10)           ,SPACE(10)   ,0                     ,"Activo"    },;
                                               NIL,.T.,"CLI_RIF"+GetWhere("=",SPACE(10)))
      ENDIF

      aCodCta:=ASQL([ SELECT TDC_TIPO,CIC_CUENTA,CTA_DESCRI,TDC_CXC,TDC_CLRGRA,TDC_DESCRI,"" AS TDC_NUMDOC,TDC_LIBVTA ]+;
                    [ FROM DPTIPDOCCLI ]+;
                    [ LEFT JOIN DPTIPDOCCLI_CTA ON CIC_CTAMOD]+GetWhere("=",oDp:cCtaMod)+[ AND CIC_CODIGO=TDC_TIPO ]+;
                    [ LEFT JOIN DPCTA           ON CIC_CTAMOD=CTA_CODMOD AND CIC_CUENTA=CTA_CODIGO ]+;
                    [ WHERE ]+GetWhereOr("TDC_TIPO",aTipDoc))

//                                nCxC:=IF(a[4]="D",+1,nCxC),;
//                                nCxC:=IF(a[4]="C",-1,nCxC),;
//                                aCodCta[n,4]:=nCxC   


      AEVAL(aCodCta,{|a,n|aCodCta[n,4]:=EJECUTAR("DPTIPCXP",a[1]),;
                          aCodCta[n,7]:=EJECUTAR("DPDOCCLIGETNUM",a[1])})

   ELSE

      // desde importar desde excel
      EJECUTAR("DPLIBCOMPRASDETCTAS") // Asigna las cuentas contables desde importar datos desde excel

      IF !ISSQLFIND("DPPROVEEDOR","PRO_RIF"+GetWhere("=",SPACE(10)))

         EJECUTAR("CREATERECORD","DPPROVEEDOR",{"PRO_CODIGO","PRO_RIF"           ,"PRO_NOMBRE","PRO_RETIVA"          ,"PRO_ESTADO"},;
                                               {SPACE(10)   ,SPACE(10)           ,SPACE(10)   ,0                     ,"Activo"    },;
                                               NIL,.T.,"PRO_RIF"+GetWhere("=",SPACE(10)))
      ENDIF

      aCodCta:=ASQL([ SELECT TDC_TIPO,CIC_CUENTA,CTA_DESCRI,TDC_CXP,TDC_CLRGRA,TDC_DESCRI,"" AS TDC_NUMDOC,TDC_LIBCOM ]+;
                    [ FROM DPTIPDOCPRO ]+;
                    [ LEFT JOIN DPTIPDOCPRO_CTA ON CIC_CTAMOD]+GetWhere("=",oDp:cCtaMod)+[ AND CIC_CODIGO=TDC_TIPO ]+;
                    [ LEFT JOIN DPCTA           ON CIC_CTAMOD=CTA_CODMOD AND CIC_CUENTA=CTA_CODIGO ]+;
                    [ WHERE ]+GetWhereOr("TDC_TIPO",aTipDoc))

      AEVAL(aCodCta,{|a,n| aCodCta[n,4]:=EJECUTAR("DPTIPCXP",a[1]),;
                           aCodCta[n,7]:=EJECUTAR("DPDOCPROGETNUM",a[1])})

/*
      AEVAL(aCodCta,{|a,n,nCxP| nCxP:=0,;
                                nCxP:=IF(a[4]="D",+1,nCxP),;
                                nCxP:=IF(a[4]="C",-1,nCxP),;
                                aCodCta[n,4]:=EJECUTAR("DPTIPCXP",a[4]),;
                                aCodCta[n,7]:=EJECUTAR("DPDOCPROGETNUM",a[1])})
*/



   ENDIF

   AEVAL(aCodCta,{|a,n| aCodCta[n,1]:=ALLTRIM(a[1]) })

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Informaci�n no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere,cNumRei)

   oDp:oFrm:=oLIBCOMEDIT

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_,cNumRei)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData),I,cMacro
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oLIBCOMEDIT","BRLIBCOMEDITX.EDT")

   oLIBCOMEDIT:Windows(0,0,aCoors[3]-160,MIN(4318,aCoors[4]-10),.T.) // Maximizado

   oLIBCOMEDIT:cCodSuc    :=cCodSuc
   oLIBCOMEDIT:lMsgBar    :=.F.
   oLIBCOMEDIT:cPeriodo   :=aPeriodos[nPeriodo]
   oLIBCOMEDIT:cCodSuc    :=cCodSuc
   oLIBCOMEDIT:nPeriodo   :=nPeriodo
   oLIBCOMEDIT:cNombre    :=""
   oLIBCOMEDIT:dDesde     :=dDesde
   oLIBCOMEDIT:cServer    :=cServer
   oLIBCOMEDIT:dHasta     :=dHasta
   oLIBCOMEDIT:cWhere     :=cWhere
   oLIBCOMEDIT:cWhere_    :=cWhere_
   oLIBCOMEDIT:cWhereQry  :=""
   oLIBCOMEDIT:cSql       :=oDp:cSql
   oLIBCOMEDIT:oWhere     :=TWHERE():New(oLIBCOMEDIT)
   oLIBCOMEDIT:cCodPar    :=cCodPar // C�digo del Par�metro
   oLIBCOMEDIT:lWhen      :=.T.
   oLIBCOMEDIT:cTextTit   :="" // Texto del Titulo Heredado
   oLIBCOMEDIT:oDb        :=oDp:oDb
   oLIBCOMEDIT:cBrwCod    :="LIBCOMEDIT"
   oLIBCOMEDIT:lTmdi      :=.T.
   oLIBCOMEDIT:aHead      :={}
   oLIBCOMEDIT:lBarDef    :=.T. // Activar Modo Dise�o.
   oLIBCOMEDIT:dFchDec    :=dFchDec
   oLIBCOMEDIT:dFchPag    :=dFchPag
   oLIBCOMEDIT:aFields    :=ACLONE(aFields)
   oLIBCOMEDIT:lSave      :=.F.
   oLIBCOMEDIT:aTipDoc    :=ACLONE(aTipDoc)
   oLIBCOMEDIT:aIva       :=ACLONE(aIva)
   oLIBCOMEDIT:aPorIva    :=ACLONE(aPorIva)
   oLIBCOMEDIT:cCodSuc    :=oDp:cSucursal
   oLIBCOMEDIT:cCodCaj    :=cCodCaj
   oLIBCOMEDIT:cCodBco    :=cCodBco
   oLIBCOMEDIT:cNumRei    :=cNumRei
   oLIBCOMEDIT:lReintegro :=!Empty(cNumRei)
   oLIBCOMEDIT:cCodCli    :=cCodCli   // Cliente en el caso de condominio
   oLIBCOMEDIT:cCodPro    :=SPACE(10) // C�digo del proveedor
   oLIBCOMEDIT:cNomPro    :=SPACE(10) // Nombre del Proveedor
   oLIBCOMEDIT:cCenCos    :=cCenCos
   oLIBCOMEDIT:nCxP       :=0 
   oLIBCOMEDIT:oFrmRefresh:=NIL
   oLIBCOMEDIT:lCondom    :=lCondom  // Condominios, debe incluir la planificacion realizada
   oLIBCOMEDIT:lCtaEgr    :=lCtaEgr
   oLIBCOMEDIT:lVenta     :=lVenta
   oLIBCOMEDIT:cWherePro  :=" (1=1) "
   oLIBCOMEDIT:cTable     :=IF(!lVenta,"DPLIBCOMPRASDET","DPLIBVENTASDET")
   oLIBCOMEDIT:aCodCta    :=ACLONE(aCodCta)
   oLIBCOMEDIT:cTipo      :=IF(oLIBCOMEDIT:lCondom,"Prestador de Servicios","Ocasional")
   oLIBCOMEDIT:cReside    :="" // Reside si o no para codigo de retencion
   oLIBCOMEDIT:cWhereCta  :="" 
   oLIBCOMEDIT:aValPorIva :={}

   AEVAL(oLIBCOMEDIT:aPorIva,{|a,n| AADD(oLIBCOMEDIT:aValPorIva,VAL(a))})

   IF !oLIBCOMEDIT:lVenta
     oLIBCOMEDIT:cWherePro  :=" NOT (LEFT(PRO_RIF,1)"+GetWhere("=","G")+" OR LEFT(PRO_RIF,1)"+GetWhere("=","T")+")"
   ENDIF


   // Condominios Cliente y Propiedad. 
   oLIBCOMEDIT:cCodCli:=cCodCli
   oLIBCOMEDIT:cId    :=cId // DPCLIENTESCLI=ITEM

   oLIBCOMEDIT:COL_LBC_CTAEGR:=0 // Cuenta Egreso
   oLIBCOMEDIT:cItemChange:=""
   oLIBCOMEDIT:LBC_FCHDEC :=dFchDec

   // Retenciones de ISLR
   oLIBCOMEDIT:nLenRet    :=SQLGET("DPTIPDOCPRO","TDC_LEN,TDC_ZERO","TDC_TIPO"+GetWhere("=","RET"))
   oLIBCOMEDIT:lZeroRet   :=DPSQLROW(2)
   oLIBCOMEDIT:cNumRet    :=IF(lVenta,EJECUTAR("DPDOCCLIGETNUM","RET"),EJECUTAR("DPDOCPROGETNUM","RET"))

   //Retenciones de IVA
   oLIBCOMEDIT:nLenRti    :=SQLGET("DPTIPDOCPRO","TDC_LEN,TDC_ZERO","TDC_TIPO"+GetWhere("=","RTI"))
   oLIBCOMEDIT:lZeroRti   :=DPSQLROW(2)
   oLIBCOMEDIT:cNumRti    :=IF(lVenta,EJECUTAR("DPDOCCLIGETNUM","RTI"),EJECUTAR("DPDOCPROGETNUM","RTI")) 

   // Guarda los par�metros del Browse cuando cierra la ventana
   oLIBCOMEDIT:bValid   :={|| EJECUTAR("BRWSAVEPAR",oLIBCOMEDIT)}

   oLIBCOMEDIT:lBtnRun     :=.F.
   oLIBCOMEDIT:lBtnMenuBrw :=.F.
   oLIBCOMEDIT:lBtnSave    :=.F.
   oLIBCOMEDIT:lBtnCrystal :=.F.
   oLIBCOMEDIT:lBtnRefresh :=.F.
   oLIBCOMEDIT:lBtnHtml    :=.T.
   oLIBCOMEDIT:lBtnExcel   :=.T.
   oLIBCOMEDIT:lBtnPreview :=.T.
   oLIBCOMEDIT:lBtnQuery   :=.F.
   oLIBCOMEDIT:lBtnOptions :=.T.
   oLIBCOMEDIT:lBtnPageDown:=.T.
   oLIBCOMEDIT:lBtnPageUp  :=.T.
   oLIBCOMEDIT:lBtnFilters :=.T.
   oLIBCOMEDIT:lBtnFind    :=.T.
   oLIBCOMEDIT:lBtnColor   :=.T.

   oLIBCOMEDIT:nClrPane1:=16775408
   oLIBCOMEDIT:nClrPane2:=16771797

   oLIBCOMEDIT:nClrText :=4144959
   oLIBCOMEDIT:nClrText1:=4227072
   oLIBCOMEDIT:nClrText2:=11162880
   oLIBCOMEDIT:nClrText3:=0

   oLIBCOMEDIT:oBrw:=TXBrowse():New( IF(oLIBCOMEDIT:lTmdi,oLIBCOMEDIT:oWnd,oLIBCOMEDIT:oDlg ))
   oLIBCOMEDIT:oBrw:SetArray( aData, .F. )
   oLIBCOMEDIT:oBrw:SetFont(oFont)

   oLIBCOMEDIT:oBrw:lFooter     := .T.
   oLIBCOMEDIT:oBrw:lHScroll    := .T.
   oLIBCOMEDIT:oBrw:nHeaderLines:= 3
   oLIBCOMEDIT:oBrw:nDataLines  := 1
   oLIBCOMEDIT:oBrw:nFooterLines:= 1
   oLIBCOMEDIT:oBrw:nFreeze     :=4+1

   oLIBCOMEDIT:aData            :=ACLONE(aData)
   oLIBCOMEDIT:aFields          :=ACLONE(aFields)


   oLIBCOMEDIT:COL_LBC_CREFIS   :=0
   oLIBCOMEDIT:COL_LBC_NODEDU   :=0
   oLIBCOMEDIT:COL_TDC_LIBVTA   :=0
   oLIBCOMEDIT:COL_TDC_LIBCOM   :=0

   AEVAL(oLIBCOMEDIT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   // Crear nombre de las Columnas
   oLIBCOMEDIT:LBC_PORRTI:=0 // % retencion de IVA,  Caso que contribuyente Ordinario
   oLIBCOMEDIT:COL_LBC_PORRTI:=0
   AEVAL(oLIBCOMEDIT:aFields,{|a,n| oLIBCOMEDIT:SET("COL_"+a[1],n)})

   IF Empty(aData[1,1])
      aData[1,oLIBCOMEDIT:COL_LBC_NUMPAR]:=STRZERO(1,5)
      aData[1,oLIBCOMEDIT:COL_LBC_ITEM]  :=STRZERO(1,5)
   ENDIF

   IF oLIBCOMEDIT:lCtaEgr
      oLIBCOMEDIT:COL_LBC_CODCTA:=oLIBCOMEDIT:COL_LBC_CTAEGR
   ENDIF

   IF !oLIBCOMEDIT:lVenta
      oLIBCOMEDIT:COL_LBC_CXC:=oLIBCOMEDIT:COL_LBC_CXP
   ENDIF

   AEVAL(aData,{|a,n|aData[n,oLIBCOMEDIT:COL_LBC_COMORG]:=ALLTRIM(SAYOPTIONS(oLIBCOMEDIT:cTable,"LBC_COMORG",a[oLIBCOMEDIT:COL_LBC_COMORG]))})


   // Campo: LBC_TIPDOC
   oCol:=oLIBCOMEDIT:oBrw:aCols[1]
   oCol:cHeader       :='Tipo'+CRLF+'Doc.'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
   oCol:nWidth        := 40
   oCol:nEditType     :=IIF( lView, 0, 1)
   oCol:bOnPostEdit   :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTTIPDOC(oCol,uValue,1,nKey)}
   oCol:aEditListTxt  :=oLIBCOMEDIT:aTipDoc
   oCol:aEditListBound:=oLIBCOMEDIT:aTipDoc
   oCol:nEditType     :=EDIT_LISTBOX

   oCol:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oLIBCOMEDIT:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=aLine[oLIBCOMEDIT:COL_TDC_CLRGRA],;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oLIBCOMEDIT:nClrPane1, oLIBCOMEDIT:nClrPane2 ) } }



   // Campo: LBC_DIA
   oCol:=oLIBCOMEDIT:oBrw:aCols[2]
   oCol:cHeader       :='D�a'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
   oCol:nWidth        := 40
   oCol:nEditType     :=IIF( lView, 0, 1)
   oCol:bOnPostEdit   :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTDIA(oCol,uValue,2,nKey)}
   oCol:cEditPicture  :='99'
   oCol:bStrData      :={|nDia,oCol|nDia:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,2],;
                                    oCol:= oLIBCOMEDIT:oBrw:aCols[2],;
                                    FDP(nDia,oCol:cEditPicture)}
// IF .T.

   // Campo: LBC_FECHA
   oCol:=oLIBCOMEDIT:oBrw:aCols[3]
   oCol:cHeader      :='Fecha'+CRLF+'Emisi�n'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
   oCol:nWidth       := 72
   oCol:nEditType    :=IIF( lView, 0, 1)
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFECHA(oCol,uValue,3,nKey)}
   oCol:nEditType    :=EDIT_GET_BUTTON
   oCol:bEditBlock   :={||EJECUTAR("BRWEDITCALENDARIO",oLIBCOMEDIT:oBrw)}

  // Campo: LBC_RIF
  oCol:=oLIBCOMEDIT:oBrw:aCols[4]
  oCol:cHeader      :='RIF'+CRLF+IF(lVenta,"Cliente","Proveedor")
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oLIBCOMEDIT:EDITRIF(4,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALRIF(oCol,uValue,4,nKey)}
  oCol:lButton      :=.F.


  // Campo: PRO_NOMBRE
  oCol:=oLIBCOMEDIT:oBrw:aCols[5]
  oCol:cHeader      :='Nombre o Razon Social'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 220
  oCol:nEditType    :=IIF( lView, 0, 1)

  IF lVenta

    oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALRIFNOMBRE(oCol,uValue,oLIBCOMEDIT:COL_CLI_NOMBRE,nKey)}

    oCol:bStrData     :={|cData,oCol|cData:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_CLI_NOMBRE],;
                                     oCol := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_CLI_NOMBRE],;
                                     cData}
  ELSE

    oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALRIFNOMBRE(oCol,uValue,oLIBCOMEDIT:COL_PRO_NOMBRE,nKey)}

    oCol:bStrData     :={|cData,oCol|cData:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_PRO_NOMBRE],;
                                     oCol:= oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_PRO_NOMBRE],;
                                     cData}
  ENDIF

  IF !oLIBCOMEDIT:lCtaEgr

   // Campo: LBC_CODCTA
   oCol:=oLIBCOMEDIT:oBrw:aCols[6]
   oCol:cHeader      :='Cuenta'+CRLF+'Contable'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
   oCol:nWidth       := 100
   oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
   oCol:bEditBlock   :={||oLIBCOMEDIT:EDITCTA(6,.F.)}
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALCTA(oCol,uValue,6,nKey)}
   oCol:lButton      :=.F.

   // Campo: CTA_DESCRI
   oCol:=oLIBCOMEDIT:oBrw:aCols[7]
   oCol:cHeader      :='Nombre'+CRLF+'Cuenta'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
   oCol:nWidth       := 180

  ELSE

   // Campo: LBC_CTAEGR
   oCol:=oLIBCOMEDIT:oBrw:aCols[6]
   oCol:cHeader      :='Cuenta'+CRLF+'Egreso'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
   oCol:nWidth       := 100
   oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
   oCol:bEditBlock   :={||oLIBCOMEDIT:EDITCTA(6,.F.)}
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALCTA(oCol,uValue,6,nKey)}
   oCol:lButton      :=.F.

   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALCTAEGR(oCol,uValue,6,nKey)}

   // Campo: CTA_DESCRI
   oCol:=oLIBCOMEDIT:oBrw:aCols[7]
   oCol:cHeader      :='Descripci�n'+CRLF+'De la Cuenta'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
   oCol:nWidth       := 200
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALNOMBREEGR(oCol,uValue,7,nKey,NIL,.T.)}


  ENDIF

  // Campo: LBC_DESCRI
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_DESCRI]
  oCol:cHeader      :='Descripci�n'+CRLF+"del Asiento"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 220
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_DESCRI,nKey,NIL,.T.)}

  // Campo: LBC_NUMFAC
  oCol:=oLIBCOMEDIT:oBrw:aCols[9]
  oCol:cHeader      :='N�mero'+CRLF+'Doc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALNUMFAC(oCol,uValue,9,nKey)}

  // Campo: LBC_NUMFIS
  oCol:=oLIBCOMEDIT:oBrw:aCols[10]
  oCol:cHeader      :='N�mero'+CRLF+'Fiscal'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,10,nKey,NIL,.T.)}

  // Campo: LBC_FACAFE
  oCol:=oLIBCOMEDIT:oBrw:aCols[11]
  oCol:cHeader      :='Factura'+CRLF+'Afectada'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nEditType    :=0 // Solo Activa si es DEBITO O CREDITO IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,11,nKey)}

  /*
  // 8/10/2024 Ahora columnas din�micas
  */
  FOR I=1 TO LEN(oLIBCOMEDIT:aPorIva)

    oCol:=oLIBCOMEDIT:oBrw:aCols[11+I]
    oCol:cEditPicture :='9,999,999,999,999,999.99'

    IF VAL(aPorIva[I])=0
      oCol:cHeader      :="EXENTO"
    ELSE
      oCol:cHeader      :="BASE "+aPorIva[i]+"%"
    ENDIF

    cMacro:="{|nMonto|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,"+LSTR(I+11)+"],FDP(nMonto,'999,999,999,999.99')}"

    oCol:bStrData:=BLOQUECOD(cMacro)

    // Se puede Modificar el Precio de Venta
    oCol:nEditType:=1

    cMacro:="{|oCol,uValue|oLIBCOMEDIT:SETMTOBAS(oCol,uValue,"+LSTR(I+11)+","+LSTR(I)+")}"
    oCol:bOnPostEdit  :=BloqueCod(cMacro)

    oCol:cFooter      :=FDP(aTotal[I+11],oCol:cEditPicture)


  NEXT I

// 08/10/2024 Reemplaza las columnas definibles

/*
IF .F.

  // Campo: LBC_MTOBAS
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOBAS]
  oCol:cHeader      :='Base'+CRLF+'Imponible'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOBAS],;
                                    oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOBAS],;
                                    FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oLIBCOMEDIT:COL_LBC_MTOBAS],oCol:cEditPicture)
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALLBCMTOBAS(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTOBAS,nKey)}


  // Campo: LBC_MTOEXE
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOEXE]
  oCol:cHeader      :='Monto'+CRLF+'Exento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOEXE],;
                                    oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOEXE],;
                                    FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oLIBCOMEDIT:COL_LBC_MTOEXE],oCol:cEditPicture)
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALLBCMTOEXE(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTOEXE,nKey)}


  // Campo: LBC_TIPIVA
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_TIPIVA]
  oCol:cHeader       :='IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth        := 72
  oCol:nEditType     :=IIF( lView, 0, 1)
  oCol:bOnPostEdit   :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTTIPIVA(oCol,uValue,oLIBCOMEDIT:COL_LBC_TIPIVA,nKey)}
  oCol:aEditListTxt  :=oLIBCOMEDIT:aIva
  oCol:aEditListBound:=oLIBCOMEDIT:aIva
  oCol:nEditType     :=EDIT_LISTBOX

  // Campo: LBC_PORIVA
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_PORIVA]
  oCol:cHeader      :='%'+CRLF+'IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_PORIVA,nKey)}
  oCol:cEditPicture :='99.99'
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 

  oCol:bStrData:={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_PORIVA],;
                               oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_PORIVA],;
                               FDP(nMonto,oCol:cEditPicture)}

ENDIF
*/

  // Campo: LBC_MTOIVA
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOIVA]
  oCol:cHeader      :='Monto'+CRLF+'IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTOIVA,nKey)}
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOIVA],;
                                    oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOIVA],;
                                    FDP(nMonto,oCol:cEditPicture)}

  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cFooter      :=FDP(aTotal[oLIBCOMEDIT:COL_LBC_MTOIVA],oCol:cEditPicture)

  IF oLIBCOMEDIT:COL_LBC_CREFIS>0
     oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_CREFIS]
     oCol:cHeader      :='Sin derecho'+CRLF+'Cr�dito'+CRLF+"Fiscal"
     oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
     oCol:nWidth       := 70
     oCol:AddBmpFile("BITMAPS\checkverde.bmp")
     oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
     oCol:bBmpData    := { |oBrw|oBrw:=oLIBCOMEDIT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CREFIS],1,2) }
     oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
     oCol:bStrData    :={||""}
     oCol:bLDClickData:={||EJECUTAR("BRLIBCOM_LBCCREFIS",oLIBCOMEDIT,oLIBCOMEDIT:COL_LBC_CREFIS)}

  ENDIF

  IF oLIBCOMEDIT:COL_LBC_NODEDU>0 
     oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_NODEDU]
     oCol:cHeader      :='No Dedu-'+CRLF+"cible"
     oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
     oCol:nWidth       := 70
     oCol:AddBmpFile("BITMAPS\checkverde.bmp")
     oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
     oCol:bBmpData    := { |oBrw|oBrw:=oLIBCOMEDIT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_NODEDU],1,2) }
     oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
     oCol:bStrData    :={||""}
     oCol:bLDClickData:={||EJECUTAR("BRLIBCOM_LBCNODEDU",oLIBCOMEDIT,oLIBCOMEDIT:COL_LBC_NODEDU)}

  ENDIF



 // Campo: LBC_MTONET
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTONET]
  oCol:cHeader      :='Monto'+CRLF+'Neto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
//oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTONET,nKey)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:CALBASEIMP(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTONET,nKey)}

  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:cFooter      :=FDP(aTotal[oLIBCOMEDIT:COL_LBC_MTONET],oCol:cEditPicture)

  oCol:bStrData     :={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTONET],;
                                    oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTONET],;
                                    FDP(nMonto,oCol:cEditPicture)}

  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 

 // Campo: LBC_PORRTI
  IF oLIBCOMEDIT:COL_LBC_PORRTI>0

    oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_PORRTI]
    oCol:cHeader      :="%"+CRLF+"RET"+CRLF+"IVA"+CRLF+"IVA"
    oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
    oCol:nWidth       := 40
    oCol:nEditType    :=IIF( lView, 0, 1)
    oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALPORRTI(oCol,uValue,oLIBCOMEDIT:COL_LBC_PORRTI,nKey)}
    oCol:cEditPicture :='9,999,999,999,999,999.99'

    // Campo: LBC_MTORTI
    oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTORTI]
    oCol:cHeader      :='Monto'+CRLF+'Retenci�n'+CRLF+"IVA"
    oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
    oCol:nWidth       := 136
    oCol:nDataStrAlign:= AL_RIGHT 
    oCol:nHeadStrAlign:= AL_RIGHT 
    oCol:nFootStrAlign:= AL_RIGHT 
    oCol:cEditPicture :='9,999,999,999,999,999.99'
    oCol:bStrData:={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTORTI],;
                              oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTORTI],;
                              FDP(nMonto,oCol:cEditPicture)}
    oCol:cFooter      :=FDP(aTotal[oLIBCOMEDIT:COL_LBC_MTORTI],oCol:cEditPicture)
    oCol:nEditType    :=IIF( lView, 0, 1)
    oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTORTI,nKey)}


    // Campo: LBC_NUMRTI
    oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_NUMRTI]
    oCol:cHeader      :='N�mero'+CRLF+'Retenci�n'+CRLF+"IVA"
    oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
    oCol:nWidth       := 80
    oCol:nEditType    :=IIF( lView, 0, 1)
    oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_NUMRTI,nKey)}

  ENDIF

  // Campo: LBC_CONISR
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_CONISR]
  oCol:cHeader      :='Con-'+CRLF+'cepto'+CRLF+"ISLR"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_CONISR,nKey)}
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oLIBCOMEDIT:EDITCONISLR(oLIBCOMEDIT:COL_LBC_CONISR,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALCONISLR(oCol,uValue,oLIBCOMEDIT:COL_LBC_CONISR,nKey)}
  oCol:lButton      :=.F.


 // Campo: LBC_PORISR
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_PORISR]
  oCol:cHeader      :="%"+CRLF+"RET"+CRLF+"ISR"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALPORISR(oCol,uValue,oLIBCOMEDIT:COL_LBC_PORISR,nKey)}
  oCol:cEditPicture :='9,999,999,999,999,999.99'

// ? oLIBCOMEDIT:COL_LBC_PORISR,"oLIBCOMEDIT:COL_LBC_PORISR"

  // Campo: LBC_MTOISR
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOISR]
  oCol:cHeader      :='Monto'+CRLF+'Retenci�n'+CRLF+"ISR"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOISR],;
                              oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOISR],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oLIBCOMEDIT:COL_LBC_MTOISR],oCol:cEditPicture)
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTOISR,nKey)}


  // Campo: LBC_NUMISR
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_NUMISR]
  oCol:cHeader      :='N�mero'+CRLF+'Retenci�n'+CRLF+"ISLR"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:VALNUMISR(oCol,uValue,oLIBCOMEDIT:COL_LBC_NUMRTI,nKey)}


  // Campo: LBC_COMORG
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_COMORG]
  oCol:cHeader      :='Nacional'+CRLF+IF(oLIBCOMEDIT:lVenta,"Exportaci�n",'Importado')
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 32
  oCol:bClrStd      := {|nClrText,uValue|uValue:=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_COMORG],;
                           nClrText:=COLOR_OPTIONS(oLIBCOMEDIT:cTable,"LBC_COMORG",uValue),;
                         {nClrText,iif( oLIBCOMEDIT:oBrw:nArrayAt%2=0, oLIBCOMEDIT:nClrPane1, oLIBCOMEDIT:nClrPane2 ) } } 
  oCol:aEditListTxt  :={"Nacional","Importada"}
  oCol:aEditListBound:={"Nacional","Importada"}
  oCol:nEditType     :=EDIT_LISTBOX
  oCol:bOnPostEdit   :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_COMORG,nKey,1)}


  // Campo: LBC_USOCON
  IF Empty(oLIBCOMEDIT:cCodCaj)

    oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_USOCON]
    oCol:cHeader       :='Contra-'+CRLF+'Partida'
    oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
    oCol:nWidth        := 80
    oCol:nEditType     :=IIF( lView, 0, 1)
    oCol:aEditListTxt  :={"Cuentas x Pagar","Caja","Caja Divisa","Banco","Banco Divisa"}
    oCol:aEditListBound:=oCol:aEditListTxt
    oCol:bOnPostEdit   :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_USOCON,nKey)}
    oCol:nEditType     :=EDIT_LISTBOX

  ELSE

    oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_USOCON]
    oCol:cHeader       :="Pago"
    oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
    oCol:nWidth        := 80
    oCol:nEditType     :=IIF( lView, 0, 1)
    oCol:aEditListTxt  :={"Caja","Banco","CXP"}
    oCol:aEditListBound:=oCol:aEditListTxt
    oCol:bOnPostEdit   :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_USOCON,nKey)}
    oCol:nEditType     :=EDIT_LISTBOX

 
  ENDIF

  // Campo: LBC_VALCAM Valor Cambiario
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_VALCAM]
  oCol:cHeader      :='Monto'+CRLF+'Valor'+CRLF+"Cambiario"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :=oDp:cPictValCam
  oCol:bStrData:={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_VALCAM],;
                              oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_VALCAM],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oLIBCOMEDIT:COL_LBC_VALCAM],oCol:cEditPicture)
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_VALCAM,nKey)}

  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_REGDOC]
  oCol:cHeader      := "Regis-"+CRLF+"trado"
  oCol:nWidth       := 40
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bBmpData    := { |oBrw|oBrw:=oLIBCOMEDIT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_REGDOC],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bStrData    :={||""}
//oCol:bLDClickData:={||oLIBCOMEDIT:DELASIENTOS()}

  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_ACTIVO]
  oCol:cHeader      := "Reg."+CRLF+"Activo"
  oCol:nWidth       := 40
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bBmpData    := { |oBrw|oBrw:=oLIBCOMEDIT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_ACTIVO],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bStrData    :={||""}
  oCol:bLDClickData:={||oLIBCOMEDIT:DELASIENTOS()}

  // Campo: LBC_NUMPAR
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_NUMPAR]
  oCol:cHeader      :='N�m.'+CRLF+'Par-'+CRLF+"tida"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80


  // Campo: LBC_ITEM
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_ITEM]
  oCol:cHeader      :='N�m.'+CRLF+'Item'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: LBC_REGPLA
  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_REGPLA]
  oCol:cHeader      :='Reg.'+CRLF+'Planif.'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: LBC_REGPLA
  IF !oLIBCOMEDIT:lVenta
    oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_CXP]
    oCol:cHeader      :="CxP"
    oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
    oCol:nWidth       := 80
    oCol:cEditPicture :='999'
    oCol:bStrData     :={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CXP],;
                                      oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_CXP],;
                                      FDP(nMonto,oCol:cEditPicture)}


  ELSE
    oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_CXC]
    oCol:cHeader      :="CxC"
    oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
    oCol:nWidth       := 80
  ENDIF

  IF oLIBCOMEDIT:COL_TDC_LIBVTA>0
     oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_TDC_LIBVTA]
     oCol:cHeader      :='Libro'+CRLF+"Venta"
     oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
     oCol:nWidth       := 70
     oCol:AddBmpFile("BITMAPS\checkverde.bmp")
     oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
     oCol:bBmpData    := { |oBrw|oBrw:=oLIBCOMEDIT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oLIBCOMEDIT:COL_TDC_LIBVTA],1,2) }
     oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
     oCol:bStrData    :={||""}
  ENDIF

  IF oLIBCOMEDIT:COL_TDC_LIBCOM>0
     oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_TDC_LIBCOM]
     oCol:cHeader      :='Libro'+CRLF+"Compra"
     oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
     oCol:nWidth       := 70
     oCol:AddBmpFile("BITMAPS\checkverde.bmp")
     oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
     oCol:bBmpData    := { |oBrw|oBrw:=oLIBCOMEDIT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,oLIBCOMEDIT:COL_TDC_LIBCOM],1,2) }
     oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
     oCol:bStrData    :={||""}
  ENDIF


  oCol:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_TDC_CLRGRA]
  oCol:cHeader      :="Color"+CRLF+"Texto"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oLIBCOMEDIT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:cEditPicture :='99999999999'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_TDC_CLRGRA],;
                                    oCol  := oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_TDC_CLRGRA],;
                                    FDP(nMonto,oCol:cEditPicture)}

  oLIBCOMEDIT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oLIBCOMEDIT:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oLIBCOMEDIT:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oLIBCOMEDIT:nClrText,;
                                                 nClrText:=IF(aLine[oLIBCOMEDIT:COL_LBC_ITEM]<>STRZERO(1,5),oLIBCOMEDIT:nClrText1,nClrText),;
                                                 nClrText:=IF(aLine[oLIBCOMEDIT:COL_LBC_REGDOC],oLIBCOMEDIT:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oLIBCOMEDIT:nClrPane1, oLIBCOMEDIT:nClrPane2 ) } }

// ENDIF

  oLIBCOMEDIT:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oLIBCOMEDIT:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oLIBCOMEDIT:oBrw:bLDblClick:={|oBrw|oLIBCOMEDIT:RUNCLICK() }

  oLIBCOMEDIT:oBrw:bChange:={||oLIBCOMEDIT:BRWCHANGE()}

  IF ISPCPRG()
    // AEVAL(oLIBCOMEDIT:oBrw:aCols,{|oCol,n| oCol:cHeader:=oCol:cHeader+CRLF+LSTR(n)})
  ENDIF

  oLIBCOMEDIT:oBrw:CreateFromCode()
  oLIBCOMEDIT:oWnd:oClient := oLIBCOMEDIT:oBrw

  // Copiar Edici�n de ColumnasColumnas

  oLIBCOMEDIT:aEditType:={}

// 8/10/2024  oLIBCOMEDIT:aFieldItemF:={"LBC_CODCTA","LBC_DESCRI","LBC_MTOBAS","LBC_TIPIVA","LBC_PORIVA","LBC_MTOIVA","LBC_MTONET"}

  oLIBCOMEDIT:aFieldItemF:={"LBC_CODCTA","LBC_DESCRI","LBC_MTOIVA","LBC_MTONET"}


// Posici�n de los campos que seran Editados en ITEM ADICIONAL
   oLIBCOMEDIT:aFieldItemP:={}
// AEVAL(oLIBCOMEDIT:aFieldItemF,{|a,n| AADD(oLIBCOMEDIT:aFieldItemP,oLIBCOMEDIT:LBCGETCOLPOS(a))})
// AEVAL(oLIBCOMEDIT:oBrw:aCols,{|oCol,n| AADD(oLIBCOMEDIT:aEditType,oCol:nEditType)})

  oLIBCOMEDIT:Activate({||oLIBCOMEDIT:ViewDatBar()})

  oLIBCOMEDIT:BRWRESTOREPAR()

  oLIBCOMEDIT:oBrw:GoBottom() 
  oLIBCOMEDIT:SETEDITTYPE(.T.)

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRLIBCOMEDIT",cWhere)
  oRep:cSql  :=oLIBCOMEDIT:cSql
  oRep:cTitle:=oLIBCOMEDIT:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oLIBCOMEDIT:oPeriodo:nAt,cWhere

  oLIBCOMEDIT:nPeriodo:=nPeriodo


  IF oLIBCOMEDIT:oPeriodo:nAt=LEN(oLIBCOMEDIT:oPeriodo:aItems)

     oLIBCOMEDIT:oDesde:ForWhen(.T.)
     oLIBCOMEDIT:oHasta:ForWhen(.T.)
     oLIBCOMEDIT:oBtn  :ForWhen(.T.)

     DPFOCUS(oLIBCOMEDIT:oDesde)

  ELSE

     oLIBCOMEDIT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oLIBCOMEDIT:oDesde:VarPut(oLIBCOMEDIT:aFechas[1] , .T. )
     oLIBCOMEDIT:oHasta:VarPut(oLIBCOMEDIT:aFechas[2] , .T. )

     oLIBCOMEDIT:dDesde:=oLIBCOMEDIT:aFechas[1]
     oLIBCOMEDIT:dHasta:=oLIBCOMEDIT:aFechas[2]

     cWhere:=oLIBCOMEDIT:HACERWHERE(oLIBCOMEDIT:dDesde,oLIBCOMEDIT:dHasta,oLIBCOMEDIT:cWhere,.T.)

     oLIBCOMEDIT:LEERDATA(cWhere,oLIBCOMEDIT:oBrw,oLIBCOMEDIT:cServer,oLIBCOMEDIT)

  ENDIF

  oLIBCOMEDIT:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oLIBCOMEDIT:cWhereQry)
       cWhere:=cWhere + oLIBCOMEDIT:cWhereQry
     ENDIF

     oLIBCOMEDIT:LEERDATA(cWhere,oLIBCOMEDIT:oBrw,oLIBCOMEDIT:cServer,oLIBCOMEDIT)

   ENDIF


RETURN cWhere

FUNCTION LEERDATA(cWhere,oBrw,cServer,oLIBEDIT,lCondom,lCtaEgr,lVenta,aIva)
   aData:=EJECUTAR("BRLIBCOMEDITLEERDATA",cWhere,oBrw,cServer,oLIBEDIT,lCondom,lCtaEgr,lVenta,aIva)
RETURN aData

FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRLIBCOMEDIT.MEM",V_nPeriodo:=oLIBCOMEDIT:nPeriodo
  LOCAL V_dDesde:=oLIBCOMEDIT:dDesde
  LOCAL V_dHasta:=oLIBCOMEDIT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las B�quedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oLIBCOMEDIT)
RETURN .T.

/*
// Ejecuci�n Cambio de Linea
*/
FUNCTION BRWCHANGE()
  LOCAL cItem:=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_ITEM]

  oLIBCOMEDIT:lSave:=.F.
  oLIBCOMEDIT:LIBREFRESHFIELD() // Refresca los Campos

  IF Empty(oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPDOC])
    oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPDOC]:=IF(oLIBCOMEDIT:lVenta,"FAV","FAC")
    oLIBCOMEDIT:PUTCTATIPDOC()
  ENDIF

// 8/10/2024
//
//  IF Empty(oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPIVA])
//    oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPIVA]:="GN"
//  ENDIF

  IF Empty(oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_COMORG])
    oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_COMORG]:="Nacional"
  ENDIF

  AEVAL(oLIBCOMEDIT:oBrw:aCols,{|oCol,n|oCol:lButton:=.F.})

  IF oLIBCOMEDIT:cItemChange<>cItem
    oLIBCOMEDIT:SETEDITTYPE(cItem=STRZERO(1,5))
  ENDIF

  oLIBCOMEDIT:cItemChange:=cItem

RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oLIBCOMEDIT")="O" .AND. oLIBCOMEDIT:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oLIBCOMEDIT:cWhere_),oLIBCOMEDIT:cWhere_,oLIBCOMEDIT:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oLIBCOMEDIT:LEERDATA(oLIBCOMEDIT:cWhere_,oLIBCOMEDIT:oBrw,oLIBCOMEDIT:cServer)
      oLIBCOMEDIT:oWnd:Show()
      oLIBCOMEDIT:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oLIBCOMEDIT:aHead:=EJECUTAR("HTMLHEAD",oLIBCOMEDIT)

// Ejemplo para Agregar mas Par�metros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oLIBCOMEDIT)
RETURN .T.

FUNCTION EDITCTA(nCol,lSave)
   LOCAL oBrw  :=oLIBCOMEDIT:oBrw,oLbx,cWhere
   LOCAL nAt   :=oBrw:nArrayAt
   LOCAL uValue:=oBrw:aArrayData[oBrw:nArrayAt,nCol]

   IF !oLIBCOMEDIT:lCtaEgr

     cWhere:="CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+IF(Empty(oLIBCOMEDIT:cWhereCta),""," AND "+oLIBCOMEDIT:cWhereCta)

     IF oDp:lCondominio

       oLbx:=DPLBX("CNDDPCTA.LBX","Cuentas con Planificaci�n, Periodo "+DTOC(oDp:dFchInicio)+"-"+DTOC(oDp:dFchCierre),cWhere)
       // oLbx:=DPLBX("CNDDPCTA.LBX","Cuentas con Planificaci�n, Periodo "+DTOC(oDp:dFchInicio)+"-"+DTOC(oDp:dFchCierre))

     ELSE

       oLbx:=DpLbx("DPCTAUTILIZACION.LBX",NIL,cWhere)

     ENDIF

     oLbx:GetValue("CTA_CODIGO",oBrw:aCols[nCol],,,uValue)

   ELSE

     oLbx:=DpLbx("DPCTAEGRESO.LBX")
     oLbx:GetValue("CEG_CODIGO",oBrw:aCols[nCol],,,uValue)

   ENDIF

   oLIBCOMEDIT:lAcction  :=.T.
   oBrw:nArrayAt:=nAt

   SysRefresh(.t.)

RETURN uValue

FUNCTION VALCTA(oCol,uValue,nCol,nKey)
 LOCAL cTipDoc,oTable,cWhere:="",cCtaOld:="",cDescri,aLine:={}
 LOCAL cDescri:=aLine[oLIBCOMEDIT:COL_CTA_DESCRI],cCodCta

 DEFAULT nKey:=0

 DEFAULT oCol:lButton:=.F.

 IF oCol:lButton=.T.
// oCol:oBrw:nColSel:=nCol+2
   oCol:lButton:=.F.
   RETURN .T.
 ENDIF

 IF !oLIBCOMEDIT:lCtaEgr

   oLIBCOMEDIT:cWhereCta:=""
   cCodCta:=EJECUTAR("FINDCODENAME","DPCTA","CTA_CODIGO","CTA_DESCRI",oCol,NIL,uValue)
   uValue :=IF(Empty(cCodCta),uValue,cCodCta)
   uValue :=ALLTRIM(uValue)

   cWhere:="LEFT(CTA_CODIGO,"+LSTR(LEN(uValue))+") "+GetWhere("=",uValue)

   IF COUNT("DPCTA",cWhere)>1

     oLIBCOMEDIT:cWhereCta:=cWhere
     EVAL(oCol:bEditBlock)

     RETURN .F.

   ENDIF

   CursorWait()

   IF !ISSQLFIND("DPCTA","CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+" AND CTA_CODIGO"+GetWhere("=",uValue))
      // 08/04/2024 EJECUTAR("XSCGMSGERR",oLIBCOMEDIT:oBrw,"Cuenta Contable no Existe")
      EVAL(oCol:bEditBlock)  
      RETURN .F.
   ENDIF

   cDescri:=SQLGET("DPCTA","CTA_DESCRI","CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+" AND CTA_CODIGO"+GetWhere("=",uValue))

   IF !EJECUTAR("ISCTADET",uValue,.T.,oLIBCOMEDIT:oBrw)
      EVAL(oCol:bEditBlock)  
      RETURN .F.
   ENDIF

 ELSE

   cCodCta:=EJECUTAR("FINDCODENAME","DPCTAEGRESO","CEG_CODIGO","CEG_DESCRI",oCol,NIL,uValue)
   uValue :=IF(Empty(cCodCta),uValue,cCodCta)

 ENDIF

 oLIBCOMEDIT:lAcction:=.F.

 IF !oLIBCOMEDIT:lCtaEgr
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CODCTA]:=uValue
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_CTA_DESCRI]:=cDescri
    oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_CODCTA)

 ELSE
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CTAEGR]:=uValue
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_CEG_DESCRI]:=cDescri
    oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_CTAEGR)

 ENDIF

 oCol:oBrw:nColSel:=oLIBCOMEDIT:COL_LBC_DESCRI
// nCol+2 OJO
 oCol:oBrw:DrawLine(.T.)

RETURN .T.

FUNCTION EDITRIF(nCol,lSave)
   LOCAL oBrw  :=oLIBCOMEDIT:oBrw,oLbx
   LOCAL nAt   :=oBrw:nArrayAt
   LOCAL aLine :=oBrw:aArrayData[oBrw:nArrayAt]
   LOCAL uValue:=oBrw:aArrayData[oBrw:nArrayAt,nCol]
   LOCAL cWhere:=""

   IF !Empty(aLine[nCol])

      IF !oLIBCOMEDIT:lVenta

        cWhere:="PRO_RIF"   +GetWhere(" LIKE ","%"+ALLTRIM(aLine[nCol])+"%")+" OR "+;
                "PRO_NOMBRE"+GetWhere(" LIKE ","%"+ALLTRIM(aLine[nCol])+"%")

        // no hay RIF con estos datos y proceso a Incluirlo
        IF COUNT("DPPROVEEDOR",cWhere)=0
          cWhere:=""
        // oBrw:nColSel:=oLIBCOMEDIT:LBCGETCOLPOS("PRO_NOMBRE")
        // RETURN .T.
        ENDIF

      ELSE

        cWhere:="CLI_RIF"+GetWhere(" LIKE ","%"+ALLTRIM(aLine[nCol])+"%")+" OR "+;
                "CLI_NOMBRE"+GetWhere(" LIKE ","%"+ALLTRIM(aLine[nCol])+"%")
         
        // no hay RIF con estos datos y proceso a Incluirlo
        IF COUNT("DPCLIENTES",cWhere)=0
          cWhere:=""
//        oBrw:nColSel:=oLIBCOMEDIT:LBCGETCOLPOS("CLI_NOMBRE")
//        RETURN .T.
        ENDIF

      ENDIF

   ENDIF

   IF !oLIBCOMEDIT:lVenta .AND. COUNT("DPPROVEEDOR")=0
      // 08/03/2024 NO DEBE BUSCAR EN EL SENIAT oLIBCOMEDIT:VALRIFSENIAT()
      RETURN .F.
   ENDIF

   IF !oLIBCOMEDIT:lVenta
     oLbx:=DpLbx("DPPROVEEDOR_RIF.LBX",cWhere,oLIBCOMEDIT:cWherePro+IF(Empty(cWhere),""," AND "+cWhere))
     oLbx:GetValue("PRO_RIF",oBrw:aCols[nCol],,,uValue)
   ELSE
     oLbx:=DpLbx("DPCLIENTES_RIF.LBX",cWhere,oLIBCOMEDIT:cWherePro+IF(Empty(cWhere),""," AND "+cWhere))
     oLbx:GetValue("CLI_RIF",oBrw:aCols[nCol],,,uValue)
   ENDIF

   oLIBCOMEDIT:lAcction  :=.T.
   oBrw:nArrayAt:=nAt

   SysRefresh(.t.)

RETURN uValue

/*
// Validar RIF DEL SENIAT
*/
FUNCTION VALRIFSENIAT2()
  LOCAL uValue :=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_RIF")
  LOCAL oCol   :=oLIBCOMEDIT:LBCGETCOLBRW("LBC_RIF")
  LOCAL nCol   :=oLIBCOMEDIT:LBCGETCOLPOS("LBC_RIF")
  LOCAL lOk ,nKey:=NIL
  LOCAL oDb    :=OpenOdbc(oDp:cDsnData),cSql

  oDp:aRif:={}
  lOk:=EJECUTAR("VALRIFSENIAT",uValue,!ISDIGIT(uValue),ISDIGIT(uValue)) 

  IF lOk

    IF LEN(oDp:aRif)>1 .AND. !("NO ENCON"$oDp:aRif[1] .OR. "NO EXIS"$UPPER(oDp:aRif[1]))

      cSql:=" SET FOREIGN_KEY_CHECKS = 0"
      oDb:Execute(cSql)

      IF oLIBCOMEDIT:lVenta
        oLIBCOMEDIT:CREATECLIENTE(uValue,oDp:aRif[1],VAL(oDp:aRif[2]))
      ELSE
        oLIBCOMEDIT:CREATEPROVEEDOR(uValue,oDp:aRif[1],VAL(oDp:aRif[2]))
      ENDIF

      cSql:=" SET FOREIGN_KEY_CHECKS = 1"
      oDb:Execute(cSql)

    ENDIF

    oLIBCOMEDIT:VALRIF(oCol,uValue,nCol,nKey)

  ENDIF

RETURN .T.

FUNCTION VALRIF(oCol,uValue,nCol,nKey)

   IF LEN(ALLTRIM(uValue))>10
     oLIBCOMEDIT:LBCMSGERR("RIF "+uValue+" no puede aceptar mas de 10 D�gitos")
     RETURN .F.
  ENDIF

RETURN EJECUTAR("LIBCOMVALRIF",oCol,uValue,nCol,nKey,oLIBCOMEDIT)

/*
// Crear la cuenta de Egreso, validar antes de grabar el registro
*/
FUNCTION CREATECTAEGRESO(cCodigo,cDescri)
   LOCAL aLine     :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]

   DEFAULT cCodigo:=aLine[oLIBCOMEDIT:COL_LBC_CTAEGR],;
           cDescri:=aLine[oLIBCOMEDIT:COL_EGR_DESCRI]

   
   IF !Empty(cCodigo)
      cCodigo:=oDp:cCtaIndef
   ENDIF

   EJECUTAR("CREATERECORD","DPCTAEGRESO",{"CEG_CODIGO","CEG_DESCRI" ,"CEG_CUENTA"   ,"CEG_ACTIVO","CEG_EGRES","CEG_CODCLA"},;
                                         {cCodigo     ,cDescri      ,oDp:cCtaIndef  ,.T.         ,.T.        ,oDp:cCtaIndef},;
                                         NIL,.T.,"CEG_CODIGO"+GetWhere("=",cCodigo))
RETURN .T.
/*
// Crear el codigo del Proveedor
*/
FUNCTION CREATEPROVEEDOR(cRif,cNombre,nRetIva)
   LOCAL cTipPer:=LEFT(cRif,1)

   cTipPer:=IF(cTipPer="V" .OR. cTipPer="E","N",cTipPer)

   DEFAULT nRetIva:=0

   cRif:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_RIF")

   EJECUTAR("CREATERECORD","DPPROVEEDOR",{"PRO_CODIGO","PRO_RIF" ,"PRO_NOMBRE","PRO_RETIVA","PRO_ESTADO","PRO_TIPO"       ,"PRO_TIPPER"},;
                                         {cRif        ,cRif      ,cNombre     ,nRetIva     ,"Activo"    ,oLIBCOMEDIT:cTipo,cTipPer     },;
            NIL,.T.,"PRO_RIF"+GetWhere("=",cRif))

RETURN .T.

/*
// Crear el codigo del Proveedor
*/
FUNCTION CREATECLIENTE(cRif,cNombre,nRetIva)
   LOCAL cTipPer:=LEFT(cRif,1)

   cRif:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_RIF")

   cTipPer:=IF(cTipPer="V" .OR. cTipPer="E","N",cTipPer)

   DEFAULT nRetIva:=0

   EJECUTAR("CREATERECORD","DPCLIENTES",{"CLI_CODIGO","CLI_RIF" ,"CLI_NOMBRE","CLI_RETIVA","CLI_ESTADO","CLI_TIPPER" },;
                                        {cRif        ,cRif      ,cNombre     ,nRetIva     ,"Activo"    ,cTipPer },;
            NIL,.T.,"CLI_RIF"+GetWhere("=",cRif))

RETURN .T.

/*
// Validar N�mero de Factura
*/
FUNCTION VALNUMFAC(oCol,uValue,nCol,nKey)
  LOCAL cWhere :=oLIBCOMEDIT:LIBWHERE()
  LOCAL aLine  :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]
  LOCAL nLen   :=LEN(aLine)
  LOCAL cWhere :="LBC_CODSUC"+GetWhere("=",oLIBCOMEDIT:cCodSuc)+" AND LBC_FCHDEC"+GetWhere("=",oLIBCOMEDIT:dFchDec)+" AND LBC_ITEM"+GetWhere("<>",aLine[nLen])
  LOCAL dFchFin:=SQLGET(oLIBCOMEDIT:cTable,"LBC_FCHDEC,LBC_ITEM",cWhere+" AND LBC_NUMFAC"+GetWhere("=",uValue)+" AND LBC_RIF"+GetWhere("=",oLIBCOMEDIT:LBC_RIF))
  LOCAL cItem  :=DPSQLROW(2),nAt

  // oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,nCol,nKey)
  nAt:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_NUMFIS")

  IF nAt>0
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nAt]:=uValue
    oCol:oBrw:nColSel:=nAt
  ENDIF

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol]:=uValue

  oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,nCol,nKey)

RETURN .T.

FUNCTION PUTDESCRI(oCol,uValue,nCol)

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue
  oCol:oBrw:DrawLine(.T.)
  oLIBCOMEDIT:LIBSAVEFIELD(nCol)

  oCol:oBrw:nColSel:=nCol+1

RETURN .T.

FUNCTION PUTFECHA(oCol,uValue,nCol)

  oLIBCOMEDIT:LBC_VALCAM:=EJECUTAR("DPGETVALCAM",oDp:cMonedaExt,uValue)

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_VALCAM ]:=oLIBCOMEDIT:LBC_VALCAM

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue
  oCol:oBrw:DrawLine(.T.)
  oLIBCOMEDIT:LIBSAVEFIELD(nCol)

  oCol:oBrw:nColSel:=nCol+1


RETURN .T.

/*
// Seleccionar tipo de Documento
*/
FUNCTION PUTTIPDOC(oCol,uValue,nCol)
  LOCAL nAt    :=ASCAN(oLIBCOMEDIT:aCodCta,{|a,n|a[1]==uValue})
  LOCAL lLibCom:=.F.
  LOCAL nCxC   :=0

  IF nAt>0 
     lLibCom:=oLIBCOMEDIT:aCodCta[nAt,8]
     nCxC   :=oLIBCOMEDIT:aCodCta[nAt,4]
  ENDIF 

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue
  oCol:oBrw:DrawLine(.T.)
  oLIBCOMEDIT:LIBSAVEFIELD(nCol)

  IF uValue="FAC" .OR. uValue="FAV" .OR. uValue="FAM"
    oCol:oBrw:aCols[oLIBCOMEDIT:COL_LBC_FACAFE]:nEditType:=0
  ELSE
    oCol:oBrw:aCols[oLIBCOMEDIT:COL_LBC_FACAFE]:nEditType:=1
  ENDIF

  IF oLIBCOMEDIT:lVenta

     oLIBCOMEDIT:nCxP:=nCxC // EJECUTAR("DPTIPCXC",uValue)
     oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CXC]:=oLIBCOMEDIT:nCxP

     IF oLIBCOMEDIT:COL_TDC_LIBVTA>0
        oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_TDC_LIBVTA]:=lLibCom
     ENDIF

     oLIBCOMEDIT:PUTCTATIPDOC()
     oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_CXC)

  ELSE

     oLIBCOMEDIT:nCxP:=nCxC // EJECUTAR("DPTIPCXP",uValue)
     oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CXP]:=oLIBCOMEDIT:nCxP
     oLIBCOMEDIT:PUTCTATIPDOC()

     IF oLIBCOMEDIT:COL_TDC_LIBCOM>0
        oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_TDC_LIBCOM]:=lLibCom
     ENDIF

  ENDIF

  oCol:oBrw:nColSel:=nCol+1

RETURN .T.

/*
// Busca la Columna 
*/
FUNCTION LBCGETCOLVALUE(cField)
   LOCAL nAt   :=ASCAN(oLIBCOMEDIT:aFields,{|a,n|a[1]==cField})
   LOCAL aLine :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]
   LOCAL uValue:=IF(nAt>0,aLine[nAt],NIL)

RETURN uValue

/*
// Busca Posici�n de la Columna 
*/
FUNCTION LBCGETCOLPOS(cField)
   LOCAL nAt   :=ASCAN(oLIBCOMEDIT:aFields,{|a,n|a[1]==cField})
RETURN nAt

/*
// Busca Posici�n de la Columna 
*/
FUNCTION LBCGETCOLBRW(cField)
   LOCAL nAt   :=ASCAN(oLIBCOMEDIT:aFields,{|a,n|a[1]==cField})

   
   IF ValType(nAt)<>"N" .OR. nAt=0 
      MensajeErr("Campo "+CTOO(cField,"C")+" no Existe")
   ENDIF

RETURN IF(nAt>0,oLIBCOMEDIT:oBrw:aCols[nAt],NIL)


/*
// GUARDAR VALOR EN EL CAMPO
*/
FUNCTION PUTFIELDVALUE(oCol,uValue,nCol,nKey,nLen,lNext,lTotal)
   LOCAL cField,aLine,aTotal:={},nTotal:=0
   LOCAL cWhere:=oLIBCOMEDIT:LIBWHERE()

   DEFAULT nCol  :=oCol:nPos,;
           lNext :=.F.,;
           lTotal:=!Empty(oCol:cFooter)

   cField:=oLIBCOMEDIT:aFields[nCol,1]
   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue
   aLine :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]

   IF nLen<>NIL .AND. ValType(uValue)="C"   
      uValue:=LEFT(uValue,nLen)
   ENDIF

   // si no existe , debe crearlo
   IF !ISSQLFIND(oLIBCOMEDIT:cTable,cWhere)
      oLIBCOMEDIT:LIBCOMGRABAR()
   ENDIF

   SQLUPDATE(oLIBCOMEDIT:cTable,cField,uValue,cWhere)

   // cada columna representa un campo y asigna el valor din�mico en el formulario
   oLIBCOMEDIT:LIBREFRESHFIELD()

   IF lTotal
      AEVAL(oCol:oBrw:aArrayData,{|a,n| nTotal:=nTotal+a[nCol]})
      oCol:cFooter      :=FDP(nTotal,oCol:cEditPicture)
      oCol:RefreshFooter()
   ENDIF

   IF lNext
      oLIBCOMEDIT:oBrw:nColSel:=nCol+1
   ENDIF

RETURN .T.

FUNCTION LIBREFRESHFIELD(nAt)
  LOCAL aLine

  DEFAULT nAt:=oLIBCOMEDIT:oBrw:nArrayAt

  aLine :=oLIBCOMEDIT:oBrw:aArrayData[nAt]

  AEVAL(oLIBCOMEDIT:aFields,{|a,n| oLIBCOMEDIT:SET(a[1],aLine[n])})

RETURN .T.

FUNCTION LIBSAVEFIELD(nCol)
  LOCAL cWhere:=oLIBCOMEDIT:LIBWHERE()
  LOCAL cField:=oLIBCOMEDIT:aFields[nCol,1]
  LOCAL uValue:=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nCol]
  LOCAL cCodigo

  // Debe guardar el registro en todo momento, por ahora
  IF !oLIBCOMEDIT:lSave .AND. COUNT(oLIBCOMEDIT:cTable,cWhere)=0
    oLIBCOMEDIT:LIBCOMGRABAR()
  ENDIF

  IF "PRO_NOMBRE"=cField .OR. "CLI_NOMBRE"=cField
     RETURN .F.
  ENDIF

  IF "LBC_RIF"=cField 

     IF !oLIBCOMEDIT:lVenta
       cCodigo:=SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_RIF"+GetWhere("=",cCodigo))
     ELSE
       cCodigo:=SQLGET("DPCLIENTES","CLI_CODIGO","CLI_RIF"+GetWhere("=",cCodigo))
     ENDIF

     SQLUPDATE(oLIBCOMEDIT:cTable,"LBC_CODIGO",cCodigo,cWhere)

  ENDIF

  SQLUPDATE(oLIBCOMEDIT:cTable,cField,uValue,cWhere)

  // Caso de Gastos de condominio, asociado con un cliente
  IF !Empty(oLIBCOMEDIT:cCodCli)
    SQLUPDATE(oLIBCOMEDIT:cTable,{"LBC_CODCLI","LBC_ID"},{oLIBCOMEDIT:cCodCli,oLIBCOMEDIT:cId},cWhere)
    //oLIBCOMEDIT:cCodCli:=cCodCli
    //oLIBCOMEDIT:cId    :=cId // DPCLIENTESCLI=ITEM
  ENDIF

  IF !Empty(oLIBCOMEDIT:cCenCos)
    SQLUPDATE(oLIBCOMEDIT:cTable,"LBC_CENCOS",oLIBCOMEDIT:cCenCos,cWhere)
  ENDIF

  oLIBCOMEDIT:LIBREFRESHFIELD() // Refresca los Campos

RETURN .T.

FUNCTION LIBWHERE()
   LOCAL x       :=oLIBCOMEDIT:BUILDITEM()
   LOCAL aLine   :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]
   LOCAL nColItem:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_ITEM")
   LOCAL nColNumP:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_NUMPAR")
   LOCAL cWhere  :="LBC_CODSUC"+GetWhere("=",oLIBCOMEDIT:cCodSuc)+" AND "+;
                   "LBC_FCHDEC"+GetWhere("=",oLIBCOMEDIT:dFchDec)+" AND "+;
                   "LBC_NUMPAR"+GetWhere("=",aLine[nColNumP]    )+" AND "+;
                   "LBC_ITEM"  +GetWhere("=",aLine[nColItem]    )

  IF LEFT(oDp:cTipCon,1)="O"

     cWhere  :="LBC_CODSUC"+GetWhere("=",oLIBCOMEDIT:cCodSuc)+" AND "+;
               "YEAR(LBC_FCHDEC )"+GetWhere("=",YEAR(oLIBCOMEDIT:dFchDec))+" AND "+;
               "MONTH(LBC_FCHDEC)"+GetWhere("=",MONTH(oLIBCOMEDIT:dFchDec))+" AND "+;
               "LBC_NUMPAR"+GetWhere("=",aLine[nColNumP]    )+" AND "+;
               "LBC_ITEM"  +GetWhere("=",aLine[nColItem]    )

  ENDIF

  
RETURN cWhere

FUNCTION BUILDITEM()
   LOCAL cMax:="",lZero:=.T.,nLen:=5
   LOCAL aLine   :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]
   LOCAL nColItem:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_ITEM")
   LOCAL nColNumP:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_NUMPAR")
   LOCAL cItem   :=aLine[nColItem]

   IF Empty(aLine[nColNumP])
      cItem:=SQLINCREMENTAL(oLIBCOMEDIT:cTable,"LBC_NUMPAR",oLIBCOMEDIT:cWhere,NIL,cMax,lZero,nLen)
   ENDIF

RETURN cItem


FUNCTION LIBCOMGRABAR(lAll)
   LOCAL aLine  :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]
   LOCAL cWhere :=oLIBCOMEDIT:LIBWHERE(),I,aFields:={},aValues:={}
   LOCAL nAt    :=oLIBCOMEDIT:oBrw:nArrayAt
   LOCAL nCxP   :=oLIBCOMEDIT:nCxP
   LOCAL cCodigo:=""
   LOCAL cRif   :=aLine[oLIBCOMEDIT:COL_LBC_RIF] 
   LOCAL cCtaEgr:=oDp:cCtaIndef
   LOCAL cCodCta:=oDp:cCtaIndef

   IF oLIBCOMEDIT:COL_LBC_CTAEGR>0
      cCtaEgr:=aLine[oLIBCOMEDIT:COL_LBC_CTAEGR]
   ELSE
      cCodCta:=aLine[oLIBCOMEDIT:COL_LBC_CODCTA]
      cCodEgr:=EJECUTAR("DPCTAEGRESOCREA",cCodCta,.T.)
   ENDIF

//? cWhere,"cWhere"

   IF !Empty(cRif)

     IF !oLIBCOMEDIT:lVenta
       cCodigo:=SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_RIF"+GetWhere("=",cRif))
     ELSE
       cCodigo:=SQLGET("DPCLIENTES","CLI_CODIGO","CLI_RIF"+GetWhere("=",cRif))
     ENDIF

   ENDIF

   DEFAULT lAll:=.F.

   oLIBCOMEDIT:lSave:=.T.

   FOR I=1 TO LEN(oLIBCOMEDIT:aFields)
   
     IF LEFT(oLIBCOMEDIT:aFields[I,1],4)="LBC_" .AND. !LEFT(oLIBCOMEDIT:aFields[I,1],10)="LBC_REGDOC" .AND. !LEFT(oLIBCOMEDIT:aFields[I,1],07)="LBC_DIA"
        AADD(aFields,oLIBCOMEDIT:aFields[I,1])
        AADD(aValues,aLine[I])
     ENDIF

   NEXT I

   AADD(aFields,"LBC_CODMOD")
   AADD(aFields,"LBC_FCHDEC")
   AADD(aFields,"LBC_CODSUC")
   AADD(aFields,IF(oLIBCOMEDIT:lVenta,"LBC_CXC","LBC_CXP"))
   AADD(aFields,"LBC_REGPLA")
   AADD(aFields,"LBC_CODIGO")
   AADD(aFields,"LBC_CENCOS")

   AADD(aValues,oDp:cCtaMod)
   AADD(aValues,oLIBCOMEDIT:dFchDec)
   AADD(aValues,oLIBCOMEDIT:cCodSuc)
   AADD(aValues,nCxP) 
   AADD(aValues,aLine[oLIBCOMEDIT:COL_LBC_REGPLA]) 
   AADD(aValues,aLine[oLIBCOMEDIT:COL_LBC_RIF   ]) // RIF=C�digo
   AADD(aValues,IF(Empty(oLIBCOMEDIT:cCenCos),oDp:cCenCos,oLIBCOMEDIT:cCenCos))

   IF oLIBCOMEDIT:lCtaEgr .AND. !ISSQLFIND("DPCTAEGRESO","CEG_CODIGO"+GetWhere("=",cCtaEgr))
      oLIBCOMEDIT:CREATECTAEGRESO(cCtaEgr,cDescri)
   ENDIF

   IF COUNT(oLIBCOMEDIT:cTable,cWhere)=0 .OR. lAll

// ? "aqui incluye si no encuentra el registro",CLPCOPY(oDp:cSql)

     EJECUTAR("CREATERECORD",oLIBCOMEDIT:cTable,aFields,aValues,NIL,.T.,cWhere)

//? CLPCOPY(oDp:cSql)

     IF !lAll
       oLIBCOMEDIT:LIBCOMADDLINE()
       oLIBCOMEDIT:oBrw:nArrayAt:=nAt
     ENDIF

   ENDIF

RETURN .T.

/*
// Agregar Linea
*/
FUNCTION LIBCOMADDLINE(lItem)
  LOCAL nColItem:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_ITEM")
  LOCAL nColNumP:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_NUMPAR")
  LOCAL cMaxNumP:=STRZERO(0,5)
  LOCAL cMaxItem:=""
  LOCAL aLine   :=ACLONE(oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt])
  LOCAL cItem   :=STRZERO(1,5)
  LOCAL nItems  :=0,nAt
  LOCAL cTipDoc :=aLine[1]

  DEFAULT lItem:=.F.

  IF !lItem

    // no suma el item
    AEVAL(oLIBCOMEDIT:oBrw:aArrayData,{|a,n| cMaxNumP:=IF(a[nColNumP]>cMaxNumP,a[nColNumP],cMaxNumP)})
    cMaxNumP:=STRZERO(VAL(cMaxNumP)+1,5)
  
  ELSE

    // Incrementa de Items en la misma partida
    cMaxNumP:=aLine[nColNumP]
    AEVAL(oLIBCOMEDIT:oBrw:aArrayData,{|a,n| nItems:=nItems+IF(a[nColNumP]=cMaxNumP,1,0)})
    cItem:=STRZERO(nItems+1,5)
    
  ENDIF

  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(a)})

  aLine[1       ]:=cTipDoc
  aLine[nColItem]:=cItem
  aLine[nColNumP]:=cMaxNumP
  aLine[oLIBCOMEDIT:COL_LBC_ACTIVO]:=.T.

  IF !lItem
    AADD(oLIBCOMEDIT:oBrw:aArrayData,ACLONE(aLine))
  ELSE
    nAt:=oLIBCOMEDIT:oBrw:nArrayAt+1
    AINSERTAR(oLIBCOMEDIT:oBrw:aArrayData,nAt,ACLONE(aLine))
    oLIBCOMEDIT:oBrw:nArrayAt:=nAt
    oLIBCOMEDIT:oBrw:nRowSel:=oLIBCOMEDIT:oBrw:nRowSel+1
  ENDIF

  oLIBCOMEDIT:nCxP:=EJECUTAR("DPTIPCXP",aLine[1])

  oLIBCOMEDIT:oBrw:Refresh(.F.)

RETURN .T.

/*
// Ejecuta Guardar y Convertir en Documentos del Proveedor
*/
FUNCTION LIBCOMSAVE()
   LOCAL dDesde:=FCHINIMES(oLIBCOMEDIT:dFchDec)
   LOCAL dHasta:=FCHFINMES(dDesde)

   IF !oLIBCOMEDIT:lVenta

      EJECUTAR("DPLIBCOMTODPDOCPRO",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:dFchDec)

      IF LEFT(oDp:cTipCon,1)="O"
        EJECUTAR("BRDOCPRORESXCNT",NIL,oLIBCOMEDIT:cCodSuc,oDp:nMensual,dDesde,dHasta,NIL)
      ENDIF

      EJECUTAR("DPLIBCOMTOBANCOS",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:dFchDec) // Transacciones Bancarias

   ELSE

      EJECUTAR("DPLIBVTATODPDOCCLI",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:dFchDec)

   ENDIF

   IF ValType(oLIBCOMEDIT:oFrmRefresh)="O"
      oLIBCOMEDIT:oFrmRefresh:BRWREFRESCAR()
   ENDIF

RETURN .T.

FUNCTION VALRIFNOMBRE(oCol,uValue,nCol,nKey)
  LOCAL cRif   :=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_RIF")
  LOCAL cNombre:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_NOMBRE")
  LOCAL aLine  :=ACLONE(oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt])
  LOCAL cCodigo:=uValue
  LOCAL oColRif:=NIL

  IF Empty(uValue)
    oLIBCOMEDIT:oBrw:nColSel:=nCol
    RETURN .F.
  ENDIF

  oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nCol  ]:=uValue
  oLIBCOMEDIT:oBrw:DrawLine(.T.)

  oLIBCOMEDIT:LIBREFRESHFIELD() // Refresca los Campos
  cCodigo:=uValue // Codigo del Proveedor

  IF !oLIBCOMEDIT:lVenta

    oLIBCOMEDIT:CREATEPROVEEDOR(cRif,uValue,oLIBCOMEDIT:LBC_PORRTI)

  ELSE

    oLIBCOMEDIT:CREATECLIENTE(cRif,uValue,oLIBCOMEDIT:LBC_PORRTI)

  ENDIF

  // Actualiza el Codigo del CLIENTE/RIF
  SQLUPDATE(oLIBCOMEDIT:cTable,{"LBC_RIF","LBC_CODIGO"},{cRif,cRif},oLIBCOMEDIT:LIBWHERE())
 
 

  // 08/04/2024
  // si el nombre de la cuenta no est�,  // Cuenta Contable
  oColRif:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_RIF") // oLIBCOMEDIT:COL_LBC_RIF)
  IF !oLIBCOMEDIT:lCtaEgr .AND. Empty(aLine[oLIBCOMEDIT:COL_CTA_DESCRI])
     // oCol:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_RIF") // oLIBCOMEDIT:COL_LBC_RIF)
     oLIBCOMEDIT:VALRIF(oColRif,cRif,oLIBCOMEDIT:COL_LBC_RIF,nKey) // aqui refresca linea de la cuenta
  ENDIF

  IF oLIBCOMEDIT:lCtaEgr .AND. Empty(aLine[oLIBCOMEDIT:COL_CEG_DESCRI])
     // oCol:=oLIBCOMEDIT:LBCGETCOLBRW(oLIBCOMEDIT:COL_LBC_RIF)
     oLIBCOMEDIT:VALRIF(oColRif,cRif,oLIBCOMEDIT:COL_LBC_RIF,nKey) // aqui refresca linea de la cuenta
  ENDIF

  IF Empty(aLine[nCol+1])
    oCol:oBrw:nColSel:=nCol+1
  ELSE
    oCol:oBrw:nColSel:=oLIBCOMEDIT:COL_LBC_NUMFAC // N�mero de Factura
  ENDIF

RETURN .T.

FUNCTION PUTTIPIVA(oCol,cTipIva,nCol)
   LOCAL nPorIva   :=oLIBCOMEDIT:GETPORIVA(cTipIva)
   LOCAL nMonto    :=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOBAS]
   LOCAL nMtoIva   :=PORCEN(nMonto,nPorIva)
   LOCAL nMtoExe   :=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOEXE]
   LOCAL oColPorRti:=NIL
   LOCAL nPorRti   :=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_PORRTI")

// 8/10/2024  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPIVA]:=cTipIva
// 8/10/2024  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_PORIVA]:=nPorIva

   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOIVA]:=nMtoIva
   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTONET]:=nMonto+nMtoIva+nMtoExe

// 8/10/2024 oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_TIPIVA)
// 8/10/2024 oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_PORIVA)

   oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_MTOIVA)
   oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_MTONET)

   IF oLIBCOMEDIT:COL_LBC_PORRTI>0
      oColPorRti:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_PORRTI")
      oLIBCOMEDIT:VALPORRTI(oColPorRti,nPorRti,oLIBCOMEDIT:COL_LBC_PORRTI,NIL)
   ENDIF

RETURN .T.

/*
// Valida % RETENCION DE IVA
*/
FUNCTION VALPORRTI(oCol,uValue,oLIBCOMEDIT:COL_LBC_PORRTI,nKey)
   LOCAL nMtoIva:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_MTOIVA")
   LOCAL nMtoRti:=PORCEN(nMtoIva,uValue)
   LOCAL cRif   :=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_RIF")

   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTORTI]:=nMtoRti

   oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_MTORTI)
   oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_PORRTI,nKey)

   SQLUPDATE("DPPROVEEDOR","PRO_RETIVA",uValue,"PRO_RIF"+GetWhere("=",cRif))

   EJECUTAR("LIBCOMGETNUMRTI",oLIBCOMEDIT) // genera el N�mero de retenci�n de IVA

RETURN .T.

/*
// Valida % RETENCION DE ISLR
*/
FUNCTION VALPORISR(oCol,uValue,nCol,nKey)
   LOCAL nMtoBas:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_MTOBAS")
   LOCAL dFecha :=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_FECHA")
   LOCAL cCodCon:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_CONISR")
   LOCAL nMtoIsr:=0 // PORCEN(nMtoBas,uValue)

   oLIBCOMEDIT:SETTIPPER()
   nMtoIsr:=EJECUTAR("CALRETISLR",nMtoBas,nMtoBas,cCodCon,oLIBCOMEDIT:cTipPer,oLIBCOMEDIT:cReside,dFecha)


   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOISR]:=nMtoIsr

   oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_MTOISR)
   oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_PORISR,nKey)

   EJECUTAR("LIBCOMGETNUMISR",oLIBCOMEDIT) // genera el N�mero de retenci�n de ISLR

RETURN .T.


FUNCTION GETPORIVA(cTipIva)
  LOCAL nPorIva:=0
  LOCAL nCol  :=IIF("N"="N",3,5)

  nPorIva:=EJECUTAR("IVACAL",cTipIva,nCol,oLIBCOMEDIT:dFchDec) 

RETURN nPorIva

/*
// Valida base imponible
*/

FUNCTION VALLBCMTOBAS(oCol,uValue,nCol,nKey)
  LOCAL cTipIva:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_TIPIVA"),nAt
  LOCAL cTipDoc:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_TIPDOC")
  LOCAL cNumDoc:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_NUMFAC")
  LOCAL nPorISR:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_PORISR")
  LOCAL cCodCon:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_CONISR")
  LOCAL nPorIva:=oLIBCOMEDIT:GETPORIVA(cTipIva)
  LOCAL oColIva:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_TIPIVA")
//LOCAL oColPor:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_PORIVA")
  LOCAL oColISR:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_PORISR")
  LOCAL oColCon:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_CONISR")
  LOCAL nColIva:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_TIPIVA")
  LOCAL nColCon:=oLIBCOMEDIT:LBCGETCOLBRW("LBC_CONISR")
  LOCAL nColISR:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_PORISR")

  oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_MTOBAS,nKey)

  IF nPorIva>0
     oLIBCOMEDIT:PUTTIPIVA(oColIva,cTipIva,nColIva)
  ENDIF

  // En el caso de Gastos o documentos no fiscales, debe generar su n�mero
  IF !oLIBCOMEDIT:lVenta .AND. Empty(cNumDoc) .AND. !ISSQLGET("DPTIPDOCPRO","TDC_LIBCOM","TDC_TIPO"+GetWhere("=",cTipDoc))
     // no es libro de compras, numero autoincremental
     cNumDoc:=SQLINCREMENTAL(oLIBCOMEDIT:cTable,"LBC_NUMFAC","LBC_TIPDOC"+GetWhere("=",cTipDoc),NIL,NIL,.T.,8)
     nAt:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_NUMFAC")
     oLIBCOMEDIT:PUTFIELDVALUE(oLIBCOMEDIT:oBrw:aCols[nAt],cNumDoc,nAt,nKey,NIL,.T.)
  ENDIF

  // AHORA DEBE AGREGAR NUEVA LINEA, si no tiene fechas vacias, agrega
  nAt:=ASCAN(oLIBCOMEDIT:oBrw:aArrayData,{|a,n| Empty(a[oLIBCOMEDIT:COL_LBC_FECHA])})
  IF nAt=0
    oLIBCOMEDIT:LIBCOMADDLINE()
  ENDIF

  // Calcular Retenci�n de ISLR
  // ? oColISR,nPorISR,nColISR,nKey,"oColISR,nPorISR,nColISR,nKey"
  IF !Empty(cCodCon)
     oLIBCOMEDIT:VALCONISLR(oColCon,cCodCon,nColCon,nKey)
  ENDIF

  oLIBCOMEDIT:VALPORISR(oColISR,nPorISR,nColISR,nKey)

RETURN .T.

/*
// Activar o Inactivar Editar Columnas
*/
FUNCTION SETEDITTYPE(lOn)

  IF lOn
    // Activa la Edici�n de las columnas
    AEVAL(oLIBCOMEDIT:aEditType,{|nEditType,n| oLIBCOMEDIT:oBrw:aCols[n]:nEditType:=nEditType} )
  ELSE

    // Desactiva 
    AEVAL(oLIBCOMEDIT:aEditType,{|nEditType,n| oLIBCOMEDIT:oBrw:aCols[n]:nEditType:=0} )

    // Activa solo las columnas editables para agregar nuevas cuentas e Items
    // ViewArray(oLIBCOMEDIT:aFieldItemP)
    AEVAL(oLIBCOMEDIT:aFieldItemP,{|nAt,n,nEditType| nEditType:=oLIBCOMEDIT:aEditType[nAt],;
                                                     oLIBCOMEDIT:oBrw:aCols[nAt]:nEditType:=nEditType})

  ENDIF

RETURN .T.
/*
// Insertar Linea
*/
FUNCTION LIBADDITEM()
   LOCAL nAt:=ASCAN(oLIBCOMEDIT:oBrw:aArrayData,{|a,n| Empty(a[2])})

   IF nAt>0 .AND. LEN(oLIBCOMEDIT:oBrw:aArrayData)>2
      ARREDUCE(oLIBCOMEDIT:oBrw:aArrayData,nAt)
      oLIBCOMEDIT:oBrw:nArrayAt--
      oLIBCOMEDIT:oBrw:nArrayAt:=MAX(oLIBCOMEDIT:oBrw:nArrayAt,1)
   ENDIF

   oLIBCOMEDIT:LIBCOMADDLINE(.T.)
   oLIBCOMEDIT:SETEDITTYPE(.F.)

   IF !Empty(oLIBCOMEDIT:aFieldItemP)
     oLIBCOMEDIT:oBrw:nColSel:=oLIBCOMEDIT:aFieldItemP[1]
   ENDIF

RETURN .T.

/*
// CREAR DOCUMENTO 
*/
FUNCTION CREARDOC(lDoc)
   LOCAL cWhere,cCodigo

   DEFAULT lDoc:=.T.

   IF Empty(oLIBCOMEDIT:LBC_NUMFAC)
      oLIBCOMEDIT:oBtnForm:MsgErr("Requiere N�mero de Documento","Ver Documento, no es Posible")
      RETURN .F.
   ENDIF

   oLIBCOMEDIT:LBC_NUMFAC:=STRTRAN(oLIBCOMEDIT:LBC_NUMFAC,CHR(10),"")
   oLIBCOMEDIT:LBC_NUMFAC:=STRTRAN(oLIBCOMEDIT:LBC_NUMFAC,CHR(13),"")

   cWhere:="LBC_CODSUC"+GetWhere("=" ,oLIBCOMEDIT:cCodSuc   )+" AND "+;
           "LBC_NUMFAC"+GetWhere("=" ,oLIBCOMEDIT:LBC_NUMFAC)+" AND "+;
           "LBC_TIPDOC"+GetWhere("=" ,oLIBCOMEDIT:LBC_TIPDOC)+" AND "+;
           "LBC_RIF   "+GetWhere("=" ,oLIBCOMEDIT:LBC_RIF   )

   IF !oLIBCOMEDIT:lVenta

      EJECUTAR("DPLIBCOMTODPDOCPRO",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:dFchDec,cWhere)
      EJECUTAR("DPLIBCOMTOBANCOS"  ,oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:dFchDec,cWhere) // Transacciones Bancarias

   ELSE

      EJECUTAR("DPLIBVTATODPDOCCLI",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:dFchDec,cWhere)

   ENDIF

   cCodigo:=SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_RIF"+GetWhere("=",oLIBCOMEDIT:LBC_RIF))

   IF !oLIBCOMEDIT:lVenta

     IF lDoc
        EJECUTAR("VERDOCPRO",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:LBC_TIPDOC,cCodigo,oLIBCOMEDIT:LBC_NUMFAC,"D")
     ELSE
        EJECUTAR("DPPRODOCMNU",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:LBC_TIPDOC,oLIBCOMEDIT:LBC_NUMFAC,cCodigo)
     ENDIF   

   ELSE

     IF lDoc
        EJECUTAR("VERDOCCLI",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:LBC_TIPDOC,cCodigo,oLIBCOMEDIT:LBC_NUMFAC,"D")
     ELSE
        EJECUTAR("DPDOCCLIMNU",oLIBCOMEDIT:cCodSuc,oLIBCOMEDIT:LBC_TIPDOC,oLIBCOMEDIT:LBC_NUMFAC,cCodigo)
     ENDIF   

   ENDIF

RETURN .T.

/*
// Calcula la Base Imponible
*/

FUNCTION CALBASEIMP(oCol,nNeto,nCol,nKey)
   LOCAL nBaseImp:=0,nMtoIva:=0
/*
// 8/10/2024   LOCAL cIVA    :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPIVA]
// 8/10/2024   LOCAL oColIva :=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_TIPIVA]
// 8/10/2024   LOCAL x       :=oLIBCOMEDIT:PUTTIPIVA(oColIva,cIVA,oLIBCOMEDIT:COL_LBC_TIPIVA,nKey)
// 8/10/2024   LOCAL nIVA    :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_PORIVA]

   nBaseImp:=nNeto/(1+nIVA/100)
   nMtoIva :=PORCEN(nBaseImp,nIVA)

   oColIva :=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOBAS]
   oLIBCOMEDIT:PUTFIELDVALUE(oColIva,nBaseImp,oLIBCOMEDIT:COL_LBC_MTOBAS,nKey)

   oColIva :=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOIVA]

   oLIBCOMEDIT:PUTFIELDVALUE(oColIva,nMtoIva,oLIBCOMEDIT:COL_LBC_MTOIVA,nKey,NIL,NIL,.T.)

   oColIva :=oLIBCOMEDIT:oBrw:aCols[nCol]
   oLIBCOMEDIT:PUTFIELDVALUE(oCol,nNeto,nCol,nKey)
*/

RETURN nBaseImp

/*
// Inactiva Registro
*/
FUNCTION DELASIENTOS()
   LOCAL nAt    :=oLIBCOMEDIT:oBrw:nArrayAt
   LOCAL nRow   :=oLIBCOMEDIT:oBrw:nRowSel

   LOCAL lActivo:=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_ACTIVO]

//? oLIBCOMEDIT:oBrw:nColSel,oLIBCOMEDIT:COL_LBC_ACTIVO

   IF oLIBCOMEDIT:oBrw:nColSel<>oLIBCOMEDIT:COL_LBC_ACTIVO
/*

      //oLIBCOMEDIT:oBrw:nColSel:=oLIBCOMEDIT:COL_LBC_ACTIVO
      // oLIBCOMEDIT:oBrw:Refresh(.T.)

      oLIBCOMEDIT:oBrw:nColSel:=oLIBCOMEDIT:COL_LBC_ACTIVO

      oLIBCOMEDIT:oBrw:Refresh(.F.)

      oLIBCOMEDIT:oBrw:nArrayAt:=nAt
      oLIBCOMEDIT:oBrw:nRowSel :=nRow
*/
   ENDIF

   oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_ACTIVO]:=!lActivo
   oLIBCOMEDIT:oBrw:DrawLine(.T.)
   oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_ACTIVO)

RETURN .T.

/*
// Contabilizar
*/
FUNCTION CONTABILIZAR()
  LOCAL cWhere,cTitle:=NIL
  LOCAL aTipCxP:={"CAJ","BCO","CJE","BCE","LBC"}

  cWhere:="DOC_CODSUC"+GetWhere("=",oLIBCOMEDIT:cCodSuc)+" AND DOC_FCHDEC"+GetWhere("=",oLIBCOMEDIT:dFchDec)

RETURN EJECUTAR("BRDOCPRORESXCNT",cWhere,oLIBCOMEDIT:cCodSuc,oDp:nIndicada,oLIBCOMEDIT:dFchDec,oLIBCOMEDIT:dFchDec,cTitle)

FUNCTION VALCODPRO()

  IF !ISSQLFIND("DPPROVEEDOR","PRO_CODIGO"+GetWhere("=",oLIBCOMEDIT:cCodPro))
    oLIBCOMEDIT:oCodPro:KeyBoard(VK_F6)
  ENDIF

  oLIBCOMEDIT:oNomPro:Refresh(.T.)

RETURN .T.

/*
// Validar Cuenta de Egreso
*/
FUNCTION VALCTAEGR(oCol,uValue,nCol,nKey)
  LOCAL cTipDoc,oTable,cWhere:="",cCtaOld:="",cDescri,aLine:={},cWhere,cCtaEgr:=""
  LOCAL nColPorRti:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_PORRTI")
  LOCAL nColTipIva:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_TIPIVA")
  LOCAL nColDescri:=oLIBCOMEDIT:LBCGETCOLPOS("LBC_DESCRI")

  DEFAULT nKey:=0

  DEFAULT oCol:lButton:=.F.

  IF oCol:lButton=.T.
    oCol:lButton:=.F.
    RETURN .T.
  ENDIF

  IF !ISSQLFIND("DPCTAEGRESO","CEG_CODIGO"+GetWhere("=",uValue))
    cCtaEgr:=EJECUTAR("FINDCODENAME","DPCTAEGRESO","CEG_CODIGO","CEG_DESCRI",oCol,NIL,uValue)
    uValue :=IF(Empty(cCtaEgr),uValue,cCtaEgr)
  ENDIF

  oCol:oBrw:aCols[nCol+1]:nEditType    :=0

  IF !ISSQLFIND("DPCTAEGRESO","CEG_CODIGO"+GetWhere("=",uValue))

    oCol:oBrw:aCols[nCol+1]:nEditType    :=1
    oCol:oBrw:nColSel:=nCol+1
 
  ENDIF

  cDescri:=SQLGET("DPCTAEGRESO","CEG_DESCRI","CEG_CODIGO"+GetWhere("=",uValue))

  oLIBCOMEDIT:lAcction:=.F.

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue
  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol+1]:=cDescri
  oCol:oBrw:DrawLine(.T.)

  oLIBCOMEDIT:LIBSAVEFIELD(oLIBCOMEDIT:COL_LBC_CTAEGR)

RETURN .T.

/*
// Validar Nombre del Proveedor y lo guarda
*/
FUNCTION VALNOMBREEGR(oCol,uValue,nCol,nKey,NIL,lRefresh)
   LOCAL aLine  :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]
   LOCAL cCodigo:=aLine[nCol-1]

   IF Empty(uValue)
      RETURN .F.
   ENDIF

   oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nCol]:=uValue
   oLIBCOMEDIT:oBrw:DrawLine(.T.)
   oLIBCOMEDIT:oBrw:nColSel++

   oLIBCOMEDIT:CREATECTAEGRESO(cCodigo,uValue)

   // Debe actualizar el libro de compras
   oLIBCOMEDIT:LIBSAVEFIELD(nCol-1) // Asignar la Cuenta de Egreso

RETURN .T.
/*
// Asignar Cuenta Contable seg�n tipo de Documento
*/
FUNCTION PUTCTATIPDOC()
   LOCAL cTipDoc:=oLIBCOMEDIT:LBCGETCOLVALUE("LBC_TIPDOC")
   LOCAL nAt    :=ASCAN(oLIBCOMEDIT:aCodCta,{|a,n|a[1]==cTipDoc}),cCodCta,cDescri
   LOCAL nField :=oLIBCOMEDIT:LBCGETCOLPOS(IF(oLIBCOMEDIT:lCtaEgr,"LBC_CTAEGR","LBC_CODCTA"))
   LOCAL nCxC   :=0,nColor:=0
   LOCAL cDescriV // Descripcion venta
   LOCAL cNumero:="",cWhere,nLen:=10,cNumFis:="",cNumFac:=""

   IF nAt>0 .AND. nField>0

      cCodCta :=oLIBCOMEDIT:aCodCta[nAt,2]
      cDescri :=oLIBCOMEDIT:aCodCta[nAt,3]
      nCxC    :=oLIBCOMEDIT:aCodCta[nAt,4]
      nColor  :=oLIBCOMEDIT:aCodCta[nAt,5]
      cDescriV:=oLIBCOMEDIT:aCodCta[nAt,6]

      cNumFac :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_NUMFAC]
      cNumFis :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_NUMFIS] 

      cWhere  :="LBC_CODSUC"+GetWhere("=",oLIBCOMEDIT:cCodSuc)+" AND "+;
                "LBC_TIPDOC"+GetWhere("=",cTipDoc            )


      IF oLIBCOMEDIT:lVenta .OR. (!oLIBCOMEDIT:lVenta .AND. !oLIBCOMEDIT:aCodCta[nAt,8]) // no libro de compras
 
        cNumero :=oLIBCOMEDIT:aCodCta[nAt,7]
        cNumero :=SQLINCREMENTAL(oLIBCOMEDIT:cTable,"LBC_NUMFAC",cWhere+" AND LBC_NUMFAC"+GetWhere("<>",cNumFac),NIL,cNumero,.T.,nLen)
        cNumFis :=SQLINCREMENTAL(oLIBCOMEDIT:cTable,"LBC_NUMFIS",cWhere+" AND LBC_NUMFIS"+GetWhere("<>",cNumFis),NIL,cNumFis,.T.,nLen)

        oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_NUMFAC]:=cNumero
        oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_NUMFIS]:=cNumFis

      ENDIF

      IF Empty(oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nField+0])
        oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nField+0]:=cCodCta
        oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nField+1]:=cDescri
        oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_DESCRI]:=cDescriV
      ENDIF

      oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CXC   ]:=nCxC
      oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_TDC_CLRGRA]:=nColor
      oLIBCOMEDIT:LIBCOMGRABAR(.T.) // Guarda toda la l�nea

   ENDIF


RETURN .T.

FUNCTION PUTDIA(oCol,uValue,nCol,nKey)
  LOCAL dFecha

  oLIBCOMEDIT:PUTCTATIPDOC()

  IF uValue>0 .AND. uValue<=31

    dFecha:=CTOD(LSTR(uValue)+"/"+LSTR(MONTH(oLIBCOMEDIT:dFchDec))+"/"+LSTR(YEAR(oLIBCOMEDIT:dFchDec)))

    IF ValType(dFecha)="D"
       oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nCol  ]:=uValue
       oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nCol+1]:=dFecha
       oLIBCOMEDIT:LIBSAVEFIELD(nCol+1)
       oLIBCOMEDIT:oBrw:nColSel:=nCol+2
       RETURN .T.
    ENDIF

  ENDIF

RETURN .F.

FUNCTION SETTIPPER()
   LOCAL aLine  :=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt]
   LOCAL cRif      :=aLine[oLIBCOMEDIT:COL_LBC_RIF] 

   oLIBCOMEDIT:cReside:=IF(Empty(oLIBCOMEDIT:cReside),"S",oLIBCOMEDIT:cReside)
   cRif       :=UPPER(cRif)
   oLIBCOMEDIT:cTipPer:=LEFT(cRif,1)
   oLIBCOMEDIT:cTipPer:=IF(ISALLDIGIT(cRif) .OR. (LEFT(cRif,1)="V" .OR. LEFT(cRif,1)="E"),"N",oLIBCOMEDIT:cTipPer)

RETURN .T.

/*
// Editar Codigo de Retenci�N
*/
FUNCTION EDITCONISLR(nCol,lSave)
RETURN EJECUTAR("LIBCOMEDITCONISLR",nCol,lSave,oLIBCOMEDIT)

/*
// Validar codigo de ISLR
*/
FUNCTION VALCONISLR(oCol,uValue,nCol,nKey)
EJECUTAR("LIBCOMVALCONISLR",oCol,uValue,nCol,nKey,oLIBCOMEDIT)

FUNCTION VALNUMISR(oCol,uValue,nCol,nKey)
EJECUTAR("LIBCOMVALNUMISR",oCol,uValue,nCol,nKey,oLIBCOMEDIT)

/*
// Valida monto exento
*/
FUNCTION VALLBCMTOEXE(oCol,uValue,nCol,nKey)
 LOCAL cTipIva:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPIVA]
 
 oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,nCol,nKey)

 oCol:oBrw:aCols[oCol:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_TIPIVA]

 oLIBCOMEDIT:PUTTIPIVA(oCol,cTipIva,oLIBCOMEDIT:COL_LBC_TIPIVA)

RETURN .T.

FUNCTION LBCMSGERR(cMsg,cTitle)
   
   DEFAULT cTitle:="Validaci�n"

   EJECUTAR("XSCGMSGERR",oLIBCOMEDIT:oBrw,cMsg,cTitle)

RETURN .T.

/*
FUNCTION SETCREFIS()
  LOCAL oCol  :=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_CREFIS]
  LOCAL uValue:=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_CREFIS]

 MensajeErr(ValType(uValue),oCol:ClassName())

//                                           oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,oLIBCOMEDIT:COL_LBC_CREFIS,nKey)}
// oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,nCol,nKey)

RETURN .T.
*/

/*
// Barra de Botones
*/
FUNCTION VIEWDATBAR()
   LOCAL oCursor,oBar,oBtn,oFont,oFontB,oCol,lSay:=.F.
   LOCAL oDlg:=NIL // IF(oLIBCOMEDIT:lTmdi,oLIBCOMEDIT:oWnd,oLIBCOMEDIT:oDlg)
   LOCAL nLin:=2,nCol:=0,nAt
   LOCAL nWidth:=0 // oLIBCOMEDIT:oBrw:nWidth()
   LOCAL nAdd  :=55+4

   IF oLIBCOMEDIT=NIL
      RETURN .F.
   ENDIF

   oDlg  :=IF(oLIBCOMEDIT:lTmdi,oLIBCOMEDIT:oWnd,oLIBCOMEDIT:oDlg)
   nWidth:=oLIBCOMEDIT:oBrw:nWidth()

   oLIBCOMEDIT:oBrw:GoBottom(.T.)
   oLIBCOMEDIT:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+40 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont   NAME "Tahoma"   SIZE 0, -10 BOLD
   DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0, -10 BOLD

   oLIBCOMEDIT:oFontBtn   :=oFont    
   oLIBCOMEDIT:nClrPaneBar:=oDp:nGris
   oLIBCOMEDIT:oBrw:oLbx  :=oLIBCOMEDIT

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP";
          TOP PROMPT "Grabar"; 
          ACTION oLIBCOMEDIT:LIBCOMSAVE()

   oBtn:cToolTip:="Guardar en Documentos del Proveedor"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XNEW.BMP";
          TOP PROMPT "Incluir"; 
          ACTION oLIBCOMEDIT:LIBADDITEM()

   oBtn:cToolTip:="Insertar nuevo Item en el mismo documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIZAR.BMP";
          TOP PROMPT "Contab"; 
          ACTION oLIBCOMEDIT:CONTABILIZAR()

   oBtn:cToolTip:="Contabilizar Documentos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP";
          TOP PROMPT "Doc."; 
          ACTION oLIBCOMEDIT:CREARDOC(.T.)

   oBtn:cToolTip:="Crear Documento"

   oLIBCOMEDIT:oBtnForm:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\MENU.BMP";
          TOP PROMPT "Men�"; 
          ACTION oLIBCOMEDIT:CREARDOC(.F.)

   oBtn:cToolTip:="Men� del Documento"

   oLIBCOMEDIT:oBtnMenu:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\seniat.BMP";
          TOP PROMPT "Seniat"; 
          ACTION oLIBCOMEDIT:VALRIFSENIAT2()

   oBtn:cToolTip:="Obtener datos del SENIAT"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP";
          TOP PROMPT "Eliminar"; 
          ACTION oLIBCOMEDIT:DELASIENTOS()

   oBtn:cToolTip:="Activar/Inactivar Registro"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oLIBCOMEDIT:oWnd:IsZoomed(),oLIBCOMEDIT:oWnd:Restore(),oLIBCOMEDIT:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"


   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","LIBCOMEDIT"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oLIBCOMEDIT:oBrw,"LIBCOMEDIT",oLIBCOMEDIT:cSql,oLIBCOMEDIT:nPeriodo,oLIBCOMEDIT:dDesde,oLIBCOMEDIT:dHasta,oLIBCOMEDIT)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oLIBCOMEDIT:oBtnRun:=oBtn



       oLIBCOMEDIT:oBrw:bLDblClick:={||EVAL(oLIBCOMEDIT:oBtnRun:bAction) }


   ENDIF




IF oLIBCOMEDIT:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oLIBCOMEDIT");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oLIBCOMEDIT:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oLIBCOMEDIT:lBtnColor

     oLIBCOMEDIT:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Colorear"; 
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oLIBCOMEDIT:oBrw,oLIBCOMEDIT,oLIBCOMEDIT:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oLIBCOMEDIT,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oLIBCOMEDIT,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oLIBCOMEDIT:oBtnColor:=oBtn

ENDIF




IF oLIBCOMEDIT:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oLIBCOMEDIT),;
                  EJECUTAR("DPBRWMENURUN",oLIBCOMEDIT,oLIBCOMEDIT:oBrw,oLIBCOMEDIT:cBrwCod,oLIBCOMEDIT:cTitle,oLIBCOMEDIT:aHead));
          WHEN !Empty(oLIBCOMEDIT:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Men� de Opciones"

ENDIF


IF oLIBCOMEDIT:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION EJECUTAR("BRWSETFIND",oLIBCOMEDIT:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oLIBCOMEDIT:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtra"; 
          MENU EJECUTAR("BRBTNMENUFILTER",oLIBCOMEDIT:oBrw,oLIBCOMEDIT);
          ACTION EJECUTAR("BRWSETFILTER",oLIBCOMEDIT:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oLIBCOMEDIT:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION EJECUTAR("BRWSETOPTIONS",oLIBCOMEDIT:oBrw);
          WHEN LEN(oLIBCOMEDIT:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar seg�n Valores Comunes"

ENDIF

IF oLIBCOMEDIT:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar"; 
          ACTION oLIBCOMEDIT:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oLIBCOMEDIT:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oLIBCOMEDIT)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oLIBCOMEDIT:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
            ACTION (EJECUTAR("BRWTOEXCEL",oLIBCOMEDIT:oBrw,oLIBCOMEDIT:cTitle,oLIBCOMEDIT:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oLIBCOMEDIT:oBtnXls:=oBtn

ENDIF

IF oLIBCOMEDIT:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "HTML"; 
          FILENAME "BITMAPS\html.BMP";
          ACTION (oLIBCOMEDIT:HTMLHEAD(),EJECUTAR("BRWTOHTML",oLIBCOMEDIT:oBrw,NIL,oLIBCOMEDIT:cTitle,oLIBCOMEDIT:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oLIBCOMEDIT:oBtnHtml:=oBtn

ENDIF


IF oLIBCOMEDIT:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Vista"; 
          ACTION (EJECUTAR("BRWPREVIEW",oLIBCOMEDIT:oBrw))

   oBtn:cToolTip:="Previsualizaci�n"

   oLIBCOMEDIT:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRLIBCOMEDIT")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Imprimir"; 
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oLIBCOMEDIT:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oLIBCOMEDIT:oBtnPrint:=oBtn

   ENDIF

/*
IF oLIBCOMEDIT:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Query"; 
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oLIBCOMEDIT:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION (oLIBCOMEDIT:oBrw:GoTop(),oLIBCOMEDIT:oBrw:Setfocus())
/*
IF nWidth>800 .OR. nWidth=0

   IF oLIBCOMEDIT:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oLIBCOMEDIT:oBrw:PageDown(),oLIBCOMEDIT:oBrw:Setfocus())
  ENDIF

  IF  oLIBCOMEDIT:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oLIBCOMEDIT:oBrw:PageUp(),oLIBCOMEDIT:oBrw:Setfocus())
  ENDIF

ENDIF
*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Ultimo"; 
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oLIBCOMEDIT:oBrw:GoBottom(),oLIBCOMEDIT:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Salir"; 
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oLIBCOMEDIT:Close()

  oLIBCOMEDIT:oBrw:SetColor(0,oLIBCOMEDIT:nClrPane1)

  nCol:=80
  oLIBCOMEDIT:SETBTNBAR(40,30,oBar)

  EVAL(oLIBCOMEDIT:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),nCol:=nCol+o:nWidth()})

  nCol:=-10	

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 1.5+nAdd,nCol+32  SAY oSay PROMPT " Declarar " OF oBar;
               SIZE 70,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane PIXEL FONT oFont BORDER RIGHT

  @ 1.5+nAdd,nCol+102 SAY oSay PROMPT " "+DTOC(oLIBCOMEDIT:dFchDec) OF oBar;
               SIZE 90,20 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL FONT oFont BORDER


  @ 22+nAdd,nCol+32  SAY oSay PROMPT " Pago " OF oBar;
               SIZE 70,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane PIXEL FONT oFont BORDER RIGHT

  @ 22+nAdd,nCol+102 SAY oSay PROMPT " "+DTOC(oLIBCOMEDIT:dFchPag) OF oBar;
               SIZE 90,20 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL FONT oFont BORDER

  oLIBCOMEDIT:SETBTNBAR(52,60,oBar)


  IF !Empty(oLIBCOMEDIT:cCodCaj)
  
    nCol:=20
    nLin:=20+20

    oBar:SetSize(200,oBar:nHeight()+25,.T.)

    @ nLin+27,nCol+001 SAY " Caja " OF oBar;
                       BORDER SIZE 074,20;
                       COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

    @ nLin+27,nCol+076 SAY " "+oLIBCOMEDIT:cCodCaj+" " OF oBar;
                       BORDER SIZE 070,20;
                       COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

    @ nLin+27,nCol+148 SAY " "+SQLGET("DPCAJA","CAJ_NOMBRE","CAJ_CODIGO"+GetWhere("=",oLIBCOMEDIT:cCodCaj))+" " OF oBar;
                       BORDER SIZE 320,20;
                       COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

    lSay:=.T.

  ENDIF

  IF !Empty(oLIBCOMEDIT:cCodCli)
  
    nCol:=20
    nLin:=20+20+20+15

    oBar:SetSize(200,oBar:nHeight()+25,.T.)

    @ nLin+27,nCol+001 SAY " Cliente " OF oBar;
                       BORDER SIZE 072,20;
                       COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

    @ nLin+27,nCol+076-3 SAY " "+oLIBCOMEDIT:cCodCli+" " OF oBar;
                         BORDER SIZE 070+20,20;
                         COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

    @ nLin+27,nCol+148+24-7 SAY " "+SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oLIBCOMEDIT:cCodCli))+" " OF oBar;
                       BORDER SIZE 320,20;
                       COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

    lSay:=.T.

  ENDIF


  IF !Empty(oLIBCOMEDIT:cCenCos)
  
    nCol:=20
    nLin:=20+20+35

    oBar:SetSize(200,oBar:nHeight()+25,.T.)

    @ nLin+27,nCol+001 SAY oDp:XDPCENCOS+" " OF oBar;
                       BORDER SIZE 074+80+6,20;
                       COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

    @ nLin+27,nCol+076+6+80 SAY " "+oLIBCOMEDIT:cCenCos+" " OF oBar;
                         BORDER SIZE 070+20,20;
                         COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

    @ nLin+27,nCol+148+26+80 SAY " "+SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oLIBCOMEDIT:cCenCos))+" " OF oBar;
                       BORDER SIZE 320,20;
                       COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

    lSay:=.T.

  ENDIF


  IF !Empty(oLIBCOMEDIT:cNumRei)
  
    nCol:=20
    nLin:=20+20

    oBar:SetSize(200,oBar:nHeight()+25,.T.)

    @ nLin+27,nCol+001 SAY " Proveedor " OF oBar;
                       BORDER SIZE 074,20;
                       COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 80,20 PIXEL RIGHT

    @ nLin+27,nCol+078 BMPGET oLIBCOMEDIT:oCodPro VAR oLIBCOMEDIT:cCodPro;
                       VALID oLIBCOMEDIT:VALCODPRO();
                       NAME "BITMAPS\FIND.BMP";
                       ACTION (oDpLbx:=DpLbx("DPPROVEEDOR",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oLIBCOMEDIT:oCodPro), oDpLbx:GetValue("PRO_CODIGO",oLIBCOMEDIT:oCodPro)); 
                       SIZE 100,21 OF oLIBCOMEDIT:oBar FONT oFontB PIXEL

     @ oLIBCOMEDIT:oCodPro:nTop(),oLIBCOMEDIT:oCodPro:nRight()+20 SAY oLIBCOMEDIT:oNomPro;
                                        PROMPT SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",oLIBCOMEDIT:cCodPro)) OF oBar;
                                        SIZE 150+150,20 PIXEL FONT oFontB;
                                        COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL BORDER

     oLIBCOMEDIT:oCodPro:bkeyDown:={|nkey| IIF(nKey=13, oLIBCOMEDIT:VALCODPRO(),NIL) }

     BMPGETBTN(oLIBCOMEDIT:oCodPro)

     lSay:=.T.

  ENDIF

  IF !lSay

    DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -28 BOLD 

    nLin:=42
    nCol:=250
    
    IF oLIBCOMEDIT:lCondom

      @ nLin+27,nCol+001 SAY " Gastos del Condominio " OF oBar;
                         BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 280+140,34 PIXEL 

    ELSE

      @ nLin+27,nCol+001 SAY IF(oLIBCOMEDIT:lVenta," Libro de Ventas"," Libro de Compras") OF oBar;
                         BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 280,34 PIXEL 

    ENDIF

  ENDIF

  oLIBCOMEDIT:oBar:=oBar

  nAt:=ASCAN(oLIBCOMEDIT:oBrw:aArrayData,{|a,n| Empty(a[oLIBCOMEDIT:COL_LBC_FECHA])})

  IF nAt=0
    oLIBCOMEDIT:LIBCOMADDLINE()
  ENDIF

RETURN .T.

FUNCTION SETMTOBAS(oCol,uValue,nCol,nColIva)
   LOCAL nKey

   oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,nCol]:=uValue

   oLIBCOMEDIT:PUTFIELDVALUE(oCol,uValue,nCol,nKey,NIL,.F.)

   oLIBCOMEDIT:CALMTOIVA()
   oLIBCOMEDIT:oBrw:DrawLine(.T.)
   oLIBCOMEDIT:oBrw:GoRight()

RETURN .T.
/*
// Calcula el IVA
*/
FUNCTION CALMTOIVA()
   LOCAL I,nMontoIva:=0,nPorcen:=0,nNeto:=0,nBase:=0,nKey:=NIL
   LOCAL oColIva:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTOIVA]
   LOCAL oColNet:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_MTONET]
   LOCAL oPorRti:=oLIBCOMEDIT:oBrw:aCols[oLIBCOMEDIT:COL_LBC_PORRTI]
   LOCAL nPorRti:=oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_PORRTI]


   FOR I=1 TO LEN(oLIBCOMEDIT:aValPorIva)
     nPorcen  :=oLIBCOMEDIT:aValPorIva[I]
     nBase    :=nBase+oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,11+I]
     nMontoIva:=nMontoIva+PORCEN(oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,11+I],nPorcen)
   NEXT I

   oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTOIVA]:=nMontoIva
   oLIBCOMEDIT:oBrw:aArrayData[oLIBCOMEDIT:oBrw:nArrayAt,oLIBCOMEDIT:COL_LBC_MTONET]:=nBase+nMontoIva

   oLIBCOMEDIT:PUTFIELDVALUE(oColIva,nMontoIva      ,oLIBCOMEDIT:COL_LBC_MTOIVA,nKey,NIL,NIL,.F.)
   oLIBCOMEDIT:PUTFIELDVALUE(oColNet,nMontoIva+nBase,oLIBCOMEDIT:COL_LBC_MTONET,nKey,NIL,NIL,.F.)

   IF nPorRti>0
      oLIBCOMEDIT:VALPORRTI(oPorRti,nPorRti,oLIBCOMEDIT:COL_LBC_PORRTI,nKey)
   ENDIF

RETURN nMontoIva
// EOF

