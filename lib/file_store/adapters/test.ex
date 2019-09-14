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
  List all keys that have been uploaded.
  """
  def list_keys do
    Agent.get(__MODULE__, fn keys -> keys end)
  end

  @impl true
  def get_public_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def get_signed_url(_store, key, _opts \\ []), do: {:ok, key}

  @impl true
  def copy(_store, _source, key), do: put_key(key)

  @impl true
  def write(_store, key, _content), do: put_key(key)

  defp put_key(key) do
    Agent.update(__MODULE__, fn keys -> keys ++ [key] end)
  end
end
