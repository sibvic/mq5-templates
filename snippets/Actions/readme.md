# Actions

Executes an action. Supports reference counting.

## IAction

Action interface.

### DoAction

Executes an action. Returns true if the action was executed successfully.

## AAction

Implements reference counting for the IAction.

## TrailingPipsAction

Keeps stop loss distance to the orders to the defined amount of pips.

## CloseTradeAction

Closes trade.

## CreateHiddenTPSLControllerAction

Creates hidden take profit and stop loss controller.

## CreateMartingaleAction

Creates martingale position.

## EntryAction

Entry action.

## CreateTrailingAction

Creates trailing action for the order. Start could be specified in pips or % of stop loss.