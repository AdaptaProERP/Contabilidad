// Programa   : BRDOCCLIRESXCNT
// Fecha/Hora : 26/12/2018 08:47:24
// Propósito  : "Resumen de Documentos de Clientes por Contabilizar"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRDOCCLIRESXCNT.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oDOCCLIRESXCNT")="O" .AND. oDOCCLIRESXCNT:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDOCCLIRESXCNT,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Resumen de Documentos de Clientes por Contabilizar" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oDOCCLIRESXCNT
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB,oFontC
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"       SIZE 0, -10 BOLD 
   DEFINE FONT oFontB NAME "Tahoma"       SIZE 0, -12 BOLD
   DEFINE FONT oFontC NAME "Courier New"  SIZE 0, -14 BOLD

   DpMdi(cTitle,"oDOCCLIRESXCNT","BRDOCCLIRESXCNT.EDT")

// oDOCCLIRESXCNT:CreateWindow(0,0,100,550)
   oDOCCLIRESXCNT:Windows(0,0,aCoors[3]-160,MIN(830+515,aCoors[4]-10),.T.) // Maximizado

   // oDOCCLIRESXCNT:cNumero :=EJECUTAR("DPNUMCBTEGET","CXCOBR")
   oDOCCLIRESXCNT:cNumero :=EJECUTAR("DPNUMCBTEXTIPDOC","DPTIPDOCCLI","",oDp:dFecha)

   oDOCCLIRESXCNT:cCodSuc  :=cCodSuc
   oDOCCLIRESXCNT:lMsgBar  :=.F.
   oDOCCLIRESXCNT:cPeriodo :=aPeriodos[nPeriodo]
   oDOCCLIRESXCNT:cCodSuc  :=cCodSuc
   oDOCCLIRESXCNT:nPeriodo :=nPeriodo
   oDOCCLIRESXCNT:cNombre  :=""
   oDOCCLIRESXCNT:dDesde   :=dDesde
   oDOCCLIRESXCNT:cServer  :=cServer
   oDOCCLIRESXCNT:dHasta   :=dHasta
   oDOCCLIRESXCNT:cWhere   :=cWhere
   oDOCCLIRESXCNT:cWhere_  :=cWhere_
   oDOCCLIRESXCNT:cWhereQry:=""
   oDOCCLIRESXCNT:cSql     :=oDp:cSql
   oDOCCLIRESXCNT:oWhere   :=TWHERE():New(oDOCCLIRESXCNT)
   oDOCCLIRESXCNT:cCodPar  :=cCodPar // Código del Parámetro
   oDOCCLIRESXCNT:lWhen    :=.T.
   oDOCCLIRESXCNT:cTextTit :="" // Texto del Titulo Heredado
   oDOCCLIRESXCNT:oDb      :=oDp:oDb
   oDOCCLIRESXCNT:cBrwCod  :="DOCCLIRESXCNT"
   oDOCCLIRESXCNT:lTmdi    :=.T.
   oDOCCLIRESXCNT:nCuantos :=0
   oDOCCLIRESXCNT:lTodos   :=.T.

   oDOCCLIRESXCNT:cCodInt  :="CXCNAC"

   // oDOCCLIRESXCNT:cCodCta  :=ALLTRIM(SQLGET("DPCODINTEGRA","CIN_CODCTA","CIN_CODIGO"+GetWhere("=",oDOCCLIRESXCNT:cCodInt)))
   // ALLTRIM(SQLGET("DPCTA"       ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oDOCCLIRESXCNT:cCodCta)))

   oDOCCLIRESXCNT:cCodCta  :=EJECUTAR("CODINTGETCTA",NIL,oDOCCLIRESXCNT:cCodInt)
   oDOCCLIRESXCNT:cDescri  :=oDp:cCtaDescri

   oDOCCLIRESXCNT:cComInt  :="VTANAC"
   oDOCCLIRESXCNT:cComCta  :=EJECUTAR("CODINTGETCTA",NIL,oDOCCLIRESXCNT:cComInt)
   oDOCCLIRESXCNT:cComNom  :=oDp:cCtaDescri

   // ALLTRIM(SQLGET("DPCODINTEGRA","CIN_CODCTA","CIN_CODIGO"+GetWhere("=",oDOCCLIRESXCNT:cComInt)))
   // oDOCCLIRESXCNT:cComNom  :=ALLTRIM(SQLGET("DPCTA"       ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oDOCCLIRESXCNT:cComCta)))

   oDOCCLIRESXCNT:oBrw:=TXBrowse():New( IF(oDOCCLIRESXCNT:lTmdi,oDOCCLIRESXCNT:oWnd,oDOCCLIRESXCNT:oDlg ))
   oDOCCLIRESXCNT:oBrw:SetArray( aData, .F. )
   oDOCCLIRESXCNT:oBrw:SetFont(oFont)

   oDOCCLIRESXCNT:oBrw:lFooter     := .T.
   oDOCCLIRESXCNT:oBrw:lHScroll    := .T.
   oDOCCLIRESXCNT:oBrw:nHeaderLines:= 3
   oDOCCLIRESXCNT:oBrw:nDataLines  := 1
   oDOCCLIRESXCNT:oBrw:nFooterLines:= 1

   oDOCCLIRESXCNT:aData            :=ACLONE(aData)
