defmodule Pedemo.RemindersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pedemo.Reminders` context.
  """

  @doc """
  Generate a reminder.
  """
  def reminder_fixture(attrs \\ %{}) do
    {:ok, reminder} =
      attrs
      |> Enum.into(%{
        channel: %{},
        date: ~U[2022-09-05 09:31:00Z],
        text: "some text"
      })
      |> Pedemo.Reminders.create_reminder()

    reminder
  end
end
