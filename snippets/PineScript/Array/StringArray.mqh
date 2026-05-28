// String array v2.0
#include <PineScript/Array/SimpleTypeArray.mqh>

class StringArray : public SimpleTypeArray<string>
{
public:
   StringArray(int size, string defaultValue)
      :SimpleTypeArray(size, defaultValue, "")
   {
   }
};
