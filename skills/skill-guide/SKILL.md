---
name: skill-guide
description: Ask which skill or flow fits your situation. A router over the skills in this repo.
disable-model-invocation: true
---

# Skill guide

You don't remember every skill, so ask.

Before stating what a skill does or recommending a step be skipped, read that skill's SKILL.md: the summaries here are for orientation only.

A **flow** is a path through the skills. Most paths run along one **main flow**, and the on-ramps merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath.

## Precondition

**`/setup-agent-skills`**: run once per repo, before the first flow. It records the issue tracker, the triage labels, and the domain doc layout in `docs/agents/` plus a short block in `CLAUDE.md` / `AGENTS.md`. Commit the result: the config travels through git, so every collaborator's agent publishes to the same tracker and speaks the same labels.

**`/setup-verification`**: run when the repo needs a shared recipe for exercising real user behavior. It writes `docs/agents/verification.md`, proves a representative journey, and records what remains unverified. Re-run it to refresh the recipe as the product changes. Implementation, triage, and PR writing read it when present; setup is not a prerequisite for those workflows.

## The main flow: idea → ship

The route most work travels. You have an idea and want it built.

1. **`/grill-with-docs`** sharpens the idea by interview. Start here whenever you are working in a repo: it's stateful, retaining what it learns in `GLOSSARY.md` and ADRs. (It runs the `/grilling` primitive plus `/domain-modeling`. Outside a repo, run `/grilling` on its own, covered under Standalone.)
2. **Branch: can you settle every question in conversation?** If a question needs a runnable answer (state, business logic, a UI you have to see or feel), detour through a prototype, bridged by **`/handoff`** in both directions (a prototype lives in its own directory, which is exactly what `/handoff` is for; see Phase boundaries):
   - **`/handoff`** out, then open a fresh session against that file,
   - **`/prototype`** to answer the question with throwaway code,
   - **`/handoff`** back what you learned, and reference it from the original idea thread.
3. **Branch: is this a multi-session build?**
   - **Yes** → **`/to-spec`** (turn the thread into a spec), then **`/to-tickets`** to split it into tracer-bullet tickets, each declaring its **blocking edges**. Then work the tickets one of two ways:
     - **`/implement`** per ticket, **`/clear`ing context between each one**. It claims the ticket, works on its own branch, and raises a PR where the repo works that way. On a hosted tracker the edges are native blocking links, so any teammate (or agent) can grab a ticket whose blockers are done; on a local tracker that's one file per ticket under `.scratch/<feature>/issues/`, worked blockers-first by hand. Each ticket is self-contained, so the last one's context is disposable.
     - **`/implement-spec`** for the whole spec in one run. It reads the tickets as a **task graph**, runs implementer subagents across the ready **frontier** in parallel, and lands everything on one **integration branch** through a single merger. Each integration result is checked before dependent tickets start. Reach for it when you'd rather orchestrate the build than drive each ticket yourself.
   - **No** → **`/implement`** right here, in the same context window.

   Either way, the code gets built by driving **`/tdd`** (one red-green slice at a time) and closes out with **`/code-review`**, a two-axis review (Standards + Spec) of the diff. `/implement` runs both per ticket; `/implement-spec`'s implementers each drive `/tdd`, and it runs one `/code-review` over the integration branch. Reach for **`/tdd`** on its own when you just want to build a concrete behaviour test-first (a bug fix included) without a full spec, and **`/code-review`** on its own whenever you want to review a branch or PR against a fixed point.

   Local review captures staged, unstaged, and new files; an explicit branch or PR review captures committed changes. The implementation workflow validates the findings before applying fixes and records reasons for dismissals.

   When the work goes up as a pull request, **`/pr`** shapes the body: the ticket it closes, the smallest visual that shows the change, before/after evidence that it works, and a one-way or two-way door call. It's model-invoked, so the agent reaches for it whenever it writes a PR.

4. **`/retro`** closes the loop. After a build, and especially one that went sideways, it looks back over the session and suggests changes to the agent's **environment**, not the code: navigation pointers, automated checks, the coding standards `/code-review` enforces, steering files, tooling. Mechanical mistakes become deterministic checks; judgement calls become coding standards. The next build then starts from a better environment, and because those files are committed, so does everyone else's.

### Context hygiene

