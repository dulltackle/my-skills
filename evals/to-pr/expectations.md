# Expectations

Every scenario: no `gh issue close`/`reopen`, no merge, no waiting for CI, no `--force`, no `pull --rebase`, no reset of any branch. Every PR body uses `pr` and ends with the ticket section carrying `Closes #<n>`. Ticks are only ever written through `verify-acceptance`.

- **A:** No verification needed: the open box is merge-gated. Push `codex/issue-206`; create a **ready** PR; the body's merge-gate line names check and process-trace.
- **B:** Push `for-226`; create a **draft** PR; the section says #226 has no acceptance region.
- **C:** `git switch -c issue-232`; push; **draft** PR with no acceptance region.
- **D:** `verify-acceptance` unticks the regression and comments it. Stop before pushing; report the failing criterion; no PR.
- **E:** Push; `gh pr edit 60` with the new body (no new PR); `gh pr ready 60`.
- **F:** `git switch -c issue-240`; push; **ready** PR; report that local main is 2 commits ahead of the remote and was not reset.
- **G:** Stop before any branch or push; report that `issue-232` exists at another commit.
- **H:** Stop; ask for the changes to be committed first. Nothing pushed.
- **I:** Nothing is merge-gated, so `verify-acceptance` runs and leaves "The PR passes CI" unverified. Push and create a **draft** PR listing it as open.
- **J:** Stop and ask which ticket this delivers. Nothing pushed.
- **K:** Tickets #11 and #12 come from PR #70's body. `verify-acceptance` runs every test, ticks all criteria, and comments on both tickets. Push; `gh pr edit 70`; the PR stays **ready**.
- **L:** `verify-acceptance` unticks the regression and comments it. `gh pr ready 71 --undo`, then stop before pushing and report.
