// Float array v2.0
#include <PineScript/Array/SimpleTypeArray.mqh>

class FloatArray : public SimpleTypeArray<double>
{
public:
   FloatArray(int size, double defaultValue)
      :SimpleTypeArray(size, defaultValue, EMPTY_VALUE)
   {
   }
};