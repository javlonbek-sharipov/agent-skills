# Integration recovery

The coordinator assigns recovery work and keeps dependent tickets blocked. Implementers author code on their own branches; the merger alone changes the integration branch. Preserve the failed check output and the before and after integration SHAs.

## Merge conflict

The merger aborts the conflicted attempt, restoring the clean checkout at the previously verified integration commit. Return the ticket to its implementer with that commit and the conflict details. The implementer merges it into its own branch, resolves and commits the conflicts, reruns the required checks, and returns a new head SHA. Requeue that new result; the old report no longer qualifies it for integration.

Other independent tickets may integrate while that worker repairs its branch, since the aborted merge left the verified integration state unchanged.

## Failed integration check

Pause ordinary merges and dependent dispatch. Compare the failure with the recorded baseline to distinguish a new regression from a pre-existing failure or an unavailable prerequisite.

For a regression, the coordinator assigns the original implementer, or a worker scoped to the interaction between tickets, a correction based on the **failed integration commit**. Include the failing command, output, and acceptance criteria. The worker commits the correction on its own branch, reruns the checks, and returns the new SHA and evidence. The merger integrates that SHA and verifies the resulting integration commit before releasing the pause. Only this recovery work may start from the failed tip.

If a rollback is preferable, the merger reverts the failed ticket's **entire integrated change** with new commits, preserving shared history. Use the recorded before and after SHAs to identify that change; reverting only the last commit of a multi-commit ticket may leave part of it behind. Verify the restored integration state before resuming.

After a revert, keep the ticket open. Its old commits remain ancestors of integration, so merging the old branch again will not restore its changes. Give the implementer the new integration tip and require a fresh, complete corrected ticket change with passing checks and a new SHA.

## Blocked check

The coordinator handles missing prerequisites within the task's authorization and asks the merger to retry the same commit when the environment is ready. A blocked check does not justify a product-code change or a passing verdict. If recovery needs work outside the authorized scope, report the blocker and preserve the branches and evidence for handoff.
