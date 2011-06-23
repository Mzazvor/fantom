//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Jun 11  Brian Frank  Creation
//

**
** EnvCmd is used to query the local env pods
**
internal class EnvCmd : Command
{

//////////////////////////////////////////////////////////////////////////
// Usage
//////////////////////////////////////////////////////////////////////////

  override Str name() { "env" }

  override Str summary() { "query pods installed in local environment" }

//////////////////////////////////////////////////////////////////////////
// Args/Opts
//////////////////////////////////////////////////////////////////////////

  @CommandArg
  {
    name = "query"
    help = "query filter used to match pods in env"
  }
  Str? query

//////////////////////////////////////////////////////////////////////////
// Execution
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    // perform query
    specs := findAll(query, out)

    // handle no pods found
    if (specs.isEmpty)
    {
      out.printLine("No pods found")
      return
    }

    // format to output
    specs.sort.each |spec|
    {
      printPodVersion(spec)
    }
  }

  internal static PodSpec[] findAll(Str query, OutStream out)
  {
    q := Query.fromStr(query)
    env := Env.cur

    // optimize one exact pod name (no wildcards)
    if (q.parts.size == 1 && q.parts[0].isNameExact)
    {
      file := env.findPodFile(q.parts[0].namePattern)
      if (file == null) return PodSpec[,]
      return [PodSpec.load(file)]
    }

    // search thru all of them
    acc := PodSpec[,]
    env.findAllPodNames.each |name|
    {
      try
      {
        file := env.findPodFile(name)
        spec := PodSpec.load(file)
        if (q.include(spec)) acc.add(spec)
      }
      catch (Err e) out.printLine("ERROR: Cannot query pod: $name\n  $e")
    }
    return acc
  }

}