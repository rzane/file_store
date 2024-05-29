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

  @typedoc "The file key."
  @type key :: binary()

  @typedoc "The prefix path option."
  @type prefix_opt :: {:prefix, binary()}

  @typedoc "The file content disposition hint for the adapter."
  @type disposition_opt :: {:disposition, binary()}

  @typedoc "The file content type hint for the adapter."
  @type content_type_opt :: {:content_type, binary()}

  @typedoc "The number of seconds the URL will expire in."
  @type expires_in_opt :: {:expires_in, integer()}

  @typedoc "The number of bytes to chunk a stream with."
  @type chunk_size_opt :: {:chunk_size, pos_integer()}

  @typedoc "Streams a file line by line."
  @type line_opt :: {:line, boolean()}

  @type list_opts :: [prefix_opt()]
  @type delete_all_opts :: [prefix_opt()]
  @type write_opts :: [content_type_opt() | disposition_opt()]
  @type public_url_opts :: [content_type_opt() | disposition_opt()]
  @type signed_url_opts :: [content_type_opt() | disposition_opt() | expires_in_opt()]
  @type stream_opts :: [chunk_size_opt() | line_opt()]

  @doc """
  Write a file to the store. If a file with the given `key`
  already exists, it will be overwritten.

  ## Options

      * `:content_type` - Sets the content type hint for the adapter.
      * `:disposition` - Sets the content disposition hint for the adapter.

  ## Examples

      iex> FileStore.write(store, "foo", "hello world")
      :ok

  """
  @spec write(t, key, binary, write_opts) :: :ok | {:error, term}
  def write(store, key, content, opts \\ [])

  @doc """
  Read the contents of a file in store into memory.

  ## Examples

      iex> FileStore.read(store, "foo")
      {:ok, "hello world"}

  """
  @spec read(t, key) :: {:ok, binary} | {:error, term}
  def read(store, key)

  @doc """
  Stream the file from from the store.

  ## Options

  * `:chunk_size` - The number of bytes for each chunk of data. It can not be
    specified with `:line`.
  * `:line` - Streams the file line by line. It can not be specified with
    `:chunk_size`.
  """
  @spec stream!(t, key, stream_opts) :: Enumerable.t()
  def stream!(store, key, opts \\ [])

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
  Delete files in bulk.

  ## Options

    * `:prefix` - Only delete keys matching the given prefix.

  ## Examples

    iex> FileStore.delete_all(store)
    :ok

    iex> FileStore.delete_all(store, prefix: "foo/")
    :ok

  """
  @spec delete_all(t, delete_all_opts) :: :ok | {:error, term}
  def delete_all(store, opts \\ [])

  @doc """
  Copy a file to a new location.

  ## Examples

      iex> FileStore.copy(store, "path/foo.txt", "path/bar.txt")
      :ok

  """
  @spec copy(t(), key(), key()) :: :ok | {:error, term()}
  def copy(store, src, dest)

  @doc """
  Renames a file from one name to another.

  **Note**: Some underlying adapters can not do this in an atomic fashion.

  ## Examples

      iex> FileStore.rename(store, "path/foo.txt", "path/bar.txt")
      :ok

  """
  @spec rename(t(), key(), key()) :: :ok | {:error, term()}
  def rename(store, src, dest)

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
