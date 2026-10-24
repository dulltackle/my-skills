# Scenarios

Each scenario runs in an isolated context that reads only the `to-commit` and `verify-acceptance` skill files and the scenario. The repo's `docs/agents/issue-tracker.md` configures GitHub, and the user's instructions set no commit scope. Describe every command you would run and the final state of the commit, branch, remote, and ticket. Do not run anything. Expected answers live in [expectations](expectations.md).

## A: All criteria ran green

Ticket #42 has `## Acceptance criteria` with three criteria. All three were run this session and passed. The current branch is `feat/items`, with no upstream. Nothing is staged.

## B: A criterion that needs the PR's own CI

Ticket #206's region has six criteria. Five were run and passed. The sixth reads "The PR passes the full real CI suite, check and process-trace, on its own commits"; no PR exists yet. The branch is `codex/issue-206`.

## C: No acceptance region

Ticket #226 has the headings Goal and status, Current friction, Directions, and no `## Acceptance criteria`. The work is done and its tests pass. The branch is `for-226`.

## D: Regression on a closed ticket

Ticket #42 is CLOSED; every box is `[x]`. A re-run on new commits finds "concurrent writes lose no orders" now fails in `items.test.ts`. The other criteria still pass.

## E: Reading criteria

Ticket #43 has two `ran` criteria that passed and one criterion "README updated" that you only read. The user confirms it after the question.

## F: Something already staged

Ticket #44's criteria all ran green. `src/a.ts` is staged; `src/b.ts` has unstaged edits.