// oDOCCLIRESXCNT:nClrText :=0
   oDOCCLIRESXCNT:nClrPane1:=16771538
   oDOCCLIRESXCNT:nClrPane2:=16765348

   oDOCCLIRESXCNT:nClrText1:=CLR_HBLUE
   oDOCCLIRESXCNT:nClrText :=0
   oDOCCLIRESXCNT:cClrText1:="Seleccionados"



   AEVAL(oDOCCLIRESXCNT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[1]
  oCol:cHeader      :='Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 30

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 340-40

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[3]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[4]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[5]
  oCol:cHeader      :='Por'+CRLF+'Conta-'+CRLF+'bilizar'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,5],FDP(nMonto,'999,999')}
   oCol:cFooter      :=FDP(aTotal[5],'999,999')


  oCol:=oDOCCLIRESXCNT:oBrw:aCols[6]
  oCol:cHeader      :='Conta-'+CRLF+"bilizados"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,6],;
                                    oCol  := oDOCCLIRESXCNT:oBrw:aCols[6],;
                                    FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)


//  oCol:bStrData:={|nMonto|nMonto:= oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,6],FDP(nMonto,'999,999')}
//   oCol:cFooter      :=FDP(aTotal[6],'999,999')


  oCol:=oDOCCLIRESXCNT:oBrw:aCols[7]
  oCol:cHeader      :='Monto'+CRLF+'por'+CRLF+'Contabilizar'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 130
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99,999,999,999,999,999.99'
  oCol:bStrData     :={|nMonto,oCol|nMonto:= oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,7],;
                                    oCol  := oDOCCLIRESXCNT:oBrw:aCols[7],;
                                    FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)

  //oCol:bStrData:={|nMonto|nMonto:= oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,7],FDP(nMonto,'99,9999,999,999,999')}
  // oCol:cFooter      :=FDP(aTotal[7],'99,9999,999,999,999')

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[8]
  oCol:cHeader      :='Cant.'+CRLF+'Docs'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,8],FDP(nMonto,'999,999')}
   oCol:cFooter      :=FDP(aTotal[8],'999,999')


  oCol:=oDOCCLIRESXCNT:oBrw:aCols[9]
  oCol:cHeader      :='Ok'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 60
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 

  oCol:bBmpData    := { ||oBrw:=oDOCCLIRESXCNT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,9],1,2) }
  oCol:bLDClickData:={||oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,9]:=!oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,9],oDOCCLIRESXCNT:oBrw:DrawLine(.T.)} 
  oCol:bStrData    :={||""}
  oCol:bLClickHeader:={||oDp:lSel:=!oDOCCLIRESXCNT:oBrw:aArrayData[1,9],; 
       AEVAL(oDOCCLIRESXCNT:oBrw:aArrayData,{|a,n| oDOCCLIRESXCNT:oBrw:aArrayData[n,9]:=oDp:lSel}),oDOCCLIRESXCNT:oBrw:Refresh(.T.)} 


  oCol:=oDOCCLIRESXCNT:oBrw:aCols[10]
  oCol:cHeader      :='Número'+CRLF+"Cbte."
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:oDataFont    :=oFontC

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[11]
  oCol:cHeader      :='Código'+CRLF+"Contable"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oDOCCLIRESXCNT:oBrw:aCols[12]
  oCol:cHeader      :='Descripción de la Cuenta'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDOCCLIRESXCNT:oBrw:aArrayData ) } 
  oCol:nWidth       :=220


   oDOCCLIRESXCNT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDOCCLIRESXCNT:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDOCCLIRESXCNT:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=iif( oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,9], oDOCCLIRESXCNT:nClrText1,  oDOCCLIRESXCNT:nClrText ),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDOCCLIRESXCNT:nClrPane1, oDOCCLIRESXCNT:nClrPane2 ) } }

   oDOCCLIRESXCNT:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDOCCLIRESXCNT:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oDOCCLIRESXCNT:oBrw:bLDblClick:={|oBrw|oDOCCLIRESXCNT:RUNCLICK() }

   oDOCCLIRESXCNT:oBrw:bChange:={||oDOCCLIRESXCNT:BRWCHANGE()}
   oDOCCLIRESXCNT:oBrw:CreateFromCode()
   oDOCCLIRESXCNT:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDOCCLIRESXCNT)}
   oDOCCLIRESXCNT:BRWRESTOREPAR()


   oDOCCLIRESXCNT:oWnd:oClient := oDOCCLIRESXCNT:oBrw


   oDOCCLIRESXCNT:Activate({||oDOCCLIRESXCNT:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDOCCLIRESXCNT:lTmdi,oDOCCLIRESXCNT:oWnd,oDOCCLIRESXCNT:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oDOCCLIRESXCNT:oBrw:nWidth()

   oDOCCLIRESXCNT:oBrw:GoBottom(.T.)
   oDOCCLIRESXCNT:oBrw:Refresh(.T.)

   IF !File("FORMS\BRDOCCLIRESXCNT.EDT")
     oDOCCLIRESXCNT:oBrw:Move(44,0,704+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          MENU oDOCCLIRESXCNT:MENUCONTAB();
          ACTION oDOCCLIRESXCNT:HACERASIENTO();
          WHEN !Empty(oDOCCLIRESXCNT:cNumero)

   oBtn:cToolTip:="Ejecutar Proceso de Contabilizar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP",NIL,"BITMAPS\XDELETEG.BMP";
          ACTION oDOCCLIRESXCNT:REHACER();
          WHEN !Empty(oDOCCLIRESXCNT:cNumero)

   oBtn:cToolTip:="Rehacer los asientos contables"



/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          MENU EJECUTAR("BRBTNMENU",{"Conciliación vs Asientos"},"oDOCCLIRESXCNT");
          FILENAME "BITMAPS\XBROWSE2.BMP";
          ACTION oDOCCLIRESXCNT:VERASIENTOS()

   oBtn:cToolTip:="Visualizar Asientos"
*/

DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          MENU EJECUTAR("BRBTNMENU",{"Conciliación vs Asientos",;
                                     "Inconsistencia Documentos Vs Asientos",;
                                     "Inconsistencia Cronológica de Asientos",;
                                     "Asientos por Actualizar",;
                                     "Clientes con Cuentas Indefinidas",;
                                     "Tipo de Documento con Cuenta Indefinida",;
                                     "Documentos con Cuentas Indefinidas",;
                                     "Documentos con Valor Cero ",;
                                     "Documentos Anulados con Asientos Contables ",;
                                     "Integración [CXCNAC] "+oDOCCLIRESXCNT:cCodCta+":"+oDOCCLIRESXCNT:cDescri,;
                                     "Integración [VTANAC] "+oDOCCLIRESXCNT:cComCta+":"+oDOCCLIRESXCNT:cComNom},;
                                     "oDOCCLIRESXCNT");
          FILENAME "BITMAPS\XBROWSE2.BMP";
          ACTION oDOCCLIRESXCNT:VERASIENTOS()

   oBtn:cToolTip:="Opciones de Conciliación"


  
/*
   IF Empty(oDOCCLIRESXCNT:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","DOCCLIRESXCNT")))
*/

/*
   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DOCCLIRESXCNT"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oDOCCLIRESXCNT:oBrw,"DOCCLIRESXCNT",oDOCCLIRESXCNT:cSql,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,oDOCCLIRESXCNT)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oDOCCLIRESXCNT:oBtnRun:=oBtn



       oDOCCLIRESXCNT:oBrw:bLDblClick:={||EVAL(oDOCCLIRESXCNT:oBtnRun:bAction) }


   ENDIF
*/

DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oDOCCLIRESXCNT:VERLISTA()

   oBtn:cToolTip:="Ver Documentos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oDOCCLIRESXCNT:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oDOCCLIRESXCNT:oBrw,oDOCCLIRESXCNT);
          ACTION EJECUTAR("BRWSETFILTER",oDOCCLIRESXCNT:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oDOCCLIRESXCNT:oBrw);
          WHEN LEN(oDOCCLIRESXCNT:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

/*
      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             MENU EJECUTAR("BRBTNMENU",{"Opción1","Opción"},"oFrm");
             FILENAME "BITMAPS\MENU.BMP";
             ACTION 1=1;

             oBtn:cToolTip:="Boton con Menu"

*/


IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oDOCCLIRESXCNT:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oDOCCLIRESXCNT)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oDOCCLIRESXCNT:oBrw,oDOCCLIRESXCNT:cTitle,oDOCCLIRESXCNT:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oDOCCLIRESXCNT:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oDOCCLIRESXCNT:HTMLHEAD(),EJECUTAR("BRWTOHTML",oDOCCLIRESXCNT:oBrw,NIL,oDOCCLIRESXCNT:cTitle,oDOCCLIRESXCNT:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oDOCCLIRESXCNT:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oDOCCLIRESXCNT:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDOCCLIRESXCNT:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDOCCLIRESXCNT")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oDOCCLIRESXCNT:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDOCCLIRESXCNT:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDOCCLIRESXCNT:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oDOCCLIRESXCNT:oBrw:GoTop(),oDOCCLIRESXCNT:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oDOCCLIRESXCNT:oBrw:PageDown(),oDOCCLIRESXCNT:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oDOCCLIRESXCNT:oBrw:PageUp(),oDOCCLIRESXCNT:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDOCCLIRESXCNT:oBrw:GoBottom(),oDOCCLIRESXCNT:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDOCCLIRESXCNT:Close()

  oDOCCLIRESXCNT:oBrw:SetColor(0,oDOCCLIRESXCNT:nClrPane1)

  EVAL(oDOCCLIRESXCNT:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDOCCLIRESXCNT:oBar:=oBar

  nLin:=344

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oDOCCLIRESXCNT:oPeriodo  VAR oDOCCLIRESXCNT:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oDOCCLIRESXCNT:LEEFECHAS();
                WHEN oDOCCLIRESXCNT:lWhen 


  ComboIni(oDOCCLIRESXCNT:oPeriodo )

  @ 10, nLin+103 BUTTON oDOCCLIRESXCNT:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDOCCLIRESXCNT:oPeriodo:nAt,oDOCCLIRESXCNT:oDesde,oDOCCLIRESXCNT:oHasta,-1),;
                         EVAL(oDOCCLIRESXCNT:oBtn:bAction));
                WHEN oDOCCLIRESXCNT:lWhen 


  @ 10, nLin+130 BUTTON oDOCCLIRESXCNT:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDOCCLIRESXCNT:oPeriodo:nAt,oDOCCLIRESXCNT:oDesde,oDOCCLIRESXCNT:oHasta,+1),;
                         EVAL(oDOCCLIRESXCNT:oBtn:bAction));
                WHEN oDOCCLIRESXCNT:lWhen 


  @ 10, nLin+170 BMPGET oDOCCLIRESXCNT:oDesde  VAR oDOCCLIRESXCNT:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDOCCLIRESXCNT:oDesde ,oDOCCLIRESXCNT:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oDOCCLIRESXCNT:oPeriodo:nAt=LEN(oDOCCLIRESXCNT:oPeriodo:aItems) .AND. oDOCCLIRESXCNT:lWhen ;
                FONT oFont

   oDOCCLIRESXCNT:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oDOCCLIRESXCNT:oHasta  VAR oDOCCLIRESXCNT:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDOCCLIRESXCNT:oHasta,oDOCCLIRESXCNT:dHasta);
                SIZE 80,23;
                WHEN oDOCCLIRESXCNT:oPeriodo:nAt=LEN(oDOCCLIRESXCNT:oPeriodo:aItems) .AND. oDOCCLIRESXCNT:lWhen ;
                OF oBar;
                FONT oFont

   oDOCCLIRESXCNT:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oDOCCLIRESXCNT:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oDOCCLIRESXCNT:oPeriodo:nAt=LEN(oDOCCLIRESXCNT:oPeriodo:aItems);
               ACTION oDOCCLIRESXCNT:HACERWHERE(oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,oDOCCLIRESXCNT:cWhere,.T.);
               WHEN oDOCCLIRESXCNT:lWhen


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

  @ 10,nLin+380 SAY oDOCCLIRESXCNT:oSay    PROMPT "Número " SIZE 80,20 RIGHT OF oBar PIXEL BORDER FONT oFont ;
                COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  @ 10,nLin+460 GET oDOCCLIRESXCNT:oNumero VAR oDOCCLIRESXCNT:cNumero OF oBar PIXEL SIZE 80,20 FONT oFont 
 
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  @ 01,nLin+380 SAY   oDOCCLIRESXCNT:oSayProgress PROMPT "Lectura"             OF oBar PIXEL SIZE 160,20 FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow
  @ 20,nLin+380 METER oDOCCLIRESXCNT:oMeter       VAR oDOCCLIRESXCNT:nCuantos  OF oBar PIXEL SIZE 160,20 FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow

 
  oDOCCLIRESXCNT:oSayProgress:Hide()
  oDOCCLIRESXCNT:oMeter:Hide()

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
 LOCAL cTipDoc:=oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,1]
 LOCAL dDesde :=oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,3]
 LOCAL dHasta :=oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,4]

 IF oDOCCLIRESXCNT:oBrw:nColSel=10
   EJECUTAR("DPTIPDOCCLI",3,cTipDoc)
   DPFOCUS(oTIPDOCCLI:oTDC_CODCTA)
   RETURN .T.
 ENDIF

 // browse por tipo de documento
 oDOCCLIRESXCNT:VERLISTA(cTipDoc,dDesde,dHasta)

RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRDOCCLIRESXCNT",cWhere)
  oRep:cSql  :=oDOCCLIRESXCNT:cSql
  oRep:cTitle:=oDOCCLIRESXCNT:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDOCCLIRESXCNT:oPeriodo:nAt,cWhere

  oDOCCLIRESXCNT:nPeriodo:=nPeriodo


  IF oDOCCLIRESXCNT:oPeriodo:nAt=LEN(oDOCCLIRESXCNT:oPeriodo:aItems)

     oDOCCLIRESXCNT:oDesde:ForWhen(.T.)
     oDOCCLIRESXCNT:oHasta:ForWhen(.T.)
     oDOCCLIRESXCNT:oBtn  :ForWhen(.T.)

     DPFOCUS(oDOCCLIRESXCNT:oDesde)

  ELSE

     oDOCCLIRESXCNT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDOCCLIRESXCNT:oDesde:VarPut(oDOCCLIRESXCNT:aFechas[1] , .T. )
     oDOCCLIRESXCNT:oHasta:VarPut(oDOCCLIRESXCNT:aFechas[2] , .T. )

     oDOCCLIRESXCNT:dDesde:=oDOCCLIRESXCNT:aFechas[1]
     oDOCCLIRESXCNT:dHasta:=oDOCCLIRESXCNT:aFechas[2]

     cWhere:=oDOCCLIRESXCNT:HACERWHERE(oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,oDOCCLIRESXCNT:cWhere,.T.)

     oDOCCLIRESXCNT:LEERDATA(cWhere,oDOCCLIRESXCNT:oBrw,oDOCCLIRESXCNT:cServer)

  ENDIF

  oDOCCLIRESXCNT:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDOCCLI.DOC_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCCLI.DOC_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oDOCCLIRESXCNT:cWhereQry)
       cWhere:=cWhere + oDOCCLIRESXCNT:cWhereQry
     ENDIF

     oDOCCLIRESXCNT:LEERDATA(cWhere,oDOCCLIRESXCNT:oBrw,oDOCCLIRESXCNT:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb,I

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF


   cSql:=" SELECT  "+;
         "  DOC_TIPDOC, "+;
         "  TDC_DESCRI, "+;
         "  MIN(DOC_FECHA) AS DESDE, "+;
         "  MAX(DOC_FECHA) AS HASTA, "+;
         "  COUNT(IF(DOC_CBTNUM='',1, NULL)) AS XCONTAB, "+;
         "  COUNT(IF(DOC_CBTNUM<>'',1, NULL)) AS CONTAB, "+;
         " SUM(IF(DOC_CBTNUM='',DOC_NETO*DOC_CXC,0)) AS SUMXCON, "+;
         "  COUNT(*) AS CUANTOS,"+;
         "  1 AS LOGICO,SPACE(08) AS DOC_NUMCBT,CTA_CODIGO,CTA_DESCRI "+;
         "  FROM DPDOCCLI "+;
         "  INNER JOIN DPTIPDOCCLI ON DOC_TIPDOC=TDC_TIPO AND TDC_CONTAB=1 "+;
         "  LEFT  JOIN DPCTA       ON TDC_CODCTA=CTA_CODIGO "+;
         "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DOC_TIPDOC"+GetWhere("<>","ANT")+" AND  DOC_CODSUC=&oDp:cSucursal AND DOC_TIPTRA='D' AND DOC_ACT=1 AND DOC_DOCORG<>'P' "+;
         "  GROUP BY DOC_TIPDOC "+;
         ""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRDOCCLIRESXCNT.SQL",cSql)

   aData:=ASQL(cSql,oDb)

// ViewArray(aData)

   AEVAL(aData,{|a,n| aData[n,03]:=SQLTODATE(a[3]),;
                      aData[n,04]:=SQLTODATE(a[4])})


   FOR I=1 TO LEN(aData)
     aData[I,10]:=EJECUTAR("DPNUMCBTEXTIPDOC","DPTIPDOCCLI",aData[I,1],aData[I,4]) 
   NEXT I

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
// ? "VACIO"
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','',0,0,0,0})
   ENDIF

// ? LEN(aData),CLPCOPY(cSql)

   IF ValType(oBrw)="O"

      oDOCCLIRESXCNT:cSql   :=cSql
      oDOCCLIRESXCNT:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

/*      
      oCol:=oDOCCLIRESXCNT:oBrw:aCols[5]
         oCol:cFooter      :=FDP(aTotal[5],'999,999')
      oCol:=oDOCCLIRESXCNT:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'999,999')
      oCol:=oDOCCLIRESXCNT:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],'999,999')

      oDOCCLIRESXCNT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
*/   
      EJECUTAR("BRWCALTOTALES",oBrw)

      oBrw:Refresh(.T.)
      AEVAL(oDOCCLIRESXCNT:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDOCCLIRESXCNT:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDOCCLIRESXCNT.MEM",V_nPeriodo:=oDOCCLIRESXCNT:nPeriodo
  LOCAL V_dDesde:=oDOCCLIRESXCNT:dDesde
  LOCAL V_dHasta:=oDOCCLIRESXCNT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDOCCLIRESXCNT)
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


    IF Type("oDOCCLIRESXCNT")="O" .AND. oDOCCLIRESXCNT:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDOCCLIRESXCNT:cWhere_),oDOCCLIRESXCNT:cWhere_,oDOCCLIRESXCNT:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oDOCCLIRESXCNT:LEERDATA(oDOCCLIRESXCNT:cWhere_,oDOCCLIRESXCNT:oBrw,oDOCCLIRESXCNT:cServer)
      oDOCCLIRESXCNT:oWnd:Show()
      oDOCCLIRESXCNT:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNMENU(nOption,cOption)
   LOCAL cWhere,nPeriodo:=12
   LOCAL cTitle:=NIL

   IF nOption=1
       oDOCCLIRESXCNT:VERCONCIL(.T.,NIL,"[ Vs Asientos ]",.T.,.T.)
   ENDIF

   IF nOption=2
       oDOCCLIRESXCNT:VERCONCIL(.F.,NIL,"[ Inconsistentes ]",.T.,.T.)
   ENDIF

   IF nOption=3
       oDOCCLIRESXCNT:VERCONCIL(NIL,"DOC_TIPTRA"+GetWhere("=","D")+" AND DATEDIFF(MOC_FECHA,DOC_FECHA)<>0"," [Inconsistencias Cronológicas]",.T.,.F.)
   ENDIF


   IF nOption=4

     cWhere:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
             "MOC_ACTUAL"+GetWhere("=","N"          )
