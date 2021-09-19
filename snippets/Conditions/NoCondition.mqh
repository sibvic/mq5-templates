// No condition v1.1

#include <AConditionBase.mqh>

#ifndef NoCondition_IMP
#define NoCondition_IMP

class NoCondition : public AConditionBase
{
public:
   NoCondition()
      :AConditionBase("No condition")
   {

   }
   bool IsPass(const int period, const datetime date) { return true; }
};

#endif