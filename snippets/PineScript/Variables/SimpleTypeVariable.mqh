// Simple type variable v1.0

#include <PineScript/Objects/IObjectDestructor.mqh>

#ifndef SimpleTypeVariable_IMPL
#define SimpleTypeVariable_IMPL

template<typename T>
class SimpleTypeVariable
{
   T _value;
   T _lastValues[1];
   T _deafultValue;
   bool _isInitialized;
public:
   SimpleTypeVariable(T deafultValue, IObjectDestructor<T>* destructor)
   {
      //ignore destructor
      _value = deafultValue;
      _lastValues[0] = deafultValue;
      _deafultValue = deafultValue;
      _isInitialized = false;
   }
   void Clear()
   {
      _lastValues[0] = _value;
      _value = _deafultValue;
      _isInitialized = false;
   }
   bool IsInitialized()
   {
      return _isInitialized;
   }
   T Get(int index = 0)
   {
      if (index == 1)
         return _lastValues[0];
      return _value;
   }
   void Set(T value)
   {
      _isInitialized = true;
      _lastValues[0] = _value;
      _value = value;
   }
};
#endif
