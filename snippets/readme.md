# Snippets

## Signaler

Sends alerts: popup message, push notification, email, sound alert and external target (Telegram, Discord, other trading platforms/bots).

Usage:

    input string start_time = "000000"; // Start time in hhmmss format
    input string stop_time = "000000"; // Stop time in hhmmss format

    Signaler* signaler;
    int OnInit()
    {
        signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
    }

    void OnDeinit(const int reason)
    {
        delete signaler;
        signaler = NULL;
    }

    void OnCalculate() // or void OnTick() for EA's
    {
        signaler.SendNotifications("Alert subject", "Alert text", _Symbol, "M1");
        //or
        signaler.SendNotifications(ENTER_BUY_SIGNAL);
    }

## InstrumentInfo

Provides information about instrument.

## TradesIterator

Iterates trades.

## TradingCalculator

Trading calculator.

## Condition

Conditions.

## MoneyManagement

Money management.

## OrdersIterator

Iterates orders.

## TradingCommands

Trading commands.

## TrailingController

Trailing logic.

## MarketOrderBuilder

Market order builder.

## TradeController

Trade controller.

## BreakevenController

Breakeven controller.

## ClosedTradesIterator

Iterates closed trades.

## AlertSignal

Draws an arrow on condition.

## NetStopLoss

Net stop loss logic.

## NetTakeProfit

Net take profit logic.

## Routines

Usefull functions.

## Order

Order entity.

## OrderBuilder

Helps to build a create order command.

## EntryPositionController

Entry position controller.

## OrderHandlers

Creates actions for new orders.