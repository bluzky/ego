defmodule Mix.Tasks.Ego.Build do
  def run(_) do
    Application.ensure_all_started(:cachex)
    Application.ensure_all_started(:ego)

    Ego.build()
  end
end
