// Programa   : ASIENTOCREA
// Fecha/Hora : 20/12/2005 21:35:42
// Propósito  : Crear Asientos Contables
// Creado Por : Juan Navas
// Llamado por: DPDOCCONTAB
// Aplicación : Contabilidad
// Tabla      : DPASIENTOS

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cNumCom,dFecha,cModOrg,cCodCta,cTipDoc,cNumero,cDescri,nMonto,cCodAux,cTipTra,cNumPag,cCenCos,cNumTra,cCodMon,nValCam,cItem)
    LOCAL cAsiento:="" // Numero del Asiento
    LOCAL oAsiento,oTabCbte,oDpCta,oAsiCos,cNumEje
    LOCAL oTable,aData:={},nTotal,I

    oDp:cError_Asiento:=""

    IF Empty(nMonto)
       oDp:cError_Asiento:="Sin Monto"
       RETURN ""
    ENDIF


// ? cCodSuc,cNumCom,dFecha,cModOrg,cCodCta,cTipDoc,cNumero,cDescri,nMonto,cCodAux,cTipTra,cNumPag,cCenCos,cNumTra,cCodMon,nValCam,cItem

    oDp:nMontoAsiento:=nMonto

    DEFAULT cTipTra:="",;
            cCodMon:=oDp:cMoneda,;
            nValCam:=1,;
            cItem  :="" 

    // cItem Número de Item de Otros Pagos, DPDOCPROCTA,DPDOCCLICTA


    DEFAULT oDp:nMtoBase  :=0,;
            oDp:nIpc      :=0,;
            oDp:dDesde    :=CTOD(""),;
            oDp:cPartida  :=STRZERO(1,5)

    // numero del Comprobante
    oDp:cNumCbteCrea:=cNumCom
    oDp:dFchCbteCrea:=dFecha

    DEFAULT oDp:lPreContab:=.F.,;
            cCodCta       :=""

