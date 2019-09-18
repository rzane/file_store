defmodule FileStore do
  @moduledoc """
  A really generic way to store files.
  """

  @behaviour FileStore.Adapter

  @type t() :: %__MODULE__{}

  defstruct adapter: nil, config: %{}

  @doc """
  Define a configurable FileStore.

      defmodule MyApp.Storage do
        use FileStore, otp_app: :my_app
      end

  Then, add this to your config:

      config :my_app, MyApp.Storage,
        adapter: FileStore.Adapters.Disk

  Your can use this module like so:

      iex> MyApp.Storage.stat("foo")
      {:ok, %FileStorage.Stat{}}

  """
  defmacro __using__(opts) do
    {otp_app, opts} = Keyword.pop(opts, :otp_app)

    quote location: :keep do
      @spec new() :: FileStore.t()
      def new do
        config = Application.get_env(unquote(otp_app), __MODULE__, [])
        unquote(opts) |> Keyword.merge(config) |> FileStore.new()
      end

      @spec stat(binary()) :: {:ok, FileStore.Stat.t()} | {:error, term()}
      def stat(key), do: FileStore.stat(new(), key)

      @spec write(binary(), iodata()) :: :ok | {:error, term()}
      def write(key, content), do: FileStore.write(new(), key, content)

      @spec upload(Path.t(), binary()) :: :ok | {:error, term()}
      def upload(source, key), do: FileStore.upload(new(), source, key)

      @spec download(binary(), Path.t()) :: :ok | {:error, term()}
      def download(key, destination), do: FileStore.download(new(), key, destination)

      @spec get_public_url(binary(), Keyword.t()) :: binary()
      def get_public_url(key, opts \\ []), do: FileStore.get_public_url(new(), key, opts)

      @spec get_signed_url(binary(), Keyword.t()) :: {:ok, binary()} | {:error, term()}
      def get_signed_url(key, opts \\ []), do: FileStore.get_signed_url(new(), key, opts)
    end
  end

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
