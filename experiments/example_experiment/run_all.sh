#!/usr/bin/env bash
# <experiment name>: <the question this experiment answers, one line>
# Stages, in order: prepare -> experiment -> plot. Each stage reads the outputs of the previous one.
#
# Usage (from anywhere): experiments/<experiment>/run_all.sh
#   GPU=<index>            selects the GPU, if the experiment uses one
#   RESULTS_SUBDIR=<name>  writes under results/<name>/ instead of the stored results
set -euo pipefail
cd "$(dirname "$0")/../.."  # project root

GPU="${GPU:-0}"
PY=.venv/bin/python
MOD=experiments.<experiment>.src

# prepare: data/ -> results/data/  (the inputs of this experiment)
$PY -m $MOD.prepare.prepare_data

# experiment: results/data/ -> results/data/  (the outputs; check the GPU is free before a GPU run)
nvidia-smi --query-gpu=index,memory.used --format=csv -i "$GPU"
CUDA_VISIBLE_DEVICES="$GPU" $PY -m $MOD.experiment.run_experiment

# plot: results/data/ -> results/figures/
$PY -m $MOD.plot.plot_results
