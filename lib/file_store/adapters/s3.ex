if Code.ensure_loaded?(ExAws.S3) do
  defmodule FileStore.Adapters.S3 do
    @moduledoc """
    Stores files using Amazon S3.

    ### Dependencies

    To use this adapter, you'll need to install and configure `ExAws.S3`.

    ### Configuration

      * `bucket` - The name of your S3 bucket. This option
        is required.

      * `ex_aws` - A keyword list of options that can be
        used to override the default configuration for `ExAws`.

    ### Example

        iex> store = FileStore.Adapters.S3.new(
        ...>   bucket: "mybucket"
        ...> )
        %FileStore.Adapters.S3{...}

        iex> FileStore.write(store, "foo", "hello world")
        :ok

        iex> FileStore.read(store, "foo")
        {:ok, "hello world"}

    """

    @enforce_keys [:bucket]
    defstruct [:bucket, ex_aws: []]

    @doc "Create a new S3 adapter"
    @spec new(keyword) :: FileStore.t()
    def new(opts) do
      if is_nil(opts[:bucket]) do
        raise "missing configuration: :bucket"
      end

      struct(__MODULE__, opts)
    end

    defimpl FileStore do
      alias FileStore.Stat
      alias FileStore.Utils

      @query_params [
        content_type: "response-content-type",
        disposition: "response-content-disposition"
      ]

      def get_public_url(store, key, opts) do
        config = get_config(store)
        host = store.bucket <> "." <> config[:host]
        query = Utils.encode_query(get_url_query(opts))
        scheme = String.trim_trailing(config[:scheme], "://")

        uri = %URI{
          scheme: scheme,
          host: host,
          port: config[:port],
          path: "/" <> key,
          query: query
        }

        URI.to_string(uri)
      end

      def get_signed_url(store, key, opts) do
        config = get_config(store)

        opts =
          opts
          |> Keyword.take([:expires_in])
          |> Keyword.put(:virtual_host, true)
          |> Keyword.put(:query_params, get_url_query(opts))

        ExAws.S3.presigned_url(config, :get, store.bucket, key, opts)
      end

      def stat(store, key) do
        store.bucket
        |> ExAws.S3.head_object(key)
        |> request(store)
        |> case do
          {:ok, %{headers: headers}} ->
            headers = Enum.into(headers, %{})
            etag = headers |> Map.get("ETag") |> unwrap_etag()
            size = headers |> Map.get("Content-Length") |> to_integer()
            type = headers |> Map.get("Content-Type")
            {:ok, %Stat{key: key, etag: etag, size: size, type: type}}

          {:error, reason} ->
            {:error, reason}
        end
      end

      def delete(store, key) do
        store.bucket
        |> ExAws.S3.delete_object(key)
        |> acknowledge(store)
      end

      def delete_all(store, opts) do
        store.bucket
        |> ExAws.S3.delete_all_objects(list!(store, opts))
        |> acknowledge(store)
      rescue
        error -> {:error, error}
      end

      def write(store, key, content, opts \\ []) do
        opts =
          opts
          |> Keyword.take([:content_type, :disposition])
          |> Utils.rename_key(:disposition, :content_disposition)

        store.bucket
        |> ExAws.S3.put_object(key, content, opts)
        |> acknowledge(store)
      end

      def read(store, key) do
        store.bucket
        |> ExAws.S3.get_object(key)
        |> request(store)
        |> case do
          {:ok, %{body: body}} -> {:ok, body}
          {:error, reason} -> {:error, reason}
        end
      end

      def stream!(store, key, opts) do
        aws_opts = Keyword.take(opts, [:chunk_size])

        stream =
          store.bucket
          |> ExAws.S3.download_file(key, :memory, aws_opts)
          |> ExAws.stream!()

        if opts[:line] do
          stream
          |> Stream.chunk_while("", &chunk_by_fun/2, &to_line_stream_after_fun/1)
          |> Stream.concat()
        else
          stream
        end
      end

      def upload(store, source, key) do
        source
        |> ExAws.S3.Upload.stream_file()
        |> ExAws.S3.upload(store.bucket, key)
        |> acknowledge(store)
      rescue
        error in [File.Error] -> {:error, error.reason}
      end

      def download(store, key, destination) do
        store.bucket
        |> ExAws.S3.download_file(key, destination)
        |> acknowledge(store)
      end

      def list!(store, opts) do
        opts = Keyword.take(opts, [:prefix])

        store.bucket
        |> ExAws.S3.list_objects(opts)
        |> ExAws.stream!(store.ex_aws)
        |> Stream.map(fn file -> file.key end)
      end

      def copy(store, src, dest) do
        store.bucket
        |> ExAws.S3.put_object_copy(dest, store.bucket, src)
        |> acknowledge(store)
      end

      def rename(store, src, dest) do
        with :ok <- copy(store, src, dest) do
          delete(store, src)
        end
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

      defp get_url_query(opts) do
        for {key, query_param} <- @query_params,
            value = Keyword.get(opts, key),
            into: [],
            do: {query_param, value}
      end

      defp get_config(store), do: ExAws.Config.new(:s3, store.ex_aws)

      defp unwrap_etag(nil), do: nil
      defp unwrap_etag(etag), do: String.trim(etag, ~s("))

      defp to_integer(nil), do: nil
      defp to_integer(value) when is_integer(value), do: value
      defp to_integer(value) when is_binary(value), do: String.to_integer(value)

      defp chunk_by_fun(chunk, acc) do
        to_try = acc <> chunk
        {elements, acc} = chunk_by_newline(to_try, "\n", [], {0, byte_size(to_try)})
        {:cont, elements, acc}
      end

      defp chunk_by_newline(_string, _newline, elements, {_offset, 0}) do
        {Enum.reverse(elements), ""}
      end

      defp chunk_by_newline(string, newline, elements, {offset, length}) do
        case :binary.match(string, newline, scope: {offset, length}) do
          {newline_offset, newline_length} ->
            difference = newline_length + newline_offset - offset
            element = binary_part(string, offset, difference)

            chunk_by_newline(
              string,
              newline,
              [element | elements],
              {newline_offset + newline_length, length - difference}
            )

          :nomatch ->
            {Enum.reverse(elements), binary_part(string, offset, length)}
        end
      end

      defp to_line_stream_after_fun(""), do: {:cont, []}
      defp to_line_stream_after_fun(acc), do: {:cont, [acc], []}
    end
  end
end
