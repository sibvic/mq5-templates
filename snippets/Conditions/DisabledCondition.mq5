// Disabled condition v1.0
#include <ICondition.mq5>

#ifndef DisabledCondition_IMP
#define DisabledCondition_IMP
class DisabledCondition : public ICondition
{
public:
   virtual bool IsPass(const int period) { return false; }
};
#endif