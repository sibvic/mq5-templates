// String stream v1.1

#ifndef StringStream_IMPL
#define StringStream_IMPL

#include <Streams/Abstract/AStringStream.mqh>

class StringStream : public AStringStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _stream[];
   string _emptyValue;
public:
   StringStream(const string symbol, const ENUM_TIMEFRAMES timeframe, string emptyValue = NULL)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _emptyValue = emptyValue;
   }
   void Init()
   {
      for (int i = 0; i < ArraySize(_stream); ++i)
      {
         _stream[i] = NULL;
      }
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, string value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   virtual bool GetValues(const int period, const int count, string &val[])
   {
      int size = iBars(_Symbol, _Period);
      int oldPos = size - period - 1;
      if (oldPos + count - 1 >= size)
      {
         return false;  
      }
      EnsureStreamHasProperSize(size);
      for (int i = 0; i < count; ++i)
      {
         if (_stream[period + i] == _emptyValue)
         {
            return false;
         }
         val[i] = _stream[period + i];
      }
      return true;
   }
   virtual bool GetSeriesValues(const int period, const int count, string &val[])
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
            _stream[i] = NULL;
         }
      }
   }
};
#endif