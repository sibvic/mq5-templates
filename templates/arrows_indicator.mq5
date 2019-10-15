// Arrows indicator v1.1

#property copyright ""
#property link      ""
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_plots 2
#property indicator_buffers 2

input color up_color = Green; // Up color
input color down_color = Red; // Down color

#include <Signaler.mq5>
#include <Conditions/ACondition.mq5>
#include <Streams/PriceStream.mq5>
#include <AlertSignal.mq5>

AlertSignal* up;
AlertSignal* down;
Signaler* mainSignaler;

class UpAlertCondition : public ACondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return false;
   }
};

class DownAlertCondition : public ACondition
{
public:
   DownAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return false;
   }
};

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("...");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   //register outputs

   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   mainSignaler = new Signaler(_Symbol, timeframe);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   ICondition* upCondition = new UpAlertCondition(_Symbol, timeframe);
   ICondition* downCondition = new DownAlertCondition(_Symbol, timeframe);
   up = new AlertSignal(upCondition, mainSignaler);
   down = new AlertSignal(downCondition, mainSignaler);
      
   int id = 2;
   PriceStream* highStream = new PriceStream(_Symbol, timeframe, PRICE_HIGH);
   PriceStream* lowStream = new PriceStream(_Symbol, timeframe, PRICE_LOW);
   id = up.RegisterStreams(id, "Up", 217, up_color, highStream);
   id = down.RegisterStreams(id, "Down", 218, down_color, lowStream);
   lowStream.Release();
   highStream.Release();
   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   delete mainSignaler;
   mainSignaler = NULL;
   delete up;
   up = NULL;
   delete down;
   down = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   for (int pos = prev_calculated; pos < rates_total; ++pos)
   {
      int oldIndex = rates_total - 1 - pos;
      up.Update(pos);
      down.Update(pos);
   }
   return rates_total;
}