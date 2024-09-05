// Abstract Int stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL
#include <Streams/Interfaces/IIntStream.mqh>

class AIntStream : public IIntStream
{
   int _refs;   
public:
   AIntStream()
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