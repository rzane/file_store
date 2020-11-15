defmodule FileStore.Middleware do
  @moduledoc """
  Middleware allows you to enhance your store with additional functionality.

  The following middlewares ship with this library.

    * `FileStore.Middleware.Logger`
    * `FileStore.Middleware.Errors`
    * `FileStore.Middleware.Prefix`

  To use a middleware, simply wrap your existing store with the middleware:

      iex> store = FileStore.Adapters.Disk.new([...])
      %FileStore.Adapters.Disk{...}

      iex> store = FileStore.Middleware.Logger.new(store)
      %FileStore.Middleware.Logger{...}

      iex> FileStore.read(store, "test.txt")
      # 02:37:30.724 [debug] READ OK key="test.txt"
      {:ok, "hello"}

  You can compose multiple middlewares, but order _does_ matter. The following
  order is recommended:

      FileStore.Adapters.Null.new()
      |> FileStore.Middleware.Errors.new()
      |> FileStore.Middleware.Prefix.new(prefix: "foo")
      |> FileStore.Middleware.Logger.new()
  """
end
