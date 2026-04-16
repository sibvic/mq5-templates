// Session bar helpers (Pine/cTrader-style "regular" session boundaries on chart TF vs D1)
// v1.0
//
// Mirrors the idea of comparing D1 session candles from platform data:
// - IsFirstBarRegular: D1 "day" at this bar differs from the prior bar (new trading day started).
// - IsLastBarRegular: this bar ends exactly when the D1 session bar ends.

class Session
{
   static int OlderBarIndex(const int pos, const bool asSeries)
   {
      if (asSeries)
      {
         return pos + 1;
      }
      return pos - 1;
   }

   static datetime DailyBarEnd(const int d1Shift, const datetime dayOpen)
   {
      if (d1Shift > 0)
      {
         return iTime(_Symbol, PERIOD_D1, d1Shift - 1);
      }
      return dayOpen + (datetime)PeriodSeconds(PERIOD_D1);
   }

public:
   static bool IsFirstBarRegular(const int pos, const datetime &time[])
   {
      const int n = ArraySize(time);
      if (pos < 0 || n < 2)
      {
         return false;
      }
      const bool asSeries = ArrayGetAsSeries(time);
      const int idxOlder = OlderBarIndex(pos, asSeries);
      if (idxOlder < 0 || idxOlder >= n)
      {
         return false;
      }
      const datetime tCur = time[pos];
      const datetime tOld = time[idxOlder];
      const int s0 = iBarShift(_Symbol, PERIOD_D1, tCur);
      const int s1 = iBarShift(_Symbol, PERIOD_D1, tOld);
      if (s0 < 0 || s1 < 0)
      {
         return false;
      }
      const datetime d0 = iTime(_Symbol, PERIOD_D1, s0);
      const datetime d1 = iTime(_Symbol, PERIOD_D1, s1);
      return (d0 != d1);
   }

   static bool IsLastBarRegular(const int pos, const datetime &time[])
   {
      const int n = ArraySize(time);
      if (pos < 0 || pos >= n)
      {
         return false;
      }
      const datetime t = time[pos];
      const int dShift = iBarShift(_Symbol, PERIOD_D1, t);
      if (dShift < 0)
      {
         return false;
      }
      const datetime dayOpen = iTime(_Symbol, PERIOD_D1, dShift);
      const datetime dayEnd = DailyBarEnd(dShift, dayOpen);
      const datetime barEnd = t + (datetime)PeriodSeconds(_Period);
      return (dayEnd == barEnd);
   }
};
