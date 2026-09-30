# ADR-002: Price field scale

- **Date:** 2026-08-19
- **Status:** Accepted

## Context

The decimal scale of the 32-bit `price` field was undocumented. That's a classic source of unit-mismatch bugs between the RTL and any software reference model, and it had to be fixed before writing notional and price-collar risk checks.

## Options considered

1. Cents (2 implied decimal places).
2. Ten-thousandths (4 implied decimal places), matching NASDAQ TotalView-ITCH's `Price(4)` format.

## Decision

Option 2: the integer field represents **price × 10,000**.

## Reasoning

This isn't an arbitrary internal convention; it's the format real ITCH feeds have used for over a decade. It strictly generalizes the cents option (standard equity prices fit with room to spare, and finer-grained instruments like FX are covered too). Integer fixed-point also keeps money arithmetic exact and cheap in hardware, with no floating-point rounding.

## Consequences

- Maximum representable price in 32 bits is about 429,496.7295, comfortably above ITCH's own `Price(4)` maximum of 200,000.0000.
- All future notional and price-collar arithmetic in the risk unit must be written against this scale. Notional (price × quantity) needs a 64-bit product.

## Verification

No RTL change was needed: the field was already a generic 32-bit unsigned integer. This ADR fixes its documented meaning. Existing test-vector literals predate the decision and are being re-annotated in the 4-decimal convention.
