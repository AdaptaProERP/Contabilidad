// Programa   : VALCODINT
// Fecha/Hora : 07/03/2024 19:43:49
// Propósito  : Validar Códigos de Integración para Generar Asientos Contables
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lValida,aCodInt,oFrm)
   LOCAL cCodCta:="",cWhere:=""
   LOCAL aCodReq:={}

   DEFAULT lValida:=.T.,;
           aCodInt:={}

   oDp:aCodInt:={}

   IF lValida

     FOR I=1 TO LEN(aCodInt)

      cCodCta  :=EJECUTAR("DPGETCTAMOD","DPCODINTEGRA_CTA",aCodInt[I],"","CODCTA")

      IF (Empty(cCodCta) .OR. cCodCta=oDp:cCtaIndef) 
        AADD(aCodReq,aCodInt[I])
      ENDIF

      AADD(oDp:aCodInt,{aCodInt[I],cCodCta})

      IF ValType(oFrm)="O"
         oFrm:Set(aCodInt[I],cCodCta) // Asigna variable Dinámica, ejemplo:  oFrm:ACTACU:="1.1.1.2." , oFrm:ACTDEP:="6.1.2.2.3.3."
      ENDIF

     NEXT I

     ADEPURA(aCodReq,{|a,n| Empty(a)})

   ELSE

     aCodReq:=aCodInt

   ENDIF

   IF !Empty(aCodReq) 

      cWhere:=GetWhereOr("CIN_CODIGO",aCodReq)
      IF COUNT("DPCODINTEGRA",cWhere)=0
         EJECUTAR("DPCODINTEGRA_ADDALL")
      ENDIF

      EJECUTAR("BRDPCODINTCTA",cWhere)

   ENDIF

RETURN Empty(aCodReq)
// EOF
