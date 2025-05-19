// Stream returns rising flag. Similar to ta.rising in PineScript v3.0
#include <Streams/Interfaces/TIStream.mqh>

class RisingStream : public TIStream<int>
{
   TIStream<double>* _source;
   int _length;
public:
   RisingStream(TIStream<double>* source, int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
   }
   ~RisingStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   bool GetSeriesValues(const int period, int count, int &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   bool GetValues(const int period, int count, int &val[])
   {
      bool boolVals[];
      ArrayResize(boolVals, count);
      if (!Get(period, count, boolVals))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = boolVals[i] ? 1 : 0;
      }
      return true;
   }
private:
   bool Get(const int period, int count, bool &val[])
   {
      double current[];
      ArrayResize(current, count);
      if (!_source.GetValues(period, count, current))
      {
         return false;
      }
      double prev[];
      ArrayResize(prev, count);
      if (!_source.GetValues(period + _length, count, prev))
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = prev[i] < current[i];
      }
      return true;
   }
};