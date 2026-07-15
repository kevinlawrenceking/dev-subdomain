# DIR-LNK-WO-5 — RQ-6 / H-1 PIN (operator relay, verbatim)

**Purpose:** durable pin of the 2026-07-15 operator relay that RULES RQ-6 (a) and stamps H-1, per
G-3. Committed docs-class alongside `DIR-LNK-WO5-PLANLOCK.md` v-final. Reproduced verbatim.

---

```
DIR-LNK-WO-5 — PRE-LOCK ADJUDICATION + RQ-6/H-1 STAMPS + FOLD GO
Numbered items 1-5, END marker. Echo item count.

1. REVIEW VERDICT: pre-lock critique ACCEPTED IN FULL — G-1..G-8 all
   ADOPTED per the architect dispositions transmitted with this relay.
   G-1 is architect-owned errata: reader-code prod exposure was an
   unstated dependency; it is now stated and stamped (H-1).

2. ANSWERS FROM THE RECORD:
   a) RQ-5i: RULED AND PINNED — rulings addendum, commit 1e7af179.
   b) RQ-6: NOT previously ruled; ruled by the item-4 stamp; pin by
      committing this relay verbatim (docs-class) with the v-final lock.
   c) contactdetails: VIEW — 44 cols, SQL SECURITY INVOKER, over
      contactdetails_tbl (V3_8; G0-2b; WO-2 Phase-4). P1 re-confirms
      fresh. WO-4 wrote the _tbl by design; readers read through views
      per house convention.

3. RQ-6 CONSEQUENCE FOR THE RECORD: option (a) means prod's
   _target/_followup/_maint tabs change visibly at WO-12 — contacts
   with inactive enrollments drop off. Correct relationship-system
   semantics; the WO-12 rollout record carries the user-visible-change
   line.

4. OPERATOR STAMP BLOCK (Kevin, 2026-07-15):
   RQ-6: RULED (a) — dev view definitions are truth. WO-5 authors from
         dev's forms including the suStatus='Active' filter; prod
         adopts them at WO-12; the visible prod tab change is accepted.
   H-1:  ACKNOWLEDGED — WO-5 reader code is held from prod until the
         WO-12 atomic sequence (backfill -> prod view flip -> reader
         code). Between WO-5 merge and WO-12, any prod deploy is
         cherry-pick-only from a pre-WO-5 base.

5. GO: fold G-1..G-8 into DIR-LNK-WO5-PLANLOCK v-final; commit
   (docs-class) together with this relay as the RQ-6/H-1 pin; execute
   the P0 remainder and P1 recon (read-only) per v-final; STOP at the
   P1 delta report. The STOP package must include the v-final lock
   verbatim (or full diff vs the proposal) for architect ratification.
   No code changes, no DDL, no DML, no push without named PUSH GO.
END RELAY — 5 items.
```

---

**CC receipt (2026-07-15):** item count = 5, END marker present. RQ-6 (a) and H-1 folded into
`DIR-LNK-WO5-PLANLOCK.md`. RQ-5i `1e7af179` and contactdetails-VIEW answer recorded. P0 remainder
+ P1 recon executed read-only; STOP delivered in `DIR-LNK-WO5-P1-DELTA.md`.
