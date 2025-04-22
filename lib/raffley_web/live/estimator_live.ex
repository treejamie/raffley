defmodule RaffleyWeb.EstimatorLive do
  use RaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, tickets: 0, price: 3 )

    IO.inspect(self(), label: "MOUNT")

    {:ok, socket}
  end

  def render(assigns) do

    IO.inspect(self(), label: "RENDER")
    ~H"""
    <div class="estimator">
      <h1>Raffle Estimator</h1>
      <section>
        <button phx-click="add" phx-value-quantity="5">
        +
        </button>
        <div>
          <%= @tickets %>
        </div>
        @  $<%= @price %>
        <div>
        = $<%= @tickets * @price %>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do

    IO.inspect(self(), label: "ADD")

    socket = update(socket, :tickets, &(&1 + String.to_integer(quantity)))

    {:noreply, socket}
  end
end
