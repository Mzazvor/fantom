//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Apr 08  Brian Frank  Creation
//

**
** Decimal is used to represent a decimal floating point
** more precisely than a Float.  Decimal is the preferred
** numeric type for financial applications.
**
const final class Decimal : Num
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a Str into a Decimal.  If invalid format and
  ** checked is false return null, otherwise throw ParseErr.
  **
  static Decimal? fromStr(Str s, Bool checked := true)

  **
  ** Default value is 0.
  **
  static const Decimal defVal

  **
  ** Private constructor.
  **
  private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if same decimal with same scale.
  **
  override Bool equals(Obj? obj)

  **
  ** Compare based on decimal value, scale is not
  ** considered for equality (unlike `equals`).
  **
  override Int compare(Obj obj)

  **
  ** Return platform specific hashcode.
  **
  override Int hash()

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Negative of this.  Shortcut is -a.
  **
  Decimal negate()

  **
  ** Multiply this with b.  Shortcut is a*b.
  **
  Decimal mult(Decimal b)

  **
  ** Divide this by b.  Shortcut is a/b.
  **
  Decimal div(Decimal b)

  **
  ** Return remainder of this divided by b.  Shortcut is a%b.
  **
  Decimal mod(Decimal b)

  **
  ** Add this with b.  Shortcut is a+b.
  **
  Decimal plus(Decimal b)

  **
  ** Subtract b from this.  Shortcut is a-b.
  **
  Decimal minus(Decimal b)

  **
  ** Increment by one.  Shortcut is ++a or a++.
  **
  Decimal increment()

  **
  ** Decrement by one.  Shortcut is --a or a--.
  **
  Decimal decrement()

/////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the absolute value of this decimal.  If this value is
  ** positive then return this, otherwise return the negation.
  **
  Decimal abs()

  **
  ** Return the smaller of this and the specified Decimal values.
  **
  Decimal min(Decimal that)

  **
  ** Return the larger of this and the specified Decimal values.
  **
  Decimal max(Decimal that)

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Get string representation.
  **
  override Str toStr()

}