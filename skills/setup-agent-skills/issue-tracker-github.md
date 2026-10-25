# Issue tracker: GitHub

Issues and specs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --json number,title,body,labels,comments`.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Make an issue a sub-issue of a parent**: `gh issue create --parent <parent> ...`, or `gh issue edit <parent> --add-sub-issue <child>` afterwards (`gh` 2.94+). Older `gh`: `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>` (database id, as in **Blocking** below). Without sub-issues, put `Part of #<parent>` at the top of the child body.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v`; `gh` does this automatically when run inside a clone.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh api --paginate 'repos/{owner}/{repo}/pulls?state=open' --jq '.[] | select(.author_association | IN("OWNER","MEMBER","COLLABORATOR") | not) | {number, title, author: .user.login, author_association, labels: [.labels[].name]}'`.
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either: resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.

## Claim and resolve a ticket

- **Claim**: `gh issue edit <number> --add-assignee @me` before starting work, so a collaborator sees it is taken. Skip tickets that already carry an assignee unless the maintainer hands them over.
- **Blocking edges**: GitHub's native issue dependencies. Add one with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#number`). `issue_dependencies_summary.blocked_by` counts the open blockers. Where dependencies aren't available, put a `Blocked by: #<n>, #<n>` line at the top of the body. A ticket is unblocked when every blocker is closed.
- **Resolve**: through the pull request when there is one (`Closes #<number>` in the PR body closes it on merge); otherwise `gh issue close <number> --comment "..."`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is one issue; its **decision tickets** are child issues of it.

- **Map**: `gh issue create --label wayfinder:map --body "..."`. Create the labels first if the repo lacks them (`gh label create wayfinder:map`, and one per ticket type).
- **Child ticket**: a sub-issue of the map (see **Make an issue a sub-issue of a parent**), carrying exactly one label, `wayfinder:<type>` (`research`, `prototype`, `grilling`, `task`), and no triage label.
- **Blocking** and **claim**: as in **Claim and resolve a ticket**. Native dependencies are canonical because the tracker UI then shows the frontier without opening the map.
- **Frontier query**: `gh api repos/<owner>/<repo>/issues/<map>/sub_issues --jq '.[] | select(.state == "open") | {number, title, assignees: [.assignees[].login], blocked_by: .issue_dependencies_summary.blocked_by}'`, then drop any entry with an assignee or `blocked_by > 0` (or an open issue in its `Blocked by` line). First in map order wins. Without sub-issues, `gh issue list --state open --search "Part of #<map>"` instead.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append the gist and link to the map's Decisions so far (`gh issue edit <map> --body-file`).
