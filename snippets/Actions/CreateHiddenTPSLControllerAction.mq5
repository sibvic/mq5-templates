// Create hidden take profit/stop loss controller action v1.0

#include <AAction.mq5>
#include <../Trade.mq5>
#include <../Conditions/ProfitInRangeCondition.mq5>
#include <../Conditions/NotCondition.mq5>
#include <../Logic/ActionOnConditionLogic.mq5>
#include <CloseTradeAction.mq5>

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