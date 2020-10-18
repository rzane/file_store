defmodule FileStore.UtilsTest do
  use ExUnit.Case

  alias FileStore.Utils

  test "join/2" do
    assert Utils.join("a", "b") == "a/b"
    assert Utils.join("a", "b/") == "a/b/"
    assert Utils.join("a/", "b") == "a/b"
    assert Utils.join("a/", "b/") == "a/b/"
    assert Utils.join("a", nil) == "a"
    assert Utils.join("a", "") == "a"
    assert Utils.join(nil, "b") == "b"
    assert Utils.join("", "b") == "b"
  end
end
