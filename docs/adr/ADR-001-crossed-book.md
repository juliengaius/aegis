# ADR-001: Crossed-book handling

- **Date:** 2026-08-17
- **Status:** Accepted

## Context

`spread = best_ask_price - best_bid_price` is an unsigned subtraction. If the book ever becomes crossed (ask < bid), which can happen with stale or out-of-order quotes, it wraps to a huge false value that any downstream consumer would trust.

## Options considered

1. Treat any `ask <= bid` (locked or crossed) as unsafe: hold spread and midpoint at 0 and flag both cases the same way.
2. Distinguish the two: a locked market (`ask == bid`) is valid and usable; only a crossed market (`ask < bid`) is unsafe and gates spread and midpoint.

## Decision

Option 2. `crossed_book` asserts only when `ask < bid`. A locked condition is tracked internally (`locked_book`) but not yet exposed as a port.

## Reasoning

Locked markets are legal and common in real trading. Treating them as unsafe would be overly conservative and would complicate the risk engine, which wants a single simple gate: `book_valid && !crossed_book`. A crossed market, by contrast, means the reference price genuinely can't be trusted.

## Consequences

- The pre-trade risk unit can use `book_valid && !crossed_book` directly as its validity gate.
- `locked_book` is available for a stricter risk mode later without changing `top_of_book`.
- `crossed_book` is deliberately **not sticky**, unlike `sequence_error`. A crossed book fixes itself on the next good quote; a missed message does not. This asymmetry is intentional.

## Verification

Added locked, crossed, and same-cycle recovery cases to `top_of_book_tb.sv`, and extended the reset checks to cover `crossed_book`.
