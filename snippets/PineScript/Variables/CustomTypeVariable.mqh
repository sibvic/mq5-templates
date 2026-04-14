// Custom type variable v1.0

#ifndef CustomTypeVariable_IMPL
#define CustomTypeVariable_IMPL
#include <PineScript/Objects/IObjectDestructor.mqh>

template<typename T>
class CustomTypeVariable
{
   T* _value;
   T* _lastValues[1];
   IObjectDestructor<T*>* _destructor;
   bool _isInitialized;
   void ReleaseCurrentWithLastPreservation()
   {
      if (_value == NULL)
         return;
      _destructor.Free(_value);
      T* p = _value;
      int refs = p.Release();
      _value = NULL;
      if (refs == 1)
      {
         if (_lastValues[0] != NULL)
         {
            _destructor.Free(_lastValues[0]);
            _lastValues[0].Release();
            _lastValues[0] = NULL;
         }
         _lastValues[0] = p;
         _lastValues[0].AddRef();
      }
   }
public:
   CustomTypeVariable(T* deafultValue, IObjectDestructor<T*>* destructor)
   {
      _destructor = destructor;
      _value = deafultValue;
      _lastValues[0] = NULL;
      _isInitialized = false;
   }
   ~CustomTypeVariable()
   {
      if (_value != NULL)
      {
         _destructor.Free(_value);
         _value.Release();
      }
      if (_lastValues[0] != NULL)
      {
         _destructor.Free(_lastValues[0]);
         _lastValues[0].Release();
      }
   }
   void Clear()
   {
      ReleaseCurrentWithLastPreservation();
      _isInitialized = false;
   }
   bool IsInitialized()
   {
      return _isInitialized;
   }
   T* Get(int index = 0)
   {
      if (index == 1)
         return _lastValues[0];
      return _value;
   }
   void Set(T* value)
   {
      _isInitialized = true;
      ReleaseCurrentWithLastPreservation();
      _value = value;
      if (_value != NULL)
      {
         _value.AddRef();
      }
   }
};
#endif
