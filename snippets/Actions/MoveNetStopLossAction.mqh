#include <TradingCalculator.mqh>
#include <TradingCommands.mqh>
#include <Actions/AAction.mqh>

// Move net stop loss action v 1.0

#ifndef MoveNetStopLossAction_IMP
#define MoveNetStopLossAction_IMP

class MoveNetStopLossAction : public AAction
{
   TradingCalculator *_calculator;
   int _magicNumber;
   double _stopLoss;
   double _breakevenTrigger;
   double _breakevenTarget;
   bool _useBreakeven;
   StopLimitType _type;
public:
   MoveNetStopLossAction(TradingCalculator *calculator, 
      StopLimitType type, 
      const double stopLoss, 
      const int magicNumber)
   {
      _useBreakeven = false;
      _type = type;
      _calculator = calculator;
      _stopLoss = stopLoss;
      _magicNumber = magicNumber;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      MoveStopLoss(true);
      MoveStopLoss(false);
      return false;
   }

   void SetBreakeven(const double breakevenTrigger, const double breakevenTarget)
   {
      _useBreakeven = true;
      _breakevenTrigger = breakevenTrigger;
      _breakevenTarget = breakevenTarget;
   }
private:
   double GetDistance(const bool isBuy, double averagePrice)
   {
      if (isBuy)
      {
         return (_calculator.GetSymbolInfo().GetBid() - averagePrice) / _calculator.GetSymbolInfo().GetPipSize();
      }
      return (averagePrice - _calculator.GetSymbolInfo().GetAsk()) / _calculator.GetSymbolInfo().GetPipSize();
   }

   double GetTarget(const bool isBuy, double averagePrice)
   {
      if (!_useBreakeven)
      {
         return _stopLoss;
      }
      double distance = GetDistance(isBuy, averagePrice);
      if (distance < _breakevenTrigger)
      {
         return _stopLoss;
      }
      return _breakevenTarget;
   }

   double GetStopLoss(bool isBuy)
   {
      double totalAmount;
      double averagePrice = _calculator.GetBreakevenPrice(isBuy, _magicNumber, totalAmount);
      if (averagePrice == 0.0)
      {
         return 0;
      }
      return _calculator.CalculateStopLoss(isBuy, GetTarget(isBuy, averagePrice), _type, totalAmount, averagePrice);
   }

   void MoveStopLoss(const bool isBuy)
   {
      TradesIterator it();
      it.WhenMagicNumber(_magicNumber);
      it.WhenSide(isBuy);
      if (it.Count() <= 1)
      {
         return;
      }
      double stopLoss = GetStopLoss(isBuy);
      if (stopLoss == 0)
      {
         return;
      }
      
      TradesIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbolInfo().GetSymbol());
      it1.WhenSide(isBuy);
      int count = 0;
      while (it1.Next())
      {
         if (it1.GetStopLoss() != stopLoss)
         {
            string error;
            if (!TradingCommands::MoveSL(it1.GetTicket(), stopLoss, error))
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

#endif