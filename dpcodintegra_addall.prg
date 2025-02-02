// Programa   : DPCODINTEGRA_ADDALL
// Fecha/Hora : 02/02/2025 03:52:49
// Propósito  : Agrega todos los códigos de Integración
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  EJECUTAR("DPCODINTEGRA_ADD","DIFRECMON"  ,"Diferencia por Reconversión Monetarí")
  EJECUTAR("DPCODINTEGRA_ADD","INDEFINIDA" ,"Integración Indefinida con Asientos ")
  EJECUTAR("DPCODINTEGRA_ADD","DIFCBTPAG"  ,"Diferencia en Comprobantes de Pago")
  EJECUTAR("DPCODINTEGRA_ADD","DIFRECING"  ,"Diferencia en Recibos de Ingreso")

  // Agregar Código de Integración
  EJECUTAR("DPCODINTEGRA_ADD","DIFRECMON"  ,"Diferencia por Reconversión Monetaria ")
  EJECUTAR("DPCODINTEGRA_ADD","INDEFINIDA" ,"Integración Indefinida con Asientos ")
  EJECUTAR("DPCODINTEGRA_ADD","DIFCBTPAG"  ,"Diferencia en Comprobantes de Pago")
  EJECUTAR("DPCODINTEGRA_ADD","DIFRECING"  ,"Diferencia en Recibos de Ingreso")

  EJECUTAR("DPCODINTEGRA_CREA","ENTINV","Entradas de Inventario")
  EJECUTAR("DPCODINTEGRA_CREA","SALINV","Salidas de Inventario")

  EJECUTAR("DPCODINTEGRA_ADD","ACTACT","Activos Cuenta Contable del Activo")
  EJECUTAR("DPCODINTEGRA_ADD","ACTACU","Activos Depreciación del Activo")
  EJECUTAR("DPCODINTEGRA_ADD","ACTDEP","Activos Depreciación Gasto")
  EJECUTAR("DPCODINTEGRA_ADD","ACTREV","Activos Revalorización")

  EJECUTAR("DPCODINTEGRA_ADD","VTAANT","Venta Anticipada")

  EJECUTAR("DPCODINTEGRA_ADD","VTAPUB","Ventas Sector Público")
  EJECUTAR("DPCODINTEGRA_ADD","VTAANT","Venta Anticipada")

  EJECUTAR("DPCODINTEGRA_ADD","COMRMU","Retención Municipal Proveedores" )
  EJECUTAR("DPCODINTEGRA_ADD","VTARMU","Retención Municipal Clientes" )

  EJECUTAR("DPCODINTEGRA_ADD","COMANT","Anticipo Proveedores" )
  EJECUTAR("DPCODINTEGRA_ADD","VTAANT","Anticipo Clientes" )

  EJECUTAR("DPCODINTEGRA_ADD","CAJNAC","Caja Moneda Nacional" )
  EJECUTAR("DPCODINTEGRA_ADD","CAJEXT","Caja Moneda Extranjera" )

  EJECUTAR("DPCODINTEGRA_ADD","BCONAC","Banco Moneda Nacional" )
  EJECUTAR("DPCODINTEGRA_ADD","BCOEXT","Banco Moneda Extranjera" )

  EJECUTAR("DPCODINTEGRA_ADD","DIFGASAXI","Gasto por Ajuste por Inflación")
  EJECUTAR("DPCODINTEGRA_ADD","DIFINGAXI","Ingreso por Ajuste por Inflación")
  EJECUTAR("DPCODINTEGRA_ADD","DIFPATAXI","Diferencia Patrimonial por Inflación")

  EJECUTAR("DPCODINTEGRA_ADD","VTASER","Ingresos/Venta por Servicios" ) // Planilla DPJ26, Casilla 700 y 797
  EJECUTAR("DPCODINTEGRA_ADD","VTAHON","Ingresos/Venta por Honorarios") // Planilla DPJ26, Casilla 700 y 797

RETURN .T.
// EOF
