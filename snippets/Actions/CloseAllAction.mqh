#include <Actions/AAction.mqh>
#include <TradesIterator.mqh>
#include <TradingCommands.mqh>

// Close all action v1.0

#ifndef CloseAllAction_IMP
#define CloseAllAction_IMP

class CloseAllAction : public AAction
{
   int _magicNumber;
   double _slippagePoints;
public:
   CloseAllAction(int magicNumber, double slippagePoints)
   {
      _magicNumber = magicNumber;
      _slippagePoints = slippagePoints;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      TradesIterator toClose();
      toClose.WhenMagicNumber(_magicNumber);
      return TradingCommands::CloseTrades(toClose) > 0;
   }
};
#endif