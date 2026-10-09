# CLAUDE.md

Working rules for this project. Read `README.md` for the folder layout.

## Layout and workflow

- Shared code lives in `common/`, shared inputs in `data/`. Each experiment is `experiments/<exp>/` with
  `run_all.sh`, `src/{prepare,experiment,plot}/`, and `results/{data,figures}/`.
- Data flows one way: `data/` → `src/prepare/` → `results/data/` → `src/experiment/` → `results/data/` →
  `src/plot/` → `results/figures/`. Write the code in that order, prepare first and plot last, and let each stage
  read only what the previous stage wrote.
- Scripts are modules run from the project root (`.venv/bin/python -m experiments.<exp>.src.<stage>.<script>`).
  No script computes its own output path: every path comes from `common/paths.py`, and `RESULTS_SUBDIR=<name>`
  redirects a whole run to `results/<name>/`.
- `run_all.sh` lists the stages in order with one comment per stage. It is the record of how the experiment was
  run, so keep it current when a step changes.
- Each question gets its own experiment folder, built on what `common/` already offers. An existing experiment's
  scripts are never modified to run a variant; the variant is a new folder.
- `common/` grows with the experiments, since what they need changes over time. It grows without touching what
  earlier experiments produce: add a new function, or a new branch behind an argument whose default keeps the
  old behaviour, and verify that the earlier experiments are unchanged (see "Working with Claude"). When an
  experiment is dropped, go over `common/` and delete what nothing uses any more.

## Code

- Write the least code that does the job: no options, branches or generality for cases that are not being run,
  and no code kept "in case". When an output is dropped, the code that produced it goes too. Less code is easier
  to review and to reproduce.
- Two options are always there because the workflow needs them: a smoke-test size, so a run can be tried on a
  few items first, and `RESULTS_SUBDIR`, so results produced while an experiment is still being developed stay
  apart from the stored ones and a re-run can be compared with them.
- A function's name says what it does. The most important inputs come first in its signature.
- One function does one thing, so a failure points at one place. Do not split a single job into a chain of tiny
  functions that a reader has to follow through several files.
- Inside a function, separate the steps with blank lines and start every such block with a one-line comment
  that says what the block does.
- Repeated code goes into `common/`, but only when two experiments really use the same thing. Prefer a plain
  function with explicit arguments over a class or a configuration layer.
- Record where adapted code comes from (repository, file, commit) in a comment at the top of the module.

## Running experiments

- Before any run, check the code statically (`py_compile`, import resolution). Then run small: a smoke test on a
  few items before the full run.
- Ask which GPU to use before every launch and check that it is free each time, not once per session.
- Never start a long run or a run that costs money (GPU hours, API calls) without being told to. Report its size
  first (compute time, number of calls, tokens) in a table and wait for the go-ahead.
- Long runs go to the background with their logs under `results/`; poll the log or the output file, never a process
  name pattern that can match the polling command itself.
- Re-runs go to `RESULTS_SUBDIR=<name>`. The stored results are only replaced on purpose.

## Checking reproducibility

- A result counts as reproduced when a re-run with the same settings gives the same raw outputs and the same
  metrics within the measurement's own noise. Compare the raw outputs first (exact match where the process is
  deterministic), then the metrics.
- Fix and document everything that can change the raw outputs: random seeds, numeric precision, how inputs are
  batched or padded, the order of operations, library versions. A change in any of them is a different
  experiment, not a re-run.
- When a metric is itself noisy (a model, a human, a sampled estimate), measure that noise before comparing
  anything with it: score the same sample twice and report the agreement. Differences smaller than that noise are
  not findings.
- Scores from different scorers (another model, another annotator, another metric version) are not
  interchangeable: never mix them in one table, and re-score everything when the scorer changes.
- Anything scored by an external model is scored blind (no condition names in the request, shuffled order) and
  resumably (a re-run fills in only the missing items).

## Documentation

- Each experiment README reads in under three minutes: the question and its one-line answer, Setup, Results
  (tables and figures), Notes, Run, Files. Details are understood from the code, not the README.
- Write the settings a reader needs to reproduce the result. Do not write the values actually used for anything
  else (machine, GPU index, timings, paths outside the project).
- The root README states what was tested, the results with tables and figures, and how to reproduce.
- Keep every number in a README traceable to a file under `results/`.

## Working with Claude

- Say the plan first and get a confirmation before changing files or starting runs. When the work has several
  numbered steps, report completion step by step in a table with a column for anything unexpected.
- Once a run is approved, run it at small scale first and show the result before the full run.
- Give mechanical sub-tasks (documentation passes, comment passes, static checks) to a cheaper model with a
  self-contained brief: files allowed, what must not change, how to verify.
- Verify a change that should not alter behaviour with evidence, not by reading: identical ASTs for comment-only
  edits, `py_compile` and import resolution for moves, exact-match counts for re-runs.
- Report outcomes as they are: what failed, what was skipped, what was not verified.
