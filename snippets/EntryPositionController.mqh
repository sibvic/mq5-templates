#include <conditions/ICondition.mqh>
#include <enums/OrderSide.mqh>
#include <Signaler.mqh>

// Entry position controller v1.0

#ifndef EntryPositionController_IMP
#define EntryPositionController_IMP

class EntryPositionController
{
   bool _includeLog;
   ICondition* _condition;
   ICondition* _filterCondition;
   OrderSide _side;
   ICloseOnOppositeStrategy *_closeOnOpposite;
   Signaler* _signaler;
   IAction* _actions[];
   string _algorithmId;
   string _alertMessage;
public:
   EntryPositionController(OrderSide side, ICondition* condition, ICondition* filterCondition, 
      ICloseOnOppositeStrategy *closeOnOpposite, Signaler* signaler, 
      string algorithmId, string alertMessage)
   {
      _algorithmId = algorithmId;
      _filterCondition = filterCondition;
      if (_filterCondition != NULL)
      {
         _filterCondition.AddRef();
      }
      _signaler = signaler;
      _side = side;
      _includeLog = false;
      _condition = condition;
      _condition.AddRef();
      _closeOnOpposite = closeOnOpposite;
      _closeOnOpposite.AddRef();
   }

   ~EntryPositionController()
   {
      _closeOnOpposite.Release();
      _condition.Release();
      if (_filterCondition != NULL)
      {
         _filterCondition.Release();
      }
      
      for (int i = 0; i < ArraySize(_actions); ++i)
      {
         _actions[i].Release();
      }
   }

   void IncludeLog()
   {
      _includeLog = true;
   }

   void AddAction(IAction* action)
   {
      int count = ArraySize(_actions);
      ArrayResize(_actions, count + 1);
      _actions[count] = action;
      _actions[count].AddRef();
   }

   bool DoEntry(int period, datetime date, string& logMessage)
   {
      bool conditionPassed = _condition.IsPass(period, date);
      if (_includeLog)
      {
         logMessage = _condition.GetLogMessage(period, date) + "; Condition passed: " + (conditionPassed ? "true" : "false");
         if (_filterCondition != NULL)
         {
            logMessage += "; Filter: " + _filterCondition.GetLogMessage(period, date);
         }
      }
      if (!conditionPassed)
      {
         return false;
      }
      bool filterPassed = _filterCondition == NULL || _filterCondition.IsPass(period, date);
      if (_includeLog)
      {
         logMessage += "; Filter passed: " + (filterPassed ? "true" : "false");
      }
      if (!filterPassed)
      {
         return false;
      }
      _closeOnOpposite.DoClose(GetOppositeSide(_side));
      
      for (int i = 0; i < ArraySize(_actions); ++i)
      {
         _actions[i].DoAction(period, date);
      }
      _signaler.SendNotifications(_alertMessage);
      return true;
   }
};

#endif