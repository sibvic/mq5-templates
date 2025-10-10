// Simple type array v1.1

#ifndef SimpleTypeArray_IMPL
#define SimpleTypeArray_IMPL
#include <PineScript/Array/ITArray.mqh>
template <typename CLASS_TYPE>
interface ISimpleTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ISimpleTypeArray<CLASS_TYPE>* Clear() = 0;
   virtual ITArray<CLASS_TYPE>* Slice(int from, int to) = 0;
};

template <typename CLASS_TYPE>
class SimpleTypeArraySlice : public ISimpleTypeArray<CLASS_TYPE>
{
   ITArray<CLASS_TYPE>* array;
   int from;
   int to;
   int _refs;
   CLASS_TYPE emptyValue;
public:
   SimpleTypeArraySlice(ITArray<CLASS_TYPE>* array, int from, int to, CLASS_TYPE emptyValue)
   {
      _refs = 1;
      this.array = array;
      this.from = from;
      this.to = to;
      this.emptyValue = emptyValue;
   }
   
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(CLASS_TYPE value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      //do nothing
      return &this;
   }
   virtual CLASS_TYPE Pop()
   {
      return emptyValue;
   }
   virtual CLASS_TYPE Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, CLASS_TYPE value)
   {
      //do nothing
   }
   virtual ITArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return NULL;
   }
   virtual ISimpleTypeArray<CLASS_TYPE>* Clear()
   {
      return NULL;
   }
   virtual CLASS_TYPE Shift()
   {
      return emptyValue;
   }
   virtual CLASS_TYPE Remove(int index)
   {
      return emptyValue;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
   int Includes(CLASS_TYPE value)
   {
      int size = Size();
      for (int i = 0; i < size; ++i)
      {
         if (Get(i) == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE First()
   {
      if (Size() == 0)
      {
         return emptyValue;
      }
      return Get(0);
   }
   CLASS_TYPE Last()
   {
      int size = Size();
      if (size == 0)
      {
         return emptyValue;
      }
      return Get(size - 1);
   }
};

template <typename CLASS_TYPE>
class SimpleTypeArray : public ISimpleTypeArray<CLASS_TYPE>
{
   CLASS_TYPE _array[];
   int _defaultSize;
   CLASS_TYPE _defaultValue;
   CLASS_TYPE _emptyValue;
   int _refs;
public:
   SimpleTypeArray(int size, CLASS_TYPE defaultValue, CLASS_TYPE emptyValue)
   {
      _refs = 1;
      _defaultSize = size;
      _defaultValue = defaultValue;
      _emptyValue = emptyValue;
      Clear();
   }

   ~SimpleTypeArray()
   {
      Clear();
   }

   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   ITArray<CLASS_TYPE>* Slice(int from, int to)
   {
      return new SimpleTypeArraySlice<CLASS_TYPE>(&this, from, to, _emptyValue);
   }
   
   ISimpleTypeArray<CLASS_TYPE>* Clear()
   {
      int size = ArraySize(_array);
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }
   
   void Sort(bool ascending)
   {
      ArraySort(_array);
      if (!ascending)
      {
         ArrayReverse(_array);
      }
   }

   void Unshift(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   CLASS_TYPE Pop()
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   CLASS_TYPE Shift()
   {
      return Remove(0);
   }

   CLASS_TYPE Get(int index)
   {
      if (index >= Size())
      {
         return _emptyValue;
      }
      if (index < 0)
      {
         index = Size() + index;
      }
      return _array[index];
   }
   
   void Set(int index, CLASS_TYPE value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   CLASS_TYPE Remove(int index)
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE PercentRank(int index)
   {
      int arraySize = Size();
      if (arraySize == 0 || arraySize <= index) { return _emptyValue; }
      CLASS_TYPE target = Get(index);
      if (target == _emptyValue)
      {
         return _emptyValue;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         CLASS_TYPE current = Get(i);
         if (current != _emptyValue && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   
   CLASS_TYPE Max()
   {
      if (Size() == 0) { return _emptyValue; }
      CLASS_TYPE max = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (max == _emptyValue || (current != _emptyValue && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   CLASS_TYPE Min()
   {
      if (Size() == 0) { return _emptyValue; }
      CLASS_TYPE min = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (min == _emptyValue || (current != _emptyValue && min > current))
         {
            min = current;
         }
      }
      return min;
   }
   
   CLASS_TYPE Sum()
   {
      CLASS_TYPE sum = 0;
      for (int i = 0; i < Size(); ++i)
      {
         sum += Get(i);
      }
      return sum;
   }
   double Stdev()
   {
      double sum = 0;
      double ssum = 0;
      int size = Size();
      if (size < 2)
      {
         return 0;
      }
      for (int i = 0; i < size; i++)
      {
         CLASS_TYPE value = Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
};
#endif