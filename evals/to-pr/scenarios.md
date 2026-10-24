# Scenarios

Each scenario runs in an isolated context that reads only the `to-pr` and `verify-acceptance` skill files and the scenario. The repo is `o/r` on GitHub, default branch `main`, and `docs/agents/issue-tracker.md` configures GitHub. Unless a scenario says otherwise: the tree is clean, `HEAD` has commits ahead of `origin/main` carrying `Refs: #<n>`, the branch has no PR, and main's protection requires `check` and `process-trace`. Describe every command you would run, the PR's final state and body's ticket section, and the report. Do not run anything. Expected answers live in [expectations](expectations.md).

## A: Last criterion is the PR's own CI (#206)

Branch `codex/issue-206`. #206's `## Acceptance criteria` has six boxes: five `[x]`, and `[ ]` "The PR passes the full real CI suite, check and process-trace, on its own commits".

## B: No acceptance region (#226)

Branch `for-226`. #226 has the headings Goal and status, Current friction, Directions, and no `## Acceptance criteria`.

## C: Detached HEAD, no region (#232)

`HEAD` is detached at `8ce581d` with `Refs: #232`. #232 is a spec with `## Testing Decisions` but no `## Acceptance criteria`. No branch named `issue-232` exists anywhere.

## D: A failing criterion

Branch `issue-42`. #42's region has one `[x]` "concurrent writes lose no orders", which fails in `items.test.ts` on `HEAD`.

## E: Existing draft, now all green

Branch `issue-43` already has draft PR #60 whose ticket section lists one open criterion. Since then that box on #43 was ticked; every box in the region is now `[x]`. A new commit is unpushed.

## F: Work committed on main

The current branch is `main`, two commits ahead of `origin/main`, both `Refs: #240`. #240 has a region with every box `[x]`.

## G: Branch name taken

`HEAD` is detached with `Refs: #232`. `origin/issue-232` exists at a different commit.

## H: Uncommitted changes

Branch `issue-44` with modified, unstaged `src/a.ts`.

## I: Protection unreadable

Branch `issue-45`. `gh api .../protection/required_status_checks` returns 403 and the rulesets endpoint returns an empty list. #45 has three `[x]` and `[ ]` "The PR passes CI".

## J: No ticket reference

Branch `cleanup`, no arguments, no PR, and no commit carries a `Refs:` trailer.

## K: After implement-spec, nothing ticked

Branch `spec-10` has ready PR #70 whose body says `Closes #10`, `Closes #11` and `Closes #12`. #10 is the spec: #11 and #12 are its sub-issues, and it has no `## Acceptance criteria`. No commit carries a `Refs:` trailer. Every criterion on #11 and #12 is `[ ]`; each is a test that passes on `HEAD`.

## L: A regression behind a ready PR

Branch `issue-46` has ready PR #71 for #46. #46's region has `[x]` "export keeps column order", which now fails in `export.test.ts` on `HEAD`.

## M: A parent that is not ready yet

Branch `spec-20` has draft PR #72 whose body says `Closes #20` and `Closes #21`. #20 is the spec with no region; #21 is its sub-issue, with one `[ ]` criterion "README updated" that can only be read. The user declines it.
