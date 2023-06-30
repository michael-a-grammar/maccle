defmodule MaccleCode.Shared do
  @spec letter?(String.t()) :: boolean()
  def letter?(letter) when is_binary(letter) do
    # This will fail for the vast majority of non-Latin characters...?
    # Also can't believe I can't make this a guard
    String.match?(letter, ~r/[[:alpha:]]/)
  end

  @spec split_string(String.t(), atom() | String.t()) :: String.t()
  def split_string(string, :space) when is_binary(string), do: split_string(string, " ")
  def split_string(string, :newline) when is_binary(string), do: split_string(string, "\n")
  def split_string(string, :tab) when is_binary(string), do: split_string(string, "\t")

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
          # `Enum.flat_map/2` kind of acts like a filter and a map operation here with the parameter match
          # Note the pin operator, might be too cute
          |> Enum.flat_map(fn
            {^letter, words} -> words
            _ -> []
          end)

        {letter, words}
      end

    {:ok, letters_and_words}
  end

  @impl true
  def handle_call({:retrieve, letter}, _from, letters_and_words) do
    words =
      letters_and_words
      |> List.keyfind!(letter, 0)
      |> elem(1)

    {:reply, words, letters_and_words}
  end

  @impl true
  def handle_call({:add, {letter, words}}, _from, letters_and_words) do
    new_letters_and_words = List.keyreplace(letters_and_words, letter, 0, {letter, words})

    {:reply, letters_and_words, new_letters_and_words}
  end
end

defmodule MaccleCode.Client do
  alias MaccleCode.Server

  def start_link(initial_words \\ []) do
    GenServer.start_link(Server, initial_words)
  end

  def retrieve_words_for_letter(pid, letter) do
    GenServer.call(pid, {:retrieve, letter})
  end

  def has_words_for_letter(pid, letter) do
    pid
    |> retrieve_words_for_letter(letter)
    |> Enum.any?()
  end

  def add_words_for_letter(pid, letter_and_words) do
    GenServer.call(pid, {:add, letter_and_words})
  end
end

defmodule MaccleCode.Dict do
  import MaccleCode.Shared

  @doc ~S"""
  The attributes provided to a call to Dict
  So, use the moby-thesaurus uh, dictionary, which generally seems to have the best results
  Format the results for easier parsing - rows seperated by newlines, columns seperated by tabs
  Match rather than query results
  Use POSIX regex for the actual query itself
  """
  @attributes ~w(--database moby-thesaurus --formatted --match --strategy re)

  def words_beginning_with(letter) do
    # TODO: can you really never use remote functions within a guard?
    if letter?(letter) do
      # Anchor at the start of word, match the letter and any sequence and count of characters until the end of the line
      attributes = @attributes ++ ["^#{letter}.*$"]

      try do
        case System.cmd("dict", attributes) do
          # TODO: would probably behoove me to check what `0` exactly means in this context
          # Presumably an exit code
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

  @type message :: String.t()
  @type unique_letters :: list(String.t())
  @type message_part :: list(String.t())
  @type message_parts :: list(message_part())

  # The 10 most common letters in English, apparently
  @common_letters ~w(e t a o i n s r h l)

  def init(opts \\ []) do
    initial_words =
      case Keyword.get(opts, :eager, nil) do
        true ->
          # Here, we eagerly load words for the 10 most common letters in English
          # As making 10 requests synchronous requests to Dict is painfully slow,
          # we fire off 10 concurrent tasks instead
          # If Dict blocks our IP, this is why lol
          @common_letters
          |> retrieve_words_for_letters()

        _ ->
          []
      end

    # TODO: Uh, is this supposed to go here?
    # Maybe look at it again when we add Phoenix, presumably that encapsulates
    # Supervision etc.
    Client.start_link(initial_words)
  end

  @spec encode(pid(), message()) :: any()
  def encode(pid, message) when is_pid(pid) and is_binary(message) do
    {unique_letters, message_parts} = format_message_to_encode(message)

    unique_letters
    |> Enum.map(fn unique_letter ->
      {Client.has_words_for_letter(pid, unique_letter), unique_letter}
    end)
    |> Enum.filter(&(!elem(&1, 0)))
    |> Enum.map(&elem(&1, 1))
    |> retrieve_words_for_letters()
    # TODO: This will be a rather large bottleneck
    # You probably want to do this as one operation
    |> Enum.map(&Client.add_words_for_letter(pid, &1))

    encoded_message =
      message_parts
      |> Enum.map(fn letters ->
        letters
        |> Enum.map(fn letter ->
          Client.retrieve_words_for_letter(pid, letter)
          |> Enum.random()
        end)
      end)

    {:ok, encoded_message}
  end

  @spec format_message_to_encode(message()) :: {unique_letters(), message_parts()}
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
