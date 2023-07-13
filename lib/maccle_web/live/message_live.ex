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
      <.input field={@form[:message_to_encode]} phx-change="change" type="textarea" rows="4" />
    </.simple_form>
    <div class="text-pink h-screen">
      <%= @encoded_message %>
    </div>
    """
  end

  def handle_event("change", %{"message_to_encode" => message_to_encode}, socket) do
    encoded_message =
      Client.encode(message_to_encode)
      |> Client.format_encoded_message()

    socket
    |> update(:message_to_encode, fn _ -> message_to_encode end)
    |> update(:encoded_message, fn _ -> encoded_message end)
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("change", _, socket), do: {:noreply, socket}
end
