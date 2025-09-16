// float array interface v2.0
#include <PineScript/Array/ITArray.mqh>

class IFloatArray : public ITArray<double>
{
public:
   virtual IFloatArray* Slice(int from, int to) = 0;
   virtual IFloatArray* Clear() = 0;
};