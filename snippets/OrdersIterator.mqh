#include <enums/CompareType.mqh>
#include <enums/OrderSide.mqh>

// Orders iterator v1.9

#ifndef OrdersIterator_IMP
#define OrdersIterator_IMP

class OrdersIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   bool _useOrderType;
   ENUM_ORDER_TYPE _orderType;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _usePendingOrder;
   bool _pendingOrder;
   bool _useComment;
   string _comment;
   CompareType _profitCompare;
public:
   OrdersIterator()
   {
      _useOrderType = false;
      _useMagicNumber = false;
      _usePendingOrder = false;
      _pendingOrder = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useComment = false;
   }

   OrdersIterator *WhenPendingOrder()
   {
      _usePendingOrder = true;
      _pendingOrder = true;
      return &this;
   }

   OrdersIterator *WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
   }

   OrdersIterator *WhenSide(const OrderSide side)
   {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
   }

   OrdersIterator *WhenOrderType(const ENUM_ORDER_TYPE orderType)
   {
      _useOrderType = true;
      _orderType = orderType;
      return &this;
   }

   OrdersIterator *WhenMagicNumber(const int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
   }

   OrdersIterator *WhenComment(const string comment)
   {
      _useComment = true;
      _comment = comment;
      return &this;
   }

   long GetMagicNumger() { return OrderGetInteger(ORDER_MAGIC); }
   ENUM_ORDER_TYPE GetType() { return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); }
   string GetSymbol() { return OrderGetString(ORDER_SYMBOL); }
   string GetComment() { return OrderGetString(ORDER_COMMENT); }
   ulong GetTicket() { return OrderGetTicket(_lastIndex); }
   double GetOpenPrice() { return OrderGetDouble(ORDER_PRICE_OPEN); }
   double GetStopLoss() { return OrderGetDouble(ORDER_SL); }
   double GetTakeProfit() { return OrderGetDouble(ORDER_TP); }

   int Count()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            count++;
      }
      return count;
   }

   bool Next()
   {
      if (_lastIndex == INT_MIN)
         _lastIndex = OrdersTotal() - 1;
      else
         _lastIndex = _lastIndex - 1;
      while (_lastIndex >= 0)
      {
         ulong ticket = OrderGetTicket(_lastIndex);
         if (OrderSelect(ticket) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            return true;
      }
      return false;
   }

   ulong First()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            return ticket;
      }
      return -1;
   }

private:
   bool PassFilter()
   {
      if (_useMagicNumber && GetMagicNumger() != _magicNumber)
         return false;
      if (_useOrderType && GetType() != _orderType)
         return false;
      if (_useSymbol && OrderGetString(ORDER_SYMBOL) != _symbol)
         return false;
      if (_usePendingOrder && !IsPendingOrder())
         return false;
      if (_useComment && OrderGetString(ORDER_COMMENT) != _comment)
         return false;
      return true;
   }

   bool IsPendingOrder()
   {
      switch (GetType())
      {
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_STOP_LIMIT:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
         case ORDER_TYPE_SELL_STOP_LIMIT:
            return true;
      }
      return false;
   }
};
#endif