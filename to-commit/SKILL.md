---
name: to-commit
description: "Commit a finished ticket as one Conventional Commit and tick its verified acceptance criteria on the ticket. Use when work for a ticket is done and needs committing, or when /implement finishes a ticket. Never pushes or opens a PR."
---

# To Commit

Commit the session's work as **one commit for one ticket**, and land the earned acceptance ticks with it.

The commit and the write-back **succeed together or neither does**. An earned `[x]` must never outlive the commit that earned it, and code must never land in a commit whose ticket did not come with it.

**Delivery is not this skill's job.** It never pushes, opens a PR, closes or reopens a ticket. The ticket closes when the PR that `to-pr` opens merges.

## Process

### 1. Identify the ticket

One ticket, one commit, though a ticket legitimately comes back for a second run. If the session spans more than one ticket, stop and say so.

### 2. Verify the criteria

Call the Skill tool with "verify-acceptance" and run its steps 1 and 2: read and classify the criteria. Hold its write-back: step 4 places it around the commit.

### 3. Peek at house style

Read the repo's recent `git log` for scope vocabulary, tense, casing. Local convention outranks the template below.

### 4. Land the commit and the first write-back

The order flips by tracker, because the invariant above has to hold on both:

- **Remote tracker**: the ticket lives outside the repo. **Commit, then write back** (verify-acceptance step 3). A failed write-back leaves a split state: the commit has landed and stays landed, so report it honestly.
- **Local markdown**: the ticket file is *in* the repo, so it belongs in the same commit. **Write back, then commit**, with the ticket file staged. Any failure rolls the ticks back and commits nothing.

#### Scope

Follow the commit scope the user's instructions set, if any. Otherwise: when something is already staged, commit only what is staged and leave unstaged edits alone; when nothing is staged, stage everything. On a local tracker, stage the ticket file as well.

Leave `Closes`/`Fixes` out of the commit: the closing keyword belongs to the PR body, where draft status gates it. A trailer would close the ticket wherever the commit lands, on evidence nobody checked.

#### When the commit fails

It is almost always a pre-commit hook, in one of two kinds:

- **The hook rewrote files** (`lint-staged --fix`, prettier, a formatter). The work is fine, the hook just moved it. Re-stage and retry **once**: a hard limit, never a loop. Report which files it touched and that they are in the commit.
- **The hook refused** (tests red, types broken, an unfixable lint error). Stop, and show the hook's own output verbatim. The hook is the user's gate and this skill has no standing to open it, so `--no-verify` is off the table. A retry that fails again counts as a refusal.

A refusal leaves the tree holding the work, so there is nothing to undo, except on local markdown, where the invariant sends you to roll the ticks back first.

```
⚠ #03 not committed: pre-commit failed

  items.test.ts → 2 failed

Ticket ticks rolled back, file restored. Fix and re-run to-commit.
```

### 5. Confirm the `read` criteria

Run verify-acceptance steps 4 and 5. A commit has landed by now, so a failure here is a split state, never a rollback. On a local tracker, land the confirmations as a follow-up `chore:` commit; never amend.

### 6. Report and hand off

Report the commit, the branch, and the criteria still `[ ]` with why, then stop. The commit is local and the ticket stays open, whatever its ticks say.

```
#42 committed abc1234 (branch feat/items, not pushed)
Acceptance 3/4 ticked; open: concurrent writes lose no orders (items.test.ts fails)
Next: to-pr delivers the branch
```

## Template

Write the commit message and the report in the language the user's instructions or the repo's history use. The template fixes the structure, not the language. `Refs:` is a git trailer key and the `feat`/`fix` prefixes are format, so both stay as they are.

<commit-template>
<type>(<scope>): <imperative summary, from the ticket title>

<one or two lines: the end-to-end behaviour this commit delivers, from the ticket's "What to build">

Verified on this commit:
- <criterion>

Not verified on this commit:
- <criterion>

Refs: #<ticket id>
</commit-template>

- Include `<scope>` only where the repo's log shows an established scope vocabulary.
- Drop "Not verified on this commit" entirely when every criterion was `ran`. Where it appears it states a fact about this commit and claims no sign-off from anyone.
- The message states what **this commit** delivered, in plain facts with no `- [ ]` / `- [x]` marks: checkboxes belong to the ticket. A reworked ticket spans several commits, and a snapshot of the whole ticket in each would leave conflicting half-lists.
- On a local tracker there are no issue ids: use `Refs: .scratch/<feature-slug>/issues/<NN>-<slug>.md`.
