defmodule Mix.Tasks.Repl do
  use Mix.Task

  @shortdoc "Starts the Lunary REPL"

  def run(_args) do
    Lunary.Main.start_repl()
  end
end
