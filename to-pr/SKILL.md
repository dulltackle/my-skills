---
name: to-pr
description: "Deliver the current branch as a pull request that closes its tickets on merge: draft until every acceptance criterion is earned, ready once it is. Use when the user wants to open or update a PR for ticket work, or at the end of /implement and /implement-spec. Safe to re-run."
---

# To PR

Put the current branch on the remote as **one PR for its tickets**. The body says `Closes #<n>` from the start; **draft status is the gate**, since a draft cannot merge. The ticket closes when the PR merges, and no step of this skill closes or reopens a ticket.

Read state from git, the PR, and the tracker, never from another skill's memory. Whoever committed the work (/implement, implementer subagents, or the user by hand), this skill does the same thing.

Re-running is normal: a PR that already exists for the branch is updated, never duplicated.

## Process

### 1. Identify the tickets

Read `docs/agents/issue-tracker.md` for how to read tickets. If it is missing, tell the user to run `/setup-matt-pocock-skills`.

Take the first source that names any ticket:

1. The user's arguments.
2. The `Closes #<n>` lines in the body of the branch's existing PR (`gh pr view --json body`).
3. The `Refs: #<n>` trailers of the commits on `origin/<default>..HEAD`.

None found → stop and ask which ticket this delivers.

### 2. Check the tree

Stop and report, changing nothing, when:

- there is no remote: a PR needs one;
- the tree has staged or unstaged changes: commit them first;
- `HEAD` has no commits ahead of `origin/<default>`: there is nothing to deliver.

### 3. Get onto a feature branch

- **A feature branch** → use it.
- **Detached `HEAD`** → `git switch -c issue-<n>`, `<n>` being the first ticket.
- **The default branch** → `git switch -c issue-<n>` the same way, and report that local `<default>` is now ahead of the remote by those commits. Never reset it: moving the user's branch back is their call.

If `issue-<n>` already exists, locally or on the remote, at another commit → stop and report. Never overwrite a branch.

### 4. Verify what is still open

Read the default branch's **required checks**, the merge gate:

```bash
gh api repos/{owner}/{repo}/branches/<default>/protection/required_status_checks --jq '.contexts'
gh api repos/{owner}/{repo}/rules/branches/<default>   # rulesets: type "required_status_checks"
```

An unticked criterion is **merge-gated** when its text asks for exactly this: this PR passing some or all of those required checks. GitHub enforces it before merge, so it need not be earned first. Unreadable protection or no required checks → nothing is merge-gated.

Re-read every ticket from the tracker. A ticket is a **parent** when another ticket in the set belongs to it, the way `docs/agents/issue-tracker.md` records that (on GitHub: a sub-issue, or a child naming it in `Part of #<n>` or a `## Parent` section). A spec delivered with its tickets is the usual parent, and it usually has no region of its own.

For each ticket with an unticked criterion that is not merge-gated, call the Skill tool with "verify-acceptance" and run all of its steps against `HEAD`. On a local tracker, commit its ticket edits as a follow-up `chore:` commit before pushing.

When a `ran` criterion fails on `HEAD`, stop before pushing: failing work stays local. If the branch already has a PR that is ready, mark it back to draft first (`gh pr ready <pr> --undo`) so it cannot merge, then report.

### 5. Decide draft or ready

A ticket is **ready** when its region is non-empty and every box in it is `[x]` or merge-gated. A parent is ready when every child in the set is, and every box in its own region, if it has one, is `[x]` or merge-gated. The PR is **ready** when every ticket is; otherwise it is a **draft**. A non-parent with no region, an unverified criterion, one awaiting the user's word: all draft.

### 6. Write the body

Call the Skill tool with "pr" for the body. Append the ticket section from the template below. When the branch's PR already has a body, keep what it says about the change and replace only the ticket section. Keep it short: the PR is a pointer to the tickets, not a copy of them.

### 7. Push

`git push -u origin <branch>` the first time, `git push` after.

**A refused push** (non-fast-forward, protected branch, pre-push hook) stops the run. Report it and hand back the command to retry. `pull --rebase` rewrites the user's commits and `--force` is off the table: the remote is the user's gate, exactly as a pre-commit hook is.

### 8. Open or update the PR

```bash
gh pr view --json number,url,isDraft          # does the branch have one?
gh pr create --base <default> --title "<title>" --body-file "$TMPDIR/pr-body.md" [--draft]
gh pr edit <pr> --body-file "$TMPDIR/pr-body.md"
gh pr ready <pr>             # draft → ready
gh pr ready <pr> --undo      # ready → draft, when a criterion lost its tick
```

Title: the commit subject when there is one commit, otherwise the ticket's title. An existing PR keeps its title.

For another tracker or forge, take the equivalent commands from `docs/agents/issue-tracker.md`; where it gives none, stop and ask.

Do not wait for CI and do not merge. Merging is the user's decision.

### 9. Report

```
PR #57 (draft) https://github.com/o/r/pull/57 ← branch issue-42, pushed
#42 open: concurrent writes lose no orders (not verified)
Guaranteed by the merge gate: PR passes check
```

Add any line from step 3, such as `local main is 2 commits ahead of the remote, not reset`.

## Template

Write the ticket section and the report in the language the user's instructions or the repo's history use. The template fixes the structure, not the language. `Closes` is GitHub's keyword, so it stays as it is.

<ticket-section>
## Tickets

Closes #42

- #42: acceptance 3/4 ticked. Open: concurrent writes lose no orders (not verified)
- Guaranteed by the merge gate: PR passes check, process-trace
</ticket-section>

- One `Closes` line per ticket.
- Per ticket, one line: ticks earned, then what is still open and why. A ticket with no region says `no acceptance region`; a parent says `ready when its children are: #11, #12`, plus its own ticks if it has a region; one whose only open boxes are merge-gated says `acceptance 5/6 ticked, the remaining 1 guaranteed by the merge gate`.
- Drop the merge-gate line when nothing is merge-gated.
