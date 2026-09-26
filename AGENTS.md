# AGENTS.md

## Project overview

MQL5/MetaTrader 5 template library designed to speed up development of
typical indicators and expert advisors (EAs). Maintained by Victor
Tereschenko (ProfitRobots), primarily to support the
[Trade Script Converter](https://convertor.profitrobots.com) and PineScript →
MQL5 conversions (the `snippets/PineScript` folder mirrors PineScript APIs).

Repository: https://github.com/sibvic/mq5-templates

## Repository layout

- `templates/` — ready-to-use `.mq5` skeletons (indicators, dashboards, EA).
  See `templates/readme.md` for the catalog and usage instructions.
- `snippets/` — reusable `.mqh` include library used by the templates.
  Notable folders:
  - `Conditions/` — `ICondition` building blocks (see below). Most trading
    logic is expressed as conditions.
  - `Actions/` — `IAction` building blocks executed when conditions pass.
  - `Streams/` — data stream abstraction (price/indicator series,
    subfolders: `Interfaces`, `Averages`, `Oscillators`, `indicators`,
    `Condition`, `Custom`, `Plots`, ...).
  - `Logic/`, `MoneyManagement/`, `Grid/`, `TradingMonitor/`, `enums/`,
    `PineScript/` and various top-level helpers (`TradingController.mqh`,
    `OrderBuilder.mqh`, `MarketOrderBuilder.mqh`, `Signaler.mqh`,
    `InstrumentInfo.mqh`, `TradingCalculator.mqh`, ...).
  - `Expert/`, `Trade/`, `Math/`, `Generic/`, `OpenCL/`, `Controls/`,
    `Graphics/`, `WinAPI/`, `Files/`, `Indicators/`, `Objects/`, `Charts/`,
    `ChartObjects/`, `Canvas/`, `Strings/`, `Tools/`, `Arrays/` — vendored
    copies of the MetaTrader 5 standard library, kept in sync with
    `MQL5\Include`. Generally don't edit these; prefer the project's own
    snippets.
- `snippets/readme.md` — per-snippet usage docs. Keep it updated when adding
  snippets.

## How the templates work

Templates are *not* compiled as-is. Workflow:

1. Copy a template from `templates/` into the target `MQL5\Experts` or
   `MQL5\Indicators` folder.
2. Enable/disable features via the `#define` / `#ifdef` block at the top of
   the file (e.g. `STOP_LOSS_FEATURE`, `TAKE_PROFIT_FEATURE`,
   `NET_STOP_LOSS_FEATURE`, `NET_TAKE_PROFIT_FEATURE`,
   `MARTINGALE_FEATURE`, `TRADING_TIME_FEATURE`,
   `WEEKLY_TRADING_TIME_FEATURE`, `ACT_ON_SWITCH_CONDITION`,
   `WITH_EXIT_LOGIC`, `USE_MARKET_ORDERS`, `ADVANCED_ALERTS`).
   Commented-out defines produce plain (non-input) variables with fixed
   defaults instead of `input` parameters.
3. Fill in the trading logic at the `// TODO: implement` / `//TODO:`
   markers — usually by implementing
   `IsPass(const int period, const datetime date)` in condition classes
   (`EntryLongCondition`, `EntryShortCondition`, `LongCondition`,
   `ShortCondition`, `UpCondition`, `DownCondition`, ...) or composing
   existing `ICondition` snippets inside the `Create*Condition` factory
   functions.
4. Resolve `#include <...>` directives before compiling in MetaEditor,
   either by:
   - injecting snippet sources with
     [MQ4Inject](https://github.com/sibvic/MQ4Inject) (supports MQL4 and
     MQL5), or
   - copying `snippets/` content into `MQL5\Include` (see `copy_to_mt.bat`).

Advanced alerts (`ADVANCED_ALERTS`, e.g. Telegram/Discord) need the
[mt-notifications-lib](https://github.com/sibvic/mt-notifications-lib) DLL
("AdvancedNotificationsLib").

## Key abstractions

### ICondition — the main building block

`snippets/Conditions/ICondition.mqh`:

```mql5
interface ICondition
{
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
```

- Entry/exit logic in `EA_Base.mq5` is implemented as condition classes
  inherited from `ACondition`, each returning `bool` from `IsPass`.
- Conditions are composed with `AndCondition` / `OrCondition` /
  `NotCondition`, combined in `CreateLongCondition` /
  `CreateShortCondition` / `CreateLongFilterCondition` /
  `CreateShortFilterCondition` / `CreateExit*Condition` factory functions.
- `ActOnSwitchCondition` wraps a condition to fire once on the rising edge
  (enabled by `ACT_ON_SWITCH_CONDITION`); `DisabledCondition` /
  `NoCondition` are neutral placeholders.
- `condition.Add(child, false)` — the second arg controls ownership/release.
- Ready conditions in `snippets/Conditions/` cover bar/BB/ichimoku/MA
  comparisons, divergences, candle `patterns/`, session & trading-time
  filters, position limits, profit ranges, stream comparisons
  (`StreamLevelCondition`, `StreamStreamCondition`), etc. Prefer reusing
  them over writing new logic.
- `IConditionFactory` produces per-symbol/timeframe conditions (used by the
  dashboard template).
- Legacy note: top-level `snippets/Condition.mqh` defines an older
  `IsPass(period)` variant — the `Conditions/` folder versions are current.

### IAction — what to do when a condition passes

`snippets/Actions/` + `ActionOnConditionLogic`. Registered via
`actions.AddActionOnCondition(action, condition)` inside the controller
setup; `AOrderAction`/`orderHandlers` run actions for each newly opened
position (ticket available in `_currentTicket`).

### Streams

`IStream`/stream classes under `snippets/Streams/` provide timeseries-style
data (access by bar index); `EntryStreamData` is passed to entry conditions.

### Trading

`CTrade tradeManager` (`Trade\Trade.mqh`) is the shared trade object;
`OrderBuilder`/`MarketOrderBuilder` build and execute orders. Mind MT5
hedging vs netting account modes when writing position logic
(`NET_*_FEATURE` flags relate to net stop loss / take profit).

## Coding conventions

- MQL5 with `#property strict`; `.mqh` includes use `#ifndef X_IMP /
  #define X_IMP` include guards.
- Interfaces are prefixed `I` (`ICondition`, `IAction`, `IStream`,
  `IConditionFactory`), abstract bases `A` (`ACondition`, `AConditionBase`,
  `AOrderAction`, `AAction`).
- Reference counting instead of `delete`: objects implementing `AddRef()`/
  `Release()` are passed around as `I*` pointers; call `Release()` after
  handing ownership to containers (`condition.Add(x, false)` takes
  ownership — follow the existing factories' pattern).
- Feature toggles: `#ifdef FEATURE` wraps `input` declarations with an
  `#else` branch declaring plain variables with the same names — keep both
  branches in sync when adding parameters.
- Templates/snippets carry a version comment (`// Name vX.Y`); bump it when
  editing.
- `input` parameters use `snake_case`; comments after `//` document the
  input label.
- Snippets reference each other via angle-bracket includes
  (`#include <Conditions/ACondition.mqh>`), assuming `snippets/` root is on
  the include path.
- No build system, tests, or CI — verification is compiling in MetaEditor 5.

## Related repositories

- MQ4Inject — include injector: https://github.com/sibvic/MQ4Inject
- fxlint — lint utility: https://github.com/sibvic/fxlint
- Sibling template packs: mq4, fxts2, pinescript, nt8 (same structure).
