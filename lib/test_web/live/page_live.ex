defmodule TestWeb.PageLive do
  use TestWeb, :live_view
  require Logger
  use Phoenix.HTML

  @impl true
  def mount(_, _, socket) do
    {:ok, assign(socket, value_from_child: nil, value_from_parent: nil, changeset: %{})}
  end

  @impl true
  def handle_params(params, _, socket) do
    Logger.info("handle params - start")

    socket =
      assign(socket,
        value_from_child: params["value-from-child"],
        value_from_parent: params["value-from-parent"]
      )

    {:ok, _} = Test.Repo.query("select pg_sleep(2);")
    Logger.info("handle params - end")
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @value_from_parent do %>
        <div id="selected-in-parent">
          Parent clicked
        </div>
      <% end %>
      <%= if @value_from_child do %>
        <div id="selected-in-child">
          Child clicked
        </div>
      <% end %>
      <form id="parent-form" phx-submit="save">
        <button id="parent-button">
          Save (parent)
        </button>
      </form>

      <.live_component id="child-component" module={Test.ChildComponent} changeset={@changeset} />
    </div>
    """
  end

  @impl true
  def handle_event("save", _, socket) do
    Logger.info("parent handle_event - save - start")

    response =
      {:noreply,
       socket
       |> put_flash(:info, "Parent clicked")
       |> push_patch(to: ~p|/?value-from-parent=parent_clicked|)}

    Logger.info("parent handle_event - save - end")
    response
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply,
     socket
     |> assign(changeset: params)}
  end
end

defmodule Test.ChildComponent do
  use TestWeb, :live_component
  use Phoenix.HTML
  require Logger

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:changeset, assigns.changeset)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form id="child-form" phx-submit="save" phx-target={@myself}>
        <button id="child-button">
          Save (child)
        </button>
      </form>
    </div>
    """
  end

  @impl true
  def handle_event("save", _, socket) do
    Logger.info("child handle_event - save - start")

    response =
      {:noreply,
       socket
       |> put_flash(:info, "Child clicked")
       |> push_patch(to: ~p|/?value-from-child=child_clicked|)}

    Logger.info("child handle_event - save - end")
    response
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply,
     socket
     |> assign(changeset: params)}
  end
end

defmodule Test.User do
  use Ecto.Schema

  schema "users" do
    field :identifies_as, Ecto.Enum,
      values: [
        female: 1,
        male: 2,
        non_binary: 3,
        not_entered: 4,
        other: 5
      ]
  end
end
