#include <AStream.mqh>

// RSI stream v1.1

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSIStream : public AStream
{
   int _indi;
public:
   RSIStream(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_APPLIED_PRICE price)
      :AStream(symbol, timeframe)
   {
      _indi = iRSI(symbol, timeframe, period, price);
   }

   ~RSIStream()
   {
      IndicatorRelease(_indi);
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return CopyBuffer(_indi, 0, period, count, val) == count;
   }
};

#endif