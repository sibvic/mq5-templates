// Condition factory interface v1.0

#include <Conditions/ICondition.mqh>

#ifndef IConditionFactory_IMPL
#define IConditionFactory_IMPL
interface IConditionFactory
{
public:
   virtual ICondition* CreateUpCondition(const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
   virtual ICondition* CreateDownCondition(const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
};
#endif