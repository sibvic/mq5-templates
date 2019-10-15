// Trailing action v1.0

#include <AAction.mq5>
#include <../Trade.mq5>
#include <../TradingCommands.mq5>
#include <../InstrumentInfo.mq5>

#ifndef TrailingAction_IMP
#define TrailingAction_IMP

class TrailingPipsAction : public AAction
{
   ITrade* _trade;
   InstrumentInfo* _instrument;
   double _lastClose;
   double _distance;
public:
   TrailingPipsAction(ITrade* trade, double distance)
   {
      _distance = distance;
      _trade = trade;
      _trade.AddRef();
      _lastClose = 0;
      _instrument = NULL;
   }

   ~TrailingPipsAction()
   {
      _trade.Release();
      delete _instrument;
   }

   virtual bool DoAction()
   {
      if (!_trade.Select())
         return true;
      string symbol = PositionGetString(POSITION_SYMBOL);
      double closePrice = iClose(symbol, PERIOD_M1, 0);
      if (_lastClose == 0)
      {
         _lastClose = closePrice;
         _instrument = new InstrumentInfo(symbol);
      }

      double stopLoss = PositionGetDouble(POSITION_SL);
      double stopDistance = MathAbs(closePrice - stopLoss) / _instrument.GetPipSize();
      if (stopDistance <= _distance)
         return false;

      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ulong ticketId = PositionGetInteger(POSITION_TICKET);
      string error;
      if (positionType == POSITION_TYPE_BUY)
      {
         TradingCommands::MoveSL(ticketId, closePrice - _distance * _instrument.GetPipSize(), error);
      }
      else
      {
         TradingCommands::MoveSL(ticketId, closePrice + _distance * _instrument.GetPipSize(), error);
      }
      _lastClose = closePrice;
      
      return false;
   }
};
#endif