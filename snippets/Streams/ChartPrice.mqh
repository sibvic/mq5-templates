// Chart price cache v1.0
// iClose/iHigh/iLow/iOpen return no price for the chart symbol while an indicator
// is inside OnCalculate. The arrays passed to OnCalculate are the prices to use.

#ifndef ChartPrice_MQH
#define ChartPrice_MQH

double ChartPriceOpen[];
double ChartPriceHigh[];
double ChartPriceLow[];
double ChartPriceClose[];
int ChartPriceRates = 0;
string ChartPriceSymbol = "";
ENUM_TIMEFRAMES ChartPriceTimeframe = PERIOD_CURRENT;

class ChartPrice
{
public:
   static void Bind(const int rates, const double &open[], const double &high[], const double &low[], const double &close[])
   {
      ChartPriceRates = rates;
      ChartPriceSymbol = _Symbol;
      ChartPriceTimeframe = (ENUM_TIMEFRAMES)_Period;
      if (ArraySize(ChartPriceClose) != rates)
      {
         ArrayResize(ChartPriceOpen, rates);
         ArrayResize(ChartPriceHigh, rates);
         ArrayResize(ChartPriceLow, rates);
         ArrayResize(ChartPriceClose, rates);
      }
      ArrayCopy(ChartPriceOpen, open, 0, 0, rates);
      ArrayCopy(ChartPriceHigh, high, 0, 0, rates);
      ArrayCopy(ChartPriceLow, low, 0, 0, rates);
      ArrayCopy(ChartPriceClose, close, 0, 0, rates);
   }

   static bool Matches(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      if (ChartPriceRates <= 0)
      {
         return false;
      }
      bool symbolOk = (symbol == ChartPriceSymbol) || (symbol == _Symbol) || (StringLen(symbol) == 0);
      bool timeframeOk = (timeframe == ChartPriceTimeframe) || (timeframe == PERIOD_CURRENT);
      return symbolOk && timeframeOk;
   }

   static int Size(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      if (!Matches(symbol, timeframe))
      {
         return 0;
      }
      return ChartPriceRates;
   }

   // Index 0 is the oldest bar, the same direction as OnCalculate.
   static bool Get(const int index, double &open, double &high, double &low, double &close)
   {
      if (index < 0 || index >= ChartPriceRates)
      {
         return false;
      }
      open = ChartPriceOpen[index];
      high = ChartPriceHigh[index];
      low = ChartPriceLow[index];
      close = ChartPriceClose[index];
      return true;
   }

   // Shift 0 is the current bar.
   static bool GetSeries(const int shift, double &open, double &high, double &low, double &close)
   {
      return Get(ChartPriceRates - 1 - shift, open, high, low, close);
   }
};

#endif
