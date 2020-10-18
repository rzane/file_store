defmodule FileStore.Adapters.Null do
  @moduledoc """
  Does not attempt to store files.

  ### Example

      iex> store = FileStore.new(adapter: FileStore.Adapters.Null)
      %FileStore{...}

      iex> FileStore.write(store, "foo", "hello world")
      :ok

      iex> FileStore.read(store, "foo")
      {:ok, "hello world"}

  """

  @behaviour FileStore.Adapter

  alias FileStore.Stat

  defstruct []

  @impl true
  def get_public_url(_store, key, _opts \\ []), do: key

  @impl true
  def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def stat(_store, key), do: {:ok, %Stat{key: key, size: 0, etag: Stat.checksum("")}}

  @impl true
  def delete(_store, _key), do: :ok

  @impl true
  def upload(_store, _source, _key), do: :ok

  @impl true
  def download(_store, _key, _destination), do: :ok

  @impl true
  def write(_store, _key, _content), do: :ok

  @impl true
  def read(_store, _key), do: {:ok, ""}

  @impl true
  def list!(_store, _opts \\ []), do: Stream.into([], [])
end
