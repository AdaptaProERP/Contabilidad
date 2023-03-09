// Programa   : BRDOCPRORESXCNT
// Fecha/Hora : 26/12/2018 08:47:24
// Propósito  : "Resumen de Documentos de Proveedores por Contabilizar"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRDOCPRORESXCNT.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oDOCPRORESXCNT")="O" .AND. oDOCPRORESXCNT:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDOCPRORESXCNT,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Resumen de Documentos de Proveedores por Contabilizar" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

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

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oDOCPRORESXCNT
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oDOCPRORESXCNT","BRDOCPRORESXCNT.EDT")

// oDOCPRORESXCNT:CreateWindow(0,0,100,550)
   oDOCPRORESXCNT:Windows(0,0,aCoors[3]-160,MIN(830+140+200,aCoors[4]-10),.T.) // Maximizado

//   oDOCPRORESXCNT:cNumero :=EJECUTAR("DPNUMCBTE","CXPOBR")
   oDOCPRORESXCNT:cNumero :=EJECUTAR("DPNUMCBTEXTIPDOC","DPTIPDOCPRO","",oDp:dFecha)
   oDOCPRORESXCNT:cCodSuc  :=cCodSuc
   oDOCPRORESXCNT:lMsgBar  :=.F.
   oDOCPRORESXCNT:cPeriodo :=aPeriodos[nPeriodo]
   oDOCPRORESXCNT:cCodSuc  :=cCodSuc
   oDOCPRORESXCNT:nPeriodo :=nPeriodo
   oDOCPRORESXCNT:cNombre  :=""
   oDOCPRORESXCNT:dDesde   :=dDesde
   oDOCPRORESXCNT:cServer  :=cServer
   oDOCPRORESXCNT:dHasta   :=dHasta
   oDOCPRORESXCNT:cWhere   :=cWhere
   oDOCPRORESXCNT:cWhere_  :=cWhere_
   oDOCPRORESXCNT:cWhereQry:=""
   oDOCPRORESXCNT:cSql     :=oDp:cSql
   oDOCPRORESXCNT:oWhere   :=TWHERE():New(oDOCPRORESXCNT)
   oDOCPRORESXCNT:cCodPar  :=cCodPar // Código del Parámetro
   oDOCPRORESXCNT:lWhen    :=.T.
   oDOCPRORESXCNT:cTextTit :="" // Texto del Titulo Heredado
   oDOCPRORESXCNT:oDb      :=oDp:oDb
   oDOCPRORESXCNT:cBrwCod  :="DOCPRORESXCNT"
   oDOCPRORESXCNT:lTmdi    :=.T.
   oDOCPRORESXCNT:nCuantos :=0
   oDOCPRORESXCNT:lTodos   :=.T.

   oDOCPRORESXCNT:cCodInt  :="CXPNAC"
   oDOCPRORESXCNT:cCodCta  :=ALLTRIM(SQLGET("DPCODINTEGRA","CIN_CODCTA","CIN_CODIGO"+GetWhere("=",oDOCPRORESXCNT:cCodInt)))
   oDOCPRORESXCNT:cDescri  :=ALLTRIM(SQLGET("DPCTA"       ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oDOCPRORESXCNT:cCodCta)))

   oDOCPRORESXCNT:cComInt  :="COMNAC"
   oDOCPRORESXCNT:cComCta  :=ALLTRIM(SQLGET("DPCODINTEGRA","CIN_CODCTA","CIN_CODIGO"+GetWhere("=",oDOCPRORESXCNT:cComInt)))
   oDOCPRORESXCNT:cComNom  :=ALLTRIM(SQLGET("DPCTA"       ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oDOCPRORESXCNT:cComCta)))

   oDOCPRORESXCNT:oBrw:=TXBrowse():New( IF(oDOCPRORESXCNT:lTmdi,oDOCPRORESXCNT:oWnd,oDOCPRORESXCNT:oDlg ))
   oDOCPRORESXCNT:oBrw:SetArray( aData, .F. )
   oDOCPRORESXCNT:oBrw:SetFont(oFont)

   oDOCPRORESXCNT:oBrw:lFooter     := .T.
   oDOCPRORESXCNT:oBrw:lHScroll    := .T.
   oDOCPRORESXCNT:oBrw:nHeaderLines:= 3
   oDOCPRORESXCNT:oBrw:nDataLines  := 1
   oDOCPRORESXCNT:oBrw:nFooterLines:= 1

  oDOCPRORESXCNT:aData    :=ACLONE(aData)
  oDOCPRORESXCNT:nClrText :=0
  oDOCPRORESXCNT:nClrPane1:=16771538
  oDOCPRORESXCNT:nClrPane2:=16765348

  oDOCPRORESXCNT:nClrText1:=CLR_HBLUE
  oDOCPRORESXCNT:cClrText1:="Seleccionados"

  AEVAL(oDOCPRORESXCNT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oDOCPRORESXCNT:oBrw:aCols[1]
  oCol:cHeader      :='Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 34

  oCol:=oDOCPRORESXCNT:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 240
  oCol:cFooter      :="Integración [CXPNAC] "+oDOCPRORESXCNT:cCodCta+":"+oDOCPRORESXCNT:cDescri


  oCol:=oDOCPRORESXCNT:oBrw:aCols[3]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oDOCPRORESXCNT:oBrw:aCols[4]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oDOCPRORESXCNT:oBrw:aCols[5]
  oCol:cHeader      :='X'+CRLF+'Cont.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 45
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,5],FDP(nMonto,'999,999')}
   oCol:cFooter      :=FDP(aTotal[5],'999,999')


  oCol:=oDOCPRORESXCNT:oBrw:aCols[6]
  oCol:cHeader      :='Conta-'+CRLF+"biliz."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 45
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,6],;
                                    oCol  := oDOCPRORESXCNT:oBrw:aCols[6],;
                                    FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)




  oCol:=oDOCPRORESXCNT:oBrw:aCols[7]
  oCol:cHeader      :='Monto'+CRLF+'por Contab'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 130
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999,999,999,999.99'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,7],;
                                    oCol  := oDOCPRORESXCNT:oBrw:aCols[7],;
                                    FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


  oCol:=oDOCPRORESXCNT:oBrw:aCols[8]
  oCol:cHeader      :='Cant.'+CRLF+'Docs'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,8],FDP(nMonto,'999,999')}
   oCol:cFooter      :=FDP(aTotal[8],'999,999')

  oCol:=oDOCPRORESXCNT:oBrw:aCols[9]
  oCol:cHeader      :='Sel.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { ||oBrw:=oDOCPRORESXCNT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,9],1,2) }
 oCol:bLDClickData:={||oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,9]:=!oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,9],oDOCPRORESXCNT:oBrw:DrawLine(.T.)} 
 oCol:bStrData    :={||""}
 oCol:bLClickHeader:={||oDp:lSel:=!oDOCPRORESXCNT:oBrw:aArrayData[1,9],; 
 AEVAL(oDOCPRORESXCNT:oBrw:aArrayData,{|a,n| oDOCPRORESXCNT:oBrw:aArrayData[n,9]:=oDp:lSel}),oDOCPRORESXCNT:oBrw:Refresh(.T.)} 


  oCol:=oDOCPRORESXCNT:oBrw:aCols[10]
  oCol:cHeader      :='Cuenta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
