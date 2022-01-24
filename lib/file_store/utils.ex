defmodule FileStore.Utils do
  @moduledoc false

  def join(nil, nil), do: nil
  def join(a, nil), do: a
  def join(nil, b), do: b

  def join(a, b) do
    String.trim_trailing(a, "/") <> "/" <> String.trim_leading(b, "/")
  end

  def join_absolute(a, b) do
    if path = join(a, b) do
      "/" <> String.trim_leading(path, "/")
    end
  end

  def append_path(%URI{path: a} = uri, b) do
    %URI{uri | path: join_absolute(a, b)}
  end

  def put_query(%URI{query: nil} = uri, query) do
    %URI{uri | query: encode_query(query)}
  end

  def encode_query([]), do: nil
  def encode_query(query), do: URI.encode_query(query)

  @spec rename_key(Keyword.t(), term(), term()) :: Keyword.t()
  def rename_key(opts, key, new_key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} ->
        opts
        |> Keyword.delete(key)
        |> Keyword.put(new_key, value)

      :error ->
        opts
    end
  end
end
