defmodule MaccleWeb.DecodeMessageLive do
  alias Maccle.MessageEncoder.Client

  use MaccleWeb, :live_view

  def mount(_params, _session, socket) do
    Client.init()

    {:ok, assign(socket, form: to_form(%{}), message_to_decode: "", decoded_message: "")}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col space-y-6">
      <.button
        class="w-1/2 bg-blue hover:bg-lavender disabled:opacity-75 disabled:active:text-white enabled:active:bg-green"
        phx-click="redirect_to_encode_message"
      >
        Encode message
      </.button>
      <div>
        <.simple_form for={@form}>
          <.input
            field={@form[:message_to_decode]}
            phx-change="change"
            type="textarea"
            rows="4"
            placeholder="Enter your encoded message here"
          />
        </.simple_form>
      </div>
      <div class="space-y-2 md:space-y-0">
        <.button
          class="bg-blue hover:bg-lavender disabled:opacity-75 disabled:active:text-white enabled:active:bg-green"
          disabled={@decoded_message == ""}
          phx-click={JS.dispatch("phx:copy", to: "#decoded-message")}
        >
          Copy decoded message
        </.button>
        <.button
          class="bg-red hover:bg-maroon disabled:opacity-75 disabled:active:text-white enabled:active:bg-green"
          disabled={@decoded_message == ""}
          phx-click={clear_message_to_decode("#message_to_decode")}
        >
          Clear typed message
        </.button>
      </div>
      <div class="h-screen">
        <div class={[
          "flex place-content-center min-h-[640px] bg-encoded-message bg-cover bg-center text-mauve sm:text-lg sm:leading-6 border-4",
          "rounded-sm border-pink hover:border-peach shadow-lg shadow-pink hover:shadow-peach",
          "outline outline-2 outline-white",
          @decoded_message !== "" && "transition-opacity ease-in duration-700 opacity-100",
          @decoded_message == "" && "transition-opacity ease-out duration-700 opacity-0"
        ]}>
          <div
            id="decoded-message"
            class={[
              "m-4 p-2 w-4/5 h-fit font-medium",
              String.length(@decoded_message) >= 80 &&
                "bg-[#ffecce] border-[#ffecce] border-4 rounded-sm"
            ]}
          >
            <%= @decoded_message %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("change", %{"value" => message_to_decode}, socket) do
    handle_event("change", %{"message_to_decode" => message_to_decode}, socket)
  end

  def handle_event("change", %{"message_to_decode" => message_to_decode}, socket) do
    decoded_message =
      Client.decode(message_to_decode)
      |> Client.format_decoded_message()

    socket
    |> update(:message_to_decode, fn _ -> message_to_decode end)
    |> update(:decoded_message, fn _ -> decoded_message end)
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("change", _, socket), do: {:noreply, socket}

  def handle_event("redirect_to_encode_message", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  def clear_message_to_decode(js \\ %JS{}, selector) do
    js
    |> JS.push("change")
    |> JS.dispatch("phx:clear", to: selector)
  end
end
