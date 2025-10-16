// Object destructor interface v1.0

#ifndef IObjectDestructor_IMPL
#define IObjectDestructor_IMPL
template<typename T>
class IObjectDestructor
{
public:
   virtual void Free(T obj) = 0;
};
#endif