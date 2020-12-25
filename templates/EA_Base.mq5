#property copyright "Copyright © 2020, ProfitRobots"
#property link      "https://github.com/sibvic/mq5-templates"
#property description "ProfitRobots templates"
#property version   "1.0"

#property strict

#define ACT_ON_SWITCH_CONDITION
#define TAKE_PROFIT_FEATURE
#define STOP_LOSS_FEATURE
#define MARTINGALE_FEATURE
#define ADVANCED_ALERTS
#define USE_MARKET_ORDERS
#define TRADING_TIME_FEATURE
#define WITH_EXIT_LOGIC
#define NET_STOP_LOSS_FEATURE
#define NET_TAKE_PROFIT_FEATURE

#include <enums/OrderSide.mq5>

#ifndef tradeManager_INSTANCE
#define tradeManager_INSTANCE
#include <Trade\Trade.mqh>
CTrade tradeManager;
#endif

enum TradingMode
{
   TradingModeOnBarClose, // Entry on candle close
   TradingModeLive // Entry on tick
};

enum TradingDirection
{
   LongSideOnly, // Long only
   ShortSideOnly, // Short only
   BothSides // Both
};

#include <enums/StopLimitType.mq5>
#include <enums/PositionSizeType.mq5>
#include <enums/StopLossType.mq5>
#include <enums/TakeProfitType.mq5>

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
input TradingMode entry_logic = TradingModeOnBarClose; // Entry type
#ifdef WITH_EXIT_LOGIC
   input TradingMode exit_logic = TradingModeOnBarClose; // Exit type
#endif
input TradingDirection trading_side = BothSides; // What trades should be taken
input double lots_value            = 0.1; // Position size
input PositionSizeType lots_type = PositionSizeContract; // Position size type
input int slippage_points           = 3; // Slippage, in points
input bool close_on_opposite = true; // Close on opposite

input string SLSection            = ""; // == Stop loss/TakeProfit ==
input StopLossType stop_loss_type = SLPips; // Stop loss type
input double stop_loss_value            = 10; // Stop loss value
input TrailingType trailing_type = TrailingDontUse; // Use trailing
input double trailing_start = 0; // Min distance to order to activate the trailing
input double trailing_step = 10; // Trailing step
input TakeProfitType take_profit_type = TPPips; // Take profit type
input double take_profit_value           = 10; // Take profit value
input double take_profit_atr_multiplicator = 1.0; // Take profit ATR Multiplicator
// input StopLimitType breakeven_type = StopLimitPips; // Trigger type for the breakeven
// input double breakeven_value = 10; // Trigger for the breakeven

input string PositionCapSection = ""; // == Position cap ==
input bool use_position_cap = true; // Use position cap?
input int max_positions = 2; // Max positions

enum MartingaleType
{
   MartingaleDoNotUse, // Do not use
   MartingaleOnLoss // Open another position on loss
};
enum MartingaleLotSizingType
{
   MartingaleLotSizingNo, // No lot sizing
   MartingaleLotSizingMultiplicator, // Using miltiplicator
   MartingaleLotSizingAdd // Addition
};
enum MartingaleStepSizeType
{
   MartingaleStepSizePips, // Pips
   MartingaleStepSizePercent, // %
};
#ifdef MARTINGALE_FEATURE
   input string MartingaleSection = ""; // == Martingale type ==
   input MartingaleType martingale_type = MartingaleDoNotUse; // Martingale type
   input MartingaleLotSizingType martingale_lot_sizing_type = MartingaleLotSizingNo; // Martingale lot sizing type
   input double martingale_lot_value = 1.5; // Matringale lot sizing value
   MartingaleStepSizeType martingale_step_type = MartingaleStepSizePips; // Step unit
   input double martingale_step = 50; // Open matringale position step
   input int max_longs = 5; // Max long positions
   input int max_shorts = 5; // Max short positions
#endif

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
input PositionDirection logic_direction = DirectLogic; // Logic type
input string StartTime = "000000"; // Start time in hhmmss format
input string EndTime = "235959"; // End time in hhmmss format
input bool LimitWeeklyTime = false; // Weekly time
input DayOfWeek WeekStartDay = DayOfWeekSunday; // Start day
input string WeekStartTime = "000000"; // Start time in hhmmss format
input DayOfWeek WeekStopDay = DayOfWeekSaturday; // Stop day
input string WeekStopTime = "235959"; // Stop time in hhmmss format
input bool MandatoryClosing = false; // Mandatory closing for non-trading time
input bool print_log = false; // Print decisions into the log
input string log_file = "log.csv"; // Log file name

