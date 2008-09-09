//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Oct 06  Andy Frank  Creation
//

using System;
using System.Text;
using Fanx.Serial;

namespace Fan.Sys
{
  /// <summary>
  /// Duration
  /// </summary>
  public sealed class Duration : FanObj, Literal
  {

  //////////////////////////////////////////////////////////////////////////
  // Construction
  //////////////////////////////////////////////////////////////////////////

    public static Duration fromStr(Str s) { return fromStr(s, Bool.True); }
    public static Duration fromStr(Str s, Bool check)
    {
      //   ns:   nanoseconds  (x 1)
      //   ms:   milliseconds (x 1,000,000)
      //   sec:  seconds      (x 1,000,000,000)
      //   min:  minutes      (x 60,000,000,000)
      //   hr:   hours        (x 3,600,000,000,000)
      //   day:  days         (x 86,400,000,000,000)
      try
      {
        string str = s.val;
        int len = str.Length;
        int x1 = str[len-1];
        int x2 = str[len-2];
        int x3 = str[len-3];
        bool dot = str.IndexOf('.') > 0;

        long mult = -1;
        int suffixLen  = -1;
        switch (x1)
        {
          case 's':
            if (x2 == 'n') { mult=1L; suffixLen=2; } // ns
            if (x2 == 'm') { mult=1000000L; suffixLen=2; } // ms
            break;
          case 'c':
            if (x2 == 'e' && x3 == 's') { mult=1000000000L; suffixLen=3; } // sec
            break;
          case 'n':
            if (x2 == 'i' && x3 == 'm') { mult=60000000000L; suffixLen=3; } // min
            break;
          case 'r':
            if (x2 == 'h') { mult=3600000000000L; suffixLen=2; } // hr
            break;
          case 'y':
            if (x2 == 'a' && x3 == 'd') { mult=86400000000000L; suffixLen=3; } // day
            break;
        }

        if (mult < 0) throw new Exception();

        str = str.Substring(0, len-suffixLen);
        if (dot)
          return make((long)(Double.Parse(str)*(double)mult));
        else
          return make(Int64.Parse(str)*mult);
      }
      catch (Exception)
      {
        if (!check.val) return null;
        throw ParseErr.make("Duration",  s).val;
      }
    }

    public static Duration make(Int ticks) { return make(ticks.val); }
    public static Duration make(long ticks)
    {
      if (ticks == 0) return Zero;
      return new Duration(ticks);
    }

    public static Duration makeMillis(long ms)
    {
      return make(ms*1000000L);
    }

    public static Duration makeSec(long secs)
    {
      return make(secs*1000000000L);
    }

    public static Duration now()
    {
      // TODO - need to be like System.nanoTime()
      /*
      Brian: you want to find whatever wraps getTickCount
      (or call the win32 function directly) 10:40PM Mon

      Brian: there is also QueryPerformanceCounter, you
      might want to check what System.nanoTime does for
      win32 in the HotSpot cod
      */

      return new Duration(System.DateTime.Now.Ticks * 100);
    }

    public static Duration boot()
    {
      return m_boot;
    }

    public static Duration uptime()
    {
      return new Duration(System.DateTime.Now.Ticks * 100 - m_boot.m_ticks);
    }

    private Duration(long ticks)
    {
      this.m_ticks = ticks;
    }

  //////////////////////////////////////////////////////////////////////////
  // Identity
  //////////////////////////////////////////////////////////////////////////

    public override sealed Bool equals(Obj obj)
    {
      if (obj is Duration)
        return m_ticks == ((Duration)obj).m_ticks ? Bool.True : Bool.False;
      else
        return Bool.False;
    }

    public override sealed Int compare(Obj obj)
    {
      long that = ((Duration)obj).m_ticks;
      if (m_ticks < that) return Int.LT; return m_ticks  == that ? Int.EQ : Int.GT;
    }

    public override sealed int GetHashCode()
    {
      return (int)(m_ticks ^ (m_ticks >> 32));
    }

    public override sealed Int hash()
    {
      return Int.make(m_ticks);
    }

    public Int ticks()
    {
      return Int.make(m_ticks);
    }

    public override sealed Type type()
    {
      return Sys.DurationType;
    }

  //////////////////////////////////////////////////////////////////////////
  // Operators
  //////////////////////////////////////////////////////////////////////////

    public Duration negate()
    {
      return make(-m_ticks);
    }

    public Duration plus(Duration x)
    {
      return make(m_ticks + x.m_ticks);
    }

