// WPR stream v1.0

#ifndef WPRStream_IMP
#define WPRStream_IMP

class WPRStream : public ABaseStream
{
   int _indi;
public:
   WPRStream(string symbol, ENUM_TIMEFRAMES timeframe, int period)
      :ABaseStream(symbol, timeframe)
   {
      _indi = iWPR(symbol, timeframe, period);
   }

   ~WPRStream()
   {
      IndicatorRelease(_indi);
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return CopyBuffer(_indi, 0, period, count, val) == count;
   }
};

#endif