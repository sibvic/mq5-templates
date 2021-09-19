#include <conditions/ProfitInRangeCondition.mqh>
#include <Actions/TrailingPipsAction.mqh>
#include <Logic/ActionOnConditionLogic.mqh>
#include <Actions/AOrderAction.mqh>

// Create trailing action v1.1

#ifndef CreateTrailingAction_IMP
#define CreateTrailingAction_IMP

// Automatically saves data about trailing as globals.
// You need to call RestoreActions() after creation of this object to restore tracking of old trades.
class CreateTrailingAction : public AOrderAction
{
   double _start;
   double _step;
   bool _startInPercent;
   ActionOnConditionLogic* _actions;
public:
   CreateTrailingAction(double start, bool startInPercent, double step, ActionOnConditionLogic* actions)
   {
      _startInPercent = startInPercent;
      _start = start;
      _step = step;
      _actions = actions;
   }

   void RestoreActions(string symbol, int magicNumber)
   {
      TradesIterator trades;
      trades.WhenSymbol(symbol);
      trades.WhenMagicNumber(magicNumber);
      while (trades.Next())
      {
         ulong ticketId = trades.GetTicket();
         string ticketIdStr = IntegerToString(ticketId);
         double step = GlobalVariableGet("tr_" + ticketIdStr + "_stp");
         if (step == 0)
         {
            continue;
         }
         double start = GlobalVariableGet("tr_" + ticketIdStr + "_strt");
         if (start == 0)
         {
            continue;
         }
         double distance = GlobalVariableGet("tr_" + ticketIdStr + "_d");
         if (distance == 0)
         {
            continue;
         }
         TradeByTicketId* order = new TradeByTicketId(ticketId);
         Create(order, distance, start);
      }
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      TradeByTicketId* order = new TradeByTicketId(_currentTicket);
      if (!order.Select() || PositionGetDouble(POSITION_SL) == 0)
      {
         order.Release();
         return false;
      }
      
      string symbol = PositionGetString(POSITION_SYMBOL);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      double pipSize = point * mult;
      
      double distance = MathAbs(PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_SL)) / pipSize;
      double start = _startInPercent ? distance * _start / 100.0 : _start;

      string ticketIdStr = IntegerToString(_currentTicket);
      GlobalVariableSet("tr_" + ticketIdStr + "_stp", _step);
      GlobalVariableSet("tr_" + ticketIdStr + "_strt", start);
      GlobalVariableSet("tr_" + ticketIdStr + "_d", distance);
      
      Create(order, distance, start);

      return true;
   }

private:
   void Create(ITrade* trade, double distance, double start)
   {
      TrailingPipsAction* action = new TrailingPipsAction(trade, distance, _step);
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(trade, start, 100000);
      _actions.AddActionOnCondition(action, condition);
      condition.Release();
      action.Release();
      trade.Release();
   }
};

#endif