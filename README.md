# Polymorphic embed infer issue

Minimum reproduction repository for the _"could not infer polymorphic embed from data"_ issue with [polymorphic_embed](https://github.com/mathieuprog/polymorphic_embed) library.

## Issue

Following the `polymorphic_embed`'s [usage](https://github.com/mathieuprog/polymorphic_embed#usage) example, making any requests (see [reproduction steps](#reproduction-steps)) results in the following error:

- could not infer polymorphic embed from data %{`<embedded-data>`}

## Initial setup

_Note: Using Docker Compose for easier setup and reproduction; should be also replicable without its utilization and shouldn't affect the functionality of the library._

The repository has been set up by following steps below:

1. Initialize the Phoenix project:

   ```
   mix phx.new pedemo
   ```

2. Create the necessary Docker/Docker Compose configuration:

   - Create `Dockerfile`
   - Create `docker-compose.yml`
   - Update `.gitignore`
   - Update `config/dev.exs`

3. Add the `polymorphic_embed` dependency into `mix.esx`.
4. Start up the application stack:
   ```
   docker-compose up --build -d
   ```
5. Find the Phoenix container and attach to its CLI:
   ```
   docker ps
   docker exec -it <container-id> /bin/sh
   ```
6. Generate the example Reminder resource and run the migration:
   ```
   mix phx.gen.json Reminders Reminder reminders date:utc_datetime text:string channel:map
   mix ecto.migrate
   exit
   ```
7. Add the resource into the router under the API scope in `lib/pedemo_web/router.ex`:
   ```
   resources "/reminders", ReminderController, except: [:new, :edit]
   ```
8. Update the Reminders resource using the `polymorphic_embed` example in `lib/pedemo/reminders/reminder.ex`:

   ```elixir
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
   ```

9. Add example modules for the embedded schemas in `lib/pedemo/channels/channel.ex`:

   ```elixir
   defmodule Pedemo.Channel.Email do
     use Ecto.Schema
     import Ecto.Changeset

     @primary_key false

     embedded_schema do
       field :address, :string
       field :confirmed, :boolean
     end

     def changeset(email, params) do
       email
       |> cast(params, ~w(address confirmed)a)
       |> validate_required(:address)
       |> validate_length(:address, min: 4)
     end
   end

   defmodule Pedemo.Channel.SMS do
     use Ecto.Schema

     @primary_key false

     embedded_schema do
       field :number, :string
     end
   end
   ```

## Reproduction steps

1. Start up the application stack:
   ```
   docker-compose up --build -d
   ```
2. If not done previously, run the Reminders resource migration - follow steps 5 and 6 from the [Initial setup](#initial-setup) section.
3. Make a POST request to the example endpoint at `localhost:4000/api/reminders`, using any tool of your choice, with the one of following JSON payloads:
   ```
   {
     "reminder": {
       "date": "2022-09-06 11:04:19.240294+00",
       "text": "test text",
       "channel": {
         "number": "0123456789"
       }
     }
   }
   ```
   ```
   {
     "reminder": {
       "date": "2022-09-06 11:04:19.240294+00",
       "text": "test",
       "channel": {
         "address": "test address",
         "confirmed": true
       }
     }
   }
   ```
