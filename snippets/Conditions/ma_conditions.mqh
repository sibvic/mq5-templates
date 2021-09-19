// MA Conditions v1.0

#ifndef MAConditions_IMP
#define MAConditions_IMP

#include <ACondition.mqh>
#include <enums/TwoStreamsConditionType.mqh>

class MAMACondition : public ACondition
{
   int _indi1;
   int _indi2;
   TwoStreamsConditionType _condition;
public:
   MAMACondition(const string symbol, ENUM_TIMEFRAMES timeframe, TwoStreamsConditionType condition
      , ENUM_MA_METHOD method1, int period1, ENUM_MA_METHOD method2, int period2)
      :ACondition(symbol, timeframe)
   {
      _condition = condition;
      _indi1 = iMA(symbol, timeframe, period1, 0, method1, PRICE_CLOSE);
      _indi2 = iMA(symbol, timeframe, period2, 0, method2, PRICE_CLOSE);
   }
   ~MAMACondition()
   {
      IndicatorRelease(_indi1);
      IndicatorRelease(_indi2);
   }

   bool IsPass(const int period, const datetime date)
   {
      double values1[2];
      if (CopyBuffer(_indi1, 0, period, 2, values1) != 2)
      {
         return false;
      }
      double values2[2];
      if (CopyBuffer(_indi2, 0, period, 2, values2) != 2)
      {
         return false;
      }
      switch (_condition)
      {
         case FirstAboveSecond:
            return values1[0] > values2[0];
         case FirstBelowSecond:
            return values1[0] < values2[0];
         case FirstCrossOverSecond:
            return values1[0] >= values2[0] && values1[1] < values2[1];
         case FirstCrossUnderSecond:
            return values1[0] <= values2[0] && values1[1] > values2[1];
      }
      return false;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      switch (_condition)
      {
         case FirstAboveSecond:
            return "MA > MA: " + (result ? "true" : "false");
         case FirstBelowSecond:
            return "MA < MA: " + (result ? "true" : "false");
         case FirstCrossOverSecond:
            return "MA co MA: " + (result ? "true" : "false");
         case FirstCrossUnderSecond:
            return "MA cu MA: " + (result ? "true" : "false");
      }
      return "MA-MA: " + (result ? "true" : "false");
   }
};

#endif