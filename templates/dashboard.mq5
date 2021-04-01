// ProfitRobots Dashboard template v.1.6
// You can find more templates at https://github.com/sibvic/mq4-templates

#property indicator_separate_window
#property strict

enum DisplayMode
{
   Vertical,
   Horizontal
};

input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD";
input bool     Include_M1               = false;
input bool     Include_M5               = false;
input bool     Include_M15              = false;
input bool     Include_M30              = false;
input bool     Include_H1               = true;
input bool     Include_H4               = false;
input bool     Include_D1               = true;
input bool     Include_W1               = true;
input bool     Include_MN1              = false;
input color    Labels_Color             = clrWhite; // Labels color
input color    button_text_color        = Black; // Button text color
input int min_button_width = 30; // Min button width
#ifdef USE_HISTORIC
   input color    historical_Up_Color      = Green; // Historical up color
#else
   color    historical_Up_Color      = Green; // Historical up color
#endif
input color    Up_Color                 = Lime; // Up color
#ifdef USE_HISTORIC
   input color    historical_Dn_Color      = Red; // Historical down color
#else
   color    historical_Dn_Color      = Red; // Historical down color
#endif
input color    Dn_Color                 = Pink; // Down color
input color    neutral_color            = clrDarkGray; // Neutral color
input int x_shift = 900; // X coordinate
input ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER; // Corner
input DisplayMode display_mode = Vertical; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height
input bool alert_on_close = false; // Alert on bar close

#define MAX_LOOPBACK 500

string   WindowName;

#include <conditions/ACondition.mq5>

class UpCondition : public ACondition
{
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      return false;
   }
};

class DownCondition : public ACondition
{
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      return false;
   }
};

ICondition* CreateUpCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   return new UpCondition(symbol, timeframe);
}

ICondition* CreateDownCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   return new DownCondition(symbol, timeframe);
}

// Dashboard v.1.2
class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

#include <Grid/EmptyCell.mq5>
#include <Grid/LabelCell.mq5>
#include <Grid/Grid.mq5>
#include <Grid/TrendValueCellFactory.mq5>

Grid *grid;

#include <Grid/GridBuilder.mq5>
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

   GridBuilder builder(x_shift, 50, cell_height, cell_height, display_mode == Vertical, corner);
   TrendValueCellFactory* factory = new TrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory.SetNeutralColor(neutral_color);
   factory.SetButtonTextColor(button_text_color);
   builder.AddCell(factory);
   builder.SetSymbols(Pairs);

   if (Include_M1)
      builder.AddTimeframe("M1", PERIOD_M1);
   if (Include_M5)
      builder.AddTimeframe("M5", PERIOD_M5);
   if (Include_M15)
      builder.AddTimeframe("M15", PERIOD_M15);
   if (Include_M30)
      builder.AddTimeframe("M30", PERIOD_M30);
   if (Include_H1)
      builder.AddTimeframe("H1", PERIOD_H1);
   if (Include_H4)
      builder.AddTimeframe("H4", PERIOD_H4);
   if (Include_D1)
      builder.AddTimeframe("D1", PERIOD_D1);
   if (Include_W1)
      builder.AddTimeframe("W1", PERIOD_W1);
   if (Include_MN1)
      builder.AddTimeframe("MN1", PERIOD_MN1);

   grid = builder.Build();

   return(0);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   grid = NULL;
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
   grid.Draw();
   
   return 0;
}
