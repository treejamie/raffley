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
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> sort_by(filter["sort_by"])
    |> IO.inspect()
    |> Repo.all()
  end

  defp sort_by(query, "prize"), do: order_by(query, :prize )
  defp sort_by(query, "ticket_price_desc"), do: order_by(query, desc: :ticket_price )
  defp sort_by(query, "ticket_price_asc"), do: order_by(query, asc: :ticket_price )
  defp sort_by(query, _), do: order_by(query, :id)

  defp search_by(query, q) when q in ["", nil], do: query
  defp search_by(query, q) do
    where(query, [r], ilike(r.prize, ^"%#{q}%"))
  end

  defp with_status(query, status) when status in ~w(open closed upcoming) do
    where(query, status: ^status)
  end
  defp with_status(query, _status), do: query

  def featured_raffles(raffle) do
    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
