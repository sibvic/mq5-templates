#include <../enums/StopLossType.mq5>
#include <../enums/TakeProfitType.mq5>
#include <../enums/PositionSizeType.mq5>
#include <../TradingCalculator.mq5>
#include <MoneyManagementStrategy.mq5>
#include <ILotsProvider.mq5>
#include <DefaultLotsProvider.mq5>
#include <PositionSizeRiskStopLossAndAmountStrategy.mq5>
#include <DefaultStopLossAndAmountStrategy.mq5>
#include <DefaultTakeProfitStrategy.mq5>
#ifndef MoneyManagementFunctions_IMP
#define MoneyManagementFunctions_IMP

MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol
   , ENUM_TIMEFRAMES timeframe, bool isBuy, PositionSizeType lotsType, double lotsValue
   , StopLossType stopLossType, double stopLossValue, TakeProfitType takeProfitType, double takeProfitValue, double takeProfitATRMult)
{
   ILotsProvider* lots = NULL;
   switch (lotsType)
   {
      case PositionSizeRisk:
      case PositionSizeRiskCurrency:
         break;
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lotsType, lotsValue);
         break;
   }
   IStopLossAndAmountStrategy* sl = NULL;
   switch (stopLossType)
   {
      case SLDoNotUse:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitDoNotUse, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDoNotUse, stopLossValue, isBuy);
         }
         break;
      case SLPercent:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitPercent, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPercent, stopLossValue, isBuy);
         }
         break;
      case SLPips:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitPips, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPips, stopLossValue, isBuy);
         }
         break;
      case SLDollar:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitDollar, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDollar, stopLossValue, isBuy);
         }
         break;
      case SLAbsolute:
         {
            if (lotsType == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lotsValue, StopLimitAbsolute, stopLossValue, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitAbsolute, stopLossValue, isBuy);
         }
         break;
   }
   ITakeProfitStrategy* tp = NULL;
   switch (takeProfitType)
   {
      case TPDoNotUse:
         tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDoNotUse, takeProfitValue, isBuy);
         break;
      #ifdef TAKE_PROFIT_FEATURE
         case TPPercent:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPercent, takeProfitValue, isBuy);
            break;
         case TPPips:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPips, takeProfitValue, isBuy);
            break;
         case TPDollar:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDollar, takeProfitValue, isBuy);
            break;
         case TPRiskReward:
            tp = new RiskToRewardTakeProfitStrategy(takeProfitValue, isBuy);
            break;
         case TPAbsolute:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitAbsolute, takeProfitValue, isBuy);
            break;
         case TPAtr:
            tp = new ATRTakeProfitStrategy(symbol, timeframe, (int)takeProfitValue, takeProfitATRMult, isBuy);
            break;
      #endif
   }
   
   return new MoneyManagementStrategy(sl, tp);
}
#endif