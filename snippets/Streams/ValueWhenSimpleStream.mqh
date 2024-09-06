// Value when stream (condition as a parameter) v1.0

#include <Streams/AStream.mqh>
#include <Conditions/ICondition.mqh>

class ValueWhenSimpleStream : public AStream
{
   datetime _periods[];
   double _values[];
   int _shift;
public:
   double _stream[];

   ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)
      :AStream(symbol, timeframe)
   {
      _shift = shift;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   double Update(const int period, datetime date, bool condition, double val)
   {
      if (condition)
      {
         int size = ArraySize(_periods);
         if (size == 0 || _periods[size - 1] != date)
         {
            ArrayResize(_periods, size + 1);
            ArrayResize(_values, size + 1);
            _values[size] = val;
            _periods[size] = date;
            ++size;
         }
         else
         {
            _values[size - 1] = val;
         }
         if (size - 1 - _shift >= 0)
         {
            _stream[period] = _values[size - 1 - _shift];
         }
         else
         {
            _stream[period] = EMPTY_VALUE;
         }
      }
      else if (period > 0)
      {
         _stream[period] = _stream[period - 1];
      }
      return _stream[period];
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; i++)
      {
         if (_stream[period - i] == EMPTY_VALUE)
         {
            return false;
         }
         val[i] = _stream[period - i];
      }
      return true;
   }
};