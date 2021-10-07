#include <Conditions/ACondition.mqh>
#include <TradesIterator.mqh>
#include <ClosedTradesIterator.mqh>

// v1.0

class MinDistanceSinceLastTradeCondition : public ACondition
{
   int _minBars;
   int _magic_number;
public:
   MinDistanceSinceLastTradeCondition(const string symbol, ENUM_TIMEFRAMES timeframe, int minBars, int magic_number)
      :ACondition(symbol, timeframe)
   {
      _minBars = minBars;
      _magic_number = magic_number;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "Min disatance since last trade: " + (IsPass(period, date) ? "true" : "false");
   }

   bool IsPass(const int period, const datetime date)
   {
      datetime orderDate = 0;

      TradesIterator it;
      it.WhenMagicNumber(_magic_number);
      while (it.Next())
      {
         if (orderDate < it.GetOpenTime())
         {
            orderDate = it.GetOpenTime();
         }
      }
      ClosedTradesIterator it2;
      it2.WhenMagicNumber(_magic_number);
      it2.WhenEntry(DEAL_ENTRY_IN);
      while (it2.Next())
      {
         if (orderDate < it2.GetTime())
         {
            orderDate = it2.GetTime();
         }
      }
      if (orderDate == 0)
         return true;
      int index = iBarShift(_symbol, _timeframe, orderDate);
      return _minBars <= index;
   }
};
