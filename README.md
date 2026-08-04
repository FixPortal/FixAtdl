# FixPortal.FixAtdl

![Release](https://img.shields.io/github/v/release/FixPortal/fixportal-fixatdl)
![CI](https://github.com/FixPortal/fixportal-fixatdl/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/github/license/FixPortal/fixportal-fixatdl)

> Modernised .NET 10 fork of [Atdl4net](https://github.com/atdl4net/atdl4net) — the open-source reference implementation of FIXatdl v1.1. Maintained by [FixPortal](https://www.fixportal.org).

## What this is

A headless library for parsing, validating, and emitting FIX-tag values from
FIXatdl v1.1 strategy XML documents. It targets .NET 10 and is consumed as a
NuGet package (`FixPortal.FixAtdl`).

## What it is *not*

- **Not a FIX engine.** It produces FIX tag values; sending them over the wire
  is the host application's responsibility. Pair with QuickFIX/n or similar.
- **Not a UI library.** The upstream Atdl4net's WPF rendering layer has been
  removed. Consumers wire their own UI (React, Blazor, WPF, anything) on top
  of the parsed model.

## Install

```
dotnet add package FixPortal.FixAtdl
```

## Quick start

```csharp
using FixPortal.FixAtdl.Xml;

var reader = new StrategiesReader();
using var stream = File.OpenRead("twap.xml");
var strategies = reader.Load(stream);

var twap = strategies.Strategies[0];
twap.Parameters["StartTime"].WireValue = "20260101-09:30:00";

foreach (var tag in twap.Parameters.GetOutputValues())
    Console.WriteLine($"{tag.Key}={tag.Value}");
```

## Differences from upstream Atdl4net

- Target framework: `net10.0` only (upstream: `net3.5`, `net4.0`).
- Namespace: `FixPortal.FixAtdl.*` (upstream: `Atdl4net.*`).
- WPF UI controls removed; library is now UI-agnostic.
- `Common.Logging` → `Microsoft.Extensions.Logging.Abstractions`.
- `System.Configuration` glue replaced with `FixAtdlOptions` POCO.
- Nullable reference types enabled throughout.
- New xUnit v3 test suite (AwesomeAssertions + NSubstitute).

## Development

Open `FixPortal.FixAtdl.slnx` in Visual Studio, then build the solution and run
the tests from Test Explorer. The equivalent command-line checks are:

```powershell
dotnet tool restore
```

```powershell
dotnet csharpier format .
```

```powershell
dotnet csharpier check .
```

```powershell
dotnet restore FixPortal.FixAtdl.slnx
```

```powershell
dotnet format FixPortal.FixAtdl.slnx analyzers --verify-no-changes --no-restore
```

```powershell
dotnet build FixPortal.FixAtdl.slnx --configuration Release --no-restore
```

```powershell
dotnet test FixPortal.FixAtdl.slnx --configuration Release --no-build
```

```powershell
dotnet pack FixPortal.FixAtdl.slnx --configuration Release --no-build --output ./_pkgout
```

Files modified from upstream carry a `// FP Enhancement: <date> — <reason>` banner.

## Mutation testing

This repo includes a scoped Stryker pilot for the first part of the library the
current characterization tests can prove well:

- `Model/Collections/ParameterCollection.cs`

Run it locally with:

```powershell
dotnet tool restore
dotnet stryker --config-file stryker-config.json
```

CI uploads both the full Stryker output and compact summaries:

- `mutation-summary.json`
- `mutation-summary.md`

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `dotnet restore` fails with NU1301 ("Unable to find package FixPortal.CodeStyle") or 401 Unauthorized on the `github-fixportal` feed | The build consumes `FixPortal.CodeStyle` from the private FixPortal GitHub Packages feed, and `nuget.config` reads its credentials from the `GITHUB_PACKAGES_TOKEN` environment variable. Without it, the feed rejects the restore anonymously. | For a local restore, set `$env:GITHUB_PACKAGES_TOKEN = "<token>"` (Windows PowerShell) or `export GITHUB_PACKAGES_TOKEN=...` (bash), then restore again. Locally the token must be a **personal access token (classic)** with the `read:packages` scope on the FixPortal org — the GitHub Packages NuGet registry does not accept fine-grained tokens, which fail with the same 401. In GitHub Actions no PAT is needed: the workflows supply `GITHUB_PACKAGES_TOKEN` from `secrets.GITHUB_TOKEN`. |

## Licence

MIT, inherited from upstream. See `LICENSE`. Attribution preserved in `NOTICE`.

## Status

Production-ready 1.0.1 release. The public surface is locked and tracked via `PublicAPI.Shipped.txt` — any future public API change breaks the build.
Issues and PRs welcome at https://github.com/FixPortal/FixAtdl.
