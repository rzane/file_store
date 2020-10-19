defmodule FileStore.Adapters.Disk do
  @moduledoc """
  Stores files on the local disk. This is primarily intended for development.

  ### Configuration

    * `storage_path` - The path on disk where files are
      stored. This option is required.

    * `base_url` - The base URL that should be used for
       generating URLs to your files.

  ### Example

      iex> store = FileStore.Adapters.Disk.new(
      ...>   storage_path: "/path/to/store/files",
      ...>   base_url: "http://example.com/files/"
      ...> )
      %FileStore.Adapters.Disk{...}

      iex> FileStore.write(store, "foo", "hello world")
      :ok

      iex> FileStore.read(store, "foo")
      {:ok, "hello world"}

  """

  @enforce_keys [:storage_path, :base_url]
  defstruct [:storage_path, :base_url]

  @doc "Create a new disk adapter"
  @spec new(keyword) :: FileStore.t()
  def new(opts) do
    struct(__MODULE__, opts)
  end

  @doc "Get an the path for a given key."
  @spec join(FileStore.t(), binary) :: Path.t()
  def join(store, key) do
    Path.join(store.storage_path, key)
  end

  defimpl FileStore do
    alias FileStore.Stat
    alias FileStore.Utils
    alias FileStore.Adapters.Disk

    def get_public_url(store, key, _opts) do
      store.base_url
      |> URI.parse()
      |> Utils.append_path(key)
      |> URI.to_string()
    end

    def get_signed_url(store, key, opts) do
      {:ok, get_public_url(store, key, opts)}
    end

    def stat(store, key) do
      with path <- Disk.join(store, key),
           {:ok, stat} <- File.stat(path),
           {:ok, etag} <- FileStore.Stat.checksum_file(path) do
        {:ok, %Stat{key: key, size: stat.size, etag: etag}}
      end
    end

    def delete(store, key) do
      case File.rm(Disk.join(store, key)) do
        :ok -> :ok
        {:error, reason} when reason in [:enoent, :enotdir] -> :ok
        {:error, reason} -> {:error, reason}
      end
    end

    def write(store, key, content) do
      with {:ok, path} <- expand(store, key) do
        File.write(path, content)
      end
    end

    def read(store, key) do
      store |> Disk.join(key) |> File.read()
    end

    def upload(store, source, key) do
      with {:ok, dest} <- expand(store, key),
           {:ok, _} <- File.copy(source, dest),
           do: :ok
    end

    def download(store, key, dest) do
      with {:ok, source} <- expand(store, key),
           {:ok, _} <- File.copy(source, dest),
           do: :ok
    end

    def list!(store, opts) do
      prefix = Keyword.get(opts, :prefix, "")

      store.storage_path
      |> Path.join(prefix)
      |> Path.join("**/*")
      |> Path.wildcard(match_dot: true)
      |> Stream.reject(&File.dir?/1)
      |> Stream.map(&Path.relative_to(&1, store.storage_path))
    end

    defp expand(store, key) do
      with path <- Disk.join(store, key),
           dir <- Path.dirname(path),
           :ok <- File.mkdir_p(dir),
           do: {:ok, path}
    end
  end
end
