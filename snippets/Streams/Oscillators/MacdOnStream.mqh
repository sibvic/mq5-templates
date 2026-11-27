#include <Streams/Averages/EMAOnStream.mqh>
#include <Streams/CustomStream.mqh>

// MACD on stream v1.0
// macd = ema(source, fastlen) - ema(source, slowlen)
// signal = ema(macd, siglen)
// histogram = macd - signal

#ifndef MacdOnStream_IMP
#define MacdOnStream_IMP

class MacdOnStream : public TIStream<double>
{
   TIStream<double>* _source;
   int _references;
   EMAOnStream* _fast;
   EMAOnStream* _slow;
   CustomStream* _macdLine;
   EMAOnStream* _signal;
public:
   MacdOnStream(TIStream<double>* source, const int fastlen, const int slowlen, const int siglen)
   {
      _source = source;
      _source.AddRef();
      _references = 1;
      _fast = new EMAOnStream(_source, fastlen);
      _slow = new EMAOnStream(_source, slowlen);
      _macdLine = new CustomStream(_source);
      _signal = new EMAOnStream(_macdLine, siglen);
   }

   ~MacdOnStream()
   {
      _signal.Release();
      _macdLine.Release();
      _fast.Release();
      _slow.Release();
      _source.Release();
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

   virtual int Size()
   {
      return _source.Size();
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      return false;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return false;
   }

   virtual bool GetValues(const int period, const int count, double &macd[], double &signal[], double &hist[])
   {
      for (int i = count - 1; i >= 0; --i)
      {
         int p = period - i;
         double fast[1];
         double slow[1];
         if (!_fast.GetValues(p, 1, fast) || !_slow.GetValues(p, 1, slow))
         {
            return false;
         }
         macd[i] = fast[0] - slow[0];
         _macdLine.SetValue(p, macd[i]);
         double signalVal[1];
         if (!_signal.GetValues(p, 1, signalVal))
         {
            signal[i] = EMPTY_VALUE;
            hist[i] = EMPTY_VALUE;
            continue;
         }
         signal[i] = signalVal[0];
         hist[i] = macd[i] - signal[i];
      }
      return true;
   }
};

#endif
