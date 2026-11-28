#include <Streams/AOnStream.mqh>
#include <Streams/Custom/IntToFloatStreamWrapper.mqh>

// Sum on stream v2.1

class SumOnStream : public AOnStream
{
   double _buffer[];
   int _length;
public:
   SumOnStream(TIStream<double> *source, int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }

      double sum = 0;
      for (int i = 0; i < _length; ++i)
      {
         double current[1];
         if (!_source.GetSeriesValues(period + i, 1, current))
         {
            return false;
         }
         sum += current[0];
      }
      int bufferIndex = totalBars - 1 - period;
      _buffer[bufferIndex] = sum;
      val = _buffer[bufferIndex];
      return true;
   }
};

class DynamicSumOnStream
{
   SumOnStream* impl;
   TIStream<double>* _source;
   IntToFloatStreamWrapper* _intWrapper;
   int _length;
   int _references;
public:
   DynamicSumOnStream(TIStream<double> *source)
   {
      impl = NULL;
      _source = source;
      _intWrapper = NULL;
      _length = 0;
      _references = 1;
   }
   DynamicSumOnStream(TIStream<int> *source)
   {
      impl = NULL;
      _intWrapper = new IntToFloatStreamWrapper(source);
      _source = _intWrapper;
      _length = 0;
      _references = 1;
   }
   ~DynamicSumOnStream()
   {
      ReleaseImpl();
      if (_intWrapper != NULL)
      {
         _intWrapper.Release();
         _intWrapper = NULL;
      }
   }
   void AddRef()
   {
      ++_references;
   }
   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }
   bool GetValues(const int period, const int length, const int count, double &val[])
   {
      if (_length != length)
      {
         ReleaseImpl();
         _length = length;
         impl = new SumOnStream(_source, _length);
      }
      return impl.GetValues(period, count, val);
   }
private:
   void ReleaseImpl()
   {
      if (impl != NULL)
      {
         impl.Release();
         impl = NULL;
      }
   }
};