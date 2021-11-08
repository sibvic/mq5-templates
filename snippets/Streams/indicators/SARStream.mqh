#include <Streams/AStream.mqh>

class SARStream : public AStream
{
   int _indi;
public:
   SARStream(string symbol, ENUM_TIMEFRAMES timeframe, double step, double max)
      :AStream(symbol, timeframe)
   {
      _indi = iSAR(symbol, timeframe, step, max);
   }

   ~SARStream()
   {
      IndicatorRelease(_indi);
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return CopyBuffer(_indi, 0, period, count, val) != count;
   }
};