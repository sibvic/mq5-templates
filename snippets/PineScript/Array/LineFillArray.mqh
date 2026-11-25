#ifndef LineFillArray_IMPL
#define LineFillArray_IMPL
// Linefill array v1.0
#include <PineScript/Array/CustomTypeArray.mqh>
#include <PineScript/Objects/LinefillsCollection.mqh>

class LineFillArray : public CustomTypeArray<LineFill*>
{
public:
   LineFillArray(int size, LineFill* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual void DeleteItem(LineFill* item)
   {
      LinefillsCollection::Delete(item);
   }
};
#endif
