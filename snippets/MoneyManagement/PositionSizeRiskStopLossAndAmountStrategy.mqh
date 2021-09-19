// Stop loss and amount strategy for position size risk v1.1

#include <IStopLossAndAmountStrategy.mqh>
#include <../TradingCalculator.mqh>

#ifndef PositionSizeRiskStopLossAndAmountStrategy_IMP
#define PositionSizeRiskStopLossAndAmountStrategy_IMP

class PositionSizeRiskStopLossAndAmountStrategy : public IStopLossAndAmountStrategy
{
   double _lots;
   TradingCalculator *_calculator;
   StopLimitType _stopLossType;
   double _stopLoss;
   bool _isBuy;
public:
   PositionSizeRiskStopLossAndAmountStrategy(TradingCalculator *calculator, double lots,
      StopLimitType stopLossType, double stopLoss, bool isBuy)
   {
      _calculator = calculator;
      _lots = lots;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
      _isBuy = isBuy;
   }
   
   void GetStopLossAndAmount(const int period, const double entryPrice, double &amount, double &stopLoss)
   {
      stopLoss = _calculator.CalculateStopLoss(_isBuy, _stopLoss, _stopLossType, 0.0, entryPrice);
      amount = _calculator.GetLots(PositionSizeRisk, _lots, _isBuy ? BuySide : SellSide, entryPrice, _isBuy ? (entryPrice - stopLoss) : (stopLoss - entryPrice));
   }
};

#endif