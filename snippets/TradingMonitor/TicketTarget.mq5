// Ticket target v1.0

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
