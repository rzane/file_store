defmodule FileStore.Adapters.Error do
  @moduledoc false

  defstruct []

  def new do
    %__MODULE__{}
  end

  defimpl FileStore do
    def write(_store, _key, _content, _opts \\ []), do: {:error, :boom}
    def read(_store, _key), do: {:error, :boom}

    def stream!(_store, key, _opts \\ []) do
      raise FileStore.Error, reason: "Does not work", key: key, action: "stream"
    end

    def upload(_store, _source, _key), do: {:error, :boom}
    def download(_store, _key, _destination), do: {:error, :boom}
    def stat(_store, _key), do: {:error, :boom}
    def delete(_store, _key), do: {:error, :boom}
    def delete_all(_store, _opts \\ []), do: {:error, :boom}
    def copy(_store, _src, _dest), do: {:error, :boom}
    def rename(_store, _src, _dest), do: {:error, :boom}
    def get_public_url(_store, key, _opts \\ []), do: key
    def get_signed_url(_store, _key, _opts \\ []), do: {:error, :boom}
    def list!(_store, _opts \\ []), do: []
  end
end
