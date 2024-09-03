// Colored fill v1.0

#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   color upColor;
   color dnColor;
   int streamIndex;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void AddColor(color clr)
   {
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   void AddColor(double clr)
   {
      if (clr == EMPTY_VALUE)
      {
         return;
      }
      AddColor((color)clr);
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
   
   void Set(int period, double value1, double value2, color clr)
   {
      if (clr == EMPTY_VALUE || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
};
#endif