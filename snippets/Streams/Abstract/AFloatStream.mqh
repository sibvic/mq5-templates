// Abstract float stream v2.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL
#include <Streams/Interfaces/TIStream.mqh>

class AFloatStream : public TIStream<double>
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