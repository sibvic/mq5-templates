//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property version   "1.0"
#property indicator_separate_window
#property strict
#define rows 3
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

#include <HeatMapValueCalculator.mq5>
#include <streams/HABarStream.mq5> 

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

#include <Conditions/ACondition.mq5>

class LongCondition : public ACondition
{
   HABarStream* _ha;
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe, HABarStream* stream)
      :ACondition(symbol, timeframe)
   {
      _ha = stream;
      _ha.AddRef();
   }

   ~LongCondition()
   {
      _ha.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double open, high, low, close;
      if (!_ha.GetValues(period, open, high, low, close))
      {
         return false;
      }
      return open < close;
   }
};

class ShortCondition : public ACondition
{
   HABarStream* _ha;
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe, HABarStream* stream)
      :ACondition(symbol, timeframe)
   {
      _ha = stream;
      _ha.AddRef();
   }

   ~ShortCondition()
   {
      _ha.Release();
   }

   bool IsPass(const int period, const datetime date)
   {
      int index = period == 0 ? 0 : iBarShift(_symbol, _timeframe, date);
      double open, high, low, close;
      if (!_ha.GetValues(period, open, high, low, close))
      {
         return false;
      }
      return open > close;
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

HABarStream* ha[];

int Create(int id, ENUM_TIMEFRAMES tf, int index, string name)
{
   int size = ArraySize(ha);
   ArrayResize(ha, size + 1);
   ha[size] = new HABarStream(_Symbol, tf);
   id = CreateHeatmap(id, index, name, 
      new LongCondition(_Symbol, tf, ha[size]), 
      new ShortCondition(_Symbol, tf, ha[size]));
   return id;
}

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("HABTF");
   IndicatorSetString(INDICATOR_SHORTNAME, "HABTF");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int size = ArraySize(conditions);
   ArrayResize(conditions, size + rows);

   int id = 0;
   int index = rows - 1;
   if (Include_M1)
   {
      id = Create(id, PERIOD_M1, index--, "M1");
   }
   if (Include_M5)
   {
      id = Create(id, PERIOD_M5, index--, "M5");
   }
   if (Include_M15)
   {
      id = Create(id, PERIOD_M15, index--, "M15");
   }
   if (Include_M30)
   {
      id = Create(id, PERIOD_M30, index--, "M30");
   }
   if (Include_H1)
   {
      id = Create(id, PERIOD_H1, index--, "H1");
   }
   if (Include_H4)
   {
      id = Create(id, PERIOD_H4, index--, "H4");
   }
   if (Include_D1)
   {
      id = Create(id, PERIOD_D1, index--, "D1");
   }
   if (Include_W1)
   {
      id = Create(id, PERIOD_W1, index--, "W1");
   }
   if (Include_MN1)
   {
      id = Create(id, PERIOD_MN1, index--, "MN1");
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
   for (int i = 0; i < ArraySize(ha); ++i)
   {
      ha[i].Refresh();
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      for (int conditionIndex = 0; conditionIndex < ArraySize(conditions); ++conditionIndex)
      {
         conditions[conditionIndex].UpdateValue(oldPos);
      }
   }
   return rates_total;
}