#include <ACondition.mqh>
#include <enums/TwoStreamsConditionType.mqh>

// Ichimoku conditions v1.1

#ifndef ICH_Conditions_IMP
#define ICH_Conditions_IMP

#define MODE_TENKANSEN 0
#define MODE_KIJUNSEN 1
#define MODE_SENKOUSPANA 2
#define MODE_SENKOUSPANB 3
#define MODE_CHIKOUSPAN 4

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

string GetPriceName(ENUM_APPLIED_PRICE price)
{
   switch (price)
   {
      case PRICE_CLOSE:
         return "Close";
      case PRICE_OPEN:
         return "Open";
      case PRICE_HIGH:
         return "High";
      case PRICE_LOW:
         return "Low";
      case PRICE_MEDIAN:
         return "Median";
      case PRICE_TYPICAL:
         return "Typical";
      case PRICE_WEIGHTED:
         return "Weighted";
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

class PriceIchimokuStreamCondition : public ACondition
{
   int _indi;
   int _streamIndex;
   int _streamPeriodShift;
   ENUM_APPLIED_PRICE _price;
   int _pricePeriodShift;
   TwoStreamsConditionType _condition;
public:
   PriceIchimokuStreamCondition(const string symbol, 
      ENUM_TIMEFRAMES timeframe, 
      TwoStreamsConditionType condition,
      int tenkanSen, 
      int kijunSen, 
      int senkoiSpanB, 
      ENUM_APPLIED_PRICE price,
      int streamIndex, 
      int pricePeriodShift = 0,
      int streamPeriodShift = 0)
      :ACondition(symbol, timeframe)
   {
      _condition = condition;
      _streamPeriodShift = streamPeriodShift;
      _pricePeriodShift = pricePeriodShift;
      _streamIndex = streamIndex;
      _price = price;
      _indi = iIchimoku(symbol, timeframe, tenkanSen, kijunSen, senkoiSpanB);
   }

   ~PriceIchimokuStreamCondition()
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
      return GetPriceName(_price) + " " + sign + " " + GetIchimokuStreamName(_streamIndex) + ": " + (IsPass(period, date) ? "true" : "false");
   }
   
   bool IsPass(const int period, const datetime date)
   {
      double values2[2];
      if (CopyBuffer(_indi, _streamIndex, period + _streamPeriodShift, 2, values2) != 2)
      {
         return false;
      }
      double price0 = GetPrice(period + _pricePeriodShift);
      double price1 = GetPrice(period + _pricePeriodShift + 1);
      switch (_condition)
      {
         case FirstAboveSecond:
            return price0 > values2[0];
         case FirstBelowSecond:
            return price0 < values2[0];
         case FirstCrossOverSecond:
            return price0 >= values2[0] && price1 < values2[1];
         case FirstCrossUnderSecond:
            return price0 <= values2[0] && price1 > values2[1];
      }
      return false;
   }
private:
   double GetPrice(int period)
   {
      switch (_price)
      {
         case PRICE_CLOSE:
            return iClose(_symbol, _timeframe, period);
         case PRICE_OPEN:
            return iOpen(_symbol, _timeframe, period);
         case PRICE_HIGH:
            return iHigh(_symbol, _timeframe, period);
         case PRICE_LOW:
            return iLow(_symbol, _timeframe, period);
         case PRICE_MEDIAN:
            return (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
         case PRICE_TYPICAL:
            return (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
         case PRICE_WEIGHTED:
            return (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
      }
      return 0;
   }
};

#endif