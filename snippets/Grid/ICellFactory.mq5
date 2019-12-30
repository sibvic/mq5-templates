// Interface for a cell factory v1.0

#include <ICell.mq5>

#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
};

#endif