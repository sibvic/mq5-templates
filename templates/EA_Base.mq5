#property copyright "Copyright © 2020, ProfitRobots"
#property link      "https://github.com/sibvic/mq5-templates"
#property description "ProfitRobots templates"
#property version   "1.0"

#property strict

#define ACT_ON_SWITCH_CONDITION
#define TAKE_PROFIT_FEATURE

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
input TradingDirection trading_side = BothSides; // What trades should be taken
input double lots_value            = 0.1; // Position size
input PositionSizeType lots_type = PositionSizeContract; // Position size type
input int slippage_points           = 3; // Slippage, in points
input bool close_on_opposite = true; // Close on opposite

input string SLSection            = ""; // == Stop loss/TakeProfit ==
input StopLossType stop_loss_type = SLPips; // Stop loss type
input double stop_loss_value            = 10; // Stop loss value
input TrailingType trailing_type = TrailingDontUse; // Use trailing
input double TrailingStep = 10; // Trailing step
input TakeProfitType take_profit_type = TPPips; // Take profit type
input double take_profit_value           = 10; // Take profit value
input double take_profit_atr_multiplicator = 1.0; // Take profit ATR Multiplicator
// input StopLimitType breakeven_type = StopLimitPips; // Trigger type for the breakeven
// input double breakeven_value = 10; // Trigger for the breakeven

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
#include <Conditions/NoCondition.mq5>
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
#include <PositionCap.mq5>
#include <TradingController.mq5>
#include <DoCloseOnOppositeStrategy.mq5>
#include <DontCloseOnOppositeStrategy.mq5>
#include <MoneyManagement/MoneyManagementStrategy.mq5>
#include <MoneyManagement/DefaultLotsProvider.mq5>
#include <MoneyManagement/PositionSizeRiskStopLossAndAmountStrategy.mq5>
#include <MoneyManagement/DefaultStopLossAndAmountStrategy.mq5>
#include <MoneyManagement/DefaultTakeProfitStrategy.mq5>
#include <MoneyManagement/RiskToRewardTakeProfitStrategy.mq5>
#include <MoneyManagement/ATRTakeProfitStrategy.mq5>

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

