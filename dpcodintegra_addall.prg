// Programa   : DPCODINTEGRA_ADDALL
// Fecha/Hora : 02/02/2025 03:52:49
// Prop�sito  : Agrega todos los c�digos de Integraci�n
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  EJECUTAR("DPCODINTEGRA_ADD","DIFRECMON"  ,"Diferencia por Reconversi�n Monetar�")
  EJECUTAR("DPCODINTEGRA_ADD","INDEFINIDA" ,"Integraci�n Indefinida con Asientos ")
  EJECUTAR("DPCODINTEGRA_ADD","DIFCBTPAG"  ,"Diferencia en Comprobantes de Pago")
  EJECUTAR("DPCODINTEGRA_ADD","DIFRECING"  ,"Diferencia en Recibos de Ingreso")

  // Agregar C�digo de Integraci�n
  EJECUTAR("DPCODINTEGRA_ADD","DIFRECMON"  ,"Diferencia por Reconversi�n Monetaria ")
  EJECUTAR("DPCODINTEGRA_ADD","INDEFINIDA" ,"Integraci�n Indefinida con Asientos ")
  EJECUTAR("DPCODINTEGRA_ADD","DIFCBTPAG"  ,"Diferencia en Comprobantes de Pago")
  EJECUTAR("DPCODINTEGRA_ADD","DIFRECING"  ,"Diferencia en Recibos de Ingreso")

  EJECUTAR("DPCODINTEGRA_CREA","ENTINV","Entradas de Inventario")
  EJECUTAR("DPCODINTEGRA_CREA","SALINV","Salidas de Inventario")

  EJECUTAR("DPCODINTEGRA_ADD","ACTACT","Activos Cuenta Contable del Activo")
  EJECUTAR("DPCODINTEGRA_ADD","ACTACU","Activos Depreciaci�n del Activo")
  EJECUTAR("DPCODINTEGRA_ADD","ACTDEP","Activos Depreciaci�n Gasto")
  EJECUTAR("DPCODINTEGRA_ADD","ACTREV","Activos Revalorizaci�n")

  EJECUTAR("DPCODINTEGRA_ADD","VTAANT","Venta Anticipada")

  EJECUTAR("DPCODINTEGRA_ADD","VTAPUB","Ventas Sector P�blico")
  EJECUTAR("DPCODINTEGRA_ADD","VTAANT","Venta Anticipada")

  EJECUTAR("DPCODINTEGRA_ADD","COMRMU","Retenci�n Municipal Proveedores" )
  EJECUTAR("DPCODINTEGRA_ADD","VTARMU","Retenci�n Municipal Clientes" )

  EJECUTAR("DPCODINTEGRA_ADD","COMANT","Anticipo Proveedores" )
  EJECUTAR("DPCODINTEGRA_ADD","VTAANT","Anticipo Clientes" )

  EJECUTAR("DPCODINTEGRA_ADD","CAJNAC","Caja Moneda Nacional" )
  EJECUTAR("DPCODINTEGRA_ADD","CAJEXT","Caja Moneda Extranjera" )

  EJECUTAR("DPCODINTEGRA_ADD","BCONAC","Banco Moneda Nacional" )
  EJECUTAR("DPCODINTEGRA_ADD","BCOEXT","Banco Moneda Extranjera" )

  EJECUTAR("DPCODINTEGRA_ADD","DIFGASAXI","Gasto por Ajuste por Inflaci�n")
  EJECUTAR("DPCODINTEGRA_ADD","DIFINGAXI","Ingreso por Ajuste por Inflaci�n")
  EJECUTAR("DPCODINTEGRA_ADD","DIFPATAXI","Diferencia Patrimonial por Inflaci�n")

  EJECUTAR("DPCODINTEGRA_ADD","VTASER","Ingresos/Venta por Servicios" ) // Planilla DPJ26, Casilla 700 y 797
  EJECUTAR("DPCODINTEGRA_ADD","VTAHON","Ingresos/Venta por Honorarios") // Planilla DPJ26, Casilla 700 y 797

RETURN .T.
// EOF
