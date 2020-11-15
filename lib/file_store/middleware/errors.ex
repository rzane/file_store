defmodule FileStore.Middleware.Errors do
  @moduledoc """
  Enhances the file store with better error messages.
  """

  @enforce_keys [:__next__]
  defstruct [:__next__]

  def new(store) do
    %__MODULE__{__next__: store}
  end

  defimpl FileStore do
    alias FileStore.Error
    alias FileStore.UploadError
    alias FileStore.DownloadError

    def stat(store, key) do
      store.__next__
      |> FileStore.stat(key)
      |> wrap(action: "read stats for key", key: key)
    end

    def write(store, key, content) do
      store.__next__
      |> FileStore.write(key, content)
      |> wrap(action: "write to key", key: key)
    end

    def read(store, key) do
      store.__next__
      |> FileStore.read(key)
      |> wrap(action: "read key", key: key)
    end

    def upload(store, path, key) do
      store.__next__
      |> FileStore.upload(path, key)
      |> wrap(UploadError, path: path, key: key)
    end

    def download(store, key, path) do
      store.__next__
      |> FileStore.download(key, path)
      |> wrap(DownloadError, path: path, key: key)
    end

    def delete(store, key) do
      store.__next__
      |> FileStore.delete(key)
      |> wrap(action: "delete key", key: key)
    end

    def delete_all(store, opts) do
      prefix = opts[:prefix]

      action =
        if prefix,
          do: "delete keys matching prefix",
          else: "delete all keys"

      store.__next__
      |> FileStore.delete_all(opts)
      |> wrap(action: action, key: opts[:prefix])
    end

    def get_public_url(store, key, opts) do
      FileStore.get_public_url(store.__next__, key, opts)
    end

    def get_signed_url(store, key, opts) do
      store.__next__
      |> FileStore.get_signed_url(key, opts)
      |> wrap(action: "generate signed URL for key", key: key)
    end

    def list!(store, opts) do
      FileStore.list!(store.__next__, opts)
    end

    defp wrap(result, error \\ Error, opts)

    defp wrap({:error, reason}, kind, opts) do
      {:error, struct(kind, Keyword.put(opts, :reason, reason))}
    end

    defp wrap(other, _, _), do: other
  end
end
