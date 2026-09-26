# Templates

Templates are skeletons for typical MT5 indicators and expert advisors. They
are **not** meant to be compiled as-is — treat each one as a starting point.

## How to use a template

1. **Pick a template** from the list below and copy it into your terminal's
   `MQL5\Experts` (for EAs) or `MQL5\Indicators` folder.
2. **Enable/disable features** via the `#define` block at the top of the file
   (e.g. `STOP_LOSS_FEATURE`, `TAKE_PROFIT_FEATURE`, `NET_STOP_LOSS_FEATURE`,
   `NET_TAKE_PROFIT_FEATURE`, `MARTINGALE_FEATURE`, `TRADING_TIME_FEATURE`,
   `WEEKLY_TRADING_TIME_FEATURE`, `ACT_ON_SWITCH_CONDITION`,
   `WITH_EXIT_LOGIC`, `USE_MARKET_ORDERS`, `ADVANCED_ALERTS`). Each feature
   wraps its `input` parameters in `#ifdef`; disabled features fall back to
   fixed default variables, so the code stays compilable either way.
3. **Insert your trading logic** at the `// TODO: implement` markers. In EAs
   this means implementing `IsPass(period, date)` in the condition classes
   (`EntryLongCondition`, `EntryShortCondition`) or composing ready-made
   `ICondition` building blocks from `snippets/Conditions/` inside the
   `Create*Condition` factory functions (combine them with
   `AndCondition`/`OrCondition`, run actions on them via
   `actions.AddActionOnCondition`). In indicator templates the markers are
   inside the `OnCalculate` loop or in the alert condition classes.
4. **Resolve the `#include` directives** before compiling in MetaEditor:
   - inject the snippet sources into the file with
     [MQ4Inject](https://github.com/sibvic/MQ4Inject) (works for MQL4 and
     MQL5), or
   - copy the content of `snippets/` into `MQL5\Include`
     (`copy_to_mt.bat` does this with robocopy).
5. Compile in MetaEditor 5 and test on a demo account.

## Template catalog

### EA_Base

Base EA template: multi-symbol trading, stop loss/take profit (incl. net
variants), trailing, martingale, trading-time filters, exit logic,
close-on-opposite and alerts — all toggled by the `#define` block. Entry
logic goes into `EntryLongCondition`/`EntryShortCondition`, exit logic into
the `CreateExit*Condition` factories.

### indicator

Indicator base template (separate window, single buffer, bars limit, unique
object-prefix handling).

### arrows_indicator

Indicator that draws signal arrows and fires alerts (popup/push/email/sound
and optional advanced alerts). Implement `UpAlertCondition` and
`DownAlertCondition`.

### dashboard

Dashboard/scanner: colored grid over pairs × timeframes. Implement `IsPass`
in `UpCondition`/`DownCondition` (produced by `ConditionFactory`).

### heatmap

Display heatmap. Implement `LongCondition`/`ShortCondition`.