// ? "ASIENTOCREA",cCodCta,oDp:cCtaIndef,"cCodCta,oDp:cCtaIndef,",oDp:cOldScript

    IF EMPTY(cCodCta) .OR. ALLTRIM(UPPE(cCodCta))=ALLTRIM(UPPER(oDp:cCtaIndef))
      cCodCta:=oDp:cCtaIndef
    ENDIF

    IF !ISSQLGET("DPCTA","CTA_CODIGO",cCodCta)
       oDpCta:=OpenTable("SELECT * FROM DPCTA",.F.)
       oDpCta:AppendBlank()
       oDpCta:Replace("CTA_CODIGO",cCodCta)
       oDpCta:Replace("CTA_DESCRI","Cuenta Indefinida")
       oDpCta:Replace("CTA_CODMOD",oDp:cCtaMod)
       oDpCta:Replace("CTA_ACTIVO",.T.)
       oDpCta:Commit()
       oDpCta:End()
    ENDIF

    //
    // Crear Asientos de Precontabilización
    //
    IF oDp:lPreContab
       
       cAsiento:=SQLINCREMENTAL("DPASIENTOSPREC","MOC_ITEM","MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                 "MOC_FECHA "+GetWhere("=",dFecha ))
    		
       oAsiento:=OpenTable("SELECT * FROM DPASIENTOSPREC",.F.)
       oAsiento:Append()
       oAsiento:Replace("MOC_ACTUAL","S"     )
       oAsiento:Replace("MOC_FECHA" ,dFecha  )
       oAsiento:Replace("MOC_CODSUC",cCodSuc )
       oAsiento:Replace("MOC_ORIGEN",cModOrg )
       oAsiento:Replace("MOC_CODAUX",cCodAux )
       oAsiento:Replace("MOC_CUENTA",cCodCta )
       oAsiento:Replace("MOC_MONTO" ,nMonto  )
       oAsiento:Replace("MOC_ITEM"  ,cAsiento)
       oAsiento:Replace("MOC_DESCRI",cDescri )
       oAsiento:Replace("MOC_TIPO"  ,cTipDoc )
       oAsiento:Replace("MOC_DOCUME",cNumero )
       oAsiento:Replace("MOC_TIPTRA",cTipTra )
       oAsiento:Replace("MOC_DOCPAG",cNumPag )
       oAsiento:Replace("MOC_CENCOS",cCenCos )
       oAsiento:Replace("MOC_NUMTRA",cNumTra )
       oAsiento:Replace("MOC_CODMON",cCodMon )
       oAsiento:Replace("MOC_VALCAM",nValCam )
       oAsiento:Replace("MOC_USUARI",oDp:cUsuario)
       oAsiento:Replace("MOC_ITEM_O",cItem)
       oAsiento:Replace("MOC_TIPASI",oDp:cTipAsiento)
       oAsiento:Commit()
       oAsiento:End()

       RETURN .T.
    ENDIF

    IF Empty(oDp:cNumPro)
       EJECUTAR("CBTGETNUMPROC") // Obtiene numero del Proceso
    ENDIF

    // 
    // Obtiene el Número del Ejercicio
    //
    cNumEje:=EJECUTAR("FCH_EJERGET",dFecha)

    oTabCbte:=OpenTable("SELECT * FROM DPCBTE WHERE CBT_NUMERO"+GetWhere("=",cNumCom)+" AND "+;
                                                   "CBT_FECHA "+GetWhere("=",dFecha )+" AND "+;
                                                   "CBT_ACTUAL"+GetWhere("=","N"    )+" AND "+;
                                                   "CBT_CODSUC"+GetWhere("=",cCodSuc),.T.)

    IF oTabCbte:RecCount()=0

       oTabCbte:Append()
       oTabCbte:Replace("CBT_NUMERO" ,cNumCom)
       oTabCbte:Replace("CBT_FECHA"  ,dFecha )
       oTabCbte:Replace("CBT_ACTUAL" ,"N"    )
       oTabCbte:Replace("CBT_CODSUC" ,cCodSuc)
       oTabCbte:Replace("CBT_NUMEJE" ,cNumEje)
       oTabCbte:Replace("CBT_NUMPRO" ,oDp:cNumPro)
       oTabCbte:Replace("CBT_USUARI" ,oDp:cUsuario)


       IF !Empty(oDp:cCbteNombre)
          oTabCbte:Replace("CBT_COMEN1" ,oDp:cCbteNombre)
       ELSE
          oTabCbte:Replace("CBT_COMEN1" ,"Creado Automáticamente por AdaptaPro ")
       ENDIF

       oTabCbte:Commit()

    ELSE

       SQLUPDATE("DPCBTE",{"CBT_NUMPRO","CBT_USUARI"},{oDp:cNumPro,oDp:cUsuario},oTabCbte:cWhere)

    ENDIF

    oTabCbte:End()

    cAsiento:=SQLINCREMENTAL("DPASIENTOS","MOC_ITEM","MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                     "MOC_NUMCBT"+GetWhere("=",cNumCom)+" AND "+;
                                                     "MOC_FECHA "+GetWhere("=",dFecha ))
    		
    oAsiento:=OpenTable("SELECT * FROM DPASIENTOS",.F.)
    oAsiento:Append()
    oAsiento:Replace("MOC_ACTUAL","N"     )
    oAsiento:Replace("MOC_NUMCBT",cNumCom )
    oAsiento:Replace("MOC_FECHA" ,dFecha  )
    oAsiento:Replace("MOC_CODSUC",cCodSuc )
    oAsiento:Replace("MOC_ORIGEN",cModOrg )
    oAsiento:Replace("MOC_CODAUX",cCodAux )
    oAsiento:Replace("MOC_CUENTA",cCodCta )
    oAsiento:Replace("MOC_MONTO" ,nMonto  )
    oAsiento:Replace("MOC_ITEM"  ,cAsiento)
    oAsiento:Replace("MOC_DESCRI",cDescri )
    oAsiento:Replace("MOC_TIPO"  ,cTipDoc )
    oAsiento:Replace("MOC_DOCUME",cNumero )
    oAsiento:Replace("MOC_TIPTRA",cTipTra )
    oAsiento:Replace("MOC_DOCPAG",cNumPag )
    oAsiento:Replace("MOC_CENCOS",cCenCos )
    oAsiento:Replace("MOC_NUMTRA",cNumTra )
    oAsiento:Replace("MOC_CODMON",cCodMon )
    oAsiento:Replace("MOC_VALCAM",nValCam )

    oAsiento:Replace("MOC_CTAMOD",oDp:cCtaMod)
    oAsiento:Replace("MOC_MTOBAS",oDp:nMtoBase)
    oAsiento:Replace("MOC_IPC"   ,oDp:nIpc    )
    oAsiento:Replace("MOC_DESDE" ,oDp:dDesde  )
    oAsiento:Replace("MOC_NUMPAR",oDp:cPartida)
    oAsiento:Replace("MOC_ITEM_O",cItem       )
    oAsiento:Replace("MOC_NUMEJE",cNumEje     )
    oAsiento:Replace("MOC_TIPASI",oDp:cTipAsiento)
    oAsiento:Replace("MOC_RIF"   ,oParCon:MOC_RIF)

    oAsiento:Commit()
    oAsiento:End()

// ? CLPCOPY(oDp:cSql),"CREAR ASIENTO"

    /*
    // Si hay un Sólo Centro de Costos no tiene Sentido hacer asientos, COUNT("DPCENCOS")>1 JN/05/07/2015
    */

//? cCenCos,COUNT("DPCENCOS")

    IF !Empty(cCenCos) .AND. COUNT("DPCENCOS")>1
       oAsiCos:=OpenTable("SELECT * FROM DPASIENTOCENCOS",.F.)     
       oAsiCos:Append()
       oAsiCos:Replace("ACC_NUMCBT",cNumCom )
       oAsiCos:Replace("ACC_CODCOS",cCenCos )
       oAsiCos:Replace("ACC_CODCTA",cCodCta )
       oAsiCos:Replace("ACC_FECHA" ,dFecha  )
       oAsiCos:Replace("ACC_ACTUAL","N"     )
       oAsiCos:Replace("ACC_ITEM"  ,cAsiento)
       oAsiCos:Replace("ACC_CODSUC",cCodSuc )
       oAsiCos:Replace("ACC_MONTO" ,nMonto  )
       oAsiCos:Replace("ACC_CODMOD",oDp:cCtaMod)

       oAsiCos:Commit()
       oAsiCos:End()
    ENDIF

    /*
    // Distribución Departamental
    */

// ? cCodCta,"cCodCta",ISSQLFIND("DPPLADPTO","PLA_CODCTA"+GetWhere("=",cCodCta)),CLPCOPY(oDp:cSql)

    IF ISSQLFIND("DPPLADPTO","PLA_CODCTA"+GetWhere("=",cCodCta)+" AND PLA_CODMOD"+GetWhere("=",oDp:cCtaMod))

       oTable:=OpenTable("SELECT * FROM DPPLADPTO WHERE PLA_CODCTA"+GetWhere("=",cCodCta))

       aData:={}

       WHILE !oTable:EOF()
          AADD(aData,{oTable:PLA_CODDEP,oTable:PLA_CTADIS,oTable:PLA_PORCEN,PORCEN(nMonto,oTable:PLA_PORCEN)})
          oTable:DbSkip()
       ENDDO

       oTable:End()
       oTable:Browse()

       nTotal:=ATOTALES(aData)[4]
 
       // Calcula Diferencias
       IF !(nTotal==nMonto) .AND. !Empty(aData)
         aData[LEN(aData),4]:=aData[LEN(aData),4]+(nMonto-nTotal)
       ENDIF

       /*
       // Realiza los Asientos por Departamento
       */
       IF LEN(aData)>0 .AND. SQLGET("DPCTA","CTA_DISDEP","CTA_CODIGO"+GetWhere("=",cCodCta)+" AND CTA_CODMOD"+GetWhere("=",oDp:cCtaMod))

          oTable:=OpenTable("SELECT * FROM DPASIENTOSDPTO",.F.)
     
          FOR I=1 TO LEN(aData)

            oTable:Append()
            oTable:Replace("ACP_NUMCBT",cNumCom )
            oTable:Replace("ACP_CODDEP",aData[I,1])
            oTable:Replace("ACP_CODCTA",cCodCta )
            oTable:Replace("ACP_FECHA" ,dFecha  )
            oTable:Replace("ACP_ACTUAL","N"     )
            oTable:Replace("ACP_ITEM"  ,cAsiento)
            oTable:Replace("ACP_CODDEP",cCodSuc )
            oTable:Replace("ACP_MONTO" ,aData[I,4])
            oTable:Replace("ACP_CTAMOD",oDp:cCtaMod)
            oTable:Replace("ACP_CODSUC",cCodSuc )
            oTable:Replace("ACP_CODDEP",aData[I,1])
            oTable:Commit()

          NEXT I

          oTable:End()
          ViewArray(aData)

       ENDIF

    ENDIF

    // Verifica Asientos de Costos
//    ? "ASIENTOCREA",cNumCom,dFecha,cModOrg,cCodCta,cTipDoc,cNumero,cDescri,nMonto,cCodAux

RETURN cAsiento
// EOF




