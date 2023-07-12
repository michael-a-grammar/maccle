defmodule MaccleWeb.MessageLive do
  alias Maccle.MessageEncoder.Client

  use MaccleWeb, :live_view

  def mount(_params, _session, socket) do
    # TODO: I don't like this - surely this could be inadvertantly called multiple times?
    Client.init()

    {:ok, assign(socket, form: to_form(%{}), message_to_encode: "", encoded_message: "")}
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@form}>
      <.input field={@form[:message_to_encode]} type="textarea" label="Message" phx-change="change" />
    </.simple_form>
    <p>
      <%= @encoded_message %>
    </p>
    """
  end

  def handle_event("change", %{"message_to_encode" => message_to_encode}, socket) do
    encoded_message = Client.encode(message_to_encode) |> Client.format_encoded_message()

    socket = update(socket, :message_to_encode, fn _ -> message_to_encode end)
    socket = update(socket, :encoded_message, fn _ -> encoded_message end)

    {:noreply, socket}
  end

  def handle_event("change", _, socket), do: {:noreply, socket}
end
