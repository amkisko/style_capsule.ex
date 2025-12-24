defmodule StyleCapsule.ErrorTest do
  use ExUnit.Case, async: true

  alias StyleCapsule.Error
  alias StyleCapsule.InvalidStyleError
  alias StyleCapsule.CapsuleNotFoundError
  alias StyleCapsule.RegistryError

  describe "StyleCapsule.Error" do
    test "raises with message string" do
      error = Error.exception("Test error message")
      assert %Error{message: "Test error message"} = error
    end

    test "raises with keyword list" do
      error = Error.exception(message: "Custom error")
      assert %Error{message: "Custom error"} = error
    end

    test "has default message" do
      error = Error.exception([])
      assert %Error{message: "StyleCapsule error"} = error
    end
  end

  describe "StyleCapsule.InvalidStyleError" do
    test "raises with module and styles" do
      error = InvalidStyleError.exception(
        module: TestModule,
        styles: ".test { color: red; }",
        message: "Invalid styles detected"
      )

      assert %InvalidStyleError{
        message: "Invalid styles detected",
        module: TestModule,
        styles: ".test { color: red; }"
      } = error
    end

    test "has default message" do
      error = InvalidStyleError.exception(module: TestModule, styles: "")
      assert error.message =~ "Invalid styles in"
      assert error.module == TestModule
    end
  end

  describe "StyleCapsule.CapsuleNotFoundError" do
    test "raises with module" do
      error = CapsuleNotFoundError.exception(
        module: TestModule,
        message: "Capsule not found"
      )

      assert %CapsuleNotFoundError{
        message: "Capsule not found",
        module: TestModule
      } = error
    end

    test "has default message" do
      error = CapsuleNotFoundError.exception(module: TestModule)
      assert error.message =~ "Capsule not found for"
      assert error.module == TestModule
    end
  end

  describe "StyleCapsule.RegistryError" do
    test "raises with operation" do
      error = RegistryError.exception(
        operation: :register,
        message: "Registry operation failed"
      )

      assert %RegistryError{
        message: "Registry operation failed",
        operation: :register
      } = error
    end

    test "has default message" do
      error = RegistryError.exception(operation: :register)
      assert error.message =~ "Registry error during"
      assert error.operation == :register
    end
  end
end
