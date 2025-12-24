defmodule StyleCapsule.Error do
  @moduledoc """
  Base error module for StyleCapsule.

  All StyleCapsule-specific errors should use this module.
  """
  defexception [:message]

  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  def exception(opts) when is_list(opts) do
    message = Keyword.get(opts, :message, "StyleCapsule error")
    %__MODULE__{message: message}
  end
end

defmodule StyleCapsule.InvalidStyleError do
  @moduledoc """
  Raised when invalid CSS styles are provided.
  """
  defexception [:message, :module, :styles]

  def exception(opts) when is_list(opts) do
    module = Keyword.get(opts, :module)
    styles = Keyword.get(opts, :styles, "")
    message = Keyword.get(opts, :message) || "Invalid styles in #{inspect(module)}"

    %__MODULE__{
      message: message,
      module: module,
      styles: styles
    }
  end
end

defmodule StyleCapsule.CapsuleNotFoundError do
  @moduledoc """
  Raised when a capsule ID cannot be found or generated.
  """
  defexception [:message, :module]

  def exception(opts) when is_list(opts) do
    module = Keyword.get(opts, :module)
    message = Keyword.get(opts, :message) || "Capsule not found for #{inspect(module)}"

    %__MODULE__{
      message: message,
      module: module
    }
  end
end

defmodule StyleCapsule.RegistryError do
  @moduledoc """
  Raised when there's an error with the compile-time registry.
  """
  defexception [:message, :operation]

  def exception(opts) when is_list(opts) do
    operation = Keyword.get(opts, :operation, :unknown)
    message = Keyword.get(opts, :message) || "Registry error during #{operation}"

    %__MODULE__{
      message: message,
      operation: operation
    }
  end
end
