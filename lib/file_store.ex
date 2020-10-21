defprotocol FileStore do
  @moduledoc """
  FileStore allows you to read, write, upload, download, and interact
  with files, regardless of where they are stored.

  ## Adapters

  This package ships with the following adapters:

    * `FileStore.Adapters.Disk`
    * `FileStore.Adapters.S3`
    * `FileStore.Adapters.Memory`
    * `FileStore.Adapters.Null`

  The documentation for each adapter includes an example that demonstrates
  it's usage.
  """

  @type key :: binary()
  @type list_opts :: [{:prefix, binary()}]

  @type public_url_opts :: [
          {:content_type, binary()}
          | {:disposition, binary()}
        ]

  @type signed_url_opts :: [
          {:content_type, binary()}
          | {:disposition, binary()}
          | {:expires_in, integer()}
        ]

  @doc """
  Write a file to the store. If a file with the given `key`
  already exists, it will be overwritten.

  ## Examples

      iex> FileStore.write(store, "foo", "hello world")
      :ok

  """
  @spec write(t, key, binary) :: :ok | {:error, term}
  def write(store, key, content)

  @doc """
  Read the contents of a file in store into memory.

  ## Examples

      iex> FileStore.read(store, "foo")
      {:ok, "hello world"}

  """
  @spec read(t, key) :: {:ok, binary} | {:error, term}
  def read(store, key)

  @doc """
  Upload a file to the store. If a file with the given `key`
  already exists, it will be overwritten.

  ## Examples

      iex> FileStore.upload(store, "/path/to/bar.txt", "foo")
      :ok

  """
  @spec upload(t, Path.t(), key) :: :ok | {:error, term}
  def upload(store, source, key)

  @doc """
  Download a file from the store and save it to the given `path`.

  ## Examples

      iex> FileStore.download(store, "foo", "/path/to/bar.txt")
      :ok

  """
  @spec download(t, key, Path.t()) :: :ok | {:error, term}
  def download(store, key, destination)

  @doc """
  Retrieve information about a file from the store.

  ## Examples

      iex> FileStore.stat(store, "foo")
      {:ok, %FileStore.Stat{key: "foo", etag: "2e5pd429", size: 24}}

  """
  @spec stat(t, key) :: {:ok, FileStore.Stat.t()} | {:error, term}
  def stat(store, key)

  @doc """
  Delete a file from the store.

  ## Examples

    iex> FileStore.delete(store, "foo")
    :ok

  """
  @spec delete(t, key) :: :ok | {:error, term}
  def delete(store, key)

  @doc """
  Get URL for your file, assuming that the file is publicly accessible.

  ## Options

    * `:content_type` - Force the `Content-Type` of the response.
    * `:disposition` - Force the `Content-Disposition` of the response.

  ## Examples

      iex> FileStore.get_public_url(store, "foo")
      "https://mybucket.s3-us-east-1.amazonaws.com/foo"

  """
  @spec get_public_url(t, key, public_url_opts) :: binary
  def get_public_url(store, key, opts \\ [])

  @doc """
  Generate a signed URL for your file. Any user with this URL should be able
  to access the file.

  ## Options

    * `:expires_in` - The number of seconds before the URL expires.
    * `:content_type` - Force the `Content-Type` of the response.
    * `:disposition` - Force the `Content-Disposition` of the response.

  ## Examples

      iex> FileStore.get_signed_url(store, "foo")
      {:ok, "https://s3.amazonaws.com/mybucket/foo?X-AMZ-Expires=3600&..."}

  """
  @spec get_signed_url(t, key, signed_url_opts) :: {:ok, binary} | {:error, term}
  def get_signed_url(store, key, opts \\ [])

  @doc """
  List files in the store.

  ## Options

    * `:prefix` - Only return keys matching the given prefix.

  ## Examples

      iex> Enum.to_list(FileStore.list!(store))
      ["bar", "foo/bar"]

      iex> Enum.to_list(FileStore.list!(store, prefix: "foo"))
      ["foo/bar"]

  """
  @spec list!(t, list_opts) :: Enumerable.t()
  def list!(store, opts \\ [])
end
