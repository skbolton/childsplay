defmodule ChildsplayTest do
  use ExUnit.Case
  doctest Childsplay

  test "greets the world" do
    assert Childsplay.hello() == :world
  end
end
