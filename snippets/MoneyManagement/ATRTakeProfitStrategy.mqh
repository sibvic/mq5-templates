// ATR take profit strategy v1.0

#include <ITakeProfitStrategy.mqh>

#ifndef ATRTakeProfitStrategy_IMP
#define ATRTakeProfitStrategy_IMP

class ATRTakeProfitStrategy : public ITakeProfitStrategy
{
   int _period;
   double _multiplicator;
   bool _isBuy;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _atr;
public:
   ATRTakeProfitStrategy(string symbol, ENUM_TIMEFRAMES timeframe, int period, double multiplicator, bool isBuy)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _period = period;
      _multiplicator = multiplicator;
      _isBuy = true;
      _atr = iATR(_symbol, _timeframe, _period);
   }
   ~ATRTakeProfitStrategy()
   {
      IndicatorRelease(_atr);
   }

   virtual void GetTakeProfit(const int period, const double entryPrice, double stopLoss, double amount, double& takeProfit)
   {
      double buffer[1];
      if (CopyBuffer(_atr, 0, period, 1, buffer) != 1)
      {
         return;
      }
      takeProfit = _isBuy ? (entryPrice + buffer[0]) : (entryPrice - buffer[0]);
   }
};
#endif