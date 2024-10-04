// syminfo.* functions from Pine Script
// v1.0

class SymInfo
{
public:
   static double Mintick(string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   
   static string Ticker()
   {
      return _Symbol;
   }
};