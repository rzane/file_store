defmodule FileStore.Config do
  @moduledoc """
  Define a configurable `FileStore`.

      defmodule MyApp.Storage do
        use FileStore.Config, otp_app: :my_app
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
      @callback init(Keyword.t()) :: Keyword.t()
      @optional_callbacks init: 1

      @spec new() :: FileStore.t()
      def new do
        config = Application.get_env(unquote(otp_app), __MODULE__, [])
        config = Keyword.merge(unquote(opts), config)

        if function_exported?(__MODULE__, :init, 1) do
          FileStore.new(init(config))
        else
          FileStore.new(config)
        end
      end

      @spec stat(binary()) :: {:ok, FileStore.Stat.t()} | {:error, term()}
      def stat(key) do
        FileStore.stat(new(), key)
      end

      @spec write(binary(), iodata()) :: :ok | {:error, term()}
      def write(key, content) do
        FileStore.write(new(), key, content)
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
    end
  end
end
