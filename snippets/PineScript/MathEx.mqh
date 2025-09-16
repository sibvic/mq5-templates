// MathEx v1.0
#ifndef MathEx_IMPL
#define MathEx_IMPL

class MathEx
{
public:
   static double ToRadians(double degreess)
   {
      if (degreess == EMPTY_VALUE)
      {
         return EMPTY_VALUE;
      }
      return degreess * (3.14 / 180);
   }
};

#endif