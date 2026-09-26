#include <Streams/Abstract/ADateTimeStream.mqh>
#include <Conditions/NoCondition.mqh>
#include <Conditions/TimeSessionCondition.mqh>

// Date/time stream v1.2

#ifndef DateTimeStream_IMP
#define DateTimeStream_IMP

class DateTimeStream : public ADateTimeStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   ENUM_TIMEFRAMES _chartTimeframe;
   bool _extended;
   ICondition* _timeFilter;
public:
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _extended = false;
      _timeFilter = new NoCondition();
      _symbol = symbol;
      _timeframe = timeframe;
   }
   DateTimeStream(const string symbol, string resolution)
   {
      _extended = false;
      _timeFilter = new NoCondition();
      _symbol = symbol;
      _timeframe = GetTimeframe(resolution);
   }
   DateTimeStream(const string symbol, ENUM_TIMEFRAMES timeframe, string targetTimeframe, string session, string timezone)
   {
      _extended = true;
      _timeFilter = new TimeSessionCondition(session);
      _symbol = symbol;
      _chartTimeframe = timeframe;
      _timeframe = GetTimeframe(targetTimeframe);
   }
   ~DateTimeStream()
   {
      if (_timeFilter != NULL)
      {
         _timeFilter.Release();
      }
   }

   bool GetSeriesValues(const int period, const int count, datetime &val[])
   {
      if (_extended)
      {
         return GetValues(Size() - period - 1, count, val);
      }
      int size = Size();
      if (period >= size - count)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iTime(_symbol, _timeframe, period + i);
      }
      return true;
   }
   bool GetValues(const int period, const int count, datetime &val[])
   {
      int size = _extended ? iBars(_symbol, _chartTimeframe) : iBars(_Symbol, _Period);
      if (!_extended)
      {
         int oldPos = size - period - 1;
         if (oldPos + count - 1 >= size)
         {
            return false;
         }
         for (int i = 0; i < count; ++i)
         {
            datetime barTime = iTime(_Symbol, _Period, oldPos + i);
            int position = iBarShift(_symbol, _timeframe, barTime);
            if (position == -1)
            {
               return false;
            }
            val[i] = iTime(_symbol, _timeframe, position);
         }
         return true;
      }

      for (int i = 0; i < count; ++i)
      {
         int oldPos = size - period - 1 + i;
         if (oldPos < 0 || oldPos >= size)
         {
            val[i] = NULL;
            continue;
         }
         datetime barTime = iTime(_symbol, _chartTimeframe, oldPos);
         int position = iBarShift(_symbol, _timeframe, barTime);
         if (position < 0)
         {
            val[i] = NULL;
            continue;
         }
         datetime t = iTime(_symbol, _timeframe, position);
         if (!_timeFilter.IsPass(0, t))
         {
            val[i] = NULL;
            continue;
         }
         val[i] = t;
      }
      return true;
   }
   
   int Size()
   {
      if (_extended)
      {
         return iBars(_symbol, _chartTimeframe);
      }
      return iBars(_Symbol, _Period);
   }
private:
   ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "2") { return PERIOD_M2; }
      if (resolution == "3") { return PERIOD_M3; }
      if (resolution == "4") { return PERIOD_M4; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "6") { return PERIOD_M6; }
      if (resolution == "10") { return PERIOD_M10; }
      if (resolution == "12") { return PERIOD_M12; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "20") { return PERIOD_M20; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60") { return PERIOD_H1; }
      if (resolution == "120") { return PERIOD_H2; }
      if (resolution == "180") { return PERIOD_H3; }
      if (resolution == "240") { return PERIOD_H4; }
      if (resolution == "360") { return PERIOD_H6; }
      if (resolution == "480") { return PERIOD_H8; }
      if (resolution == "720") { return PERIOD_H12; }
      if (resolution == "D") { return PERIOD_D1; }
      if (resolution == "W") { return PERIOD_W1; }
      if (resolution == "M") { return PERIOD_MN1; }
      return PERIOD_CURRENT;
   }
};
#endif
