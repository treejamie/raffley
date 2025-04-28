defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view
  alias Raffley.Raffles
  import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do

    socket =
      socket
      |> stream(:raffles, Raffles.list_raffles())
      |> assign(:form, to_form(%{}))

    {:ok, socket}
  end


  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <.banner :if={false}>
        <.icon name="hero-sparkles-solid" />
        Mystery Raffle Coming Soon

        <:details :let={vibe}>
          To Be Revealed Tomorrow
          <%= vibe %>
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner>

      <.filter_form form={@form} />

      <div class="raffles" id="raffles" phx-update="stream">
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id}/>
      </div>
    </div>
    """
  end

  def filter_form(assigns) do
    ~H"""
    <.form for={@form}>
        <.input field={@form[:q]} placeholder="Search..." autocomplete="off" />

        <.input
          type="select"
          field={@form[:status]}
          prompt="Status"
          options={[:upcoming, :open, :closed]}
          />

          <.input
          type="select"
          field={@form[:sort_by]}
          prompt="Sort By"
          options={[:prize, :ticket_price]}
          />

      </.form>
    """
  end


  attr :raffle, Raffley.Raffles.Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <img src={@raffle.image_path}/>
        <h2> <%= @raffle.prize %></h2>
        <div class="details">
          <div class="price">
            $<%= @raffle.ticket_price %>
          </div>
          <.badge status={@raffle.status} />
        </div>
      </div>
    </.link>
  """
  end
end
