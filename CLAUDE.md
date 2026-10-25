# agent-skills

One flat set of skills under `skills/<name>/`: a `SKILL.md`, optional reference files beside it, and `agents/openai.yaml` with Codex UI metadata. `tmp/` holds a clone of the upstream repo the skills were adapted from; it is gitignored and not part of the set.

## Invariants

- **Every skill ships.** Each `skills/<name>` directory has an entry in `.claude-plugin/plugin.json`'s `skills` array, and nothing else does. Run `claude plugin validate .` after touching a manifest; it must pass (warnings about the root `CLAUDE.md` and a missing icon are expected).
- **Name matches folder.** The `name:` in `SKILL.md` frontmatter equals the directory name.
- **Invocation is explicit.** A user-invoked skill sets `disable-model-invocation: true` and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, with a one-line human-facing description. A model-invoked skill omits both and carries a trigger-rich description. Keep the two files in sync.
- **Dependencies name the tool.** A skill reaches another with `Call the Skill tool with "<name>"`, one skill per call, and only a model-invoked skill can be reached that way. A user-invoked precondition is phrased for the human: "tell the user to run `/setup-agent-skills`".
- **The router tells the truth.** When you add, rename, remove, or re-route a skill, update `skills/skill-guide/SKILL.md` and the tables in `README.md` in the same change.
- **Steering files win.** A skill's defaults for side effects (opening PRs, pushing, repo-wide checks, commits) defer to the target repo's `CLAUDE.md` / `AGENTS.md`. State the override at the step that acts, not only in a preamble.
- **Write for agents.** Call the Skill tool with "writing-for-agents" before editing any `SKILL.md`. No em-dashes in prose; rewrite the sentence instead.