// +" AND "+;
//             "MOC_NUMCBT"+GetWhere("=",oDOCCLIRESXCNT:cNumero)

     cTitle:=" [Por Actualizar]"

     EJECUTAR("BRASIENTOSVTA",cWhere,oDp:cSucursal,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,cTitle)

     RETURN NIL

   ENDIF

   IF nOption=5
      cWhere:=NIL
      cTitle:=NIL
      EJECUTAR("BRDOCCLIINDEF",cWhere,oDOCCLIRESXCNT:cCodSuc,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,cTitle)
      RETURN .T.
   ENDIF

   IF nOption=6
      EJECUTAR("BRDOCCLICTAIND",cWhere,oDOCCLIRESXCNT:cCodSuc,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,cTitle)
      RETURN .T.
   ENDIF
  
   IF nOption=7
       EJECUTAR("BRDOCCLICTAINDD",cWhere,oDOCCLIRESXCNT:cCodSuc,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,cTitle)
   ENDIF

   IF nOption=8
      oDOCCLIRESXCNT:VERCONCIL(.F.,NIL,"[ Con Valores en Cero ]",.T.,.T.)
   ENDIF

   IF nOption=9
      oDOCCLIRESXCNT:VERCONCIL(.T.,"DOC_ACT=0 ","[ Anulados con Asientos ]",.T.,.T.)
   ENDIF

   IF nOption=09+1
       EJECUTAR("DPCODINTEGRA",3,oDOCCLIRESXCNT:cCodInt)
   ENDIF

   IF nOption=10+1
       EJECUTAR("DPCODINTEGRA",3,oDOCCLIRESXCNT:cComInt)
   ENDIF

