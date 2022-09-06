defmodule Pedemo.Reminders.Reminder do
  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  schema "reminders" do
    field :date, :utc_datetime
    field :text, :string

    polymorphic_embeds_one(:channel,
      types: [
        sms: Pedemo.Channel.SMS,
        email: Pedemo.Channel.Email
      ],
      on_type_not_found: :raise,
      on_replace: :update
    )

    timestamps()
  end

  @doc false
  def changeset(reminder, attrs) do
    reminder
    |> cast(attrs, [:date, :text])
    |> cast_polymorphic_embed(:channel, required: true)
    |> validate_required([:date, :text])
  end
end
