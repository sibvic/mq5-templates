#ifndef FloatStream_IMPL
#define FloatStream_IMPL

#include <Streams/AStreamBase.mqh>
// Float stream v1.0

class FloatStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif