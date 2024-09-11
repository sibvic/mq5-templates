// Float array v1.4
#include <Array/IFloatArray.mqh>

class FloatArraySlice : public IFloatArray
{
   IFloatArray* array;
   int from;
   int to;
public:
   FloatArraySlice(IFloatArray* array, int from, int to)
   {
      this.array = array;
      this.from = from;
      this.to = to;
   }
   int GetFrom() { return from; }
   int GetTo() { return to; }
   virtual void Unshift(double value)
   {
      //do nothing
   }
   virtual int Size()
   {
      return to - from + 1;
   }
   virtual void Push(double value)
   {
      //do nothing
   }
   virtual double Pop()
   {
      return NULL;
   }
   virtual double Get(int index)
   {
      return array.Get(index + from);
   }
   virtual void Set(int index, double value)
   {
      //do nothing
   }
   virtual IFloatArray* Slice(int from, int to)
   {
      return NULL;
   }
   virtual IFloatArray* Clear()
   {
      return NULL;
   }
   virtual double Shift()
   {
      return NULL;
   }
   virtual double Remove(int index)
   {
      return NULL;
   }
   virtual void Sort(bool ascending)
   {
      //do nothing
   }
};

class FloatArray : public IFloatArray
{
   double _array[];
   int _defaultSize;
   double _defaultValue;
   FloatArraySlice* slices[];
public:
   FloatArray(int size, double defaultValue)
   {
      _defaultSize = size;
      _defaultValue = defaultValue;
      Clear();
   }
   ~FloatArray()
   {
      Clear();
   }

   IFloatArray* Clear()
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

   void Unshift(double value)
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

   void Push(double value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
   }

   double Pop()
   {
      int size = ArraySize(_array);
      double value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   double Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, double value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }

   double Shift()
   {
      return Remove(0);
   }
   
   IFloatArray* Slice(int from, int to)
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
      slices[size] = new FloatArraySlice(&this, from, to);
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

   double Remove(int index)
   {
      int size = ArraySize(_array);
      double value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
};