#include <Streams/AOnStream.mqh>
#include <Streams/CustomStream.mqh>
#include <Streams/averages/RmaOnStream.mqh>

// HullOnStream v2.0
class HullOnStream : public AOnStream
{
   int _length;
   CustomStream* _buffer;
   IStream* _half;
   IStream* _full;
   IStream* _hull;
public:
   HullOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _source = source;
      _half = new RmaOnStream(source, (int)MathFloor(length / 2));
      _full = new RmaOnStream(source, length);
      _buffer = new CustomStream();
      _hull = new RmaOnStream(_buffer, (int)MathFloor(MathSqrt(length)));
   }

   ~HullOnStream()
   {
      _hull.Release();
      _buffer.Release();
      _half.Release();
      _full.Release();
   }

   bool GetSeriesValue(const int period, double &val)
   {
      int size = Size();
      _buffer.SetSize(size);
      double half[1];
      double full[1];
      if (!_half.GetSeriesValues(period, 1, half) || !_full.GetSeriesValues(period, 1, full))
         return false;
      
      _buffer._data[period] = half[0] * 2 - full[0];
      double res[1];
      if (!_hull.GetSeriesValues(period, 1, res))
         return false;
      val = res[0];
      return true;
   }
};