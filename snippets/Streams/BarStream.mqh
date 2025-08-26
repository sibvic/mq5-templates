// Bar stream v2.1

#include <Streams/IBarStream.mqh>

#ifndef BarStream_IMP
#define BarStream_IMP

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _referenceCount;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   virtual void AddRef()
   {
      ++_referenceCount;
   }
   virtual void Release()
   {
      --_referenceCount;
      if (_referenceCount == 0)
         delete &this;
   }
   
   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = Size() - iBarShift(_symbol, _timeframe, date) + 1;
      return true;
   }
   
   virtual bool GetDate(const int period, datetime &dt)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      dt = iTime(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos || oldPos < 0)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos + count - 1 || oldPos < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int oldPos, const int count, double &val[])
   {
      int size = Size();
      if (size <= oldPos + count - 1 || oldPos < 0)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual void Refresh() { }
};

#endif