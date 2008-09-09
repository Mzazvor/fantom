//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 May 07  Brian Frank  Creation
//

using compiler
using fandoc

**
** ApiToHtmlGenerator generates an HTML file for a Type's API
**
class ApiToHtmlGenerator : HtmlGenerator
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(DocCompiler compiler, Location loc, OutStream out, Type t)
    : super(compiler, loc, out)
  {
    this.t = t
    sorter := |Slot a, Slot b -> Int| { return a.name <=> b.name }
    filter := |Slot s -> Bool| { return showSlot(t, s) }
    this.slots = t.slots.rw.sort(sorter).findAll(filter)
  }

//////////////////////////////////////////////////////////////////////////
// Generator
//////////////////////////////////////////////////////////////////////////

  override Str title()
  {
    return t.qname
  }

  override Void header()
  {
    out.print("<ul>\n")
    out.print("  <li><a href='../index.html'>$docHome</a></li>\n")
    out.print("  <li><a href='index.html'>$t.pod.name</a></li>\n")
    out.print("  <li><a href='${t.name}.html'>$t.name</a></li>\n")
    out.print("</ul>\n")
  }

  override Void content()
  {
    out.print("<div class='type'>\n")
    typeOverview
    typeDetail
    out.print("</div>\n")
    slotsDetail
  }

  override Void sidebar()
  {
    actions
    slotsOverview
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the Uri for the source file of this Type.
  **
  Str source()
  {
    return "${t.name}_src.html"
  }

  **
  ** Generate the actions.
  **
  Void actions()
  {
    out.print("<h2>More Info</h2>\n")
    out.print("<ul class='clean'>\n")
    out.print("  <li><a href='$source'>View Source</a></li>\n")
    out.print("  <li><a href='#' onclick='ShowSlots.toggle(event); return false;'>")
    out.print("Show All Slots</a></li>\n")
    out.print("</ul>\n")
  }

  **
  ** Generate the type overview documentation.
  **
  Void typeOverview()
  {
    out.print("<div class='overview'>\n")
    out.print("<h2>")
    if (t.isMixin) out.print("mixin")
    else
    {
      if (t.isAbstract) out.print("abstract ")
      if (t.isConst) out.print("const ")
      if (t.isFinal) out.print("final ")
      if (t.isEnum)
        out.print("enum")
      else
        out.print("class")
    }
    out.print("</h2>\n")
    out.print("<h1>$t.qname</h1>\n")
    if (t.base != null) inheritance
    out.print("</div>\n")
  }

  **
  ** Generate the type detail documentation.
  **
  Void typeDetail()
  {
    if (t.doc == null) return
    out.print("<div class='detail'>\n")
    fandoc(t.qname, t.doc)
    if (t.isEnum)
    {
      out.print("<ul>\n")
      vals := t.field("values").get as Obj[]
      vals.each |Obj obj|
      {
        out.print("<li><a href='#$obj'>").print(obj).print("</a></li>\n")
      }
      out.print("</ul>\n")
    }
    out.print("</div>\n")
  }

  **
  ** Generate the type inheritance.
  **
  Void inheritance()
  {
    chain := Type[t]
    base  := t.base
    while (base != null)
    {
      chain.insert(0, base)
      base = base.base
    }
    out.print("<pre>")
    chain.each |Type t, Int i|
    {
      if (i > 0) out.print("\n${Str.spaces(i*2)}")
      if (i == chain.size-1) out.print(t.qname)
      else out.print("<a href='${compiler.uriMapper.map(t.qname, loc)}'>$t.qname</a>")
    }
    t.mixins.each |Type t, Int i|
    {
      //if (i == 0) out.print("\n\nMixin: ")
      if (i == 0) out.print(" : ")
      else out.print(", ")
      out.print("<a href='${compiler.uriMapper.map(t.qname, loc)}'>$t.qname</a>")
    }
    out.print("</pre>")
  }

  **
  ** Generate the slot overview documentation.
  **
  Void slotsOverview(Bool hideByDefault := true)
  {
    out.print("<div class='slots'>\n")
    out.print("<div class='overview'>\n")
    out.print("<h2>Slots</h2>\n")
    out.print("<ul class='clean'>\n")
    slots.each |Slot slot|
    {
      if (!showSlot(t, slot)) return
      out.print("  <li")
      if (!showByDefault(t, slot)) out.print(" class='hidden'")
      if (!hideByDefault) out.print(" style='display: block;'")
      out.print("><a href='#$slot.name'>$slot.name</a></li>\n")
    }
    out.print("</ul>\n")
    out.print("</div>\n")
    out.print("</div>\n")
  }

  **
  ** Generate the slot detail documentation.
  **
  Void slotsDetail()
  {
    out.print("<div class='slots'>\n")
    out.print("<div class='detail'>\n")
    out.print("<h2>Slots</h2>\n")
    out.print("<dl>\n")
    slots.each |Slot slot| { slotDetail(slot) }
    out.print("</dl>\n")
    out.print("</div>\n")
    out.print("</div>\n")
  }

  **
  ** Generate the documentation for the given slot.
  **
  Void slotDetail(Slot slot)
  {
    if (!showSlot(t, slot)) return

    oldfile := loc.file
    loc.file = slot.qname
    doc := slot.doc

    hidden := !showByDefault(t, slot)
    cls := (slot.isField) ? "field" : "method"
    if (hidden) cls += " hidden"
    out.print("<dt id='$slot.name' class='$cls'>$slot.name")
      out.print("<a href='$source#$slot.name'>Source</a></dt>\n")
    out.print("<dd")
    if (hidden) out.print(" class='hidden'")
    out.print(">\n")

    // Slot spec
    out.print("<p><code>")
    if (slot.isField)
    {
      f := (Field)slot
      meta := parseMeta(slot.doc)
      slotModifiers(f)
      typeLink(f.of)
      out.print(" $f.name")
      def := meta["def"]
      if (def != null) out.print(" := $def")
      setter(f)
    }
    else
    {
      m := (Method)slot
      if (m.isCtor) out.print("new")
      else
      {
        slotModifiers(m)
        typeLink(m.returns)
      }
      out.print(" $m.name")
      out.print("(")
      meta := parseMeta(slot.doc)
      m.params.each |Param p, Int i|
      {
        if (i > 0) out.print(", ")
        typeLink(p.of)
        out.print(" $p.name")
        if (p.hasDefault)
        {
          out.print(" := ")
          out.print(meta.get("${p.name}.def", "def"))
        }
      }
      out.print(")")
    }
    out.print("</code></p>\n")

    // inherited
    if (slot.isOverride)
    {
      // if no-doc, walk inheritance for doc
      base := t.base
      while (doc == null && base != null)
      {
        doc = base.slot(slot.name, false)?.doc
        base = base.base
      }

/* TODO: this code isn't right and when it does it
should link to the slot
      out.print("<p>Inherited from ")
      typeLink(t.base)
      out.print("</p>\n")
*/
    }

    // Slot comment
    if (doc != null)
      fandoc(slot.qname, doc)

    out.print("</dd>\n")

    loc.file = oldfile
  }

  **
  ** Write a slot's modifiers.
  **
  Void slotModifiers(Slot s)
  {
    if (s.isVirtual)
    {
      if (s.isAbstract) out.print("abstract ")
      else if (s.isOverride) out.print("override ")
      else out.print("virtual ")
    }

    if (s.isStatic) out.print("static ")
    else if (s.isConst) out.print("const ")

    if (s.isProtected) out.print("protected ")
    else if (s.isPrivate)   out.print("private ")
    else if (s.isInternal)  out.print("internal ")

    if (s.isNative) out.print("native ")

    if (s.isField)
    {
      Method z := s->setter
      if (z != null && !s.isPrivate && z.isPrivate) out.print("readonly ")
    }
  }

  **
  ** Write a field's setter proctection level if its different
  ** from the getter's level.
  **
  Void setter(Field f)
  {
    Method s := f->setter
    if (s == null) return
    if (f.isPublic    && s.isPublic)    return
    if (f.isProtected && s.isProtected) return
    if (f.isPrivate   && s.isPrivate)   return
    if (f.isInternal  && s.isInternal)  return

    // this case handled already in slotModifers() by writing 'readonly'
    if (!f.isPrivate && s.isPrivate) return

    // if we made this far, they must be different
    out.print(" { ")
    slotModifiers(s)
    out.print("set }")
  }

  **
  ** Convenience for <code>out.print(makeTypeLink(t))</code>.
  **
  Void typeLink(Type t)
  {
    map := |Type x->Uri| { return compiler.uriMapper.map(x.qname, loc) }
    out.print(makeTypeLink(t, map))
  }

  **
  ** Make a type link out in the form <a href='type.uri'>type.name</a>.
  **
  static Str makeTypeLink(Type t, |Type->Uri| map)
  {
    if (!t.isGeneric)
    {
      p := t.params
      if (p["L"] != null)
      {
        of := p["V"]
        return "${makeTypeLink(of,map)}[]"
      }
      if (p["M"] != null)
      {
        key := p["K"]
        val := p["V"]
        return "${makeTypeLink(key,map)}:${makeTypeLink(val,map)}"
      }
      if (p["R"] != null)
      {
        buf := StrBuf().addChar('|')
        keys := p.keys.rw.sort |Str a, Str b -> Int| { return a <=> b }
        keys.each |Str k, Int i|
        {
          if (k == "R") return
          if (i > 0) buf.add(", ")
          buf.add(makeTypeLink(p[k], map))
        }
        if (p["R"] != Void#) buf.add(" -> ").add(makeTypeLink(p["R"], map))
        buf.addChar('|')
        return buf.toStr
      }
    }

    // map A,B,C... to Obj
    if (t.pod.name == "sys" && t.name.size == 1)
      return "<a href='${map(Obj#)}'>$t.name</a>"

    return "<a href='${map(t)}'>$t.name</a>"
  }

  **
  ** Parse def parameters.
  **
  Str:Str parseMeta(Str text)
  {
    meta := Str:Str[:]
    if (text == null || !text.startsWith("@"))
      return meta

    InStream.makeForStr(text).eachLine |Str line|
    {
      if (!line.startsWith("@")) return
      i := line.index("=")
      if (i == null) return
      meta[line[1...i]] = line[i+1..-1].trim
    }

    return meta
  }

  **
  ** Write out the fandoc for this text - if an exception
  ** is thrown, write the original text.
  **
  Void fandoc(Str qname, Str text)
  {
    try
    {
      // TODO - we could save some cycles here by reusing
      // the stream we used for parseDefs

      in := InStream.makeForStr(text)
      while (in.peek == '@') in.readLine // eat def args if they exist

      doc := FandocParser().parse("API for $qname", in)
      doc.children.each |DocNode child| { child.write(this) }
    }
    catch { out.print("<p>$text<p>\n") }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Type t        // type to documenting
  Slot[] slots  // slots to document

}
