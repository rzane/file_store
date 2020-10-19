defmodule FileStore.Utils do
  @moduledoc false

  def join(a, nil), do: a
  def join(a, ""), do: a
  def join(nil, b), do: b
  def join("", b), do: b
  def join(a, b), do: String.trim_trailing(a, "/") <> "/" <> b

  def join_abs_path(a, nil), do: "/" <> String.trim_leading(a)
  def join_abs_path(nil, b), do: "/" <> String.trim_leading(b)

  def join_abs_path(a, b) do
    "/" <> String.trim(a, "/") <> "/" <> String.trim_leading(b, "/")
  end

  def append_path(%URI{path: a} = uri, b) do
    %URI{uri | path: join_abs_path(a, b)}
  end
end
