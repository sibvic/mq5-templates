#include <TradingCalculator.mqh>
#include <Actions/AAction.mqh>
#include <TradingCommands.mqh>

// Move net take profit action v 1.0

#ifndef MoveNetTakeProfitAction_IMP

class MoveNetTakeProfitAction : public AAction
{
   TradingCalculator *_calculator;
   int _magicNumber;
   double _takeProfit;
   StopLimitType _type;
public:
   MoveNetTakeProfitAction(TradingCalculator *calculator, StopLimitType type, const double takeProfit, const int magicNumber)
   {
      _type = type;
      _calculator = calculator;
      _takeProfit = takeProfit;
      _magicNumber = magicNumber;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      MoveTakeProfit(true);
      MoveTakeProfit(false);
      return false;
   }
private:
   void MoveTakeProfit(const bool isBuy)
   {
      TradesIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenSide(isBuy);
      if (it.Count() <= 1)
      {
         return;
      }
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(isBuy, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
      {
         return;
      }
         
      double takeProfit = _calculator.CalculateTakeProfit(isBuy, _takeProfit, _type, totalAmount, averagePrice);
      
      TradesIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbolInfo().GetSymbol());
      it.WhenSide(isBuy);
      int count = 0;
      while (it1.Next())
      {
         if (it1.GetTakeProfit() != takeProfit)
         {
            string error;
            if (!TradingCommands::MoveTP(it1.GetTicket(), takeProfit, error))
            {
               Print(error);
            }
            else
            {
               ++count;
            }
         }
      }
   }
};

#define MoveNetTakeProfitAction_IMP

#endif