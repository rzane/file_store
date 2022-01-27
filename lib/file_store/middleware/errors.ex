defmodule FileStore.Middleware.Errors do
  @moduledoc """
  By default, each adapter will return errors in a different format. This
  middleware attempts to make the errors returned by this library a little
  more useful by wrapping them in exception structs:

    * `FileStore.Error`
    * `FileStore.UploadError`
    * `FileStore.DownloadError`
    * `FileStore.CopyError`
    * `FileStore.RenameError`

  Each of these structs contain `reason` field, where you'll find the original
  error that was returned by the underlying adapter.

  One nice feature of this middleware is that it makes it easy to raise:

      store
      |> FileStore.Middleware.Errors.new()
      |> FileStore.read("example.jpg")
      |> case do
        {:ok, data} -> data
        {:error, error} -> raise error
      end

  See the documentation for `FileStore.Middleware` for more information.
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
    alias FileStore.RenameError
    alias FileStore.CopyError

    def stat(store, key) do
      store.__next__
      |> FileStore.stat(key)
      |> wrap(action: "read stats for key", key: key)
    end

    def write(store, key, content, opts) do
      store.__next__
      |> FileStore.write(key, content, opts)
      |> wrap(action: "write to key", key: key)
    end

    def read(store, key) do
      store.__next__
      |> FileStore.read(key)
      |> wrap(action: "read key", key: key)
    end

    def copy(store, src, dest) do
      store.__next__
      |> FileStore.copy(src, dest)
      |> wrap(CopyError, action: "copy", src: src, dest: dest)
    end

    def rename(store, src, dest) do
      store.__next__
      |> FileStore.rename(src, dest)
      |> wrap(RenameError, action: "rename", src: src, dest: dest)
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
