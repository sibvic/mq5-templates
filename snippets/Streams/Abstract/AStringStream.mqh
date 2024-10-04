// Abstract implementation for IStringStream v1.0

#ifndef AStringStream_IMPL
#define AStringStream_IMPL

#include <Streams/Interfaces/IStringStream.mqh>

class AStringStream : public IStringStream
{
   int _refs;   
public:
   AStringStream()
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
