// Colored plot v1.2
#include <PineScriptUtils.mqh>

class ColoredPlot
{
   int plotIndex;
   double values[];
   double colors[];
   double buffer[];
   
   uint initColors[];
   int offset;
public:
   ColoredPlot(int plotIndex)
   {
      this.plotIndex = plotIndex;
      offset = INT_MIN;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTransparency(clr);
      if (transp == 100)
      {
         return;
      }
      uint colorOnly = GetColorOnly(clr);
      int colorsCount = ArraySize(initColors);
      for (int i = 0; i < colorsCount; ++i)
      {
         if (initColors[i] == colorOnly)
         {
            return;
         }
      }
      ArrayResize(initColors, colorsCount + 1);
      initColors[colorsCount] = colorOnly;
   }
   
   void SetOffset(int offset)
   {
      this.offset = offset;
   }
   
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id++, values, INDICATOR_DATA);
      SetIndexBuffer(id++, colors, INDICATOR_COLOR_INDEX);
      // Palette must be applied after the color buffer is bound. Doing it earlier is reset
      // by SetIndexBuffer, and a DRAW_COLOR_LINE with no palette is not drawn.
      ApplyColors();
      if (offset != INT_MIN)
      {
         PlotIndexSetInteger(plotIndex, PLOT_SHIFT, offset);
      }
      return id;
   }
   int RegisterInternalStreams(int id)
   {
      SetIndexBuffer(id++, buffer, INDICATOR_CALCULATIONS);
      return id;
   }
   
   void Init()
   {
      ArrayInitialize(values, EMPTY_VALUE);
      ArrayInitialize(colors, EMPTY_VALUE);
      ArrayInitialize(buffer, EMPTY_VALUE);
   }
   
   double Set(int pos, double value, uint clr)
   {
      if (value == EMPTY_VALUE)
      {
         values[pos] = EMPTY_VALUE;
         colors[pos] = EMPTY_VALUE;
         buffer[pos] = EMPTY_VALUE;
         return EMPTY_VALUE;
      }
      buffer[pos] = value;
      values[pos] = value;
      int colorIndex = FindColorIndex(clr);
      // Fully transparent still keeps the price. Fills read this value, and the color buffer stays empty so the line breaks.
      if (colorIndex < 0)
      {
         colors[pos] = EMPTY_VALUE;
         return value;
      }
      colors[pos] = colorIndex;
      int prevValueIndex = FindPrevValueIndex(pos);
      if (prevValueIndex == -1)
      {
         return value;
      }
      int length = pos - prevValueIndex + 1;
      if (length <= 1)
      {
         return value;
      }
      double diff = buffer[pos] - buffer[prevValueIndex];
      double step = diff / (length - 1);
      for (int i = 0; i < length; ++i)
      {
         values[prevValueIndex + i] = buffer[prevValueIndex] + step * i;
         colors[prevValueIndex + i] = colorIndex;
      }
      return value;
   }
private:
   int FindPrevValueIndex(int pos)
   {
      for (int i = pos - 1; i >= 0; --i)
      {
         if (buffer[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return -1;
   }
   void ApplyColors()
   {
      int colorsCount = ArraySize(initColors);
      if (colorsCount == 0)
      {
         PlotIndexSetInteger(plotIndex, PLOT_COLOR_INDEXES, 1);
         PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, 0, clrNONE);
         return;
      }
      PlotIndexSetInteger(plotIndex, PLOT_COLOR_INDEXES, colorsCount);
      for (int i = 0; i < colorsCount; ++i)
      {
         PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, i, initColors[i]);
      }
   }
   int FindColorIndex(uint clr)
   {
      int transp = GetTransparency(clr);
      if (transp == 100)
      {
         return -1;
      }
      uint searchingColor = GetColorOnly(clr);
      int colorsCount = ArraySize(initColors);
      for (int i = 0; i < colorsCount; ++i)
      {
         if (initColors[i] == searchingColor)
         {
            return i;
         }
      }
      if (colorsCount >= 64)
      {
         return 0;
      }
      ArrayResize(initColors, colorsCount + 1);
      initColors[colorsCount] = searchingColor;
      ApplyColors();
      return colorsCount;
   }
};