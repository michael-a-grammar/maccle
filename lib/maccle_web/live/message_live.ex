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
    <div class="flex flex-col space-y-10">
      <div>
        <.simple_form for={@form}>
          <.input
            field={@form[:message_to_encode]}
            phx-change="change"
            type="textarea"
            rows="4"
            placeholder="Enter your message here"
          />
        </.simple_form>
      </div>
      <div class="h-screen">
        <div class={[
          "bg-gradient-to-b from-base to-crust text-pink sm:text-lg sm:leading-6 border-4",
          "rounded-sm border-pink hover:border-peach shadow-pink hover:shadow-peach",
          "outline outline-2 outline-white rounded-sm",
          @encoded_message == "" && "invisible"
        ]}>
          <p class="p-8">
            <%= @encoded_message %>
          </p>
        </div>
      </div>
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