RETURN .T.


FUNCTION HTMLHEAD()

   oDOCCLIRESXCNT:aHead:=EJECUTAR("HTMLHEAD",oDOCCLIRESXCNT)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

FUNCTION HACERASIENTO(nOption)
  LOCAL oCursor,cSql
  LOCAL aTipDoc:={},cWhere:=IF(oDOCCLIRESXCNT:lTodos,"","DOC_CBTNUM"+GetWhere("=",""))
  LOCAL cWhere,cCodSuc,nPeriodo:=12,dDesde,dHasta,cTitle:=NIL,cRecibo

  IF nOption=2
     cWhere:="MOC_ORIGEN"+GetWhere("=","VTA")
     EJECUTAR("DPCBTEACT",NIL,NIL,NIL,cWhere)
     RETURN .T.
  ENDIF
 

  Aeval(oDOCCLIRESXCNT:oBrw:aArrayData,{|a,n|  IIF(a[9] , AADD(aTipDoc,a[1]) , NIL ) })

  IF LEN(aTipDoc)=0
     MensajeErr("Debe Seleccionar los Tipos de Documentos")
     RETURN .F.
  ENDIF

  CursorWait() 

  oDOCCLIRESXCNT:oNumero:Hide()
  oDOCCLIRESXCNT:oSay:Hide()

  oDOCCLIRESXCNT:oSayProgress:Show()
  oDOCCLIRESXCNT:oSayProgress:SetText("Leyendo Documentos")

  cSql:=" SELECT DOC_CODIGO,DOC_TIPDOC,DOC_NUMERO,DOC_ESTADO,DOC_IMPOTR,DOC_CENCOS,DOC_CXC,DOC_TIPTRA,DOC_SERFIS,DOC_RECNUM FROM DPDOCCLI "+;
        " WHERE DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_TIPTRA='D' AND DOC_DOCORG<>'P' AND DOC_ACT=1 "+;
        IF(Empty(oDOCCLIRESXCNT:dDesde),"","   AND ")+GetWhereAnd("DOC_FECHA",oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta)+;
        "   AND "+GetWhereOr("DOC_TIPDOC",aTipDoc)+" AND DOC_ACT=1 "+IF(Empty(cWhere),""," AND ")+cWhere+;
        " ORDER BY DOC_FECHA,DOC_HORA" // LAS OPCIONES DE DOCUMENTOS NO GUARDAN LA HORA

  oCursor:=OpenTable(cSql,.T.)

  IF Empty(oCursor:RecCount())
     oDOCCLIRESXCNT:oSayProgress:Hide()
     oDOCCLIRESXCNT:oSay:Show()
     oDOCCLIRESXCNT:oNumero:Show()
     MensajeErr("No hay Documentos para Contabilizar")
     oCursor:End()
     RETURN .F.
  ENDIF

  IF !MsgNoYes("Contabilizar "+LSTR(oCursor:RecCount())+" Documento(s)")
     oDOCCLIRESXCNT:oSayProgress:Hide()
     oDOCCLIRESXCNT:oSay:Show()
     oDOCCLIRESXCNT:oNumero:Show()
     RETURN .F.
  ENDIF

  oDOCCLIRESXCNT:oSay:Hide()
  oDOCCLIRESXCNT:oNumero:Hide()

  oDOCCLIRESXCNT:oSay:Show()
  oDOCCLIRESXCNT:oMeter:Show()

  oCursor:Gotop()

  EJECUTAR("CBTGETNUMPROC") // Obtiene numero del Proceso

  oDOCCLIRESXCNT:oMeter:SetTotal(oCursor:RecCount())

  WHILE !oCursor:Eof()

     oDOCCLIRESXCNT:oSayProgress:SetText("Contabilizando "+oCursor:DOC_TIPDOC+" "+oCursor:DOC_NUMERO)

     oDOCCLIRESXCNT:oMeter:Set(oCursor:Recno())

     IF oCursor:DOC_TIPDOC="ANT"

       // Debe buscar el recibo de ingreso y contabilizarlo

       EJECUTAR("DPRECIBOCONT",oDp:cSucursal     ,;
                               oCursor:DOC_RECNUM,;
                               oCursor:DOC_RECNUM,;
                               oDOCCLIRESXCNT:cNumero,.F.,.F.)

     ELSE

       EJECUTAR("DPDOCCONTAB",oDOCCLIRESXCNT:cNumero,;
                              oDp:cSucursal,;
                              oCursor:DOC_TIPDOC,;
                              oCursor:DOC_CODIGO,;
                              oCursor:DOC_NUMERO,.T.,.F.,NIL,NIL,NIL,oCursor:DOC_SERFIS)
     ENDIF

     oCursor:DbSkip()

  ENDDO
 
  oCursor:End()

  oDOCCLIRESXCNT:BRWREFRESCAR()

  oDOCCLIRESXCNT:oSayProgress:Hide()
  oDOCCLIRESXCNT:oMeter:Hide()

  oDOCCLIRESXCNT:oSay:Show()
  oDOCCLIRESXCNT:oNumero:Show()


