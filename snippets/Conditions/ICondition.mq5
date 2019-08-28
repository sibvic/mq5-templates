// ICondition v1.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};
#endif