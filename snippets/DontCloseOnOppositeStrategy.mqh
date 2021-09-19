// Don't close on opposite strategy v1.1

#include <ICloseOnOppositeStrategy.mqh>

#ifndef DontCloseOnOppositeStrategy_IMP
#define DontCloseOnOppositeStrategy_IMP
class DontCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _references;
public:
   DontCloseOnOppositeStrategy()
   {
      _references = 1;
   }

   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   void DoClose(const OrderSide side)
   {
      // do nothing
   }
};

#endif