// Colored fill v2.1
#include <PineScriptUtils.mqh>
#include <Streams/Interfaces/TIStream.mqh>

#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredTopBottomFill
{
   double p1[];
   double p2[];
   int colorsCount;
   uint topColor;
   uint bottomColor;
   int streamIndex;
   double top;
   double bottom;
public:
   ColoredTopBottomFill(int streamIndex, double top, double bottom, uint topColor, uint bottomColor)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      this.top = top;
      this.bottom = bottom;
      this.topColor = topColor;
      this.bottomColor = bottomColor;
   }
   ~ColoredTopBottomFill()
   {
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }

   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, GetColorOnly(topColor));
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, GetColorOnly(topColor));
      return id + 2;
   }
   
   void Set(int period, double value1, double value2)
   {
      if (value1 == EMPTY_VALUE || value2 == EMPTY_VALUE)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      double sum = value1 + value2;
      double avgValue = sum == 0 ? 0 : sum / 2;
      if (avgValue > top || avgValue < bottom)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
};
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   uint upColor;
   uint dnColor;
   uint topColor;
   uint bottomColor;
   int streamIndex;
   TIStream<double>* top;
   TIStream<double>* bottom;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      top = NULL;
      bottom = NULL;
   }
   ~ColoredFill()
   {
      if (top != NULL)
      {
         top.Release();
      }
      if (bottom != NULL)
      {
         bottom.Release();
      }
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void SetTopBottom(TIStream<double>* top, TIStream<double>* bottom, int topColor, int bottomColor)
   {
      this.top = top;
      top.AddRef();
      this.bottom = bottom;
      bottom.AddRef();
      this.topColor = topColor;
      this.bottomColor = bottomColor;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      clr = GetColorOnly(clr);
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, dnColor);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, uint clr = INT_MAX)
   {
      int transp = GetTranparency(clr);
      if (clr == INT_MAX || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE || transp == 100)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      value1 = LimitValue(period, value1);
      value2 = LimitValue(period, value2);
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
private:
   double LimitValue(int pos, double value)
   {
      if (top == NULL || bottom == NULL)
      {
         return value;
      }
      double topValue[1];
      if (!top.GetValues(pos, 1, topValue))
      {
         return value;
      }
      double bottomValue[1];
      if (!bottom.GetValues(pos, 1, bottomValue))
      {
         return value;
      }
      if (value > topValue[0])
      {
         return topValue[0];
      }
      if (value < bottomValue[0])
      {
         return bottomValue[0];
      }
      return value;
   }   
};
#endif