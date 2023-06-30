defmodule MaccleCode.Shared do
  @spec letter?(String.t()) :: boolean()
  def letter?(letter) when is_binary(letter) do
    # This will fail for the vast majority of non-Latin characters
    # Maybe checking the length of the string is silly
    # Also can't believe I can't make this a guard
    String.length(letter) == 1 && String.match?(letter, ~r/[[:alpha:]]/)
  end

  @spec split_string(String.t(), atom() | String.t()) :: String.t()
  def split_string(string, :space), do: split_string(string, " ")
  def split_string(string, :newline), do: split_string(string, "\n")
  def split_string(string, :tab), do: split_string(string, "\t")

  def split_string(string, pattern) when is_binary(string) do
    String.split(string, pattern, trim: true)
  end
end

defmodule MaccleCode.Server do
  use GenServer

  @impl true
  def init(initial_words \\ []) do
    letters_and_words =
      for codepoint <- ?a..?z, into: %{} do
        letter = <<codepoint::utf8>>

        words =
          initial_words
          # `Enum.flat_map/2` kind of acts like a filter and a map operation here with the parameter match
          # Note the pin operator, might be too cute
          |> Enum.flat_map(fn
            {^letter, words} -> words
            _ -> []
          end)

        {String.to_atom(letter), words}
      end

    {:ok, letters_and_words}
  end

  @impl true
  def handle_call({:retrieve, letter}, _from, letters_and_words) do
    words = Map.fetch(letters_and_words, letter)

    {:reply, words, letters_and_words}
  end

  @impl true
  def handle_call({:add, {letter, words}}, _from, letters_and_words) do
    new_letters_and_words = Map.put(letters_and_words, letter, words)

    {:reply, new_letters_and_words}
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
    # TODO: Can you really never use remote functions within a guard?
    if letter?(letter) do
      # Anchor at the start of word, match the letter and any sequence and count of characters until the end of the line
      attributes = @attributes ++ ["^#{letter}.*$"]

      try do
        case System.cmd("dict", attributes) do
          # Would probably behoove me to check what `0` exactly means in this case
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
          |> Enum.map(fn letter ->
            Task.async(fn ->
              # Let it fail
              {:ok, words} = Dict.words_beginning_with(letter)

              {letter, words}
            end)
          end)
          |> Task.await_many()

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
    # Reminder - the below returns:
    # Two element tuple containing two lists

    # First list is the unique letters contained within the message,
    # each of which should be checked against our server to ensure we have words persisted for said letter

    # Second list is a list of lists, each nested list containing the individual
    # letters of a word of the message

    # TODO: Refactor the above Task jazz within `MaccleCode.init/1`, as we will need to possibly query Dict
    # for each unique letter. This could go horribly wrong with rate limits, but we'll see
    # Add a function to the server to ensure that we have words persisted (or not) for a letter
    # If we don't, then query Dict

    # For each letter of a word of a message (breathe), query the server and return a random
    # word. That becomes part of the encoded message
    # For now, return the unencoded message and the encoded message, so:
    # {:ok, {unencoded_message, encoded_message}}
    format_message_to_encode(message)
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
end
