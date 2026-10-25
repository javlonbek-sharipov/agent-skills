---
name: implement
description: "Implement one ticket, or one small piece of work, in this session: claim it, branch, build test-first, review, raise the PR if needed."
disable-model-invocation: true
---

Implement the work described by the user in the spec or ticket. One ticket per run: for a whole spec of tickets, point the user at `/implement-spec`.

The repo's steering file (`CLAUDE.md` / `AGENTS.md`) overrides the defaults below. Two overrides are common, and both are honoured without asking: pull requests only when the developer asks for one, and repo-wide checks left to CI.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask. If the tracker hasn't been provided to you, tell the user to run `/setup-agent-skills`.

**Claim the ticket** the way the tracker doc describes (assign it to yourself), so a collaborator sees it is taken. If it already carries someone else's name, stop and ask.

**Work on a branch named for the ticket**, cut from the integration branch when one exists, otherwise from the main branch. Record that base branch for review.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking and single test files regularly as you go, and the full test suite once at the end. When the steering file reserves repo-wide checks for CI (the full suite, a whole-project typecheck or lint), skip those: the targeted checks you ran are the bar, CI runs the rest, and your report says which checks ran.

For changed user behavior, read `docs/agents/verification.md` when it exists and run the relevant journeys under the same steering-file limits. Capture the action, result, and evidence path; report any blocked or unverified behavior. If the recipe is missing, tell the user to run `/setup-verification`, then continue with the repo's available verification methods.

Once done, call the Skill tool with "code-review" using its Working scope and the task's changed paths, so staged, unstaged, and new files are included before commit. Pass the recorded base branch as the fixed point and the fetched ticket contents, or the user's task brief when there is no ticket, as the spec source. Read [RESOLVING-FINDINGS.md](../code-review/RESOLVING-FINDINGS.md) to validate and act on the report. Rerun affected checks and journeys after fixes.

Commit only the reviewed task changes, with the staged content matching the reviewed state, unless the steering file says otherwise. If commits are deferred, report the uncommitted state instead of pushing or resolving the ticket. Unresolved requirements or required checks keep the ticket open and any PR in draft. Otherwise, close the work out the way the repo does it:

- **Pull requests**: push the branch and open a PR against the branch you cut from. Call the Skill tool with "pr" for the body; it leads with the reference that closes the ticket.
- **PRs only on request** (the steering file says so): stop at the commit, report the branch, and offer the PR in one line. Open it as above only when the developer asks.
- **No pull requests**: resolve the ticket the way the tracker doc closes work, and report the branch.
