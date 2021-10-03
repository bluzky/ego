defmodule Mix.Tasks.Ego.Server do
  def run(_) do
    Ego.server()

    receive do
      msg -> IO.puts(msg)
    end
  end
end
