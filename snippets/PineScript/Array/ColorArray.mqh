// Color array v1.0
#include <PineScript/Array/SimpleTypeArray.mqh>

class ColorArray : public SimpleTypeArray<uint>
{
public:
   ColorArray(int size, uint defaultValue)
      :SimpleTypeArray(size, defaultValue, INT_MIN)
   {
   }
};