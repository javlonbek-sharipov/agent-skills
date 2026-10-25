---
name: implement-spec
description: "Build a whole spec on one integration branch: parallel implementers, serialized verified merges, then a final code review."
disable-model-invocation: true
---

You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-agent-skills`.

The goal is the entire spec implemented on a single **integration branch**, with every ticket resolved the way the issue tracker closes work.

The repo's steering file (`CLAUDE.md` / `AGENTS.md`) overrides the defaults below: a PR only when the developer asks, repo-wide checks left to CI, and the like.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** should be run in the background where possible for maximum concurrency.

## Steps

1. Read the spec and tickets to understand the task graph.

   Check the effective commit policy before creating branches, claiming tickets, or dispatching agents. This workflow needs commits on both worker and integration branches. Use authorization already given in the session; do not ask for it again. If commits remain disallowed or deferred, explain the incompatibility and stop before starting implementation.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch and record the branch it was cut from as the base for final review. If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets. When the steering file says PRs are opened only when the developer asks, skip the draft unless they did.

   Record the starting commit and establish its baseline with the targeted checks permitted by the steering file. Report pre-existing failures without expanding the tickets to fix them. If they prevent reliable verification of a ticket, keep that ticket blocked; dispatch only independent work whose required checks can run and pass.

   Read `docs/agents/verification.md` when present and give workers the relevant journey pointers. If it is missing, the coordinator tells the user to run `/setup-verification` once and selects available verification methods for the workers to use.

4. Use **implementer subagents** to implement each ticket, each in its own worktree on its own branch. Each implementer subagent:
   - receives its scope, acceptance criteria, and the verified integration commit to start from; confirms that base before editing without discarding existing work;
   - claims its ticket the way the tracker doc describes (assigns it to the user running this skill), so collaborators see it is taken;
   - calls the Skill tool with `tdd` to build the ticket;
   - commits its ticket work first under the effective commit policy, then merges the latest verified integration tip into its clean branch, resolves any conflicts there, and commits the merge before rerunning checks;
   - runs targeted checks and relevant journeys from `docs/agents/verification.md`, if present, respecting any repo-wide checks reserved for CI;
   - returns its ticket, branch, exact post-merge head SHA, checks actually run with results and evidence paths, and any deviations or blockers. Uncommitted ticket work is not ready to merge. Workers report missing prerequisites to the coordinator.

5. Use one **merger subagent** as the sole writer to the integration branch. Wait for each merge and its checks before starting the next:
   - Queue only tickets whose scoped acceptance criteria and required targeted checks pass. Return failed or blocked work to its implementer.
   - Start from a clean integration checkout, record its current SHA, and merge the worker's reported SHA, not a branch tip that may have advanced.
   - Run targeted checks and relevant verification journeys against the resulting integration commit, respecting the steering file's CI limits. A worker's passing checks do not verify the combined result.
   - Record the before and after integration SHAs, commands, results, and evidence. For a merge conflict or failed or blocked checks, follow [RECOVERY.md](RECOVERY.md). Resume ordinary merges and dependent dispatch only when the integration state is verified again.

6. After a merge passes its integration checks, recompute the **frontier** and start newly ready tickets from that verified integration commit. Independent implementers can keep running while merges are serialized.

7. Once all tickets are integrated and verified, call the Skill tool with "code-review" using Committed scope, the base branch recorded in step 3 as the fixed point, and the supplied spec and tickets as the spec source. Read [RESOLVING-FINDINGS.md](../code-review/RESOLVING-FINDINGS.md), then assign confirmed fixes to one **implementer subagent**. Integrate its fixes through step 5 and review the changed portions. Record dismissed findings with reasons and report unresolved ones. Every new integration commit needs its own verification result before handoff.

8. If integration checks or review findings remain unresolved, report them and keep affected tickets open and any PR in draft. Otherwise, if a draft PR exists, mark it ready for review. If none exists, report the integration branch and resolve each ticket the way the issue tracker closes work. If the PR was skipped on the steering file's say-so, leave the tickets open and offer the PR in one line.

9. Clean up implementer worktrees whose work is fully incorporated. Preserve any unmerged or uncommitted work and report its location.

The integration and evidence guidance is adapted from pstack; see [CREDITS.md](CREDITS.md).
