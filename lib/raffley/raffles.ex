defmodule Raffley.Raffles do
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def list_raffles do
    Repo.all(Raffle)
  end

  def filter_raffles do
    Raffle
    |> where(status: :closed)
    |> where([r], ilike(r.prize, "%gourmet%"))
    |> order_by(:prize)
    |> Repo.all()
  end

  def featured_raffles(raffle) do
    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
