// Pine-script like safe operations
// v1.3

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
bool ParameterDefined(double p) { return p != EMPTY_VALUE; }
bool ParameterDefined(int p) { return p != INT_MIN; }
bool ParameterDefined(string p) { return p != NULL; }
template <typename T1, typename T2>
bool BothParametersDefined(T1 left, T2 right) { return ParameterDefined(left) && ParameterDefined(right); }

template <typename T1, typename T2>
double SafePlus(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return left + right;
}

template <typename T1, typename T2>
double SafeMinus(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return left - right;
}
int SafeMinus(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return left - right;
}

template <typename T1, typename T2>
double SafeDivide(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right) || right == 0) { return EMPTY_VALUE; }
   return left / right;
}

template <typename T1, typename T2>
double SafeMultiply(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return left * right;
}
int SafeMultiply(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return left * right;
}

template <typename T1, typename T2>
bool SafeGreater(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left > right;
}

template <typename T1, typename T2>
bool SafeGE(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left >= right;
}

template <typename T1, typename T2>
bool SafeLess(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left < right;
}

template <typename T1, typename T2>
bool SafeLE(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return false; }
   return left <= right;
}

template <typename T>
double SafeMathExp(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathExp(value);
}

template <typename T1, typename T2>
double SafeMathMax(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return MathMax(left, right);
}
int SafeMathMax(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return MathMax(left, right);
}

template <typename T1, typename T2, typename T3>
double SafeMathMax(T1 param1, T2 param2, T3 param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}
int SafeMathMax(int param1, int param2, int param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return INT_MIN;
   }
   return MathMax(MathMax(param1, param2), param3);
}

template <typename T1, typename T2>
double SafeMathMin(T1 left, T2 right)
{
   if (!BothParametersDefined(left, right)) { return EMPTY_VALUE; }
   return MathMin(left, right);
}
int SafeMathMin(int left, int right)
{
   if (!BothParametersDefined(left, right)) { return INT_MIN; }
   return MathMin(left, right);
}

template <typename T1, typename T2, typename T3>
double SafeMathMin(T1 param1, T2 param2, T3 param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
}
int SafeMathMin(int param1, int param2, int param3)
{
   if (!ParameterDefined(param1) || !ParameterDefined(param2) || !ParameterDefined(param3))
   {
      return INT_MIN;
   }
   return MathMin(MathMin(param1, param2), param3);
}

template <typename T1, typename T2>
double SafeMathPow(T1 value, T2 power)
{
   if (!BothParametersDefined(value, power)) { return EMPTY_VALUE; }
   return MathPow(value, power);
}

template <typename T>
double SafeMathAbs(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathAbs(value);
}

template <typename T>
double SafeMathRound(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathRound(value);
}

template <typename T>
double SafeMathRound(T value, int precision)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return NormalizeDouble(value, precision);
}

template <typename T>
double SafeMathSqrt(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathSqrt(value);
}

template <typename T>
int SafeSign(T value)
{
   if (!ParameterDefined(value)) { return INT_MIN; }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

template <typename T>
double SafeLog(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathLog(value);
}
template <typename T>
double SafeLog10(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathLog10(value);
}
template <typename T>
double SafeCos(T value) 
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathCos(value);
}
template <typename T>
double SafeArccos(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathArccos(value);
}
template <typename T>
double SafeSin(T value) 
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathSin(value);
}
template <typename T>
double SafeArcsin(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathArcsin(value);
}
template <typename T>
double SafeTan(T value) 
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathTan(value);
}
template <typename T>
double SafeArctan(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return MathArctan(value);
}
template <typename T>
double InvertSign(T value)
{
   if (!ParameterDefined(value)) { return EMPTY_VALUE; }
   return -value;
}
template <typename T>
int SafeMathCeil(T value)
{
   if (!ParameterDefined(value)) { return INT_MIN; }
   return (int)MathCeil(value);
}
double SafeMod(int val1, int val2)
{
   if (val1 == INT_MIN || val2 == INT_MIN)
   {
      return EMPTY_VALUE;
   }
   return val1 % val2;
}