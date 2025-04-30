defmodule RaffleyWeb.AdminRaffleLive.Form do
  use RaffleyWeb, :live_view
  alias Raffley.Admin
  alias Raffley.Raffles.Raffle

  def mount(_params, _session, socket) do

    changeset = Raffle.changeset(%Raffle{}, %{})

    socket =
      socket
      |> assign(:page_title, "New Raffle")
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end


  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    case Admin.create_raffle(raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle created sucessfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form" phx-submit="save">

        <.input field={@form[:prize]} label="Prize"/>

        <.input field={@form[:description]} type="textarea" label="Description" />

        <.input field={@form[:ticket_price]} type="number" label="Ticket Price" />

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a status"
          options={[:upcoming, :open, :closed]}
        />

        <.input field={@form[:image_path]} label="Image Path"/>

        <:actions>
          <.button phx-disable-with="Saving..."> Save Raffle </.button>
        </:actions>

      <.back navigate={~p"/admin/raffles"}>
       Back
      </.back>

    </.simple_form>
    """
  end
end
