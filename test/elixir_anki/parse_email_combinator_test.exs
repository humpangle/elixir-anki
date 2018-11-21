defmodule ElixirAnki.ParseEmailCombinatorTest do
  use ExUnit.Case, async: true
  alias ElixirAnki.ParseEmailCombinator, as: PCE

  # @tag :skip
  test "starting with a dot fails" do
    assert {
             :error,
             %PCE{
               result: _result,
               column: 1,
               label: "must_not_start_with_dot",
               unused: "me",
               consumed: ""
             }
           } = PCE.parse(".me")
  end

  # @tag :skip
  test "with consecutive dots fails" do
    assert {:error,
            %PCE{
              result: ["a"],
              column: [5, 6],
              label: label,
              unused: "..-.12-@",
              consumed: "bc_"
            }} = PCE.parse("abc_..-.12-@")

    assert label =~ "Consecutive"
  end

  # @tag :skip
  test "no @ fails" do
    assert {:error,
            %PCE{
              result: ["a"],
              column: 10,
              label: "before_first_at",
              unused: "",
              consumed: "bc_-.12-"
            }} = PCE.parse("abc_-.12-")
  end

  # @tag :skip
  test "with @ but not followed by another char fails" do
    assert {:error,
            %PCE{
              result: ["@", "bc_-.12-", "a"],
              column: 11,
              label: label,
              unused: "",
              consumed: ""
            }} = PCE.parse("abc_-.12-@")

    assert label =~ "After @"
  end

  # @tag :skip
  test "with @ followed by @/./_ fails" do
    char = Enum.random(["@", ".", "_"])

    assert {:error,
            %PCE{
              result: ["@", "bc_-.12-", "a"],
              column: 11,
              label: label,
              unused: ^char,
              consumed: ""
            }} = PCE.parse("abc_-.12-@" <> char)

    assert label =~ "After @"
  end

  # @tag :skip
  test "with @ preceded by ./_ fails" do
    char = Enum.random([".", "_"])
    unused = char <> "@me.com"

    assert {:error,
            %PCE{
              result: ["a"],
              column: 10,
              label: label,
              unused: ^unused,
              consumed: "bc_-.12-"
            }} = PCE.parse("abc_-.12-" <> char <> "@me.com")

    assert label =~ "@ can not be preceded by"
  end

  # @tag :skip
  test "with @ followed by one or more chars and . followed by non ascii chars fails" do
    assert {:error,
            %PCE{
              result: ["5", "@", "bc_-.12-", "a"],
              column: 13,
              label: _label,
              unused: "5",
              consumed: ""
            }} = PCE.parse("abc_-.12-@5.5")
  end

  # @tag :skip
  test "well formed email passes" do
    assert {:ok,
            %PCE{
              result: ["com", ".", "5", "@", "bc_-.12-", "a"],
              column: 15,
              label: _label,
              unused: "",
              consumed: ""
            }} = PCE.parse("abc_-.12-@5.com")
  end
end
