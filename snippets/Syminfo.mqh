double SyminfoMintick(string symbol)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   return point * mult;
}