defmodule RaffleyWeb.RaffleyLive.Show do
  use RaffleyWeb, :live_view
  alias Raffley.Raffles
  alias Raffley.Tickets
  alias Raffley.Tickets.Ticket

  import RaffleyWeb.CustomComponents

  on_mount({RaffleyWeb.UserAuth, :mount_current_user})

  def mount(_params, _session, socket) do
    changeset = Tickets.change_ticket(%Ticket{})

    socket = assign(socket, :form, to_form(changeset))

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    raffle = Raffles.get_raffle!(id)
    tickets = Raffles.list_tickets(raffle)

    socket =
      socket
      |> assign(:raffle, raffle)
      |> stream(:tickets, tickets)
      |> assign(:page_title, raffle.prize)
      |> assign(:ticket_count, Enum.count(tickets))
      |> assign(:ticket_sum, Enum.sum_by(tickets, fn t-> t.price end))
      |> assign_async(:featured_raffles, fn ->
        {:ok, %{featured_raffles: Raffles.featured_raffles(raffle)}}
      end)

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
            <div>
            <h2>{@raffle.prize}</h2>
            <h3>{@raffle.charity.name}</h3>

            </div>
            <div class="price">
              ${@raffle.ticket_price} / ticket
            </div>
          </header>
          <div class="totals">
          {@ticket_count} Tickets sold &bull; ${@ticket_sum} raised
          </div>
          <div class="description">
            {@raffle.description}
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left">
          <div :if={@raffle.status == :open}>

            <%= if @current_user do %>
            <.form for={@form} id="ticket-form" phx-change="validate"
              phx-submit="save">
              <.input field={@form[:comment]} placeholder="Comment.." autofocus />
              <.button>
                Get a ticket
              </.button>
            </.form>
            <% else %>
              <.link href={~p"/users/log_in"} class="button">
                Log in to get a ticket.
              </.link>
            <% end %>
          </div>
          <div id="tickets" phx-update="stream">
            <.ticket :for={{dom_id, ticket} <- @streams.tickets}
            ticket={ticket}
            id={dom_id}
            />
          </div>
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

      <.async_result :let={result} assign={@raffles}>

        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>

        <:failed :let={{:error, reason}}>
          <div class="failed">
            {reason}
          </div>
        </:failed>

        <ul class="raffles">
          <li :for={raffle <- result}>
          <.link navigate={~p"/raffles/#{raffle}"}>
            <img src={raffle.image_path} alt="{raffle.description}">
            {raffle.prize}
            </.link>
          </li>
        </ul>

      </.async_result>


    </section>
    """
  end

  attr :id, :string,  required: true
  attr :ticket, Ticket, required: true
  def ticket(assigns) do
    ~H"""
    <div class="ticket" id={@id}>
      <span class="timeline"></span>
      <section>
        <div class="price-paid">
          ${@ticket.price}
        </div>
        <div>
          <span class="username">
            {@ticket.user.username}
          </span>
          bought a ticket

          <blockquote>
            {@ticket.comment}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    changeset = Tickets.change_ticket(%Ticket{}, ticket_params)

    socket = assign(socket, :form, to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do

    %{raffle: raffle, current_user: user} = socket.assigns

    case Tickets.create_ticket(raffle, user, ticket_params) do
      {:ok, ticket} ->
        changeset = Tickets.change_ticket(%Ticket{})
        socket =
          socket
          |> assign(:form, to_form(changeset))
          |> stream_insert(:tickets, ticket)
          |> update(:ticket_count, &(&1 + 1))
          |> update(:ticket_sum, &(&1 + ticket.price))
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
      end
  end


end
