// Order action (abstract) v1.0
// Used to execute action on orders

#include <AAction.mq5>
#ifndef AOrderAction_IMP
#define AOrderAction_IMP
class AOrderAction : public AAction
{
protected:
   ulong _currentTicket;
public:
   virtual bool DoAction(ulong ticket)
   {
      _currentTicket = ticket;
      return DoAction(0, 0);
   }
};

#endif