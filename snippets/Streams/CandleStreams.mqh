// Candles stream v.1.2
#include <PineScriptUtils.mqh>

class CandleStreams
{
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];
   double ColorIndex[];
   color colors[];
   int streamIndex;
public:
   CandleStreams(int streamIndex)
   {
      this.streamIndex = streamIndex;
   }
   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
      ArrayInitialize(ColorIndex, 0);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
      ColorIndex[index] = 0;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTransparency(clr);
      if (transp == 100)
      {
         return;
      }
      int size = ArraySize(colors);
      ArrayResize(colors, size + 1);
      colors[size] = (color)GetColorOnly(clr);
   }

   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id, OpenStream, INDICATOR_DATA);
      SetIndexBuffer(id + 1, HighStream, INDICATOR_DATA);
      SetIndexBuffer(id + 2, LowStream, INDICATOR_DATA);
      SetIndexBuffer(id + 3, CloseStream, INDICATOR_DATA);
      SetIndexBuffer(id + 4, ColorIndex, INDICATOR_COLOR_INDEX);
      int size = ArraySize(colors);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, size);
      for (int i = 0; i < size; ++i)
      {
         PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, i, colors[i]);
      }
      return id + 5;
   }
   
   void Set(const int index, const double open, const double high, const double low, const double close, uint clr)
   {
      if (clr == (uint)EMPTY_VALUE)
      {
         return;
      }
      int transp = GetTransparency(clr);
      if (transp == 100)
      {
         Clear(index);
         return;
      }
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
      ColorIndex[index] = FindColor(clr);
   }
   
   void SetOffset(int offset)
   {
   }
private:
   int FindColor(uint clr)
   {
      color searchingColor = (color)GetColorOnly(clr);
      int size = ArraySize(colors);
      for (int i = 0; i < size; ++i)
      {
         if (colors[i] == searchingColor)
         {
            return i;
         }
      }
      if (size < 64)
      {
         ArrayResize(colors, size + 1);
         colors[size] = searchingColor;
         PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, size + 1);
         PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, size, searchingColor);
         return size;
      }
      int best = 0;
      int bestDistance = 1000000000;
      for (int i = 0; i < size; ++i)
      {
         int distance = ColorDistance(colors[i], searchingColor);
         if (distance < bestDistance)
         {
            bestDistance = distance;
            best = i;
         }
      }
      return best;
   }

   int ColorDistance(color left, color right)
   {
      int dr = Channel(left, 0) - Channel(right, 0);
      int dg = Channel(left, 8) - Channel(right, 8);
      int db = Channel(left, 16) - Channel(right, 16);
      return dr * dr + dg * dg + db * db;
   }

   int Channel(color clr, int shift)
   {
      return (int)(((uint)clr >> shift) & 0xFF);
   }
};