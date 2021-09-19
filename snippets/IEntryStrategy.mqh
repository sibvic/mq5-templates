// Entry strategy v1.1

#include <MoneyManagement/IMoneyManagementStrategy.mqh>

#ifndef IEntryStrategy_IMP
#define IEntryStrategy_IMP
interface IEntryStrategy
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual ulong OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, bool ecnBroker) = 0;

   virtual int Exit(const OrderSide side) = 0;
};
#endif