defmodule FileStore.Config do
  @moduledoc """
  Define a configurable store.

  ### Usage

  First, define a new module:

      defmodule MyApp.Storage do
        use FileStore.Config, otp_app: :my_app
      end

  In your config files, you'll need to configure your adapter:

      config :my_app, MyApp.Storage,
        adapter: FileStore.Adapters.Disk,
        storage_path: "/path/to/files",
        base_url: "https://localhost:4000"

  You can also configure any `FileStore.Middleware` here:

      config :my_app, MyApp.Storage,
        adapter: FileStore.Adapters.Disk,
        # ...etc...
        middleware: [FileStore.Middleware.Errors]

  If you need to dynamically configure your store at runtime,
  you can implement the `init/1` callback.

      def init(opts) do
        Keyword.put(opts, :foo, "bar")
      end

  ### Example

      iex> MyApp.Storage.write("foo", "hello world")
      :ok

      iex> MyApp.Storage.read("foo")
      {:ok, "hello world"}

  """

  defmacro __using__(opts) do
    {otp_app, opts} = Keyword.pop(opts, :otp_app)

    quote location: :keep do
      @spec init(keyword) :: keyword
      def init(opts), do: opts
      defoverridable init: 1

      @spec new() :: FileStore.t()
      def new do
        config = Application.get_env(unquote(otp_app), __MODULE__, [])
        config = unquote(opts) |> Keyword.merge(config) |> init()
        {middlewares, config} = Keyword.pop(config, :middleware, [])

        case Keyword.pop(config, :adapter) do
          {nil, _} ->
            raise "Adapter not specified in #{__MODULE__} configuration"

          {adapter, config} ->
            Enum.reduce(middlewares, adapter.new(config), fn
              {middleware, args}, store -> middleware.new(store, args)
              middleware, store -> middleware.new(store)
            end)
        end
      end

      @spec stat(binary()) :: {:ok, FileStore.Stat.t()} | {:error, term()}
      def stat(key) do
        FileStore.stat(new(), key)
      end

      @spec read(binary()) :: {:ok, binary()} | {:error, term()}
      def read(key) do
        FileStore.read(new(), key)
      end

      @spec write(binary(), binary(), FileStore.write_opts()) :: :ok | {:error, term()}
      def write(key, content, opts \\ []) do
        FileStore.write(new(), key, content, opts)
      end

      @spec delete(binary()) :: :ok | {:error, term()}
      def delete(key) do
        FileStore.delete(new(), key)
      end

      @spec delete_all(FileStore.delete_all_opts()) :: :ok | {:error, term()}
      def delete_all(opts \\ []) do
        FileStore.delete_all(new(), opts)
      end

      @spec copy(FileStore.key(), FileStore.key()) :: :ok | {:error, term()}
      def copy(src, dest) do
        FileStore.copy(new(), src, dest)
      end

      @spec rename(FileStore.key(), FileStore.key()) :: :ok | {:error, term()}
      def rename(src, dest) do
        FileStore.rename(new(), src, dest)
      end

      @spec upload(Path.t(), binary()) :: :ok | {:error, term()}
      def upload(source, key) do
        FileStore.upload(new(), source, key)
      end

      @spec download(binary(), Path.t()) :: :ok | {:error, term()}
      def download(key, destination) do
        FileStore.download(new(), key, destination)
      end

      @spec get_public_url(binary(), Keyword.t()) :: binary()
      def get_public_url(key, opts \\ []) do
        FileStore.get_public_url(new(), key, opts)
      end

      @spec get_signed_url(binary(), Keyword.t()) :: {:ok, binary()} | {:error, term()}
      def get_signed_url(key, opts \\ []) do
        FileStore.get_signed_url(new(), key, opts)
      end

      @spec list! :: Enumerable.t()
      def list!(opts \\ []) do
        FileStore.list!(new(), opts)
      end
    end
  end
end
