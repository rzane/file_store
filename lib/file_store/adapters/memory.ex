defmodule FileStore.Adapters.Memory do
  @moduledoc """
  Stores files in memory. This adapter is particularly
  useful in tests.

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
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc "Stops the agent for the test adapter."
  def stop(reason \\ :normal, timeout \\ :infinity) do
    Agent.stop(__MODULE__, reason, timeout)
  end

  @doc "Get the data associated with a given key."

  @impl true
  def get_public_url(_store, key, _opts \\ []), do: key

  @impl true
  def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def stat(_store, key) do
    case Agent.get(__MODULE__, &Map.fetch(&1, key)) do
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
    case Agent.get(__MODULE__, &Map.fetch(&1, key)) do
      {:ok, data} -> File.write(destination, data)
      :error -> {:error, :enoent}
    end
  end
end
