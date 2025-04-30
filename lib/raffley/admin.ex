defmodule Raffley.Admin do
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query

  def list_raffles() do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_raffle(attrs \\ %{}) do
    #
    #
    #
    #  WARNING - THIS LESSON WAS TO PROVE THE POINT ABOUT ECTO CHANGESETS
    #            BEING A THING TO USE. THIS CODE DOES NOT USE CHANGESETS.
    #
    # . DRAGONS BELOW. DRAGONS!
    %Raffle{
      prize: attrs["prize"],
      description: attrs["description"],
      ticket_price: attrs["ticket_price"] |> String.to_integer(),
      status: attrs["status"] |> String.to_existing_atom(),
      image_path: "images/jersey.jpg"
    }
    |> Repo.insert!()
  end
end
