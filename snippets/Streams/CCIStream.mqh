// CCI stream v1.0

#ifndef CCIStream_IMP
#define CCIStream_IMP

class CCIStream : public ABaseStream
{
   int _indi;
public:
   CCIStream(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_APPLIED_PRICE price)
      :ABaseStream(symbol, timeframe)
   {
      _indi = iCCI(symbol, timeframe, period, price);
   }

   ~CCIStream()
   {
      IndicatorRelease(_indi);
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return CopyBuffer(_indi, 0, period, count, val) == count;
   }
};

#endif