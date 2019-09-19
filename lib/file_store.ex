defmodule FileStore do
  @moduledoc """
  A unified interface to various file storage backends.

  ## Adapters

    * `FileStore.Adapters.Disk`
    * `FileStore.Adapters.S3`
    * `FileStore.Adapters.Memory`
    * `FileStore.Adapters.Null`
  """

  @behaviour FileStore.Adapter

  defstruct adapter: nil, config: %{}

  @type t() :: %__MODULE__{
          adapter: module(),
          config: map()
        }

  @doc """
  Configures a new store.

  ## Examples

      iex> FileStore.new(adapter: FileStore.Adapters.Null)
      %FileStore{adapter: FileStore.Adapters.Null, config: %{}}

  """
  @spec new(Keyword.t()) :: FileStore.t()
  def new(opts) do
    %__MODULE__{
      adapter: Keyword.fetch!(opts, :adapter),
      config: opts |> Keyword.delete(:adapter) |> Enum.into(%{})
    }
  end

  @impl true
  def write(store, key, content) do
    store.adapter.write(store, key, content)
  end

  @impl true
  def upload(store, source, key) do
    store.adapter.upload(store, source, key)
  end

  @impl true
  def download(store, key, destination) do
    store.adapter.download(store, key, destination)
  end

  @impl true
  def stat(store, key) do
    store.adapter.stat(store, key)
  end

  @impl true
  def get_public_url(store, key, opts \\ []) do
    store.adapter.get_public_url(store, key, opts)
  end

  @impl true
  def get_signed_url(store, key, opts \\ []) do
    store.adapter.get_signed_url(store, key, opts)
  end
end
