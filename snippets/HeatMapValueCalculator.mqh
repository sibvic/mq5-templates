// Heatmap value calculator v1.0

#include <Conditions/ICondition.mqh>

#ifndef IHeatMapValueCalculator_IMP
#define IHeatMapValueCalculator_IMP

class IHeatMapValueCalculator
{
public:
   virtual void UpdateValue(const int period) = 0;
};

class StreamOnCondition
{
   ICondition* _condition;
   double _stream[];
   double _value;
public:
   StreamOnCondition(ICondition* condition, double value)
   {
      _value = value;
      _condition = condition;
      _condition.AddRef();
   }

   ~StreamOnCondition()
   {
      _condition.Release();
   }

   int RegisterStreams(int id, string name, color clr)
   {
      SetIndexBuffer(id, _stream, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id, PLOT_LABEL, name);
      ++id;

      return id;
   }

   void Set(int period, datetime date)
   {
      int index = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1 - period;
      _stream[index] = _condition.IsPass(period, date) ? _value : EMPTY_VALUE;
   }
};

class MultiHeatMapValueCalculator : public IHeatMapValueCalculator
{
   double _value;
   StreamOnCondition* _streams[];
public:
   MultiHeatMapValueCalculator(const double value)
   {
      _value = value;
   }

   ~MultiHeatMapValueCalculator()
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         delete _streams[i];
      }
      ArrayResize(_streams, 0);
   }

   int RegisterStreams(int id, color clr, ICondition* condition, string name)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      _streams[size] = new StreamOnCondition(condition, _value);
      return _streams[size].RegisterStreams(id, name, clr);
   }

   void UpdateValue(const int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         StreamOnCondition* item = _streams[i];
         item.Set(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period));
      }
   }
};

class HeatMapValueCalculator : public IHeatMapValueCalculator
{
   double _value;
   ICondition* _upCondition;
   ICondition* _downCondition;
   double up[];
   double dn[];
   double nt[];
public:
   HeatMapValueCalculator(const double value, ICondition* upCondition, ICondition* downCondition)
   {
      _upCondition = upCondition;
      _upCondition.AddRef();
      _downCondition = downCondition;
      _downCondition.AddRef();
      _value = value;
   }

   ~HeatMapValueCalculator()
   {
      _upCondition.Release();
      _downCondition.Release();
   }

   int RegisterStreams(int id, color upClor, color downColor, color neutralColor, string name)
   {
      SetIndexBuffer(id, nt, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, neutralColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " N");
      ++id;

      SetIndexBuffer(id, up, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, upClor);
      PlotIndexSetString(id, PLOT_LABEL, name + " U");
      ++id;

      SetIndexBuffer(id, dn, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, downColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " D");
      ++id;

      return id;
   }

   void UpdateValue(const int period)
   {
      int index = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1 - period;
      up[index] = EMPTY_VALUE;
      dn[index] = EMPTY_VALUE;
      nt[index] = EMPTY_VALUE;
      if (_upCondition.IsPass(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period)))
         up[index] = _value;
      else if (_downCondition.IsPass(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period)))
         dn[index] = _value;
      else
         nt[index] = _value;
   }
};

class SingleHeatMapValueCalculator : public IHeatMapValueCalculator
{
   double _value;
   ICondition* _condition;
   double pos[];
   double nt[];
public:
   SingleHeatMapValueCalculator(const double value, ICondition* condition)
   {
      _condition = condition;
      _condition.AddRef();
      _value = value;
   }

   ~SingleHeatMapValueCalculator()
   {
      _condition.Release();
   }

   int RegisterStreams(int id, color positiveColor, color neutralColor, string name)
   {
      SetIndexBuffer(id, pos, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, positiveColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " P");
      ++id;

      SetIndexBuffer(id, nt, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_ARROW, 110);
      PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, neutralColor);
      PlotIndexSetString(id, PLOT_LABEL, name + " N");
      ++id;

      return id;
   }

   void UpdateValue(const int period)
   {
      int index = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1 - period;
      pos[index] = EMPTY_VALUE;
      nt[index] = EMPTY_VALUE;
      if (_condition.IsPass(period, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period)))
         pos[index] = _value;
      else
         nt[index] = _value;
   }
};

#endif