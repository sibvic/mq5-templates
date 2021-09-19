// Close on opposite strategy v2.0

#include <ICloseOnOppositeStrategy.mqh>

#ifndef DoCloseOnOppositeStrategy_IMP
#define DoCloseOnOppositeStrategy_IMP

class DoCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _magicNumber;
   int _slippage;
   int _references;
public:
   DoCloseOnOppositeStrategy(const int slippage, const int magicNumber)
   {
      _magicNumber = magicNumber;
      _slippage = slippage;
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
      TradesIterator toClose();
      toClose.WhenSide(side);
      toClose.WhenMagicNumber(_magicNumber);
      TradingCommands::CloseTrades(toClose);
   }
};
#endif