//  oCol:bLDblClick   :={|oBrw|oDOCPRORESXCNT:EDITTIPDOCCLI() }



  oCol:=oDOCPRORESXCNT:oBrw:aCols[11]
  oCol:cHeader      :='Descripción de la Cuenta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCPRORESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120+120



   oDOCPRORESXCNT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDOCPRORESXCNT:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDOCPRORESXCNT:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=iif( oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,9], oDOCPRORESXCNT:nClrText1,  oDOCPRORESXCNT:nClrText ),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDOCPRORESXCNT:nClrPane1, oDOCPRORESXCNT:nClrPane2 ) } }

   oDOCPRORESXCNT:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDOCPRORESXCNT:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oDOCPRORESXCNT:oBrw:bLDblClick:={|oBrw|oDOCPRORESXCNT:RUNCLICK() }

   oDOCPRORESXCNT:oBrw:bChange:={||oDOCPRORESXCNT:BRWCHANGE()}
   oDOCPRORESXCNT:oBrw:CreateFromCode()
   oDOCPRORESXCNT:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDOCPRORESXCNT)}
   oDOCPRORESXCNT:BRWRESTOREPAR()

   oDOCPRORESXCNT:oWnd:oClient := oDOCPRORESXCNT:oBrw

   oDOCPRORESXCNT:Activate({||oDOCPRORESXCNT:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDOCPRORESXCNT:lTmdi,oDOCPRORESXCNT:oWnd,oDOCPRORESXCNT:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oDOCPRORESXCNT:oBrw:nWidth()

   oDOCPRORESXCNT:oBrw:GoBottom(.T.)
   oDOCPRORESXCNT:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRDOCPRORESXCNT.EDT")
//     oDOCPRORESXCNT:oBrw:Move(44,0,704+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          MENU oDOCPRORESXCNT:MENUCONTAB();
          ACTION oDOCPRORESXCNT:HACERASIENTO();
          WHEN !Empty(oDOCPRORESXCNT:cNumero)

   oBtn:cToolTip:="Ejecutar Proceso de Contabilizar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP",NIL,"BITMAPS\XDELETEG.BMP";
          ACTION oDOCPRORESXCNT:REHACER();
          WHEN !Empty(oDOCPRORESXCNT:cNumero)

   oBtn:cToolTip:="Remover Asientos Automáticos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          MENU EJECUTAR("BRBTNMENU",{"Conciliación vs Asientos",;
                                     "Inconsistencia Documentos Vs Asientos",;
                                     "Inconsistencia Cronológica de Asientos",;
                                     "Asientos por Actualizar",;
                                     "Proveedores con Cuentas Indefinidas",;
                                     "Tipo de Documento con Cuenta Indefinida",;
                                     "Documentos con Cuentas Indefinidas",;
                                     "Documentos con Valor Cero ",;
                                     "Integración [CXPNAC] "+oDOCPRORESXCNT:cCodCta+":"+oDOCPRORESXCNT:cDescri,;
                                     "Integración [COMNAC] "+oDOCPRORESXCNT:cComCta+":"+oDOCPRORESXCNT:cComNom,;
                                     "Integración con Cuentas Indefinidas"},;
                                     "oDOCPRORESXCNT");
          FILENAME "BITMAPS\XBROWSE2.BMP";
          ACTION oDOCPRORESXCNT:VERASIENTOS()

   oBtn:cToolTip:="Opciones de Conciliación"
  