MoneyManagementStrategy* CreateMoneyManagementStrategy(TradingCalculator* tradingCalculator, string symbol,
   ENUM_TIMEFRAMES timeframe, bool isBuy)
{
   ILotsProvider* lots = NULL;
   switch (lots_type)
   {
      case PositionSizeRisk:
      case PositionSizeRiskCurrency:
         break;
      default:
         lots = new DefaultLotsProvider(tradingCalculator, lots_type, lots_value);
         break;
   }
   IStopLossAndAmountStrategy* sl = NULL;
   switch (stop_loss_type)
   {
      case SLDoNotUse:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitDoNotUse, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDoNotUse, stop_loss_value, isBuy);
         }
         break;
      case SLPercent:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitPercent, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPercent, stop_loss_value, isBuy);
         }
         break;
      case SLPips:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitPips, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitPips, stop_loss_value, isBuy);
         }
         break;
      case SLDollar:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitDollar, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitDollar, stop_loss_value, isBuy);
         }
         break;
      case SLAbsolute:
         {
            if (lots_type == PositionSizeRisk)
               sl = new PositionSizeRiskStopLossAndAmountStrategy(tradingCalculator, lots_value, StopLimitAbsolute, stop_loss_value, isBuy);
            else
               sl = new DefaultStopLossAndAmountStrategy(tradingCalculator, lots, StopLimitAbsolute, stop_loss_value, isBuy);
         }
         break;
   }
   ITakeProfitStrategy* tp = NULL;
   switch (take_profit_type)
   {
      case TPDoNotUse:
         tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDoNotUse, take_profit_value, isBuy);
         break;
      #ifdef TAKE_PROFIT_FEATURE
         case TPPercent:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPercent, take_profit_value, isBuy);
            break;
         case TPPips:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitPips, take_profit_value, isBuy);
            break;
         case TPDollar:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitDollar, take_profit_value, isBuy);
            break;
         case TPRiskReward:
            tp = new RiskToRewardTakeProfitStrategy(take_profit_value, isBuy);
            break;
         case TPAbsolute:
            tp = new DefaultTakeProfitStrategy(tradingCalculator, StopLimitAbsolute, take_profit_value, isBuy);
            break;
         case TPAtr:
            tp = new ATRTakeProfitStrategy(symbol, timeframe, (int)take_profit_value, take_profit_atr_multiplicator, isBuy);
            break;
      #endif
   }
   
   return new MoneyManagementStrategy(sl, tp);
}

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

   Signaler* signaler = new Signaler(symbol, timeframe);
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
               CreateTrailingAction* trailingAction = new CreateTrailingAction(trailing_start, trailing_step, actions);
               controller.AddOrderAction(trailingAction);
               trailingAction.Release();
            }
            break;
      }
   #endif

   #ifdef MARTINGALE_FEATURE
      switch (martingale_type)
      {
         case MartingaleDoNotUse:
            controller.SetShortMartingaleStrategy(new NoMartingaleStrategy());
            controller.SetLongMartingaleStrategy(new NoMartingaleStrategy());
            break;
         case MartingaleOnLoss:
            {
               PriceMovedFromTradeOpenCondition* condition = new PriceMovedFromTradeOpenCondition(symbol, timeframe, martingale_step_type, martingale_step);
               controller.SetShortMartingaleStrategy(new ActiveMartingaleStrategy(tradingCalculator, martingale_lot_sizing_type, martingale_lot_value, condition));
               controller.SetLongMartingaleStrategy(new ActiveMartingaleStrategy(tradingCalculator, martingale_lot_sizing_type, martingale_lot_value, condition));
               condition.Release();
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

   ICondition* longFilterCondition = CreateLongFilterCondition(symbol, timeframe);
   ICondition* shortFilterCondition = CreateShortFilterCondition(symbol, timeframe);

   #ifdef WITH_EXIT_LOGIC
      controller.SetExitLogic(exit_logic);
      ICondition* exitLongCondition = CreateExitLongCondition(symbol, timeframe);
      ICondition* exitShortCondition = CreateExitShortCondition(symbol, timeframe);
   #else
      ICondition* exitLongCondition = new DisabledCondition();
      ICondition* exitShortCondition = new DisabledCondition();
   #endif

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
   
   IMoneyManagementStrategy* longMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, true);
   IMoneyManagementStrategy* shortMoneyManagement = CreateMoneyManagementStrategy(tradingCalculator, symbol, timeframe, false);
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

   if (close_on_opposite)
      controller.SetCloseOnOpposite(new DoCloseOnOppositeStrategy(magic_number));
   else
      controller.SetCloseOnOpposite(new DontCloseOnOppositeStrategy());

   #ifdef POSITION_CAP_FEATURE
      if (position_cap)
      {
         controller.SetLongPositionCap(new PositionCapStrategy(BuySide, magic_number, no_of_buy_position, no_of_positions, symbol));
         controller.SetShortPositionCap(new PositionCapStrategy(SellSide, magic_number, no_of_sell_position, no_of_positions, symbol));
      }
      else
      {
         controller.SetLongPositionCap(new NoPositionCapStrategy());
         controller.SetShortPositionCap(new NoPositionCapStrategy());
      }
   #endif

   controller.SetEntryLogic(entry_logic);
//   #ifdef USE_MARKET_ORDERS
      controller.SetEntryStrategy(new MarketEntryStrategy(symbol, magic_number, slippage_points, actions));
   // #else
   //    IStream *longPrice = new LongEntryStream(symbol, timeframe);
   //    IStream *shortPrice = new ShortEntryStream(symbol, timeframe);
   //    controller.SetEntryStrategy(new PendingEntryStrategy(symbol, magic_number, slippage_points, longPrice, shortPrice, actions));
   // #endif
   if (print_log)
   {
      controller.SetPrintLog(log_file);
   }

   return controller;
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