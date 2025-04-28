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

  def filter_raffles(filter) do
    Raffle
    |> where(status: ^filter["status"])
    |> where([r], ilike(r.prize, ^"%#{filter["q"]}%"))
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
