#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v2.0
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/BoxesCollection.mqh>

class BoxArray : public CustomTypeArray<Box*>
{
public:
   BoxArray(int size, Box* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Box* Clone(Box* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Box* clone = BoxesCollection::Create(item.GetId() + index, item.GetLeft(), item.GetTop(), item.GetRight(), item.GetBottom(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Box* item)
   {
      BoxesCollection::Delete(item);
   }
};

#endif