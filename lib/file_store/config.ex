defmodule FileStore.Config do
  @moduledoc """
  Define a configurable store.

  ### Usage

  First, define a new module:

      defmodule Storage do
        use FileStore.Config, otp_app: :my_app
      end

  In your config files, you'll need to configure your adapter:

      config :my_app, Storage,
        adapter: FileStore.Adapters.Memory

  If you need to dynamically configure your store at runtime,
  you can implement the `init/1` callback.

      def init(opts) do
        Keyword.put(opts, :foo, "bar")
      end

  ### Example

      iex> Storage.write("hello world", "foo")
      :ok

      iex> Storage.stat("foo")
      {:ok, %FileStore.Stat{key: "foo", ...}}

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

        unquote(opts)
        |> Keyword.merge(config)
        |> init()
        |> FileStore.new()
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
