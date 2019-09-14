defmodule FileStore.Adapters.Null do
  @behaviour FileStore.Adapter

  @impl true
  def get_public_url(_store, key, _opts \\ []), do: key

  @impl true
  def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def copy(_store, _source, _key), do: :ok

  @impl true
  def write(_store, _key, _content), do: :ok
end
