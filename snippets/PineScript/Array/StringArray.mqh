// String array v2.1
#ifndef StringArray_IMPL
#define StringArray_IMPL
#include <PineScript/Array/SimpleTypeArray.mqh>

class StringArray : public SimpleTypeArray<string>
{
public:
   StringArray(int size, string defaultValue)
      :SimpleTypeArray(size, defaultValue, "")
   {
   }
};
#endif
