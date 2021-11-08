#include <Conditions/AConditionBase.mqh>
#include <Streams/IBarStream.mqh>
// Ascending bar condnition v1.0

class AscendingBarCondition : public AConditionBase
{
   IBarStream* _stream;
public:
   AscendingBarCondition(IBarStream* stream)
      :AConditionBase("Ascending bar")
   {
      _stream = stream;
      _stream.AddRef();
   }
   ~AscendingBarCondition()
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
      return open > close;
   }
};