    public Duration minus(Duration x)
    {
      return make(m_ticks - x.m_ticks);
    }

    public Duration mult(Float x)
    {
      return make((long)(m_ticks * x.val));
    }

    public Duration div(Float x)
    {
      return make((long)(m_ticks / x.val));
    }

    public Duration floor(Duration accuracy)
    {
      if (m_ticks % accuracy.m_ticks == 0) return this;
      return make(m_ticks - (m_ticks % accuracy.m_ticks));
    }

  //////////////////////////////////////////////////////////////////////////
  // Conversion
  //////////////////////////////////////////////////////////////////////////

    public override Str toStr()
    {
      if (m_ticks == 0) return ZeroStr;
      return Str.make(str());
    }

    public void encode(ObjEncoder @out)
    {
      @out.w(str());
    }

    public string str()
    {
      // if clean millisecond boundary
      long ns = m_ticks;
      if (ns % nsPerMilli == 0)
      {
        if (ns % nsPerDay == 0) return ns/nsPerDay + "day";
        if (ns % nsPerHr  == 0) return ns/nsPerHr  + "hr";
        if (ns % nsPerMin == 0) return ns/nsPerMin + "min";
        if (ns % nsPerSec == 0) return ns/nsPerSec + "sec";
        return ns/nsPerMilli + "ms";
      }

      // return in nanoseconds
      return ns + "ns";
    }

    public Int toMillis()
    {
      return Int.make(m_ticks/nsPerMilli);
    }

    public Int toSec()
    {
      return Int.make(m_ticks/nsPerSec);
    }

    public Int toMin()
    {
      return Int.make(m_ticks/nsPerMin);
    }

    public Int toHour()
    {
      return Int.make(m_ticks/nsPerHr);
    }

    public Int toDay()
    {
      return Int.make(m_ticks/nsPerDay);
    }

  //////////////////////////////////////////////////////////////////////////
  // Locale
  //////////////////////////////////////////////////////////////////////////

    public Str toLocale()
    {
      long ticks = this.m_ticks;
      StringBuilder s;

      // less than 1000ns Xns
      if (ticks < 1000L) return Str.make(ticks + "ns");

      // less than 2ms X.XXXms
      if (ticks < 2*nsPerMilli)
      {
        s = new StringBuilder();
        long ms = ticks/nsPerMilli;
        long us = (ticks - ms*nsPerMilli)/1000L;
        s.Append(ms);
        s.Append('.');
        if (us < 100) s.Append('0');
        if (us < 10)  s.Append('0');
        s.Append(us);
        if (s[s.Length-1] == '0') s.Length = s.Length-1;
        if (s[s.Length-1] == '0') s.Length = s.Length-1;
        s.Append("ms");
        return Str.make(s.ToString());
      }

      // less than 2sec Xms
      if (ticks < 2L*nsPerSec)   return Str.make(ticks/nsPerMilli + "ms");

      // less than 2min Xsec
      if (ticks < 1L*nsPerMin)   return Str.make(ticks/nsPerSec+ "sec");

      // [Xdays] [Xhr] Xmin Xsec
      long days  = ticks/nsPerDay; ticks -= days*nsPerDay;
      long hr  = ticks/nsPerHr;    ticks -= hr*nsPerHr;
      long min = ticks/nsPerMin;   ticks -= min*nsPerMin;
      long sec = ticks/nsPerSec;

      s = new StringBuilder();
      if (days > 0) s.Append(days).Append(days == 1 ? "day " : "days ");
      if (days > 0 || hr > 0) s.Append(hr).Append("hr ");
      s.Append(min).Append("min ");
      s.Append(sec).Append("sec");
      return Str.make(s.ToString());
    }


  //////////////////////////////////////////////////////////////////////////
  // C#
  //////////////////////////////////////////////////////////////////////////

    public long sec()
    {
      return m_ticks/1000000000L;
    }

    public long millis()
    {
      return m_ticks/1000000L;
    }

  //////////////////////////////////////////////////////////////////////////
  // Fields
  //////////////////////////////////////////////////////////////////////////

    public static readonly Duration Zero = new Duration(0);
    public static readonly Str ZeroStr = Str.make("0ns");
    public const long nsPerDay   = 86400000000000L;
    public const long nsPerHr    = 3600000000000L;
    public const long nsPerMin   = 60000000000L;
    public const long nsPerSec   = 1000000000L;
    public const long nsPerMilli = 1000000L;
    static readonly Duration m_boot = now();

    public readonly long m_ticks;

  }
}