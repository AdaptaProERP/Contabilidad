// Programa   : DPCODINTEGRA_ADDALL
// Fecha/Hora : 02/02/2025 03:52:49
// Prop�sito  : Agrega todos los c�digos de Integraci�n
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  EJECUTAR("DPCODINTEGRA_ADD","DIFRECMON"  ,"Diferencia por Reconversi�n Monetar�a")
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

  EJECUTAR("DPCODINTEGRA_ADD","SERIESFISCAL","Series Fiscales")

  EJECUTAR("DPCODINTEGRA_ADD","VTASER","Ingresos/Venta por Servicios" ) // Planilla DPJ26, Casilla 700 y 797
  EJECUTAR("DPCODINTEGRA_ADD","VTAHON","Ingresos/Venta por Honorarios") // Planilla DPJ26, Casilla 700 y 797

  EJECUTAR("DPCODINTEGRA_ADD","VTAPUB","Ventas Sector P�blico")

  EJECUTAR("DPCODINTEGRA_ADD","INVCTAACT"  ,"Inventario Activos")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTAINI"  ,"Inventario Inicial")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTAFIN"  ,"Inventario Final")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTACOM"  ,"Inventario Compras")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTACOS"  ,"Inventario Costo de Venta")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTACOM"  ,"Inventario Compras")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTAVTA"  ,"Inventario Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTADVV"  ,"Inventario Devoluci�n de Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","INVCTADVC"  ,"Inventario Deoluci�n de Compras")

  EJECUTAR("DPCODINTEGRA_ADD","VTAIVA"  ,"IVA Transacciones de Venta")
  EJECUTAR("DPCODINTEGRA_ADD","COMIVA"  ,"IVA Transacciones de Compras")

  EJECUTAR("DPCODINTEGRA_ADD","VTACRE","Nota de Cr�dito en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTADEB","Nota de D�bito en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTARTI","Retenci�n de IVA en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTARET","Retenci�n de ISLR en Ventas")
  EJECUTAR("DPCODINTEGRA_ADD","VTAMUN","Retenci�n Municipal en Ventas")

  EJECUTAR("DPCODINTEGRA_ADD","COMCRE","Nota de Cr�dito en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMDEB","Nota de D�bito en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMRTI","Retenci�n de IVA en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMRET","Retenci�n de ISLR en Compras")
  EJECUTAR("DPCODINTEGRA_ADD","COMMUN","Retenci�n Municipal en Compras")

RETURN .T.
// EOF