//  cWhere:="MOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
//          "MOC_ACTUAL"+GetWhere("=","N"          )
// +" AND "+;
//          "MOC_NUMCBT"+GetWhere("=",oDOCCLIRESXCNT:cNumero)

  cWhere:="CBT_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND CBT_NUMPRO"+GetWhere("=",oDp:cNumPro)+" AND CBT_USUARI"+GetWhere("=",oDp:cUsuario)

  EJECUTAR("BRASIENTOSVTA",cWhere,oDp:cSucursal,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,cTitle)

  oDp:cNumPro:=""

RETURN .T.

PROCE MENUCONTAB()
   LOCAL oPopFind,I,cBuscar,bAction,cFrm
   LOCAL aOption:={}

   cFrm:=oDOCCLIRESXCNT:cVarName

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

            bAction:=cFrm+":lTodos:=.F.,oDOCCLIRESXCNT:HACERASIENTO("+LSTR(I)+")"
            bAction:=BloqueCod(bAction)
       
            C5MenuAddItem(aOption[I],,.F.,,bAction,,,,,,,.F.,,,.F.,,,,,,,,.F.,)

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION VERASIENTOS()
  LOCAL cWhere:="MOC_ORIGEN"+GetWhere("=","VTA"),cCodSuc,nPeriodo,dDesde,dHasta,cTitle:=", Origen [Venta]"

  EJECUTAR("BRASIENTORESORG",cWhere,oDOCCLIRESXCNT:cCodSuc,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,cTitle)

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

