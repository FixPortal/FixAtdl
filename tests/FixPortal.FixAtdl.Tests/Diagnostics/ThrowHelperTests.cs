using FixPortal.FixAtdl.Diagnostics;

namespace FixPortal.FixAtdl.Tests.Diagnostics;

/// <summary>
/// Tests for <see cref="ThrowHelper"/> exception construction, focused on the
/// ArgumentException-family ParamName threading (G-D).
/// </summary>
public class ThrowHelperTests
{
    [Fact]
    public void NewWithParamName_threads_supplied_param_name()
    {
        // The two-string constructor of ArgumentException-family types takes the parameter name
        // first and the message second; ThrowHelper must surface the real parameter name here,
        // not only the historical synthetic placeholder name.
        ArgumentOutOfRangeException ex = ThrowHelper.NewWithParamName<ArgumentOutOfRangeException>(
            source: null,
            paramName: "tenorOffset",
            message: "out of range"
        );

        ex.ParamName.Should().Be("tenorOffset");
    }

    [Fact]
    public void New_without_param_name_defaults_to_Value_for_argument_exceptions()
    {
        // Back-compat: the plain New<T> path keeps the historical synthetic "Value" name.
        ArgumentOutOfRangeException ex = ThrowHelper.New<ArgumentOutOfRangeException>(
            null,
            "out of range"
        );

        ex.ParamName.Should().Be("Value");
    }

    [Fact]
    public void New_params_overload_preserves_literal_braces_when_no_arguments_are_supplied()
    {
        var ex = ThrowHelper.New<InvalidOperationException>(null, "{NULL}", []);

        ex.Message.Should().Be("{NULL}");
    }

    [Fact]
    public void Rethrow_formats_the_outer_message_once()
    {
        var inner = new InvalidOperationException("inner");

        var ex = ThrowHelper.Rethrow(null, inner, "Could not parse {0}", "{NULL}", "unused");

        ex.Should().BeOfType<InvalidOperationException>();
        ex.Message.Should().Be("Could not parse {NULL}");
        ex.InnerException.Should().BeSameAs(inner);
    }
}
