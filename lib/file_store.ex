defmodule FileStore do
  @moduledoc """
  A really generic way to store files.
  """

  @behaviour FileStore.Adapter

  @type t() :: %__MODULE__{}

  defstruct adapter: nil, config: %{}

  def new(opts) do
    {adapter, opts} = Keyword.pop(opts, :adapter, FileStore.Adapters.Null)
    config = Enum.into(opts, %{})
    %__MODULE__{adapter: adapter, config: config}
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
  def download(store, key, destionation) do
    store.adapter.download(store, key, destionation)
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