/*
   IF Empty(oDOCPRORESXCNT:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","DOCPRORESXCNT")))
*/

/*
   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DOCPRORESXCNT"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oDOCPRORESXCNT:oBrw,"DOCPRORESXCNT",oDOCPRORESXCNT:cSql,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,oDOCPRORESXCNT)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oDOCPRORESXCNT:oBtnRun:=oBtn

       oDOCPRORESXCNT:oBrw:bLDblClick:={||EVAL(oDOCPRORESXCNT:oBtnRun:bAction) }

   ENDIF
*/
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oDOCPRORESXCNT:VERLISTA()

   oBtn:cToolTip:="Ver Documentos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oDOCPRORESXCNT:oBrw,oDOCPRORESXCNT);
          ACTION EJECUTAR("BRWSETFILTER",oDOCPRORESXCNT:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oDOCPRORESXCNT:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oDOCPRORESXCNT:HTMLHEAD(),EJECUTAR("BRWTOHTML",oDOCPRORESXCNT:oBrw,NIL,oDOCPRORESXCNT:cTitle,oDOCPRORESXCNT:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oDOCPRORESXCNT:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oDOCPRORESXCNT:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDOCPRORESXCNT:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDOCPRORESXCNT")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oDOCPRORESXCNT:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDOCPRORESXCNT:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDOCPRORESXCNT:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oDOCPRORESXCNT:oBrw:GoTop(),oDOCPRORESXCNT:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oDOCPRORESXCNT:oBrw:PageDown(),oDOCPRORESXCNT:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oDOCPRORESXCNT:oBrw:PageUp(),oDOCPRORESXCNT:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDOCPRORESXCNT:oBrw:GoBottom(),oDOCPRORESXCNT:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDOCPRORESXCNT:Close()

  oDOCPRORESXCNT:oBrw:SetColor(0,oDOCPRORESXCNT:nClrPane1)

  EVAL(oDOCPRORESXCNT:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDOCPRORESXCNT:oBar:=oBar

  nLin:=344

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin-4 COMBOBOX oDOCPRORESXCNT:oPeriodo  VAR oDOCPRORESXCNT:cPeriodo ITEMS aPeriodos;
                SIZE 100+4,200+6;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oDOCPRORESXCNT:LEEFECHAS();
                WHEN oDOCPRORESXCNT:lWhen 


  ComboIni(oDOCPRORESXCNT:oPeriodo )

  @ 10, nLin+103 BUTTON oDOCPRORESXCNT:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDOCPRORESXCNT:oPeriodo:nAt,oDOCPRORESXCNT:oDesde,oDOCPRORESXCNT:oHasta,-1),;
                         EVAL(oDOCPRORESXCNT:oBtn:bAction));
                WHEN oDOCPRORESXCNT:lWhen 


  @ 10, nLin+130 BUTTON oDOCPRORESXCNT:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDOCPRORESXCNT:oPeriodo:nAt,oDOCPRORESXCNT:oDesde,oDOCPRORESXCNT:oHasta,+1),;
                         EVAL(oDOCPRORESXCNT:oBtn:bAction));
                WHEN oDOCPRORESXCNT:lWhen 


  @ 10, nLin+170-9 BMPGET oDOCPRORESXCNT:oDesde  VAR oDOCPRORESXCNT:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDOCPRORESXCNT:oDesde ,oDOCPRORESXCNT:dDesde);
                SIZE 76+8,24;
                OF   oBar;
                WHEN oDOCPRORESXCNT:oPeriodo:nAt=LEN(oDOCPRORESXCNT:oPeriodo:aItems) .AND. oDOCPRORESXCNT:lWhen ;
                FONT oFont

   oDOCPRORESXCNT:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252-4 BMPGET oDOCPRORESXCNT:oHasta  VAR oDOCPRORESXCNT:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDOCPRORESXCNT:oHasta,oDOCPRORESXCNT:dHasta);
                SIZE 80+4,24;
                WHEN oDOCPRORESXCNT:oPeriodo:nAt=LEN(oDOCPRORESXCNT:oPeriodo:aItems) .AND. oDOCPRORESXCNT:lWhen ;
                OF oBar;
                FONT oFont

   oDOCPRORESXCNT:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oDOCPRORESXCNT:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oDOCPRORESXCNT:oPeriodo:nAt=LEN(oDOCPRORESXCNT:oPeriodo:aItems);
               ACTION oDOCPRORESXCNT:HACERWHERE(oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,oDOCPRORESXCNT:cWhere,.T.);
               WHEN oDOCPRORESXCNT:lWhen


  @ 10,nLin+380 SAY oDOCPRORESXCNT:oSay    PROMPT "Número " SIZE 80,20 RIGHT OF oBar PIXEL BORDER;
                COLOR oDp:nClrLabelText,oDp:nClrLabelPane   FONT oFont

  @ 10,nLin+460 GET oDOCPRORESXCNT:oNumero VAR oDOCPRORESXCNT:cNumero OF oBar PIXEL SIZE 80,20 ;
                COLOR oDp:nClrYellowText,oDp:nClrYellow  FONT oFont
 
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  @ 01,nLin+380 SAY   oDOCPRORESXCNT:oSayProgress PROMPT "Lectura"             OF oBar PIXEL SIZE 160,20;
                      COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  @ 20,nLin+380 METER oDOCPRORESXCNT:oMeter       VAR oDOCPRORESXCNT:nCuantos  OF oBar PIXEL SIZE 160,20
 
  oDOCPRORESXCNT:oSayProgress:Hide()
  oDOCPRORESXCNT:oMeter:Hide()

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL cWhere:=NIL,cCodSuc:=NIL,nPeriodo:=NIL,dDesde:=NIL,dHasta:=NIL,cTitle:=NIL,lView:=NIL
  LOCAL cTipDoc:=oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,1]

  IF oDOCPRORESXCNT:oBrw:nColSel=10
    // EJECUTAR("DPTIPDOCPRO",3,cTipDoc)
    // DPFOCUS(oTIPDOCPRO:oTDC_CODCTA)
    cWhere:="TDC_TIPO"+GetWhere("=",cTipDoc)
    EJECUTAR("BRTIPDOCCLICTA",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,lView)

  ENDIF

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRDOCPRORESXCNT",cWhere)
  oRep:cSql  :=oDOCPRORESXCNT:cSql
  oRep:cTitle:=oDOCPRORESXCNT:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDOCPRORESXCNT:oPeriodo:nAt,cWhere

  oDOCPRORESXCNT:nPeriodo:=nPeriodo


  IF oDOCPRORESXCNT:oPeriodo:nAt=LEN(oDOCPRORESXCNT:oPeriodo:aItems)

     oDOCPRORESXCNT:oDesde:ForWhen(.T.)
     oDOCPRORESXCNT:oHasta:ForWhen(.T.)
     oDOCPRORESXCNT:oBtn  :ForWhen(.T.)

     DPFOCUS(oDOCPRORESXCNT:oDesde)

  ELSE

     oDOCPRORESXCNT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDOCPRORESXCNT:oDesde:VarPut(oDOCPRORESXCNT:aFechas[1] , .T. )
     oDOCPRORESXCNT:oHasta:VarPut(oDOCPRORESXCNT:aFechas[2] , .T. )

     oDOCPRORESXCNT:dDesde:=oDOCPRORESXCNT:aFechas[1]
     oDOCPRORESXCNT:dHasta:=oDOCPRORESXCNT:aFechas[2]

     cWhere:=oDOCPRORESXCNT:HACERWHERE(oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,oDOCPRORESXCNT:cWhere,.T.)

     oDOCPRORESXCNT:LEERDATA(cWhere,oDOCPRORESXCNT:oBrw,oDOCPRORESXCNT:cServer)

  ENDIF

  oDOCPRORESXCNT:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDOCPRO.DOC_FCHDEC"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCPRO.DOC_FCHDEC',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCPRO.DOC_FCHDEC',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oDOCPRORESXCNT:cWhereQry)
       cWhere:=cWhere + oDOCPRORESXCNT:cWhereQry
     ENDIF

     oDOCPRORESXCNT:LEERDATA(cWhere,oDOCPRORESXCNT:oBrw,oDOCPRORESXCNT:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

/*
   cSql:=" SELECT  "+;
          "  DOC_TIPDOC, "+;
          "  TDC_DESCRI, "+;
          "  MIN(IF(DOC_CBTNUM='',DOC_FECHA,NULL)) AS DESDE, "+;
          "  MAX(IF(DOC_CBTNUM='',DOC_FECHA,NULL)) AS HASTA, "+;
          "  COUNT(IF(DOC_CBTNUM='',1, NULL)) AS XCONTAB, "+;
          "  COUNT(IF(DOC_CBTNUM<>'',1, NULL)) AS CONTAB, "+;
            " SUM(IF(DOC_CBTNUM='',DOC_NETO*DOC_CXP,0)) AS SUMXCON, "+;
          "  COUNT(*) AS CUANTOS,"+;
          "  1 AS LOGICO,TDC_CODCTA "+;
          "  FROM DPDOCPRO "+;
          "  INNER JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO AND TDC_CONTAB=1 "+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DOC_CODSUC=&oDp:cSucursal AND DOC_TIPTRA='D' AND DOC_ACT=1 AND DOC_DOCORG<>'P' "+;
          "  GROUP BY DOC_TIPDOC "+;
""
*/

   cSql:=" SELECT  "+;
          "  DOC_TIPDOC, "+;
          "  TDC_DESCRI, "+;
          "  MIN(DOC_FCHDEC) AS DESDE, "+;
          "  MAX(DOC_FCHDEC) AS HASTA, "+;
          "  COUNT(IF(DOC_CBTNUM='',1, NULL)) AS XCONTAB, "+;
          "  COUNT(IF(DOC_CBTNUM<>'',1, NULL)) AS CONTAB, "+;
            " SUM(IF(DOC_CBTNUM='',DOC_NETO*DOC_CXP,0)) AS SUMXCON, "+;
          "  COUNT(*) AS CUANTOS,"+;
          "  1 AS LOGICO,TDC_CODCTA,CTA_DESCRI "+;
          "  FROM DPDOCPRO "+;
          "  INNER JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO AND TDC_CONTAB=1 "+;
          "  LEFT  JOIN DPCTA       ON TDC_CODCTA=CTA_CODIGO "+;
          IF("WHERE"$cWhere,"","  WHERE ")+;
          cWhere+IIF(Empty(cWhere),""," AND ")+" DOC_CODSUC=&oDp:cSucursal AND DOC_TIPTRA='D' AND DOC_ACT=1 AND DOC_DOCORG<>'P' "+;
          "  GROUP BY DOC_TIPDOC "+;
          ""
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRDOCPRORESXCNT.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
   ENDIF

   IF ValType(oBrw)="O"

      oDOCPRORESXCNT:cSql   :=cSql
      oDOCPRORESXCNT:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oDOCPRORESXCNT:oBrw:aCols[5]
      oCol:cFooter      :=FDP(aTotal[5],'999,999')
      oCol:=oDOCPRORESXCNT:oBrw:aCols[6]
      oCol:cFooter      :=FDP(aTotal[6],'999,999')
      oCol:=oDOCPRORESXCNT:oBrw:aCols[7]
      oCol:cFooter      :=FDP(aTotal[7],'999,999,999,999,999')

      oDOCPRORESXCNT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oDOCPRORESXCNT:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDOCPRORESXCNT:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDOCPRORESXCNT.MEM",V_nPeriodo:=oDOCPRORESXCNT:nPeriodo
  LOCAL V_dDesde:=oDOCPRORESXCNT:dDesde
  LOCAL V_dHasta:=oDOCPRORESXCNT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDOCPRORESXCNT)
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


    IF Type("oDOCPRORESXCNT")="O" .AND. oDOCPRORESXCNT:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDOCPRORESXCNT:cWhere_),oDOCPRORESXCNT:cWhere_,oDOCPRORESXCNT:cWhere)
      cWhere:=STRTRAN(cWhere,"WHERE ","")

      oDOCPRORESXCNT:LEERDATA(oDOCPRORESXCNT:cWhere_,oDOCPRORESXCNT:oBrw,oDOCPRORESXCNT:cServer)
      oDOCPRORESXCNT:oWnd:Show()
      oDOCPRORESXCNT:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)
   LOCAL cWhere,nPeriodo:=12
   LOCAL cTitle:=NIL


   IF nOption=1
       oDOCPRORESXCNT:VERCONCIL(.T.,NIL,"[ Vs Asientos ]",.T.,.T.)
   ENDIF

   IF nOption=2
       oDOCPRORESXCNT:VERCONCIL(.F.,NIL,"[ Inconsistentes ]",.T.,.T.)
   ENDIF

   IF nOption=3
       oDOCPRORESXCNT:VERCONCIL(NIL,"DOC_TIPTRA"+GetWhere("=","D")+" AND DATEDIFF(MOC_FECHA,"+IF(oDp:lConFchDec,"DOC_FCHDEC","DOC_FECHA")+")<>0"," [Inconsistencias Cronológicas]",.T.,.F.)
   ENDIF


   IF nOption=4

     cWhere:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
             "MOC_ACTUAL"+GetWhere("=","N"          )+" AND "+;
             "MOC_NUMCBT"+GetWhere("=",oDOCPRORESXCNT:cNumero)

     cTitle:=" [Por Actualizar]"

     EJECUTAR("BRASIENTOSCOM",cWhere,oDp:cSucursal,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)

     RETURN NIL

   ENDIF

   IF nOption=5
      cWhere:=NIL
      cTitle:=NIL
      EJECUTAR("BRDOCPROINDEF",cWhere,oDOCPRORESXCNT:cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)
      RETURN .T.
   ENDIF

   IF nOption=6
      EJECUTAR("BRDOCPROCTAIND",cWhere,oDOCPRORESXCNT:cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)
      RETURN .T.
   ENDIF
  
   IF nOption=7
       EJECUTAR("BRDOCPROCTAINDD",cWhere,oDOCPRORESXCNT:cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)
   ENDIF

   IF nOption=8
