---
name: prototype
description: Build a throwaway prototype, in the app's own stack, to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look and feel like, on web, mobile or desktop.
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape. The platform (a browser tab, a phone, a desktop window) decides only where the prototype runs, never which shape it takes.

## Pick a branch

Identify which question is being answered, using the user's prompt, the surrounding code, or by asking if the user is around:

- **"Does this logic / state model feel right?"** → [LOGIC.md](LOGIC.md). Build a single shareable HTML file (free-play buttons plus tabbed guided walkthroughs) that pushes the state machine through cases that are hard to reason about on paper, and that a non-developer can drive. It moves into the app only on the two triggers LOGIC.md names.
- **"What should this look and feel like?"** → [UI.md](UI.md). Generate several radically different UI variations of one screen, inside the real app on whatever platform it runs, switchable from a floating bar. Variants may differ in layout, in interaction, or both.

The two branches produce very different artifacts, so getting this wrong wastes the whole prototype. If the question is genuinely ambiguous and the user isn't reachable, default to whichever branch better matches the surrounding code (a backend module → logic; a screen or component → UI) and state the assumption in the run card.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Locate the prototype code close to where it will actually be used (next to the module or screen it's prototyping for) so context is obvious, but name it so a casual reader can see it's a prototype, not production. For throwaway UI screens, obey whatever routing convention the project already uses; don't invent a new top-level structure. In a repo with several apps, build in one: the app the question names. When the question is about shared code and the user is away, pick the app with the cheapest launch (a browser tab, then a web renderer in a shell, then a native toolkit) and record the choice in the run card.
2. **Open with a run card.** The first thing in the prototype's main file (the visible intro of an HTML demo, a top-of-file comment in app code) states: the question, in one paragraph; how to launch; the one step that reaches the prototype; the variant keys; every assumption made on the user's behalf. Surfacing the run card is the hand-over. Whoever can run the dev build drives the prototype; someone who can't gets a screen recording of the walkthrough, not a distribution pipeline.
3. **Trivial to run.** Launching is the project's own dev command, as its README, task runner or `CLAUDE.md` defines it, plus at most one step to reach the prototype: a URL, a flag, a dev-menu entry. A logic demo is a single HTML file the user double-clicks. Either way, no thinking required to start it: the prototype adds a reach step, never a launcher.
4. **No persistence by default.** State lives in memory. Persistence is the thing the prototype is _checking_, not something it should depend on. If the question explicitly involves a database, hit a scratch DB or a local file with a clear "PROTOTYPE, wipe me" name. Sample rows that fill a UI prototype's host screen are the one exception; UI.md bounds them.
5. **Skip the polish.** No tests, no error handling beyond what makes the prototype _runnable_, no abstractions. The point is to learn something fast.
6. **Surface the state.** After every action (logic) or on every variant switch (UI), print or render the full relevant state so the user can see what changed.
7. **Capture it when done.** Fold any validated decision into the real code, then capture the prototype itself as a **primary source**: commit it to a throwaway branch, out of main, and leave a context pointer to that branch on the implementation issue. The fold lands on its own branch off main, or where the repo's steering files say. The prototype branch stays frozen at the prototype commit, so it survives as the primary source. A PR carries the fold only, never the prototype commit; a PR asked for before the verdict waits for the verdict. Capture the answer too (the verdict and the question it settled) in the issue or a commit. The main branch keeps only the validated decision.
