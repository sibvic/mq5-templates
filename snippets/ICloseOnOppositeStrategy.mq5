// Close on opposite strategy interface v1.0

#ifndef ICloseOnOppositeStrategy_IMP
#define ICloseOnOppositeStrategy_IMP

interface ICloseOnOppositeStrategy
{
public:
   virtual void DoClose(const OrderSide side) = 0;
};

#endif