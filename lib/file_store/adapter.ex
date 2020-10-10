defmodule FileStore.Adapter do
  @moduledoc false

  alias FileStore.Stat

  @type store :: FileStore.t()
  @type key :: FileStore.key()

  @callback write(store, key, binary) :: :ok | {:error, term}
  @callback read(store, key) :: {:ok, binary} | {:error, term}
  @callback upload(store, Path.t(), key) :: :ok | {:error, term}
  @callback download(store, key, Path.t()) :: :ok | {:error, term}
  @callback stat(store, key) :: {:ok, Stat.t()} | {:error, term}
  @callback delete(store, key) :: :ok | {:error, term}
  @callback get_public_url(store, key) :: binary
  @callback get_public_url(store, key, keyword) :: binary
  @callback get_signed_url(store, key, keyword) :: {:ok, binary} | {:error, term}
  @callback list(store) :: Enumerable.t()
end
