// HullOnStream v1.0
class HullOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   HullOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _source = source;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      double price[1];
      int Half_length = (int)MathFloor(_length / 2);
      double hmw = 0;
      double hma = 0;
      for (int k = 0; k < Half_length && (period - k) >= 0; k++)
      {
         if (!_source.GetValues(period - k, 1, price))
            return false;

         double weight = Half_length - k;
         hmw += weight;
         hma += weight * price[0];
      }
      _buffer[size - 1 - period] = 2.0 * hma / hmw;

      hmw = 0;
      hma = 0;
      for (int k = 0; k < _length && (period - k) >= 0; k++)
      {
         if (!_source.GetValues(period - k, 1, price))
            return false;

         double weight = _length - k;
         hmw += weight;
         hma += weight * price[0];
      }
      _buffer[size - 1 - period] -= hma / hmw;
      
      int Hull_length = (int)MathFloor(MathSqrt(_length));
      hmw = 0;
      hma = 0;
      for (int k = 0; k < Hull_length && (period - k) >= 0; k++)
      {
         double weight = Hull_length - k;
         hmw += weight;
         hma += weight * _buffer[size - 1 - period - k];
      }
      val = hma / hmw;
      return true;
   }
};