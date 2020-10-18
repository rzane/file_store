defmodule FileStore.Adapters.Memory do
  @moduledoc """
  Stores files in memory. This adapter is particularly
  useful in tests.

  ### Configuration

    * `name` - The name used to register the process.

    * `base_url` - The base URL that should be used for
       generating URLs to your files.

  ### Example

      iex> store = FileStore.Adapters.Memory.new(base_url: "http://example.com/files/")
      %FileStore.Adapters.Memory{...}

      iex> FileStore.write(store, "foo", "hello world")
      :ok

      iex> FileStore.read(store, "foo")
      {:ok, "hello world"}

  ### Usage in tests

      defmodule MyTest do
        use ExUnit.Case

        setup do
          start_supervised!(FileStore.Adapters.Memory)
          :ok
        end

        test "writes a file" do
          store = FileStore.Adapters.Memory.new()
          assert :ok = FileStore.write(store, "foo", "bar")
          assert {:ok, "bar"} = FileStore.read(store, "foo")
        end
      end

  """

  use Agent

  @enforce_keys [:base_url]
  defstruct [:base_url, name: __MODULE__]

  @doc "Creates a new memory adapter"
  @spec new(keyword) :: FileStore.t()
  def new(opts) do
    struct(__MODULE__, opts)
  end

  @doc "Starts an agent for the test adapter."
  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc "Stops the agent for the test adapter."
  def stop(store, reason \\ :normal, timeout \\ :infinity) do
    Agent.stop(store.name, reason, timeout)
  end

  defimpl FileStore do
    alias FileStore.Stat
    alias FileStore.Utils

    def get_public_url(store, key, _opts \\ []) do
      store.base_url
      |> URI.parse()
      |> Utils.append_path(key)
      |> URI.to_string()
    end

    def get_signed_url(store, key, opts \\ []) do
      {:ok, get_public_url(store, key, opts)}
    end

    def stat(store, key) do
      store.name
      |> Agent.get(&Map.fetch(&1, key))
      |> case do
        {:ok, data} ->
          {:ok, %Stat{key: key, size: byte_size(data), etag: Stat.checksum(data)}}

        :error ->
          {:error, :enoent}
      end
    end

    def delete(store, key) do
      Agent.update(store.name, &Map.delete(&1, key))
    end

    def write(store, key, content) do
      Agent.update(store.name, &Map.put(&1, key, content))
    end

    def read(store, key) do
      Agent.get(store.name, &Map.fetch(&1, key))
    end

    def upload(store, source, key) do
      with {:ok, data} <- File.read(source) do
        write(store, key, data)
      end
    end

    def download(store, key, destination) do
      case read(store, key) do
        {:ok, data} -> File.write(destination, data)
        :error -> {:error, :enoent}
      end
    end

    def list!(store, opts \\ []) do
      prefix = Keyword.get(opts, :prefix, "")

      store.name
      |> Agent.get(&Map.keys/1)
      |> Stream.filter(&String.starts_with?(&1, prefix))
    end
  end
end
