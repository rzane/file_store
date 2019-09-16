defmodule FileStore.Adapters.Disk do
  @behaviour FileStore.Adapter

  @default_base_url "http://localhost:4000/uploads/"

  @impl true
  def get_public_url(store, key, _opts \\ []) do
    store |> get_base_url() |> URI.merge(key) |> URI.to_string()
  end

  @impl true
  def get_signed_url(store, key, _opts \\ []) do
    {:ok, get_public_url(store, key)}
  end

  @impl true
  def write(store, key, content) do
    with {:ok, storage_path} <- ensure_storage_path(store) do
      storage_path
      |> Path.join(key)
      |> File.write(content)
      |> case do
        :ok -> :ok
        _error -> :error
      end
    end
  end

  @impl true
  def upload(store, source, key) do
    with {:ok, storage_path} <- ensure_storage_path(store) do
      destination = Path.join(storage_path, key)

      case File.copy(source, destination) do
        {:ok, _} -> :ok
        _error -> :error
      end
    end
  end

  @impl true
  def download(store, key, destination) do
    with {:ok, storage_path} <- ensure_storage_path(store) do
      storage_path
      |> Path.join(key)
      |> File.copy(destination)
      |> case do
        {:ok, _} -> :ok
        _error -> :error
      end
    end
  end

  defp ensure_storage_path(store) do
    storage_path = get_storage_path(store)

    case File.mkdir_p(storage_path) do
      :ok -> {:ok, storage_path}
      _ -> :error
    end
  end

  defp get_base_url(store) do
    Map.get(store.config, :base_url, @default_base_url)
  end

  defp get_storage_path(store) do
    Map.get_lazy(store.config, :storage_path, &File.cwd!/0)
  end
end
