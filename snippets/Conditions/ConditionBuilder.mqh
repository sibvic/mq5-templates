#include <OrCondition.mqh>
#include <AndCondition.mqh>

// Condition builder v1.0

// Parses conditions defined in a string for (like 1 and 2 or 3) and create them.
// Supported features:
// - and
// - or

class ConditionBuilder
{
   ICondition* current;
public:
   ConditionBuilder()
   {
      current;
   }

   ICondition* Get()
   {
      return current;
   }

   void Add(ICondition* condition)
   {
      if (current == NULL)
      {
         current = condition;
         return;
      }
      AndCondition* and = dynamic_cast<AndCondition*>(current);
      if (and != NULL)
      {
         and.Add(condition, false);
         return;
      }
      OrCondition* or = dynamic_cast<OrCondition*>(current);
      if (or != NULL)
      {
         or.Add(condition, false);
         return;
      }
      Print("Error in conditions");
   }

   void And()
   {
      if (current == NULL)
      {
         Print("Error in conditions");
         return;
      }
      AndCondition* and = dynamic_cast<AndCondition*>(current);
      if (and != NULL)
      {
         return;
      }
      and = new AndCondition();
      and.Add(current, false);
      current = and;
   }

   void Or()
   {
      if (current == NULL)
      {
         Print("Error in conditions");
         return;
      }
      OrCondition* or = dynamic_cast<OrCondition*>(current);
      if (or != NULL)
      {
         return;
      }
      or = new OrCondition();
      or.Add(current, false);
      current = or;
   }
};

ICondition* CreateRules(string rules)
{
   ConditionBuilder builder;
   string items[];
   StringSplit(rules, ' ', items);
   for (int i = 0; i < ArraySize(items); ++i)
   {
      if (items[i] == "1")
      {
         //builder.Add(new Rule1Condition(symbol, timeframe));
      } else if (items[i] == "and")
      {
         builder.And();
      }
      else if (items[i] == "or")
      {
         builder.Or();
      }
   }
   return builder.Get();
}
