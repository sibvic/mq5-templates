// str.* functions from Pine Script
// v1.1

class Str
{
public:
   static string ToString(int value, string format)
   {
      if (value == INT_MIN)
      {
         return "NaN";
      }
      if (format == "percent")
      {
         return IntegerToString(value, 2) + "%";
      }
      if (format == "$")
      {
         return "$" + IntegerToString(value);
      }
      if (format == "mintick")
      {
         int dec = DigitsForMintick(MintickFromPoint());
         return DoubleToString((double)value, dec);
      }
      if (format == "volume")
      {
         return IntegerToString(value);
      }
      if (format != "")
      {
         string hashFmt;
         if (TryApplyHashDecimalFormat((double)value, format, hashFmt))
            return hashFmt;
      }
      return IntegerToString(value);
   }
   static string ToString(double value, string format)
   {
      if (value == EMPTY_VALUE)
      {
         return "NaN";
      }
      if (format == "percent")
      {
         return DoubleToString(value, 2) + "%";
      }
      if (format == "$")
      {
         return "$" + DoubleToString(value, 2);
      }
      if (format == "mintick")
      {
         int dec = DigitsForMintick(MintickFromPoint());
         return DoubleToString(value, dec);
      }
      if (format == "volume")
      {
         return DoubleToString(value, 0);
      }
      string valueStr = DoubleToString(value);
      if (format != "")
      {
         string hashFmt;
         if (TryApplyHashDecimalFormat(value, format, hashFmt))
            return hashFmt;
         StringReplace(format, "#.#", valueStr);
         return format;
      }
      return valueStr;
   }
   static string ToString(double value)
   {
      if (value == EMPTY_VALUE)
      {
         return "NaN";
      }
      return DoubleToString(value);
   }
   static string ToString(int value)
   {
      if (value == INT_MIN)
      {
         return "NaN";
      }
      return IntegerToString(value);
   }
   static string ToString(string value)
   {
      return value;
   }
   static string ReplaceAll(string source, string target, string replaceWith)
   {
      StringReplace(source, target, replaceWith);
      return source;
   }
   static bool Contains(string source, string str)
   {
      return StringFind(source, str) != -1;
   }
   static double ToNumber(string str)
   {
      return StringToDouble(str);
   }
   static int Length(string str)
   {
      return StringLen(str);
   }

private:
   // MQL5: SymbolInfoDouble(Symbol(), SYMBOL_POINT) replaces MQL4 MarketInfo(Symbol(), MODE_POINT)
   static double MintickFromPoint()
   {
      double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
      int mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   static int DigitsForMintick(double mintick)
   {
      if (mintick <= 0)
         return (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
      int d = 0;
      double x = mintick;
      while (d < 16 && MathAbs(x - MathRound(x)) > 1e-8)
      {
         x *= 10.0;
         d++;
      }
      return d;
   }
   // "#.#", "#.##", "##.###", ... — # after '.' sets DoubleToString precision
   static bool TryApplyHashDecimalFormat(double value, string format, string &outResult)
   {
      int len = StringLen(format);
      for (int dotPos = 0; dotPos < len; dotPos++)
      {
         if (StringGetCharacter(format, dotPos) != '.')
            continue;
         int leftHash = 0;
         for (int i = dotPos - 1; i >= 0; i--)
         {
            if (StringGetCharacter(format, i) != '#')
               break;
            leftHash++;
         }
         if (leftHash == 0)
            continue;
         int rightHash = 0;
         for (int i = dotPos + 1; i < len; i++)
         {
            if (StringGetCharacter(format, i) != '#')
               break;
            rightHash++;
         }
         if (rightHash == 0)
            continue;
         int tokStart = dotPos - leftHash;
         int tokLen = leftHash + 1 + rightHash;
         string num = DoubleToString(value, rightHash);
         outResult = StringSubstr(format, 0, tokStart) + num + StringSubstr(format, tokStart + tokLen);
         return true;
      }
      return false;
   }
};

enum StrFormatValueType
{
   String,
   Integer,
   Float
};
interface IStrFormatValue
{
public:
   virtual StrFormatValueType GetType() = 0;
};
class StrFormatStringValue : public IStrFormatValue
{
   string value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::String;
   }
   
   void SetValue(string val)
   {
      value = val;
   }
   string GetValue()
   {
      return value;
   }
};
class StrFormatIntValue : public IStrFormatValue
{
   int value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Integer;
   }
   
   void SetValue(int val)
   {
      value = val;
   }
   int GetValue()
   {
      return value;
   }
};
class StrFormatDoubleValue : public IStrFormatValue
{
   double value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Float;
   }
   
   void SetValue(double val)
   {
      value = val;
   }
   double GetValue()
   {
      return value;
   }
};
class StrFormat
{
   string format;
   IStrFormatValue* values[];
   int nextValueIndex;
public:
   StrFormat(string format)
   {
      this.format = format;
      nextValueIndex = 0;
   }
   ~StrFormat()
   {
      int size = ArraySize(values);
      for (int i = 0; i < size; ++i)
      {
         delete values[i];
      }
   }
   
   StrFormat* Add(string value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatStringValue();
      }
      ((StrFormatStringValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(int value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatIntValue();
      }
      ((StrFormatIntValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(double value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatDoubleValue();
      }
      ((StrFormatDoubleValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   
   string Format()
   {
      int size = ArraySize(values);
      string res = format;
      for (int i = 0; i < size; ++i)
      {
         int pos = StringFind(res, "{" + IntegerToString(i));
         if (pos < 0)
         {
            continue;
         }
         int end = StringFind(res, "}", pos + 1);
         if (end < 0)
         {
            continue;
         }
         switch (values[i].GetType())
         {
         case StrFormatValueType::String:
            {
               string strValue = ((StrFormatStringValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + strValue + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Integer:
            {
               int intValue = ((StrFormatIntValue*)values[i]).GetValue();
               string numberFormat = StringSubstr(res, pos + 1, end - pos - 1);
               res = StringSubstr(res, 0, pos) + FormatWithNumberPattern((double)intValue, numberFormat, true) + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Float:
            {
               double doubleValue = ((StrFormatDoubleValue*)values[i]).GetValue();
               string numberFormat = StringSubstr(res, pos + 1, end - pos - 1);
               res = StringSubstr(res, 0, pos) + FormatWithNumberPattern(doubleValue, numberFormat, false) + StringSubstr(res, end + 1);
            }
            break;
         }
      }
      nextValueIndex = 0;
      return res;
   }
private:
   // {index,number,#.#} / {0,number,#.##} — decimals = count of '#' after '.' in the hash pattern (same as Str::TryApplyHashDecimalFormat)
   string FormatWithNumberPattern(double value, string numberFormat, bool sourceIsInt)
   {
      string tokens[];
      int count = StringSplit(numberFormat, ',', tokens);
      if (count < 3 || tokens[1] != "number")
      {
         if (sourceIsInt)
            return IntegerToString((int)value);
         return DoubleToString(value);
      }
      int decimals = HashPatternDecimalPlaces(tokens[2]);
      if (decimals < 0)
      {
         if (sourceIsInt)
            return IntegerToString((int)value);
         return DoubleToString(value);
      }
      return DoubleToString(value, decimals);
   }
   int HashPatternDecimalPlaces(string pattern)
   {
      int pointPos = StringFind(pattern, ".");
      if (pointPos < 0)
         return -1;
      int n = 0;
      int len = StringLen(pattern);
      for (int i = pointPos + 1; i < len; i++)
      {
         if (StringGetCharacter(pattern, i) != '#')
            break;
         n++;
      }
      return n;
   }
};