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
end
