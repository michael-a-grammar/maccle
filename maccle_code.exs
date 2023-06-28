defmodule MaccleCode do
  @type message :: String.t()

  @spec start(message()) :: any()
  def start(message) when is_binary(message) do
    message
    |> String.split(" ", trim: true)
    |> Enum.map(fn message_part ->
      # TODO: This will not handle none alpha characters
      message_part
      |> String.graphemes()
      |> Enum.filter(&String.match?(&1, ~r/[[:alpha:]]/))

      # TODO: Ideally -
      # Filter unique letters
      # Make a query to dict for each one
      # Persist the results
      # Right now we do it all at once

      |> Enum.map(fn letter ->
        # So, use the moby thesaurus dictionary as that seems to be the best or at
        # least easiest to understand and parse
        # Match (rather than query!) using POSIX regex
        # I'm unsure whether or not this returns like, every word beginning with the 
        # provided letter
        "dict -d 'moby-thesaurus' -m -s re '^#{String.downcase(letter)}.*$'"
      end)
    end)
  end
end

ExUnit.start(exclude: [:ignore])

defmodule MaccleCode.Test do
  use ExUnit.Case, async: true

  @tag :ignore
  test "it splits a message on spaces" do
    message = "Hello world, it's nice to be here!"

    expected = ["Hello", "world,", "it's", "nice", "to", "be", "here!"]

    result = MaccleCode.start(message)

    assert ^result = expected
  end

  @tag :ignore
  test "it ignores two or more spaces" do
    message = "Hello  world, it's     nice to be here!"

    expected = ["Hello", "world,", "it's", "nice", "to", "be", "here!"]

    result = MaccleCode.start(message)

    assert ^result = expected
  end

  test "it splits a message part into letters" do
    message = "Hello world, it's nice to be here!"

    expected = [
      ["H", "e", "l", "l", "o"],
      ["w", "o", "r", "l", "d"],
      ["i", "t", "s"],
      ["n", "i", "c", "e"],
      ["t", "o"],
      ["b", "e"],
      ["h", "e", "r", "e"]
    ]

    result = MaccleCode.start(message)

    assert ^result = expected
  end
end
