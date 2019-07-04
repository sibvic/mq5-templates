// Trade controller v.1.19

#include <Trade\Trade.mqh>

class TradeController
{   
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastbartime;
   datetime _lastEntry;
   EntryType _entryType;
   Signaler *_signaler;
   TradingTime *_tradingTime;
   BreakevenController *_breakeven[];
   INetStopLossStrategy *_netStopLoss;
   TradeCalculator *_calculator;
   TrailingLogic *_trailing;
   ICondition *_longCondition;
   ICondition *_shortCondition;
   IMoneyManagementStrategy *_longMoneyManagementStrategy;
   IMoneyManagementStrategy *_shortMoneyManagementStrategy;
   IPositionCapStrategy* _positionCap;
   bool _allowTrading;
   bool _closeOnOpposite;
   int _slippage;
   StopLimitType _breakevenType;
   double _breakevenValue;
   int _magicNumber;
   ICooldownController* _cooldownController;
public:
   TradeController(Signaler *signaler, TradeCalculator *calculator, ENUM_TIMEFRAMES timeframe, EntryType entryType, bool allowTrading)
   {
      _closeOnOpposite = false;
      _positionCap = NULL;
      _allowTrading = allowTrading;
      _longCondition = NULL;
      _shortCondition = NULL;
      _longMoneyManagementStrategy = NULL;
      _shortMoneyManagementStrategy = NULL;
      _netStopLoss = NULL;
      _signaler = signaler;
      _entryType = entryType;
      _timeframe = timeframe;
      _calculator = calculator;
      _tradingTime = NULL;
      _trailing = NULL;
      _cooldownController = NULL;
      _magicNumber = 0;
   }

   ~TradeController()
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         delete _breakeven[i];
      }
      delete _positionCap;
      delete _longMoneyManagementStrategy;
      delete _shortMoneyManagementStrategy;
      delete _longCondition;
      delete _shortCondition;
      delete _trailing;
      delete _calculator;
      delete _signaler;
      delete _tradingTime;
      delete _netStopLoss;
      delete _cooldownController;
   }

   TradeController* SetCooldown(ICooldownController* controller) { _cooldownController = controller; return &this; }
   TradeController* SetSlippage(int slippage) { _slippage = slippage; return &this; }
   TradeController* SetBreakevenType(StopLimitType breakevenType, double breakevenValue) { _breakevenType = breakevenType; _breakevenValue = breakevenValue; return &this; }
   TradeController* SetCloseOnOpposite(bool closeOnOpposite) { _closeOnOpposite = closeOnOpposite; return &this; }
   TradeController* SetPositionCap(IPositionCapStrategy* positionCap) { _positionCap = positionCap; return &this; }
   TradeController *SetLongCondition(ICondition *condition) { _longCondition = condition; return &this; }
   TradeController *SetShortCondition(ICondition *condition) { _shortCondition = condition; return &this; }
   TradeController *SetTradingTime(TradingTime *tradingTime) { _tradingTime = tradingTime; return &this; }
   TradeController *SetTrailing(TrailingLogic *trailing) { _trailing = trailing; return &this; }
   TradeController *SetNetStopLossStrategy(INetStopLossStrategy *strategy) { _netStopLoss = strategy; return &this; }
   TradeController *SetLongMoneyManagementStrategy(IMoneyManagementStrategy *moneyManagementStrategy) { _longMoneyManagementStrategy = moneyManagementStrategy; return &this; }
   TradeController *SetShortMoneyManagementStrategy(IMoneyManagementStrategy *moneyManagementStrategy) { _shortMoneyManagementStrategy = moneyManagementStrategy; return &this; }
   TradeController* SetMagicNumber(int magicNumber) { _magicNumber = magicNumber; return &this; }

   void DoTrading()
   {
      _netStopLoss.DoLogic();
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         _breakeven[i].DoLogic();
      }
      _trailing.DoLogic();

      if (IsExitBuyCondition() && _allowTrading)
      {
         switch (LogicType)
         {
            case DirectLogic:
               {
                  if (CloseTrades(POSITION_TYPE_BUY))
                     _signaler.SendNotifications(EXIT_BUY_SIGNAL);
                  break;
               }
            case ReversalLogic:
               {
                  if (CloseTrades(POSITION_TYPE_SELL))
                     _signaler.SendNotifications(EXIT_SELL_SIGNAL);
                  break;
               }
         }
      }
      if (IsExitSellCondition() && _allowTrading)
      {
         switch (LogicType)
         {
            case DirectLogic:
               if (CloseTrades(POSITION_TYPE_SELL))
                  _signaler.SendNotifications(EXIT_SELL_SIGNAL);
               break;
            case ReversalLogic:
               if (CloseTrades(POSITION_TYPE_BUY))
                  _signaler.SendNotifications(EXIT_BUY_SIGNAL);
               break;
         }
      }
      
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      datetime current_time = iTime(symbol, _timeframe, 0);
      if (_tradingTime != NULL && !_tradingTime.IsTradingTime(current_time))
      {
         if (MandatoryClosing && _allowTrading)
         {
            TradesIterator it;
            it.WhenSymbol(symbol);
            it.WhenMagicNumber(_magicNumber);
            int closedCount = TradingCommands::CloseTrades(it);
            TradingCommands::DeleteOrders(_magicNumber, symbol);
            if (closedCount)
               _signaler.SendNotifications("Mandatory closing");
         }
         return;
      }

      int shift = 0;
      if (_entryType == EntryOnClose)
      {
         if (_lastEntry == current_time)
            return;
         _lastEntry = current_time;
         shift = 1;
      }
      if (_cooldownController.IsCooldownPeriod(shift))
         return;
      if (_longCondition.IsPass(shift))
      {
         if (_allowTrading)
         {
            if (!_positionCap.IsLimitHit())
               GoLong(_longMoneyManagementStrategy, shift);
         }
         _signaler.SendNotifications(ENTER_BUY_SIGNAL);
         _cooldownController.RegisterTrading(shift);
      }
      if (_shortCondition.IsPass(shift))
      {
         if (_allowTrading)
         {
            if (!_positionCap.IsLimitHit())
               GoShort(_shortMoneyManagementStrategy, shift);
         }
         _signaler.SendNotifications(ENTER_SELL_SIGNAL);
         _cooldownController.RegisterTrading(shift);
      }
   }