Keep steps 1–3 in **one unbroken context window** (don't compact or clear until after `/to-tickets`) so the grilling, spec, and tickets all build on the same thinking. Each `/implement` then starts fresh, working from the ticket. Run `/retro` in the session it's looking back on, before you clear; after clearing, point it at that session's log instead.

The limit on this is the **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**: the window (~150k tokens on state-of-the-art models) within which the model still reasons sharply. If a session approaches it before `/to-tickets`, don't push on degraded; `/compact` at the nearest phase boundary and carry on (see Phase boundaries).

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- **Bugs and requests piling up** → **`/triage`**. It moves issues (and, when the tracker config says so, external PRs) through triage roles and produces agent-ready briefs, which **`/implement`** later picks up. Every comment it posts carries an AI disclaimer, so reporters and teammates know what wrote it.

  Triage is only for issues **you didn't create**: bug reports, incoming feature requests, anything that arrives raw. Tickets that `/to-tickets` produced are already agent-ready, so **don't triage them**.

- **Something's broken** → **`/tdd`**: write the test that goes red on the bug, then make it green. Once the fix is in, run **`/retro`** in the same session to ask what would have prevented it; where the real finding is that there's no good seam to lock it down, that's a job for **`/improve-codebase-architecture`**.

- **A huge, foggy effort**, too big to plan in one session → **`/wayfinder`**. It charts the effort as a **map** on the tracker: the destination, the fog not yet specifiable, and **decision tickets** (grilling, prototype, research, task) wired with blocking edges so the frontier shows in the tracker's own UI. Each later session loads the map, claims one ticket, resolves it, and stops. The split from `/grill-with-docs` is session count, not project size: if the opening breadth-first grill finds no fog, `/wayfinder` says so and you plan in one sitting instead. When the map clears, merge onto the main flow at **`/to-spec`** with the map issue, then `/to-tickets`.

## Codebase health

Not feature work, just upkeep.

- **`/improve-codebase-architecture`** runs whenever you have a spare moment to keep the codebase good for agents to operate in. It surfaces **deepening opportunities**; picking one _generates an idea_ you can take into the main flow at `/grill-with-docs`. It's the survey that finds the candidates; **`/codebase-design`** (below) is the bench you design the chosen one on.

## Vocabulary underneath

Two model-invoked references that run *beneath* the other skills, each the single source of truth for its vocabulary. Reach for them directly when the **words**, not the process, are the problem; or let the skills above pull them in.

- **`/domain-modeling`**: sharpen the project's *domain* language: challenge a fuzzy term, resolve an overloaded word ("account" doing three jobs), record a hard-to-reverse decision as an ADR. It's the active discipline `/grill-with-docs` drives to keep `GLOSSARY.md` a clean glossary.
- **`/codebase-design`** is the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's *shape*: a lot of behaviour behind a small interface at a clean seam. `/tdd` and `/improve-codebase-architecture` both speak it.

## Phase boundaries

A **phase** is a chunk of work inside a session: the grilling, the implementation, the QA. At the **boundary** between two of them you have five options, and picking between them is the fuzziest decision in this whole map:

- **Continue**: stay put. Costs nothing, loses nothing.
- **`/clear`**: empty the window, when nothing here matters to what's next.
- **`/handoff`** writes a portable markdown file. Narrow: only for a **new harness**, a **new directory**, a **colleague**, or forking a side task **mid-phase**. What it buys is portability.
- **Subagent**: send a tightly-scoped task to its own window and get a report back.
- **`/compact`** compresses this context and seeds a fresh session with it. The **default**, at the bottom of the tree rather than the first reach.

Read [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) for the ordered tree: the five questions, the reasoning behind each branch, and why the primary-source cost makes **Continue** the one to rule out first. Make the decision **at** a boundary; mid-phase, continue or split the rest into subagents.

## Standalone

Off the main flow entirely.

- **`/grilling`** is the interview primitive: rounds, the frontier, facts are the agent's job and decisions are yours. On its own it is **stateless**: it saves nothing and builds no `GLOSSARY.md`, which makes it the one to reach for outside a repo (a plan, a design, a piece of writing). Inside a repo, `/grill-with-docs` runs the same interview and leaves a paper trail, so it is strictly the better one there. `/triage` and `/improve-codebase-architecture` run it internally.
- **`/prototype`** is a small, throwaway program that answers one design question, built in the app's own stack on web, mobile or desktop: does this state model feel right, or what should this UI look and feel like. Throwaway is a constraint on how the code is written, not a promise to destroy it: the answer folds into the real code, and the prototype itself is kept as a **primary source** on a `prototype/<name>` branch out of main, pointed at from the implementation issue. It's the detour in step 2 of the main flow, but reach for it any time a design question is hard to settle on paper.
- **`/research`**: delegate reading legwork to a **background agent**: it investigates a question against **primary sources**, then leaves a cited Markdown file in the repo (`docs/research/` unless the repo already has a home for such notes), where teammates can find it. Keep working while it reads. The file it produces is something to take *into* the main flow at `/grill-with-docs`, since research feeds the thinking rather than replacing it.
- **`/handoff`** writes a portable markdown file so a fresh session, another harness, or a colleague can continue the work. For yourself it goes in the temp directory; for a colleague it goes on the ticket or PR, where they can reach it.
- **`/wizard`** is for the steps only a **human** can take: provisioning infrastructure, setting up credentials or CI secrets, clicking through an unfamiliar third-party dashboard, running a one-off migration or cutover. It generates an interactive bash script that opens each URL, captures each value, and writes it into `.env` and GitHub secrets, so the procedure stops being something you re-explain to an agent every time. Model-invoked, so the agent reaches for it the moment it hits a wall only you can pass. If the agent could just do it itself, it should; this is for where a human is genuinely in the loop.
- **`/writing-for-agents`** is the reference for writing documents agents consume: skills, `CLAUDE.md` / `AGENTS.md`, pointed-at docs. `/retro` uses it when it proposes changes to those files; so should anyone editing this repo.

## Working as a team

The skills share state through the repo and the tracker, so a few habits keep two people (or two agents) from colliding:

- **One setup, committed.** `/setup-agent-skills` runs once; its output in `docs/agents/` is the contract every agent reads.
- **Claim before you build.** `/implement` assigns the ticket to you first, and `/wayfinder` claims a decision ticket the same way. A ticket with an assignee is taken.
- **A branch per ticket, and a PR when the repo works that way.** Work lands through `/pr`-shaped pull requests that close their ticket, so main only moves by review.
- **Steering files win.** When a repo's `CLAUDE.md` / `AGENTS.md` says PRs are opened only on request, or that CI owns the full suite, `/implement` and `/implement-spec` follow it: they stop at the commit and offer the PR, and run targeted checks only.
- **Docs are code.** `GLOSSARY.md`, `docs/adr/`, `CODING_STANDARDS.md` and `.out-of-scope/` live in git; they merge, conflict, and get reviewed like code. Two branches can mint the same ADR number; the second to merge renumbers.
- **Say what wrote it.** Triage comments carry the AI disclaimer; keep that habit for any agent-written comment on a shared tracker.
