// Array v1.8
#include <PineScript/Array/IArray.mqh>
#include <PineScript/Array/LineArray.mqh>
#include <PineScript/Array/IntArray.mqh>
#include <PineScript/Array/FloatArray.mqh>
#include <PineScript/Array/BoxArray.mqh>
#include <PineScript/Array/LineArray.mqh>
#include <PineScript/Array/CustomTypeArray.mqh>

class Array
{
public:
   template <typename ARRAY_TYPE>
   static void Clear(ARRAY_TYPE array) { if (array == NULL) { return; } array.Clear(); }
   
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE First(ARRAY_TYPE array, VALUE_TYPE defaultValue)
   {
      if (array == NULL || array.Size() == 0) { return defaultValue; } 
      return array.Get(0);
   }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Last(ARRAY_TYPE array, VALUE_TYPE defaultValue)
   {
      if (array == NULL || array.Size() == 0) { return defaultValue; } 
      return array.Get(array.Size() - 1);
   }

   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static int IndexOf(ARRAY_TYPE array, VALUE_TYPE value)
   {
      if (array == NULL)
      {
         return -1;
      }
      for (int i = 0; i < array.Size(); ++i)
      {
         if (value == array.Get(i))
         {
            return i;
         }
      }
      return -1;
   }
   
   template <typename ARRAY_TYPE, typename DUMMY_TYPE1, typename DUMMY_TYPE2, typename DUMMY_TYPE3>
   static ARRAY_TYPE Slice(ARRAY_TYPE array, int from, int to, ARRAY_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Slice(from, to); }
   
   static void Sort(IIntArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   static void Sort(IFloatArray* array, string order) { if (array == NULL) { return; } array.Sort(order == "ascending"); }
   
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Unshift(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Unshift(value); }
   
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int Size(ARRAY_TYPE array, int defaultValue) { if (array == NULL) { return INT_MIN;} return array.Size(); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Shift(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Shift(); }

   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Push(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Push(value); }
  
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Pop(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Pop(); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE, typename dummy>
   static VALUE_TYPE Get(ARRAY_TYPE array, int index, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Get(index); }
   
   template <typename ARRAY_TYPE, typename DUMMY_TYPE, typename VALUE_TYPE>
   static void Set(ARRAY_TYPE array, int index, VALUE_TYPE value) { if (array == NULL) { return; } array.Set(index, value); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Remove(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Remove(index); }

   template <typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE Copy(ARRAY_TYPE array, ARRAY_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Copy(); }

   template<typename TYPE>
   static double PercentRank(ISimpleTypeArray<TYPE>* array, int index, TYPE emptyValue)
   {
      int arraySize = array.Size();
      if (array == NULL || arraySize == 0 || arraySize <= index) { return emptyValue; }
      int target = array.Get(index);
      if (target == emptyValue)
      {
         return emptyValue;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         int current = array.Get(i);
         if (current != emptyValue && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   static double PercentRank(ISimpleTypeArray<int>* array, int index) { return PercentRank<int>(array, index, INT_MIN); }
   static double PercentRank(ISimpleTypeArray<double>* array, int index) { return PercentRank<double>(array, index, EMPTY_VALUE); }
   
   template<typename TYPE>
   static TYPE Max(ISimpleTypeArray<TYPE>* array, int nth, TYPE emptyValue)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return emptyValue;
      }
      TYPE maxVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         TYPE val = array.Get(i);
         if (maxVal < val)
         {
            maxVal = val;
         }
      }
      return maxVal;
   }
   static double Max(ISimpleTypeArray<double>* array, int nth) { return Max<double>(array, nth, EMPTY_VALUE); }
   static int Max(ISimpleTypeArray<int>* array, int nth) { return Max<int>(array, nth, INT_MIN); }
   
   template<typename TYPE>
   static TYPE Min(ISimpleTypeArray<TYPE>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return EMPTY_VALUE;
      }
      TYPE minVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         TYPE val = array.Get(i);
         if (minVal > val)
         {
            minVal = val;
         }
      }
      return minVal;
   }
   static double Min(ISimpleTypeArray<double>* array, int nth) { return Min<double>(array, nth); }
   static int Min(ISimpleTypeArray<int>* array, int nth) { return Min<int>(array, nth); }

   template<typename TYPE>
   static TYPE Sum(ISimpleTypeArray<TYPE>* array, TYPE emptyValue)
   {
      if (array == NULL || array.Size() == 0)
      {
         return emptyValue;
      }
      TYPE sum = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static double Sum(ISimpleTypeArray<double>* array) { return Sum<double>(array, EMPTY_VALUE); }
   static int Sum(ISimpleTypeArray<int>* array) { return Sum<int>(array, INT_MIN); }
   
   template<typename TYPE>
   static double Avg(ISimpleTypeArray<TYPE>* array, TYPE emptyValue)
   {
      if (array == NULL || array.Size() == 0)
      {
         return emptyValue;
      }
      return Sum(array) / array.Size();
   }
   static double Avg(ISimpleTypeArray<double>* array) { return Avg<double>(array, EMPTY_VALUE); }
   static double Avg(ISimpleTypeArray<int>* array) { return Avg<int>(array, INT_MIN); }
   
   template<typename T1, typename T2>
   static double Covariance(ISimpleTypeArray<T1>* array1, ISimpleTypeArray<T2>* array2)
   {
      if (array1 == NULL || array2 == NULL || array1.Size() != array2.Size())
      {
         return 0;
      }
      double avg1 = Avg(array1);
      double avg2 = Avg(array2);
      double sum = 0;
      for (int i = 0; i < array1.Size(); ++i)
      {
         sum = sum + (array1.Get(i) - avg1) * (array2.Get(i) - avg2);
      }
      return sum / array1.Size();
   }
   static double Covariance(ISimpleTypeArray<int>* array1, ISimpleTypeArray<int>* array2) { return Covariance<int, int>(array1, array2); }
   static double Covariance(ISimpleTypeArray<double>* array1, ISimpleTypeArray<double>* array2) { return Covariance<double, double>(array1, array2); }
   static double Covariance(ISimpleTypeArray<int>* array1, ISimpleTypeArray<double>* array2) { return Covariance<int, double>(array1, array2); }
   static double Covariance(ISimpleTypeArray<double>* array1, ISimpleTypeArray<int>* array2) { return Covariance<double, int>(array1, array2); }
   
   template<typename TYPE>
   static double Stdev(ISimpleTypeArray<TYPE>* array, TYPE emptyValue)
   {
      if (array == NULL)
      {
         return emptyValue;
      }
      double sum = 0;
      double ssum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += array.Get(i);
         ssum += MathPow(size, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
   static double Stdev(ISimpleTypeArray<int>* array) { return Stdev<int>(array, INT_MIN); }
   static double Stdev(ISimpleTypeArray<double>* array) { return Stdev<double>(array, EMPTY_VALUE); }
   
   template<typename TYPE>
   static double Variance(ISimpleTypeArray<TYPE>* array, bool biased, TYPE emptyValue)
   {
      if (array == NULL || !biased)
      {
         return emptyValue;
      }
      double avg = Avg(array);
      double sum = 0;
      int size = array.Size();
      for (int i = 0; i < size; i++)
      {
         sum += MathPow(array.Get(i) - avg, 2);
      }
      return sum / size;
   }
   static double Variance(ISimpleTypeArray<int>* array, bool biased) { return Variance<int>(array, biased, INT_MIN); }
   static double Variance(ISimpleTypeArray<double>* array, bool biased) { return Variance<double>(array, biased, EMPTY_VALUE); }
};

