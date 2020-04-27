// Close on opposite strategy v1.0

#include <ICloseOnOppositeStrategy.mq5>

#ifndef DoCloseOnOppositeStrategy_IMP
#define DoCloseOnOppositeStrategy_IMP

class DoCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _magicNumber;
public:
   DoCloseOnOppositeStrategy(const int magicNumber)
   {
      _magicNumber = magicNumber;
   }

   void DoClose(const OrderSide side)
   {
      TradesIterator toClose();
      toClose.WhenSide(side);
      toClose.WhenMagicNumber(_magicNumber);
      TradingCommands::CloseTrades(toClose);
   }
};
#endif