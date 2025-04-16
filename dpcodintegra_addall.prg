// Programa   : DPCODINTEGRA_ADDALL
// Fecha/Hora : 02/02/2025 03:52:49
// Propósito  : Agrega todos los códigos de Integración
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  EJECUTAR("DPCODINTEGRA_ADD","DIFRECMON"  ,"Diferencia por Reconversión Monetaría")
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

  EJECUTAR("DPCODINTEGRA_ADD","SERIESFISCAL","Series Fiscales")

  EJECUTAR("DPCODINTEGRA_ADD","VTASER","Ingresos/Venta por Servicios" ) // Planilla DPJ26, Casilla 700 y 797
  EJECUTAR("DPCODINTEGRA_ADD","VTAHON","Ingresos/Venta por Honorarios") // Planilla DPJ26, Casilla 700 y 797

  EJECUTAR("DPCODINTEGRA_ADD","VTAPUB","Ventas Sector Público")

  EJECUTAR("DPCODINTEGRA_ADD","INVCTAACT"  ,"Inventario Activos")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTAINI"  ,"Inventario Inicial")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTAFIN"  ,"Inventario Final")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTACOM"  ,"Inventario Compras")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTACOS"  ,"Inventario Costo de Venta")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTACOM"  ,"Inventario Compras")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTAVTA"  ,"Inventario Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTADVV"  ,"Inventario Devolución de Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTADVC"  ,"Inventario Deolución de Compras")

  EJECUTAR("DPCODINTEGRA_ADD","VTAIVA"  ,"IVA Transacciones de Venta")
  EJECUTAR("DPCODINTEGRA_ADD","COMIVA"  ,"IVA Transacciones de Compras")

  EJECUTAR("DPCODINTEGRA_ADD","VTACRE","Nota de Crédito en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTADEB","Nota de Débito en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTARTI","Retención de IVA en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTARET","Retención de ISLR en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTAMUN","Retención Municipal en Ventas")

  EJECUTAR("DPCODINTEGRA_ADD","COMCRE","Nota de Crédito en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMDEB","Nota de Débito en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMRTI","Retención de IVA en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMRET","Retención de ISLR en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMMUN","Retención Municipal en Compras")

RETURN .T.
// EOF