RETURN EJECUTAR("BRCONCTADOCCLI",cWhere,oDOCCLIRESXCNT:cCodSuc,oDOCCLIRESXCNT:nPeriodo,oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta,cTitle,lRun,lContab)
// EJECUTAR("BRCONCTADOCPRO",cWhere,oDOCPRORESXCNT:cCodSuc,oDOCPRORESXCNT:nPeriodo,oDOCPRORESXCNT:dDesde,oDOCPRORESXCNT:dHasta,cTitle,lRun,lContab)

FUNCTION REHACER()
   LOCAL cWhere:=[ MOC_CODSUC]+GetWhere("=",oDp:cSucursal)+" AND "+;
                 [ MOC_ORIGEN]+GetWhere("=","VTA"        )+IF(Empty(oDOCCLIRESXCNT:dDesde),""," AND ")+;
                 GetWhereAnd("MOC_FECHA",oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta  )

   LOCAL nCantid:=COUNT("DPASIENTOS",cWhere)

   IF !MsgNoYes("Deseas Remover "+LSTR(nCantid)+" Asientos Generados en la Aplicación de Ventas")
      RETURN .T.
   ENDIF

   MsgRun("Removiendo Asientos","Procesando",{|| EJECUTAR("DPASIENTOSDELXORG",oDp:cSucursal,"VTA",oDOCCLIRESXCNT:dDesde,oDOCCLIRESXCNT:dHasta) })
  
   MsgRun("Removiendo Asientos Repetidos del Ejercicio","Procesando",{|| EJECUTAR("DPASIENTOSVTAREP")})

   MsgMemo("Proceso Concluido")

