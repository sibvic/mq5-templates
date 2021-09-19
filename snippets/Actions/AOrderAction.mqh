#include <Actions/AAction.mqh>

// Order action (abstract) v1.0
// Used to execute action on orders

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
   
   virtual void RestoreActions(string symbol, int magicNumber) = 0;
};

#endif