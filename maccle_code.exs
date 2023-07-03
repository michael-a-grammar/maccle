defmodule MaccleCode.Shared do
  def letter?(letter) when is_binary(letter) do
    String.match?(letter, ~r/[[:alpha:]]/)
  end

  def split_string(string, :space) when is_binary(string) do
    split_string(string, " ")
  end

  def split_string(string, :newline) when is_binary(string) do
    split_string(string, "\n")
  end
  
  def split_string(string, :tab) when is_binary(string) do
    split_string(string, "\t")
  end

  def split_string(string, pattern) when is_binary(string) do
    String.split(string, pattern, trim: true)
  end
end

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

defmodule MaccleCode.Client do
  import MaccleCode.Shared
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

defmodule MaccleCode.Dict do
  import MaccleCode.Shared

  @attributes ~w(--database moby-thesaurus --formatted --match --strategy re)

  def words_beginning_with(letter) do
    if letter?(letter) do
      attributes = @attributes ++ ["^#{letter}.*$"]

      try do
        case System.cmd("dict", attributes) do
          {result, 0} ->
            words =
              result
              |> split_string(:newline)
              |> Enum.map(&split_string(&1, :tab))
              |> Enum.map(&List.last/1)
              |> Enum.filter(&(!String.contains?(&1, " ")))

            {:ok, words}

          _ ->
            {:error, letter}
        end
      rescue
        e in ErlangError -> {:error, e}
      end
    else
      {:error, letter}
    end
  end
end

defmodule MaccleCode do
  alias MaccleCode.Client
  alias MaccleCode.Dict
  import MaccleCode.Shared

  @common_letters ~w(e t a o i n s r h l)

  def init(opts \\ []) do
    initial_words =
      case Keyword.get(opts, :eager, nil) do
        true ->
          @common_letters
          |> retrieve_words_for_letters()

        _ ->
          []
      end

    Client.start_link(initial_words)
  end

  def encode(pid, message) when is_pid(pid) and is_binary(message) do
    {unique_letters, message_parts} = format_message_to_encode(message)

    unique_letters
    |> then(&Client.has_words_for_letters(pid, &1))
    |> Enum.filter(&(!elem(&1, 1)))
    |> Enum.map(&elem(&1, 0))
    |> retrieve_words_for_letters()
    |> then(&Client.add_words_for_letters(pid, &1))

    encoded_message =
      message_parts
      |> Enum.map(fn letters ->
        letters
        |> then(&Client.retrieve_words_for_letters(pid, &1))
        |> Enum.map(fn words ->
          words
          |> elem(1)
          |> Enum.random()
        end)
      end)

    {:ok, encoded_message}
  end

  def format_encoded_message(encoded_message) do
    case encoded_message do
      {:ok, encoded_message_parts} ->
        Enum.map_join(encoded_message_parts, " ", &Enum.join(&1, " "))

      _ ->
        :error
    end
  end

  def decode(pid, message) when is_pid(pid) and is_binary(message) do
    message
    |> split_string(:space)
    |> Enum.map(&String.at(&1, 0))
  end

  defp format_message_to_encode(message) when is_binary(message) do
    message
    |> split_string(:space)
    |> Enum.map(fn message_part ->
      message_part
      |> String.graphemes()
      |> Enum.filter(&letter?/1)
      |> Enum.map(&String.downcase/1)
    end)
    |> then(fn message_parts ->
      unique_letters =
        message_parts
        |> List.flatten()
        |> Enum.uniq()

      {unique_letters, message_parts}
    end)
  end

  defp retrieve_words_for_letters(letters) do
    letters
    |> Enum.map(fn letter ->
      Task.async(fn ->
        {:ok, words} = Dict.words_beginning_with(letter)

        {letter, words}
      end)
    end)
    |> Task.await_many()
  end
end