//      EJECUTAR("BRCONCTADOCPRO",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,lRun,lContab)
      oDOCPRORESXCNT:VERCONCIL(.F.,NIL,"[ Con Valores en Cero ]",.T.,.T.)
   ENDIF

   IF nOption=09
       EJECUTAR("DPCODINTEGRA",3,oDOCPRORESXCNT:cCodInt)
   ENDIF

   IF nOption=10
       EJECUTAR("DPCODINTEGRA",3,oDOCPRORESXCNT:cComInt)
   ENDIF

   IF nOption=11
      EJECUTAR("DPCONTABEVALCTAINDEF")
   ENDIF


RETURN .T.

FUNCTION HTMLHEAD()

   oDOCPRORESXCNT:aHead:=EJECUTAR("HTMLHEAD",oDOCPRORESXCNT)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

FUNCTION HACERASIENTO(nOption)
  LOCAL oCursor,cSql
  LOCAL aTipDoc:={},cWhere:=IF(oDOCPRORESXCNT:lTodos,"","DOC_CBTNUM"+GetWhere("=",""))
  LOCAL cWhere,cCodSuc,nPeriodo:=oDOCPRORESXCNT:nPeriodo,dDesde:=oDOCPRORESXCNT:dDesde,dHasta:=oDOCPRORESXCNT:dHasta,cTitle:=NIL 
  LOCAL aCbte:={},aLine:={},cActual:="",cFileWhere:="temp\dpasientoswhere.txt",cWhereM:="",nAt

  EJECUTAR("DPDOCPRORETSETFCHDEC")

