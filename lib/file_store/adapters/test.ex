defmodule FileStore.Adapters.Test do
  @behaviour FileStore.Adapter

  use Agent

  @doc """
  Starts and agent for the test adapter.
  """
  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc """
  Stops the agent for the test adapter.
  """
  def stop(reason \\ :normal, timeout \\ :infinity) do
    Agent.stop(__MODULE__, reason, timeout)
  end

  @doc """
  Get all files.
  """
  def get_files do
    Agent.get(__MODULE__, fn state -> state end)
  end

  @doc """
  Add an file to the state.
  """
  def put_file(key) do
    Agent.update(__MODULE__, fn state -> state ++ [key] end)
  end

  @impl true
  def get_public_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def copy(_store, _source, key) do
    put_file(key)
    :ok
  end

  @impl true
  def write(_store, key, _content) do
    put_file(key)
    :ok
  end
end
