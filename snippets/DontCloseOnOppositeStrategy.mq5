// Don't close on opposite strategy v1.0

#include <ICloseOnOppositeStrategy.mq5>

#ifndef DontCloseOnOppositeStrategy_IMP
#define DontCloseOnOppositeStrategy_IMP
class DontCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
public:
   void DoClose(const OrderSide side)
   {
      // do nothing
   }
};

#endif