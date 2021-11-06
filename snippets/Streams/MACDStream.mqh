// MACD stream v1.1

#ifndef MACDStream_IMP
#define MACDStream_IMP

class MACDStream : public AStream
{
   int _indi;
public:
   MACDStream(string symbol, ENUM_TIMEFRAMES timeframe, int fast_ema_period, int slow_ema_period, int signal_period, ENUM_APPLIED_PRICE price)
      :AStream(symbol, timeframe)
   {
      _indi = iMACD(symbol, timeframe, fast_ema_period, slow_ema_period, signal_period, PRICE_CLOSE);
   }

   ~MACDStream()
   {
      IndicatorRelease(_indi);
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return CopyBuffer(_indi, 0, period, count, val) == count;
   }
};

#endif