//Signaler v 1.4
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
#ifdef ADVANCED_ALERTS
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#endif

#include <Conditions/TradingTimeCondition.mq5>
#include <Conditions/DisabledCondition.mq5>
#include <Conditions/AndCondition.mq5>
#include <Conditions/ACondition.mq5>
#include <Conditions/NoCondition.mq5>
#include <Conditions/NotCondition.mq5>
#ifdef ACT_ON_SWITCH_CONDITION
#include <Conditions/ActOnSwitchCondition.mq5>
#endif
#include <Streams/IStream.mq5>
#include <MarketEntryStrategy.mq5>
#include <InstrumentInfo.mq5>
#include <TradesIterator.mq5>
#include <TradingCalculator.mq5>
#include <OrdersIterator.mq5>
#include <TradingCommands.mq5>
#include <TrailingController.mq5>
#include <NetStopLoss.mq5>
#include <MarketOrderBuilder.mq5>
#include <conditions/PositionLimitHitCondition.mq5>
#include <Actions/EntryAction.mq5>
#include <Actions/CreateTrailingAction.mq5>
#include <TradingController.mq5>
#include <DoCloseOnOppositeStrategy.mq5>
#include <DontCloseOnOppositeStrategy.mq5>
#include <EntryPositionController.mq5>
#include <MoneyManagement/functions.mq5>

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

ICondition* CreateLongFilterCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }
   AndCondition* condition = new AndCondition();
   condition.Add(new NoCondition(), false);
   return condition;
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

ICondition* CreateShortFilterCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == LongSideOnly)
   {
      return (ICondition *)new DisabledCondition();
   }
   AndCondition* condition = new AndCondition();
   condition.Add(new NoCondition(), false);
   return condition;
}

ICondition* CreateExitLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   AndCondition* condition = new AndCondition();
   condition.Add(new DisabledCondition(), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else
      return (ICondition *)condition;
   #endif
}

ICondition* CreateExitShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   AndCondition* condition = new AndCondition();
   condition.Add(new DisabledCondition(), false);
   #ifdef ACT_ON_SWITCH_CONDITION
      ActOnSwitchCondition* switchCondition = new ActOnSwitchCondition(symbol, timeframe, (ICondition*) condition);
      condition.Release();
      return switchCondition;
   #else
      return (ICondition *)condition;
   #endif
}

#ifdef MARTINGALE_FEATURE
void CreateMartingale(TradingCalculator* tradingCalculator, string symbol, ENUM_TIMEFRAMES timeframe, IEntryStrategy* entryStrategy, 
   OrderHandlers* orderHandlers, ActionOnConditionLogic* actions)
{
   CustomLotsProvider* lots = new CustomLotsProvider();

   IStopLossStrategy* stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, true, stop_loss_type, stop_loss_value, 0/*stop_loss_atr_multiplicator*/);
   ITakeProfitStrategy* tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, true, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IMoneyManagementStrategy* longMoneyManagement = new MoneyManagementStrategy(lots, stopLoss, tp);
   IAction* openLongAction = new EntryAction(entryStrategy, BuySide, longMoneyManagement, "", orderHandlers, true);
   
   stopLoss = CreateStopLossStrategyForLots(lots, tradingCalculator, symbol, timeframe, false, stop_loss_type, stop_loss_value, 0/*stop_loss_atr_multiplicator*/);
   tp = CreateTakeProfitStrategy(tradingCalculator, symbol, timeframe, false, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IMoneyManagementStrategy* shortMoneyManagement = new MoneyManagementStrategy(lots, stopLoss, tp);
   IAction* openShortAction = new EntryAction(entryStrategy, SellSide, shortMoneyManagement, "", orderHandlers, true);

   CreateMartingaleAction* martingaleAction = new CreateMartingaleAction(lots, martingale_lot_sizing_type, martingale_lot_value, 
      martingale_step, openLongAction, openShortAction, max_longs, max_shorts, actions);
   openLongAction.Release();
   openShortAction.Release();
   
   martingaleAction.RestoreActions(_Symbol, magic_number);
   orderHandlers.AddOrderAction(martingaleAction);
   martingaleAction.Release();
}
#endif

TradingController* controllers[];

