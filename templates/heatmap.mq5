#property version   "1.0"
#property indicator_separate_window
#property strict
#define rows 9
#define plots (rows * 3)
#property indicator_plots plots
#property indicator_buffers plots

input bool Include_M1 = false; // Include M1
input bool Include_M5 = false; // Include M5
input bool Include_M15 = false; // Include M15
input bool Include_M30 = false; // Include M30
input bool Include_H1 = true; // Include H1
input bool Include_H4 = false; // Include H4
input bool Include_D1 = true; // Include D1
input bool Include_W1 = true; // Include W1
input bool Include_MN1 = false; // Include MN1
input color up_color = Green; // Up color
input color dn_color = Red; // Down color
input color ne_color = Gray; // Neutral color
input int bars_limit = 1000; // Bars limit

#include <HeatMapValueCalculator.mqh>

IHeatMapValueCalculator* conditions[];

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

#include <Conditions/ACondition.mqh>

class LongCondition : public ACondition
{
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   ~LongCondition()
   {
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      //TODO: implement
      return false;
   }
};

class ShortCondition : public ACondition
{
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   ~ShortCondition()
   {
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      //TODO: implement
      return false;
   }
};

int CreateHeatmap(int id, int index, string name, ICondition* longCondition, ICondition* shortCondition)
{
   HeatMapValueCalculator* calc = new HeatMapValueCalculator(index + 1, longCondition, shortCondition);
   longCondition.Release();
   shortCondition.Release();
   conditions[index] = calc;
   return calc.RegisterStreams(id, up_color, dn_color, ne_color, name);
}

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("...");
   IndicatorSetString(INDICATOR_SHORTNAME, "...");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int size = ArraySize(conditions);
   ArrayResize(conditions, size + rows);

   int id = 0;
   int index = rows - 1;
   if (Include_M1)
   {
      id = CreateHeatmap(id, index--, "M1", 
         new LongCondition(_Symbol, PERIOD_M1), 
         new ShortCondition(_Symbol, PERIOD_M1));
   }
   if (Include_M5)
   {
      id = CreateHeatmap(id, index--, "M5", 
         new LongCondition(_Symbol, PERIOD_M5), 
         new ShortCondition(_Symbol, PERIOD_M5));
   }
   if (Include_M15)
   {
      id = CreateHeatmap(id, index--, "M15", 
         new LongCondition(_Symbol, PERIOD_M15), 
         new ShortCondition(_Symbol, PERIOD_M15));
   }
   if (Include_M30)
   {
      id = CreateHeatmap(id, index--, "M30", 
         new LongCondition(_Symbol, PERIOD_M30), 
         new ShortCondition(_Symbol, PERIOD_M30));
   }
   if (Include_H1)
   {
      id = CreateHeatmap(id, index--, "H1", 
         new LongCondition(_Symbol, PERIOD_H1), 
         new ShortCondition(_Symbol, PERIOD_H1));
   }
   if (Include_H4)
   {
      id = CreateHeatmap(id, index--, "H4", 
         new LongCondition(_Symbol, PERIOD_H4), 
         new ShortCondition(_Symbol, PERIOD_H4));
   }
   if (Include_D1)
   {
      id = CreateHeatmap(id, index--, "D1", 
         new LongCondition(_Symbol, PERIOD_D1), 
         new ShortCondition(_Symbol, PERIOD_D1));
   }
   if (Include_W1)
   {
      id = CreateHeatmap(id, index--, "W1", 
         new LongCondition(_Symbol, PERIOD_W1), 
         new ShortCondition(_Symbol, PERIOD_W1));
   }
   if (Include_MN1)
   {
      id = CreateHeatmap(id, index--, "MN1", 
         new LongCondition(_Symbol, PERIOD_MN1), 
         new ShortCondition(_Symbol, PERIOD_MN1));
   }
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   for (int i = 0; i < ArraySize(conditions); ++i)
   {
      delete conditions[i];
   }
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      //ArrayInitialize(out, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      for (int conditionIndex = 0; conditionIndex < ArraySize(conditions); ++conditionIndex)
      {
         if (conditions[conditionIndex] != NULL)
         {
            conditions[conditionIndex].UpdateValue(oldPos);
         }
      }
   }
   return rates_total;
}