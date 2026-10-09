# <Experiment name>: <the question in one line>

<Two or three sentences: what is asked, and the one-line answer once the results are in.>

**Answer:** <one line with the key numbers>.

## Setup

- <Inputs: what is evaluated and how many.>
- <Conditions, one line each, named exactly as in the code.>
- <Metric: what is measured and how.>
- <Only the settings a reader needs to interpret the results.>

## Results

| Condition | Metric |
|---|---|
| <A> | <0.00> |
| <B> | <0.00> |

![<figure>](results/figures/<figure>.png)

- <Finding 1.>
- <Finding 2.>

## Notes

- <Caveats a reader must know; at most five.>

## Run

```bash
experiments/<experiment>/run_all.sh
```

Single steps, from the project root:

```bash
.venv/bin/python -m experiments.<experiment>.src.prepare.prepare_data        # data/ -> results/data/
.venv/bin/python -m experiments.<experiment>.src.experiment.run_experiment   # results/data/ -> results/data/
.venv/bin/python -m experiments.<experiment>.src.plot.plot_results           # results/data/ -> results/figures/
```

`RESULTS_SUBDIR=<name>` writes under `results/<name>/` instead of the stored results.

## Files

```
src/
├── prepare/        builds the inputs of this experiment from data/
├── experiment/     runs the experiment on them
└── plot/           draws the figures from the outputs
results/
├── data/           inputs and outputs of each run (git-ignored)
└── figures/        figures embedded above (tracked)
```
