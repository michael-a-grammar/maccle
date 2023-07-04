defmodule MaccleCode.Server do
  use GenServer

  @impl true
  def init(initial_words \\ []) do
    letters_and_words =
      for codepoint <- ?a..?z, into: [] do
        letter = <<codepoint::utf8>>

        words =
          initial_words
          |> Enum.flat_map(fn
            {^letter, words} -> words
            _ -> []
          end)

        {letter, words}
      end

    {:ok, letters_and_words}
  end

  @impl true
  def handle_call({:retrieve, letters}, _from, letters_and_words) do
    retrieved_letters_and_words =
      Enum.map(letters, fn letter ->
        List.keyfind!(letters_and_words, letter, 0)
      end)

    {:reply, retrieved_letters_and_words, letters_and_words}
  end

  @impl true
  def handle_call({:add, letters_and_words_to_add}, _from, letters_and_words) do
    new_letters_and_words =
      Enum.reduce(letters_and_words_to_add, letters_and_words, fn {letter, words}, acc ->
        List.keyreplace(acc, letter, 0, {letter, words})
      end)

    {:reply, letters_and_words, new_letters_and_words}
  end
end
