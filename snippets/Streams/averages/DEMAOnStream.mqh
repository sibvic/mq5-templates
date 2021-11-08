#include <Streams/AOnStream.mqh>
#include <Streams/CustomStream.mqh>
#include <Streams/averages/RmaOnStream.mqh>

// DEMAOnStream v1.0
class DEMAOnStream : public AOnStream
{
   double _alpha;
   CustomStream* _buffer;
   CustomStream* _buffer2;
public:
   DEMAOnStream(IStream* source, const int length)
      :AOnStream(source)
   {
      _alpha = 2.0 / (1.0 + length);
      _source = source;
      _buffer = new CustomStream();
      _buffer2 = new CustomStream();
   }

   ~DEMAOnStream()
   {
      _buffer.Release();
      _buffer2.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      _buffer.SetSize(size);
      _buffer2.SetSize(size);

      double prices[1];
      if (!_source.GetSeriesValues(period, 1, prices))
      {
         return false;
      }

      _buffer._data[period] = _buffer._data[period - 1] + _alpha * (prices[0] - _buffer._data[period - 1]);
      _buffer2._data[period] = _buffer2._data[period - 1] + _alpha * (_buffer._data[period] - _buffer._data[period - 1]);
      val = _buffer._data[period] * 2.0 - _buffer2._data[period];
      return true;
   }
};