defmodule Raffley.Raffles do

  alias Raffley.Raffles.Raffle
  alias Raffley.Repo


  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end


  @spec list_raffles() :: [
          %Raffle{
            description: <<_::64, _::_*8>>,
            id: 1 | 2 | 3,
            image_path: <<_::64, _::_*8>>,
            prize: <<_::144>>,
            status: :closed | :open | :upcoming,
            ticket_price: 1 | 2 | 3
          },
          ...
        ]
  def list_raffles do
    Repo.all(Raffle)
  end

  def featured_raffles(raffle) do
    list_raffles() |> List.delete(raffle)
  end

end
