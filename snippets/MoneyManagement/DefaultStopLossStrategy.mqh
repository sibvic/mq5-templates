#include <TradingCalculator.mqh>
#include <enums/StopLimitType.mqh>
#include <MoneyManagement/IStopLossStrategy.mqh>

// Default stop loss stream v1.0

#ifndef DefaultStopLossStrategy_IMP
#define DefaultStopLossStrategy_IMP

class DefaultStopLossStrategy : public IStopLossStrategy
{
   TradingCalculator* _calculator;
   StopLimitType _stopLossType;
   double _stopLoss;
   bool _isBuy;
public:
   DefaultStopLossStrategy(TradingCalculator* calculator, StopLimitType stopLossType, double stopLoss, bool isBuy)
   {
      _isBuy = isBuy;
      _stopLoss = stopLoss;
      _stopLossType = stopLossType;
      _calculator = calculator;
   }

   virtual double GetValue(const int period, double entryPrice)
   {
      return _calculator.CalculateStopLoss(_isBuy, _stopLoss, _stopLossType, 0.0, entryPrice);
   }
};

#endif