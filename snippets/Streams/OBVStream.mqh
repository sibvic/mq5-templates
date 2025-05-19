#include <streams/AOnStream.mqh>
#include <Streams/CustomStream.mqh>

// OBV on stream v2.0

#ifndef OBVStream_IMP
#define OBVStream_IMP

class OBVStream : public AOnStream
{
   StreamBuffer* _buffer;
   TIStream<double> *_volumeSource;
public:
   OBVStream(TIStream<double> *source, TIStream<double> *volumeSource)
      :AOnStream(source)
   {
      _volumeSource = volumeSource;
      _volumeSource.AddRef();
      _buffer = new StreamBuffer();
   }

   ~OBVStream()
   {
      _volumeSource.Release();
      delete _buffer;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      _buffer.EnsureSize(size);
      int pos = size - 1 - period;

      double prices[2];
      double vol[1];
      if (!_source.GetSeriesValues(period, 2, prices) || !_volumeSource.GetSeriesValues(period, 1, vol))
      {
         return false;
      }
      if (pos == 0 || _buffer._data[pos - 1] == EMPTY_VALUE)
      {
         val = vol[0];
      }
      else if (prices[0] > prices[1])
      {
         val = _buffer._data[pos - 1] + vol[0];
      }
      else
      {
         val = _buffer._data[pos - 1] - vol[0];
      }

      _buffer._data[pos] = val;

      return true;
   }
};

#endif