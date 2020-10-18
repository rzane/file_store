defmodule FileStore do
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

  @behaviour FileStore.Adapter

  @type key :: binary
  @type url :: binary
  @type path :: Path.t()
  @type t :: %{:__struct__ => FileStore.Adapter, optional(atom()) => any()}

  @doc """
  Configures a new store.

  ## Examples

      iex> FileStore.new(adapter: FileStore.Adapters.Memory)
      %FileStore{adapter: FileStore.Adapters.Memory, config: %{}}

  """
  @spec new(keyword) :: t()
  def new(config) do
    {adapter, config} = Keyword.pop!(config, :adapter)
    struct(adapter, config)
  end

  @doc """
  Write a file to the store. If a file with the given `key`
  already exists, it will be overwritten.

  ## Examples

      iex> FileStore.write(store, "foo", "hello world")
      :ok

  """
  @impl true
  @spec write(t, key, binary) :: :ok | {:error, term}
  def write(store, key, content) do
    store.__struct__.write(store, key, content)
  end

  @doc """
  Read the contents of a file in store into memory.

  ## Examples

      iex> FileStore.read(store, "foo")
      {:ok, "hello world"}

  """
  @impl true
  @spec read(t, key) :: {:ok, binary} | {:error, term}
  def read(store, key) do
    store.__struct__.read(store, key)
  end

  @doc """
  Upload a file to the store. If a file with the given `key`
  already exists, it will be overwritten.

  ## Examples

      iex> FileStore.upload(store, "/path/to/bar.txt", "foo")
      :ok

  """
  @impl true
  @spec upload(t, path, key) :: :ok | {:error, term}
  def upload(store, source, key) do
    store.__struct__.upload(store, source, key)
  end

  @doc """
  Download a file from the store and save it to the given `path`.

  ## Examples

      iex> FileStore.download(store, "foo", "/path/to/bar.txt")
      :ok

  """
  @impl true
  @spec download(t, key, path) :: :ok | {:error, term}
  def download(store, key, destination) do
    store.__struct__.download(store, key, destination)
  end

  @doc """
  Retrieve information about a file from the store.

  ## Examples

      iex> FileStore.stat(store, "foo")
      {:ok, %FileStore.Stat{key: "foo", etag: "2e5pd429", size: 24}}

  """
  @impl true
  @spec stat(t, key) :: {:ok, FileStore.Stat.t()} | {:error, term}
  def stat(store, key) do
    store.__struct__.stat(store, key)
  end

  @doc """
  Delete a file from the store.

  ## Examples

    iex> FileStore.delete(store, "foo")
    :ok

  """
  @impl true
  @spec delete(t, key) :: :ok | {:error, term}
  def delete(store, key) do
    store.__struct__.delete(store, key)
  end

  @doc """
  Get URL for your file, assuming that the file is publicly accessible.

  ## Examples

      iex> FileStore.get_public_url(store, "foo")
      "https://mybucket.s3-us-east-1.amazonaws.com/foo"

  """
  @impl true
  @spec get_public_url(t, key, keyword) :: url
  def get_public_url(store, key, opts \\ []) do
    store.__struct__.get_public_url(store, key, opts)
  end

  @doc """
  Generate a signed URL for your file. Any user with this URL should be able
  to access the file.

  ## Examples

      iex> FileStore.get_signed_url(store, "foo")
      {:ok, "https://s3.amazonaws.com/mybucket/foo?X-AMZ-Expires=3600&..."}

  """
  @impl true
  @spec get_signed_url(t, key, keyword) :: {:ok, url} | {:error, term}
  def get_signed_url(store, key, opts \\ []) do
    store.__struct__.get_signed_url(store, key, opts)
  end

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
  @impl true
  @spec list!(t) :: Enumerable.t()
  def list!(store, opts \\ []) do
    store.__struct__.list!(store, opts)
  end
end
