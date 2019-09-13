defmodule FileStore.Adapters.Disk do
  @behaviour FileStore.Adapter

  @impl true
  def get_public_url(store, key, _opts \\ []) do
    {:ok, join_url(store.config.base_url, key)}
  end

  @impl true
  def get_signed_url(store, key, _opts \\ []) do
    get_public_url(store, key)
  end

  @impl true
  def copy(store, source, key) do
    destination = Path.join(store.config.storage_path, key)

    case File.copy(source, destination) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  @impl true
  def write(store, key, content) do
    destination = Path.join(store.config.storage_path, key)

    case File.write(destination, content) do
      :ok -> :ok
      {:error, _} -> :error
    end
  end

  defp join_url(a, b) do
    String.trim_trailing(a, "/") <> "/" <> String.trim_leading(b, "/")
  end
end
