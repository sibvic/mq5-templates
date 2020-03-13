// Disabled condition v1.0
#include <AConditionBase.mq5>

#ifndef DisabledCondition_IMP
#define DisabledCondition_IMP
class DisabledCondition : public AConditionBase
{
public:
   virtual bool IsPass(const int period, const datetime date) { return false; }
};
#endif