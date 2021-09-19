#include <ACondition.mqh>
// Bar condnitions v1.0

#ifndef BarConditions_IMP
#define BarConditions_IMP

class MinBodySizeCondition : public ACondition
{
   double _minSize;
public:
   MinBodySizeCondition(const string symbol, ENUM_TIMEFRAMES timeframe, double minSize)
      :ACondition(symbol, timeframe)
   {
      _minSize = minSize;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double body = MathAbs(iOpen(_symbol, _timeframe, period) - iClose(_symbol, _timeframe, period));
      double candle = iHigh(_symbol, _timeframe, period) - iLow(_symbol, _timeframe, period);
      return candle == 0 ? (_minSize == 0) : (body / candle >= _minSize / 100.0);
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      return "Min body size: " + (result ? "true" : "false");
   }
};
#endif