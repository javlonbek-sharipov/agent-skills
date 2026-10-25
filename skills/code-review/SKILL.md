---
name: code-review
description: "Review a branch, PR, or local changes since a fixed point along two axes: Standards and Spec. Runs both reviews in parallel sub-agents and reports them side by side. Local review includes staged, unstaged, and untracked files. Use for code review, work in progress, or \"review since X\"."
---

Two-axis review of a captured changeset since a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-agent-skills`, then carry on: only the issue lookup in step 2 needs it.

## Process

### 1. Capture the review scope

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, default to the repo's main branch (`origin/main`, else `main`, else `master`) and say which ref you used.

Resolve the fixed point and `HEAD` to commit SHAs, then compute `git merge-base <base-sha> <head-sha>`. Capture the commit list with `git log <base-sha>..<head-sha> --oneline`. A bad ref or missing merge-base fails here.

Choose and state the scope once:

- **Committed:** an explicitly requested branch or PR review uses `git diff <merge-base-sha> <head-sha>`. Uncommitted work is outside this scope.
- **Working:** local implementation and work-in-progress review use `git diff <merge-base-sha>`, which includes committed changes plus the net staged and unstaged changes. Enumerate untracked files separately with `git ls-files --others --exclude-standard -z`, preserving the null-delimited paths; Git's diff does not include them.

If the request does not choose, use Working when the checkout has local changes, otherwise Committed. Honor any narrower paths the caller supplies. Exclude unrelated pre-existing edits and generated verification artifacts from the selected patch and untracked files unless the user explicitly includes them in scope. Name the excluded paths or hunks in the report; surrounding code remains available as context.

Save the selected patch, the untracked files being reviewed, and their original path mapping to a temporary snapshot outside the repo. Include the scope, captured SHAs, and commit list. Both reviewers read the same snapshot; they can consult original files for surrounding context. Keep the checkout stable until they finish, or recapture and repeat the affected review when it changes. Do not stage, stash, or commit files merely to include them in review.

The scope is empty only when both its tracked patch and selected untracked files are empty. Report that before spawning reviewers.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. The spec, ticket, or task brief supplied by the caller: use provided text or a file path directly, or fetch a supplied tracker reference using the tracker doc.
2. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in the tracker doc.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. When `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

Issue both sub-agent calls together, in the foreground, and aggregate the reports they return.

**Standards sub-agent prompt** should include:

- The snapshot path, scope, captured SHAs, and commit list from step 1.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The brief: "Report problems introduced or worsened by this changeset, using surrounding code for context. Per file/hunk, report (a) documented-standard violations: cite the standard (file + the rule); and (b) baseline smells: name the smell and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The same snapshot path, scope, captured SHAs, and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
