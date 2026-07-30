// FP Enhancement: 2026-05-24 — FixAtdlOptions POCO replaces System.Configuration glue.

namespace FixPortal.FixAtdl.Configuration;

/// <summary>Runtime options for the FixPortal.FixAtdl library. Placeholder — no knobs yet; properties added as concrete needs emerge.</summary>
public sealed class FixAtdlOptions
{
    /// <summary>The default options instance.</summary>
    public static FixAtdlOptions Default { get; } = new();
}
