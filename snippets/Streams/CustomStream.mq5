// CustomStream v1.0

class CustomStream : public IStream
{
protected:
   int _references;
public:
   double _data[];

   CustomStream()
   {
      _references = 1;
   }

   virtual int Size()
   {
      return ArrayRange(_data, 0);
   }
   
   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         if (_data[size - 1 - period + i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period + i];
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }

   void SetSize(int size)
   {
      if (ArrayRange(_data, 0) < size) 
         ArrayResize(_data, size);
   }
};