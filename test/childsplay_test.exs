defmodule ChildsPlayTest do
  use ExUnit.Case
  doctest ChildsPlay

  defmodule Agent1 do
    use Agent

    def start_link(_) do
      Agent.start_link(fn -> %{} end)
    end
  end

  defmodule Agent2 do
    use Agent

    def start_link(_) do
      Agent.start_link(fn -> %{} end)
    end
  end

  defmodule Agent3 do
    use Agent

    def start_link(_) do
      Agent.start_link(fn -> %{} end)
    end
  end

  describe "build/1" do
    test "can handle sublists" do
      assert {:ok, pid} =
               [
                 [],
                 [
                   [
                     {Agent1, fn -> %{} end}
                   ]
                 ],
                 Agent2
               ]
               |> ChildsPlay.build()
               |> Supervisor.start_link(strategy: :one_for_one)

      assert %{workers: 2} = Supervisor.count_children(pid)
    end
  end

  describe "given/2" do
    test "being passed booleans" do
      {:ok, pid} =
        [
          ChildsPlay.given(true, Agent1),
          ChildsPlay.given(false, Agent2),
          # TODO: Should I do this or does this cause issues with other API'S
          ChildsPlay.given(nil, Agent3)
        ]
        |> ChildsPlay.build()
        |> Supervisor.start_link(strategy: :rest_for_one)

      assert %{workers: 1} = Supervisor.count_children(pid)
    end

    test "passing a predicate function" do
      {:ok, pid} =
        [
          ChildsPlay.given(fn -> true end, Agent1),
          ChildsPlay.given(fn -> false end, Agent2),
          ChildsPlay.given(fn -> nil end, Agent3)
        ]
        |> ChildsPlay.build()
        |> Supervisor.start_link(strategy: :rest_for_one)

      assert %{workers: 1} = Supervisor.count_children(pid)
    end

    test "can be passed a list of children for condition" do
      {:ok, pid} =
        [
          ChildsPlay.given(true, [Agent1, Agent2, Agent3])
        ]
        |> ChildsPlay.build()
        |> Supervisor.start_link(strategy: :rest_for_one)

      assert %{workers: 3} = Supervisor.count_children(pid)
    end

    # NOTE: This test kinda sits between `given/2` and `build/1`
    test "recursion works" do
      {:ok, pid} =
        [
          ChildsPlay.given(
            true,
            [
              Agent1,
              Agent2,
              ChildsPlay.given(
                true,
                Agent3
              )
            ]
          )
        ]
        |> ChildsPlay.build()
        |> Supervisor.start_link(strategy: :rest_for_one)

      assert %{workers: 3} = Supervisor.count_children(pid)
    end
  end
end
