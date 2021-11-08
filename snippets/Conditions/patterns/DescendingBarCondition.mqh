#include <Conditions/AConditionBase.mqh>
#include <Streams/IBarStream.mqh>
// Descending bar condnition v1.0

class DescendingBarCondition : public AConditionBase
{
   IBarStream* _stream;
public:
   DescendingBarCondition(IBarStream* stream)
      :AConditionBase("Descending bar")
   {
      _stream = stream;
      _stream.AddRef();
   }
   ~DescendingBarCondition()
   {
      _stream.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double open, close;
      if (!_stream.GetOpenClose(period, open, close))
      {
         return false;
      }
      return open < close;
   }
};