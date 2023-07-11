defmodule MaccleCode.Server do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def retrieve_words_for_letters(pid, letters) do
    GenServer.call(pid, {:retrieve, letters})
  end

  @spec has_words_for_letters(atom | pid | {atom, any} | {:via, atom, any}, any) :: list
  def has_words_for_letters(pid, letters) do
    pid
    |> retrieve_words_for_letters(letters)
    |> Enum.map(fn {letter, words} -> {letter, Enum.any?(words)} end)
  end

  def add_words_for_letters(pid, letters_and_words) do
    GenServer.call(pid, {:add, letters_and_words})
  end

  @impl true
  def init(_opts) do
    letters_and_words =
      for codepoint <- ?a..?z, into: [] do
        {<<codepoint::utf8>>, []}
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
