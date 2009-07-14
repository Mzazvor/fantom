//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 May 09  Brian Frank  Creation
//

**
** Symbol models a qualified name/value pair.
**
final const class Symbol
{

  **
  ** Find a Symbol by it's qualified name "pod::name".  If the symbol
  ** doesn't exist and checked is false then return null, otherwise
  ** throw UnknownPodErr or UnknownSymbolErr.
  **
  static Symbol? find(Str qname, Bool checked := true)

  **
  ** Private constructor.
  **
  private new make()

  **
  ** Pod which declared this symbol.
  **
  Pod pod()

  **
  ** Qualified name of symbol is "{pod.name}::{name}".
  **
  Str qname()

  **
  ** Get the simple, unqualified name of the symbol.
  **
  Str name()

  **
  ** Get the value type of the symbol.
  **
  Type of()

  **
  ** Get the default value of the symbol as originally declared.
  ** Use `val` to get the current value.
  **
  Obj? defVal()

  **
  ** Get the current value of the symbol.
  **
  Obj? val()

  **
  ** Hashcode is based on `qname`.
  **
  override Int hash()

  **
  ** Two symbols are equal if they have same `qname`.
  **
  override Bool equals(Obj? that)

  **
  ** Return "@qname".
  **
  override Str toStr()

}