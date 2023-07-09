defmodule MaccleCode.Messaging.Encoder do
  alias MaccleCode.Messaging.Dict
  alias MaccleCode.Messaging.Server
  alias MaccleCode.Messaging.Shared

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

    Server.start_link(initial_words)
  end

  def encode(pid, message) when is_pid(pid) and is_binary(message) do
    {unique_letters, message_parts} = format_message_to_encode(message)

    unique_letters
    |> then(&Server.has_words_for_letters(pid, &1))
    |> Enum.filter(&(!elem(&1, 1)))
    |> Enum.map(&elem(&1, 0))
    |> retrieve_words_for_letters()
    |> then(&Server.add_words_for_letters(pid, &1))

    encoded_message =
      message_parts
      |> Enum.map(fn letters ->
        letters
        |> then(&Server.retrieve_words_for_letters(pid, &1))
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

  defp format_message_to_encode(message) when is_binary(message) do
    message
    |> Shared.split_string(:space)
    |> Enum.map(fn message_part ->
      message_part
      |> String.graphemes()
      |> Enum.filter(&Shared.letter?/1)
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
