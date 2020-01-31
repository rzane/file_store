if Code.ensure_compiled?(ExAws.S3) do
  defmodule FileStore.Adapters.S3 do
    @moduledoc """
    Stores files using Amazon S3.

    ### Dependencies

    To use this adapter, you'll need to install the following dependencies:

        def deps do
          [
            {:ex_aws_s3, "~> 2.0"},
            {:hackney, ">= 0.0.0"},
            {:sweet_xml, ">= 0.0.0"}
          ]
        end

    ### Configuration

      * `bucket` - The name of your S3 bucket. This option
        is required.

      * `base_url` - The base URL that should be used for
        generating the public URLs to your files.

      * `ex_aws` - A keyword list of options that can be
        used to configure `ExAws`.

    ### Example

        iex> store = FileStore.new(
        ...>   adapter: FileStore.Adapters.S3,
        ...>   bucket: "mybucket"
        ...> )
        %FileStore{...}

        iex> FileStore.write(store, "foo", "hello world")
        :ok

        iex> FileStore.read(store, "foo")
        {:ok, "hello world"}

    """

    @behaviour FileStore.Adapter

    alias FileStore.Stat

    @impl true
    def get_public_url(store, key, _opts \\ []) do
      store
      |> get_base_url()
      |> URI.merge(key)
      |> URI.to_string()
    end

    @impl true
    def get_signed_url(store, key, opts \\ []) do
      store
      |> get_config()
      |> ExAws.S3.presigned_url(:get, get_bucket(store), key, opts)
    end

    @impl true
    def stat(store, key) do
      store
      |> get_bucket()
      |> ExAws.S3.head_object(key)
      |> ExAws.request()
      |> case do
        {:ok, %{headers: headers}} ->
          headers = Enum.into(headers, %{})
          etag = headers |> Map.get("ETag") |> unwrap_etag()
          size = headers |> Map.get("Content-Length") |> to_integer()
          {:ok, %Stat{key: key, etag: etag, size: size}}

        {:error, reason} ->
          {:error, reason}
      end
    end

    @impl true
    def write(store, key, content) do
      store
      |> get_bucket()
      |> ExAws.S3.put_object(key, IO.iodata_to_binary(content))
      |> acknowledge(store)
    end

    @impl true
    def read(store, key) do
      store
      |> get_bucket()
      |> ExAws.S3.get_object(key)
      |> request(store)
      |> case do
        {:ok, %{body: body}} -> {:ok, body}
        {:error, reason} -> {:error, reason}
      end
    end

    @impl true
    def upload(store, source, key) do
      source
      |> ExAws.S3.Upload.stream_file()
      |> ExAws.S3.upload(get_bucket(store), key)
      |> acknowledge(store)
    rescue
      error in [File.Error] -> {:error, error.reason}
    end

    @impl true
    def download(store, key, destination) do
      store
      |> get_bucket()
      |> ExAws.S3.download_file(key, destination)
      |> acknowledge(store)
    end

    defp request(op, store) do
      ExAws.request(op, get_overrides(store))
    end

    defp acknowledge(op, store) do
      case request(op, store) do
        {:ok, _} -> :ok
        {:error, reason} -> {:error, reason}
      end
    end

    defp get_base_url(store) do
      Map.get_lazy(store, :base_url, fn ->
        "https://#{get_bucket(store)}.s3-#{get_region(store)}.amazonaws.com"
      end)
    end

    defp get_bucket(store) do
      case Map.fetch(store.config, :bucket) do
        {:ok, bucket} -> bucket
        :error -> raise "S3 storage expects a `:bucket`"
      end
    end

    defp get_region(store), do: store |> get_config() |> Map.fetch!(:region)
    defp get_config(store), do: ExAws.Config.new(:s3, get_overrides(store))
    defp get_overrides(store), do: Map.get(store.config, :ex_aws, [])

    defp unwrap_etag(nil), do: nil
    defp unwrap_etag(etag), do: String.trim(etag, ~s("))

    defp to_integer(nil), do: nil

    defp to_integer(value) when is_binary(value) do
      {value, _} = Integer.parse(value)
      value
    end

    defp to_integer(value), do: value
  end
end
