#include <Streams/AStream.mqh>
// CustomStream v2.0

class CustomStream : public AStream
{
   double _data[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void SetValue(int period, double value)
   {
      EnsureStreamHasProperSize(Size());
      _data[period] = value;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      EnsureStreamHasProperSize(Size());
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         if (_data[size - 1 - period + i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period + i];
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      EnsureStreamHasProperSize(Size());
      int bars = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }

private:
   void EnsureStreamHasProperSize(int size)
   {
      if (ArrayRange(_data, 0) != size) 
      {
         ArrayResize(_data, size);
      }
   }
};