defmodule Raffley.Raffles do
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query

  def subscribe(raffle_id) do
    Phoenix.PubSub.subscribe(Raffley.PubSub, "raffley:#{raffle_id}")
  end

  def broadcast(raffle_id, message) do
    Phoenix.PubSub.broadcast(Raffley.PubSub, "raffley:#{raffle_id}", message)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
    |> Repo.preload([:charity, :winning_ticket])
  end

  def list_tickets(raffle) do
      raffle
      |> Ecto.assoc(:tickets)
      |> preload(:user)
      |> order_by(desc: :inserted_at)
      |> Repo.all()
  end

  def list_raffles do
    Repo.all(Raffle)
  end

  def filter_raffles(filter) do
    Raffle
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> with_charity(filter["charity"])
    |> sort_by(filter["sort_by"])
    |> preload(:charity)
    |> Repo.all()
  end

  defp with_charity(query, slug) when slug in ["", nil], do: query

  defp with_charity(query, slug) do
    # from r in query,
    # join: c in Charity,
    # on: r.charity_id == c.id,
    # where: c.slug == ^slug
    # above and below are pragmatically the same

    from(r in query,
      join: c in assoc(r, :charity),
      where: c.slug == ^slug
    )
  end

  defp sort_by(query, "prize"), do: order_by(query, :prize)
  defp sort_by(query, "ticket_price_desc"), do: order_by(query, desc: :ticket_price)
  defp sort_by(query, "ticket_price_asc"), do: order_by(query, asc: :ticket_price)

  defp sort_by(query, "charity") do
    from(r in query,
      join: c in assoc(r, :charity),
      order_by: c.name
    )
  end

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
    Process.sleep(500)

    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
