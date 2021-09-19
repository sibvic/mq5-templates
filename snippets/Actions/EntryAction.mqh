#include <MoneyManagement/IMoneyManagementStrategy.mqh>
#include <IEntryStrategy.mqh>
#include <OrderHandlers.mqh>

// Entry action v1.0

#ifndef EntryAction_IMP
#define EntryAction_IMP

class EntryAction : public AAction
{
   IEntryStrategy* _entryStrategy;
   OrderSide _side;
   IMoneyManagementStrategy* _moneyManagement;
   string _algorithmId;
   OrderHandlers* _orderHandlers;
   bool _singleAction;
   bool _ecnBroker;
public:
   EntryAction(IEntryStrategy* entryStrategy, OrderSide side, IMoneyManagementStrategy* moneyManagement, string algorithmId, 
      OrderHandlers* __orderHandlers, bool ecnBroker, bool singleAction = false)
   {
      _singleAction = singleAction;
      _orderHandlers = __orderHandlers;
      _orderHandlers.AddRef();
      _algorithmId = algorithmId;
      _moneyManagement = moneyManagement;
      _side = side;
      _ecnBroker = ecnBroker;
      _entryStrategy = entryStrategy;
      _entryStrategy.AddRef();
   }

   ~EntryAction()
   {
      _orderHandlers.Release();
      _entryStrategy.Release();
      delete _moneyManagement;
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      ulong order = _entryStrategy.OpenPosition(period, _side, _moneyManagement, _algorithmId, _ecnBroker);
      if (order >= 0)
      {
         _orderHandlers.DoAction(order);
      }
      return _singleAction;
   }
};

#endif