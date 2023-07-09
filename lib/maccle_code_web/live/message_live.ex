defmodule MaccleCodeWeb.MessageLive do
  use MaccleCodeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}), message_to_encode: "", encoded_message: "")}
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@form}>
      <.input field={@form[:message_to_encode]} type="textarea" label="Message" phx-change="change" />
    </.simple_form>
    """
  end

  def handle_event("change", %{"message_to_encode" => message_to_encode}, socket) do
    {:noreply, update(socket, :message_to_encode, fn _ -> message_to_encode end)}
  end

  def handle_event("change", _, socket), do: {:noreply, socket}
end
