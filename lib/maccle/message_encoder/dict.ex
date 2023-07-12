defmodule Maccle.MessageEncoder.Dict do
  alias Maccle.MessageEncoder.Shared

  @attributes ~w(--database moby-thesaurus --formatted --match --strategy re)

  def words_beginning_with(letter) do
    if Shared.letter?(letter) do
      attributes = @attributes ++ ["^#{letter}.*$"]

      try do
        case System.cmd("dict", attributes) do
          {result, 0} ->
            words =
              result
              |> Shared.split_string(:newline)
              |> Enum.map(&Shared.split_string(&1, :tab))
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
