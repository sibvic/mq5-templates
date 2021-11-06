#include <Actions/AOrderAction.mqh>
// Order handlers v1.1

#ifndef OrderHandlers_IMP
#define OrderHandlers_IMP

class OrderHandlers
{
   AOrderAction* _orderHandlers[];
   int _references;
public:
   OrderHandlers()
   {
      _references = 1;
   }

   ~OrderHandlers()
   {
      Clear();
   }

   void Clear()
   {
      for (int i = 0; i < ArraySize(_orderHandlers); ++i)
      {
         delete _orderHandlers[i];
      }
      ArrayResize(_orderHandlers, 0);
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

   void AddOrderAction(AOrderAction* orderAction)
   {
      int count = ArraySize(_orderHandlers);
      ArrayResize(_orderHandlers, count + 1);
      _orderHandlers[count] = orderAction;
      orderAction.AddRef();
   }

   void DoAction(ulong order)
   {
      for (int orderHandlerIndex = 0; orderHandlerIndex < ArraySize(_orderHandlers); ++orderHandlerIndex)
      {
         _orderHandlers[orderHandlerIndex].DoAction(order);
      }
   }
};

#endif