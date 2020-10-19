defmodule FileStore.UtilsTest do
  use ExUnit.Case

  alias FileStore.Utils

  test "join/2" do
    assert Utils.join("a", "b") == "a/b"
    assert Utils.join("a", "b/") == "a/b/"
    assert Utils.join("a/", "b") == "a/b"
    assert Utils.join("a/", "b/") == "a/b/"
    assert Utils.join("a", nil) == "a"
    assert Utils.join(nil, "b") == "b"
    assert Utils.join(nil, nil) == nil
  end

  test "join_absolute/2" do
    assert Utils.join_absolute("a", "b") == "/a/b"
    assert Utils.join_absolute("a", "b/") == "/a/b/"
    assert Utils.join_absolute("/a", "/b/") == "/a/b/"
    assert Utils.join_absolute(nil, "b") == "/b"
    assert Utils.join_absolute("a", nil) == "/a"
    assert Utils.join_absolute(nil, nil) == nil
  end

  test "append_path/2" do
    assert %URI{path: "/bar"} =
             "http://example.com"
             |> URI.parse()
             |> Utils.append_path("bar")

    assert %URI{path: "/foo/bar"} =
             "http://example.com/foo"
             |> URI.parse()
             |> Utils.append_path("bar")

    assert %URI{path: "/foo/bar"} =
             "http://example.com/foo/"
             |> URI.parse()
             |> Utils.append_path("/bar")
  end
end
