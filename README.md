# software-factory

A software factory that works through this repo's GitHub issues. Label an
issue `factory`, run `/factory run` in Claude Code, and agents decide whether
it's worth building, write a spec, build it, test it with `factory/checks.sh`,
review it, and open a pull request that closes the issue. The approver merges
what it's sure of and hands you the rest.

The repo also holds a tiny calculator (`calc.py`, `tests/`, `web/index.html`)
for the factory to work on. Swap it for a real project by replacing those
files, `factory/checks.sh` and the project parts of `AGENTS.md`.

## The loop

```
issues labeled `factory`
        │
        ▼
intake (fable) ── NEEDS-INFO → asks the author on the issue, waits for a reply
        │         REJECT     → says why on the issue, removes the label
        ▼ ACCEPT, maybe rescoped; rates risk + surfaces
route (script)    picks reviewers and models from config.json
        ▼
spec-writer (opus) → spec.md
        ▼
builder (sonnet, opus when risky) → commits, pushes, opens a draft PR "Closes #n"
        ▼            ▲
gate (script) ─FAIL──┤  factory/checks.sh; no reviewer runs on a failing build
        ▼ PASS       │
reviewers ─CHANGES───┘  code (haiku | sonnet) + CodeRabbit, + ux & ui on UI changes,
        │                + security + CodeRabbit security on security changes
        ▼ all PASS
approver (opus) ── APPROVE  → sync with main, gate again, gh pr merge
                └─ ESCALATE → PR ready for you, issue labeled factory:needs-human
```

## Commands

```
/factory run          drain the queue: every open `factory` issue, `concurrency` at a time; also resumes
/factory issue <n>    one issue now
/factory <feature>    create the issue (labeled), then run it
/factory rework <n>   send an escalated job back to the builder with your PR comments
```

You approve by merging the PR on GitHub.

## What's in here

```
.claude/
  skills/factory/SKILL.md     the orchestrator: queue, concurrency, the pipeline
  agents/
    intake.md                 fable    worth building? at what scope? risk + surfaces
    spec-writer.md            opus     spec.md
    builder.md                routed   code, commits, the PR, build.md
    reviewer-code.md          routed   correctness, scope, simplicity, tests
    reviewer-coderabbit.md    routed   runs the CodeRabbit CLI on the branch, keeps confirmed major findings
    reviewer-security.md      opus     only when intake flags `security`
    reviewer-coderabbit-security.md
                              sonnet   only when intake flags `security`; deep CodeRabbit review, security findings only
    reviewer-ux.md            sonnet   only when intake flags `ui`
    reviewer-ui.md            haiku    only when intake flags `ui`
    approver.md               opus     APPROVE or ESCALATE
factory/
  config.json                 concurrency, rounds, labels, routing, protected paths, prices
  checks.sh                   this repo's checks: syntax, no string-to-HTML in web/, unit tests
  bin/job                     the only writer of job.json; refuses illegal moves; merges
  bin/gate                    runs checks.sh in a job's worktree → round-N/checks.md
  bin/route                   risk + surfaces → the job's reviewers and models
  bin/cr-review               runs a CodeRabbit review detached and waits for it (reviews outlast one Bash call)
  dashboard.html              the board
AGENTS.md                     what every agent reads first
```

## Dashboard

```bash
cd factory && python3 -m http.server
```

Open <http://localhost:8000/dashboard.html>. Each job is a card with its issue
and PR, a row of gate and review chips per round, its risk, builder model,
cost and time. Click a card to read every file the job wrote.

## Requirements

- Claude Code 2.1.257 or later, `python3` 3.9 or later, and an authenticated
  `gh` that can push to this repo and manage its labels.
- The labels, created once:

  ```bash
  gh label create factory --color 5319E7 --description "Build this with the software factory"
  gh label create factory:needs-info --color FBCA04 --description "The factory asked the author a question"
  gh label create factory:needs-human --color D93F0B --description "The factory needs a human decision on the PR"
  ```

- The [CodeRabbit CLI](https://docs.coderabbit.ai/cli), installed and signed in
  (`coderabbit auth login`; `coderabbit doctor` checks it), for the two
  CodeRabbit reviewers. It allows a limited number of reviews per hour
  (`coderabbit usage` shows yours), and each job uses one or two per round. When the CLI is
  missing or over its limit, those reviewers report an error and the job waits
  in review until `/factory run` resumes it.

- Optional: the [`agent-browser`](https://github.com/vercel-labs/agent-browser)
  CLI, so the builder and the UX and UI reviewers can drive the page. Without
  it they review the markup statically and say so.

## Cost and safety

- It opens and merges real PRs and runs on your Claude plan. Start with
  `concurrency: 1` in `factory/config.json` and read every PR until you trust it.
- Intake runs on Fable once per issue. Depending on your plan, Fable can bill
  to usage credits rather than your plan's included usage.
- Only issues labeled `factory` run, and only people with triage or write
  access can add labels. Issue text reaches the agents as quoted data, never
  as their instructions.
- The factory pushes only `factory/*` branches, merges only through
  `gh pr merge`, and never deploys.

## Credits and license

The factory design, scripts and dashboard come from
[ZazenCodes' Software Factory for Claude Code v2](https://github.com/zazencodes/zazencodes-season-3/tree/main/src/software-factory-claude-code-v2),
released under the [GPLv3](LICENSE). This repo keeps that license.
