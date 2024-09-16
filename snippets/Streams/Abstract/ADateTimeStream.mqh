// Abstract date/time stream v1.0

#ifndef ADateTimeStream_IMPL
#define ADateTimeStream_IMPL
#include <Streams/Interfaces/IDateTimeStream.mqh>

class ADateTimeStream : public IDateTimeStream
{
   int _refs;   
public:
   ADateTimeStream()
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