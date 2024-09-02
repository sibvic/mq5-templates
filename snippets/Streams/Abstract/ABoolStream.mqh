// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
#include <Streams/Interfaces/IBoolStream.mqh>

class ABoolStream : public IBoolStream
{
   int _refs;   
public:
   ABoolStream()
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