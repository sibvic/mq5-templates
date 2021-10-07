# Conditions

## ICondition

Condition interface.

## ACondition

Condition base.

## DisabledCondition

Disabled condition. Always returns false.

## ProfitInRangeCondition

Returns true when profit of the order in the specified range.

## TradingTimeCondition

Trading time condition.

## NotCondition

Inverts another condition.

## bar_conditions

Bar conditions.

## bb_conditions

Bands conditions.

## divergence_conditions

Conditions for detecting a divergence.

## PositionLimitHitCondition

Position limit hit condition.

## StreamLevelCondition

Stream-level condition.

## StreamStreamCondition

Stream-stream condition.

## ConditionBuilder

Parses conditions defined in a string for (like 1 and 2 or 3) and create them.

Supported features:
 - and
 - or

## AndCondition

Returns true when all conditions returns true.

## OrCondition

Return true when at least one of the conditions returns true.

## MinDistanceSinceLastTradeCondition

Condition is true when there is enoght distance since last trade