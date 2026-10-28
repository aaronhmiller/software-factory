#!/usr/bin/env bash
# The repo's checks. Exit 0 only when the branch is fit to review.
#
# The gate runs this script from the main checkout with the job's worktree as
# the working directory. Keep it fast, deterministic and non-interactive: no
# watch modes, no prompts, nothing that rewrites files.
set -euo pipefail

export PYTHONDONTWRITEBYTECODE=1

# Syntax check every Python file without writing .pyc files.
python3 - <<'PY'
import ast, pathlib, sys
files = [p for p in pathlib.Path(".").rglob("*.py")
         if not any(part.startswith(".") or part in {"factory", "node_modules", "__pycache__"} for part in p.parts)]
for f in files:
    ast.parse(f.read_text(), filename=str(f))
print(f"syntax ok: {len(files)} python file(s)")
PY

# The static page must not build HTML from strings (AGENTS.md convention).
if grep -nE "innerHTML|insertAdjacentHTML|document\.write|\beval\(" web/*.html; then
  echo "checks: web/ uses string-to-HTML APIs; use textContent or DOM nodes" >&2
  exit 1
fi

# Unit tests.
python3 -m unittest discover -s tests -t . 
