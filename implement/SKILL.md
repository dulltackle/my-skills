---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, spawn one read-only subagent with the ticket context that calls the Skill tool with "open-code-review-delegate" to review the work. If the `ocr` CLI is missing, stop and report that review is blocked. Validate its findings, fix the valid ones, and rerun the affected tests.

Call the Skill tool twice, for "to-commit" and then "to-pr", to commit your work and deliver it as a pull request.
