defmodule FileStore.Middleware.Logger do
  @moduledoc """
  This middleware allows you to log all operations.

  See the documentation for `FileStore.Middleware` for more information.
  """

  @enforce_keys [:__next__]
  defstruct [:__next__]

  def new(store) do
    %__MODULE__{__next__: store}
  end

  defimpl FileStore do
    require Logger

    def stat(store, key) do
      store.__next__
      |> FileStore.stat(key)
      |> log("STAT", key: key)
    end

    def write(store, key, content) do
      store.__next__
      |> FileStore.write(key, content)
      |> log("WRITE", key: key)
    end

    def read(store, key) do
      store.__next__
      |> FileStore.read(key)
      |> log("READ", key: key)
    end

    def upload(store, source, key) do
      store.__next__
      |> FileStore.upload(source, key)
      |> log("UPLOAD", key: key)
    end

    def download(store, key, dest) do
      store.__next__
      |> FileStore.download(key, dest)
      |> log("DOWNLOAD", key: key)
    end

    def delete(store, key) do
      store.__next__
      |> FileStore.delete(key)
      |> log("DELETE", key: key)
    end

    def delete_all(store, opts) do
      store.__next__
      |> FileStore.delete_all(opts)
      |> log("DELETE ALL", opts)
    end

    def get_public_url(store, key, opts) do
      FileStore.get_public_url(store.__next__, key, opts)
    end

    def get_signed_url(store, key, opts) do
      FileStore.get_signed_url(store.__next__, key, opts)
    end

    def list!(store, opts) do
      FileStore.list!(store.__next__, opts)
    end

    def log(result, msg, meta) do
      case normalize(result) do
        :ok ->
          log_msg(:debug, msg, "OK", meta)

        {:error, extra_meta} ->
          meta = Keyword.merge(meta, extra_meta)
          log_msg(:warn, msg, "ERROR", meta)
      end

      result
    end

    defp log_msg(level, msg, status, meta) do
      Logger.log(level, fn -> [msg, ?\s, status, ?\s, inspect_meta(meta)] end)
    end

    defp normalize(:ok), do: :ok
    defp normalize({:ok, _}), do: :ok
    defp normalize(:error), do: {:error, []}
    defp normalize({:error, reason}), do: {:error, [error: reason]}

    defp inspect_meta(meta) do
      Enum.map_join(meta, " ", fn {key, value} ->
        "#{key}=#{inspect(value)}"
      end)
    end
  end
end
