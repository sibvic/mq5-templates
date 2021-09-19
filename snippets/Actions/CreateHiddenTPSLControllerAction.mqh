// Create hidden take profit/stop loss controller action v1.0

#include <AAction.mqh>
#include <../Trade.mqh>
#include <../Conditions/ProfitInRangeCondition.mqh>
#include <../Conditions/NotCondition.mqh>
#include <../Logic/ActionOnConditionLogic.mqh>
#include <CloseTradeAction.mqh>

#ifndef CreateHiddenTPSLControllerAction_IMP
#define CreateHiddenTPSLControllerAction_IMP

class CreateHiddenTPSLControllerAction : public AAction
{
   ActionOnConditionLogic* _actions;
public:
   CreateHiddenTPSLControllerAction(ActionOnConditionLogic* actions)
   {
      _actions = actions;
   }

   virtual bool DoAction()
   {
      TradeByTicketId* trade = new TradeByTicketId(PositionGetInteger(POSITION_TICKET));
      ICondition* inRangeCondition = new ProfitInRangeCondition(trade, -stop_loss, take_profit);
      ICondition* notInRangeCondition = new NotCondition(inRangeCondition);
      inRangeCondition.Release();
      CloseTradeAction* closeTrade = new CloseTradeAction(trade);
      _actions.AddActionOnCondition(closeTrade, notInRangeCondition);
      closeTrade.Release();
      notInRangeCondition.Release();
      trade.Release();
      return true;
   }
};


#endif