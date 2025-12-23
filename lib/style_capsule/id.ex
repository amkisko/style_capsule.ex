defmodule StyleCapsule.Id do
  @moduledoc """
  Generates and validates capsule IDs for component scoping.

  Capsule IDs are deterministic, URL-safe identifiers derived from module names
  or other stable terms. They are used to scope CSS rules to specific components.
  """

  @max_length 32
  @min_length 8
  @valid_pattern ~r/^[a-zA-Z0-9_-]+$/

  @type opts :: keyword()

  @doc """
  Generates a deterministic capsule ID for a module or term.

  ## Options

    * `:length` - Desired length of the ID (default: 12)
    * `:prefix` - Optional prefix to add to the ID

  ## Examples

      iex> id = StyleCapsule.Id.generate(MyAppWeb.Components.Card)
      iex> String.length(id) >= 8
      true

      iex> id = StyleCapsule.Id.generate(MyAppWeb.Components.Card, length: 8)
      iex> String.length(id)
      8

  """
  @spec generate(module() | term(), opts()) :: binary()
  def generate(module_or_term, opts \\ []) do
    length = Keyword.get(opts, :length, 12)
    prefix = Keyword.get(opts, :prefix, "")

    input_string =
      cond do
        is_atom(module_or_term) ->
          Atom.to_string(module_or_term)

        is_binary(module_or_term) ->
          module_or_term

        true ->
          inspect(module_or_term)
      end

    base_id =
      input_string
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)
      |> String.slice(0, length)

    if prefix != "" do
      prefix <> base_id
    else
      base_id
    end
  end

  @doc """
  Validates a capsule ID and raises if invalid.

  ## Examples

      iex> StyleCapsule.Id.validate!("abc12345")
      :ok

      iex> StyleCapsule.Id.validate!("invalid id!")
      ** (ArgumentError) Invalid capsule ID: must match pattern ^[a-zA-Z0-9_-]+$

  """
  @spec validate!(binary()) :: :ok
  def validate!(id) when is_binary(id) do
    cond do
      String.length(id) < @min_length ->
        raise ArgumentError,
              "Invalid capsule ID: must be at least #{@min_length} characters, got #{String.length(id)}"

      String.length(id) > @max_length ->
        raise ArgumentError,
              "Invalid capsule ID: must be at most #{@max_length} characters, got #{String.length(id)}"

      not Regex.match?(@valid_pattern, id) ->
        raise ArgumentError,
              "Invalid capsule ID: must match pattern ^[a-zA-Z0-9_-]+$"

      true ->
        :ok
    end
  end

  def validate!(id) do
    raise ArgumentError, "Capsule ID must be a binary, got: #{inspect(id)}"
  end

  @doc """
  Validates a capsule ID and returns `:ok` or `{:error, reason}`.

  ## Examples

      iex> StyleCapsule.Id.validate("abc12345")
      :ok

      iex> StyleCapsule.Id.validate("invalid id!")
      {:error, "Invalid capsule ID: must match pattern ^[a-zA-Z0-9_-]+$"}

  """
  @spec validate(binary()) :: :ok | {:error, binary()}
  def validate(id) when is_binary(id) do
    validate!(id)
  rescue
    e in ArgumentError -> {:error, Exception.message(e)}
  end

  def validate(id) do
    {:error, "Capsule ID must be a binary, got: #{inspect(id)}"}
  end
end
