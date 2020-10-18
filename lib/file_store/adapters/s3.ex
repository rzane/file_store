if Code.ensure_loaded?(ExAws.S3) do
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

      * `ex_aws` - A keyword list of options that can be
        used to configure `ExAws`.

      * `prefix` - An optional prefix for the FileStore
        that acts like a parent directory. If the `prefix`
        is `"images"`, then storing a file (`"cat.jpg"`)
        in S3 with this store will have the resolved key
        or `"images/cat.jpg"`. (This is most useful with
        `use FileStore.Config` modules.)

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
    alias FileStore.Utils

    @enforce_keys [:bucket]
    defstruct [:bucket, prefix: nil, ex_aws: []]

    @impl true
    def get_public_url(store, key, _opts \\ []) do
      config = get_config(store)
      scheme = String.trim_trailing(config[:scheme], "://")
      path = "/" <> store.bucket <> "/" <> put_prefix(store, key)

      uri = %URI{
        scheme: scheme,
        host: config[:host],
        port: config[:port],
        path: path
      }

      URI.to_string(uri)
    end

    @impl true
    def get_signed_url(store, key, opts \\ []) do
      config = get_config(store)
      key = put_prefix(store, key)
      ExAws.S3.presigned_url(config, :get, store.bucket, key, opts)
    end

    @impl true
    def stat(store, key) do
      store.bucket
      |> ExAws.S3.head_object(put_prefix(store, key))
      |> request(store)
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
    def delete(store, key) do
      store.bucket
      |> ExAws.S3.delete_object(key)
      |> acknowledge(store)
    end

    @impl true
    def write(store, key, content) do
      store.bucket
      |> ExAws.S3.put_object(put_prefix(store, key), content)
      |> acknowledge(store)
    end

    @impl true
    def read(store, key) do
      store.bucket
      |> ExAws.S3.get_object(put_prefix(store, key))
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
      |> ExAws.S3.upload(store.bucket, put_prefix(store, key))
      |> acknowledge(store)
    rescue
      error in [File.Error] -> {:error, error.reason}
    end

    @impl true
    def download(store, key, destination) do
      store.bucket
      |> ExAws.S3.download_file(put_prefix(store, key), destination)
      |> acknowledge(store)
    end

    @impl true
    def list!(store, opts \\ []) do
      prefix = put_prefix(store, opts[:prefix])

      store.bucket
      |> ExAws.S3.list_objects(prefix: prefix)
      |> ExAws.stream!(store.ex_aws)
      |> Stream.map(fn file -> file.key end)
    end

    defp request(op, store) do
      ExAws.request(op, store.ex_aws)
    end

    defp acknowledge(op, store) do
      case request(op, store) do
        {:ok, _} -> :ok
        {:error, reason} -> {:error, reason}
      end
    end

    defp get_config(store), do: ExAws.Config.new(:s3, store.ex_aws)
    defp put_prefix(store, key), do: Utils.join(store.prefix, key)

    defp unwrap_etag(nil), do: nil
    defp unwrap_etag(etag), do: String.trim(etag, ~s("))

    defp to_integer(nil), do: nil
    defp to_integer(value) when is_integer(value), do: value
    defp to_integer(value) when is_binary(value), do: String.to_integer(value)
  end
end
