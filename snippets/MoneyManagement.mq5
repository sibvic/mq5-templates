// Money management strategy v.1.1
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};

class AMoneyManagementStrategy : public IMoneyManagementStrategy
{
protected:
   TradeCalculator *_calculator;
   PositionSizeType _lotsType;
   double _lots;
   StopLimitType _stopLossType;
   double _stopLoss;
   StopLimitType _takeProfitType;
   double _takeProfit;

   AMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
   {
      _calculator = calculator;
      _lotsType = lotsType;
      _lots = lots;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
      _takeProfitType = takeProfitType;
      _takeProfit = takeProfit;
   }
};

class StopLossStreamLongMoneyManagementStrategy : public AMoneyManagementStrategy
{
   IStream *_stopLossStream;
public:
   StopLossStreamLongMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , IStream *stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, 0, 0, takeProfitType, takeProfit)
   {
      _stopLossStream = stopLoss;
   }
   ~StopLossStreamLongMoneyManagementStrategy()
   {
      delete _stopLossStream;
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      double stopLossVal[1];
      if (!_stopLossStream.GetValues(period, 1, stopLossVal))
      {
         amount = 0;
         stopLoss = 0;
         takeProfit = 0;
         return;
      }
      if (_lotsType == PositionSizeRisk)
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, entryPrice, entryPrice - stopLoss);
      else
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, 0.0, 0);
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice + (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(true, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class StopLossStreamShortMoneyManagementStrategy : public AMoneyManagementStrategy
{
   IStream *_stopLossStream;
public:
   StopLossStreamShortMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , IStream *stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, 0, 0, takeProfitType, takeProfit)
   {
      _stopLossStream = stopLoss;
   }
   ~StopLossStreamShortMoneyManagementStrategy()
   {
      delete _stopLossStream;
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      double stopLossVal[1];
      if (!_stopLossStream.GetValues(period, 1, stopLossVal))
      {
         amount = 0;
         stopLoss = 0;
         takeProfit = 0;
         return;
      }
      if (_lotsType == PositionSizeRisk)
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, entryPrice, stopLoss - entryPrice);
      else
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, 0.0, 0);
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(false, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class LongMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   LongMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, entryPrice, entryPrice - stopLoss);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, 0.0, 0);
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice + (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(true, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class ShortMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   ShortMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, entryPrice, stopLoss - entryPrice);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, 0.0, 0);
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(false, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};