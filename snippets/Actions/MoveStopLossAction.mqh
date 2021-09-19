// Move stop loss action v1.0

#include <AAction.mqh>

#ifndef MoveStopLossAction_IMP
#define MoveStopLossAction_IMP

class MoveStopLossAction : public AAction
{
public:
   MoveStopLossAction()
   {

   }

   virtual bool DoAction()
   {
      return false;
   }
};

#endif