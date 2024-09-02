// Colored fill v1.0

#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
   double p1[];
   double p2[];
   color colors[];
   color upColor;
   color dnColor;
   int colorId;
public:
   void Init()
   {
      ArrayInitialize(p1, EMPTY_VALUE);
      ArrayInitialize(p2, EMPTY_VALUE);
   }
   
   void AddColor(color clr)
   {
      int size = ArraySize(colors);
      ArrayResize(colors, size + 1);
      colors[size] = clr;
   }
   int RegisterStreams(int id)
   {
      colorId = id;
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_SHIFT, 0);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, color clr)
   {
      if (clr == EMPTY_VALUE)
      {
         return;
      }
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      if (dnColor == clr)
      {
         p1[period] = MathMax(value1, value2);
         p2[period] = MathMin(value1, value2);
         return;
      }
      upColor = dnColor;
      dnColor = clr;
      PlotIndexSetInteger(colorId, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(colorId + 1, PLOT_LINE_COLOR, 1, dnColor);
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
};
#endif