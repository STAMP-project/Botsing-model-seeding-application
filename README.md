# Botsing-model-seeding-application
This repository contains the replication package for the Botsing model-seeding, test-seeding, and no-seeding evaluation on the 124 crashes from JCrashPack.

This Evaluation contains 3 phases: 1) model generation, 2) Botsing execution (no-seiding, test-seeding, and model-seeding), and 3) analysis (manual and statistical). In this README, we will explain how you can repicate each of these steps.


## Model generation
For model generation, you need to run following bash script in the root directory:

```bash
. Evaluation/model-generation/main.sh
```

This script will create all of the models for the second step in `Evaluation/analysis-result`.

__Note:__ The result of this part is already available in `Evaluation/analysis-result`.

__Note:__ This script parallelize the process of model generation. The default number of parallel processes is 15. You can change it in line `5` of `main.sh` script.

## Botsing execution
### no-seeding
For running __no-seeding__ executions, you need to run following bash script in the root directory:

```bash
. Evaluation/crash-reproduction-no-seeding/main.sh
```

The execution log of Botsing will be saved in `Evaluation/crash-reproduction-no-seeding/logs/` directory.

The generated tests by Botsing will be saved in `Evaluation/crash-reproduction-no-seeding/results` directory.

The useful information for statistical analysis will be saved in `Evaluation/crash-reproduction-no-seeding/results/results.csv`. __This file already contains the information for step 3.__

__Note:__ This script parallelize the process of test generation. The default number of parallel processes is 50. You can change it in line `5` of `main.sh` script.

### test-seeding
For running __test-seeding__ executions, you need to run following bash script in the root directory:

```bash
. Evaluation/crash-reproduction-test-seeding/main.sh
```

The execution log of Botsing will be saved in `Evaluation/crash-reproduction-test-seeding/logs/` directory.

The generated tests by Botsing with test seeding will be saved in `Evaluation/crash-reproduction-test-seeding/results` directory.

The useful information for statistical analysis will be saved in `Evaluation/crash-reproduction-test-seeding/results/results.csv`. __This file already contains the information for step 3.__

__Note:__ This script parallelize the process of test generation. The default number of parallel processes is 50. You can change it in line `5` of `main.sh` script.


### model-seeding
For running __model-seeding__ executions, you need to run following bash script in the root directory:

```bash
. Evaluation/crash-reproduction-model-seeding/main.sh
```

The execution log of Botsing will be saved in `Evaluation/crash-reproduction-model-seeding/logs/` directory.

The generated tests by Botsing with model seeding will be saved in `Evaluation/crash-reproduction-model-seeding/results` directory.

The useful information for statistical analysis will be saved in `Evaluation/crash-reproduction-model-seeding/results/results.csv`. __This file already contains the information for step 3.__

__Note:__ This script parallelize the process of test generation. The default number of parallel processes is 50. You can change it in line `5` of `main.sh` script.


## Analysis

### Manual analysis

The notes about the results of manual analysis is available in `Analysis/manual-analysis/`.

### Statistical Analysis
The avaialble R Script in `Analysis/RScripts` applies the needed statistical tests to answer the research questions. It also, generates the graphs and tables, which are used in the paper.

For collecting the results of each research question, you can run the R scripts which start with `rq<number of research question>`.
