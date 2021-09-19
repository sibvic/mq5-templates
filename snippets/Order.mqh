// Order v1.1

#ifndef Order_IMP
#define Order_IMP

interface IOrder
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool Select() = 0;
};

class OrderByMagicNumber : public IOrder
{
   int _magicMumber;
   int _references;
   ulong _ticketId;
public:
   OrderByMagicNumber(int magicNumber)
   {
      _ticketId = 0;
      _magicMumber = magicNumber;
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
      OrdersIterator it();
      it.WhenMagicNumber(_magicMumber);
      _ticketId = it.First();
      return OrderSelect(_ticketId);
   }
};

class OrderByTicketId : public IOrder
{
   ulong _ticket;
   int _references;
public:
   OrderByTicketId(ulong ticket)
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
      return OrderSelect(_ticket);
   }
};

#endif