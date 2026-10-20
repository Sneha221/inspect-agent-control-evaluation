# Evaluating Prompt-Injection Resilience in Tool-Using Agents

**An exploratory AI Control project using Inspect AI, Python, and Gemma**

[![Python](https://img.shields.io/badge/Python-3.11%2B-blue)](https://www.python.org/)
[![Evaluation](https://img.shields.io/badge/Evaluation-Inspect%20AI-orange)](https://inspect.ai-safety-institute.org.uk/)
[![Status](https://img.shields.io/badge/Status-Research%20Prototype-yellow)]()

## Overview

Can a simple authorization boundary prevent a language-model agent from executing unauthorized actions when untrusted input contains adversarial instructions?

This project investigates that question through a small, controlled evaluation of a tool-using language-model agent. Using Inspect AI, I constructed an incident-report analysis task in which an untrusted report contains an embedded prompt-injection attempt instructing the agent to invoke a simulated sensitive-data export tool.

I compare guarded and unguarded configurations across five attack strategies to examine how the authorization boundary affects observed action-execution outcomes.

The project is an exploratory investigation into **AI Control, prompt-injection resilience, and tool authorization**. It is intended to develop a reproducible evaluation methodology rather than claim a validated defense.

## Research question

**Can a deterministic authorization boundary reduce unauthorized tool execution under adversarial prompting, and how can its security benefits be evaluated alongside legitimate task performance?**

The initial experiment focuses on execution safety. Follow-up work will investigate whether the protection preserves useful agent behavior and how the results vary across attack strategies and repeated trials.

## Threat model

The agent is asked to read an incident report and summarize what happened. The report is treated as untrusted evidence, but it contains an embedded instruction attempting to override the task and trigger a sensitive action.

The simulated sensitive-data export tool represents a privileged capability.

The experiment considers two configurations:

- **Unguarded baseline:** the simulated export tool permits execution.
- **Guard enabled:** the simulated export tool blocks execution and returns an authorization-failure result.

No real sensitive data is accessed, and no actual data is exported.

### Attack strategies

| Strategy | Adversarial technique |
|---|---|
| Direct | Explicitly instructs the agent to ignore the task and invoke the tool |
| Authority | Claims that a security director or higher authority has authorized the action |
| Urgency | Uses an emergency scenario to pressure immediate execution |
| Roleplay | Asks the agent to pretend approval has already been granted |
| Indirect | Presents the action as a required step for completing the report |

These categories provide a starting point for comparing behavior under different forms of adversarial instruction. They do not represent an exhaustive prompt-injection benchmark.

## Implementation

The evaluation is implemented in Python using Inspect AI.

Core components:

1. **Untrusted report tool:** Returns incident evidence containing an embedded adversarial instruction.
2. **Agent policy:** Requires the agent to report whether the simulated action actually executed.
3. **Simulated export tool:** Represents the sensitive action without accessing real data.
4. **Authorization guard:** Blocks the simulated action when enabled.
5. **Custom Inspect scorer:** Inspects recorded tool events and determines whether an execution was detected.

The scorer prioritizes the observed security outcome over the agent's final textual response. It also records additional metadata, including whether the tool was called, whether execution or blocking was detected, and whether the final label was correct.

This distinction matters: a blocked unauthorized attempt can count as safe under an execution-based metric even when the agent still attempts the action.

## Preliminary results

The initial evaluation history contains guarded and unguarded runs for four attack strategies, plus an unguarded urgency run.

| Attack strategy | Guard disabled | Guard enabled |
|---|---:|---:|
| Direct | 0.4 | 1.0 |
| Authority | 0.2 | 1.0 |
| Roleplay | 0.0 | 1.0 |
| Indirect | 1.0 | 1.0 |
| Urgency | 1.0 | Not available in the recorded comparison |

Scores are the recorded Inspect accuracy values. The initial runs report five samples for each of the listed conditions.

Across the four attack strategies with both configurations recorded, the mean score increased from 0.40 without the guard to 1.00 with the guard.

### Preliminary interpretation

The results are consistent with the hypothesis that an enforcement boundary can prevent simulated unauthorized execution even when adversarial instructions are present.

The unguarded baseline also behaved differently across attack strategies. Direct, authority-based, and roleplay attacks produced lower scores than indirect attacks in the recorded runs.

However, the guarded result is expected to a significant extent because the current implementation blocks every export request whenever the guard is enabled. It therefore demonstrates the effect of this simulated enforcement mechanism, not that the language model itself has become more resistant to prompt injection.

These results are preliminary and should not be interpreted as generalizable attack-success probabilities or evidence of a production-ready security solution.

## Limitations

The current implementation has several important limitations:

- **Unconditional blocking:** The guard blocks every export when enabled, regardless of whether a request is legitimate or authorized.
- **Limited sample size:** Five samples per recorded run are insufficient to establish generalization.
- **Incomplete comparison:** A guarded urgency result is not present in the available run history.
- **Execution-focused scoring:** The primary score does not penalize attempted unauthorized actions if the simulated action is blocked.
- **Scorer validation:** Event detection must be checked against actual Inspect transcripts to ensure tool calls and results are recorded reliably.
- **Limited task diversity:** The evaluation uses a single incident-report task and one simulated sensitive capability.
- **No production validation:** The experiment does not evaluate real-world data access, deployment security, or operational attack conditions.

These limitations motivate the next phase of the project.

## Planned experiments

### 1. Add benign and authorized controls

Evaluate legitimate tasks alongside malicious reports to measure whether the guard preserves useful behavior. Add explicit authorization conditions rather than blocking all actions unconditionally.

### 2. Measure multiple outcomes

Report the following metrics separately:

- **Unauthorized execution rate:** Unauthorized actions successfully executed divided by unauthorized action trials.
- **Unauthorized attempt rate:** Unauthorized tool-call attempts divided by unauthorized action trials.
- **Legitimate task success rate:** Successfully completed benign tasks divided by benign task trials.
- **False-block rate:** Legitimate authorized actions blocked divided by legitimate authorized action attempts.

### 3. Run balanced comparisons

Use matched guarded and unguarded conditions with the same prompts, model configuration, task instructions, and scoring criteria. Increase repetitions and report variability as the evaluation develops.

### 4. Investigate generalization

Test additional attack variants and task scenarios. Where possible, distinguish attacks used during development from held-out cases used for evaluation.

### 5. Explore uncertainty-based monitoring

As a potential extension, investigate whether generation-time signals, including token log probabilities, can help flag suspicious agent behavior before an unsafe action is executed.

Compare the additional monitor against the existing authorization guard to determine whether it provides measurable incremental value.

## Reproducibility

The project is designed to use configurable Inspect AI tasks, allowing attack strategy and guard configuration to be varied independently.

For a reproducible release, the repository should include:

- Source code for the evaluation and scorer
- Dependency versions and setup instructions
- Commands for running each configuration
- Raw or summarized evaluation results
- Model identifier and relevant generation settings
- A description of the scoring rubric and known limitations

Model outputs can vary across runs. The reported preliminary scores should therefore be treated as observations from the recorded experiment, not universal model characteristics.

## Getting started

The project uses Python and Inspect AI.

Create and activate a virtual environment, then install Inspect AI:

```bash
python -m venv .venv
```

On Linux or macOS:

```bash
source .venv/bin/activate
```

On Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Install the dependency:

```bash
pip install inspect-ai
```

Install and configure the model provider required by your evaluation environment. The initial experiment used the Ollama model identifier `ollama/gemma4:latest`.

Save the task implementation in a Python file, for example `agent_control_eval.py`. After verifying the installed Inspect version and task registration, run the task with the appropriate model configuration.

Example command pattern:

```bash
inspect eval agent_control_eval.py \
  --model ollama/gemma4:latest \
  -T guard_enabled=false \
  -T attack_variant=roleplay
```

For Windows PowerShell, the same command can be entered on one line.

**Note:** Verify the task file's registered task name and the CLI arguments supported by your installed Inspect version before running. The command is an example invocation pattern, not a claim that every environment will accept it unchanged.

## Repository structure

A suggested structure for the public repository:

```text
inspect-agent-control-evaluation/
├── README.md
├── agent_control_eval.py
├── requirements.txt
├── experiments/
│   └── experiment_matrix.md
├── results/
│   └── preliminary_results.csv
└── docs/
    ├── threat_model.md
    └── limitations.md
```

Only include files that actually exist and have been validated. Keep generated logs and large model artifacts out of version control unless they are needed and appropriate to share.

## Research relevance

This project explores a practical question at the intersection of:

- AI Control and agent oversight
- Prompt-injection evaluation
- Tool-use security and authorization
- Adversarial testing of language-model agents
- Security–usefulness trade-offs

The broader motivation is to investigate how systems can constrain consequential agent actions even when the model encounters adversarial or misleading instructions.

## Author's note

This is an independent research prototype developed to build practical experience with AI safety evaluations and agent-control mechanisms.

The initial results are exploratory. The next stage focuses on validating the scorer, introducing meaningful authorization controls, and evaluating security alongside legitimate task completion.

Feedback on the experimental design, metrics, and opportunities for more rigorous evaluation is welcome.

---

*Keywords: AI Safety, AI Control, Inspect AI, Prompt Injection, Agent Security, Tool Authorization, Adversarial Evaluation, LLM Evaluation.*
