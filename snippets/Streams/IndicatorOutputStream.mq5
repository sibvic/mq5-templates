#include <ABaseStream.mq5>

// IndicatorOutputStream v3.0

#ifndef IndicatorOutputStream_IMP
#define IndicatorOutputStream_IMP

class IndicatorOutputStream : public ABaseStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 0, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id + 0, PLOT_LABEL, name);
      return id + 1;
   }
   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[period + i];
      }
      return true;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[size - 1 - period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period - i];
      }
      return true;
   }
};
#endif