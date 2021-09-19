#include <ABaseStream.mqh>

#ifndef TrueRangeStream_IMP
#define TrueRangeStream_IMP

class TrueRangeStream : public ABaseStream
{
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double hl = MathAbs(iHigh(_symbol, _timeframe, size - 1 - period - i) - iLow(_symbol, _timeframe, size - 1 - period - i));
         double hc = MathAbs(iHigh(_symbol, _timeframe, size - 1 - period - i) - iClose(_symbol, _timeframe, size - 1 - period - i - 1));
         double lc = MathAbs(iLow(_symbol, _timeframe, size - 1 - period - i) - iClose(_symbol, _timeframe, size - 1 - period - i - 1));

         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
};
#endif