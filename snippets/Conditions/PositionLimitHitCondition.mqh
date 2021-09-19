
#include <Conditions/AConditionBase.mqh>
#include <enums/OrderSide.mqh>
#include <TradesIterator.mqh>

// Position limit hit condition v1.0

#ifndef PositionLimitHitCondition_IMP
#define PositionLimitHitCondition_IMP

class PositionLimitHitCondition : public AConditionBase
{
   int _magicNumber;
   int _maxSidePositions;
   int _totalPositions;
   string _symbol;
   OrderSide _side;
public:
   PositionLimitHitCondition(const OrderSide side, const int magicNumber, const int maxSidePositions, const int totalPositions,
      const string symbol = "")
      :AConditionBase("Position limit hit")
   {
      _symbol = symbol;
      _side = side;
      _magicNumber = magicNumber;
      _maxSidePositions = maxSidePositions;
      _totalPositions = totalPositions;
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      TradesIterator sideSpecificIterator();
      sideSpecificIterator.WhenMagicNumber(_magicNumber);
      sideSpecificIterator.WhenSide(_side);
      if (_symbol != "")
      {
         sideSpecificIterator.WhenSymbol(_symbol);
      }
      int side_positions = sideSpecificIterator.Count();
      if (side_positions >= _maxSidePositions)
      {
         return true;
      }

      TradesIterator it();
      it.WhenMagicNumber(_magicNumber);
      if (_symbol != "")
      {
         it.WhenSymbol(_symbol);
      }
      int positions = it.Count();
      return positions >= _totalPositions;
   }
};

#endif