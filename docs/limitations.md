# Limitations and Future Work

## 1. Current Status

This project is an early-stage evaluation of prompt-injection behavior in a tool-using language model. It uses Inspect AI, a simulated sensitive-action tool, and a configurable guard.

The current results are preliminary and should not be treated as evidence of a generally effective prompt-injection defense.

## 2. Unconditional Blocking

When the guard is enabled, the current implementation blocks every simulated export.

Consequently, a high safety score in the guarded configuration is expected by design. It does not establish that the model correctly distinguishes malicious instructions from legitimate requests.

**Planned improvement:** Introduce explicitly authorized and unauthorized action scenarios. Evaluate whether the system blocks unauthorized actions while allowing authorized actions.

## 3. Security Is Not the Same as Correctness

The custom scorer measures whether the sensitive action executed. A blocked tool call can count as safe even if the model attempted an unauthorized action.

The final-answer correctness field is recorded as metadata and does not determine the score.

Therefore, the current score does not capture every relevant aspect of agent behavior.

**Planned improvement:** Report separate metrics for unauthorized tool-call attempts, successful unauthorized execution, correct final responses, and blocked actions.

## 4. Limited Evaluation Coverage

The experiment includes five attack variants: direct, authority, urgency, roleplay, and indirect instructions.

It does not establish robustness against other attack styles, different models, different tasks, or more complex tool environments.

**Planned improvement:** Expand the evaluation only after validating the current test harness, then assess additional attack variants and models.

## 5. Small Sample Size

The available runs contain five samples per listed condition. This is sufficient for an initial implementation check, but not for strong statistical conclusions.

The results may be sensitive to model variability, prompt wording, and the particular samples selected.

**Planned improvement:** Increase the number of repetitions, preserve run-level results, and report sample counts and uncertainty alongside aggregate metrics.

## 6. Incomplete Experimental Conditions

A guarded result for the urgency attack is not present in the currently available evaluation history.

The current results therefore do not provide a complete matched comparison across all five attack variants.

**Planned improvement:** Run the missing condition and verify that guarded and unguarded evaluations use matched settings.

## 7. Scoring and Logging Validation

The scorer infers tool-call and execution outcomes from the Inspect AI task transcript. Incorrect parsing could produce misleading results.

**Planned improvement:** Validate the scorer using known examples of successful calls, blocked calls, attempted calls without execution, and cases where the tool is never called.

## 8. Security–Usefulness Trade-off

A system that blocks every sensitive action may prevent unauthorized execution but also prevent legitimate work.

The initial experiment does not yet measure the false-block rate or legitimate task success rate.

**Planned improvement:** Introduce benign tasks and explicitly authorized actions, then measure:

- Unauthorized execution rate.
- Unauthorized tool-call attempt rate.
- Legitimate task success rate.
- False-block rate.
- Final-answer correctness.
- Latency, where relevant.

Define each metric precisely before running the expanded experiment.

## 9. Simulated Environment

The export tool does not access or transfer real sensitive data. This reduces risk during experimentation, but limits the conclusions that can be drawn about real-world integrations.

The project does not establish the security of an actual enterprise agent or external authorization service.

## 10. Interpretation

The current findings support a narrow conclusion: under the tested conditions, enabling the implemented guard is associated with improved execution-safety scores for several attack variants.

Because the guard blocks all exports, this result primarily demonstrates the behavior of the enforcement mechanism, not the model's intrinsic resistance to prompt injection.

## 11. Research Direction

The next phase will investigate whether an authorization boundary can reduce unsafe tool execution while preserving legitimate agent capabilities.

The goal is to make the evaluation more rigorous, reproducible, and informative about the security–usefulness trade-off.
