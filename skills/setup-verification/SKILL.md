---
name: setup-verification
description: "Create or refresh a repo's recipe for verifying real user behavior."
disable-model-invocation: true
---

Create or refresh `docs/agents/verification.md`: a shared recipe another agent can follow to run the real product, exercise a user journey, and leave evidence. Keep it in the repo alongside the other agent docs so it works across harnesses.

Setup owns the recipe and its verification helpers. Report product regressions separately; changing expected behavior to accommodate a bug is not recipe maintenance.

## 1. Ground the recipe

Read the repo's steering file, its run commands, existing tests and automation, and any current verification docs. Use the codebase to identify:

- The surfaces users interact with: UI, CLI, API, or library interface.
- How to reach a usable local instance, including build steps, migrations, fixtures, authentication, and a ready signal.
- Which available tool or command can drive that surface. Prefer existing repo automation and the active harness's supported tools. Record prerequisites when the driver is not available everywhere.
- How to isolate ports, profiles, data, and processes. If instances cannot be isolated, allow only one driver at a time.

Ask only for facts the repo and available tools cannot establish. Keep credentials out of the recipe; name the environment variables or existing auth setup it needs.

## 2. Write the recipe

Use the repo's actual commands, paths, and selectors. Include these sections, keeping the feature list small enough to maintain:

- **Launch.** Preparation and startup from fresh test state, the ready signal, and the expected build or revision. Ready means a journey can run, including completed initialization.
- **Driver and isolation.** The tool or CLI used, how to select the intended instance, and which resources each run owns. For short-lived commands, give each invocation its own scratch state.
- **Doctor.** A read-only check of instance identity, readiness, and authentication. Run it before driving and after a surprising failure; reset a stuck session to known state before retrying.
- **Journeys.** For each feature: prerequisites, entry point, actions through the public interface, expected observable result, evidence to capture, and known gotchas. Preserve distinct entry points when they exercise different behavior.
- **Evidence.** Capture the action and result, including relevant side effects, with exact commands and the tested revision. Name an evidence directory outside the checkout or ignored by Git by default, separate from disposable instance state. Keep these generated artifacts out of source review and commits unless the user requests their inclusion. A shortcut through internal setters does not prove the user journey.
- **Cleanup.** Stop only processes the run started and remove only its scratch state, including after failed attempts. Keep evidence and confirm it still exists after teardown.
- **Coverage.** Record the date, tested revision, driver, journeys attempted, their outcomes, and evidence paths. Distinguish verified, failed, blocked, and not run; list missing prerequisites explicitly. Earlier results retain their original date and revision.

Reuse existing scripts where possible. If a helper is needed, put it with the repo's verification tooling, document its invocation in the recipe, and run it. Follow the target repo's steering file for which checks run locally and which belong to CI.

## 3. Prove or refresh it

**First setup:** follow the written instructions from launch through one representative journey, evidence capture, and cleanup. Mark the other journeys as not run. If startup or the driver is unavailable, leave an explicitly unverified draft and report the concrete blocker.

**Refresh:** reconcile the feature list with current source and attempt every listed journey. Classify each mismatch before editing:

- **Recipe drift:** instructions no longer match intended behavior. Correct them and rerun the affected journey.
- **Driver gap:** the product works but the driver cannot exercise it. Fix the helper within scope and rerun, or record the missing capability.
- **Product regression:** intended behavior is broken. Record the failure and evidence without weakening the expected result.

Clean up each failed attempt before retrying. After a recipe or helper correction, retry the affected journey once; if it still cannot run, record it as blocked or failed and continue with independent journeys. A refresh is complete only when every listed journey has a current outcome. Summarize unresolved failures separately from successful coverage.

## 4. Register and hand back

Create the `## Agent skills` section in the repo's steering file when absent, then add or update this sub-block inside it:

```markdown
### Verification

For real user journeys, verification commands, and evidence capture, read `docs/agents/verification.md`.
```

Use `CLAUDE.md` when it exists, otherwise `AGENTS.md`. If neither exists and the user has not named one, ask which to create while finishing the recipe. Preserve the other setup sub-blocks and surrounding user content.

Report the recipe path, the driver actually exercised, verified journeys, evidence locations, and remaining gaps. Follow the repo's steering file for commits, pushes, and PRs; setup or refresh alone does not require opening a PR. Share the recipe and helpers through git under that policy.

Adapted from pstack; see [CREDITS.md](CREDITS.md).
