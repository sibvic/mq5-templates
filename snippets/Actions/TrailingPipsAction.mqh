#include <Actions/AAction.mqh>
#include <Trade.mqh>
#include <TradingCommands.mqh>
#include <InstrumentInfo.mqh>

// Trailing action v2.1

#ifndef TrailingAction_IMP
#define TrailingAction_IMP

class TrailingPipsAction : public AAction
{
   ITrade* _trade;
   InstrumentInfo* _instrument;
   double _lastClose;
   double _distancePips;
   double _stepPips;
   double _distance;
   double _step;
public:
   TrailingPipsAction(ITrade* trade, double distancePips, double stepPips)
   {
      _distancePips = distancePips;
      _stepPips = stepPips;
      _distance = 0;
      _step = 0;
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

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_trade.Select())
         return true;
      string symbol = PositionGetString(POSITION_SYMBOL);
      double closePrice = iClose(symbol, PERIOD_M1, 0);
      if (_lastClose == 0)
      {
         _lastClose = closePrice;
         _instrument = new InstrumentInfo(symbol);
         _distance = _distancePips * _instrument.GetPipSize();
         _step = _stepPips * _instrument.GetPipSize();
      }

      double stopLoss = PositionGetDouble(POSITION_SL);
      double stopDistance = MathAbs(closePrice - stopLoss) / _instrument.GetPipSize();
      if (stopDistance <= _distance)
         return false;

      ulong ticketId = PositionGetInteger(POSITION_TICKET);
      _lastClose = closePrice;
      double newStop = GetNewStopLoss(closePrice);
      if (newStop == 0.0)
         return false;
      
      string error;
      TradingCommands::MoveSL(ticketId, newStop, error);
      
      return false;
   }
private:
   double GetNewStopLoss(double closePrice)
   {
      double stopLoss = PositionGetDouble(POSITION_SL);
      if (stopLoss == 0.0)
      {
         return 0;
      }
         
      double newStop = stopLoss;
      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if (positionType == POSITION_TYPE_BUY)
      {
         while (_instrument.RoundRate(newStop + _step) < _instrument.RoundRate(closePrice - _distance))
         {
            newStop = _instrument.RoundRate(newStop + _step);
         }
         if (newStop == stopLoss) 
         {
            return 0;
         }
      }
      else
      {
         while (_instrument.RoundRate(newStop - _step) > _instrument.RoundRate(closePrice + _distance))
         {
            newStop = _instrument.RoundRate(newStop - _step);
         }
         if (newStop == stopLoss) 
         {
            return 0;
         }
      }

      return newStop;
   }
};
#endif