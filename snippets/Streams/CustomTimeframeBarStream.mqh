// Custom timeframe bar stream v1.0

#include <ACustomBarStream.mqh>

#ifndef CustomTimeframeBarStream_IMP
#define CustomTimeframeBarStream_IMP

class CustomTimeframeBarStream : public ACustomBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
public:
   CustomTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int timeframeMult)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, _timeframe) - 1;
      if (_size > 0)
         start = iBarShift(_symbol, _timeframe, _dates[_size - 1]);

      for (int i = start; i >= 0; --i)
      {
         datetime barStart = NormilizeDate(iTime(_symbol, _timeframe, i));
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, _timeframe, i);
            _high[_size - 1] = iHigh(_symbol, _timeframe, i);
            _low[_size - 1] = iLow(_symbol, _timeframe, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, _timeframe, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, _timeframe, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, _timeframe, i);
      }
   }
private:
   datetime NormilizeDate(datetime dt)
   {
      switch (_timeframe)
      {
         case PERIOD_MN1:
         {
            MqlDateTime date;
            TimeToStruct(dt, date);
            int months = (date.year - 1970) * 12 + date.mon - 1;
            int targetMonths = (months / _timeframeMult) * _timeframeMult;
            int targetYears = targetMonths / 12;
            date.year = 1970 + targetYears;
            date.mon = targetMonths - targetYears * 12 + 1;
            date.day = 1;
            date.hour = 0;
            date.min = 0;
            date.sec = 0;
            return StructToTime(date);
         }
      }
      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      return (dt / periodLength) * periodLength;
   }
};
#endif