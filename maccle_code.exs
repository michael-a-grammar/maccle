defmodule MaccleCode.Shared do
  def letter?(letter) do
    String.length(letter) == 1 && String.match?(letter, ~r/[[:alpha:]]/)
  end
end

defmodule MaccleCode do
  import MaccleCode.Shared

  @type message :: String.t()
  @type message_part :: list(String.t())
  @type message_parts :: list(message_part())

  # The most common letters in English, apparently
  @common_letters ~w(e t a o i n s r h l)

  @spec start(message()) :: any()
  def start(message) when is_binary(message) do
    format_message_to_encode(message)
  end

  @spec start(message()) :: {list(String.t()), message_parts()}
  defp format_message_to_encode(message) when is_binary(message) do
    message
    |> String.split(" ", trim: true)
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
              |> String.split("\n", trim: true)
              |> Enum.map(&String.split(&1, "\t", trim: true))
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

ExUnit.start(exclude: [:ignore])

defmodule MaccleCode.Test do
  use ExUnit.Case, async: true

  describe "MaccleCode.start/1" do
    @tag :ignore
    test "it splits a message on spaces" do
      message = "Hello world, it's nice to be here!"

      expected = ~w(Hello world it's nice to be here!)

      result = MaccleCode.start(message)

      assert ^result = expected
    end

    @tag :ignore
    test "it ignores two or more spaces" do
      message = "Hello  world, it's     nice to be here!"

      expected = ~w(Hello world it's nice to be here!)

      result = MaccleCode.start(message)

      assert ^result = expected
    end

    @tag :ignore
    test "it splits a message part into letters" do
      message = "Hello world, it's nice to be here!"

      expected = [
        ~w(H e l l o),
        ~w(w o r l d),
        ~w(i t s),
        ~w(n i c e),
        ~w(t o),
        ~w(b e),
        ~w(h e r e)
      ]

      result = MaccleCode.start(message)

      assert ^result = expected
    end

    test "it returns a split message and unique letters" do
      message = "Hello world, it's nice to be here!"

      unique_letters = ~w(h e l o w r d i t s n c b)

      split_message = [
        ~w(h e l l o),
        ~w(w o r l d),
        ~w(i t s),
        ~w(n i c e),
        ~w(t o),
        ~w(b e),
        ~w(h e r e)
      ]

      expected = {unique_letters, split_message}

      result = MaccleCode.start(message)

      assert ^result = expected
    end
  end

  describe "MaccleCode.Dict.words_beginning_with/1" do
    @tag :ignore
    test "it returns an ok tuple" do
      letter = "h"

      expected = {:ok, letter}

      result = MaccleCode.Dict.words_beginning_with(letter)

      assert ^result = expected
    end

    @tag :ignore
    test "it returns an error tuple if not provided with a letter" do
      character = "!"

      expected = {:error, character}

      result = MaccleCode.Dict.words_beginning_with(character)

      assert ^result = expected
    end

    @tag :ignore
    test "it strips the results of garbage" do
      results = "
dict.org	2628	moby-thesaurus	ha ha
dict.org	2628	moby-thesaurus	haberdasher
dict.org	2628	moby-thesaurus	haberdashery
dict.org	2628	moby-thesaurus	habit
dict.org	2628	moby-thesaurus	habitat
dict.org	2628	moby-thesaurus	habitation
dict.org	2628	moby-thesaurus	habitual
dict.org	2628	moby-thesaurus	habitually
dict.org	2628	moby-thesaurus	habituate
dict.org	2628	moby-thesaurus	habituation
dict.org	2628	moby-thesaurus	habitue
dict.org	2628	moby-thesaurus	hachure
dict.org	2628	moby-thesaurus	hacienda
dict.org	2628	moby-thesaurus	hack
dict.org	2628	moby-thesaurus	hack it"

      expected = ~w(
        haberdasher
        haberdashery
        habit
        habitat
        habitation
        habitual
        habitually
        habituate
        habituation
        habitue
        hachure        
        hacienda      
        hack
      )

      result =
        results
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, "\t", trim: true))
        |> Enum.map(&List.last/1)
        |> Enum.filter(&(!String.contains?(&1, " ")))

      IO.inspect(result, label: "result")

      assert ^expected = result
    end
  end
end
