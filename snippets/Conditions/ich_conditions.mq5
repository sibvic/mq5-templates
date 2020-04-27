// Ichimoku conditions v1.0

#include <ACondition.mq5>

#ifndef ICH_Conditions_IMP
#define ICH_Conditions_IMP

string GetIchimokuStreamName(int streamIndex)
{
   switch (streamIndex)
   {
      case TENKANSEN_LINE:
         return "Tenkan-sen";
      case KIJUNSEN_LINE:
         return "Kijun-sen";
      case SENKOUSPANA_LINE:
         return "Senkou Span A";
      case SENKOUSPANB_LINE:
         return "Senkou Span B";
      case CHIKOUSPAN_LINE:
         return "Chikou Span";
   }
   return "";
} 

class IchimokuStreamsCondition : public ACondition
{
   int _indi;
   int _firstStreamIndex;
   int _firstStreamPeriodShift;
   int _secondStreamIndex;
   int _secondStreamPeriodShift;
   TwoStreamsConditionType _condition;
public:
   IchimokuStreamsCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      int firstStreamIndex, 
      int secondStreamIndex,
      int firstStreamPeriodShift = 0,
      int secondStreamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _condition = condition;
      _firstStreamPeriodShift = firstStreamPeriodShift;
      _secondStreamPeriodShift = secondStreamPeriodShift;
      _firstStreamIndex = firstStreamIndex;
      _secondStreamIndex = secondStreamIndex;
      _indi = iIchimoku(symbol, timeframe, tenkanSen, kijunSen, senkoiSpanB);
   }

   ~IchimokuStreamsCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      bool result = IsPass(period, date);
      string sign = "";
      switch (_condition)
      {
         case FirstAboveSecond:
            sign = ">";
            break;
         case FirstBelowSecond:
            sign = "<";
            break;
         case FirstCrossOverSecond:
            sign = "co";
            break;
         case FirstCrossUnderSecond:
            sign = "cu";
            break;
      }
      return GetIchimokuStreamName(_firstStreamIndex) + " " + sign + " " + GetIchimokuStreamName(_secondStreamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double values1[2];
      if (CopyBuffer(_indi, _firstStreamIndex, period + _firstStreamPeriodShift, 2, values1) != 2)
      {
         return false;
      }
      double values2[2];
      if (CopyBuffer(_indi, _secondStreamIndex, period + _secondStreamPeriodShift, 2, values2) != 2)
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
};

#endif