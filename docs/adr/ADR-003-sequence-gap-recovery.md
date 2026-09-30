# ADR-003: Sequence-gap recovery

- **Date:** 2026-08-19
- **Status:** Accepted (implementation is the next milestone)

## Context

`sequence_error` is a sticky flag with no way to clear it short of a full reset. A book that has missed a message can't be trusted, so the flag must stay set, but there has to be a defined path back to a trustworthy book. The open questions were: what clears the flag, what the sequence baseline re-anchors to, and whether recovery should re-request the missed messages.

## Options considered

1. **Retransmission:** request the missed range and replay it into the book.
2. **Snapshot-only resync:** wait for a snapshot message that carries the full current state, and rebuild from it.

## Decision

Option 2. A snapshot message (type `10`) carries its own sequence number, which becomes the new baseline (`last_seq`), and it clears `sequence_error` unconditionally.

## Reasoning

This mirrors how MoldUDP64 / ITCH feeds are consumed in practice: a gapped consumer resyncs from a snapshot rather than trying to patch holes in place. Retransmission requires a request path back to the feed source, which is out of scope for this project (no real exchange connectivity).

## Consequences

- The control-message handler (roadmap week 4) is unblocked.
- The decoder must accept message type `10` in addition to `01`.
- Between a gap and the next snapshot, `sequence_error` stays high, so the risk unit can reject orders while the book is untrustworthy.

## Verification (planned)

Gap followed by snapshot clears the error and re-anchors the sequence; gap with no snapshot keeps the error set; in-order updates after a snapshot don't raise a false gap.
