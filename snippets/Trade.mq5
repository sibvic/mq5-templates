// Trade v1.1

#ifndef Trade_IMP
#define Trade_IMP

class ITrade
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool Select() = 0;
   virtual ulong GetTicket() = 0;
};

class TradeByTicketId : public ITrade
{
   ulong _ticket;
   int _references;
public:
   TradeByTicketId(ulong ticket)
   {
      _ticket = ticket;
      _references = 1;
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual bool Select()
   {
      return PositionSelectByTicket(_ticket);
   }

   virtual ulong GetTicket()
   {
      return _ticket;
   }
};

#endif