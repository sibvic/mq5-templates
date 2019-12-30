// Trend value cell v1.0

#ifndef TrendValueCell_IMP
#define TrendValueCell_IMP

#include <../conditions/ICondition.mq5>

#ifndef ENTER_BUY_SIGNAL
#define ENTER_BUY_SIGNAL 1
#endif
#ifndef ENTER_SELL_SIGNAL
#define ENTER_SELL_SIGNAL -1
#endif

class TrendValueCell : public ICell
{
   string _id; int _x; int _y; string _symbol; ENUM_TIMEFRAMES _timeframe; datetime _lastDatetime;
   ICondition* _upCondition;
   ICondition* _downCondition;
   datetime _lastSignalDate;
public:
   TrendValueCell(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   { 
      _id = id; 
      _x = x; 
      _y = y; 
      _symbol = symbol; 
      _timeframe = timeframe; 
      _upCondition = CreateUpCondition(_symbol, _timeframe);
      _downCondition = CreateDownCondition(_symbol, _timeframe);
   }

   ~TrendValueCell()
   {
      delete _upCondition;
      delete _downCondition;
   }

   virtual void Draw()
   { 
      int direction = GetDirection(); 
      ObjectMakeLabel(_id, _x, _y, GetDirectionSymbol(direction), GetDirectionColor(direction), 1, 0, "Arial", font_size); 
      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (currentTime != _lastSignalDate)
      {
         switch (direction)
         {
            case ENTER_BUY_SIGNAL:
               _lastSignalDate = currentTime;
               break;
            case ENTER_SELL_SIGNAL:
               _lastSignalDate = currentTime;
               break;
         }
      }
   }

private:
   int GetDirection()
   {
      datetime date = iTime(_symbol, _timeframe, 0);
      if (_upCondition.IsPass(0, date))
         return ENTER_BUY_SIGNAL;
      if (_downCondition.IsPass(0, date))
         return ENTER_SELL_SIGNAL;
      return 0;
   }

   color GetDirectionColor(const int direction) { if (direction >= 1) { return Up_Color; } else if (direction <= -1) { return Dn_Color; } return Neutral_Color; }
   string GetDirectionSymbol(const int direction)
   {
      if (direction == ENTER_BUY_SIGNAL)
         return "BUY";
      else if (direction == ENTER_SELL_SIGNAL)
         return "SELL";
      return "-";
   }
};
#endif