TradingController* CreateController(const string symbol, ENUM_TIMEFRAMES timeframe, string &error)
{
   #ifdef TRADING_TIME_FEATURE
      ICondition* tradingTimeCondition = CreateTradingTimeCondition(start_time, stop_time, use_weekly_timing,
         week_start_day, week_start_time, week_stop_day, 
         week_stop_time, error);
      if (tradingTimeCondition == NULL)
         return NULL;
   #endif

   TradingCalculator* tradingCalculator = TradingCalculator::Create(symbol);
   if (!tradingCalculator.IsLotsValid(lots_value, lots_type, error))
   {
      #ifdef TRADING_TIME_FEATURE
      tradingTimeCondition.Release();
      #endif
      delete tradingCalculator;
      return NULL;
   }
   OrderHandlers* orderHandlers = new OrderHandlers();

   Signaler* signaler = new Signaler(symbol, timeframe);
   signaler.SetPopupAlert(Popup_Alert);
   signaler.SetEmailAlert(Email_Alert);
   signaler.SetPlaySound(Play_Sound, Sound_File);
   signaler.SetNotificationAlert(Notification_Alert);
   #ifdef ADVANCED_ALERTS
   signaler.SetAdvancedAlert(Advanced_Alert, Advanced_Key);
   #endif
   signaler.SetMessagePrefix(symbol + "/" + signaler.GetTimeframeStr() + ": ");
   
   TradingController* controller = new TradingController(tradingCalculator, timeframe, timeframe, signaler);
   
   ActionOnConditionLogic* actions = new ActionOnConditionLogic();
   controller.SetActions(actions);
   //controller.SetECNBroker(ecn_broker);
   
   //if (breakeven_type != StopLimitDoNotUse)
   {
      #ifndef USE_NET_BREAKEVEN
         // MoveStopLossOnProfitOrderAction* orderAction = new MoveStopLossOnProfitOrderAction(breakeven_type, breakeven_value, breakeven_level, signaler, actions);
         // controller.AddOrderAction(orderAction);
         // orderAction.Release();
      #endif
   }

   #ifdef STOP_LOSS_FEATURE
      switch (trailing_type)
      {
         case TrailingDontUse:
            break;
      #ifdef INDICATOR_BASED_TRAILING
         case TrailingIndicator:
            break;
      #endif
         case TrailingPips:
            {
               CreateTrailingAction* trailingAction = new CreateTrailingAction(trailing_start, false, trailing_step, actions);
               controller.AddOrderAction(trailingAction);
               trailingAction.Release();
            }
            break;
      }
   #endif

   #ifdef USE_MARKET_ORDERS
      IEntryStrategy* entryStrategy = new MarketEntryStrategy(symbol, magic_number, slippage_points, actions);
   #else
      // AStream *longPrice = new LongEntryStream(symbol, timeframe);
      // AStream *shortPrice = new ShortEntryStream(symbol, timeframe);
      // IEntryStrategy* entryStrategy = new PendingEntryStrategy(symbol, magic_number, slippage_points, longPrice, shortPrice, actions, ecn_broker);
   #endif
   #ifdef MARTINGALE_FEATURE
      switch (martingale_type)
      {
         case MartingaleOnLoss:
            {
               CreateMartingale(tradingCalculator, symbol, timeframe, entryStrategy, orderHandlers, actions);
            }
            break;
      }
   #endif

   AndCondition* longCondition = new AndCondition();
   longCondition.Add(CreateLongCondition(symbol, timeframe), false);
   AndCondition* shortCondition = new AndCondition();
   shortCondition.Add(CreateShortCondition(symbol, timeframe), false);
   #ifdef TRADING_TIME_FEATURE
      longCondition.Add(tradingTimeCondition, true);
      shortCondition.Add(tradingTimeCondition, true);
      tradingTimeCondition.Release();
   #endif

   AndCondition* longFilterCondition = new AndCondition();
   longFilterCondition.Add(CreateLongFilterCondition(symbol, timeframe), false);
   AndCondition* shortFilterCondition = new AndCondition();
   shortFilterCondition.Add(CreateShortFilterCondition(symbol, timeframe), false);

   #ifdef WITH_EXIT_LOGIC
      controller.SetExitLogic(exit_logic);
      ICondition* exitLongCondition = CreateExitLongCondition(symbol, timeframe);
      ICondition* exitShortCondition = CreateExitShortCondition(symbol, timeframe);
   #else
      ICondition* exitLongCondition = new DisabledCondition();
      ICondition* exitShortCondition = new DisabledCondition();
   #endif
   if (use_position_cap)
   {
      ICondition* buyLimitCondition = new PositionLimitHitCondition(BuySide, magic_number, max_positions, max_positions, symbol);
      ICondition* sellLimitCondition = new PositionLimitHitCondition(SellSide, magic_number, max_positions, max_positions, symbol);
      longFilterCondition.Add(new NotCondition(buyLimitCondition), false);
      shortFilterCondition.Add(new NotCondition(sellLimitCondition), false);
      buyLimitCondition.Release();
      sellLimitCondition.Release();
   }
   ICloseOnOppositeStrategy* closeOnOpposite = close_on_opposite 
      ? (ICloseOnOppositeStrategy*)new DoCloseOnOppositeStrategy(slippage_points, magic_number)
      : (ICloseOnOppositeStrategy*)new DontCloseOnOppositeStrategy();
   EntryPositionController* longPosition = new EntryPositionController(BuySide, longCondition, longFilterCondition, 
      closeOnOpposite, signaler, "", "Buy");
   EntryPositionController* shortPosition = new EntryPositionController(SellSide, shortCondition, shortFilterCondition,
      closeOnOpposite, signaler, "", "Sell");
   longCondition.Release();
   shortCondition.Release();
   longFilterCondition.Release();
   shortFilterCondition.Release();
   closeOnOpposite.Release();

   switch (logic_direction)
   {
      case DirectLogic:
         controller.SetLongCondition(longCondition);
         controller.SetLongFilterCondition(longFilterCondition);
         controller.SetShortCondition(shortCondition);
         controller.SetShortFilterCondition(shortFilterCondition);
         controller.SetExitLongCondition(exitLongCondition);
         controller.SetExitShortCondition(exitShortCondition);
         break;
      case ReversalLogic:
         controller.SetLongCondition(shortCondition);
         controller.SetLongFilterCondition(shortFilterCondition);
         controller.SetShortCondition(longCondition);
         controller.SetShortFilterCondition(longFilterCondition);
         controller.SetExitLongCondition(exitShortCondition);
         controller.SetExitShortCondition(exitLongCondition);
         break;
   }
   longFilterCondition.Release();
   shortFilterCondition.Release();
   #ifdef TRADING_TIME_FEATURE
      if (mandatory_closing)
      {
         NotCondition* condition = new NotCondition(tradingTimeCondition);
         IAction* action = new CloseAllAction(magic_number, slippage_points);
         actions.AddActionOnCondition(action, condition);
         action.Release();
         condition.Release();
      }
   #endif
   
   IMoneyManagementStrategy* longMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, true
      , lots_type, lots_value, stop_loss_type, stop_loss_value, 1, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   IMoneyManagementStrategy* shortMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, false
      , lots_type, lots_value, stop_loss_type, stop_loss_value, 1, take_profit_type, take_profit_value, take_profit_atr_multiplicator);
   controller.AddLongMoneyManagement(longMoneyManagement);
   controller.AddShortMoneyManagement(shortMoneyManagement);

   #ifdef NET_STOP_LOSS_FEATURE
      if (net_stop_loss_type != StopLimitDoNotUse)
      {
         MoveNetStopLossAction* action = new MoveNetStopLossAction(tradingCalculator, net_stop_loss_type, net_stop_loss_value, signaler, magic_number);
         #ifdef USE_NET_BREAKEVEN
            if (breakeven_type != StopLimitDoNotUse)
            {
               //TODO: use breakeven_type as well
               action.SetBreakeven(breakeven_value, breakeven_level);
            }
         #endif

         NoCondition* condition = new NoCondition();
         actions.AddActionOnCondition(action, condition);
         action.Release();
      }
   #endif
   #ifdef NET_TAKE_PROFIT_FEATURE
      if (net_take_profit_type != StopLimitDoNotUse)
      {
         IAction* action = new MoveNetTakeProfitAction(tradingCalculator, net_take_profit_type, net_take_profit_value, signaler, magic_number);
         NoCondition* condition = new NoCondition();
         actions.AddActionOnCondition(action, condition);
         action.Release();
      }
   #endif

   controller.SetEntryLogic(entry_logic);
   controller.SetEntryStrategy(entryStrategy);
   if (print_log)
   {
      controller.SetPrintLog(log_file);
   }

   return controller;
}

OrderHandlers* orderHandlers;
int OnInit()
{
   orderHandlers = new OrderHandlers();
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
   orderHandlers.Clear();
   orderHandlers.Release();
   for (int i = 0; i < ArraySize(controllers); ++i)
   {
      delete controllers[i];
   }
   int size = ArraySize(controllers);
   ArrayResize(controllers, 0);
}

void OnTick()
{
   for (int i = 0; i < ArraySize(controllers); ++i)
   {
      controllers[i].DoTrading();
   }
}