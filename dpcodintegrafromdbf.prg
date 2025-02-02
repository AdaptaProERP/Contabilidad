// Programa   : DPCODINTEGRAFROMDBF
// Fecha/Hora : 27/02/2024 11:18:33
// Propósito  : Importar Códigos de Integración Contable
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
 LOCAL cFile:="dp\DPCODINTEGRA.DBF"
 LOCAL cWhere,oTable

 IF !FILE(cFile)
    RETURN NIL
 ENDIF

 oTable:=OpenTable("SELECT * FROM DPCODINTEGRA",.F.)
 oTable:lAuditar:=.F.

 CLOSE ALL
 USE (cFile) EXCLU

 WHILE !EOF()

    cWhere:="CIN_CODIGO"+GetWhere("=",A->CIN_CODIGO)

    IF !ISSQLFIND("DPCODINTEGRA",cWhere)
       oTable:AppendBlank()
       AEVAL(DBSTRUCT(),{|a,n| oTable:Replace(a[1],FIELDGET(n))})
       oTable:Commit("")
    ENDIF

    DBSKIP()

 ENDDO

 oTable:End()
 CLOSE ALL

RETURN .T.
// EOF

