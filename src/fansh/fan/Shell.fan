//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Jan 08  Brian Frank  Creation
//

using compiler
using concurrent

**
** Fantom Shell
**
class Shell
{

//////////////////////////////////////////////////////////////////////////
// Main Loop
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the shell main loop.
  **
  Void run()
  {
    warmup
    out.printLine("Fantom Shell v${Pod.of(this).version} ('?' for help)")
    while (isAlive)
    {
      // input next line
      line := Env.cur.prompt("fansh> ") ?: "quit"

      // skip empty lines
      line = line.trim
      if (line.size == 0) continue

      // check if line maps to predefined command
      if (command(line)) continue

      // evaluate the line
      Evaluator(this).eval(line)
    }
  }

  private Void warmup()
  {
    // launch a dummy evaluator to preload
    // all the compiler code into memory
    f := |->| { Evaluator(null).eval("0") }
    Actor(ActorPool(), f).send(null)
  }

//////////////////////////////////////////////////////////////////////////
// Commands
//////////////////////////////////////////////////////////////////////////

  **
  ** If the line maps to a command function, then run
  ** it and return true.  Otherwise return false.
  **
  Bool command(Str line)
  {
    switch (line)
    {
      case "bye":
      case "exit":
      case "quit":
        quit
        return true
      case "help":
      case "usage":
      case "?":
        help
        return true
      case "clear":
        clear
        return true
      case "scope":
        dumpScope
        return true
    }

    if (line.startsWith("using "))
    {
      addUsing(line)
      return true
    }

    return false
  }

  **
  ** Run the 'quit' command.
  **
  Void quit()
  {
    isAlive = false
  }

  **
  ** Run the 'help' command.
  **
  Void help()
  {
    out.printLine
    out.printLine("Fantom Shell v${Pod.of(this).version}")
    out.printLine("Commands:")
    out.printLine("  quit, exit, bye   exit shell")
    out.printLine("  ?, help, usage    help summary")
    out.printLine("  clear             clear the using imports and local variables")
    out.printLine("  scope             dump the using imports and local variables")
    out.printLine("  using x           import pod x into namespace (any valid using stmt allowed)")
    out.printLine
  }

  **
  ** Clear the environment
  **
  Void clear()
  {
    usings.clear
    scope.clear
  }

  **
  ** Run the 'scope' command.
  **
  Void dumpScope()
  {
    out.printLine
    out.printLine("Current Usings:")
    usings.each |u| { out.printLine("  $u.target") }
    out.printLine
    out.printLine("Current Scope:")
    scope.vals.sort.each |v| { out.printLine("  $v.of $v.name = $v.val") }
    out.printLine
  }

  **
  ** Add using statement after we
  **
  Void addUsing(Str line)
  {
    s := line["using ".size..-1].trim
    u := Use(s)
    usings.add(u)
    ok := Evaluator(this).eval("Add using: $line".toCode)
    if (!ok) usings.remove(u)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  internal Var? findInScope(Str name)
  {
    return scope.find |Var v->Bool| { v.name == name }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  OutStream out := Env.cur.out
  InStream in := Env.cur.in
  internal Bool isAlive := true
  internal Int evalCount := 0
  internal Str:Var scope := Str:Var[:]
  internal Use[] usings := Use[,]

}

**************************************************************************
** Var
**************************************************************************

internal class Var
{
  override Int compare(Obj obj) { return ((Var)obj).name <=> name }

  Type of := Obj#
  Str? name
  Obj? val
}

**************************************************************************
** Use
**************************************************************************

internal class Use
{
  new make(Str target)
  {
    this.target = target
    if (target.contains(" as "))
    {
      asFrom = target[0.. target.index(" as ")].trim.replace(" ", "")
      asTo   = target[target.index(" as ")+4..-1].trim
    }
  }

  Bool matchAs(Type t)
  {
    sig := t.toNonNullable.signature
    return asFrom == sig
  }

  const Str target
  const Str? asFrom
  const Str? asTo
}

**************************************************************************
** Main
**************************************************************************

**
** Main launcher for fan shell.
**
class Main { static Void main() { Shell.make.run } }