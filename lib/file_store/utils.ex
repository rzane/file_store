defmodule FileStore.Utils do
  @moduledoc false

  def join(a, nil), do: a
  def join(a, ""), do: a
  def join(nil, b), do: b
  def join("", b), do: b
  def join(a, b), do: String.trim_trailing(a, "/") <> "/" <> b
end
