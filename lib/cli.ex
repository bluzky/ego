defmodule Ego.CLI do
  def main(args) do
    args |> parse_args |> process_args
  end

  def parse_args(args) do
    {params, command, _} = OptionParser.parse(args, switches: [help: :boolean])
    {command, params}
  end

  def process_args({_, help: true}) do
    print_help_message()
  end

  def process_args({["build" | _], _}) do
    Ego.build()
  end

  def process_args({["server" | _], _}) do
    Ego.server()
  end

  def process_args(_) do
    IO.puts("Welcome to the Toy Robot simulator!")
    print_help_message()
  end

  @commands %{
    "build" => "generate static site"
  }

  defp print_help_message do
    IO.puts("\nEgo supports following commands:\n")

    @commands
    |> Enum.map(fn {command, description} -> IO.puts("  #{command} - #{description}") end)
  end
end
