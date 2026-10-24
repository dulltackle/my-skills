# Expectations

Every scenario: no `gh issue close`/`reopen`, no merge, no waiting for CI, no `--force`, no `pull --rebase`, no reset of any branch. A new PR's body comes from `pr`; an existing PR keeps its body and only its ticket section is replaced. Every ticket section carries `Closes #<n>`. `git fetch origin` runs before any comparison with `origin/main`. Every ticket with a region goes through `verify-acceptance` on every run, `[x]` boxes re-run too; ticks are only ever written through it, and a run that changes nothing posts no comment.

- **A:** `verify-acceptance` re-runs the five `[x]` boxes (all pass, no comment); the open box is merge-gated. Push `codex/issue-206`; create a **ready** PR; the body's merge-gate line names check and process-trace.
- **B:** Push `for-226`; create a **draft** PR; the section says #226 has no acceptance region.
- **C:** `git switch -c issue-232`; push; **draft** PR with no acceptance region.
- **D:** `verify-acceptance` unticks the regression and comments it. Stop before pushing; report the failing criterion; no PR.
- **E:** `verify-acceptance` re-runs every box of #43 on the new commit; all pass, nothing changes, no comment. Push; `gh pr edit 60` replacing only the ticket section (no new PR, no `pr` call); `gh pr ready 60`.
- **F:** `git switch -c issue-240`; `verify-acceptance` re-runs #240 (all pass, no comment); push; **ready** PR; report that local main is 2 commits ahead of the remote and was not reset.
- **G:** Stop before any branch or push; report that `issue-232` exists at another commit.
- **H:** Stop; ask for the changes to be committed first. Nothing pushed.
- **I:** Nothing is merge-gated, so `verify-acceptance` runs and leaves "The PR passes CI" unverified. Push and create a **draft** PR listing it as open; the report adds `re-run to-pr once CI has finished`.
- **J:** Stop and ask which ticket this delivers. Nothing pushed.
- **K:** Tickets #10, #11 and #12 come from PR #70's body. #10 is a parent, so it is not verified and its missing region does not make the PR a draft. `verify-acceptance` runs every test on #11 and #12, ticks all criteria, and comments on both. Push; `gh pr edit 70`; the PR stays **ready**; the section says `#10: ready: children #11, #12 are ready`.
- **L:** `verify-acceptance` unticks the regression and comments it. `gh pr ready 71 --undo`, then stop before pushing and report. The PR body is left as it is.
- **M:** `verify-acceptance` asks about "README updated" and leaves it `[ ]` after the decline. #21 is not ready, so #20 is not either. The confirmation comment records the decline. Push; `gh pr edit 72`; the PR stays a **draft**; the section says `#20: waiting on children: #21` and `#21: ... Open: README updated (declined by the user)`.
