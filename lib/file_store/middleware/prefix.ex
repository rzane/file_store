defmodule FileStore.Middleware.Prefix do
  @enforce_keys [:__next__, :prefix]
  defstruct [:__next__, :prefix]

  @doc "Add the prefix adapter to your store."
  def new(store, opts) do
    struct(__MODULE__, Keyword.put(opts, :__next__, store))
  end

  defimpl FileStore do
    alias FileStore.Stat
    alias FileStore.Utils

    def stat(store, key) do
      with {:ok, stat} <- FileStore.stat(store.__next__, put_prefix(key, store)) do
        {:ok, %Stat{stat | key: remove_prefix(stat.key, store)}}
      end
    end

    def delete(store, key) do
      FileStore.delete(store.__next__, put_prefix(key, store))
    end

    def write(store, key, content) do
      FileStore.write(store.__next__, put_prefix(key, store), content)
    end

    def read(store, key) do
      FileStore.read(store.__next__, put_prefix(key, store))
    end

    def upload(store, source, key) do
      FileStore.upload(store.__next__, source, put_prefix(key, store))
    end

    def download(store, key, dest) do
      FileStore.download(store.__next__, put_prefix(key, store), dest)
    end

    def get_public_url(store, key, opts) do
      FileStore.get_public_url(store.__next__, put_prefix(key, store), opts)
    end

    def get_signed_url(store, key, opts) do
      FileStore.get_signed_url(store.__next__, put_prefix(key, store), opts)
    end

    def list!(store, opts) do
      opts = update_key(opts, :prefix, &put_prefix(&1, store))

      store.__next__
      |> FileStore.list!(opts)
      |> Stream.map(&remove_prefix(&1, store))
    end

    defp put_prefix(key, store) do
      Utils.join(store.prefix, key)
    end

    defp remove_prefix(key, store) do
      key
      |> String.trim_leading(store.prefix)
      |> String.trim_leading("/")
    end

    defp update_key(opts, key, fun) do
      case Keyword.fetch(opts, key) do
        {:ok, value} -> Keyword.put(opts, key, fun.(value))
        :error -> opts
      end
    end
  end
end
