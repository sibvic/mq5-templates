// Trading commands v.1.1
class TradingCommands
{
public:
   static bool MoveStop(const ulong ticket, const double stopLoss, string &error)
   {
      if (!PositionSelectByTicket(ticket))
      {
         error = "Invalid ticket";
         return false;
      }
      return tradeManager.PositionModify(ticket, stopLoss, PositionGetDouble(POSITION_TP));
   }

   static void DeleteOrders(const int magicNumber, const string symbol)
   {
      OrdersIterator it();
      it.WhenMagicNumber(magicNumber);
      it.WhenSymbol(symbol);
      while (it.Next())
      {
         tradeManager.OrderDelete(it.GetTicket());
      }
   }

   static int CloseTrades(TradesIterator &it)
   {
      int close = 0;
      while (it.Next())
      {
         switch (it.GetPositionType())
         {
            case POSITION_TYPE_BUY:
               {
                  if (!tradeManager.PositionClose(it.GetTicket())) 
                     Print("LastError = ", GetLastError());
                  else
                     ++close;
               }
               break;
            case POSITION_TYPE_SELL:
               {
                  if (!tradeManager.PositionClose(it.GetTicket())) 
                     Print("LastError = ", GetLastError());
                  else
                     ++close;
               }
               break;
         }
      }
      return close;
   }
};