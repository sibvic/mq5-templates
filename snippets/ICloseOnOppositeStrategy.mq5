// Close on opposite strategy interface v1.1

#ifndef ICloseOnOppositeStrategy_IMP
#define ICloseOnOppositeStrategy_IMP

interface ICloseOnOppositeStrategy
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual void DoClose(const OrderSide side) = 0;
};

#endif