// ? nOption,"nOption"

  IF nOption=2
     cWhere:="MOC_ORIGEN"+GetWhere("=","COM")
     EJECUTAR("DPCBTEACT",NIL,NIL,NIL,cWhere," Originados desde Compras [Compras]")
     RETURN .T.
  ENDIF


  Aeval(oDOCPRORESXCNT:oBrw:aArrayData,{|a,n|  IIF(a[9] , AADD(aTipDoc,a[1]) , NIL ) })

  IF LEN(aTipDoc)=0
     MensajeErr("Debe Seleccionar los Tipos de Documentos")
     RETURN .F.
  ENDIF

  CursorWait() 

  oDOCPRORESXCNT:oNumero:Hide()
  oDOCPRORESXCNT:oSay:Hide()

  oDOCPRORESXCNT:oSayProgress:Show()
  oDOCPRORESXCNT:oSayProgress:SetText("Leyendo Documentos")

  cSql:=" SELECT DOC_CODIGO,DOC_TIPDOC,DOC_NUMERO,DOC_ESTADO,DOC_IMPOTR,DOC_CENCOS,DOC_CXP,DOC_TIPTRA,DOC_CBTNUM,DOC_FCHDEC FROM DPDOCPRO "+;
        " WHERE DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_TIPTRA='D' AND DOC_DOCORG<>'P' AND DOC_ACT=1 "+;
        "   AND "+GetWhereAnd("DOC_FCHDEC",oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta)+;
        "   AND "+GetWhereOr("DOC_TIPDOC",aTipDoc)+" AND DOC_ACT=1 "+IF(Empty(cWhere),""," AND ")+cWhere+;
        " ORDER BY DOC_FCHDEC,DOC_HORA" // LAS OPCIONES DE DOCUMENTOS NO GUARDAN LA HORA

  oCursor:=OpenTable(cSql,.T.)

  DPWRITE("TEMP\DPDOCPROCONTAB.SQL",cSql)

  IF Empty(oCursor:RecCount())
     oDOCPRORESXCNT:oSayProgress:Hide()
     oDOCPRORESXCNT:oSay:Show()
     oDOCPRORESXCNT:oNumero:Show()
     MensajeErr("No hay Documentos para Contabilizar")
     oCursor:End()
     RETURN .F.
  ENDIF

  IF !MsgNoYes("Contabilizar "+LSTR(oCursor:RecCount())+" Documento(s)")
     oDOCPRORESXCNT:oSayProgress:Hide()
     oDOCPRORESXCNT:oSay:Show()
     oDOCPRORESXCNT:oNumero:Show()
     RETURN .F.
  ENDIF

  oDOCPRORESXCNT:oSay:Hide()
  oDOCPRORESXCNT:oNumero:Hide()

  oDOCPRORESXCNT:oSay:Show()
  oDOCPRORESXCNT:oMeter:Show()

  oCursor:Gotop()

  oDOCPRORESXCNT:oMeter:SetTotal(oCursor:RecCount())

  EJECUTAR("CBTGETNUMPROC") // Obtiene numero del Proceso
 

  WHILE !oCursor:Eof()

     oDOCPRORESXCNT:oSayProgress:SetText("Contabilizando "+oCursor:DOC_TIPDOC+" "+oCursor:DOC_NUMERO)

     oDOCPRORESXCNT:oMeter:Set(oCursor:Recno())

     oDp:cNumCbteCrea:=""
     oDp:cFchCbteCrea:=CTOD("")

     EJECUTAR("DPDOCCONTAB",oDOCPRORESXCNT:cNumero,;
                            oDp:cSucursal,;
                            oCursor:DOC_TIPDOC,;
                            oCursor:DOC_CODIGO,;
                            oCursor:DOC_NUMERO,.F.,.F.)

     IF Empty(oDp:cNumCbteCrea)
        oDp:dFchCbteCrea:=oCursor:DOC_FCHDEC
        oDp:cNumCbteCrea:=oCursor:DOC_CBTNUM
     ENDIF

     cWhere:="CBT_CODSUC"+GetWhere("=",oDp:cSucursal   )+" AND "+;
             "CBT_NUMERO"+GetWhere("=",oDp:cNumCbteCrea)+" AND "+;
             "CBT_FECHA" +GetWhere("=",oDp:dFchCbteCrea)

     cActual:=SQLGET("DPCBTE","CBT_ACTUAL",cWhere)

     aLine:={oDp:cNumCbteCrea,oDp:dcFchCbteCrea,cActual}
     nAt  :=ASCAN(aCbte,{|a,n| a[1]=aLine[1] .AND. a[2]=aLine[2] .AND. a[3]=aLine[3]})

     IF nAt=0

        cWhereM:=cWhereM+IF(!Empty(cWhereM)," OR ",""       )+;
                 "(MOC_ACTUAL"+GetWhere("=",cActual         )+" AND "+;
                 " MOC_NUMCBT"+GetWhere("=",oDp:cNumCbteCrea)+" AND "+;
                 " MOC_FECHA" +GetWhere("=",oDp:dFchCbteCrea)+")"

        AADD(aCbte,aLine)

     ENDIF

     // Evalua la inconsistencia de los Asientos
     EJECUTAR("DPASIENTOSACT",oDOCPRORESXCNT:cNumero,oDp:dFchContab,"N",oDp:cSucursal,NIL,NIL,.T.)

     oCursor:DbSkip()

  ENDDO
 
  oCursor:End()