private:
   ulong GoLong(IMoneyManagementStrategy *moneyManagementStrategy, const int period)
   {
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      if (_closeOnOpposite)
      {
         TradesIterator it();
         it.WhenMagicNumber(_magicNumber);
         it.WhenSide(SellSide);
         it.WhenSymbol(symbol);
         TradingCommands::CloseTrades(it);
      }

      double ask = _calculator.GetSymbolInfo().GetAsk();
      double amount = 0.0;
      double stopLoss = 0.0;
      double takeProfit = 0.0;
      moneyManagementStrategy.Get(period, ask, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return 0;
      
      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      ulong order = orderBuilder
         .SetStopLoss(stopLoss)
         .SetSide(BuySide)
         .SetInstrument(symbol)
         .SetAmount(amount)
         .SetSlippage(_slippage)
         .SetMagicNumber(_magicNumber)
         .SetTakeProfit(takeProfit)
         .SetComment("")
         .Execute(error);
      delete orderBuilder;
      if (order != 0)
      {
         _trailing.Create(order, stopLoss, true);
         if (_breakevenType != StopLimitDoNotUse)
            CreateBreakeven(order);
      }
      else
         Print("Failed to open long position: " + error);
      return order;
   }

   ulong GoShort(IMoneyManagementStrategy *moneyManagementStrategy, const int period)
   {
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      if (_closeOnOpposite)
      {
         TradesIterator it();
         it.WhenMagicNumber(_magicNumber);
         it.WhenSide(BuySide);
         it.WhenSymbol(symbol);
         TradingCommands::CloseTrades(it);
      }

      double bid = _calculator.GetSymbolInfo().GetBid();
      double amount = 0.0;
      double stopLoss = 0.0;
      double takeProfit = 0.0;
      moneyManagementStrategy.Get(period, bid, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return 0;

      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      ulong order = orderBuilder
         .SetStopLoss(stopLoss)
         .SetSide(SellSide)
         .SetInstrument(symbol)
         .SetAmount(amount)
         .SetSlippage(_slippage)
         .SetMagicNumber(_magicNumber)
         .SetTakeProfit(takeProfit)
         .SetComment("")
         .Execute(error);
      delete orderBuilder;
      if (order != 0)
      {
         _trailing.Create(order, stopLoss, false);
         if (_breakevenType != StopLimitDoNotUse)
            CreateBreakeven(order);
      }
      else
         Print("Failed to open short position: " + error);
      return order;
   }

   void CreateBreakeven(const ulong order)
   {
      if (!OrderSelect(order))
         return;
      ulong orderType = OrderGetInteger(ORDER_TYPE);
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      bool isBuy = orderType == ORDER_TYPE_BUY;
      double basePrice = isBuy ? _calculator.GetSymbolInfo().GetAsk() : _calculator.GetSymbolInfo().GetBid();
      double target = 0;
      double targetValue = isBuy 
         ? basePrice - target * _calculator.GetSymbolInfo().GetPipSize()
         : basePrice + target * _calculator.GetSymbolInfo().GetPipSize();
      double triggerValue = _calculator.CalculateTakeProfit(isBuy, _breakevenValue, _breakevenType, OrderGetDouble(ORDER_VOLUME_CURRENT), basePrice);

      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         if (_breakeven[i].SetOrder(order, triggerValue, targetValue))
         {
            return;
         }
      }

      ArrayResize(_breakeven, i_count + 1);
      _breakeven[i_count] = new BreakevenController();
      _breakeven[i_count].SetOrder(order, triggerValue, targetValue);
   }
};