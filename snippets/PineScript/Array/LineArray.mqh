#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v2.0
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/LinesCollection.mqh>

class LineArray : public CustomTypeArray<Line*>
{
public:
   LineArray(int size, Line* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Line* Clone(Line* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Line* item)
   {
      LinesCollection::Delete(item);
   }
};

#endif