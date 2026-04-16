#ifndef BoolStream_IMPL
#define BoolStream_IMPL

#include <Streams/Abstract/TAStream.mqh>
// Bool stream v3.0 — TIStream<bool>

class BoolStream : public TAStream<bool>
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _stream[];
   int _emptyValue;
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = -1)
   {
      _emptyValue = emptyValue;
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
   }

   virtual int Size()
   {
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, bool value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value ? 1 : 0;
   }

   bool GetValues(const int period, const int count, int &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);

      for (int i = 0; i < count; ++i)
      {
         int raw = _stream[period - i];
         if (raw == _emptyValue)
         {
            return false;
         }
         val[i] = raw;
      }
      return true;
   }

   bool GetSeriesValues(const int period, const int count, int &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }

   virtual bool GetValues(const int period, const int count, bool &val[])
   {
      int tmp[];
      ArrayResize(tmp, count);
      if (!GetValues(period, count, tmp))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = (tmp[i] != 0);
      }
      return true;
   }

   virtual bool GetSeriesValues(const int period, const int count, bool &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      int currentSize = ArrayRange(_stream, 0);
      if (currentSize != size)
      {
         ArrayResize(_stream, size);
         for (int i = currentSize; i < size; ++i)
         {
            _stream[i] = _emptyValue;
         }
      }
   }
};

#endif
