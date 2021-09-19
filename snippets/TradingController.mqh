// Trade controller v3.0

#include <Trade\Trade.mqh>
#include <BreakevenController.mqh>
#include <Logic/ActionOnConditionLogic.mqh>
#include <ICloseOnOppositeStrategy.mqh>
#include <IEntryStrategy.mqh>
#include <Actions/AOrderAction.mqh>
#include <EntryPositionController.mqh>

class TradingController
{
   ENUM_TIMEFRAMES _entryTimeframe;
   ENUM_TIMEFRAMES _exitTimeframe;
   datetime _lastActionTime;
   Signaler *_signaler;
   datetime _lastEntryTime;
   datetime _lastExitTime;
   TradingCalculator *_calculator;
   ICondition* _exitLongCondition;
   ICondition* _exitShortCondition;
   IEntryStrategy *_entryStrategy;
   ActionOnConditionLogic* _actions;
   TradingMode _entryLogic;
   TradingMode _exitLogic;
   int _logFile;
   EntryPositionController* _longPositions[];
   EntryPositionController* _shortPositions[];
public:
   TradingController(TradingCalculator *calculator, 
                     ENUM_TIMEFRAMES entryTimeframe, 
                     ENUM_TIMEFRAMES exitTimeframe, 
                     ActionOnConditionLogic* actions,
                     Signaler *signaler, 
                     const string algorithmId = "")
   {
      _entryLogic = TradingModeOnBarClose;
      _exitLogic = TradingModeOnBarClose;
      _actions = actions;
      _calculator = calculator;
      _signaler = signaler;
      _entryTimeframe = entryTimeframe;
      _exitTimeframe = exitTimeframe;
      _exitLongCondition = NULL;
      _exitShortCondition = NULL;
      _logFile = -1;
   }

   ~TradingController()
   {
      if (_logFile != -1)
      {
         FileClose(_logFile);
      }
      for (int i = 0; i < ArraySize(_longPositions); ++i)
      {
         delete _longPositions[i];
      }
      ArrayResize(_longPositions, 0);
      for (int i = 0; i < ArraySize(_shortPositions); ++i)
      {
         delete _shortPositions[i];
      }
      ArrayResize(_shortPositions, 0);
      delete _actions;
      delete _entryStrategy;
      if (_exitLongCondition != NULL)
         _exitLongCondition.Release();
      if (_exitShortCondition != NULL)
         _exitShortCondition.Release();
      delete _calculator;
      delete _signaler;
   }

   void AddLongPosition(EntryPositionController* entryPos)
   {
      int size = ArraySize(_longPositions);
      ArrayResize(_longPositions, size + 1);
      _longPositions[size] = entryPos;
   }
   void AddShortPosition(EntryPositionController* entryPos)
   {
      int size = ArraySize(_shortPositions);
      ArrayResize(_shortPositions, size + 1);
      _shortPositions[size] = entryPos;
   }

   void SetPrintLog(string logFile)
   {
      _logFile = FileOpen(logFile, FILE_WRITE | FILE_CSV, ",");
      for (int i = 0; i < ArraySize(_longPositions); ++i)
      {
         _longPositions[i].IncludeLog();
      }
      for (int i = 0; i < ArraySize(_shortPositions); ++i)
      {
         _shortPositions[i].IncludeLog();
      }
   }
   void SetEntryLogic(TradingMode logicType) { _entryLogic = logicType; }
   void SetExitLogic(TradingMode logicType) { _exitLogic = logicType; }
   void SetExitLongCondition(ICondition *condition) { _exitLongCondition = condition; }
   void SetExitShortCondition(ICondition *condition) { _exitShortCondition = condition; }
   void SetEntryStrategy(IEntryStrategy *entryStrategy)
   { 
      _entryStrategy = entryStrategy; 
      _entryStrategy.AddRef(); 
   }

   void DoTrading()
   {
      int entryTradePeriod = _entryLogic == TradingModeLive ? 0 : 1;
      datetime entryTime = iTime(_calculator.GetSymbolInfo().GetSymbol(), _entryTimeframe, entryTradePeriod);
      _actions.DoLogic(entryTradePeriod, entryTime);
      string entryLongLog = "";
      string entryShortLog = "";
      string exitLongLog = "";
      string exitShortLog = "";
      if (_lastEntryTime != 0 && EntryAllowed(entryTime))
      {
         if (DoEntryLogic(entryTradePeriod, entryTime, entryLongLog, entryShortLog))
         {
            _lastActionTime = entryTime;
         }
         _lastEntryTime = entryTime;
      }
      else if (_lastEntryTime == 0)
      {
         _lastEntryTime = entryTime;
      }

      int exitTradePeriod = _exitLogic == TradingModeLive ? 0 : 1;
      datetime exitTime = iTime(_calculator.GetSymbolInfo().GetSymbol(), _exitTimeframe, exitTradePeriod);
      if (ExitAllowed(exitTime))
      {
         DoExitLogic(exitTradePeriod, exitTime, exitLongLog, exitShortLog);
         _lastExitTime = exitTime;
      }
      if (_logFile != -1 && (entryLongLog != "" || entryShortLog != "" || exitLongLog != "" || exitShortLog != ""))
      {
         FileWrite(_logFile, TimeToString(TimeCurrent()), 
            ";Entry long: " + entryLongLog, 
            ";Entry short: " + entryShortLog, 
            ";Exit long: " + exitLongLog, 
            ";Exit short: " + exitShortLog);
      }
   }
private:
   bool ExitAllowed(datetime exitTime)
   {
      return _exitLogic != TradingModeOnBarClose || _lastExitTime != exitTime;
   }

   void DoExitLogic(int exitTradePeriod, datetime date, string& longLog, string& shortLog)
   {
      bool exitLongPassed = _exitLongCondition.IsPass(exitTradePeriod, date);
      bool exitShortPassed = _exitShortCondition.IsPass(exitTradePeriod, date);
      if (_logFile != -1)
      {
         longLog = _exitLongCondition.GetLogMessage(exitTradePeriod, date) + "; Exit long executed: " + (exitLongPassed ? "true" : "false");
         shortLog = _exitShortCondition.GetLogMessage(exitTradePeriod, date) + "; Exit short executed: " + (exitShortPassed ? "true" : "false");
      }
      if (exitLongPassed)
      {
         if (_entryStrategy.Exit(BuySide) > 0)
         {
            _signaler.SendNotifications("Exit Buy");
         }
      }
      if (exitShortPassed)
      {
         if (_entryStrategy.Exit(SellSide) > 0)
         {
            _signaler.SendNotifications("Exit Sell");
         }
      }
   }

   bool EntryAllowed(datetime entryTime)
   {
      if (_entryLogic == TradingModeOnBarClose)
      {
         return _lastEntryTime != entryTime;
      }
      return _lastActionTime != entryTime;
   }
   bool DoEntryLogic(int entryTradePeriod, datetime date, string& longLog, string& shortLog)
   {
      bool positionOpened = false;
      for (int i = 0; i < ArraySize(_longPositions); ++i)
      {
         if (_longPositions[i].DoEntry(entryTradePeriod, date, longLog))
         {
            positionOpened = true;
         }
      }
      for (int i = 0; i < ArraySize(_shortPositions); ++i)
      {
         if (_shortPositions[i].DoEntry(entryTradePeriod, date, shortLog))
         {
            positionOpened = true;
         }
      }
      return positionOpened;
   }
};