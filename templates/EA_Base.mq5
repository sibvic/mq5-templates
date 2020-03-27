// EA base template v1.1

#property version   "1.00"
#property description "ProfitRobots templates: https://github.com/sibvic/mq5-templates"
#property strict

#define ACT_ON_SWITCH_CONDITION

#include <enums/OrderSide.mq5>

#ifndef tradeManager_INSTANCE
#define tradeManager_INSTANCE
#include <Trade\Trade.mqh>
CTrade tradeManager;
#endif

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

#include <enums/StopLimitType.mq5>
#include <enums/PositionSizeType.mq5>

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
input TradingDirection trading_side = BothSides; // What trades should be taken
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
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
//#import "AdvancedNotificationsLib.dll"
//void AdvancedAlert(string key, string text, string instrument, string timeframe);
//#import

#include <Conditions/TradingTimeCondition.mq5>
#include <Conditions/DisabledCondition.mq5>
#include <Conditions/AndCondition.mq5>
#include <Conditions/ACondition.mq5>
#ifdef ACT_ON_SWITCH_CONDITION
#include <Conditions/ActOnSwitchCondition.mq5>
#endif
#include <InstrumentInfo.mq5>
#include <TradesIterator.mq5>
#include <TradingCalculator.mq5>
#include <MoneyManagement.mq5>
#include <OrdersIterator.mq5>
#include <TradingCommands.mq5>
#include <TrailingController.mq5>
#include <NetStopLoss.mq5>
#include <MarketOrderBuilder.mq5>
#include <PositionCap.mq5>
#include <TradingController.mq5>

class EntryLongCondition : public ACondition
{
public:
   EntryLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      // TODO: implement
      return false;
   }
};

class EntryShortCondition : public ACondition
{
public:
   EntryShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      // TODO: implement
      return false;
   }
};

ICondition* CreateLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   AndCondition* condition = new AndCondition();
   condition.Add(new EntryLongCondition(symbol, timeframe), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else 
      return (ICondition*) condition;
   #endif
}

ICondition* CreateShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == LongSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }

   AndCondition* condition = new AndCondition();
   condition.Add(new EntryShortCondition(symbol, timeframe), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else 
      return (ICondition*) condition;
   #endif
}

TradingController* controllers[];

TradingController* CreateController(const string symbol, ENUM_TIMEFRAMES tf, string &error)
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
   
   TradingCalculator *tradeCalculator = new TradingCalculator(symbol);
   Signaler *signaler = new Signaler(symbol, tf);
   TradingController* tradingController = new TradingController(signaler, tradeCalculator, tf, entry_type, allow_trading);
   tradingController.SetTradingTime(tradingTime)
      .SetCloseOnOpposite(close_on_opposite)
      .SetSlippage(slippage_points)
      .SetMagicNumber(magic_number)
      .SetBreakevenType(breakeven_type, breakeven_value)
      .SetTrailing(new TrailingLogic(tradeCalculator, trailing_type, TrailingStep, 0, tf))
      .SetNetStopLossStrategy(new NoNetStopLossStrategy());
   IPositionCapStrategy* positionCap = use_position_cap 
      ? (IPositionCapStrategy*)new PositionCapStrategy(max_positions)
      : (IPositionCapStrategy*)new NoPositionCapStrategy();
   tradingController.SetPositionCap(positionCap);

   ICondition *longCondition = CreateLongCondition(symbol, tf);
   ICondition *shortCondition = CreateShortCondition(symbol, tf);
   IMoneyManagementStrategy *longMoneyManagement = new LongMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   IMoneyManagementStrategy *shortMoneyManagement = new ShortMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   if (LogicType == DirectLogic)
   {
      tradingController.SetLongCondition(longCondition);
      tradingController.SetShortCondition(shortCondition);
      tradingController.SetLongMoneyManagementStrategy(longMoneyManagement);
      tradingController.SetShortMoneyManagementStrategy(shortMoneyManagement);
   }
   else
   {
      tradingController.SetLongCondition(shortCondition);
      tradingController.SetShortCondition(longCondition);
      tradingController.SetLongMoneyManagementStrategy(shortMoneyManagement);
      tradingController.SetShortMoneyManagementStrategy(longMoneyManagement);
   }
   
   return tradingController;
}

int OnInit()
{
   string error;
   string sym_arr[];
   if (symbols != "")
   {
      StringSplit(symbols, ',', sym_arr);
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
      TradingController* controller = CreateController(symbol, (ENUM_TIMEFRAMES)_Period, error);
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