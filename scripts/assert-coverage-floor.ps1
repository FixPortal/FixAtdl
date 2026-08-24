<#
.SYNOPSIS
    Fails when library line coverage drops below a floor, and writes a short summary.

.DESCRIPTION
    Reads a Cobertura report and gates on the PRODUCTION assembly's line rate.

    Measuring the report's top-level `line-rate` would be wrong: it averages the test
    assembly in, and a test assembly covers itself almost completely. Measured on this
    repository at the time this script was written, the whole-report rate was 84.3%
    while the library alone was 73.3% -- an 11-point flattery that would let real
    library coverage rot a long way before any floor noticed.

    A missing package, a report with no packages, or an unparsable file all FAIL. The
    whole point of a floor is to distinguish "coverage dropped" from "coverage was
    never measured", and a checker that treats an absent number as a pass cannot.

.PARAMETER ReportPath
    Path to the Cobertura XML report.

.PARAMETER Package
    The package (assembly) name to gate on, as it appears in the report.

.PARAMETER MinimumLineRate
    The floor, as a percentage.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $ReportPath,
    [Parameter(Mandatory)][string] $Package,
    [Parameter(Mandatory)][double] $MinimumLineRate
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ReportPath -PathType Leaf)) {
    Write-Error "Coverage report not found at '$ReportPath'. The collect step did not produce one, so coverage was not measured -- this is a failure, not a pass."
    exit 1
}

try {
    $report = [xml](Get-Content -LiteralPath $ReportPath -Raw)
}
catch {
    Write-Error "Coverage report at '$ReportPath' is not parseable XML: $($_.Exception.Message)"
    exit 1
}

# @() is load-bearing: a single <package> element does not come back as an array, so
# `.Count` on the bare value would be $null and every count test below would misread.
$packages = @($report.coverage.packages.package)
if ($packages.Count -eq 0) {
    Write-Error "Coverage report at '$ReportPath' contains no packages. Nothing was measured."
    exit 1
}

$target = $packages | Where-Object { $_.name -eq $Package }
if (-not $target) {
    $names = ($packages | ForEach-Object { $_.name }) -join ', '
    Write-Error "Coverage report contains no package named '$Package'. Present: $names. A renamed assembly silently ends coverage enforcement, so this fails rather than passing over it."
    exit 1
}

# -eq on an array FILTERS rather than compares, so a duplicated package name would
# leave $target holding two elements and the cast below would throw an unhelpful error.
$target = @($target)
if ($target.Count -gt 1) {
    Write-Error "Coverage report contains $($target.Count) packages named '$Package'; cannot decide which to gate on."
    exit 1
}

$lineRate = [double]$target[0].'line-rate' * 100
$branchRate = [double]$target[0].'branch-rate' * 100

$summary = @(
    "### Coverage floor",
    "",
    "| Assembly | Line | Branch | Floor |",
    "|---|--:|--:|--:|",
    ("| ``{0}`` | {1:N1}% | {2:N1}% | {3:N1}% |" -f $Package, $lineRate, $branchRate, $MinimumLineRate)
)

if ($lineRate -lt $MinimumLineRate) {
    $summary += ""
    $summary += ("**FAILED** - line coverage {0:N1}% is below the {1:N1}% floor." -f $lineRate, $MinimumLineRate)
    $summary
    Write-Error ("Line coverage for '{0}' is {1:N1}%, below the {2:N1}% floor." -f $Package, $lineRate, $MinimumLineRate)
    exit 1
}

$summary
exit 0
