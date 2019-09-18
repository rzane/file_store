defmodule FileStore.Adapters.Disk do
  alias FileStore.Stat

  @behaviour FileStore.Adapter

  @default_base_url "http://localhost:4000/storage/disk/"

  @spec get_path(FileStore.t(), binary()) :: {:ok, Path.t()} | {:error, File.posix()}
  def get_path(store, key) do
    with {:ok, storage_path} <- get_storage_path(store),
         do: {:ok, Path.join(storage_path, key)}
  end

  @impl true
  def get_public_url(store, key, _opts \\ []) do
    store |> get_base_url() |> URI.merge(key) |> URI.to_string()
  end

  @impl true
  def get_signed_url(store, key, _opts \\ []) do
    {:ok, get_public_url(store, key)}
  end

  @impl true
  def stat(store, key) do
    with {:ok, storage_path} <- get_storage_path(store),
         path <- Path.join(storage_path, key),
         {:ok, stat} <- File.stat(path),
         {:ok, etag} <- FileStore.Stat.compute_checksum(path) do
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
    with {:ok, storage_path} <- get_storage_path(store),
         path <- Path.join(storage_path, key),
         dir <- Path.dirname(path),
         :ok <- File.mkdir_p(dir),
         do: {:ok, path}
  end

  defp get_storage_path(store) do
    case Map.fetch(store.config, :storage_path) do
      {:ok, path} ->
        {:ok, path}

      :error ->
        with {:ok, cwd} <- File.cwd() do
          {:ok, Path.join(cwd, "storage")}
        end
    end
  end

  defp get_base_url(store) do
    Map.get(store.config, :base_url, @default_base_url)
  end
end
