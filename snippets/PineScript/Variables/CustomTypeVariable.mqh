// Custom type variable v1.0

#ifndef CustomTypeVariable_IMPL
#define CustomTypeVariable_IMPL
#include <PineScript/Objects/IObjectDestructor.mqh>

template<typename T>
class CustomTypeVariable
{
   T* _value;
   IObjectDestructor<T*>* _destructor;
   bool _isInitialized;
public:
   CustomTypeVariable(T* deafultValue, IObjectDestructor<T*>* destructor)
   {
      _destructor = destructor;
      _value = deafultValue;
      _isInitialized = false;
   }
   ~CustomTypeVariable()
   {
      if (_value != NULL)
      {
         _destructor.Free(_value);
         _value.Release();
      }
   }
   void Clear()
   {
      if (_value != NULL)
      {
         _destructor.Free(_value);
         _value.Release();
         _value = NULL;
      }
      _isInitialized = false;
   }
   bool IsInitialized()
   {
      return _isInitialized;
   }
   T* Get()
   {
      return _value;
   }
   void Set(T* value)
   {
      _isInitialized = true;
      if (_value != NULL)
      {
         _destructor.Free(_value);
         _value.Release();
      }
      _value = value;
      if (_value != NULL)
      {
         _value.AddRef();
      }
   }
};
#endif
