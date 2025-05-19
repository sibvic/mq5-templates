#ifndef LabelArray_IMPL
#define LabelArray_IMPL
// Label array v1.0
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/LabelsCollection.mqh>

class LabelArray : public CustomTypeArray<Label*>
{
public:
   LabelArray(int size, Label* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Label* Clone(Label* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Label* clone = LabelsCollection::Create(item.GetId() + index, item.GetX(), item.GetY(), 0);
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Label* item)
   {
      LabelsCollection::Delete(item);
   }
};

#endif