defmodule FileStore.Adapters.Memory do
  @moduledoc """
  Stores files in memory. This adapter is particularly
  useful in tests.

  ### Configuration

    * `name` - The name used to register the process.

  ### Example

      iex> store = FileStore.new(adapter: FileStore.Adapters.Memory)
      %FileStore{adapter: FileStore.Adapters.Memory, config: %{}}

      iex> FileStore.write(store, "hello world", "foo")
      :ok

      iex> FileStore.stat(store, "foo")
      {:ok, %FileStore.Stat{key: "foo", ...}}

  ### Usage in tests

      defmodule MyTest do
        use ExUnit.Case

        setup do
          start_supervised!(FileStore.Adapters.Memory)
          :ok
        end

        test "writes a file" do
          store = FileStore.new(adapter: FileStore.Adapters.Memory)
          assert :ok = FileStore.write(store, "foo", "bar")
          assert {:ok, _} = FileStore.stat(store, "bar")
        end
      end

  """

  @behaviour FileStore.Adapter

  use Agent

  alias FileStore.Stat

  @doc "Starts and agent for the test adapter."
  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc "Stops the agent for the test adapter."
  def stop(store, reason \\ :normal, timeout \\ :infinity) do
    Agent.stop(get_name(store), reason, timeout)
  end

  @impl true
  def get_public_url(_store, key, _opts \\ []), do: key

  @impl true
  def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def stat(store, key) do
    store
    |> get_name()
    |> Agent.get(&Map.fetch(&1, key))
    |> case do
      {:ok, data} ->
        {:ok, %Stat{key: key, size: byte_size(data), etag: Stat.checksum(data)}}

      :error ->
        {:error, :enoent}
    end
  end

  @impl true
  def write(store, key, content) do
    store
    |> get_name()
    |> Agent.update(&Map.put(&1, key, content))
  end

  @impl true
  def read(store, key) do
    store
    |> get_name()
    |> Agent.get(&Map.fetch(&1, key))
  end

  @impl true
  def upload(store, source, key) do
    with {:ok, data} <- File.read(source) do
      write(store, key, data)
    end
  end

  @impl true
  def download(store, key, destination) do
    case read(store, key) do
      {:ok, data} -> File.write(destination, data)
      :error -> {:error, :enoent}
    end
  end

  defp get_name(store), do: Map.get(store.config, :name, __MODULE__)
end
