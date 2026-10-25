# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Claim and resolve a ticket

- **Claim**: add an `Assignee: <name>` line near the top of the file before starting work. Skip files that already carry one.
- **Blocking edges**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists has `Status: done`.
- **Resolve**: set `Status: done` and append the outcome under `## Comments`.

Local files suit solo work. For a team, commit `.scratch/` so everyone sees the same tickets, or re-run `/setup-agent-skills` and pick a hosted tracker.

## Wayfinding operations

Used by `/wayfinder`. The **map** is one file; its **decision tickets** are one file each beside it.

- **Map**: `.scratch/<effort-slug>/map.md`, holding the map body.
- **Child ticket**: `.scratch/<effort-slug>/issues/<NN>-<slug>.md`, numbered from `01`, with a `Type:` line (`research`, `prototype`, `grilling`, `task`) near the top and the question in the body.
- **Blocking** and **claim**: as in **Claim and resolve a ticket**.
- **Frontier query**: scan `issues/` for files with no `Status: done`, no `Assignee:`, and every blocker at `Status: done`. Lowest number wins.
- **Resolve**: append the answer under `## Answer`, set `Status: done`, then append the gist and a relative link to the map's Decisions so far in `map.md`.
