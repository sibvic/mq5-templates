// Pine-script like strategy functions
// v1.0

#ifndef PineStrategy_IMPL
#define PineStrategy_IMPL

#include <Signaler.mqh>

class PineStrategy
{
public:
   static void Entry(Signaler* signaler, string id, bool longDirection)
   {
      signaler.SendNotifications(id);
   }
   
   static void Exit(Signaler* signaler, string id, string comment)
   {
      string message = id;
      if (comment != NULL)
      {
         message = message + ": " + comment;
      }
      signaler.SendNotifications(message);
   }
   
   static double GetPositionSize()
   {
      return 0;
   }
   
   static void Close(Signaler* signaler, string id, bool when)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static void Cancel(Signaler* signaler, string id, bool when)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static void CancelAll(Signaler* signaler, bool when)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications("Cancel all");
   }
   
   static void CloseAll(Signaler* signaler, bool when, string id)
   {
      if (!when)
      {
         return;
      }
      signaler.SendNotifications(id);
   }
   
   static void CloseAll(Signaler* signaler, string comment, string alert_message, bool immediately = false, bool disable_alert = false)
   {
      if (disable_alert)
      {
         return;
      }
      string message = "Close all";
      if (alert_message != NULL && StringLen(alert_message) > 0)
      {
         message = alert_message;
      }
      else if (comment != NULL && StringLen(comment) > 0)
      {
         message = comment;
      }
      signaler.SendNotifications(message);
   }
   
   static double Equity()
   {
      return 0;
   }
   
   static int ClosedTrades()
   {
      return 0;
   }
   
   static int OpenTrades()
   {
      return 0;
   }

   static double PositionAvgPrice()
   {
      return 0;
   }
};

#endif 