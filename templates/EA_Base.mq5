#property version   "1.00"
#property description "ProfitRobots templates: https://github.com/sibvic/mq5-templates"
#property strict

#include <Trade\Trade.mqh>

enum OrderSide
{
   BuySide,
   SellSide
};

CTrade tradeManager;

enum EntryType
{
   EntryOnClose, // Entry on candle close
   EntryLive // Entry on tick
};

enum TradingDirection
{
   LongSideOnly, // Long only
   ShortSideOnly, // Short only
   BothSides // Both
};

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $
   StopLimitRiskReward // Set in % of stop loss
};

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeMoneyPerPip // $ per pip
};

enum PositionDirection
{
   DirectLogic, // Direct
   ReversalLogic // Reversal
};

enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips, // Use trailing in pips
   TrailingPercent // Use trailing in % of stop
};

input string GeneralSection = ""; // == General ==
input string symbols = ""; // Symbols to trade. Separated by ","
input bool allow_trading = true; // Allow trading
input bool BTCAccount = false; // Is BTC Account?
input EntryType entry_type = EntryOnClose; // Entry type
input TradingDirection trading_direction = BothSides; // What trades should be taken
input double lot_size            = 0.1; // Position size
input PositionSizeType lot_type = PositionSizeContract; // Position size type
input int slippage_points           = 3; // Slippage, in points
input bool close_on_opposite = true; // Close on opposite

input string SLSection            = ""; // == Stop loss/TakeProfit ==
input StopLimitType stop_loss_type = StopLimitPips; // Stop loss type
input double stop_loss_value            = 10; // Stop loss value
input TrailingType trailing_type = TrailingDontUse; // Use trailing
input double TrailingStep = 10; // Trailing step
input StopLimitType take_profit_type = StopLimitPips; // Take profit type
input double take_profit_value           = 10; // Take profit value
input StopLimitType breakeven_type = StopLimitPips; // Trigger type for the breakeven
input double breakeven_value = 10; // Trigger for the breakeven

input string PositionCapSection = ""; // == Position cap ==
input bool use_position_cap = true; // Use position cap?
input int max_positions = 2; // Max positions

enum DayOfWeek
{
   DayOfWeekSunday = 0, // Sunday
   DayOfWeekMonday = 1, // Monday
   DayOfWeekTuesday = 2, // Tuesday
   DayOfWeekWednesday = 3, // Wednesday
   DayOfWeekThursday = 4, // Thursday
   DayOfWeekFriday = 5, // Friday
   DayOfWeekSaturday = 6 // Saturday
};

input string OtherSection            = ""; // == Other ==
input int magic_number        = 42; // Magic number
input PositionDirection LogicType = DirectLogic; // Logic type
input string StartTime = "000000"; // Start time in hhmmss format
input string EndTime = "235959"; // End time in hhmmss format
input bool LimitWeeklyTime = false; // Weekly time
input DayOfWeek WeekStartDay = DayOfWeekSunday; // Start day
input string WeekStartTime = "000000"; // Start time in hhmmss format
input DayOfWeek WeekStopDay = DayOfWeekSaturday; // Stop day
input string WeekStopTime = "235959"; // Stop time in hhmmss format
input bool MandatoryClosing = false; // Mandatory closing for non-trading time

//Signaler v 1.4
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment5                 = "- DISABLED IN THIS VERSION -";
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll and cpprest141_2_10.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
//#import "AdvancedNotificationsLib.dll"
//void AdvancedAlert(string key, string text, string instrument, string timeframe);
//#import

#include <Stream.mq5>
#include <TradingTime.mq5>
#include <InstrumentInfo.mq5>
#include <TradesIterator.mq5>
#include <TradingCalculator.mq5>
#include <Condition.mq5>
#include <MoneyManagement.mq5>
#include <OrdersIterator.mq5>
#include <TradingCommands.mq5>
#include <TrailingController.mq5>
#include <NetStopLoss.mq5>
#include <MarketOrderBuilder.mq5>
#include <PositionCap.mq5>
#include <TradeController.mq5>
#include <Cooldown.mq5>

TradeController* controllers[];

