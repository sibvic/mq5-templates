// Bool array v2.0
#ifndef BoolArray_IMP
#define BoolArray_IMP
#include <PineScript/Array/SimpleTypeArray.mqh>

class BoolArray : public SimpleTypeArray<bool>
{
public:
   BoolArray(int size, bool defaultValue)
      :SimpleTypeArray(size, defaultValue, false)
   {
   }
};
#endif
