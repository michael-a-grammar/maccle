defmodule Maccle.MessageEncoder.Client do
  alias Maccle.MessageEncoder.Dict
  alias Maccle.MessageEncoder.Server
  alias Maccle.MessageEncoder.Shared

  @common_letters ~w(e t a o i n s r h l)

  def init(opts \\ []) do
    case Keyword.get(
           opts,
           :eager_load_words_for_common_letters,
           eager_load_words_for_common_letters()
         ) do
      true ->
        @common_letters
        |> retrieve_words_for_letters()
        |> then(&Server.add_words_for_letters(Server, &1))

      _ ->
        []
    end

    :ok
  end

  def encode(message) when is_binary(message) do
    {unique_letters, message_parts} = format_message_to_encode(message)

    unique_letters
    |> then(&Server.has_words_for_letters(Server, &1))
    |> Enum.filter(&(!elem(&1, 1)))
    |> Enum.map(&elem(&1, 0))
    |> retrieve_words_for_letters()
    |> then(&Server.add_words_for_letters(Server, &1))

    encoded_message =
      message_parts
      |> Enum.map(fn letters ->
        letters
        |> then(&Server.retrieve_words_for_letters(Server, &1))
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

  def decode(encoded_message) when is_binary(encoded_message) do
    encoded_message
    |> Shared.split_string(:space)
    |> Enum.map(&String.first/1)
  end

  def format_decoded_message(decoded_message) do
    decoded_message
    |> Enum.join(" ")
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

  defp eager_load_words_for_common_letters() do
    Application.fetch_env!(:maccle, :eager_load_words_for_common_letters)
  end
end
