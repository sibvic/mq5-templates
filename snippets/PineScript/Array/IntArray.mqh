// Int array v2.0
#include <PineScript/Array/SimpleTypeArray.mqh>

class IntArray : public SimpleTypeArray<int>
{
public:
   IntArray(int size, int defaultValue)
      :SimpleTypeArray(size, defaultValue, INT_MIN)
   {
   }
};