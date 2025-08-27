#ifndef FixnanStream_IMP
#define FixnanStream_IMP
// Fix NAN stream v1.0

#include <Streams/AOnStream.mqh>

class FixnanStream : public AOnStream
{
   int _maxLookback;
public:
   FixnanStream(TIStream<double>* source)
      :AOnStream(source)
   {
      _maxLookback = 1000;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      for (int i = 0; i < _maxLookback; ++i)
      {
         double v[1];
         if (_source.GetSeriesValues(period + i, 1, v))
         {
            val = v[0];
            return true;
         }
      }

      return false;
   }

};

class FixnanStreamFactory
{
public:
   static TIStream<double>* Create(TIStream<double>* source)
   {
      return new FixnanStream(source);
   }
};
#endif