//  IF !Empty(cWhereM)
//    cWhereM:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND ("+cWhereM+")"
//  ENDIF
  
  EJECUTAR("DPCBTEFIX2")

  oDOCPRORESXCNT:BRWREFRESCAR()

  oDOCPRORESXCNT:oSayProgress:Hide()
  oDOCPRORESXCNT:oMeter:Hide()

  oDOCPRORESXCNT:oSay:Show()
  oDOCPRORESXCNT:oNumero:Show()
/*
  cWhere:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "MOC_ACTUAL"+GetWhere("=","N"          )+" AND "+;
          "MOC_NUMCBT"+GetWhere("=",oDOCPRORESXCNT:cNumero)

  IF COUNT("DPASIENTOS",cWhere)=0

    cWhere:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
            "MOC_ACTUAL"+GetWhere("=","S"          )+" AND "+;
            "MOC_NUMCBT"+GetWhere("=",oDOCPRORESXCNT:cNumero)

  ENDIF
*/
  DPWRITE(cFileWhere,cWhereM)
//EJECUTAR("BRASIENTOSCOM",cWhere,oDp:cSucursal,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)

  cWhereM:="CBT_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND CBT_NUMPRO"+GetWhere("=",oDp:cNumPro)+" AND CBT_USUARI"+GetWhere("=",oDp:cUsuario)

