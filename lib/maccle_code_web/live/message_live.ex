defmodule MaccleCodeWeb.MessageLive do
  alias MaccleCode.Messaging.Encoder

  use MaccleCodeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, pid} = Encoder.init(eager: true)

    {:ok,
     assign(socket, form: to_form(%{}), message_to_encode: "", encoded_message: "", encoder: pid)}
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
    pid = socket.assigns.encoder

    encoded_message = Encoder.encode(pid, message_to_encode) |> Encoder.format_encoded_message()

    socket = update(socket, :message_to_encode, fn _ -> message_to_encode end)
    socket = update(socket, :encoded_message, fn _ -> encoded_message end)

    {:noreply, socket}
  end

  def handle_event("change", _, socket), do: {:noreply, socket}
end
