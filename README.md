# agent-skills

A curated set of agent skills for real engineering work: interview the idea, write the spec, split it into tickets, build test-first, review, ship, look back. Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) and trimmed to one flat set that a team can share.

Works with Claude Code as a plugin, and with any Agent Skills compatible harness (Codex, Copilot, Cursor and others) through skills.sh.

## Install

**Claude Code, as a plugin (recommended for a team).** The skills are namespaced (`/agent-skills:tdd`) and update when the repo does.

```bash
claude plugin marketplace add javlonbek-sharipov/agent-skills
claude plugin install agent-skills@javlonbek-sharipov
```

**Vendor editable copies into a project** (any harness). The files become yours to edit:

```bash
npx skills@latest add javlonbek-sharipov/agent-skills
```

**Contributing to this repo.** Symlink the skills into your local harness so edits are live (pick this or the plugin, not both):

```bash
scripts/link-skills.sh
```

## Set up each repo once

Run `/setup-agent-skills` in the repo you work on. It records the issue tracker (GitHub, GitLab, local markdown, or one you describe), the triage labels, and the domain doc layout in `docs/agents/`, plus a short block in `CLAUDE.md` or `AGENTS.md`. **Commit that output.** It is the contract every collaborator's agent reads, so the whole team publishes tickets to the same place and speaks the same labels.

## The flow

Type `/skill-guide` whenever you don't know which skill fits. The short version:

1. `/grill-with-docs` sharpens the idea by interview, recording terms in `GLOSSARY.md` and decisions as ADRs.
2. `/to-spec` turns the conversation into a spec on the tracker. `/to-tickets` splits it into tracer-bullet tickets with blocking edges.
3. `/implement` builds one ticket (claim, branch, `/tdd`, `/code-review`, `/pr`). `/implement-spec` orchestrates the whole graph onto an integration branch.
4. `/retro` turns what went wrong into checks, standards and pointers for next time.

`/triage` is the on-ramp for issues you didn't write. `/prototype`, `/research`, `/wizard` and `/handoff` sit beside the flow.

## Skills

User-invoked (you type them):

| Skill | What it does |
| --- | --- |
| [`skill-guide`](skills/skill-guide/SKILL.md) | Router: which skill or flow fits your situation |
| [`setup-agent-skills`](skills/setup-agent-skills/SKILL.md) | Configure a repo's tracker, triage labels and domain docs, once per repo |
| [`grill-with-docs`](skills/grill-with-docs/SKILL.md) | Relentless interview that also writes `GLOSSARY.md` and ADRs |
| [`to-spec`](skills/to-spec/SKILL.md) | Turn the conversation into a spec on the tracker |
| [`to-tickets`](skills/to-tickets/SKILL.md) | Split a spec into tracer-bullet tickets with blocking edges |
| [`implement`](skills/implement/SKILL.md) | Build one ticket: claim, branch, TDD, review, PR if needed |
| [`implement-spec`](skills/implement-spec/SKILL.md) | Build a whole spec with parallel subagents on an integration branch |
| [`triage`](skills/triage/SKILL.md) | Move incoming issues and external PRs through triage roles to agent-ready briefs |
| [`improve-codebase-architecture`](skills/improve-codebase-architecture/SKILL.md) | Find deepening opportunities, report them visually, grill through one |
| [`retro`](skills/retro/SKILL.md) | Retrospective: improve the agent's environment, not the code |
| [`handoff`](skills/handoff/SKILL.md) | Compact the conversation into a document another session or a colleague picks up |

Model-invoked (the agent reaches for them; you can type them too):

| Skill | What it does |
| --- | --- |
| [`grilling`](skills/grilling/SKILL.md) | The interview primitive: rounds, the frontier, decisions are yours |
| [`domain-modeling`](skills/domain-modeling/SKILL.md) | Sharpen terms, write `GLOSSARY.md` and ADRs |
| [`codebase-design`](skills/codebase-design/SKILL.md) | Deep-module vocabulary: module, interface, seam, adapter |
| [`tdd`](skills/tdd/SKILL.md) | Red-green loop at pre-agreed seams |
| [`code-review`](skills/code-review/SKILL.md) | Two-axis review of a diff: Standards and Spec |
| [`pr`](skills/pr/SKILL.md) | PR body: ticket, smallest visual, evidence, merge danger |
| [`prototype`](skills/prototype/SKILL.md) | Throwaway code that answers one design question |
| [`research`](skills/research/SKILL.md) | Background agent researches primary sources into `docs/research/` |
| [`wizard`](skills/wizard/SKILL.md) | Bash wizard for steps only a human can do |
| [`writing-for-agents`](skills/writing-for-agents/SKILL.md) | How to write skills, `CLAUDE.md` and other docs agents read |

## Working as a team

- Setup output in `docs/agents/` is committed and shared.
- `/implement` claims a ticket before building. An assigned ticket is taken.
- Work lands as a branch per ticket, plus a PR whose body closes the ticket when the repo works through PRs.
- A repo's `CLAUDE.md` / `AGENTS.md` wins over skill defaults: if it says PRs only on request, or that CI owns repo-wide checks, `/implement` and `/implement-spec` stop at the commit and run targeted checks only.
- `GLOSSARY.md`, `docs/adr/`, `CODING_STANDARDS.md` and `.out-of-scope/` are reviewed and merged like code.
- Agent-written tracker comments carry an AI disclaimer.

## Maintaining this repo

See [CLAUDE.md](CLAUDE.md) for the invariants: one folder per skill, every skill listed in the plugin manifest, `skill-guide` kept in sync, user- versus model-invoked frontmatter, and `claude plugin validate .` before you push.

## Credits and license

The skills derive from Matt Pocock's [skills](https://github.com/mattpocock/skills) repository, MIT licensed. The `pr` skill's summary visuals come from Dex Horthy's `show-me` (see `skills/pr/CREDITS.md`). This repo keeps the MIT license: see [LICENSE](LICENSE).
