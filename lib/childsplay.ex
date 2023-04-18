defmodule ChildSplay do
  @moduledoc """
  Make building a list of children a `Supervisor` manages a problem of the
  past.

  We've all been there before. Your new project starts out with a clean
  Supervision tree of only a few children. Make sure this is running, make sure
  that is running. Life is good. But eventually rules start to pop up that make
  it so the list of children you start gets more and more complex.

  Some of the greatest hits of the projects I've been involved in.

  > "Don't start the email server in Dev. We use a mocked version there."

  > "If its a cronjob node we don't want to start up consumers."

  This leads to all sorts of variations on how to filter and tranform the list
  of children for our Supervisors. Most lead to bloated descriptions and
  confusing logic.

  ```elixir
  defmodule MyApp.Application do
    use Application
    # importing not required - just cleaner
    import ChildSplay

    def start(_type, _args) do
      [
        # Add regular children you know and love (possibly more than the others)
        MyApp.Repo,
        given(
          Application.get_env(:my_app, :cronjob_node?, false),
          ConsumerSupervisor
        ),
        given(
          System.get_env("ENV") == "PROD",
          [
            MyApp.MailServer,
            MyApp.MetricsServer
          ]
        ),
      ]
      |> build()
      |> Supervised.start_link(strategy: :one_for_one)
    end
  end
  ```

  ## Building child lists

  The core function at work is `given/2` which takes a boolean (or a predicate
  function) and a single child or a list of children to start. When the value is
  true the children will be rendered.

  The core data structure at play here is just a list, the trick that
  `ChildSplay` adds is that now nested lists get flattened. What this means is
  that we could go as far as doing this if we wanted to.

  ```elixir
  defmodule MyApp.Application do
    use Application
    import ChildSplay

    def start(_type, _args) do
      [
        given(
          System.get_env("ENV") == "PROD",
          [
            MyApp.MailServer,
            given(
              Application.get_env(:my_app, :cronjob_node?, false),
              [
                MyApp.Consumer1,
                MyApp.Consumer2
              ]
            )
          ]
        ),
      ]
      |> build()
      |> Supervised.start_link(strategy: :one_for_one)
    end
  end
  ```

  With great power comes great responsibility. Always favor whatever is more
  declarative and childs play for all!
  """

  @type predicate :: (() -> boolean())

  @type children :: [
          []
          | Supervisor.child_spec()
          | {module(), term()}
          | module()
          | (old_erlang_child_spec :: :supervisor.child_spec())
        ]

  @spec given(nil | boolean() | predicate(), children()) :: children()
  @doc """
  If `condition` is true, or predicate returning true allow children.

  ```elixir
  [
    ChildSplay.given(true, Agent),
    ChildSplay.given(false, Agent),
    ChildSplay.given(true, [Worker1, Worker2]),
    ChildSplay.given(fn -> false end, [Worker3, Worker4])
  ]
  |> ChildSplay.build()
  |> Supervisor.start_link(strategy: :one_for_one)
  ```
  """
  def given(condition, children) when is_function(condition) do
    if condition.() do
      children
    else
      []
    end
  end

  def given(true, children), do: children
  def given(false, _children), do: []
  def given(nil, _children), do: []

  @spec build(children()) :: [any()]
  def build(children) do
    List.flatten(children)
  end
end
