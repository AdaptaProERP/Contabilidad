// Programa   : DPNUMCBTEXTIPDOC
// Fecha/Hora : 25/03/2022 04:58:33
// Propósito  : Devolver Numero de Comprobante por Tipo de Documento
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cTipo,dFecha,cNumCom,cRefere,cId)
  LOCAL cNumero:=STRZERO(1,8),cSql,nAt:=0,cSintax,oDb:=OpenOdbc(oDp:cDsnData)

// ? "DPNUMCBTEXTIPDOC",cTable,cTipo
//? "cTable,cTipo,dFecha,cNumCom,cRefere,cId",cTable,cTipo,dFecha,cNumCom,cRefere,cId

  DEFAULT oDp:aNumCbte:={},;
          cTable:="DPTIPDOCCLI",;
          cTipo :="FAV",;
          dFecha:=oDp:dFecha   

  IF COUNT("DPNUMCBTE")>0
    EJECUTAR("DPNUMCBTECREA")
  ENDIF
           
  IF Empty(oDp:aNumCbte) 

     SQLUPDATE("dpnumcbte","DNC_TABLA","DPCBTE",[DNC_CODIGO="CBT"])

     cSql:=" SELECT DNC_ID,DNC_TABLA,DNC_CLAVE,DNC_CODIGO,DNC_DESCRI,DNC_SINTAX,DNC_REFERE,DNC_FCHINI,DNC_REPLAC,DNC_ACTUAL "+;
           " FROM DPNUMCBTE WHERE DNC_ACTIVO=1 "

     oDp:aNumCbte:=ASQL(cSql,oDb)
     AEVAL(oDp:aNumCbte,{|a,n| oDp:aNumCbte[n,2]:=ALLTRIM(a[2]),;
                               oDp:aNumCbte[n,3]:=ALLTRIM(a[3]),;
                               oDp:aNumCbte[n,4]:=ALLTRIM(a[4]) })

  ENDIF

  // ViewArray(oDp:aNumCbte)

  /*
  // Si es Aplicación el tipo de documento es Vacio
  */

  nAt:=0

  IF !Empty(cId)
     nAt:=ASCAN(oDp:aNumCbte,{|a,n| cId==a[1]})
  ENDIF

  IF nAt=0

    IF !Empty(cRefere)
      nAt:=ASCAN(oDp:aNumCbte,{|a,n| cRefere==a[7]})
    ELSE
      nAt:=ASCAN(oDp:aNumCbte,{|a,n| cTable==a[2] .AND. cTipo==a[4]})
    ENDIF

  ENDIF

  // Ahora busca por tipo de documento, caso contabilidad DPCBTEPAGO y debe ser DPCBTE
  IF nAt=0 .AND. cTipo="CBT"
    nAt:=ASCAN(oDp:aNumCbte,{|a,n| cTipo==a[4]})
  ENDIF


  oDp:cCbteNombre:=""

  IF nAt>0

     cSintax:=oDp:aNumCbte[nAt,6]
     cNumero:=EJECUTAR("DPNUMCBTSINTAX",cSintax,dFecha)

     oDp:lCbteActual:=oDp:aNumCbte[nAt,10]
     oDp:cCbteNombre:=oDp:aNumCbte[nAt,05]
     oDp:cCbteNombre:=oDp:cCbteNombre+IIF(Empty(oDp:cCbteNombre),"","/ ")+oDp:aNumCbte[nAt,5]


  ELSE

    ViewArray(oDp:aNumCbte)
    ? "NUMERO CBTE SIN SINTAXIS",cTable,cTipo,dFecha,cNumCom,cRefere,cId

  ENDIF

// ?cTable,cTipo,dFecha,nAt,cSintax,cNumero,oDp:cCbteNombre
//  ViewArray(oDp:aNumCbte)

RETURN cNumero
//
