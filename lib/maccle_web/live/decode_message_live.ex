defmodule MaccleWeb.DecodeMessageLive do
  alias Maccle.MessageEncoder.Client

  use MaccleWeb, :live_view

  def mount(_params, _session, socket) do
    Client.init()

    {:ok, assign(socket, form: to_form(%{}), message_to_encode: "", encoded_message: "")}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col space-y-6">
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
      <div class="space-y-2 md:space-y-0">
        <.button
          class="bg-blue hover:bg-lavender disabled:opacity-75 disabled:active:text-white enabled:active:bg-green"
          disabled={@encoded_message == ""}
          phx-click={JS.dispatch("phx:copy", to: "#encoded-message")}
        >
          Copy encoded message
        </.button>
        <.button
          class="bg-red hover:bg-maroon disabled:opacity-75 disabled:active:text-white enabled:active:bg-green"
          disabled={@encoded_message == ""}
          phx-click={clear_message_to_encode("#message_to_encode")}
        >
          Clear typed message
        </.button>
      </div>
      <div class="h-screen">
        <div class={[
          "flex place-content-center min-h-[640px] bg-encoded-message bg-cover bg-center text-mauve sm:text-lg sm:leading-6 border-4",
          "rounded-sm border-pink hover:border-peach shadow-lg shadow-pink hover:shadow-peach",
          "outline outline-2 outline-white",
          @encoded_message !== "" && "transition-opacity ease-in duration-700 opacity-100",
          @encoded_message == "" && "transition-opacity ease-out duration-700 opacity-0"
        ]}>
          <div
            id="encoded-message"
            class={[
              "m-4 p-2 w-4/5 h-fit font-medium",
              String.length(@encoded_message) >= 80 &&
                "bg-[#ffecce] border-[#ffecce] border-4 rounded-sm"
            ]}
          >
            <%= @encoded_message %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("change", %{"value" => message_to_encode}, socket) do
    handle_event("change", %{"message_to_encode" => message_to_encode}, socket)
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

  def clear_message_to_encode(js \\ %JS{}, selector) do
    js
    |> JS.push("change")
    |> JS.dispatch("phx:clear", to: selector)
  end
end
