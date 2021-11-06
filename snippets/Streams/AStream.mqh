// AStream v1.1
#include <Streams/IStream.mqh>
class AStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~AStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};