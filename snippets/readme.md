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

## Cooldown

Used to limit trading for a certain amount of time after the trade.

There are two version: OncePerBarCooldownController and TimeRangeCooldownController

### OncePerBarCooldownController

It forbids trading on the same bar. This allows to open not more that 1 order on the same bar.

Usage:

    OncePerBarCooldownController* cooldown;
    int OnInit()
    {
        cooldown = new OncePerBarCooldownController(_Symbol, (ENUM_TIMEFRAMES)_Period);
    }

    void OnDeinit(const int reason)
    {
        delete cooldown;
        cooldown = NULL;
    }

    void OnTick()
    {
        int pos = 0;
        if (!cooldown.IsCooldownPeriod(pos))
        {
            //open order
            cooldown.RegisterTrading(pos);
        }
    }

### TimeRangeCooldownController

Limits number of orders to a selected number in a time range (intraday). It's good for limiting number of orders during the day (or part of the day).

Usage:

    input string start_time = "000000"; // Start time in hhmmss format
    input int max_trades = 2; // Max trades per day

    TimeRangeCooldownController* cooldown;
    int OnInit()
    {
        cooldown = new TimeRangeCooldownController(_Symbol, (ENUM_TIMEFRAMES)_Period, max_trades);
        string error;
        if (!cooldown.Init(start_time, string &error)
        {
            Print(error);
            delete cooldown;
            cooldown = NULL;
            return INIT_FAILED;
        }
    }

    void OnDeinit(const int reason)
    {
        delete cooldown;
        cooldown = NULL;
    }

    void OnTick()
    {
        int pos = 0;
        if (!cooldown.IsCooldownPeriod(pos))
        {
            //open order
            cooldown.RegisterTrading(pos);
        }
    }

## TradingTime

Trading time.

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

## PositionCap

Position cap.

## TradeController

Trade controller.

## Stream

Streams.

## BreakevenController

Breakeven controller.

## TradingMonitor

Monitors trades and orders (creation, deletion, change).

## ClosedTradesIterator

Iterates closed trades.