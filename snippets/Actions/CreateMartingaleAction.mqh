#include <../Conditions/ProfitInRangeCondition.mq5>
#include <../MoneyManagement/ILotsProvider.mq5>
#include <../Logic/ActionOnConditionLogic.mq5>
#include <../Trade.mq5>
#include <AOrderAction.mq5>
// v1.1

class CustomLotsProvider : public ILotsProvider
{
   double _lots;
public:
   void SetLots(double lots)
   {
      _lots = lots;
   }

   virtual double GetValue(int period, double entryPrice)
   {
      return _lots;
   }
};

class CreateMartingaleAction : public AOrderAction
{
   ActionOnConditionLogic* _actions;
   double _partingaleStepPips;
   IAction* _longAction;
   IAction* _shortAction;
   int _maxLongPositions;
   int _maxShortPositions;
   double _lotsValue;
   MartingaleLotSizingType _lotsSizingType;
   CustomLotsProvider* _lots;
public:
   CreateMartingaleAction(CustomLotsProvider* lots, MartingaleLotSizingType lotsSizingType, double lotsValue, 
      double partingaleStepPips, IAction* longAction, IAction* shortAction, 
      int maxLongPositions, int maxShortPositions, ActionOnConditionLogic* actions)
   {
      _lots = lots;
      _lotsValue = lotsValue;
      _lotsSizingType = lotsSizingType;
      _maxLongPositions = maxLongPositions;
      _maxShortPositions = maxShortPositions;
      _longAction = longAction;
      _longAction.AddRef();
      _shortAction = shortAction;
      _shortAction.AddRef();
      _actions = actions;
      _partingaleStepPips = partingaleStepPips;
   }

   ~CreateMartingaleAction()
   {
      _longAction.Release();
      _shortAction.Release();
   }

   void RestoreActions(string symbol, int magicNumber)
   {
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (IsLimitHit())
      {
         return false;
      }
      ITrade* order = new TradeByTicketId(_currentTicket);
      if (!order.Select())
      {
         order.Release();
         return false;
      }
      InstrumentInfo instrument(PositionGetString(POSITION_SYMBOL));
      switch (_lotsSizingType)
      {
         case MartingaleLotSizingNo:
            _lots.SetLots(PositionGetDouble(POSITION_VOLUME));
            break;
         case MartingaleLotSizingMultiplicator:
            _lots.SetLots(instrument.NormalizeLots(PositionGetDouble(POSITION_VOLUME) * _lotsValue));
            break;
         case MartingaleLotSizingAdd:
            _lots.SetLots(instrument.NormalizeLots(PositionGetDouble(POSITION_VOLUME) + _lotsValue));
            break;
      }
      ProfitInRangeCondition* condition = new ProfitInRangeCondition(order, -100000, -_partingaleStepPips);
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         _actions.AddActionOnCondition(_longAction, condition);
      }
      else
      {
         _actions.AddActionOnCondition(_shortAction, condition);
      }
      condition.Release();
      order.Release();

      return true;
   }
private:
   bool IsLimitHit()
   {
      TradesIterator sideSpecificIterator();
      sideSpecificIterator.WhenMagicNumber(magic_number);
      sideSpecificIterator.WhenSymbol(PositionGetString(POSITION_SYMBOL));
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         sideSpecificIterator.WhenSide(BuySide);
         int side_positions = sideSpecificIterator.Count();
         return side_positions >= _maxLongPositions;
      }
      sideSpecificIterator.WhenSide(SellSide);
      int side_positions = sideSpecificIterator.Count();
      return side_positions >= _maxShortPositions;
   }
};