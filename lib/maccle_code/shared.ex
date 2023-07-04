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
