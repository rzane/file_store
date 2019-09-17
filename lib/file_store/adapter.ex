defmodule FileStore.Adapter do
  alias FileStore.Stat

  @type store() :: FileStore.t()
  @type key() :: binary()
  @type path() :: Path.t()

  @doc """
  Writes a file to the store.
  """
  @callback write(store(), key(), iodata()) :: :ok | {:error, term()}

  @doc """
  Uploads a file to the store.
  """
  @callback upload(store(), path(), key()) :: :ok | {:error, term()}

  @doc """
  Downloads a file from the store.
  """
  @callback download(store(), key(), path()) :: :ok | {:error, term()}

  @doc """
  Retrieves information about a file from the store.
  """
  @callback stat(store(), key()) :: {:ok, Stat.t()} | {:error, term()}

  @doc """
  See `FileStore.Adapter.get_public_url/3`.
  """
  @callback get_public_url(store(), key()) :: binary()

  @doc """
  Generate a public URL for accessing the file.
  """
  @callback get_public_url(store(), key(), Keyword.t()) :: binary()

  @doc """
  See `FileStore.Adapter.get_signed_url/3`.
  """
  @callback get_signed_url(store(), key()) :: {:ok, binary()} | {:error, term()}

  @doc """
  Generate a signed URL for accessing a file. If the adapter does not support
  signed URLs, the regular URL will be returned.
  """
  @callback get_signed_url(store(), key(), Keyword.t()) :: {:ok, binary()} | {:error, term()}
end
