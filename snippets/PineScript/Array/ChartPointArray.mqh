#ifndef ChartPointArray_IMPL
#define ChartPointArray_IMPL
// ChartPoint array v1.0
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/ChartPoint.mqh>

class ChartPointArray : public CustomTypeArray<ChartPoint*>
{
public:
   ChartPointArray(int size, ChartPoint* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual ChartPoint* Clone(ChartPoint* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      ChartPoint* clone = ChartPoint::Create();
      item.CopyTo(clone);
      return clone;
   }
};

#endif