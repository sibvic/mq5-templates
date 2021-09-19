//Move to breakeven action v1.0

#ifndef MoveToBreakevenAction_IMP
#define MoveToBreakevenAction_IMP

#include <../Order.mqh>
#include <../TradingCommands.mqh>
#include <../Signaler.mqh>
#include <../InstrumentInfo.mqh>

class MoveToBreakevenAction : public AAction
{
   Signaler* _signaler;
   double _trigger;
   double _target;
   InstrumentInfo *_instrument;
   IOrder* _order;
   string _name;
   double _refLots;
public:
   MoveToBreakevenAction(double trigger, double target, string name, IOrder* order, Signaler *signaler, double refLots = 0)
   {
      _signaler = signaler;
      _trigger = trigger;
      _target = target;
      _name = name;

      _order = order;
      _order.AddRef();
      _order.Select();
      string symbol = PositionGetString(POSITION_SYMBOL);
      _instrument = new InstrumentInfo(symbol);
      _refLots = refLots;
   }

   ~MoveToBreakevenAction()
   {
      delete _instrument;
      _order.Release();
   }

   virtual bool DoAction(const int period, const datetime date)
   {
      if (!_order.Select() || (_refLots != 0 && _instrument.CompareLots(PositionGetDouble(POSITION_VOLUME_CURRENT), _refLots) != 0))
      {
         return false;
      }
      long ticket = OrderGetInteger(ORDER_TICKET);
      string error;
      if (!TradingCommands::MoveSL(ticket, _target, error))
      {
         Print(error);
         return false;
      }
      if (_signaler != NULL)
      {
         _signaler.SendNotifications(GetNamePrefix() + "Trade " + IntegerToString(ticket) + " has reached " 
            + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
            + DoubleToString(_target, _instrument.GetDigits()));
      }
      return true;
   }
private:
   string GetNamePrefix()
   {
      if (_name == "")
         return "";
      return _name + ". ";
   }
};

#endif