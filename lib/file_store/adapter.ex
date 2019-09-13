defmodule FileStore.Adapter do
  @type store() :: FileStore.t()
  @type key() :: binary()
  @type path() :: Path.t()

  @doc """
  Writes a file to the store.
  """
  @callback write(store(), key(), iodata()) :: :ok | :error

  @callback copy(store(), path(), key()) :: :ok | :error
  @callback get_public_url(store(), key()) :: {:ok, binary()} | :error
  @callback get_public_url(store(), key(), Keyword.t()) :: {:ok, binary()} | :error
  @callback get_signed_url(store(), key()) :: {:ok, binary()} | :error
  @callback get_signed_url(store(), key(), Keyword.t()) :: {:ok, binary()} | :error
end
