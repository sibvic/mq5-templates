// Int array v1.4
#include <Array/IIntArray.mqh>

class IntArraySlice : public IIntArray
{
   IIntArray* array;
   int from;
   int to;
public:
   IntArraySlice(IIntArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(int value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(int value)
   {
      //do nothing
   }
   virtual int Pop()
   {
      return NULL;
   }
   virtual int Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, int value)
   {
      //do nothing
   }
   virtual IIntArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IIntArray* Clear()
   {
      return NULL;
   }
   virtual int Shift()
   {
      return NULL;
   }
   virtual int Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class IntArray : public IIntArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
   IntArraySlice* slices[];
public:
   IntArray(int size, int defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }
   ~IntArray()
   {
      Clear();
   }

   IIntArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      int size = ArraySize(slices);
      for (int i = 0; i < size; i++)
      {
         delete slices[i];
      }
      ArrayResize(slices, 0);
      return &this;
   }

   void Unshift(int value)
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

   void Push(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   int Pop()
   {
      int size = ArraySize(_array);
      int value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   int Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, int value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }

   int Shift()
   {
      return Remove(0);
   }
   
   IIntArray* Slice(int from, int to)
   {
      int size = ArraySize(slices);
      for (int i = 0; i < size; ++i)
      {
         if (slices[i].GetFrom() == from && slices[i].GetTo() == to)
         {
            return slices[i];
         }
      }
      ArrayResize(slices, size + 1);
      slices[size] = new IntArraySlice(&this, from, to);
      return slices[size];
   }
   
   void Sort(bool ascending)
   {
      ArraySort(_array);
      if (!ascending)
      {
         ArrayReverse(_array);
      }
   }

   int Remove(int index)
   {
      int size = ArraySize(_array);
      int value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};