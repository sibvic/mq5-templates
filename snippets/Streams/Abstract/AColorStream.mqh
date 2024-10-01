// Abstract color stream v1.0

#ifndef AColorStream_IMPL
#define AColorStream_IMPL
#include <Streams/Interfaces/IColorStream.mqh>

class AColorStream : public IColorStream
{
   int _refs;   
public:
   AColorStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif