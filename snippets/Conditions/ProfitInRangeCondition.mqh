#include <Conditions/AConditionBase.mqh>
#include <Trade.mqh>
#include <InstrumentInfo.mqh>

// Profit in range condition v2.0

#ifndef ProfitInRangeCondition_IMP
#define ProfitInRangeCondition_IMP

class ProfitInRangeCondition : public AConditionBase
{
   ITrade* _trade;
   InstrumentInfo* _instrument;
   double _minProfit;
   double _maxProfit;
public:
   ProfitInRangeCondition(ITrade* trade, double minProfit, double maxProfit)
   {
      _trade = trade;
      _trade.AddRef();
      _minProfit = minProfit;
      _maxProfit = maxProfit;
      _instrument = NULL;
   }

   ~ProfitInRangeCondition()
   {
      _trade.Release();
      if (_instrument != NULL)
         delete _instrument;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      if (!_trade.Select())
         return true;
      
      string symbol = PositionGetString(POSITION_SYMBOL);
      if (_instrument == NULL)
         _instrument = new InstrumentInfo(symbol);

      double closePrice = iClose(symbol, PERIOD_M1, 0);
      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      if (positionType == POSITION_TYPE_BUY)
      {
         double profit = (closePrice - openPrice) / _instrument.GetPipSize();
         return profit >= _minProfit && profit <= _maxProfit;
      }
      else
      {
         double profit = (openPrice - closePrice) / _instrument.GetPipSize();
         return profit >= _minProfit && profit <= _maxProfit;
      }
      return false;
   }
};

#endif