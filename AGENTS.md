# software-factory

A tiny standard-library calculator that exists to exercise the software
factory in `factory/` and `.claude/`. `calc.py` holds the functions, `tests/`
the `unittest` suite, and `web/index.html` a static page that adds two numbers.

## Layout

```
calc.py            the calculator functions (standard library only)
tests/test_calc.py one unittest class per function
web/index.html     the static page: markup, styles and script in one file
factory/           the software factory (see below)
.claude/           the factory's skill and agents
```

## Fresh checkout

Nothing to install. Python 3.9 or later from the standard library is enough.
No env files, no build step.

## Dev server

The page is static. Serve `web/` on a given port:

```bash
python3 -m http.server <port> --directory web
```

Then open `http://localhost:<port>/`.

## Validation

These are the checks `factory/checks.sh` runs. Run them from the repo root.

```bash
python3 -m unittest discover -s tests -t .
bash factory/checks.sh
```

## Conventions

- Every function in `calc.py` has a test in `tests/`. New functions get a new
  `tests/test_<name>.py` with a `<Name>Test` class, in the style of
  `tests/test_calc.py`. Existing test files are protected and are not edited.
- Standard library only. No dependencies, lockfiles, build tools or CI.
- `web/index.html` stays one file. Anything derived from input reaches the DOM
  through `textContent` or DOM nodes, never `innerHTML`.
- One-line commit messages in the style of `git log --oneline`.

## Scope

This project is a tiny standard-library calculator (`calc.py`, its tests, and
a static page in `web/`) that exists to exercise the factory. Anything that
isn't a small, testable change to it doesn't belong here.

## Security hot spots

- `web/index.html` is the only user-facing surface. Anything derived from
  input must reach the DOM through `textContent` or DOM nodes, never
  `innerHTML`, `insertAdjacentHTML`, `document.write` or `eval`. No inline
  event handlers in markup, no remote scripts or stylesheets.
- `calc.py` is pure standard-library code with no I/O. A new import, a file
  read, a subprocess, a network call or an environment lookup is a finding.
- The dev server is `python3 -m http.server`; nothing in the repo may be
  reachable from the page except `web/`.
- No dependencies, lockfiles, CI, hooks or scripts that run on checkout.

## Styling

There are no design tokens or shared components: all styles live in the
`<style>` block of `web/index.html` (system font stack, `#222` text on white,
6px radii, 8px and 16px spacing). New values come from what is already there.

## Who uses this

The page has one kind of user: a person who opens it to try the calculator,
on a desktop or a phone, with no account and nothing to sign in to. Everything
must work for them on first load, with the keyboard alone, and with a screen
reader.

## Software factory

`/factory run` builds every open GitHub issue labeled `factory` through
intake → spec → build → gate → review → approve, one PR per issue. State is in
`factory/jobs/` (gitignored); `factory/bin/job` is its only writer. Checks:
`factory/checks.sh`. Dashboard: `cd factory && python3 -m http.server`, then
open http://localhost:8000/dashboard.html.
