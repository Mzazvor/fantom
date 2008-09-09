//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 08  Brian Frank  Creation
//
package fan.fwt;

import fan.sys.*;
import fan.sys.List;
import org.eclipse.swt.*;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.*;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.events.*;

public class ComboPeer
  extends WidgetPeer
  implements Listener, ModifyListener
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static ComboPeer make(fan.fwt.Combo self)
    throws Exception
  {
    ComboPeer peer = new ComboPeer();
    ((fan.fwt.Widget)self).peer = peer;
    peer.self = self;
    return peer;
  }

  public Widget create(Widget parent)
  {
    fan.fwt.Combo self = (fan.fwt.Combo)this.self;

    int style = self.dropDown.val ? SWT.DROP_DOWN : SWT.SIMPLE;
    if (self.editable.val) style |= SWT.READ_ONLY;
    Combo c = new Combo((Composite)parent, style);
    control = c;
    c.addListener(SWT.DefaultSelection, this);
    c.addModifyListener(this);
    return c;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  // Str text := ""
  public Str text(fan.fwt.Combo self) { return text.get(); }
  public void text(fan.fwt.Combo self, Str v) { text.set(v); }
  public final Prop.StrProp text = new Prop.StrProp(this, "")
  {
    public String get(Widget w) { return ((Combo)w).getText(); }
    public void set(Widget w, String v) { ((Combo)w).setText(v);  }
  };

  // Obj[] items := Obj[,]
  public List items(fan.fwt.Combo self) { return items.get(); }
  public void items(fan.fwt.Combo self, List v) { items.set(v); }
  public final Prop.ItemsProp items = new Prop.ItemsProp (this)
  {
    public void set(Widget w, String[] v) { ((Combo)w).setItems(v); }
  };

  // Font font := null
  public fan.fwt.Font font(fan.fwt.Combo self) { return font.get(); }
  public void font(fan.fwt.Combo self, fan.fwt.Font v) { font.set(v); }
  public final Prop.FontProp font = new Prop.FontProp(this)
  {
    public void set(Widget w, Font v) { ((Combo)w).setFont(v); }
  };

//////////////////////////////////////////////////////////////////////////
// Eventing
//////////////////////////////////////////////////////////////////////////

  public void handleEvent(Event event)
  {
    fan.fwt.Combo self = (fan.fwt.Combo)this.self;
    if (event.type == SWT.DefaultSelection)
      self.onAction().fire(event(EventId.action));
  }

  public void modifyText(ModifyEvent event)
  {
    fan.fwt.Combo self = (fan.fwt.Combo)this.self;
    self.onModify().fire(event(EventId.modified));
  }

}