?  cWhereM

  EJECUTAR("BRASIENTOSCOM",cWhereM,oDp:cSucursal,nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)
  
RETURN .T.

PROCE MENUCONTAB()
   LOCAL oPopFind,I,cBuscar,bAction,cFrm
   LOCAL aOption:={}

   cFrm:=oDOCPRORESXCNT:cVarName

   AADD(aOption,"No Contabilizados")
   AADD(aOption,"Actualizar Asientos")

   C5MENU oPopFind POPUP;
          COLOR    oDp:nMenuItemClrText,oDp:nMenuItemClrPane;
          COLORSEL oDp:nMenuItemSelText,oDp:nMenuItemSelPane;
          COLORBOX oDp:nMenuBoxClrText;
          HEIGHT   oDp:nMenuHeight;
          FONT     oDp:oFontMenu;
          LOGOCOLOR oDp:nMenuMainClrText

          FOR I=1 TO LEN(aOption)

            bAction:=cFrm+":lTodos:=.F.,oDOCPRORESXCNT:HACERASIENTO("+LSTR(I)+")"
            bAction:=BloqueCod(bAction)
       
            C5MenuAddItem(aOption[I],,.F.,,bAction,,,,,,,.F.,,,.F.,,,,,,,,.F.,)

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION VERASIENTOS()
  LOCAL cWhere:="MOC_ORIGEN"+GetWhere("=","COM"),cCodSuc,nPeriodo,dDesde,dHasta,cTitle:=", Origen [Compra]"

  EJECUTAR("BRASIENTORESORG",cWhere,oDOCPRORESXCNT:cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)

