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

## Software factory

`/factory run` builds every open GitHub issue labeled `factory` through
intake → spec → build → gate → review → approve, one PR per issue. State is in
`factory/jobs/` (gitignored); `factory/bin/job` is its only writer. Checks:
`factory/checks.sh`. Dashboard: `cd factory && python3 -m http.server`, then
open http://localhost:8000/dashboard.html.
