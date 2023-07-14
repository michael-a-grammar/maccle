defmodule MaccleWeb.Attributions do
  import MaccleWeb.CoreComponents

  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
      <.button
        class="bg-blue hover:bg-lavender disabled:opacity-75 disabled:active:text-white enabled:active:bg-green"
        phx-click={show_modal("attributions-modal")}
      >
        Attributions
      </.button>
      <.modal id="attributions-modal">
        <ul>
          <li>
            <a
              class="hover:text-sapphire"
              href="https://www.freepik.com/free-vector/set-vector-cute-cartoonish-cats-isolated-white-background_26373379.htm#query=cat%20svg&position=11&from_view=keyword&track=ais"
              target="_blank"
            >
              Cat wallpaper by callmetak
            </a>
          </li>
          <li>
            <a
              class="hover:text-pink"
              href="https://www.freepik.com/free-vector/cute-cat-sitting-cartoon-vector-icon-illustration-animal-nature-icon-concept-isolated-premium-vector-flat-cartoon-style_22638092.htm#query=cat%20svg&position=30&from_view=keyword&track=ais"
              target="_blank"
            >
              Encoded message cat wallpaper by catalyststuff
            </a>
          </li>
          <li>
            <a
              class="hover:text-mauve"
              href="https://codepen.io/johanmouchet/pen/OXxvqM"
              target="_blank"
            >
              Cat animation by Johan Mouchet
            </a>
          </li>
        </ul>
      </.modal>
    </div>
    """
  end
end
