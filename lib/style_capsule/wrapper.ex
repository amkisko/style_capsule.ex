defmodule StyleCapsule.Wrapper do
  @moduledoc """
  Wraps HTML content in a root element with `data-capsule` attribute.
  """

  @doc """
  Wraps HTML content in a root element with `data-capsule` attribute.

  ## Options

    * `:tag` - HTML tag name. Defaults to `:div`.
    * `:attrs` - Additional attributes to add to the wrapper element.

  ## Examples

      iex> StyleCapsule.Wrapper.wrap("<div class=\\"content\\">Hello</div>", "abc12345")
      ~s(<div data-capsule="abc12345"><div class="content">Hello</div></div>)

      iex> StyleCapsule.Wrapper.wrap("<div class=\\"content\\">Hello</div>", "abc12345", tag: :span)
      ~s(<span data-capsule="abc12345"><div class="content">Hello</div></span>)

  """
  @spec wrap(iodata(), binary(), keyword()) :: binary()
  def wrap(html_or_iodata, capsule_id, opts \\ []) do
    tag = Keyword.get(opts, :tag, :div)
    attrs = Keyword.get(opts, :attrs, [])

    StyleCapsule.Id.validate!(capsule_id)

    tag_attrs = build_attrs(capsule_id, attrs)
    tag_name = to_string(tag)

    html_string =
      html_or_iodata
      |> IO.iodata_to_binary()

    ~s(<#{tag_name}#{tag_attrs}>#{html_string}</#{tag_name}>)
  end

  @doc false
  defp build_attrs(capsule_id, additional_attrs) do
    base_attrs = [{"data-capsule", capsule_id}]
    all_attrs = base_attrs ++ normalize_attrs(additional_attrs)

    Enum.map_join(all_attrs, "", fn {key, value} ->
      key_str = to_string(key)
      value_str = escape_html_attr(to_string(value))
      ~s( #{key_str}="#{value_str}")
    end)
  end

  @doc false
  defp normalize_attrs(attrs) when is_list(attrs) do
    Enum.map(attrs, fn
      {key, value} -> {key, value}
      key when is_atom(key) -> {key, true}
      other -> raise ArgumentError, "Invalid attribute: #{inspect(other)}"
    end)
  end

  @doc false
  defp normalize_attrs(_), do: []

  @doc false
  defp escape_html_attr(str) do
    str
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
