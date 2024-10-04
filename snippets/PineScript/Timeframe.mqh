// PineScript timeframe.* functions
// v1.0

class Timeframe
{
public:
   static string Period()
   {
      if (_Period == PERIOD_M1) { return "1"; }
      if (_Period == PERIOD_M5) { return "5"; }
      if (_Period == PERIOD_M15) { return "15"; }
      if (_Period == PERIOD_M30) { return "30"; }
      if (_Period == PERIOD_H1) { return "60"; }
      if (_Period == PERIOD_H4) { return "240"; }
      if (_Period == PERIOD_D1) { return "D"; }
      if (_Period == PERIOD_W1) { return "W"; }
      if (_Period == PERIOD_MN1) { return "M"; }
      return "1";
   }
   
   static bool Change(string timeframe, int pos)
   {
      int bars = iBars(_Symbol, _Period);
      if (bars <= pos + 1)
      {
         return true;
      }
      datetime currentBar = iTime(_Symbol, _Period, pos);
      datetime prevBar = iTime(_Symbol, _Period, pos + 1);
      ENUM_TIMEFRAMES tf = GetTimeframe(timeframe);
      return iBarShift(_Symbol, tf, currentBar) != iBarShift(_Symbol, tf, prevBar);
   }
   
   static bool IsDWM()
   {
      switch (_Period)
      {
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return true;
      }
      return false;
   }
   
   static ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60") { return PERIOD_H1; }
      if (resolution == "240") { return PERIOD_H4; }
      if (resolution == "D") { return PERIOD_D1; }
      if (resolution == "W") { return PERIOD_W1; }
      if (resolution == "M") { return PERIOD_MN1; }
      return PERIOD_CURRENT;
   }
};