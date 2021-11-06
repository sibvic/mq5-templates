// Stochastic stream v1.1

#ifndef StochStream_IMP
#define StochStream_IMP

class StochStream : public AStream
{
   int _indi;
public:
   StochStream(string symbol, ENUM_TIMEFRAMES timeframe, int stoch_k, int stoch_d, int stoch_slowing, ENUM_MA_METHOD method, ENUM_STO_PRICE price)
      :AStream(symbol, timeframe)
   {
      _indi = iStochastic(symbol, timeframe, stoch_k, stoch_d, stoch_slowing, method, price);
   }

   ~StochStream()
   {
      IndicatorRelease(_indi);
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return CopyBuffer(_indi, 0, period, count, val) == count;
   }
};

#endif