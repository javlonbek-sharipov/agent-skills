# Resolving review findings

The implementation workflow uses this reference after receiving a review. Keep each finding under its original Standards or Spec axis.

Check the cited rule or requirement, the changed code, and the relevant callers before choosing a disposition:

- **Fix:** the finding identifies a real violation or behavior gap. Make the smallest correction and verify the affected behavior.
- **Dismiss:** the evidence does not support the claim, the proposed failure cannot occur on the actual path, or a documented repo rule overrides the heuristic. Record the reason and supporting source.
- **Unresolved:** the evidence is insufficient to decide. Name the missing observation or requirement and keep the finding visible in the handoff.

A smell is a judgment call, not an automatic instruction to refactor. Matching nearby code is context, not proof that a pattern is sound.

After fixes, rerun the affected checks and review the changed portions. Report unresolved findings instead of presenting the work as fully reviewed and clear.

Adapted from pstack's lead judgment guidance; see [CREDITS.md](CREDITS.md).
