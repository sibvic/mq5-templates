
class LowestPriceStream : public AStream
{
   int _periods;
public:
   LowestPriceStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe, int periods)
      :AStream(symbolInfo, timeframe)
   {
      _periods = periods;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbolInfo.GetSymbol();
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iLowest(symbol, _timeframe, MODE_LOW, _periods, period);
      }
      return true;
   }
};

class HighestPriceStream : public AStream
{
   int _periods;
public:
   HighestPriceStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe, int periods)
      :AStream(symbolInfo, timeframe)
   {
      _periods = periods;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbolInfo.GetSymbol();
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iHighest(symbol, _timeframe, MODE_HIGH, _periods, period);
      }
      return true;
   }
};