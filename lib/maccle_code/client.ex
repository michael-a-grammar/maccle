defmodule MaccleCode.Client do
  alias MaccleCode.Server

  def start_link(initial_words \\ []) do
    GenServer.start_link(Server, initial_words)
  end

  def retrieve_words_for_letters(pid, letters) do
    GenServer.call(pid, {:retrieve, letters})
  end

  def has_words_for_letters(pid, letters) do
    pid
    |> retrieve_words_for_letters(letters)
    |> Enum.map(fn {letter, words} -> {letter, Enum.any?(words)} end)
  end

  def add_words_for_letters(pid, letters_and_words) do
    GenServer.call(pid, {:add, letters_and_words})
  end
end