RETURN .T.

FUNCTION VERCONCIL(lOk,cWhere,cTitle,lRun,lContab)
  LOCAL cCodSuc,nPeriodo,dDesde,dHasta

  DEFAULT cTitle:=NIL

  DEFAULT cWhere:="DOC_TIPTRA"+GetWhere("=","D")

  DEFAULT lOk:=.T.

  IF !lOk
     cWhere:=cWhere+" AND MOC_ACTUAL IS NULL "
  ENDIF

  IF "Cero"$cTitle
     cWhere:=cWhere+" AND DOC_NETO=0 "
  ENDIF

EJECUTAR("BRCONCTADOCPRO",cWhere,oDOCPRORESXCNT:cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle,lRun,lContab)

FUNCTION REHACER()
   LOCAL cWhere:=[ MOC_CODSUC]+GetWhere("=",oDp:cSucursal)+" AND "+;
                 [ MOC_ORIGEN]+GetWhere("=","COM"        )+IF(Empty(oDOCPRORESXCNT:dDesde),""," AND ")+;
                 [ MOC_DOCPAG]+GetWhere("=",""           )+" AND "+;
                 GetWhereAnd("MOC_FECHA",oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta  )
   LOCAL nCantid:=COUNT("DPASIENTOS",cWhere)


   IF !MsgNoYes("Deseas Remover "+LSTR(nCantid)+" Asientos Generados en la Aplicación de Compras")
      RETURN .T.
   ENDIF

   MsgRun("Removiendo Asientos","Procesando",{||   EJECUTAR("DPASIENTOSDELXORG",oDp:cSucursal,"COM",oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cWhere) })
  
   MsgMemo("Proceso Concluido")

   oDOCPRORESXCNT:BRWREFRESCAR()

RETURN .T.

FUNCTION VERLISTA()
  LOCAL cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle:=NIL
  LOCAL cTipDoc:=oDOCPRORESXCNT:oBrw:aArrayData[oDOCPRORESXCNT:oBrw:nArrayAt,1]
  LOCAL lLibCom:=SQLGET("DPTIPDOCPRO","TDC_LIBCOM","TDC_TIPO"+GetWhere("=",cTipDoc))

  IF !lLibCom
     cWhere:="DOC_TIPDOC"+GetWhere("=",cTipDoc)
     RETURN EJECUTAR("BRDPDOCPRODOC",cWhere,cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)
  ENDIF

EJECUTAR("BRDOCPRORET",cWhere,cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle)

FUNCTION EDITTIPDOCCLI()
RETURN NIL

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oDOCPRORESXCNT)
// EOF
