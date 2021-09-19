#include <ITicketTarget.mqh>
// Ticket target v1.0
#ifndef TicketTarget_IMP
#define TicketTarget_IMP

class TicketTarget : public ITicketTarget
{
   ulong _ticket;
public:
   virtual void SetTicket(ulong ticket)
   {
      _ticket = ticket;
   }
   
   ulong GetTicket()
   {
      return _ticket;
   }   
};

#endif