RETURN .T.

FUNCTION VERLISTA(cTipDoc,dDesde,dHasta)
  LOCAL cWhere:="",cTitle:=" [ "+oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,1]+":"+oDOCCLIRESXCNT:oBrw:aArrayData[oDOCCLIRESXCNT:oBrw:nArrayAt,2]+"]"
  LOCAL nPeriodo:=oDOCCLIRESXCNT:nPeriodo
  LOCAL lLibVta :=SQLGET("DPTIPDOCCLI","TDC_LIBVTA","TDC_TIPO"+GetWhere("=",cTipDoc))

  IF !cTipDoc=NIL
    cWhere:=[ DOC_TIPDOC]+GetWhere("=",cTipDoc)
  ENDIF

  IF !Empty(dDesde)
     nPeriodo:=11
     cWhere  :=cWhere+IF(Empty(cWhere),""," AND ")+GetWhereAnd("DOC_FECHA",dDesde,dHasta)
  ELSE
     dDesde  :=oDOCCLIRESXCNT:dDesde
     dHasta  :=oDOCCLIRESXCNT:dHasta
  ENDIF

  IF cTipDoc="CHD"
     cWhere:=""
     RETURN EJECUTAR("BRCHDCXC",cWhere,oDp:cSucursal,nPeriodo,dDesde,dHasta,cTitle,cTipDoc)
  ENDIF

  IF !lLibVta
     RETURN EJECUTAR("BRDPDOCCLICXC",cWhere,oDp:cSucursal,nPeriodo,dDesde,dHasta,cTitle,cTipDoc)
  ENDIF

RETURN EJECUTAR("BRSERFISCAL",cWhere,oDp:cSucursal,nPeriodo,dDesde,dHasta)


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oDOCCLIRESXCNT)
// EOF
