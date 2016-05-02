ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Imines.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Imines.Repo --quiet)


