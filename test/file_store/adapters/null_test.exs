defmodule FileStore.Adapters.NullTest do
  use ExUnit.Case

  alias FileStore.Adapters.Null

  setup do
    {:ok, store: FileStore.new(adapter: Null)}
  end

  test "get_public_url/2", %{store: store} do
    assert FileStore.get_public_url(store, "foo") == "foo"
  end

  test "get_signed_url/2", %{store: store} do
    assert FileStore.get_signed_url(store, "foo") == {:ok, "foo"}
  end

  test "write/3", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")
  end

  test "read/3", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")
    assert FileStore.read(store, "foo") == {:ok, ""}
  end

  test "download/3", %{store: store} do
    assert :ok = FileStore.download(store, "foo", "download.txt")
  end

  test "upload/3", %{store: store} do
    assert :ok = FileStore.upload(store, "upload.txt", "foo")
  end

  test "stat/2", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")
    assert FileStore.stat(store, "foo") == {:ok, %FileStore.Stat{key: "foo"}}
  end
end
