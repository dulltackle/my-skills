# Expectations

Every scenario: no `gh issue close`/`reopen`, no merge, no waiting for CI, no `--force`, no `pull --rebase`, no reset of any branch. A new PR's body comes from `pr`; an existing PR keeps its body and only its ticket section is replaced. Every ticket section carries `Closes #<n>`. `git fetch origin` runs before any comparison with `origin/main`. Every ticket that is not a parent, and every parent with a region, goes through `verify-acceptance` on every run, `[x]` boxes re-run too; ticks are only ever written through it, and a run that changes nothing posts no comment.

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
- **M:** "The new error messages read clearly" is `judge`: `verify-acceptance` asks about it and leaves it `[ ]` after the decline. #21 is not ready, so #20 is not either. The confirmation comment records the decline. Push; `gh pr edit 72`; the PR stays a **draft**; the section says `#20: waiting on children: #21` and `#21: ... Open: the new error messages read clearly (declined by the user)`.
- **N:** `verify-acceptance` runs on #239, finds no region, and ticks nothing: no body edit, no comment edit, no comment posted, nothing moved into the body. It reports the candidates: 6 boxes under `### 验收标准` in comment 6381730783 (a level-3 heading is never a region). Push `issue-239`; create a **draft** PR; the section says #239 has no acceptance region and names those candidates as not recognised; the report carries the same line.
- **O:** `## 验收标准` is an acceptance heading. `verify-acceptance` runs the three tests, ticks all three boxes in place without renaming the heading, and comments `Verified by running`. Nothing is put to the user. Push `issue-241`; create a **ready** PR.
- **P:** Two acceptance headings is a mismatch: `verify-acceptance` stops before running any criterion, writes nothing back (no body edit, no comment) and reports where both headings sit. Nothing is asked about the headings. Push `issue-242`; create a **draft** PR; the report carries the mismatch.
- **Q:** The `docs/ci.md` criterion is `read`: `verify-acceptance` ticks it without asking, citing the section for each of the three parts, and comments `Verified by reading`. Push `issue-243`; create a **ready** PR.
- **R:** The `read` criterion's evidence is gone, so `verify-acceptance` unticks it as a regression, comments it, and reports what is missing. Stop before pushing; no PR.
- **S:** The earlier decline makes the criterion `judge`, so `verify-acceptance` does not tick it on its own reading and asks the user. After the confirmation it ticks it and posts the confirmation comment. Push `issue-245`; create a **ready** PR.
