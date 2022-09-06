defmodule Pedemo.Repo.Migrations.CreateReminders do
  use Ecto.Migration

  def change do
    create table(:reminders) do
      add :date, :utc_datetime
      add :text, :string
      add :channel, :map

      timestamps()
    end
  end
end
