// Close trade action v1.0

#include <../Trade.mqh>
#include <../TradingCommands.mqh>

#ifndef CloseTradeAction_IMP
#define CloseTradeAction_IMP

class CloseTradeAction : public AAction
{
   ITrade* _trade;
public:
   CloseTradeAction(ITrade* trade)
   {
      _trade = trade;
      _trade.AddRef();
   }

   ~CloseTradeAction()
   {
      _trade.Release();
   }

   virtual bool DoAction()
   {
      string error;
      return TradingCommands::CloseTrade(_trade.GetTicket(), error);
   }
};

#endif