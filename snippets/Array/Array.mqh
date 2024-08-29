// Array v1.0
#include <Array/IArray.mqh>

class Array : public IArray
{
   double array[];
public:
   Array(int size)
   {
      ArrayResize(array, size);
   }

   void Unshift(double value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      array[size] = value;
      return value;
   }

   int Size()
   {
      return ArraySize(array);
   }

   void Push(double value)
   {
      int size = ArraySize(array);
      ArrayResize(array, size + 1);
      array[size] = value;
   }

   double Pop()
   {
      int size = ArraySize(array);
      double value = array[0];
      for (int i = 0; i < size - 1; ++i)
      {
         array[i] = array[i + 1];
      }
      ArrayResize(array, size - 1);
      return value;
   }

   double Get(int index)
   {
      return array[index];
   }
};