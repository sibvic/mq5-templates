// Conversion to string v1.1

string ToString(int value, string format)
{
   if (format == "percent")
   {
      return IntegerToString(value, 2) + "%";
   }
   return IntegerToString(value);
}
string ToString(double value, string format)
{
   if (format == "percent")
   {
      return DoubleToString(value, 2) + "%";
   }
   return DoubleToString(value);
}
string ToString(double value)
{
   return DoubleToString(value);
}
string ToString(int value)
{
   return IntegerToString(value);
}