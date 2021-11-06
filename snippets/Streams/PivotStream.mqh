//Pivot stream v1.1

#include <AStream.mqh>

enum PivotStreamType
{
   PivotStreamP,
   PivotStreamS1,
   PivotStreamS2,
   PivotStreamS3,
   PivotStreamR1,
   PivotStreamR2,
   PivotStreamR3
};

class PivotStream : public AStream
{
   ENUM_TIMEFRAMES _chartTimeframe;
   PivotStreamType _stream;
public:
   PivotStream(string symbol, ENUM_TIMEFRAMES timeframe, ENUM_TIMEFRAMES chartTimeframe, PivotStreamType stream)
      :AStream(symbol, timeframe)
   {
      _chartTimeframe = chartTimeframe;
      _stream = stream;
   }

   bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         int btf_i = iBarShift(_symbol, _timeframe, iTime(NULL, _chartTimeframe, i + period));
         if (btf_i == -1)
         {
            return false;
         }
         double p, s1, s2, s3, r1, r2, r3;
         if (!CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3))
         {
            return false;
         }
         switch (_stream)
         {
            case PivotStreamP:
               val[i] = p;
               break;
            case PivotStreamS1:
               val[i] = s1;
               break;
            case PivotStreamS2:
               val[i] = s2;
               break;
            case PivotStreamS3:
               val[i] = s3;
               break;
            case PivotStreamR1:
               val[i] = r1;
               break;
            case PivotStreamR2:
               val[i] = r2;
               break;
            case PivotStreamR3:
               val[i] = r3;
               break;
         }
      }
      return true;
   }

private:
   bool CalcPivot(const int i, double &p, 
      double &s1, double &s2, double &s3,
      double &r1, double &r2, double &r3)
   {
      ResetLastError();
      double high  = iHigh(_symbol, _timeframe, i+1);
      int error = GetLastError();
      switch (error)
      {
         case ERR_HISTORY_NOT_FOUND:
            {
               static bool ERR_HISTORY_NOT_FOUND_printed = false;
               if (!ERR_HISTORY_NOT_FOUND_printed)
               {
                  Print("No history");
                  ERR_HISTORY_NOT_FOUND_printed = true;
               }
            }
            return false;
      }
      double low   = iLow(_symbol, _timeframe, i+1);
      double open  = iOpen(_symbol, _timeframe, i+1);
      double close = iClose(_symbol, _timeframe, i+1);
      p = (high + low + close) / 3;
      r1 = (2 * p) - low;
      s1 = (2 * p) - high;
      r2 = p + (high - low);
      s2 = p - (high - low);
      r3 = p + (high - low) * 2;
      s3 = p - (high - low) * 2;
      return true;
   }
};