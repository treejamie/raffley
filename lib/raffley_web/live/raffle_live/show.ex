defmodule RaffleyWeb.RaffleyLive.Show do
  use RaffleyWeb, :live_view
  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  # this is calle immediately after mound
  def handle_params(%{"id" => id}, _uri, socket) do

    # this code was in mount, but it was moved into
    # here to demonstrate how this works.
    raffle = Raffles.get_raffle!(id)

    socket =
      socket
      |> assign(:raffle, raffle)
      |> assign(:page_title, raffle.prize)
      |> assign(:featured_raffles, Raffles.featured_raffles(raffle))

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-show">
      <div class="raffle">
        <img src={@raffle.image_path} alt={@raffle.prize}>
        <section>
          <.badge status={@raffle.status} />
          <header>
            <h2>{@raffle.prize}</h2>
            <div class="price">
              ${@raffle.ticket_price} / ticket
            </div>
          </header>
          <div class="description">
            {@raffle.description}
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left">
        </div>
          <div class="right">
          <.featured_raffles raffles={@featured_raffles} />
          </div>
      </div>
    </div>
    """
  end

  def featured_raffles(assigns) do
    ~H"""
    <section>
      <h4>Featured Raffles</h4>
      <ul class="raffles">
        <li :for={raffle <- @raffles}>
         <.link navigate={~p"/raffles/#{raffle}"}>
          <img src={raffle.image_path} alt="{raffle.description}">
          {raffle.prize}
          </.link>
        </li>
      </ul>
    </section>
    """
  end
end
