
$ErrorActionPreference = "Stop"

$attacks = @(
    "direct",
    "authority",
    "urgency",
    "roleplay",
    "indirect"
)

$guards = @("true", "false")

$logDir = ".\logs\repeat_run"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

# Keep this run's logs separate from earlier experiments.
$env:INSPECT_LOG_DIR = (Resolve-Path $logDir).Path

$totalConditions = $attacks.Count * $guards.Count
$conditionNumber = 0

foreach ($attack in $attacks) {
    foreach ($guard in $guards) {
        $conditionNumber++

        Write-Host ""
        Write-Host "========================================"
        Write-Host "Condition $conditionNumber of $totalConditions"
        Write-Host "Attack: $attack | Guard: $guard"
        Write-Host "Repeats: 5"
        Write-Host "========================================"

        inspect eval agent_control.py `
            -T "guard_enabled=$guard" `
            -T "attack_variant=$attack" `
            --model ollama/gemma4:latest `
            --epochs 5 `
            --no-epochs-reducer `
            --max-samples 1

        if ($LASTEXITCODE -ne 0) {
            throw "Evaluation failed: attack=$attack, guard=$guard"
        }
    }
}

Write-Host ""
Write-Host "All 10 conditions completed."
Write-Host "Logs saved in: $logDir"
