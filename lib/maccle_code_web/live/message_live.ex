defmodule MaccleCodeWeb.MessageLive do
  use MaccleCodeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: %{name: "encode_message"}, message_to_encode: "")}
  end

  def render(assigns) do
    ~H"""
      <.simple_form for={@form} phx-change="change">
        <.input
          name="message-to-encode"
          type="textarea"
          label="Message"
          value="" />
      </.simple_form>
    """
  end

  def handle_event("change", %{"key" => key, "value" => value}, socket) do
    {:noreply, update(socket, :message_to_encode, fn message_to_encode ->

      IO.inspect(message_to_encode, label: "Message to encode")
      IO.inspect({key, value}, label: "Keydown")

      result = value <> key

      IO.inspect(result, label: "Result")
    end)}
  end
  
  def handle_event("keydown", _, socket) do
    {:noreply, socket}
  end
end
