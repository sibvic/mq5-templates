// Arrows indicator v2.1

#property copyright ""
#property link      ""
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_plots 2
#property indicator_buffers 2

#define ACT_ON_SWITCH

input color up_color = Green; // Up color
input color down_color = Red; // Down color

#include <Signaler.mq5>
#include <Conditions/ACondition.mq5>
#include <Conditions/ActOnSwitchCondition.mq5>
#include <Streams/PriceStream.mq5>
#include <AlertSignal.mq5>

AlertSignal* alerts[];
Signaler* mainSignaler;

class UpAlertCondition : public ACondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
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

   bool IsPass(const int period, const datetime date)
   {
      return false;
   }
};

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

int OnInit(void)
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("...");
   IndicatorSetString(INDICATOR_SHORTNAME, "...");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   //register outputs
   int id = 2;
   PriceStream* highStream = new PriceStream(_Symbol, timeframe, PRICE_HIGH);
   PriceStream* lowStream = new PriceStream(_Symbol, timeframe, PRICE_LOW);

   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   mainSignaler = new Signaler(_Symbol, timeframe);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   {
      ICondition* upCondition = new UpAlertCondition(_Symbol, timeframe);
      ICondition* downCondition = new DownAlertCondition(_Symbol, timeframe);
      #ifdef ACT_ON_SWITCH
         ActOnSwitchCondition* upSwitch = new ActOnSwitchCondition(_Symbol, timeframe, upCondition);
         upCondition.Release();
         upCondition = upSwitch;
         ActOnSwitchCondition* downSwitch = new ActOnSwitchCondition(_Symbol, timeframe, downCondition);
         downCondition.Release();
         downCondition = downSwitch;
      #endif
      int size = ArraySize(alerts);
      ArrayResize(alerts, size + 2);
      alerts[size] = new AlertSignal(upCondition, mainSignaler);
      alerts[size + 1] = new AlertSignal(downCondition, mainSignaler);
      id = alerts[size].RegisterStreams(id, "Up", 217, up_color, highStream);
      id = alerts[size + 1].RegisterStreams(id, "Down", 218, down_color, lowStream);
   }
   lowStream.Release();
   highStream.Release();
   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   delete mainSignaler;
   mainSignaler = NULL;
   for (int i = 0; i < ArraySize(alerts); ++i)
   {
      delete alerts[i];
   }
   ArrayResize(alerts, 0);
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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      //ArrayInitialize(out, EMPTY_VALUE);
      for (int i = 0; i < ArraySize(alerts); ++i)
      {
         alerts[i].Init();
      }
   }
   int first = 0;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldIndex = rates_total - 1 - pos;
      for (int i = 0; i < ArraySize(alerts); ++i)
      {
         alerts[i].Update(oldIndex, time[pos]);
      }
   }
   return rates_total;
}