TradeController* CreateController(const string symbol, ENUM_TIMEFRAMES tf, string &error)
{
   TradingTime *tradingTime = new TradingTime();
   if (!tradingTime.Init(StartTime, EndTime, error))
   {
      delete tradingTime;
      return NULL;
   }
   if (LimitWeeklyTime && !tradingTime.SetWeekTradingTime(WeekStartDay, WeekStartTime, WeekStopDay, WeekStopTime, error))
   {
      delete tradingTime;
      return NULL;
   }
   TimeRangeCooldownController* cooldown = new TimeRangeCooldownController(symbol, PERIOD_M1, max_positions);
   if (!cooldown.Init(StartTime, error))
   {
      delete tradingTime;
      delete cooldown;
      return NULL;
   }

   TradingCalculator *tradeCalculator = new TradingCalculator(symbol);
   Signaler *signaler = new Signaler(symbol, tf);
   TradeController* tradeController = new TradeController(signaler, tradeCalculator, tf, entry_type, allow_trading);
   tradeController.SetTradingTime(tradingTime)
      .SetCloseOnOpposite(close_on_opposite)
      .SetCooldown(cooldown)
      .SetSlippage(slippage_points)
      .SetMagicNumber(magic_number)
      .SetBreakevenType(breakeven_type, breakeven_value)
      .SetTrailing(new TrailingLogic(tradeCalculator, trailing_type, TrailingStep, 0, tf))
      .SetNetStopLossStrategy(new NoNetStopLossStrategy());
   IPositionCapStrategy* positionCap = use_position_cap 
      ? (IPositionCapStrategy*)new PositionCapStrategy(max_positions)
      : (IPositionCapStrategy*)new NoPositionCapStrategy();
   tradeController.SetPositionCap(positionCap);

   ICondition *longCondition = trading_direction != ShortSideOnly ? (ICondition *)new EntryLongCondition(tradeCalculator.GetSymbolInfo(), tf) : (ICondition *)new DisabledCondition();
   ICondition *shortCondition = trading_direction != LongSideOnly ? (ICondition *)new EntryShortCondition(tradeCalculator.GetSymbolInfo(), tf) : (ICondition *)new DisabledCondition();
   IMoneyManagementStrategy *longMoneyManagement = new LongMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   IMoneyManagementStrategy *shortMoneyManagement = new ShortMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   if (LogicType == DirectLogic)
   {
      tradeController.SetLongCondition(longCondition);
      tradeController.SetShortCondition(shortCondition);
      tradeController.SetLongMoneyManagementStrategy(longMoneyManagement);
      tradeController.SetShortMoneyManagementStrategy(shortMoneyManagement);
   }
   else
   {
      tradeController.SetLongCondition(shortCondition);
      tradeController.SetShortCondition(longCondition);
      tradeController.SetLongMoneyManagementStrategy(shortMoneyManagement);
      tradeController.SetShortMoneyManagementStrategy(longMoneyManagement);
   }
   
   return tradeController;
}

void split(string& arr[], string str, string sym) 
{
   ArrayResize(arr, 0);
   int len = StringLen(str);
   for (int i=0; i < len;)
   {
      int pos = StringFind(str, sym, i);
      if (pos == -1)
         pos = len;

      string item = StringSubstr(str, i, pos-i);
      StringTrimLeft(item);
      StringTrimRight(item);

      int size = ArraySize(arr);
      ArrayResize(arr, size+1);
      arr[size] = item;

      i = pos+1;
   }
}

int OnInit()
{
   string error;
   string sym_arr[];
   if (symbols != "")
   {
      split(sym_arr, symbols, ",");
   }
   else
   {
      ArrayResize(sym_arr, 1);
      sym_arr[0] = _Symbol;
   }
   int sym_count = ArraySize(sym_arr);
   for (int i = 0; i < sym_count; i++)
   {
      string symbol = sym_arr[i];
      TradeController* controller = CreateController(symbol, (ENUM_TIMEFRAMES)_Period, error);
      if (controller == NULL)
      {
         Print(error);
         return INIT_FAILED;
      }
      int controllersCount = ArraySize(controllers);
      ArrayResize(controllers, controllersCount + 1);
      controllers[controllersCount] = controller;
   }
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   for (int i = 0; i < ArraySize(controllers); ++i)
   {
      delete controllers[i];
   }
}

void OnTick()
{
   for (int i = 0; i < ArraySize(controllers); ++i)
   {
      controllers[i].DoTrading();
   }
}