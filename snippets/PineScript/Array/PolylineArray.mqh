#ifndef PolylineArray_IMPL
#define PolylineArray_IMPL
// Polyline array v1.0
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/PolyLinesCollection.mqh>

class PolylineArray : public CustomTypeArray<Polyline*>
{
public:
   PolylineArray(int size, Polyline* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Polyline* Clone(Polyline* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Polyline* clone = PolyLinesCollection::Create(item.GetId(), NULL, 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Polyline* item)
   {
      PolyLinesCollection::Delete(item);
   }
};

#endif