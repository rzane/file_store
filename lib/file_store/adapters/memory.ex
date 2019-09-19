defmodule FileStore.Adapters.Memory do
  @behaviour FileStore.Adapter

  use Agent

  alias FileStore.Stat

  @doc """
  Starts and agent for the test adapter.
  """
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Stops the agent for the test adapter.
  """
  def stop(reason \\ :normal, timeout \\ :infinity) do
    Agent.stop(__MODULE__, reason, timeout)
  end

  @doc """
  List all keys that have been uploaded.
  """
  @spec list_keys() :: list(binary())
  def list_keys do
    Agent.get(__MODULE__, &Map.keys/1)
  end

  @doc """
  Check if the given key is in state.
  """
  @spec has_key?(binary()) :: boolean()
  def has_key?(key) do
    Agent.get(__MODULE__, &Map.has_key?(&1, key))
  end

  @doc """
  Get the data associated with a given key.
  """
  @spec fetch(binary()) :: {:ok, iodata()} | :error
  def fetch(key) do
    Agent.get(__MODULE__, &Map.fetch(&1, key))
  end

  @impl true
  def get_public_url(_store, key, _opts \\ []), do: key

  @impl true
  def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def stat(_store, key) do
    case fetch(key) do
      {:ok, data} ->
        {:ok, %Stat{key: key, size: byte_size(data), etag: Stat.checksum(data)}}

      :error ->
        {:error, :enoent}
    end
  end

  @impl true
  def write(_store, key, content) do
    Agent.update(__MODULE__, &Map.put(&1, key, content))
  end

  @impl true
  def upload(store, source, key) do
    with {:ok, data} <- File.read(source) do
      write(store, key, data)
    end
  end

  @impl true
  def download(_store, key, destination) do
    case fetch(key) do
      {:ok, data} -> File.write(destination, data)
      :error -> {:error, :enoent}
    end
  end
end
