#include <enums/OrderSide.mqh>
#include <InstrumentInfo.mqh>
// Order builder v1.3

#ifndef OrderBuilder_IMP
#define OrderBuilder_IMP

class OrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stop;
   double _limit;
   double _stopLimit;
   int _magicNumber;
   datetime _expiration;
   string _comment;
public:
   OrderBuilder()
   {
      _comment = "";
      _expiration = 0;
      _stopLimit = 0;
      _orderSide = BuySide;
      _instrument = "";
      _amount = 0;
      _rate = 0;
      _slippage = 0;
      _stop = 0;
      _limit = 0;
      _stopLimit = 0;
      _magicNumber = 0;
   }
   
   OrderBuilder *SetExpiration(const datetime expiration)
   {
      _expiration = expiration;
      return &this;
   }
   
   OrderBuilder *SetSide(const OrderSide orderSide)
   {
      _orderSide = orderSide;
      return &this;
   }
   
   OrderBuilder *SetInstrument(const string instrument)
   {
      _instrument = instrument;
      return &this;
   }
   
   OrderBuilder *SetStopLimit(const double stopLimit)
   {
      _stopLimit = stopLimit;
      return &this;
   }
   
   OrderBuilder *SetAmount(const double amount)
   {
      _amount = amount;
      return &this;
   }
    
   OrderBuilder *SetRate(const double rate)
   {
      _rate = rate;
      return &this;
   }
   
   OrderBuilder *SetSlippage(const int slippage)
   {
      _slippage = slippage;
      return &this;
   }
   
   OrderBuilder *SetStopLoss(const double stop)
   {
      _stop = stop;
      return &this;
   }
   
   OrderBuilder *SetTakeProfit(const double limit)
   {
      _limit = limit;
      return &this;
   }
   
   OrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }

   OrderBuilder *SetComment(const string comment)
   {
      _comment = comment;
      return &this;
   }
   
   ulong Execute(string &error)
   {
      InstrumentInfo instrument(_instrument);
      MqlTradeRequest request;
      ZeroMemory(request);
      double tickSize = SymbolInfoDouble(_instrument, SYMBOL_TRADE_TICK_SIZE);
      if (_orderSide == BuySide)
      {
         double ask = SymbolInfoDouble(_instrument, SYMBOL_ASK);
         if (_rate > ask)
         {
            request.type = _stopLimit == 0.0 ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_STOP_LIMIT;
            request.stoplimit = MathRound(_stopLimit / tickSize) * tickSize;
         }
         else
            request.type = ORDER_TYPE_BUY_LIMIT;
      }
      else
      {
         double bid = SymbolInfoDouble(_instrument, SYMBOL_BID);
         if (_rate < bid)
         {
            request.type = _stopLimit == 0.0 ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_STOP_LIMIT;
            request.stoplimit = MathRound(_stopLimit / tickSize) * tickSize;
         }
         else
            request.type = ORDER_TYPE_SELL_LIMIT;
      }
      int digits = (int)SymbolInfoInteger(_instrument, SYMBOL_DIGITS);
      request.action = TRADE_ACTION_PENDING;
      request.symbol = _instrument;
      request.volume = _amount;
      request.price = instrument.RoundRate(_rate);
      request.deviation = _slippage;
      if (_stop != 0.0)
         request.sl = instrument.RoundRate(_stop);
      if (_limit != 0.0)
         request.tp = instrument.RoundRate(_limit);
      request.magic = _magicNumber;
      if (_comment != "")
         request.comment = _comment;
      if (_expiration != 0)
      {
         request.type_time = ORDER_TIME_SPECIFIED;
         request.expiration = _expiration;
      }
      MqlTradeResult result;
      ZeroMemory(result);
      bool res = OrderSend(request, result);
      if (!res)
      {
         switch (result.retcode)
         {
            case TRADE_RETCODE_LIMIT_VOLUME:
               error = "The volume of orders and positions for the symbol has reached the limit";
               return 0;
            case TRADE_RETCODE_INVALID_PRICE:
               error = "Invalid price in the request";
               return 0;
            case TRADE_RETCODE_INVALID_STOPS:
               {
                  int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  double price = request.stoplimit > 0.0 ? request.stoplimit : request.price;
                  if (request.sl != 0.0)
                  {
                     double diff = MathRound((price - request.sl) / point);
                     if (_orderSide == BuySide)
                     {
                        if (diff <= 0)
                        {
                           error = "The stop loss should be lower than the rate for the buy order";
                           return 0;
                        }
                     }
                     else if (diff >= 0)
                     {
                        error = "The stop loss should be higher than the rate for the sell order";
                        return 0;
                     }
                     if (MathAbs(diff) < minStopDistancePoints)
                     {
                        error = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                        return 0;
                     }
                  }
                  if (request.tp != 0.0)
                  {
                     double diff = MathRound((price - request.tp) / point);
                     if (_orderSide == BuySide)
                     {
                        if (diff >= 0)
                        {
                           error = "The take profit should be lower than the rate for the buy order";
                           return 0;
                        }
                     }
                     else if (diff <= 0)
                     {
                        error = "The take profit should be higher than the rate for the sell order";
                        return 0;
                     }
                     if (MathAbs(diff) < minStopDistancePoints)
                     {
                        error = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                        return 0;
                     }
                  }
                  error = "Invalid stops in the request";
               }
               return 0;
            case TRADE_RETCODE_INVALID_VOLUME:
               error = "Volume/lot size is invalid";
               return 0;
            case TRADE_RETCODE_CLIENT_DISABLES_AT:
               error = "Trading is disabled";
               return 0;
         }
         int error = GetLastError();
         switch (error)
         {
            case 4109:
               error = "Trading is not allowed";
               break;
            case 130:
               error = "Failed to create order: stoploss/takeprofit is too close";
               break;
            case ERR_TRADE_SEND_FAILED:
               error = "Trade request sending failed";
               break;
            default:
               error = "Failed to create order: " + IntegerToString(error);
               break;
         }
      }
      return result.order;
   }
};

#endif