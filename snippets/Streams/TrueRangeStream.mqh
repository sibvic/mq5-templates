#include <Streams/AStream.mqh>
#include <Streams/ChartPrice.mqh>

//True range stream v1.2

class TrueRangeStream : public AStream
{
   bool _handleNa;
public:
   TrueRangeStream(const string symbol, ENUM_TIMEFRAMES timeframe, bool handleNa = false)
      :AStream(symbol, timeframe)
   {
      _handleNa = handleNa;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      if ((_handleNa && period + count > size) || (!_handleNa && period + count + 1 > size))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         double open, high, low, close;
         if (!Quote(period + i, open, high, low, close))
         {
            return false;
         }
         if ((period + i + 1 == size) && _handleNa)
         {
            double hl = MathAbs(high - low);
            double hc = MathAbs(high - close);
            double lc = MathAbs(low - close);
            val[i] = MathMax(lc, MathMax(hl, hc));
            continue;
         }
         double prevOpen, prevHigh, prevLow, prevClose;
         if (!Quote(period + i + 1, prevOpen, prevHigh, prevLow, prevClose))
         {
            return false;
         }
         double hl = MathAbs(high - low);
         double hc = MathAbs(high - prevClose);
         double lc = MathAbs(low - prevClose);
         val[i] = MathMax(lc, MathMax(hl, hc));
      }
      return true;
   }
private:
   bool Quote(const int shift, double &open, double &high, double &low, double &close)
   {
      if (ChartPrice::Matches(_symbol, _timeframe))
      {
         return ChartPrice::GetSeries(shift, open, high, low, close);
      }
      if (shift < 0 || shift >= Size())
      {
         return false;
      }
      open = iOpen(_symbol, _timeframe, shift);
      high = iHigh(_symbol, _timeframe, shift);
      low = iLow(_symbol, _timeframe, shift);
      close = iClose(_symbol, _timeframe, shift);
      return true;
   }
};