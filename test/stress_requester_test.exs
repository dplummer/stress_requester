defmodule StressRequesterTest do
  use ExUnit.Case
  doctest StressRequester

  test "greets the world" do
    assert StressRequester.hello() == :world
  end
end
