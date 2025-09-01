#ifndef BarsSinceStreamV2_IMPL
#define BarsSinceStreamV2_IMPL

#include <Streams/Abstract/TAStream.mqh>
#include <Streams/Interfaces/TIStream.mqh>

// Counts number of bars since last condition.
// v3.0

class BarsSinceStreamV2 : public TAStream<int>
{
   TIStream<int>* _condition;
   int _bars[];
public:
   BarsSinceStreamV2(TIStream<int>* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~BarsSinceStreamV2()
   {
      _condition.Release();
   }

   int Size()
   {
      return _condition.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   virtual bool GetValues(const int period, const int count, int &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         int value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   virtual bool GetValue(const int period, int &val)
   {
      int size = Size();
      if (period >= size)
      {
         return false;
      }
      int currentBufferSize = ArrayRange(_bars, 0);
      if (currentBufferSize != size) 
      {
         ArrayResize(_bars, size);
         for (int i = currentBufferSize; i < size; ++i)
         {
            _bars[i] = (int)EMPTY_VALUE;
         }
      }
      if (_bars[period] == (int)EMPTY_VALUE)
      {
         FillHistory(period);
      }
      val = _bars[period];
      return true;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex > 0; --periodIndex)
      {
         int val[1];
         if (_condition.GetValues(periodIndex, 1, val) && val[0] == true)
         {
            _bars[periodIndex] = 0;
            for (int ii = periodIndex + 1; ii <= period; ++ii)
            {
               _bars[ii] = _bars[ii - 1] + 1;
            }
            return;
         }
      }
   }
};
#endif