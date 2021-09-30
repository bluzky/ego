defmodule Mix.Tasks.Ego.Server do
  def run(_) do
    Application.ensure_all_started(:cachex)
    Application.ensure_all_started(:ego)
    Ego.CLI.main(["server"])

    receive do
      msg -> IO.puts(msg)
    end
  end
end
