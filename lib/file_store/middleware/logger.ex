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

    def write(store, key, content, opts) do
      store.__next__
      |> FileStore.write(key, content, opts)
      |> log("WRITE", key: key)
    end

    def read(store, key) do
      store.__next__
      |> FileStore.read(key)
      |> log("READ", key: key)
    end

    def copy(store, src, dest) do
      store.__next__
      |> FileStore.copy(src, dest)
      |> log("COPY", src: src, dest: dest)
    end

    def rename(store, src, dest) do
      store.__next__
      |> FileStore.rename(src, dest)
      |> log("RENAME", src: src, dest: dest)
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

    defp log({:ok, value}, msg, meta) do
      log(:ok, msg, meta)
      {:ok, value}
    end

    defp log(:ok, msg, meta) do
      Logger.log(:debug, fn ->
        [msg, ?\s, "OK", ?\s, format_meta(meta)]
      end)

      :ok
    end

    defp log({:error, error}, msg, meta) do
      Logger.log(:error, fn ->
        [msg, ?\s, "ERROR", ?\s, format_meta(meta), format_error(error)]
      end)

      {:error, error}
    end

    defp format_meta(meta) do
      Enum.map(meta, fn {key, value} ->
        [Atom.to_string(key), ?\=, inspect(value)]
      end)
    end

    defp format_error(%{__exception__: true} = error) do
      [?\n, Exception.format(:error, error)]
    end

    defp format_error(error) do
      [" error=", inspect(error)]
    end
  end
end
