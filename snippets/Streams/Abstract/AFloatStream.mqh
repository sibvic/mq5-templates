// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL
#include <Streams/IStream.mqh>

class AFloatStream : public IStream
{
   int _refs;   
public:
   AFloatStream()
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