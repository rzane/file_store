defmodule FileStore.Adapters.Null do
  @moduledoc """
  Does not attempt to store files.

  ### Example

      iex> store = FileStore.Adaptesr.Null.new()
      %FileStore{...}

      iex> FileStore.write(store, "foo", "hello world")
      :ok

      iex> FileStore.read(store, "foo")
      {:ok, "hello world"}

  """

  defstruct []

  @doc "Creates a new null adapter"
  @spec new(keyword) :: FileStore.t()
  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end

  defimpl FileStore do
    alias FileStore.Stat

    def get_public_url(_store, key, _opts \\ []), do: key
    def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}
    def stat(_store, key), do: {:ok, %Stat{key: key, size: 0, etag: Stat.checksum("")}}
    def delete(_store, _key), do: :ok
    def upload(_store, _source, _key), do: :ok
    def download(_store, _key, _destination), do: :ok
    def write(_store, _key, _content), do: :ok
    def read(_store, _key), do: {:ok, ""}
    def list!(_store, _opts \\ []), do: Stream.into([], [])
  end
end
