defmodule Thrash.EnumeratedTest do
  use ExUnit.Case

  # note TacoType comes from test/simple_struct.ex, which is generated
  # from the thrift hrl

  test "Creates a lookup from atom to id" do
    assert TacoType.id(:barbacoa) == 123
  end

  test "Creates a lookup from id to atom" do
    assert TacoType.atom(125) == :steak
  end

  # using a different module name
  defmodule TacoVariety do
    use Thrash.Enumerated, TacoType
  end

  test "manual module name works" do
    assert TacoVariety.id(:barbacoa) == 123
  end
end
