// Constant value stream v1.0

#ifndef ConstValueStream_IMP
#define ConstValueStream_IMP

class ConstValueStream : public ABaseStream
{
   double _value;
public:
   ConstValueStream(string symbol, const ENUM_TIMEFRAMES timeframe, double value)
      :ABaseStream(symbol, timeframe)
   {
      _value = value;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = _value;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = _value;
      }
      return true;
   }
};

#endif