#include <enums/TakeProfitType.mqh>
#include <enums/StopLossType.mqh>
#include <enums/PositionSizeType.mqh>
#include <MoneyManagement/IStopLossStrategy.mqh>
#include <MoneyManagement/DefaultStopLossStrategy.mqh>
// #include <HighLowStopLossStrategy.mqh>
#include <MoneyManagement/MoneyManagementStrategy.mqh>
// #include <ATRStopLossStrategy.mqh>
#include <MoneyManagement/RiskBalanceStopLossStrategy.mqh>
#include <MoneyManagement/ILotsProvider.mqh>
#include <MoneyManagement/RiskLotsProvider.mqh>
#include <MoneyManagement/DefaultLotsProvider.mqh>
#include <MoneyManagement/DollarStopLossStrategy.mqh>
#include <MoneyManagement/ITakeProfitStrategy.mqh>
#include <MoneyManagement/DefaultTakeProfitStrategy.mqh>
#include <MoneyManagement/RiskToRewardTakeProfitStrategy.mqh>
// #include <ATRTakeProfitStrategy.mqh>
#include <TradingCalculator.mqh>

#ifndef MoneyManagementFunctions_IMP
#define MoneyManagementFunctions_IMP

IStopLossStrategy* CreateStopLossStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy, StopLossType stopLossType, double stopLossValue, double stopLosstAtrMultiplicator)
{
   switch (stopLossType)
   {
      case SLDoNotUse:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitDoNotUse, stopLossValue, isBuy);
      case SLPercent:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitPercent, stopLossValue, isBuy);
      case SLPips:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitPips, stopLossValue, isBuy);
      case SLAbsolute:
         return new DefaultStopLossStrategy(tradingCalculator, StopLimitAbsolute, stopLossValue, isBuy);
    //   case SLHighLow:
    //      return new HighLowStopLossStrategy((int)stopLossValue, isBuy, symbol, timeframe);
    //   case SLAtr:
    //      return new ATRStopLossStrategy(symbol, timeframe, (int)stopLossValue, stopLosstAtrMultiplicator, isBuy);
      case SLDollar:
      case SLRiskBalance:
         Print("Not supported stop loss and amount types");
         return NULL; // Not supported at all
   }
   return NULL;
}

IStopLossStrategy* CreateStopLossStrategyForLots(ILotsProvider* lots, TradingCalculator* tradingCalculator,
   string symbol, ENUM_TIMEFRAMES timeframe, bool isBuy, 
   StopLossType stopLossType, double stopLossValue, double stopLossAtrMultiplicator)
{
   switch (stopLossType)
   {
      case SLDollar:
         return new DollarStopLossStrategy(tradingCalculator, stopLossValue, isBuy, lots);
      case SLRiskBalance:
         return new RiskBalanceStopLossStrategy(tradingCalculator, stopLossValue, isBuy, lots);
      default:
         return CreateStopLossStrategy(tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
   }
   return NULL;
}

ITakeProfitStrategy* CreateTakeProfitStrategy(TradingCalculator* tradingCalculator, 
   string symbol, ENUM_TIMEFRAMES timeframe, bool isBuy, 
   TakeProfitType takeProfitType, double takeProfitValue, double takeProfitAtrMultiplicator)
{
   switch (takeProfitType)
   {
      #ifdef TAKE_PROFIT_FEATURE
         case TPPercent:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPercent, takeProfitValue, isBuy);
         case TPPips:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPips, takeProfitValue, isBuy);
         case TPDollar:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDollar, takeProfitValue, isBuy);
         case TPRiskReward:
            return new RiskToRewardTakeProfitStrategy(takeProfitValue, isBuy);
         case TPAbsolute:
            return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitAbsolute, takeProfitValue, isBuy);
        //  case TPAtr:
        //     return new ATRTakeProfitStrategy(symbol, timeframe, (int)takeProfitValue, takeProfitAtrMultiplicator, isBuy);
      #endif
   }
   return new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDoNotUse, takeProfitValue, isBuy);
}

MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy, PositionSizeType lotsType, double lotsValue,
   StopLossType stopLossType, double stopLossValue, double stopLossAtrMultiplicator,
   TakeProfitType takeProfitType, double takeProfitValue, double takeProfitAtrMultiplicator)
{
   ILotsProvider* lots = NULL;
   IStopLossStrategy* stopLoss = NULL;
   switch (lotsType)
   {
      case PositionSizeRisk:
         stopLoss = CreateStopLossStrategy(tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
         lots = new RiskLotsProvider(tradingCalculator, lotsType, lotsValue, stopLoss, isBuy ? BuySide : SellSide);
         break;
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lotsType, lotsValue);
         stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, isBuy, stopLossType, stopLossValue, stopLossAtrMultiplicator);
         break;
   }
   ITakeProfitStrategy* tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, isBuy, takeProfitType, takeProfitValue, takeProfitAtrMultiplicator);
   return new MoneyManagementStrategy(lots, stopLoss, tp);
}
#endif