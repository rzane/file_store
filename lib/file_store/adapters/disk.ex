defmodule FileStore.Adapters.Disk do
  @moduledoc """
  Stores files on the local disk. This is primarily intended for development.

  ### Configuration

    * `storage_path` - The path on disk where files are
      stored. This option is required.

    * `base_url` - The base URL that should be used for
       generating URLs to your files.

  ### Example

      iex> store = FileStore.new(
      ...>   adapter: FileStore.Adapters.Disk,
      ...>   storage_path: "/path/to/store/files",
      ...>   base_url: "http://example.com/files/"
      ...> )
      %FileStore{...}

      iex> FileStore.write(store, "foo", "hello world")
      :ok

      iex> FileStore.stat("foo")
      {:ok, %FileStore.Stat{key: "foo", ...}}

  """

  @behaviour FileStore.Adapter

  alias FileStore.Stat

  @doc "Get an the path for a given key."
  @spec join(FileStore.t(), binary) :: Path.t()
  def join(store, key) do
    store |> get_storage_path() |> Path.join(key)
  end

  @impl true
  def get_public_url(store, key, _opts \\ []) do
    store |> get_base_url() |> URI.merge(key) |> URI.to_string()
  end

  @impl true
  def get_signed_url(store, key, opts \\ []) do
    {:ok, get_public_url(store, key, opts)}
  end

  @impl true
  def stat(store, key) do
    with path <- join(store, key),
         {:ok, stat} <- File.stat(path),
         {:ok, etag} <- FileStore.Stat.checksum_file(path) do
      {:ok, %Stat{key: key, size: stat.size, etag: etag}}
    end
  end

  @impl true
  def write(store, key, content) do
    with {:ok, path} <- expand(store, key) do
      File.write(path, content)
    end
  end

  @impl true
  def read(store, key) do
    store |> join(key) |> File.read()
  end

  @impl true
  def upload(store, source, key) do
    with {:ok, dest} <- expand(store, key),
         {:ok, _} <- File.copy(source, dest),
         do: :ok
  end

  @impl true
  def download(store, key, dest) do
    with {:ok, source} <- expand(store, key),
         {:ok, _} <- File.copy(source, dest),
         do: :ok
  end

  defp expand(store, key) do
    with path <- join(store, key),
         dir <- Path.dirname(path),
         :ok <- File.mkdir_p(dir),
         do: {:ok, path}
  end

  defp get_storage_path(store) do
    case Map.fetch(store.config, :storage_path) do
      {:ok, path} -> path
      :error -> raise "Disk storage expects a `:storage_path`."
    end
  end

  defp get_base_url(store) do
    case Map.fetch(store.config, :base_url) do
      {:ok, url} -> url
      :error -> raise "Disk storage expects a `:base_url`."
    end
  end
end
