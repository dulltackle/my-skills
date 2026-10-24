# Expectations

Every scenario: no `git push`, no `gh pr`, no `gh issue close` or `gh issue reopen`. The report ends by pointing at `to-pr`. The commit carries `Refs: #<n>` and never `Closes`/`Fixes`. Verification goes through `verify-acceptance`.

- **A:** Stage everything, one commit, then re-read the body, tick all three, comment. Branch stays unpushed.
- **B:** Commit; tick the five that ran. The sixth stays `[ ]` as unverified (not `read`, not asked of the user) and is reported. Nothing is pushed: `to-pr` decides delivery.
- **C:** Commit; no ticks and no invented criteria; state that #226 has no acceptance criteria region and nothing was written back. Nothing is pushed or closed.
- **D:** Commit; untick "concurrent writes lose no orders" loudly and comment it as unticked on regression. The ticket stays CLOSED; report that reopening is the user's call.
- **E:** Commit; tick the two `ran` criteria; ask about "README updated" only; after the yes, tick it with a confirmation comment. Still no push or close.
- **F:** Commit only `src/a.ts`; `src/b.ts` stays unstaged and uncommitted. Tick and comment as in A.
